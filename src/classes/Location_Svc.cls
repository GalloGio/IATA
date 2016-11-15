public class Location_Svc {

	//Method to set the BillTo and ShipTo Contact AccountId
	public static void setLocationAccountId(List<Location__c> locations, Map<Id, Location__c> mapOldLocation, Boolean toInsert){
		
		set<Id> contactIds = new set<Id>();
		Map<Id,Contact> contactMap = new map<Id,Contact>();

		for(Location__c location : locations){
			//for Insert a new Location
			if(toInsert && location.Contact__c != null && (location.Type__c == IECConstants.BILLTO || location.Type__c == IECConstants.SHIPTO)){
				contactIds.add(location.Contact__c);
			}
			// for Update
			if(!toInsert && location.Contact__c != null &&  location.Contact__c != mapOldLocation.get(location.Id).Contact__c && 
				(location.Type__c == IECConstants.BILLTO || location.Type__c == IECConstants.SHIPTO))
			{
				contactIds.add(location.Contact__c);
			}
		}

		//Get the Contact with the Account information
		if(contactIds.size() > 0){
			contactMap = Contact_Sel.getContactById(contactIds);
		
			//Set the Location account id with 
			if(contactMap.size() > 0){
				for(Location__c location : locations)
					if (toInsert && location.Contact__c != null && (location.Type__c == IECConstants.BILLTO || location.Type__c == IECConstants.SHIPTO)) {
						Contact contact = contactMap.get(location.Contact__c);
						location.Account__c = (contact.Account.ParentId != null) ? contact.Account.ParentId : contact.AccountId;
					}
			}
		}

	}

	/**
	 * Function will sync any new inserts on Locations object to SAP
	 **/
	//Sync Locations with SAP when a location is created or edited
	public static void SendLocationToSAP(List<Location__c> locations){
		if(locations == null || locations.size() == 0) return; 
		
		system.debug('in SendLocationToSAP');
		
		set<Id> accountIds = new set<Id>();
		map<Id,Location__c> accountId_Location = new map<Id,Location__c>();
		List<Location__c> toCreateSoldToLocation = new List<Location__c>();

		// The list of Location Ids that will be synced with SAP
		Set<Id> setSoldToIdsToSAP = new Set<Id>();
    	
		for(Location__c location : locations){
			/* Commented till figure out whether we are going to filter using recordtypes or not
			// Retrieve list of RecordTypeIds that are allowed to be synced to SAP
			String sAccRecTypeToSAP = Utility.getTextSetting('Account Record Type IDs to sync to SAP');
			*/
			/* Commented till figure out whether we are going to filter using recordtypes or not
    		// Make sure that the account has the required RecType
	    	if (sAccRecTypeToSAP.contains(location.Account_Record_Type_Id__c))
	    	{
		    	*/
		    	// Sync SOLD-TO Accounts to SAP
		    	if (location.Type__c == 'Sold To'
			    	// Only if it is active As Sold-To Deactivation only happens from SAP
			    	&& location.Active__c)
		    	{
		    		setSoldToIdsToSAP.add(location.Id);
		    	}
	    	/*}*/

			//verified if the bill to and Ship to is related to a contact
			if((location.Type__c == IECConstants.BILLTO || location.Type__c == IECConstants.SHIPTO) && location.Contact__c != null){
				accountIds.add(location.Account__c);
			}
		}

		//get the list of location by Account
		if(accountIds.size() > 0){
			//get the Location by Account Id
			accountId_Location = new Location_Sel().getSoldToAccountLocation(accountIds);
		}

		//
		set<Id> soldToLocationIds2CreateFirst = new set<Id>();
		set<Id> locationIds = new set<Id>();
		for(Location__c location : locations){
			//verified if the bill to and Ship to is related to a contact
			if((location.Type__c == IECConstants.BILLTO || location.Type__c == IECConstants.SHIPTO) && location.Contact__c != null){
				//Get the Account Location information
				Location__c soldToLocation = accountId_Location.get(location.Account__c);
				//check if the sold to location is active before sync
				if(soldToLocation != null && soldToLocation.Active__c){
					locationIds.add(location.Id);
					if(soldToLocation.SAP_Id__c == null){
						soldToLocationIds2CreateFirst.add(location.Id);
					}
				}else{
					//BillTo or ShipTo location to Create
					if(soldToLocation == null) toCreateSoldToLocation.add(location);
				}
			}
		}

		// Make the SAP call to update the account/contact
	    if (!setSoldToIdsToSAP.isEmpty())
	    {
	    	IECAddress_Svc.syncCustomerMasterWithSAP(setSoldToIdsToSAP);
	    }

	    if(toCreateSoldToLocation.size() > 0) List<Location__c> createdLocation = locationToCreate(toCreateSoldToLocation);

		//Call SAP to sync the Customer information
		if(soldToLocationIds2CreateFirst.size() > 0) IECAddress_Svc.syncCustomerMasterWithSAP(locationIds,soldToLocationIds2CreateFirst);
		else IECAddress_Svc.syncCustomerMasterWithSAP(locationIds);
		
	}

	//sold to Location to create
	public static List<Location__c> locationToCreate(List<Location__c> toCreateSoldToLocation){

		List<Location__c> locationsToInsert = new List<Location__c>();
		set<Id> createdLocation = new set<Id>();

		set<Id> contactIds = new set<Id>();

		//Get the contactIds
		for(Location__c loca : toCreateSoldToLocation){
			contactIds.add(loca.Contact__c);
		}

		map<Id,Contact> contactMap = Contact_Sel.getContactById(contactIds);

		for(Location__c location : toCreateSoldToLocation){
			//Get the related contact
			Contact contact = contactMap.get(location.Contact__c);

			//Create the new sold to location to insert
			Location__c newLocation = new Location__c();
			newLocation.Type__c = IECConstants.SOLDTO;
			newLocation.Address__c = location.Address__c;
			newLocation.Active__c = true;
			newLocation.Account__c = (contact.Account.ParentId != null) ? contact.Account.ParentId : contact.AccountId;
			locationsToInsert.add(newLocation);
		}

		if(locationsToInsert.size() > 0){
			try{
				insert locationsToInsert;
			}catch(Exception ex){
				IECErrorLogger.logApexException('Location_Svc.locationToCreate', JSON.serialize(toCreateSoldToLocation), ex.getMessage(), ex.getStackTraceString());
			}
		}
		return locationsToInsert;
	}


	/**
	 * Function will prepare a batch job to make api object update to Zuora with updated contacts' address
	 *
	 * @param setLocationId The set of Location__c Ids that has been modified
	 */
	public static void syncLocationsWithZuora(Set<Id> setLocationId) {
		try {

			String query  = ' SELECT Id, Contact__c, Account__c, Address__c, Type__c, Account_Contact_ID__c' +
            '   , Contact_First_Name__c, Contact_Last_Name__c, Contact_Email__c, Email__c, Contact_Phone__c, Phone__c' +
            '   , Country__c, State__c, City__c, ZipCode__c, Street__c, VAT_Number__c, SAP_Id__c' +  
            '   FROM Location__c WHERE Account__c <> NULL' +
            '   AND Contact__c <> NULL ' +
            '   AND Id IN :setLocationId' +
            '   AND Active__c = true' +
            '   AND Type__c = \'Bill To\'';

            List<Location__c> lstLocation = Database.query(query);

            //Call by queueable if less than 50000 locations
            if(lstLocation != null && lstLocation.size() > 0)
                Id jobID = System.enqueueJob(new ContactAddressZSync_Queueable(lstLocation, setLocationId, 'Location'));
			
		}
		//Call Batch if we have more than 50000 locations
		catch(LimitException e){Database.ExecuteBatch(new ContactAddressZSync_Batch(setLocationId, 'Location'));}
		catch (Exception ex) {IECErrorLogger.logApexException('Location_Svc.syncLocationsWithZuora', 'setLocationId: ' + setLocationId, ex.getMessage(), ex.getStackTraceString());}
	}
	
	
	/**
	 * Function will sync any new updates on Locations object to SAP and Zuora
	 **/
	public static void syncLocationsUpdateWithExternalSystems(List<Location__c> lstLocation, Map<Id, Location__c> mapOldLocation)
	{
		/* Commented till figure out whether we are going to filter using recordtypes or not
		// Retrieve list of RecordTypeIds that are allowed to be synced to SAP
		String sAccRecTypeToSAP = Utility.getTextSetting('Account Record Type IDs to sync to SAP');
		*/
		
		// The list of Location Ids that will be synced with SAP
		Set<Id> setSoldToIdsToSAP = new Set<Id>();
		
		// The list of Location Ids that will be synced with Zuora
		Set<Id> setBillToIdsToZuora = new Set<Id>();
		
		/* Commented by Samy (2016-02-29) Only one billing location is supported
		// The map holding any de-activated BillTo Account/Contact combo and their replacement Active Location Ids that will be synced with Zuora
		Map<String, Id> mapInactiveAccContToActiveBillToLocId = new Map<String, Id>();
    	*/
    	
	    for (Location__c loc : lstLocation)
	    {
    		/* Commented till figure out whether we are going to filter using recordtypes or not
    		// Make sure that the account has the required RecType
	    	if (sAccRecTypeToSAP.contains(loc.Account_Record_Type_Id__c))
	    	{
	    	*/
		    	Location__c oldLoc = mapOldLocation.get(loc.Id);

		    	// Sync SOLD-TO Accounts to SAP
		    	if (loc.Type__c == 'Sold To'
		    		// Only if it is active As Sold-To Deactivation only happens from SAP
		    		&& loc.Active__c
		    		// And only track address changes
		    		&& loc.Address__c != oldLoc.Address__c)
		    	{
		    		setSoldToIdsToSAP.add(loc.Id);
	    		}
	    		// Sync BILL-TO Contacts to Zuora
		    	else if (loc.Type__c == 'Bill To')
		    	{
		    		// Only if it is active
		    		if (loc.Active__c
		    			// And only track address, SAP ID, VAT# changes, Email, or Phone
			    		&& (loc.Address__c != oldLoc.Address__c
			    			|| loc.SAP_Id__c != oldLoc.SAP_Id__c
			    			|| loc.VAT_Number__c != oldLoc.VAT_Number__c
			    			|| loc.Email__c != oldLoc.Email__c
			    			|| loc.Phone__c != oldLoc.Phone__c
			    			))
			    	{
			    		setBillToIdsToZuora.add(loc.Id);
		    		}
		    		/* Commented by Samy (2016-02-29) Only one billing location is supported
		    		// Or disabling the current address and
		    		else if (!loc.Active__c)
		    		{
		    			// Keep record of the Account/Contact combo to find any replacement for it later on
		    			mapInactiveAccContToActiveBillToLocId.put(loc.Account_Contact_ID__c, null);
		    		}*/
		    	}
	    	/*}*/
	    }
	    
	    // Make the SAP call to update the account/contact
	    if (!setSoldToIdsToSAP.isEmpty())
	    {
	    	IECAddress_Svc.syncCustomerMasterWithSAP(setSoldToIdsToSAP);
	    }
	    
	    /* Commented by Samy (2016-02-29) Only one billing location is supported
	    // Will determine here the replacement locations for any de-activated bill-to locations
	    if (!mapInactiveAccContToActiveBillToLocId.isEmpty())
	    {
	    	for (Location__c loc : new Location_Sel().getBillToLocationsByAccountContactId(mapInactiveAccContToActiveBillToLocId.keySet()))
	    	{
	    		// Only load one previous active location only
	    		// so make sure that the replacement location is not already set before adding new one
	    		if (mapInactiveAccContToActiveBillToLocId.containsKey(loc.Account_Contact_Id__c)
	    			&& mapInactiveAccContToActiveBillToLocId.get(loc.Account_Contact_Id__c) == null)
    			{
    				mapInactiveAccContToActiveBillToLocId.put(loc.Account_Contact_Id__c, loc.Id);
    			}
	    	}
	    	
	    	// Add whatever locations we retrieved to the list of location to sync to Zuora to override Contacts with the replacement address
	    	for (Id idLoc : mapInactiveAccContToActiveBillToLocId.values())
	    	{
	    		if (idLoc != null)
	    			setBillToIdsToZuora.add(idLoc);
	    	}
	    }*/
	    
	    // Make the Zuora call to update the contact address
	    if (!setBillToIdsToZuora.isEmpty())
	    {
	    	syncLocationsWithZuora(setBillToIdsToZuora);
	    }
	}
	
	/**
	 * Function will sync any new updates on Locations object to the Order object
	 **/
	public static void syncLocationsUpdateWithNewOrders(Map<Id, Location__c> mapLocation, Map<Id, Location__c> mapOldLocation)
	{
		return;
		/*
		// The list of Location Ids that will be synced with the Order object
		Set<Id> setLocId = new Set<Id>();
		
	    for (Location__c loc : mapLocation.values())
	    {
	    	Location__c oldLoc = mapOldLocation.get(loc.Id);

    		// Specify which BILL-TO & SHIP-TO that will be synced to Order object
	    	if ((loc.Type__c == 'Bill To' || loc.Type__c == 'Ship To')
	    		// Only if it is active
	    		&& loc.Active__c
	    		// And only track address changes
	    		&& loc.Address__c != oldLoc.Address__c)
	    	{
	    		setLocId.add(loc.Id);
    		}
	    }
	    
	    List<Order> lstOrder = Order_Sel.getNewOrdersByLocation(setLocId);
	    
	    if (!lstOrder.isEmpty())
	    {
	    	for (Order ord : lstOrder)
	    	{
	    		// Update Bill to address if the order has the specified location
	    		if (setLocId.contains(ord.BillTo_Location__c))
	    			ord.BillTo_Address__c = mapLocation.get(ord.BillTo_Location__c).Address__c;
	    		
	    		// Update Ship to address if the order has the specified location
	    		if (setLocId.contains(ord.ShipTo_Location__c))
	    			ord.ShipTo_Address__c = mapLocation.get(ord.ShipTo_Location__c).Address__c;
	    	}
	    	
	    	update lstOrder;
	    }
	    */
	}
	
	// Checks if the location record is valid
	//		current validation requirement are:
	//		- No more than one Sold-To location per Account
	//		- No more than one Bill-To location per Account/Contact combo
	//		- No more than one Ship-To location per Account/Contact/Address combo 
	public static List<Location__c> IsLocationValid(List<Location__c> lstLocation) {
		List<Location__c> lstValidLocation = new List<Location__c>();
		
		// Variables used to store unique values to compare it with other existing location for uniqueness
		Set<Id> setSoldToAccountId = new Set<Id>();
		Set<String> setBillToAccountContactId = new Set<String>();
		Set<String> setShipToAccountContactAddressId = new Set<String>();
		
		Set<String> setCurrentLocationId = new Set<String>();
        
        for (Location__c loc : lstLocation) {
        	// Check locations of type 'Sold To' to verify only one Address per Account
			if(loc.Type__c  == 'Sold To')
			{
	        	// Build a set of Account Ids to validate
				setSoldToAccountId.add(loc.Account__c);
				// This will only apply if this is an update trigger
				if (loc.Id != null)
					setCurrentLocationId.add(loc.Id);
			}
			// Check locations of type 'Bill To' to verify only one Address per Account/Contact
			else if(loc.Type__c  == 'Bill To')
			{
	        	// Build a set of Account/Contact Ids to validate
				setBillToAccountContactId.add(String.valueOf(loc.Account__c).left(15) + '|' + String.valueOf(loc.Contact__c).left(15));
				// This will only apply if this is an update trigger
				if (loc.Id != null)
					setCurrentLocationId.add(loc.Id);
			}
			// Check locations of type 'Ship To' to verify uniqueness of Account/Contact/Address combination
			else if(loc.Type__c  == 'Ship To')
			{
	        	// Build a set of Account/Contact Ids to validate
				setShipToAccountContactAddressId.add(String.valueOf(loc.Account__c).left(15) + '|' + String.valueOf(loc.Contact__c).left(15) + '|' + String.valueOf(loc.Address__c).left(15));
				// This will only apply if this is an update trigger
				if (loc.Id != null)
					setCurrentLocationId.add(loc.Id);
			}
        }

		if (!setSoldToAccountId.isEmpty()
			|| !setBillToAccountContactId.isEmpty()
			|| !setShipToAccountContactAddressId.isEmpty())
		{
			// Retrieve any possible existing locations that match any of the previously found locations to validate
			Map<String, Set<String>> mapLocType_To_Key = new Map<String, Set<String>>();
	        for (Location__c loc :
	        	[SELECT Type__c, Account__c, Account_Contact_ID__c, Account_Contact_Address_ID__c
	        	FROM Location__c
	        	WHERE (
	        			(Type__c = 'Sold To' AND Account__c IN :setSoldToAccountId)
	        			OR (Type__c = 'Bill To' AND Account_Contact_ID__c IN :setBillToAccountContactId)
	        			OR (Type__c = 'Ship To' AND Account_Contact_Address_ID__c IN :setShipToAccountContactAddressId)
        			)
	        		AND Active__c = true
	        		AND Id NOT IN :setCurrentLocationId])
	        {
	        	// Add the key to the map based on the location type. each type has a different key to use
	        	if (mapLocType_To_Key.containsKey(loc.Type__c))
	        		mapLocType_To_Key.get(loc.Type__c).add((loc.Type__c == 'Sold To') ? String.valueOf(loc.Account__c) : ((loc.Type__c == 'Bill To') ? loc.Account_Contact_ID__c : loc.Account_Contact_Address_ID__c));
	        	else
	        		mapLocType_To_Key.put(loc.Type__c, new Set<String> {(loc.Type__c == 'Sold To') ? String.valueOf(loc.Account__c) : ((loc.Type__c == 'Bill To') ? loc.Account_Contact_ID__c : loc.Account_Contact_Address_ID__c)});
	        }
	        
	        // Now compare the existing list with the ones we have in the trigger to check for uniquness
	        for (Location__c loc : lstLocation) {
	        	if(loc.Type__c  == 'Sold To'
	        		&& mapLocType_To_Key.containsKey(loc.Type__c)
					&& mapLocType_To_Key.get(loc.Type__c).contains(String.valueOf(loc.Account__c)))
				{
					loc.addError(Label.IEC_Error_OnlyOneLocationPerSoldTo);
				}
				else if(loc.Type__c  == 'Bill To'
	        		&& mapLocType_To_Key.containsKey(loc.Type__c)
					&& mapLocType_To_Key.get(loc.Type__c).contains(String.valueOf(loc.Account__c).left(15) + '|' + String.valueOf(loc.Contact__c).left(15)))
				{
					loc.addError(Label.IEC_Error_OnlyOneLocationPerBillTo);
				}
				else if(loc.Type__c  == 'Ship To'
	        		&& mapLocType_To_Key.containsKey(loc.Type__c)
					&& mapLocType_To_Key.get(loc.Type__c).contains(String.valueOf(loc.Account__c).left(15) + '|' + String.valueOf(loc.Contact__c).left(15) + '|' + String.valueOf(loc.Address__c).left(15)))
				{
					loc.addError(Label.IEC_Error_OnlyOneLocationPerShipToCombination);
				}
				else
				{
					lstValidLocation.add(loc);
				}
	        }
	        
	        return lstValidLocation;
		}

		return lstLocation;
	}

    public static void forbidSAPLocationDeletion(List<Location__c> locations2Delete)
    {
    	for(Location__c location : locations2Delete)
    	{
    		if(String.isNotBlank(location.SAP_Id__c) && location.Active__c==true)
    		{
    			location.addError('Location "'+location.Name+'" cannot be deleted because it is already synched in SAP');
    		}
    	}
    }

    //Function call on Insert/Update of location 
    //	to validate uniqueness of BillTo location
    public static void validateOneActiveBillTo(List<Location__c> locations)
    {
    	Set<Id> contactIds = new Set<Id>();
    	for(Location__c loc : locations)
    		if(loc.Type__c == IECConstants.BILLTO)
    			contactIds.add(loc.Contact__c);
    	
    	Map<Id, Location__c> existingActiveBillToByContact = Location_Sel.getActiveBillToByContact(contactIds);

    	for(Location__c loc : locations)
    	{
    		if(loc.Type__c == IECConstants.BILLTO)
    		{
    			if(existingActiveBillToByContact.containsKey(loc.Contact__c))
    			{
    				Location__c location = existingActiveBillToByContact.get(loc.Contact__c);
    				if(location.Id != loc.Id)
    				{
    					//New Active location 
    					//loc.addError('Only one active BillTo per Customer');
    				}
    			}
    		}
    	}    		
    }

    //Create a new Location
    public static Location__c createLocation(Id addressId,Id contactId,String email, String phone, String VATNumber, String type_x){
    	return createLocation(addressId, contactId, email, phone, VATNumber, type_x, null, null);
    }
    public static Location__c createLocation(Id addressId,Id contactId,String email, String phone, String VATNumber, String type_x, String attention, String addressName){
    	
    	Location__c location    =   new Location__c();
	    location.Type__c        =   type_x;
	    location.Address__c     =   addressId;
	    location.Contact__c     =   contactId;
	    location.VAT_Number__c  =   VATNumber;
	    location.Email__c 		= 	email;
	    location.Phone__c 		= 	phone;
	    location.Attention__c	= 	attention;
	    location.Address_Name__c= 	addressName;

	    try{
	        insert location;
	    }catch(Exception ex){
	    	System.debug('createLocation Exception::'+ex.getMessage());
	        //IECErrorLogger.logApexException('Location_Svc/createShipToLocation', JSON.serialize(location), ex.getMessage(), ex.getStackTraceString()); 
	        return null;
	    }
	    return location;
    }

    public static Location__c createLocation(Id addressId,Id contactId,String VATNumber, String shipTo){
    	Contact contact = new Contact_Sel().getContactById(contactId);
    	return createLocation(addressId, contact, VATNumber, shipTo);
    }
	public static Location__c createLocation(Id addressId,Contact contact,String VATNumber, String shipTo){

	    Location__c location    =   new Location__c();
	    location.Type__c        =   shipTo;
	    location.Address__c     =   addressId;
	    location.Contact__c     =   (contact != null) ? contact.Id : '';
	    location.VAT_Number__c  =   VATNumber;
	    location.Email__c 		= 	(contact != null) ? contact.Email : '';
	    location.Phone__c 		= 	(contact != null) ? contact.Phone : '';
	    if (shipTo == IECConstants.SHIPTO)
	    {
		    location.Address_Name__c = 'Work';
		    location.Attention__c = (contact != null) ? contact.Name : '';
	    }

	    try{
	        insert location;
	    }catch(Exception ex){
	        //IECErrorLogger.logApexException('Location_Svc/createShipToLocation', JSON.serialize(location), ex.getMessage(), ex.getStackTraceString()); 
	        return null;
	    }
	    return location;
	}
	
	// Check for Sold/Bill/Ship-To location for a specific contact and Initialize if doesn't exist
	//	returns boolean result based on whether were able to successfully create or find existing location records 
	public static Boolean InitializeContactLocations(Id idContact)
	{
		if (idContact == null) return false;
		
		Account oAccount;
		Contact oContact;
		// Variable used to determine if an update to the account/contact record is required
		Boolean bRequiredAccountUpdate = false;
		Boolean bRequiredContactUpdate = false;
		
		//Map<String, Location__c> mapType_Location = new Map<String, Location__c>();
		
		// Variable storing the VAT number retrieved from either the Account or Sold-To Location record
		String sVATNumber = '';
		
		// Retrieve the related Account/Contact to create sold/ship/bill to locations
    	List<Contact> lstContact = [SELECT Id, AccountId, Account.ParentId, BillTo_Location__c, ShipTo_Location__c, Email, Phone, Name FROM Contact WHERE Id = :idContact];

    	if (!lstContact.isEmpty())
    	{
    		oContact = lstContact.get(0);
			Id idAccount = (oContact.Account.ParentId != null) ? oContact.Account.ParentId : oContact.AccountId;

            // Now build up the new Sold-To Location
        	oAccount = new Account_Sel().getAccountById(idAccount);
    	}
    	else
    		return false;
    		
		// Initialize variables to determine which of the location types are missing
        Location_Sel lSelector = new Location_Sel();
		Boolean bBillToFound, bShipToFound, bSoldToFound;
		bBillToFound = bShipToFound = bSoldToFound = false;
		Id idSoldToAddress;
		
        // First determine whether the contact has a sold-to location or not
        Map<Id, Location__c> mapAccountId_to_Location = lSelector.getSoldToAccountLocation(new Set<Id>{oAccount.Id});
        bSoldToFound = (mapAccountId_to_Location.containsKey(oAccount.Id) && mapAccountId_to_Location.get(oAccount.Id) != null);
        
        // If no sold-to location exist, then create one
        if (!bSoldToFound)
        {
        	try
        	{
        		// If VAT Number is not empty
        		if (String.isNotBlank(oAccount.VAT_Number__c))
    			{
    				// And VAT Number is valid
        			if (IECVATUtil.Validate_VAT(oAccount.IATA_ISO_Country__r.ISO_Code__c, oAccount.VAT_Number__c) == '')
	        		{
	        			sVATNumber = oAccount.VAT_Number__c;
	        		}
        		}
        	}
        	catch (Exception e)
        	{
        		IECErrorLogger.logApexException('Location_Svc.InitializeContactLocations'
	   				, 'Exception thrown while Validating VAT Number:\nAccount: ' + oAccount
	   				, e.getMessage()
					, e.getStackTraceString()
	   			);
        	}
        	
        	try
        	{
        		IECAddress__c oAddress;
        		
        		// First query the address table to make sure that the address doesn't already exist
        		List<IECAddress__c> lstAddress = new IECAddress_Sel().getAddress(oAccount.BillingStreet, oAccount.BillingCity, oAccount.IATA_ISO_Country__r.ISO_Code__c, oAccount.IATA_ISO_Billing_State__r.ISO_Code__c, oAccount.BillingPostalCode);
        		
        		if (lstAddress.isEmpty())
        		{
	            	// Otherwise Create the IEC Address record
	            	oAddress = new IECAddress__c (
	            		Street__c = Utility.removeNewline(oAccount.BillingStreet)
	            		, City__c = oAccount.BillingCity
	            		, ZipCode__c = oAccount.BillingPostalCode
	            		, ISO_State__c = oAccount.IATA_ISO_Billing_State__c
	            		, ISO_Country__c = oAccount.IATA_ISO_Country__c
	            	);

	            	if(Test.isRunningTest()) oAddress.Address_Type__c = Utility.generateRandomString(8);
	            	
	            	insert oAddress;
        		}
        		else
        			oAddress = lstAddress.get(0);
            	
            	idSoldToAddress = oAddress.Id;
            	
            	// Now create the Sold-To location
            	Location__c oLocation = new Location__c(
            		Account__c = oAccount.Id
            		, Address__c = oAddress.Id
            		, Active__c = true
            		, Type__c = IECConstants.SOLDTO
            		, VAT_Number__c = String.isBlank(sVATNumber) ? null : sVATNumber
            	);
            	insert oLocation;
            	
            	// Set the default location on the account to the new one
            	oAccount.SoldTo_Location__c = oLocation.Id;
            	
            	//mapType_Location.put(IECConstants.SOLDTO, oLocation);
            	
            	bRequiredAccountUpdate = true;
            	bSoldToFound = true;
        	}
        	catch (Exception e)
        	{
        		IECErrorLogger.logApexException('Location_Svc.InitializeContactLocations'
	   				, 'Exception thrown while initializing new Sold-To location:\nidContact: ' + idContact
	   				, e.getMessage()
					, e.getStackTraceString()
	   			);
        	}
        }
        // If found then store some variables from the Location record for later use
        else
        {
        	idSoldToAddress = mapAccountId_to_Location.get(oAccount.Id).Address__c;
        	sVATNumber = mapAccountId_to_Location.get(oAccount.Id).VAT_Number__c;
		}

		// Second determine whether the contact has a bill/ship-to locations or not
        for(Location__c loc : lSelector.getContactsLocations(new Set<Id>{idContact}).values())
        {
            if(loc.Type__c == IECConstants.BILLTO)
                bBillToFound = true;
            else if(loc.Type__c == IECConstants.SHIPTO)
                bShipToFound = true;
            
            // If found both Bill/Ship to locations then no need to go further in the loop
            if (bBillToFound && bShipToFound) break;
        }
        
        // If no bill-to exist, then create one
        if (!bBillToFound)
        {
        	try
        	{
            	// Now create the Bill-To location
            	Location__c oLocation = new Location__c(
            		Account__c = oAccount.Id
            		, Contact__c = idContact
            		// Use same Address from the Sold-To Account Location
            		, Address__c = idSoldToAddress
            		, Active__c = true
            		, Type__c = IECConstants.BILLTO
            		, VAT_Number__c = String.isBlank(sVATNumber) ? null : sVATNumber 
            		, Email__c = (oContact != null) ? oContact.Email : null
            		, Phone__c = (oContact != null) ? oContact.Phone : null
            	);
            	insert oLocation;
            	
            	// Set the default location on the contact to the new one
            	oContact.BillTo_Location__c = oLocation.Id;
            	
            	//mapType_Location.put(IECConstants.BILLTO, oLocation);
            	
            	bRequiredContactUpdate = true;
            	bBillToFound = true;
        	}
        	catch (Exception e)
        	{
        		IECErrorLogger.logApexException('Location_Svc.InitializeContactLocations'
	   				, 'Exception thrown while initializing new Bill-To location:\nidContact: ' + idContact
	   				, e.getMessage()
					, e.getStackTraceString()
	   			);
        	}
        }
        
        // If no ship-to exist, then create one
        if (!bShipToFound)
        {
        	try
        	{
        		IECAddress__c oAddress;
        		
        		// First query the address table to make sure that the address doesn't already exist
        		List<IECAddress__c> lstAddress;
        		
        		// If Shipping address doesn't exist on the account use the billing address
        		if (String.isBlank(oAccount.ShippingStreet))
        			oAddress = new IECAddress__c(Id = idSoldToAddress);
        		else
        		{
        			lstAddress = new IECAddress_Sel().getAddress(oAccount.ShippingStreet, oAccount.ShippingCity, oAccount.IATA_ISO_Country__r.ISO_Code__c, oAccount.IATA_ISO_Shipping_State__r.ISO_Code__c, oAccount.ShippingPostalCode);
        		
	        		if (lstAddress.isEmpty())
	        		{
		            	// Otherwise Create the IEC Address record
		            	oAddress = new IECAddress__c (
		            		Street__c = Utility.removeNewline(oAccount.ShippingStreet)
		            		, City__c = oAccount.ShippingCity
		            		, ZipCode__c = oAccount.ShippingPostalCode
		            		, ISO_State__c = oAccount.IATA_ISO_Shipping_State__c
		            		, ISO_Country__c = oAccount.IATA_ISO_Country__c
		            	);

		            	if(Test.isRunningTest()) oAddress.Address_Type__c = Utility.generateRandomString(8);

		            	insert oAddress;
	        		}
	        		else
	        			oAddress = lstAddress.get(0);
        		}
            	
            	// Now create the Ship-To location
            	Location__c oLocation = new Location__c(
            		Account__c = oAccount.Id
            		, Contact__c = idContact
            		, Address__c = oAddress.Id
            		, Active__c = true
            		, Type__c = IECConstants.SHIPTO
            		, VAT_Number__c = String.isBlank(sVATNumber) ? null : sVATNumber
            		, Email__c = (oContact != null) ? oContact.Email : null
            		, Phone__c = (oContact != null) ? oContact.Phone : null
            		, Attention__c = oContact.Name
            		, Address_Name__c = 'New'
            	);



            	insert oLocation;
            	
            	// Set the default location on the contact to the new one
            	oContact.ShipTo_Location__c = oLocation.Id;
            	
            	//mapType_Location.put(IECConstants.SHIPTO, oLocation);
            	
            	bRequiredContactUpdate = true;
            	bShipToFound = true;
        	}
        	catch (Exception e)
        	{
   				IECErrorLogger.logApexException('Location_Svc.InitializeContactLocations'
	   				, 'Exception thrown while initializing new Ship-To location:\nidContact: ' + idContact
	   				, e.getMessage()
					, e.getStackTraceString()
	   			);
        	}
        }
        
        //if (mapType_Location.size() > 0)
        //{
        //	insert mapType_Location.values();
        //	if (mapType_Location.containsKey(IECConstants.SOLDTO))
        //		oAccount.SoldTo_Location__c = mapType_Location.get(IECConstants.SOLDTO).Id;
        //	if (mapType_Location.containsKey(IECConstants.BILLTO))
        //		oContact.BillTo_Location__c = mapType_Location.get(IECConstants.BILLTO).Id;
        //	if (mapType_Location.containsKey(IECConstants.SHIPTO))
        //		oContact.ShipTo_Location__c = mapType_Location.get(IECConstants.SHIPTO).Id;
        //}
        
        // Update the account if a new Sold-to location is created
        if (bRequiredAccountUpdate)
        	update oAccount;
        	
        // Update the contact if a new Bill/Ship-to locations are created
        if (bRequiredContactUpdate)
        	update oContact;
        
        return (bBillToFound && bShipToFound && bSoldToFound);
	}
}