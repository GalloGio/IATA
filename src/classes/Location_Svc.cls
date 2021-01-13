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

		List<Id> lstLocationId = new List<Id>();
		for(Location__c location : locations)
			lstLocationId.add(location.Id);
		System.enqueueJob(new Location_Queue(Location_Sel.getLocationToSyncSAP(new List<Id>(lstLocationId), null, null, null, null).values()));

/*		system.debug('in SendLocationToSAP');
		
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
/*		    	// Sync SOLD-TO Accounts to SAP
		    	if (location.Type__c == 'Sold To'
			    	// Only if it is active As Sold-To Deactivation only happens from SAP
			    	&& location.Active__c)
		    	{
		    		setSoldToIdsToSAP.add(location.Id);
		    	}
	    	/*}*/

/*			//verified if the bill to and Ship to is related to a contact
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
*/		
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
		//Set<Id> setSoldToIdsToSAP = new Set<Id>();
		
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
		    	//if (loc.Type__c == 'Sold To'
		    	//	// Only if it is active As Sold-To Deactivation only happens from SAP
		    	//	&& loc.Active__c
		    	//	// And only track address changes
		    	//	&& loc.Address__c != oldLoc.Address__c)
		    	//{
		    	//	setSoldToIdsToSAP.add(loc.Id);
	    		//}
	    		// Sync BILL-TO Contacts to Zuora
		    	//else 
		    	if (loc.Type__c == 'Bill To')
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
	    //if (!setSoldToIdsToSAP.isEmpty())
	    //{
	    //	IECAddress_Svc.syncCustomerMasterWithSAP(setSoldToIdsToSAP);
	    //}
	    
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
			if ((loc.Type__c  == 'Sold To' && loc.Account__c != null) ||
				((loc.Type__c  == 'Bill To' || loc.Type__c  == 'Ship To') && loc.Account__c != null && loc.Contact__c != null))
			{
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
    public static Location__c createLocation(Id accountId,Id addressId,Id contactId,String email, String phone, String VATNumber, String type_x){
    	return createLocation(accountId, addressId, contactId, email, phone, VATNumber, type_x, null, null);
    }
    public static Location__c createLocation(Id accountId,Id addressId,Id contactId,String email, String phone, String VATNumber, String type_x, String attention, String addressName){
    	
    	Location__c location    =   new Location__c();
	    location.Type__c        =   type_x;
	    location.Account__c     =   accountId;
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
/*
    public static Location__c createLocation(Id accountId,Id addressId,Id contactId,String VATNumber, String shipTo){
    	Contact contact = new Contact_Sel().getContactById(contactId);
    	return createLocation(accountId, addressId, contact, VATNumber, shipTo);
    }
	public static Location__c createLocation(Id accountId,Id addressId,Contact contact,String VATNumber, String shipTo){

	    Location__c location    =   new Location__c();
	    location.Type__c        =   shipTo;
	    location.Account__c     =   accountId;
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
*/	
	// Check for Sold/Bill/Ship-To location for a specific contact and Initialize if doesn't exist
	//	returns boolean result based on whether were able to successfully create or find existing location records 
/*	public static Boolean InitializeContactLocations(Id idContact)
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
*/

	/****************************************************************************************************
	    Created by Thai 2016-12-05
	        Format filter to query addresses
	****************************************************************************************************/
	String formatAddressToQuery(String Street, String City, String isoCountryCode, String isoStateCode, String PostalCode)
	{
		return '(Street__c=' + (String.isBlank(Street) ? 'null' : '\'' + Utility.removeNewline(Street).replace('\'', '\\\'') + '\'')
		     + ' and City__c=' + (String.isBlank(City) ? 'null' : '\'' + City.replace('\'', '\\\'') + '\'')
		     + ' and ISO_Country__r.ISO_Code__c=' + (String.isBlank(isoCountryCode) ? 'null' : '\'' + isoCountryCode + '\'')
		     + ' and ISO_State__r.ISO_Code__c=' + (String.isBlank(isoStateCode) ? 'null' : '\'' + isoStateCode + '\'')
		     + ' and ZipCode__c=' + (String.isBlank(PostalCode) ? 'null)' : '\'' + PostalCode.replace('\'', '\\\'') + '\')');
	} //*** end of "formatAddressToQuery"


	/****************************************************************************************************
	    Created by Thai 2016-12-05
	        Initialize default location records for contacts/accounts
	****************************************************************************************************/
	public static List<String> initializeDefaultLocations(List<Id> lstContactId)
	{
		List<String> lstResult = new List<String>(), lstResultBeforeUpsert = new List<String>();
		String strQuery = 'select Id, Email, Phone, Name, FirstName, LastName, Salutation'
		                + ', BillTo_Location__c, BillTo_Location__r.SAP_Id__c, BillTo_Location__r.Active__c'
		                + ', ShipTo_Location__c, ShipTo_Location__r.SAP_Id__c, ShipTo_Location__r.Active__c'
		                + ', AccountId, Account.Name, Account.Phone, Account.Email__c, Account.Default_Payment_Type__c, Account.VAT_Number__c'
		                + ', Account.SoldTo_Location__c, Account.SoldTo_Location__r.SAP_Id__c, Account.SoldTo_Location__r.Active__c'
		                + ', Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.IATA_ISO_Country__r.ISO_Code__c'
		                + ', Account.IATA_ISO_Billing_State__r.ISO_Code__c, Account.IATA_ISO_Billing_State__r.IEC_Valid_SAP__c'
		                + ', Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode'
		                + ', Account.IATA_ISO_Shipping_State__r.ISO_Code__c, Account.IATA_ISO_Shipping_State__r.IEC_Valid_SAP__c'
		                + ', Account.IATA_ISO_Shipping_Country__r.ISO_Code__c'
		                + ', Account.ParentId, Account.Parent.Name, Account.Parent.Phone, Account.Parent.Email__c, Account.Parent.Default_Payment_Type__c, Account.Parent.VAT_Number__c'
		                + ', Account.Parent.SoldTo_Location__c, Account.Parent.SoldTo_Location__r.SAP_Id__c, Account.Parent.SoldTo_Location__r.Active__c'
		                + ', Account.Parent.BillingStreet, Account.Parent.BillingCity, Account.Parent.BillingPostalCode, Account.Parent.IATA_ISO_Country__r.ISO_Code__c'
		                + ', Account.Parent.IATA_ISO_Billing_State__r.ISO_Code__c, Account.Parent.IATA_ISO_Billing_State__r.IEC_Valid_SAP__c'
		                + ', Account.Parent.ShippingStreet, Account.Parent.ShippingCity, Account.Parent.ShippingPostalCode'
		                + ', Account.Parent.IATA_ISO_Shipping_State__r.ISO_Code__c, Account.Parent.IATA_ISO_Shipping_State__r.IEC_Valid_SAP__c'
		                + ', Account.Parent.IATA_ISO_Shipping_Country__r.ISO_Code__c'
		                + ' from Contact where Id in :lstContactId';
		Map<Id, Contact> mapId_Contact = new Map<Id, Contact>((List<Contact>) Database.query(strQuery));
		Contact oContact;
		Account oAccount, oParentAccount;
		List<Account> lstAccountToUpdate = new List<Account>();
		Map<String, Location__c> mapPartner_Location = new Map<String, Location__c>();
		List<IEC_Error_Log__c> lstSyncResult, lstError = new List<IEC_Error_Log__c>();
		IECAddress__c oAddress;
		List<IECAddress__c> lstAddress = new List<IECAddress__c>(), lstNewAddress = new List<IECAddress__c>();
		List<Location__c> lstUpdateLocation = new List<Location__c>();
		Location__c oLocation;
		Map<String, Location__c> mapUpdateId_Location = new Map<String, Location__c>();
		String sVATNumber, soldToSAPId, billToSAPId, shipToSAPId, strQueryAddress, strStreet;
		Location_Svc cls = new Location_Svc();
		Id idRecord;
		Integer i1, i2;
		
		//*** check if need to create locations
		strQuery = '';
		strQueryAddress = '';
		for (i1 = 0; i1 < lstContactId.size(); i1++)
		{
			oContact = mapId_Contact.get(lstContactId[i1]);
			lstResult.add('');
			if (oContact != null)
			{
				oAccount = oContact.Account;
				oParentAccount = (!String.isBlank(oAccount.ParentId) && oAccount.ParentId != oAccount.Id) ? oAccount.Parent : oAccount;
				
				//*** no need if all SAP IDs are found, if not then prepare to query locations and addresses for contact
				if (!String.isBlank(oParentAccount.SoldTo_Location__r.SAP_Id__c) && oParentAccount.SoldTo_Location__r.Active__c == true &&
				    !String.isBlank(oContact.BillTo_Location__r.SAP_Id__c) && oContact.BillTo_Location__r.Active__c == true &&
				    !String.isBlank(oContact.ShipTo_Location__r.SAP_Id__c) && oContact.ShipTo_Location__r.Active__c == true)
					lstResult[i1] = null;
				else
				{
					strQuery += ' or (Account__c=\'' + oParentAccount.Id + '\' and (Type__c=\'Sold To\' or (Type__c in (\'Bill To\',\'Ship To\') and Contact__c=\'' + oContact.Id + '\')))';
					if (!String.isBlank(oParentAccount.BillingStreet) || !String.isBlank(oParentAccount.BillingCity) ||
						!String.isBlank(oParentAccount.IATA_ISO_Billing_State__r.ISO_Code__c) || !String.isBlank(oParentAccount.BillingPostalCode))
						strQueryAddress += ' or ' + cls.formatAddressToQuery(oParentAccount.BillingStreet, oParentAccount.BillingCity, oParentAccount.IATA_ISO_Country__r.ISO_Code__c
						                                                   , oParentAccount.IATA_ISO_Billing_State__r.ISO_Code__c, oParentAccount.BillingPostalCode);
					if (!String.isBlank(oParentAccount.ShippingStreet) || !String.isBlank(oParentAccount.ShippingCity) ||
						!String.isBlank(oParentAccount.IATA_ISO_Shipping_State__r.ISO_Code__c) || !String.isBlank(oParentAccount.ShippingPostalCode))
						strQueryAddress += ' or ' + cls.formatAddressToQuery(oParentAccount.ShippingStreet, oParentAccount.ShippingCity, oParentAccount.IATA_ISO_Country__r.ISO_Code__c
						                                                   , oParentAccount.IATA_ISO_Shipping_State__r.ISO_Code__c, oParentAccount.ShippingPostalCode);
					if (oParentAccount.BillingStreet != oAccount.BillingStreet || oParentAccount.BillingCity != oAccount.BillingCity || oParentAccount.BillingPostalCode != oAccount.BillingPostalCode ||
					    oParentAccount.IATA_ISO_Country__r.ISO_Code__c != oAccount.IATA_ISO_Country__r.ISO_Code__c || oParentAccount.IATA_ISO_Billing_State__r.ISO_Code__c != oAccount.IATA_ISO_Billing_State__r.ISO_Code__c)
						if (!String.isBlank(oAccount.BillingStreet) || !String.isBlank(oAccount.BillingCity) ||
							!String.isBlank(oAccount.IATA_ISO_Billing_State__r.ISO_Code__c) || !String.isBlank(oAccount.BillingPostalCode))
							strQueryAddress += ' or ' + cls.formatAddressToQuery(oAccount.BillingStreet, oAccount.BillingCity, oAccount.IATA_ISO_Country__r.ISO_Code__c
							                                                   , oAccount.IATA_ISO_Billing_State__r.ISO_Code__c, oAccount.BillingPostalCode);
					if (oParentAccount.ShippingStreet != oAccount.ShippingStreet || oParentAccount.ShippingCity != oAccount.ShippingCity || oParentAccount.ShippingPostalCode != oAccount.ShippingPostalCode ||
					    oParentAccount.IATA_ISO_Country__r.ISO_Code__c != oAccount.IATA_ISO_Country__r.ISO_Code__c || oParentAccount.IATA_ISO_Shipping_State__r.ISO_Code__c != oAccount.IATA_ISO_Shipping_State__r.ISO_Code__c)
						if (!String.isBlank(oAccount.ShippingStreet) || !String.isBlank(oAccount.ShippingCity) ||
							!String.isBlank(oAccount.IATA_ISO_Shipping_State__r.ISO_Code__c) || !String.isBlank(oAccount.ShippingPostalCode))
							strQueryAddress += ' or ' + cls.formatAddressToQuery(oAccount.ShippingStreet, oAccount.ShippingCity, oAccount.IATA_ISO_Country__r.ISO_Code__c
							                                                   , oAccount.IATA_ISO_Shipping_State__r.ISO_Code__c, oAccount.ShippingPostalCode);
				}
			}
		}
		if (strQuery == '')
			return lstResult;
		
		//*** backup results -> will return this results when error on insert/update
		lstResultBeforeUpsert.addAll(lstResult);
		
		//*** get existing active locations -> the latest SAP Id will be in the map
		strQuery = 'select Id, Type__c, VAT_Number__c, Phone__c, Email__c, SAP_Id__c, Active__c'
		         + ', Address__c, Address__r.Street__c, Address__r.City__c, Address__r.ZipCode__c'
		         + ', Address__r.ISO_State__c, Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.IEC_Valid_SAP__c'
		         + ', Address__r.ISO_Country__r.ISO_Code__c, Address__r.ISO_Country__c'
		         + ', Contact__c, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName'
		         + ', Account__c, Account__r.Name, Account__r.Phone, Account__r.Email__c, Account__r.Default_Payment_Type__c'
		         + ', Account__r.SoldTo_Location__r.SAP_Id__c'
		         + ' from Location__c where Active__c=true and (' + strQuery.substring(4) + ') order by SAP_Id__c nulls first';
		for (Location__c loc : Database.query(strQuery))
			mapPartner_Location.put(loc.Type__c + (loc.Type__c == IECConstants.SOLDTO ? loc.Account__c : loc.Contact__c), loc);
		
		//*** get addresses
		if (strQueryAddress != '')
		{
			strQueryAddress = 'select Id, Street__c, City__c, ISO_Country__c, ISO_Country__r.ISO_Code__c, ISO_State__c, ISO_State__r.ISO_Code__c, ISO_State__r.IEC_Valid_SAP__c, ZipCode__c'
			                + ' from IECAddress__c where ' + strQueryAddress.substring(4);
			lstAddress = Database.query(strQueryAddress);
		}
		
		//*** create/update locations
		for (i1 = 0; i1 < lstContactId.size(); i1++)
		{
			oContact = mapId_Contact.get(lstContactId[i1]);
			if (lstResult[i1] == null || oContact == null)
				continue;
			
			oAccount = oContact.Account;
			oParentAccount = (!String.isBlank(oAccount.ParentId) && oAccount.ParentId != oAccount.Id) ? oAccount.Parent : oAccount;
			
			// validate VAT Number is not empty
			sVATNumber = null;
			if (String.isNotBlank(oParentAccount.VAT_Number__c))
				try
				{
					if (IECVATUtil.Validate_VAT(oParentAccount.IATA_ISO_Country__r.ISO_Code__c, oParentAccount.VAT_Number__c) == '')
						sVATNumber = oParentAccount.VAT_Number__c;
				}
				catch (Exception e) { /* ignore error */ }
			
			//*** get/create sold to entity
			if (!String.isBlank(oParentAccount.SoldTo_Location__r.SAP_Id__c) && oParentAccount.SoldTo_Location__r.Active__c == true)
				soldToSAPId = oParentAccount.SoldTo_Location__r.SAP_Id__c;
			else
			{
				oLocation = mapPartner_Location.get(IECConstants.SOLDTO + oParentAccount.Id);
				if (oLocation == null)
				{
					//*** get/create address
					strStreet = Utility.removeNewline(oParentAccount.BillingStreet);
					for (i2 = 0; i2 < lstAddress.size(); i2++)
						if (strStreet == lstAddress[i2].Street__c && oParentAccount.BillingCity == lstAddress[i2].City__c && oParentAccount.BillingPostalCode == lstAddress[i2].ZipCode__c &&
						    oParentAccount.IATA_ISO_Country__r.ISO_Code__c == lstAddress[i2].ISO_Country__r.ISO_Code__c && oParentAccount.IATA_ISO_Billing_State__r.ISO_Code__c == lstAddress[i2].ISO_State__r.ISO_Code__c)
							break;
					if (i2 >= lstAddress.size())
					{
						oAddress = new IECAddress__c (Street__c = strStreet, City__c = oParentAccount.BillingCity , ZipCode__c = oParentAccount.BillingPostalCode
						                            , ISO_State__c = oParentAccount.IATA_ISO_Billing_State__c, ISO_State__r = oParentAccount.IATA_ISO_Billing_State__r
						                            , ISO_Country__c = oParentAccount.IATA_ISO_Country__c, ISO_Country__r = oParentAccount.IATA_ISO_Country__r
						                            , Address_Type__c = (Test.isRunningTest() ? Utility.generateRandomString(8) : null));
						lstNewAddress.add(oAddress);
						lstAddress.add(oAddress);
					}
					else
						oAddress = lstAddress[i2];
					
					//*** create the location
					oLocation = new Location__c(Account__c = oParentAccount.Id, Account__r = oParentAccount, Address__c = oAddress.Id, Address__r = oAddress
					                          , Id = null, Active__c = true, Type__c = IECConstants.SOLDTO, SAP_Id__c=null, VAT_Number__c = sVATNumber);
					mapPartner_Location.put(IECConstants.SOLDTO + oParentAccount.Id, oLocation);
				}
				
				//*** prepare to update account
				if (oParentAccount.SoldTo_Location__c != oLocation.Id || oLocation.Id == null)
					mapUpdateId_Location.put('ST' + oParentAccount.Id, oLocation);
				
				//*** send location to SAP if no ID yet
				soldToSAPId = oLocation.SAP_Id__c;
				if (String.isBlank(soldToSAPId))
				{
					lstUpdateLocation.add(oLocation);
					lstSyncResult = IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{oLocation}, null, false, lstAccountToUpdate);
					if (lstSyncResult[0] == null)
						soldToSAPId = oLocation.SAP_Id__c;
					else
					{
						lstResult[i1] += '\nST' + lstSyncResult[0].Extra_Information__c;
						lstError.addAll(lstSyncResult);
					}
				}
			} //*** end for sold to

			//*** create bill to entity if necessary
			if (!String.isBlank(oContact.BillTo_Location__r.SAP_Id__c) && oContact.BillTo_Location__r.Active__c == true)
				billToSAPId = oContact.BillTo_Location__r.SAP_Id__c;
			else
			{
				oLocation = mapPartner_Location.get(IECConstants.BILLTO + oContact.Id);
				if (oLocation == null)
				{
					//*** get/create address
					strStreet = Utility.removeNewline(oAccount.BillingStreet);
					for (i2 = 0; i2 < lstAddress.size(); i2++)
						if (strStreet == lstAddress[i2].Street__c && oAccount.BillingCity == lstAddress[i2].City__c && oAccount.BillingPostalCode == lstAddress[i2].ZipCode__c &&
						    oAccount.IATA_ISO_Country__r.ISO_Code__c == lstAddress[i2].ISO_Country__r.ISO_Code__c && oAccount.IATA_ISO_Billing_State__r.ISO_Code__c == lstAddress[i2].ISO_State__r.ISO_Code__c)
							break;
					if (i2 >= lstAddress.size())
					{
						oAddress = new IECAddress__c (Street__c = strStreet, City__c = oAccount.BillingCity , ZipCode__c = oAccount.BillingPostalCode
						                            , ISO_State__c = oAccount.IATA_ISO_Billing_State__c, ISO_State__r = oAccount.IATA_ISO_Billing_State__r
						                            , ISO_Country__c = oAccount.IATA_ISO_Country__c, ISO_Country__r = oAccount.IATA_ISO_Country__r
						                            , Address_Type__c = (Test.isRunningTest() ? Utility.generateRandomString(8) : null));
						lstNewAddress.add(oAddress);
						lstAddress.add(oAddress);
					}
					else
						oAddress = lstAddress[i2];
					
					//*** create the location
					oLocation = new Location__c(Account__c = oParentAccount.Id, Account__r = oParentAccount, Address__c = oAddress.Id, Address__r = oAddress
					                          , Contact__c = oContact.Id, Contact__r = oContact, Email__c = oContact.Email, Phone__c = oContact.Phone
					                          , Id = null, Active__c = true, Type__c = IECConstants.BILLTO, SAP_Id__c=null, VAT_Number__c = sVATNumber);
					mapPartner_Location.put(IECConstants.BILLTO + oContact.Id, oLocation);
				}
				
				//*** prepare to update contact
				if (oContact.BillTo_Location__c != oLocation.Id || oLocation.Id == null)
					mapUpdateId_Location.put('BT' + oContact.Id, oLocation);
				
				//*** send location to SAP if no ID yet
				billToSAPId = oLocation.SAP_Id__c;
				if (String.isBlank(billToSAPId))
				{
					lstUpdateLocation.add(oLocation);
					if (!String.isBlank(soldToSAPId))
					{
						lstSyncResult = IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{oLocation}, new Map<Id, String>{oContact.Id => soldToSAPId}, false);
						if (lstSyncResult[0] == null)
							billToSAPId = oLocation.SAP_Id__c;
						else
						{
							lstResult[i1] += '\nBT' + lstSyncResult[0].Extra_Information__c;
							lstError.addAll(lstSyncResult);
						}
					}
				}
			} //*** end for bill to

			//*** create ship to entity if necessary
			if (!String.isBlank(oContact.ShipTo_Location__r.SAP_Id__c) && oContact.ShipTo_Location__r.Active__c == true)
				shipToSAPId = oContact.ShipTo_Location__r.SAP_Id__c;
			else
			{
				oLocation = mapPartner_Location.get(IECConstants.SHIPTO + oContact.Id);
				if (oLocation == null)
				{
					//*** get/create address
					if (String.isBlank(oAccount.ShippingStreet))
					{
						strStreet = Utility.removeNewline(oAccount.BillingStreet);
						for (i2 = 0; i2 < lstAddress.size(); i2++)
							if (strStreet == lstAddress[i2].Street__c && oAccount.BillingCity == lstAddress[i2].City__c && oAccount.BillingPostalCode == lstAddress[i2].ZipCode__c &&
							    oAccount.IATA_ISO_Country__r.ISO_Code__c == lstAddress[i2].ISO_Country__r.ISO_Code__c && oAccount.IATA_ISO_Billing_State__r.ISO_Code__c == lstAddress[i2].ISO_State__r.ISO_Code__c)
								break;
					}
					else
					{
						strStreet = Utility.removeNewline(oAccount.ShippingStreet);
						for (i2 = 0; i2 < lstAddress.size(); i2++)
							if (strStreet == lstAddress[i2].Street__c && oAccount.ShippingCity == lstAddress[i2].City__c && oAccount.ShippingPostalCode == lstAddress[i2].ZipCode__c &&
							    oAccount.IATA_ISO_Country__r.ISO_Code__c == lstAddress[i2].ISO_Country__r.ISO_Code__c && oAccount.IATA_ISO_Shipping_State__r.ISO_Code__c == lstAddress[i2].ISO_State__r.ISO_Code__c)
								break;
					}
					if (i2 >= lstAddress.size())
					{
						if (String.isBlank(oAccount.ShippingStreet))
							oAddress = new IECAddress__c (Street__c = strStreet, City__c = oAccount.BillingCity , ZipCode__c = oAccount.BillingPostalCode
							                            , ISO_State__c = oAccount.IATA_ISO_Billing_State__c, ISO_State__r = oAccount.IATA_ISO_Billing_State__r
							                            , ISO_Country__c = oAccount.IATA_ISO_Country__c, ISO_Country__r = oAccount.IATA_ISO_Country__r
							                            , Address_Type__c = (Test.isRunningTest() ? Utility.generateRandomString(8) : null));
						else
							oAddress = new IECAddress__c (Street__c = strStreet, City__c = oAccount.ShippingCity , ZipCode__c = oAccount.ShippingPostalCode
							                            , ISO_State__c = oAccount.IATA_ISO_Shipping_State__c, ISO_State__r = oAccount.IATA_ISO_Shipping_State__r
							                            , ISO_Country__c = oAccount.IATA_ISO_Shipping_Country__c, ISO_Country__r = oAccount.IATA_ISO_Shipping_Country__r
							                            , Address_Type__c = (Test.isRunningTest() ? Utility.generateRandomString(8) : null));
						lstNewAddress.add(oAddress);
						lstAddress.add(oAddress);
					}
					else
						oAddress = lstAddress[i2];
					
					//*** create the location
					oLocation = new Location__c(Account__c = oParentAccount.Id, Account__r = oParentAccount, Address__c = oAddress.Id, Address__r = oAddress
					                          , Contact__c = oContact.Id, Contact__r = oContact, Email__c = oContact.Email, Phone__c = oContact.Phone, Attention__c = oContact.Name, Address_Name__c = 'New'
					                          , Id = null, Active__c = true, Type__c = IECConstants.SHIPTO, SAP_Id__c=null, VAT_Number__c = sVATNumber);
					mapPartner_Location.put(IECConstants.SHIPTO + oContact.Id, oLocation);
				}
				
				//*** prepare to update contact
				if (oContact.ShipTo_Location__c != oLocation.Id || oLocation.Id == null)
					mapUpdateId_Location.put('SH' + oContact.Id, oLocation);
				
				//*** send location to SAP if no ID yet
				shipToSAPId = oLocation.SAP_Id__c;
				if (String.isBlank(shipToSAPId))
				{
					lstUpdateLocation.add(oLocation);
					if (!String.isBlank(soldToSAPId))
					{
						lstSyncResult = IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{oLocation}, new Map<Id, String>{oContact.Id => soldToSAPId}, false);
						if (lstSyncResult[0] == null)
							shipToSAPId = oLocation.SAP_Id__c;
						else
						{
							lstResult[i1] += '\nSH' + lstSyncResult[0].Extra_Information__c;
							lstError.addAll(lstSyncResult);
						}
					}
				}
			} //*** end for ship to
			
			if (String.isBlank(lstResult[i1]))
				lstResult[i1] = null;
		} //*** end of loop for contacts
		
		try
		{
			//*** insert addresses
			if (lstNewAddress.size() > 0)
				insert lstNewAddress;
			
			//*** insert/update locations
			if (lstUpdateLocation.size() > 0)
			{
				//*** set address before insert/update
				for (i1 = 0; i1 < lstUpdateLocation.size(); i1++)
					if (String.isBlank(lstUpdateLocation[i1].Address__c))
						lstUpdateLocation[i1].Address__c = lstUpdateLocation[i1].Address__r.Id;
				upsert lstUpdateLocation;
			}
			
			//*** update account/contact
			List<SObject> lstUpdate = new List<SObject>();
			for (String k : mapUpdateId_Location.keySet())
				if (k.startsWith('ST'))   //*** sold to
				{
					idRecord = Id.valueOf(k.substring(2));
					//*** search if account to update is already in list of accounts to update
					for (i1 = 0; i1 < lstAccountToUpdate.size(); i1++)
						if (lstAccountToUpdate[i1].Id == idRecord)
						{
							lstAccountToUpdate[i1].SoldTo_Location__c = mapUpdateId_Location.get(k).Id;
							break;
						}
					//*** add to list of accounts to update if not already in list
					if (i1 >= lstAccountToUpdate.size())
						lstUpdate.add(new Account(Id=k.substring(2), SoldTo_Location__c=mapUpdateId_Location.get(k).Id));
				}
				else if (k.startsWith('BT'))
					if (mapUpdateId_Location.containsKey('SH' + k.substring(2)))   //*** bill to and ship to
						lstUpdate.add(new Contact(Id=k.substring(2), BillTo_Location__c=mapUpdateId_Location.get(k).Id
						                        , ShipTo_Location__c=mapUpdateId_Location.get('SH' + k.substring(2)).Id));
					else   //*** bill to without ship to
						lstUpdate.add(new Contact(Id=k.substring(2), BillTo_Location__c=mapUpdateId_Location.get(k).Id));
				else if (!mapUpdateId_Location.containsKey('BT' + k.substring(2)))   //*** ship to without bill to
					lstUpdate.add(new Contact(Id=k.substring(2), ShipTo_Location__c=mapUpdateId_Location.get(k).Id));
			if (lstUpdate.size() > 0)
				update lstUpdate;
			if (lstAccountToUpdate.size() > 0)
				update lstAccountToUpdate;
		}
		catch (Exception e)
		{
			lstError.add(IECErrorLogger.createErrorLog('Location_Svc.initializeDefaultLocations'
			                                         , '***** New addresses\n' + lstNewAddress + '\n***** Locations\n' + lstUpdateLocation + '\n***** Accounts/Contacts: ' + mapUpdateId_Location
			                                         , e.getMessage(), e.getStackTraceString()));
			lstResult.clear();
			lstResult.addAll(lstResultBeforeUpsert);
			for (i1 = 0; i1 < lstResult.size(); i1++)
				if (lstResult[i1] != null)
					lstResult[i1] += '\n' + e.getMessage();
		}
		
		//*** log error if any
		if (lstError.size() > 0)
			try
			{
				insert lstError;
			}
			catch (Exception e) { /* ignore error */ }
		
		return lstResult;
	} //*** end of "initializeDefaultLocations"


}