/* Test Coverage: some of the functions below are covered in the class Location_Dom_Test */

public class IECAddress_Svc 
{
    public static SAP_CustomerMaster.HTTPS_Port setCalloutHeader(SAP_CustomerMaster.HTTPS_Port req)
    {
        String authorizationHeader =  Utility.getSAPauthorization();

        if(req.inputHttpHeaders_x == null)
        {
            req.inputHttpHeaders_x = new Map<String,String>(); 
        }
        req.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        req.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
        req.endpoint_x = Utility.fixEndpointDomain(req.endpoint_x);

        return req;
    }

    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function return the Request Type to send to SAP                                    *
     *      Xyy     X:    C  = Create      U = Update      D = Delete (or inactivation)             *
     *             yy:    SP = Sold-to    BP = Bill-to    SH = Ship-to                              *
     ************************************************************************************************/
    public static String getRequestType(Location__c location)
    {
        String requestType;
        if(location.Active__c == false) requestType = 'D';
        else if(String.isNotBlank(location.SAP_Id__c))  requestType = 'U' ;
        else requestType = 'C';
 
        if(location.Type__c == 'Sold To') requestType += 'SP';
        else if(location.Type__c == 'Bill To') requestType += 'BP';
        else if(location.Type__c == 'Ship To') requestType += 'SH';
        else requestType = null;

        return requestType;
    }

    public static String getSAPPaymentType(String paymentType)
    {
        if(paymentType == null) return paymentType;
        
        Map<String, String> SAPPaymentMap = new Map<String, String>{
            'creditcard'            =>  '1',
            'banktransfer'          =>  'T',
            'check'                 =>  'C',
            'ich'                   =>  'I'
        };

        String str = paymentType.toLowerCase().replace(' ', '');

        return (SAPPaymentMap.containsKey(str)) ? SAPPaymentMap.get(str) : paymentType;
    }

    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function return the Request Object to send to SAP                                  *
     ************************************************************************************************/
    public static SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request createCustomerMasterRequestObject(Location__c location, Map<Id, Location__c> soldToLocationByContactId)
    {
        SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = new SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request();
            
        SAP_CustomerMaster.SoldTo_element soldTo = new SAP_CustomerMaster.SoldTo_element();
        SAP_CustomerMaster.BillTo_element billTo = new SAP_CustomerMaster.BillTo_element();
        SAP_CustomerMaster.ShipTo_element shipTo = new SAP_CustomerMaster.ShipTo_element();

        SAP_CustomerMaster.Contact_element contactInfo = new SAP_CustomerMaster.Contact_element(); 
            contactInfo.Title       = Utility.truncate(location.Contact_Salutation__c,30);
            contactInfo.FirstName   = Utility.truncate(location.Contact_First_Name__c,40);
            contactInfo.LastName    = Utility.truncate(location.Contact_Last_Name__c,40);
            //contactInfo.Telephone   = Utility.truncate(location.Contact_Phone__c,30);
            contactInfo.Telephone   = Utility.truncate(location.Phone__c,30);
            //contactInfo.Email       = Utility.truncate(location.Contact_Email__c,241);
            contactInfo.Email       = Utility.truncate(location.Email__c,241);
            
        //-- Request Type : mandatory for all requests
        request.RequestType         = getRequestType(location);

        //-- SFDC Account ID: only for Sold To Creation 
        if(request.RequestType == 'CSP') request.SFDCAccountID = Utility.truncate(location.Account__c, 15); 

        //-- SFDC Contact ID: for Sold To Creation & Bill To Creation 
        if(request.RequestType == 'CSP' || request.RequestType == 'CBP' || request.RequestType == 'CSH') request.SFDCContactID = Utility.truncate(location.Contact__c, 15); 

        //-- SAP Sold To ID : for all except Sold To Creation 
        if(request.RequestType != 'CSP')
        {
            if(request.RequestType == 'USP') soldTo.SAPSoldToID  = Utility.truncate(location.SAP_Id__c, 10);
            else
            {
                //-- SoldTo is created first we enter here
                Location__c soldToLocation = soldToLocationByContactId.get(location.Contact__c);
                System.debug('soldToLocation::'+soldToLocation);
                if (soldToLocation != null)
                    soldTo.SAPSoldToID  = Utility.truncate(soldToLocation.SAP_Id__c, 10);
            }
        }

        //-- SAP Bill To ID : for Bill To Update/Inactivation 
        if(request.RequestType == 'UBP' || request.RequestType == 'DBP') billTo.SAPBillToID = Utility.truncate(location.SAP_Id__c, 10);

        //-- SAP Ship To ID : for Ship To Update/Inactivation 
        if(request.RequestType == 'USH' || request.RequestType == 'DSH') shipTo.SAPShipToID = Utility.truncate(location.SAP_Id__c, 10);

        //-- Sold To Details : when Create/Update SoldTo 
        if(request.RequestType == 'CSP' || request.RequestType == 'USP')
        {
            soldTo.Name1            = Utility.truncate(location.Account_Name__c,40);
            soldTo.Name2            = Utility.truncate(location.Account_Name__c,40,40);
            soldTo.Name3            = Utility.truncate(location.Account_Name__c,80,40);
            soldTo.SearchTerm1      = Utility.truncate(location.Account__c,15);
            soldTo.Street2          = Utility.truncate(location.Street__c,40);
            soldTo.Street3          = Utility.truncate(location.Street__c,40,60);
            soldTo.PostalCode       = Utility.truncate(location.ZipCode__c, 10);
            soldTo.City             = Utility.truncate(location.City__c, 40);
            soldTo.Country          = Utility.truncate(location.ISO_Country_Code__c,3);
            soldTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c)) ? 'NA' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            soldTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c) || location.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            soldTo.Telephone        = Utility.truncate(location.Account_Phone__c,30);
            soldTo.Email            = Utility.truncate(location.Account_Email__c,241);
            if (!String.isBlank(location.VAT_Number__c) && !String.isBlank(location.ISO_Country_Code__c))
                if (!location.VAT_Number__c.startsWithIgnoreCase(location.ISO_Country_Code__c))
                    soldTo.VAT_Reg_No = Utility.truncate(location.ISO_Country_Code__c + location.VAT_Number__c,20);
                else
                    soldTo.VAT_Reg_No = Utility.truncate(location.VAT_Number__c,20);
            soldTo.PaymentMethod    = getSAPPaymentType(location.Account_Payment_Type__c);
            //soldTo.PaymentTerms     = Utility.truncate(location.Account_Payment_Term__c,4);   //*** this attribute belongs to SAP therefore do not send
        }

        //-- Bill To Details: BillTo Update/Creation + SoldTo Creation
        if(request.RequestType == 'CSP' || request.RequestType == 'CBP' || request.RequestType == 'UBP')
        {
            billTo.Name1            = Utility.truncate(location.Account_Name__c,40);
            billTo.Name2            = Utility.truncate(location.Account_Name__c,40,40);
            billTo.Name3            = Utility.truncate(location.Account_Name__c,80,40);
            billTo.SearchTerm1      = Utility.truncate(location.Contact__c,15);
            billTo.Street2          = Utility.truncate(location.Street__c,40);
            billTo.Street3          = Utility.truncate(location.Street__c,40,60);
            billTo.PostalCode       = Utility.truncate(location.ZipCode__c, 10);
            billTo.City             = Utility.truncate(location.City__c, 40);
            billTo.Country          = Utility.truncate(location.ISO_Country_Code__c,3);
            //billTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c)) ? 'NA' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            billTo.Region           = (String.isBlank(location.ISO_State_Code_SAP__c) || location.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            billTo.PaymentMethod    = getSAPPaymentType(location.Account_Payment_Type__c);
            if (!String.isBlank(location.VAT_Number__c) && !String.isBlank(location.ISO_Country_Code__c))
                if (!location.VAT_Number__c.startsWithIgnoreCase(location.ISO_Country_Code__c))
                    billTo.VAT_Reg_No = Utility.truncate(location.ISO_Country_Code__c + location.VAT_Number__c,20);
                else
                    billTo.VAT_Reg_No = Utility.truncate(location.VAT_Number__c,20);
            billTo.Contact          = contactInfo;
        }

        //-- Ship To Details: ShipTo Update/Creation + SoldTo Creation
        if(request.RequestType == 'CSP' || request.RequestType == 'CSH' || request.RequestType == 'USH')
        {
            shipTo.Name1        = Utility.truncate(location.Account_Name__c,40);
            shipTo.Name2        = Utility.truncate(location.Account_Name__c,40,40);
            shipTo.Name3        = Utility.truncate(location.Account_Name__c,80,40);
            shipTo.SearchTerm1  = Utility.truncate(location.Contact__c,15);
            shipTo.Street2      = Utility.truncate(location.Street__c,40);
            shipTo.Street3      = Utility.truncate(location.Street__c,40,60);
            shipTo.PostalCode   = Utility.truncate(location.ZipCode__c, 10);
            shipTo.City         = Utility.truncate(location.City__c, 40);
            shipTo.Country      = Utility.truncate(location.ISO_Country_Code__c,3);
            //shipTo.Region       = (String.isBlank(location.ISO_State_Code_SAP__c)) ? 'NA' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            shipTo.Region       = (String.isBlank(location.ISO_State_Code_SAP__c) || location.IEC_Valid_SAP_State__c != true) ? '' : Utility.truncate(location.ISO_State_Code_SAP__c,3);
            if (!String.isBlank(location.VAT_Number__c) && !String.isBlank(location.ISO_Country_Code__c))
                if (!location.VAT_Number__c.startsWithIgnoreCase(location.ISO_Country_Code__c))
                    shipTo.VAT_Reg_No = Utility.truncate(location.ISO_Country_Code__c + location.VAT_Number__c,20);
                else
                    shipTo.VAT_Reg_No = Utility.truncate(location.VAT_Number__c,20);
            shipTo.Contact      = contactInfo; 
        }

        //-- Sold To Information: sent all the time 
        request.SoldTo = soldTo;

        //-- Bill To Information: for CSP, CBP, UBP and DBP
        if(request.RequestType == 'CSP' || request.RequestType == 'CBP' || request.RequestType == 'UBP' || request.RequestType == 'DBP') request.BillTo = billTo;

        //-- Ship To Information: for CSP, CSH, USH and DSH
        if(request.RequestType == 'CSP' || request.RequestType == 'CSH' || request.RequestType == 'USH' || request.RequestType == 'DSH') request.ShipTo = shipTo;

        return request;
    } 

    
    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      Logic to make SAP callouts                                                              *
     ************************************************************************************************/
    public static void syncCustomerMasterWithSAP(List<Location__c> locations)
    {
        //-- Build Request objects for SAP call 
        Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request> requestByLocation = new Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request>(); 
        Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response> responseByLocation = new Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response>();

        //-- Sold To Location By Contact 
        Set<Id> contactIds = new Set<Id>();
        for(Location__c location : locations)
        {
            contactIds.add(location.Contact__c);
        }

        Location_Sel lSelector = new Location_Sel(); 
        Map<Id, Location__c> soldToLocationByContactId = lSelector.getSoldToLocationByContactId(contactIds);

        //-- Locations MAP 
        Map<Id, Location__c> locationById = new Map<Id, Location__c>(locations);
        
        map<String,String> ContactIdByAccountId = new map<String,String>();

        for(Location__c location : locations)
        {
        	requestByLocation.put(location.Id, createCustomerMasterRequestObject(location, soldToLocationByContactId));
            if(location.Contact__c != null)
            	ContactIdByAccountId.put(Utility.truncate(location.Contact__c,15),Utility.truncate(location.Account__c,15));
        }

        //-- Set Authentication header 
        SAP_CustomerMaster.HTTPS_Port req = new SAP_CustomerMaster.HTTPS_Port(); 
        req = setCalloutHeader(req);

        //-- Errors logging
        List<IEC_Error_Log__c> errorLogs = new List<IEC_Error_Log__c>();
        
        Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request> request2Reprocess = new Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request>();
		
		Map<Id,String> SAPAccountByAccountId = new Map<Id,String>();
		
		
		
        //-- Do Callouts for each location 
        for(Id locationId : requestByLocation.keySet())
        {
        	
            SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = requestByLocation.get(locationId);
            
            try
            {
            	SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response = req.SI_SFDC_CustomerMasterUpdate_SYNC(request);
                if(response.Error != null /*&& response.Error.Message.contains('locked')*/)
                {
                   request2Reprocess.put(locationId, request); 
                }
                else
                {
                    responseByLocation.put(locationId, response);
                    if(request.RequestType == 'CSP')
                    	SAPAccountByAccountId.put(response.SAP_SoldTo.SFDCAccountID, response.SAP_SoldTo.SAPSoldToID);
                }
            }
            catch(Exception ex)
            {
                if(!System.isFuture() && !System.isBatch() && !System.isScheduled())
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,ex.getMessage()));
                else
                    errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerMasterWithSAP', JSON.serialize(request), ex.getMessage(), ex.getStackTraceString()));                
            }
        }
        
        //-- Updated 2016-07-01 David D & Kevin K to reprocess failled SAP Customer master when sold to is locked
        if(!request2Reprocess.isEmpty())
        {
            for(Id locationId : request2Reprocess.keySet())
            {
                SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = request2Reprocess.get(locationId);
                try
                {
                	//if the SAPSoldToId is missing in the BillTo or ShipTo request 
                	if((request.RequestType == 'CBP' || request.RequestType == 'CSH') && (request.SoldTo == null || String.isBlank(request.SoldTo.SAPSoldToID))){
                		if(request.RequestType == 'CBP'){
                			String accountId = ContactIdByAccountId.get(request.BillTo.SearchTerm1);
                			if(accountId != null)
                				request.SoldTo.SAPSoldToID = SAPAccountByAccountId.get(accountId);
                		}
                		if(request.RequestType == 'CSH'){
                			String accountId = ContactIdByAccountId.get(request.ShipTo.SearchTerm1);
                			if(accountId != null)
                				request.SoldTo.SAPSoldToID = SAPAccountByAccountId.get(accountId);
                		}
                			
                	}
                		
                	
                    SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response = req.SI_SFDC_CustomerMasterUpdate_SYNC(request);
                    
                    responseByLocation.put(locationId, response);
                }
                catch(Exception ex)
                {
                    if(!System.isFuture() && !System.isBatch() && !System.isScheduled())
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,ex.getMessage()));
                    else
                        errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.syncCustomerMasterWithSAP', JSON.serialize(request), ex.getMessage(), ex.getStackTraceString()));                
                }
            }
        }

        if(errorLogs.size() > 0) IECErrorLogger.logErrors(errorLogs, true);
        
        //-- Update with SAP response 
        processResponse(responseByLocation, requestByLocation);
    }

    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function is called by trigger when location is created/updated                     *
     *      Or when certain Contact information such as email changed                               *
     *      Then the changes are sent to SAP                                                        *
     ************************************************************************************************/
    public static void syncCustomerMasterWithSAP(Set<Id> locationIds)
    {   
        //set<Id> locationIdsToSend = new set<Id>();

        //for(Id locationId : locationIds){
        //    String methodName = Utility.idsInTriggers.get(locationId);
        //    if(methodName != null && methodName == 'syncCustomerMasterWithSAP'){
        //        //if(location.SAP_Id__c == oldLocation.SAP_Id__c)
        //        {
        //            locationIdsToSend.add(locationId);
        //        }
        //    }else{
        //        Utility.idsInTriggers.put(locationId,'syncCustomerMasterWithSAP');
        //    }
        //}
        
        //if(!locationIdsToSend.isEmpty())
        if(locationIds.size() == 1)
        {
            List<Location__c> locations = (List<Location__c>) new Location_Sel().selectSObjectById(locationIds);
            System.enqueueJob(new Location_Queue(locations));
        }
        else if (!locationIds.isEmpty()) Database.executeBatch(new Location_Batch(locationIds), 10);
            
    }

    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      Same as previous function called when we are about to sync ShipTo or BillTo             *
     *      without SoldTo                                                                          *
     ************************************************************************************************/
    public static void syncCustomerMasterWithSAP(Set<Id> locationIds, Set<Id> soldToLocationIds2CreateFirst)
    {
    	
        if (!locationIds.isEmpty() || !soldToLocationIds2CreateFirst.isEmpty())
            Database.executeBatch(new Location_Batch(locationIds, soldToLocationIds2CreateFirst), 10);
        
        //System.debug('syncCustomerMasterWithSAP CREATE SOLDTO FIRST');

        //set<Id> locationIdsToSend = new set<Id>();
        //set<Id> soldToLocationIdsToSend = new set<Id>();

        //for(Id locationId : locationIds){
        //    String methodName = Utility.idsInTriggers.get(locationId);
        //    if(methodName != null && methodName == 'syncCustomerMasterWithSAP'){
        //        //if(location.SAP_Id__c == oldLocation.SAP_Id__c)
        //        {
        //            locationIdsToSend.add(locationId);
        //        }
        //    }else{
        //        Utility.idsInTriggers.put(locationId,'syncCustomerMasterWithSAP');
        //    }
        //}

        //for(Id soldToLocationId : soldToLocationIds2CreateFirst){
        //    String methodName = Utility.idsInTriggers.get(soldToLocationId);
        //    if(methodName != null && methodName == 'syncCustomerMasterWithSAP'){
        //        //if(location.SAP_Id__c == oldLocation.SAP_Id__c)
        //        {
        //            soldToLocationIdsToSend.add(soldToLocationId);
        //        }
        //    }else{
        //        Utility.idsInTriggers.put(soldToLocationId,'syncCustomerMasterWithSAP');
        //    }
        //}

        //if(!locationIdsToSend.isEmpty() && !soldToLocationIdsToSend.isEmpty())
        //    Database.executeBatch(new Location_Batch(locationIdsToSend, soldToLocationIdsToSend), 10);
    }
    
    /************************************************************************************************
     *  Created By David D 02/2016                                                                  *
     *      This function update SAP_Id fields on Location                                          *
     ************************************************************************************************/
    public static void processResponse(Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response> responseByLocation, Map<Id, SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request> requestByLocation)
    {
        Location_Sel lSelector = new Location_Sel(); 
        List<Location__c> locations = (List<Location__c>) lSelector.selectSObjectById(responseByLocation.keySet());

        Map<Id, Account> accounts2Update = new Map<Id, Account>();

        //-- Errors logging
        List<IEC_Error_Log__c> errorLogs = new List<IEC_Error_Log__c>();

        for(Location__c location : locations)
        {
            SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response = responseByLocation.get(location.Id);
            SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Request request = requestByLocation.get(location.Id);

            if(location.Type__c == 'Sold To' && response.SAP_SoldTo != null)
            {
                location.SAP_Id__c = response.SAP_SoldTo.SAPSoldToID;
                accounts2Update.put(response.SAP_SoldTo.SFDCAccountID,new Account(Id=response.SAP_SoldTo.SFDCAccountID, Sales_Office__c=response.SAP_SoldTo.SalesOffice, Payment_Term__c=response.SAP_SoldTo.PaymentTerms, Price_Group__c=response.SAP_SoldTo.PriceGroup));
            } 
            else if(location.Type__c == 'Bill To' && response.SAP_BillTo != null) location.SAP_Id__c = response.SAP_BillTo.SAPBillToID; 
            else if(location.Type__c == 'Ship To' && response.SAP_ShipTo != null)  location.SAP_Id__c = response.SAP_ShipTo.SAPShipToID;
            
            if(response.Error != null) errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.processResponse', JSON.serialize(request),JSON.serialize(response.Error), null));             
        }

        if(!accounts2Update.isEmpty())
        {
            try{update accounts2Update.values();}
            catch(Exception ex){errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.processResponse', JSON.serialize(locations), ex.getMessage(), ex.getStackTraceString()));}     
        }


        //-- Update Locations : be sure that triggers are not recall SAP after this update  
        try{update locations;}
        catch(Exception ex){errorLogs.add(IECErrorLogger.createErrorLog('IECAddress_Svc.processResponse', JSON.serialize(locations), ex.getMessage(), ex.getStackTraceString()));}

        if(errorLogs.size() > 0) IECErrorLogger.logErrors(errorLogs, true);
    }

    /**
     * Function will prepare a batch job to make api object update to Zuora with updated contacts' address
     *
     * @param setAddressId The set of IECAddress__c Ids that has been modified
     */
    public static void syncIECAddressWithZuora(Set<Id> setAddressId) {
        try {
            String query  = ' SELECT Id, Contact__c, Account__c, Address__c, Type__c, Account_Contact_ID__c' +
            '   , Contact_First_Name__c, Contact_Last_Name__c, Email__c, Phone__c ' +
            '   , Country__c, State__c, City__c, ZipCode__c, Street__c, VAT_Number__c, SAP_Id__c' +  
            '   FROM Location__c WHERE Account__c <> NULL' +
            '   AND Contact__c <> NULL ' +
            '   AND Address__c IN :setAddressId' +
            '   AND Active__c = true' +
            '   AND Type__c = \'Bill To\''; 

            List<Location__c> lstLocation = Database.query(query);

            //Call by queueable if less than 50000 locations
            if(lstLocation != null && lstLocation.size() > 0)
                Id jobID = System.enqueueJob(new ContactAddressZSync_Queueable(lstLocation, setAddressId, 'IECAddress'));
            
        }
        catch(LimitException e){
            //Call Batch if we have more than 50000 locations
            ContactAddressZSync_Batch btch = new ContactAddressZSync_Batch(setAddressId, 'IECAddress');
            Database.ExecuteBatch(btch);
        }
        catch (Exception ex) {
            IECErrorLogger.logApexException('IECAddress_Svc.syncIECAddressWithZuora', 'setAddressId: ' + setAddressId, ex.getMessage(), ex.getStackTraceString());
        }
    }
    
    /**
     * Function will query all location records that reference the specified IECAddress
     * record and make an update to SAP
     *
     * @param setAddressId The set of IECAddress__c Ids that has been modified
     */
    public static void syncIECAddressWithSAP(Set<Id> setAddressId) {
        // The map of Location that will be synced with SAP
        Map<Id, Location__c> mapLocation = new Map<Id, Location__c>(
            [SELECT Id
            FROM Location__c
            WHERE Address__c IN :setAddressId
                AND Active__c = true
                AND Type__c IN ('Sold To', 'Bill To', 'Ship To')]);
        
        // Make the SAP call to update the account/contact
        if (!mapLocation.isEmpty())
        {
            IECAddress_Svc.syncCustomerMasterWithSAP(mapLocation.keySet());
        }
    }
    
    // Determine whether there is a difference between two address records
    public static Boolean isAddressChanged(IECAddress__c oAddress1, IECAddress__c oAddress2)
    {
        if (oAddress1 == null && oAddress2 == null)
            return false;
        else if (oAddress1 == null && oAddress2 != null || oAddress1 != null && oAddress2 == null)
            return true;
        else
            return (oAddress1.Street__c != oAddress2.Street__c || oAddress1.City__c != oAddress2.City__c || oAddress1.ZipCode__c != oAddress2.ZipCode__c || oAddress1.ISO_Country__c != oAddress2.ISO_Country__c || oAddress1.ISO_State__c != oAddress2.ISO_State__c);
    }

    public static Boolean isAddressChanged(Address_DTO adr1, Address_DTO adr2)
    {
        if (adr1 == null && adr2 == null)
            return false;
        else if (adr1 == null && adr2 != null || adr1 != null && adr2 == null)
            return true;
    	
        String full1 = adr1.street1 +'|'+ adr1.street2 +'|'+ adr1.city +'|'+ adr1.stateCode +'|'+ adr1.postalCode +'|'+ adr1.countryCode;
    	full1 = full1.replace(' ','').trim().toLowerCase();
		
		String full2 = adr2.street1 +'|'+ adr2.street2 +'|'+ adr2.city +'|'+ adr2.stateCode +'|'+ adr2.postalCode +'|'+ adr2.countryCode;
    	full2 = full2.replace(' ','').trim().toLowerCase();		

        System.debug('full1::'+full1);
        System.debug('full2::'+full2);

    	return (full1 != full2);
    }

    //verified if the address change
	public static Location__c updateAddress(
							String street,String city, Id isoCountryId,Id isStateId,String zipCode, String VATNumber,
							Contact loginContact,String locationType
							){
		

		List<IECAddress__c> existingAddresses = new IECAddress_Sel().getAddressByIsoIds(street,city, isoCountryId, isStateId,zipCode);

        Id iecAddressId;
        //if address already exist, just change the location reference to that Address
        if(existingAddresses != null && existingAddresses.size() > 0){
            iecAddressId = existingAddresses[0].Id;
        }else{
            //If address don't existe create a new one and update the Location
            IECAddress__c newIECAddress = createNewIECAddress(street,city, isoCountryId, isStateId,zipCode);
            if(newIECAddress != null){
            	iecAddressId = newIECAddress.Id;
            }
        }

        //Get the login Contact Billing Location
        List<Location__c> lstBillToLocation;
		if(locationType == IECConstants.SHIPTO)
			lstBillToLocation = new Location_Sel().getLocations(new set<Id>{loginContact.BillTo_Location__c});

		//Create a new BillTolocation
        if(lstBillToLocation == null && iecAddressId != null){
            lstBillToLocation.add(Location_Svc.createLocation(iecAddressId,loginContact,VATNumber, locationType));
            //Update the Contact with the new BillTo Location as defautl Billto Location
            loginContact.BillTo_Location__c = lstBillToLocation[0].Id;
            update loginContact;
        }

        //Update the Location with the new Address
        if(iecAddressId != null && lstBillToLocation != null && lstBillToLocation.size() > 0){
        	lstBillToLocation[0].Address__c = iecAddressId;
        	update lstBillToLocation[0];
        }

        return lstBillToLocation[0];
	}

	public static IECAddress__c createNewIECAddress(String street,String city, Id isoCountryId,Id isStateId,String zipCode){
		//Create a new IECAddress
        IECAddress__c iecAddress 	= 	new IECAddress__c();
        iecAddress.Street__c 		= 	street;
        iecAddress.City__c 			= 	city;
        iecAddress.ISO_Country__c 	= 	isoCountryId;
        iecAddress.ISO_State__c 	= 	isStateId;
        iecAddress.ZipCode__c 		= 	zipCode;

        try{
            insert iecAddress;
        }catch(Exception ex){
            //IECErrorLogger.logApexException('IECAddress_Svc.createNewIECAddress', JSON.serialize(iecAddress), ex.getMessage(), ex.getStackTraceString());
            return null;
        }
        return iecAddress;
	}

	public static IECAddress__c newAddress(String street,String city, String countryCode, String stateCode, String zipCode)
	{
		List<IATA_ISO_Country__c> isoCountries = ISO_Country_State_Helper.getIsoCountryByIsoCode(countryCode);
		Id countryId; 
		Id stateId; 

	    if(isoCountries != null && isoCountries.size() > 0){
	        countryId = isoCountries[0].Id;
	        if(String.isNotBlank(stateCode))
	        {
	        	List<IATA_ISO_State__c> isoStates = ISO_Country_State_Helper.getIsoStateByIsoCode(countryCode, stateCode);
	        	if(isoStates != null && isoStates.size() > 0)
	        	{
	        		stateId = isoStates[0].Id;
	        	}	
	        }
	    }
	    
		IECAddress__c address = new IECAddress__c(
			Street__c = street,
			City__c = city,
			ISO_Country__c = countryId,
			ISO_State__c = stateId,
			ZipCode__c = zipCode
		);

		try{
			insert address; 
			return address;
		}catch(Exception e){
			return null;			
		}
	}
}