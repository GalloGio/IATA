public without sharing class AMS_AgencyUpdateHelper {

    public static Set<Id> accSentToExternalSystemFlag = new Set<Id>();

    public static void agencyRelathionshipUpdate(List<SObject> updatedRecords){
        List<AMS_Agency_Updates__c> agencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        Set<Id> setIds = new Set<Id>();//set of ids that are not agency relathionship
        Set<Id> idsToQuery = new Set<Id>();
        for(SObject obj: updatedRecords){
            if(obj.getSObjectType() != Schema.AMS_Agencies_relationhip__c.getSObjectType())
                setIds.add(obj.Id);
            else
                idsToQuery.add(obj.Id);
        }

        //get all records updated that are related to a agency relathionship
        Map<ID,AMS_Agencies_relationhip__c> agenciesRel = new Map<ID,AMS_Agencies_relationhip__c>([Select id from AMS_Agencies_relationhip__c where Hierarchy__c In :setIds]);
        idsToQuery.addAll(agenciesRel.keySet());

        //get the already existing Agency Updates related to the agency relationships to ensure that there is only one record in agency update
        //related to a agency relathionship
        List<AMS_Agency_Updates__c> aulist = [select id, RelationShip__c from AMS_Agency_Updates__c where RelationShip__c in :idsToQuery and Update_Type__c <> 'Update_Sent'];
        Set<Id> agenciesAlreadyUpdated = new Set<Id>();
        for(AMS_Agency_Updates__c au: aulist){
            agenciesAlreadyUpdated.add(au.RelationShip__c);
        }

        //remove agencies that already have an agency update record
        idsToQuery.removeAll(agenciesAlreadyUpdated);

        //create the Agency Update records
        for(Id toCreate: idsToQuery){
            AMS_Agency_Updates__c aux = new AMS_Agency_Updates__c(RelationShip__c = toCreate, Update_Type__c = 'Update');
            agencyUpdateToInsert.add(aux);
        }

        if(agencyUpdateToInsert.size() > 0)
            insert agencyUpdateToInsert;

        return;
    }

    public static void agencyUpdate(List<SObject> updatedRecords){
        List<AMS_Agency_Updates__c> agencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        Set<Id> agencyIds = new Set<Id>();
        for(SObject obj: updatedRecords){
            if(obj.getSObjectType() != Schema.Account.getSObjectType()){
                agencyIds.add((Id)obj.get('Account__c'));//all the fields relating to Agency in every other object as API name Agency__c
            }
            else
                agencyIds.add(obj.Id);
        }

        //get the already existing Agency Updates related to the agency to ensure that there is only one record in agency update related to the agency
        List<AMS_Agency_Updates__c> aulist = [select id, Account__c from AMS_Agency_Updates__c where Account__c in :agencyIds and Update_Type__c <> 'Update_Sent'];
        Set<Id> agenciesAlreadyUpdated = new Set<Id>();
        for(AMS_Agency_Updates__c au: aulist){
            agenciesAlreadyUpdated.add(au.Account__c);
        }
 
        //remove agencies that already have an agency update record
        agencyIds.removeAll(agenciesAlreadyUpdated);

                ////Validate ShippingState and ShippingCountry
        //List<Account> aulist_shippingAddress = [select id,  Name, IATACode__c,ShippingState, ShippingCountry from Account where id in :agencyIds ];
        //Set<Id> agenciesShippingError = new Set<Id>();
        //for(Account au: aulist_shippingAddress){

        //    Boolean bError = false;
        //    String accErrors = '';
        //    if(String.isNotEmpty(au.ShippingState) && !AMS_Utils.isValidState(au.ShippingState) ){
        //        accErrors += au.Name+' ('+au.IATACode__c+'-'+au.id+'): Shipping State is invalid - ' + au.ShippingState + '\n';
        //        bError = true;
        //    }
        //    if(String.isNotEmpty(au.ShippingCountry) && !AMS_Utils.isValidCountry(au.ShippingCountry) ){
        //        accErrors += au.Name+' ('+au.IATACode__c+'-'+au.id+'): Shipping Country is invalid - ' + au.ShippingCountry + '\n';
        //        bError = true;
        //    }
        //    if(bError){
        //        agenciesShippingError.add(au.id);

        //        //create Log entry
        //        Technical_Logs__c tlog = new Technical_Logs__c();
        //        tlog.Status__c = 'Error';
        //        tlog.Operation__c = 'Agency Update Shipping Validation';
        //        DateTime dtStart = system.now();
        //        tlog.start_date__c = dtStart;
        //        DateTime dtEnd = system.now();
        //        tlog.End_Date__c = dtEnd;
        //        tlog.Log__c = accErrors;
        //        tlog.Record__c = au.IATACode__c+' - '+au.id;
        //        try {
        //            insert tlog;
        //        }catch (Exception ex) {
        //                system.debug('Log writing error: ' + ex.getMessage());
        //        }    
        //    }
        //}

        ////remove agencies that had Shipping validation errors 
        //agencyIds.removeAll(agenciesShippingError);
        
        //Validate IATACode
        //Set<Id> setAccountsToValidate = new Set<Id>();
        //List<Account> aulist_validate = [select id,  Name, IATACode__c,ShippingState, ShippingCountry from Account where id in :agencyIds ];

        //List<Agency_Applied_Change_code__c> lAgencyAppliedChangeCode = [SELECT Account__c,Account__r.IATACode__c,Active__c,Change_Code__c 
        //                        FROM Agency_Applied_Change_code__c 
        //                        WHERE Change_Code__c != null 
        //                        AND Active__c = true 
        //                        AND Account__c in :agencyIds];

        //for(Agency_Applied_Change_code__c aacc: lAgencyAppliedChangeCode){
        //    setAccountsToValidate.add(aacc.Account__c);
        //}

        //Set<Id> agenciesValidateError = new Set<Id>();
        //for(Account au: aulist_validate){

        //    Boolean bError = false;
        //    Boolean bErrorLog = false;
        //    String accErrors = '';
            
        //    //Validates if IATACODE is empty
        //    //result: will not create the Agency Update Record and will not create a Log entry
        //    if( String.isEmpty(au.IATACode__c) ){
        //        bError = true;
        //        bErrorLog = false;
        //    }

        //    //Validates if IATACODE is empty and if a Active Change code exists
        //    //result: will not create the Agency Update Record and will create a Log entry
        //    if(String.isEmpty(au.IATACode__c) && setAccountsToValidate.contains(au.Id) ){
        //        accErrors += au.Name+' ('+au.IATACode__c+'-'+au.id+'): IATACode - ' + au.ShippingCountry + '\n';
        //        bError = true;
        //        bErrorLog = true;
        //    }

        //    if(bError){
        //        agenciesValidateError.add(au.id);
        //    }
            
        //    if(bErrorLog){
        //        //create Log entry
        //        Technical_Logs__c tlog = new Technical_Logs__c();
        //        tlog.Status__c = 'Error';
        //        tlog.Operation__c = 'Agency Update IATACode Validation';
        //        DateTime dtStart = system.now();
        //        tlog.start_date__c = dtStart;
        //        DateTime dtEnd = system.now();
        //        tlog.End_Date__c = dtEnd;
        //        tlog.Log__c = accErrors;
        //        tlog.Record__c = au.id;
        //        try {
        //            insert tlog;
        //        }catch (Exception ex) {
        //                system.debug('Log writing error: ' + ex.getMessage());
        //        }    
        //    }
        //}

        ////remove agencies that had Shipping validation errors 
        //agencyIds.removeAll(agenciesValidateError);
        
        system.debug('accSentToExternalSystemFlag: ' + accSentToExternalSystemFlag);
        //remove agencies that have been updated on integration with SAP 
        agencyIds.removeAll(accSentToExternalSystemFlag);

        //create the Agency Update records
        for(Id toCreate: agencyIds){
            AMS_Agency_Updates__c aux = new AMS_Agency_Updates__c(Account__c = toCreate, Update_Type__c = 'Update');
            agencyUpdateToInsert.add(aux);
        }

        if(agencyUpdateToInsert.size() > 0)
            insert agencyUpdateToInsert;

        return;
    }

    public static void accountUpdate(List<AMS_Agency_Updates__c> sentUpdates) {   
        List<Account> integratedAccounts = new List<Account>();
        List<Account> integratedAccountsNoDuplicates = new List<Account>();
        for(AMS_Agency_Updates__c updatedAgency : sentUpdates){
            integratedAccounts.add(new Account(Id = updatedAgency.Account__c, Sent_to_External_System__c = true));
        }

        //remove duplicates - Sets, by definition, contain no duplicates.  So, the first addAll() causes any dupes to overwrite themselves when going into the set
        Set<Account> setIntegratedAccounts = new Set<Account>();
        setIntegratedAccounts.addAll(integratedAccounts);
        integratedAccountsNoDuplicates.addAll(setIntegratedAccounts);

        update integratedAccountsNoDuplicates;
    }
    
    
    
    /*AMSFTS: duplicated code
    public static void updateAccountWithParentId(List<AMS_Agencies_relationhip__c> relationships){
         //need to query again to retrieve some fields of parent object
        
        List<Id> agencyIds = new List<Id>(); 
        List<Id> relationshipids = new List<Id>(); 
        Map<Id,Id> AgChildToAgParent = new Map<Id,Id>(); 
        
        for(AMS_Agencies_relationhip__c h : relationships){
            relationshipids.add(h.id);
            AgChildToAgParent.put(h.Child_Account__c, h.Parent_Account__c);
            agencyIds.add(h.Child_Account__c);
            agencyIds.add(h.Parent_Account__c);
        }
        relationships = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__r.RecordType.DeveloperName FROM AMS_Agencies_relationhip__c WHERE Id IN :relationshipids];
        Map<Id,Account> IdToAgencies = new Map<Id,Account>([SELECT Name, Id FROM Account WHERE Id IN :agencyIds]); 
              

        
        // updating the child account with the id of the parent
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        for(AMS_Agencies_relationhip__c h : relationships){
            if(h.Hierarchy__r.RecordType.DeveloperName == 'MAIN'){
                Account ch = IdToAgencies.get(h.Child_Account__c);
                if(accountsToUpdate.get(ch.Id)!=null){
                    continue;
                }
                Id parentid = IdToAgencies.get(h.Parent_Account__c).Id;
                ch.ParentId = parentid;
                if(parentid!=null)
                    accountsToUpdate.put(ch.id,ch);
            }
        }
        
        if(accountsToUpdate.size()>0)
            update accountsToUpdate.values();
        
    }*/
}