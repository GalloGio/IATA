public without sharing class AMS_AgencyUpdateHelper {

    public static Set<Id> accSentToExternalSystemFlag = new Set<Id>();
/*
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
*/
    public static void agencyUpdate(List<SObject> updatedRecords){
        List<AMS_Agency_Updates__c> agencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> agencyUpdateToUpdate = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> invalidAgencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> reEvaluateAgencyUpdate = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> toRemoveAgencyUpdate = new List<AMS_Agency_Updates__c>();

        //get the change code settings to skip agency update generation
        Set<String> codesToSkipUpdate = new Set<String>();
        for(AMS_ChangeCodes__c codeConf :[SELECT Change_Code__c FROM AMS_ChangeCodes__c WHERE Skip_Agency_Update__c = true]){
            codesToSkipUpdate.add(codeConf.Change_Code__c);
        }

        Map<Id, Agency_Applied_Change_code__c> mAgencyChangeCode= new Map<Id, Agency_Applied_Change_code__c>();
        Set<Id> agencyIds = new Set<Id>();
        for(SObject obj: updatedRecords){
            //only create update if the change code corresponding change code setting is not flagged to skip agency update;
            if (obj.getSObjectType().getDescribe().getName() == 'Agency_Applied_Change_code__c' && !codesToSKipUpdate.contains((String)obj.get(Schema.Agency_Applied_Change_code__c.Change_Code__c))){
                if(obj.getSObjectType() != Schema.Account.getSObjectType()){
                    agencyIds.add((Id)obj.get('Account__c'));//all the fields relating to Agency in every other object as API name Agency__c
                }
                else
                    agencyIds.add(obj.Id);
            }
        }


        //get the already existing Agency Updates related to the agency to ensure that there is only one record in agency update related to the agency
        //List<Account> aulist = [select id,  Name, IATACode__c,ShippingState, ShippingCountry,
        //        (select id,Update_Type__c from AMS_Agency_Updates__r), 
        //        (SELECT Account__c,Account__r.IATACode__c,Active__c,Change_Code__c from Agencies_Applied_Change_codes__r WHERE Change_Code__c != null AND Active__c = true)
        //        from Account where id in :agencyIds];

        List<Account> aulist = [select id,  Name, IATACode__c,BillingStreet,IATA_ISO_Country__c,BillingCity,BillingPostalCode,
                                            Top_Parent__c,Location_Type__c,Status__c,CASS_Number__c,Check_Digit__c,Location_Class__c,
                (select id,Update_Type__c,Change_Code__c,Account__c,Status__c from AMS_Agency_Updates__r where Integration_System__c = 'SAP PI' ), 
                (SELECT Account__c,Account__r.IATACode__c,Active__c,Change_Code__c,For_Integration__c from Agencies_Applied_Change_codes__r WHERE Change_Code__c != null AND For_Integration__c = true)
                from Account where id in :agencyIds];


        //Checks for for the accounts passed on the trigger, to see if existing records with status different from "Update_Sent", already exist for those accounts
        //if they exist these accounts are marked to be removed from the list to create agecu update records
        Set<Id> agenciesAlreadyUpdated = new Set<Id>();
        Set<Id> agenciesUpdateNotToCreate = new Set<Id>();
        Set<Id> setToRemoveAgencyUpdate = new Set<Id>();
        Set<Id> setReEvaluateAgencyUpdate = new Set<Id>();
        
        
        for(Account au: aulist){
            Boolean bAlreadyUpdated = false;
            Boolean bToReEvaluateUpdate = false;
            for(AMS_Agency_Updates__c au2: au.AMS_Agency_Updates__r){

                //FM 22-09-2016 - added condition to "Invalid" status to be not ignored
                //if(!au2.Update_Type__c.equalsIgnoreCase('Update_Sent')){
                if(!au2.Update_Type__c.equalsIgnoreCase('Update_Sent') && !au2.Update_Type__c.equalsIgnoreCase('Invalid') && !au2.Update_Type__c.equalsIgnoreCase('Deleted')){
                    bAlreadyUpdated = true;
                    break;
                }
            }
            if(bAlreadyUpdated) agenciesAlreadyUpdated.add(au.Id);

            //Checks if there's a record on update status that needs to be rechecked
            for(AMS_Agency_Updates__c au2: au.AMS_Agency_Updates__r){

                if(au2.Update_Type__c.equalsIgnoreCase('Update') ){
                    bToReEvaluateUpdate = true;
                    reEvaluateAgencyUpdate.add(au2);
                    setReEvaluateAgencyUpdate.add(au2.Account__c);
                    break;
                }
                
            }
            
        }

 
        //remove agencies that already have an agency update record
        agencyIds.removeAll(agenciesAlreadyUpdated);

        //Validate IATACode
        Set<Id> setAccountsToValidate = new Set<Id>();
      
        for(Account au: aulist){
            if(au.Agencies_Applied_Change_codes__r.size() > 0){

                List<Agency_Applied_Change_code__c> lAuxACC = au.Agencies_Applied_Change_codes__r;
                Agency_Applied_Change_code__c auxACC = new Agency_Applied_Change_code__c();
System.debug('au.Agencies_Applied_Change_codes__r: ' + au.Agencies_Applied_Change_codes__r);
                for(Agency_Applied_Change_code__c aacc : lAuxACC){
System.debug('auxACC: ' + auxACC);  
System.debug('aacc: ' + aacc);                  
                    if(aacc.For_Integration__c == true){
                        if(auxACC == null){
                            auxACC = aacc;
                        }else{
                            String sRecIdA = AMS_Utils.getRecIdFromChangeCode( auxACC.Change_Code__c );
                            String sRecIdB = AMS_Utils.getRecIdFromChangeCode( aacc.Change_Code__c );

System.debug('sRecIdA: ' + sRecIdA);
System.debug('sRecIdB: ' + sRecIdB);

                            //Validates if the RecId for both Change Codes are equal or not
                            if(sRecIdA != sRecIdB){

                                String sRecIdRes = AMS_Utils.getRecIdFromIntegrationMatriz( sRecIdA, sRecIdB );
System.debug('sRecIdRes: ' + sRecIdRes);
                                //RB 10-11-2017 - If the determined recId is 'D' check the account status, and if not Terminated, force recId = 'C'
                                //RB 16-04-2018 this validation should only be applied when checking against an already existing agency update record.
                                /*if(sRecIdRes == 'D' && au.Status__c != 'Terminated'){
                                    sRecIdRes = 'C';
                                }*/
System.debug('sRecIdRes after D: ' + sRecIdRes);                              
                                //Check if the agency update record is to delete or not save at all!!
                                if(sRecIdRes == 'F'){
                                    //remove entry
                                    agenciesUpdateNotToCreate.add(aacc.Account__c);
                                    auxACC = aacc;
                                      //only need to check against "B" value, if "B" wins we change the auxACC to the 2nd change code
                                }else if(sRecIdRes == sRecIdB){
                                    auxACC = aacc;
                                }

                            }else{
                                //if both change code are of the same type (ex:"C") we check if the record being tested is the active one, if so that one becomes the one to use
                                if(aacc.Active__c == true){
                                    auxACC = aacc;
                                }
                            }
                        }
                        
                    }
                }
System.debug('reEvaluateAgencyUpdate: ' + reEvaluateAgencyUpdate);
                //Check again, this time against the already existing agecy update record
                if(reEvaluateAgencyUpdate.size() > 0){

                    String sRecIdWinner = '';

                    for(AMS_Agency_Updates__c au3: reEvaluateAgencyUpdate){

                        if(au3.Account__c == auxACC.Account__c){
                            String sRecIdA = AMS_Utils.getRecIdFromChangeCode( au3.Change_Code__c );
                            String sRecIdB = AMS_Utils.getRecIdFromChangeCode( auxACC.Change_Code__c);
System.debug('sRecIdA: ' + sRecIdA);
System.debug('sRecIdB: ' + sRecIdB);
System.debug('sRecIdWinner: ' + sRecIdWinner);
                            if(sRecIdWinner != ''){
                                sRecIdB = sRecIdWinner;
                            }

                            //Validates if the RecId for both Change Codes are equal or not
                            if(sRecIdA != sRecIdB){

                                String sRecIdRes = AMS_Utils.getRecIdFromIntegrationMatriz( sRecIdA, sRecIdB );
                                sRecIdWinner = sRecIdRes;
System.debug('sRecIdRes: ' + sRecIdRes);
System.debug('setToRemoveAgencyUpdate: ' + setToRemoveAgencyUpdate);
                                //RB 10-11-2017 - If the determined recId is 'D' check the account status, and if not Terminated, force recId = 'C'
                                if(sRecIdRes == 'D' && au3.Status__c != 'Terminated'){
                                    sRecIdRes = 'C';
                                }
System.debug('sRecIdRes after D: ' + sRecIdRes);
                                //Check if the agency update record is to delete or not save at all!!
                                if(sRecIdRes == 'F'){
                                    //remove entry
                                    au3.Update_Type__c = 'Deleted';
                                    au3.Change_Code__c = '';
                                    if(setToRemoveAgencyUpdate == null || !setToRemoveAgencyUpdate.contains(au3.Account__c) ){
System.debug('au3: ' + au3);                                        
                                        toRemoveAgencyUpdate.add(au3);
                                        setToRemoveAgencyUpdate.add(au3.Account__c);
                                    }
                                
                                      //only need to check against "B" value, if "B" wins we change the auxACC to the 2nd change code
                                }else if(sRecIdRes == sRecIdB){
                                    au3.Change_Code__c = auxACC.Change_Code__c;
                                }

                            }else{
                                //if both change code are of the same type (ex:"C") we check if the record being tested is the active one, if so that one becomes the one to use
                                au3.Change_Code__c = auxACC.Change_Code__c;
                                
                            }
                        }

                    }

                }

                
                mAgencyChangeCode.put(au.Id, auxACC); //Storing change code for use later
                setAccountsToValidate.add(au.Id);
            }
        }

        //remove agencies that have 2 Change codes that cancel each other (ex: an "A" and a "D")
        agencyIds.removeAll(agenciesUpdateNotToCreate);
        agencyIds.removeAll(setToRemoveAgencyUpdate);
        

        Set<Id> agenciesValidateError = new Set<Id>();
        Set<Id> agenciesInvalid = new Set<Id>();
        for(Account au: aulist){

            Boolean bError = false;
            Boolean bErrorLog = false;
            Boolean bInvalid = false;

            Boolean bToValidate = setAccountsToValidate.contains(au.Id);

            Agency_Applied_Change_code__c agApplCC = mAgencyChangeCode.get(au.Id);
            String sChangeCode = agApplCC == null ? '' : agApplCC.Change_Code__c;
            String sRecId = AMS_Utils.getRecIdFromChangeCode(sChangeCode);

            String accErrors = '';
            
            //Validates if IATACODE is empty
            //result: on Fail - will create the Agency Update Record in "Invalid" Status and will NOT create a Log entry
            if( String.isEmpty(au.IATACode__c) ){
                bError = true;
                bErrorLog = false;
                bInvalid = true;
            }

            //Validates if IATACODE is empty and if a Active Change code exists
            //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
            if(String.isEmpty(au.IATACode__c) && bToValidate ){
                accErrors += 'IATACode empty - Agency:' + au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                bError = true;
                bErrorLog = true;
                bInvalid = true;
            }

            //Validates if billing address is empty 
            //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
            if(AMS_Utils.isAddressEmpty(au, 'Billing') && bToValidate ){
                accErrors += '\nBilling address empty - Agency: '+au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                bError = true;
                bErrorLog = true;
                bInvalid = true;
            }

            //Validates Hierarchy (null top parent cannot be sent to SAP except for HO, AO)
            //result: on Fail - will create the Agency Update Record in "Invalid" Status and will NOT create a Log entry
            //Site type EP, AO, SP, AA & HO are all considered as HO in PI. - Jitender
            //if(au.Top_Parent__c == null && au.Location_Type__c != 'HO' && au.Location_Type__c != 'AO' && bToValidate){
            if(au.Top_Parent__c == null && !AMS_Utils.LocationTypeAllHOTypes.contains(au.Location_Type__c) && bToValidate){

                

                accErrors += '\nHO Id empty - Agency: '+au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                bError = true;
                bErrorLog = true;     
                bInvalid = true;          
            }

            //Validates if In case change code created will be sent with C or T (change or terminate) to sap check if the account is in status 
            //      “New application pending” and if yes, do not mark the account for update
            //result: on Fail - will NOT create the Agency Update Record Status and will NOT create a Log entry
            if(au.Status__c != null && au.Status__c.equalsIgnoreCase('New application pending') && sRecId != 'A' && bToValidate){
                bError = true;
                bErrorLog = false;
                bInvalid = false;
            }

            //Validates if CASS number field is not empty for all accounts that are C, R , I=Import, Q=Courier?? (need to check from where these values are)
            //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
            if(String.isEmpty(au.CASS_Number__c) && AMS_Utils.LocationClassCARGO.contains(au.Location_Class__c) && bToValidate ){
                accErrors += '\nCASS Number empty - Agency:' + au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                bError = true;
                bErrorLog = true;
                bInvalid = true;
            }

            //Validates if Check that check digit is not empty
            //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
            if(String.isEmpty(au.Check_Digit__c) && bToValidate ){
                accErrors += '\nCheck Digit empty - Agency:' + au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                bError = true;
                bErrorLog = true;
                bInvalid = true;
            }

            if(bError){
                agenciesValidateError.add(au.id);
            }

            if(bInvalid){
                agenciesInvalid.add(au.id);
            }
            
            if(bErrorLog){
                //create Log entry
                Technical_Logs__c tlog = new Technical_Logs__c();
                tlog.Status__c = 'Error';
                tlog.Operation__c = 'Agency Update IATACode Validation';
                DateTime dtStart = system.now();
                tlog.start_date__c = dtStart;
                DateTime dtEnd = system.now();
                tlog.End_Date__c = dtEnd;
                tlog.Log__c = accErrors;
                tlog.Record__c = au.id;
                try {
                    insert tlog;
                }catch (Exception ex) {
                        system.debug('Log writing error: ' + ex.getMessage());
                }    
            }
        }

        //remove agencies that had Shipping validation errors 
        agencyIds.removeAll(agenciesValidateError);
        

        system.debug('accSentToExternalSystemFlag: ' + accSentToExternalSystemFlag);
        //remove agencies that have been updated on integration with SAP 
        agencyIds.removeAll(accSentToExternalSystemFlag);

        //create the Agency Update records - with "Update" status
        for(Id toCreate: agencyIds){
            
            //Get change code to store on agency update record
            Agency_Applied_Change_code__c agApplCC = mAgencyChangeCode.get(toCreate);
            String sChangeCode = agApplCC == null ? '' : agApplCC.Change_Code__c;
            
            AMS_Agency_Updates__c aux = new AMS_Agency_Updates__c(Account__c = toCreate, Update_Type__c = 'Update', Change_Code__c = sChangeCode,Integration_System__c='SAP PI');
            agencyUpdateToInsert.add(aux);
        }

        //create the Agency Update records - with "Invalid" status
        for(Id toCreateInvalid: agenciesInvalid){
            
            //Get change code to store on agency update record
            Agency_Applied_Change_code__c agApplCC = mAgencyChangeCode.get(toCreateInvalid);
            String sChangeCode = agApplCC == null ? '' : agApplCC.Change_Code__c;
            
            AMS_Agency_Updates__c aux = new AMS_Agency_Updates__c(Account__c = toCreateInvalid, Update_Type__c = 'Invalid', Change_Code__c = sChangeCode,Integration_System__c='SAP PI');
            invalidAgencyUpdateToInsert.add(aux);
        }
 

        //create the Agency Update records - with "Invalid" status
        for(AMS_Agency_Updates__c toUpdate: reEvaluateAgencyUpdate){
            //1st check if agency passed the validations
            //if(!agenciesValidateError.contains( toUpdate.Account__c ) ){
            if( !setToRemoveAgencyUpdate.contains(toUpdate.Account__c) && !agenciesValidateError.contains( toUpdate.Account__c ) ){    
                agencyUpdateToUpdate.add(toUpdate);
            }
        }

        //create the Agency Update records - with "Invalid" status
        for(AMS_Agency_Updates__c toUpdateDelete: toRemoveAgencyUpdate){
            agencyUpdateToUpdate.add(toUpdateDelete);
        }


        System.debug('toRemoveAgencyUpdate:' + toRemoveAgencyUpdate);
        System.debug('agencyUpdateToInsert:' + agencyUpdateToInsert);
        System.debug('invalidAgencyUpdateToInsert:' + invalidAgencyUpdateToInsert);
        System.debug('agencyUpdateToUpdate:' + agencyUpdateToUpdate);

        if(agencyUpdateToInsert.size() > 0)
            insert agencyUpdateToInsert;

        if(invalidAgencyUpdateToInsert.size() > 0)
            insert invalidAgencyUpdateToInsert;    


        if(agencyUpdateToUpdate.size() > 0) update agencyUpdateToUpdate;  

        return;
    }

    public static void accountUpdate(List<AMS_Agency_Updates__c> sentUpdates) {   
        List<Account> integratedAccounts = new List<Account>();
        List<Account> integratedAccountsNoDuplicates = new List<Account>();
        for(AMS_Agency_Updates__c updatedAgency : sentUpdates){
            integratedAccounts.add(new Account(Id = updatedAgency.Account__c, Sent_to_External_System__c = true, Last_Integration_Date__c = datetime.now()));
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