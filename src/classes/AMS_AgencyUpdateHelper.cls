public without sharing class AMS_AgencyUpdateHelper {

    public static Set<Id> accSentToExternalSystemFlag = new Set<Id>();

    public static void agencyUpdate(List<SObject> updatedRecords){
        List<AMS_Agency_Updates__c> agencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> agencyUpdateToUpdate = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> invalidAgencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> reEvaluateAgencyUpdate = new List<AMS_Agency_Updates__c>();
        List<AMS_Agency_Updates__c> toRemoveAgencyUpdate = new List<AMS_Agency_Updates__c>();

        Map<Id, Agency_Applied_Change_code__c> mAgencyChangeCode= new Map<Id, Agency_Applied_Change_code__c>();
        Set<Id> agencyIds = new Set<Id>();

        Schema.SObjectType objType = updatedRecords.get(0).getSObjectType();
        String objName = objType.getDescribe().getName();

        for(SObject obj : updatedRecords){
            //only create update if the change code corresponding change code setting is not flagged to skip agency update;
            if (objName == 'Agency_Applied_Change_code__c' && !(Boolean)obj.get('Skip_Agency_Update__c')){
                if(objType != Schema.Account.getSObjectType()){
                    agencyIds.add((Id)obj.get('Account__c'));//all the fields relating to Agency in every other object as API name Agency__c
                }
                else
                    agencyIds.add(obj.Id);
            }
        }


        //get the already existing Agency Updates related to the agency to ensure that there is only one record in agency update related to the agency
        List<Account> aulist = [SELECT Id, Name, IATACode__c, BillingStreet, IATA_ISO_Country__c, BillingCity, BillingPostalCode,
                                            Top_Parent__c, Location_Type__c, Status__c, CASS_Number__c, Check_Digit__c, Location_Class__c,
                (SELECT Id, Update_Type__c, Change_Code__c, Account__c, Status__c, Agency_Applied_Change_code__r.Integration_RecId__c FROM AMS_Agency_Updates__r WHERE Integration_System__c = 'SAP PI' ), 
                (SELECT Account__c, Account__r.IATACode__c, Active__c, Change_Code__c, For_Integration__c, Integration_RecId__c FROM Agencies_Applied_Change_codes__r WHERE Change_Code__c != null AND For_Integration__c = true)
                FROM Account WHERE id IN: agencyIds];


        //Checks for for the accounts passed on the trigger, to see if existing records with status different from "Update_Sent", already exist for those accounts
        //if they exist these accounts are marked to be removed from the list to create agecu update records
        Set<Id> agenciesAlreadyUpdated = new Set<Id>();
        Set<Id> agenciesUpdateNotToCreate = new Set<Id>();
        Set<Id> setToRemoveAgencyUpdate = new Set<Id>();
        Set<Id> agenciesValidateError = new Set<Id>();
        Set<Id> agenciesInvalid = new Set<Id>();
        List<Technical_Logs__c> tlogList = new List<Technical_Logs__c>();
        
        for(Account au : aulist){
            Boolean bAlreadyUpdated = false;
            Boolean bToReEvaluateUpdate = false;
            AMS_Agency_Updates__c agencyUpdateToReEvaluate;

            for(AMS_Agency_Updates__c au2: au.AMS_Agency_Updates__r){

                if(!bToReEvaluateUpdate && au2.Update_Type__c.equalsIgnoreCase('Update')){
                    bToReEvaluateUpdate = true;
                    agencyUpdateToReEvaluate = au2;
                    reEvaluateAgencyUpdate.add(au2);
                }
                if(!bAlreadyUpdated && !au2.Update_Type__c.equalsIgnoreCase('Update_Sent') && !au2.Update_Type__c.equalsIgnoreCase('Invalid') && !au2.Update_Type__c.equalsIgnoreCase('Deleted')){
                    bAlreadyUpdated = true;
                    agenciesAlreadyUpdated.add(au.Id);
                }

                if(bAlreadyUpdated && bToReEvaluateUpdate) break;
            }

            Boolean bToValidate;
            Agency_Applied_Change_code__c agApplCC;

            if(au.Agencies_Applied_Change_codes__r.isEmpty()){
                bToValidate = false;
                agApplCC = null;
            } else {
                List<Agency_Applied_Change_code__c> lAuxACC = au.Agencies_Applied_Change_codes__r;
                Agency_Applied_Change_code__c auxACC = new Agency_Applied_Change_code__c();

                for(Agency_Applied_Change_code__c aacc : lAuxACC){
                    if(aacc.For_Integration__c){
                        if(auxACC == null){
                            auxACC = aacc;
                        }else{
                            String sRecIdA = auxACC.Integration_RecId__c == null ? AMS_Utils.getRecIdFromChangeCode( auxACC.Change_Code__c ) : auxACC.Integration_RecId__c;
                            String sRecIdB = aacc.Integration_RecId__c == null ? AMS_Utils.getRecIdFromChangeCode( aacc.Change_Code__c ) : aacc.Integration_RecId__c;

                            //Validates if the RecId for both Change Codes are equal or not
                            if(sRecIdA != sRecIdB){

                                String sRecIdRes = AMS_Utils.getRecIdFromIntegrationMatriz( sRecIdA, sRecIdB );

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
                //Check again, this time against the already existing agecy update record
                if(agencyUpdateToReEvaluate != null){

                    String sRecIdWinner = '';

                    String sRecIdA = agencyUpdateToReEvaluate.Agency_Applied_Change_code__r.Integration_RecId__c == null ? AMS_Utils.getRecIdFromChangeCode( agencyUpdateToReEvaluate.Change_Code__c ) : agencyUpdateToReEvaluate.Agency_Applied_Change_code__r.Integration_RecId__c;
                    String sRecIdB = sRecIdWinner == '' ? (auxACC.Integration_RecId__c == null ? AMS_Utils.getRecIdFromChangeCode( auxACC.Change_Code__c ) : auxACC.Integration_RecId__c) : sRecIdWinner;

                    //Validates if the RecId for both Change Codes are equal or not
                    if(sRecIdA != sRecIdB){

                        String sRecIdRes = sRecIdWinner = AMS_Utils.getRecIdFromIntegrationMatriz( sRecIdA, sRecIdB );

                        //RB 10-11-2017 - If the determined recId is 'D' check the account status, and if not Terminated, force recId = 'C'
                        if(sRecIdRes == 'D' && agencyUpdateToReEvaluate.Status__c != 'Terminated'){
                            sRecIdRes = 'C';
                        }
                        //Check if the agency update record is to delete or not save at all!!
                        if(sRecIdRes == 'F'){
                            //remove entry
                            agencyUpdateToReEvaluate.Update_Type__c = 'Deleted';
                            agencyUpdateToReEvaluate.Change_Code__c = '';
                            if(setToRemoveAgencyUpdate == null || !setToRemoveAgencyUpdate.contains(agencyUpdateToReEvaluate.Account__c) ){
                             
                                toRemoveAgencyUpdate.add(agencyUpdateToReEvaluate);
                                setToRemoveAgencyUpdate.add(agencyUpdateToReEvaluate.Account__c);
                            }
                        
                              //only need to check against "B" value, if "B" wins we change the auxACC to the 2nd change code
                        }else if(sRecIdRes == sRecIdB){
                            agencyUpdateToReEvaluate.Change_Code__c = auxACC.Change_Code__c;
                        }

                    }else{
                        //if both change code are of the same type (ex:"C") we check if the record being tested is the active one, if so that one becomes the one to use
                        agencyUpdateToReEvaluate.Change_Code__c = auxACC.Change_Code__c;
                        
                    }
                }

                bToValidate = true;
                agApplCC = auxACC;
                mAgencyChangeCode.put(au.Id, auxACC); //Storing change code for use later
            }

            Boolean bError = false;
            Boolean bErrorLog = false;
            Boolean bInvalid = false;
            
            String sChangeCode = agApplCC == null ? '' : agApplCC.Change_Code__c;
            String sRecId = agApplCC == null || agApplCC.Integration_RecId__c == null ? AMS_Utils.getRecIdFromChangeCode( sChangeCode ) : agApplCC.Integration_RecId__c;

            String accErrors = '';
            
            //Validates if IATACODE is empty
            //result: on Fail - will create the Agency Update Record in "Invalid" Status and will NOT create a Log entry
            if( String.isEmpty(au.IATACode__c) ){
                bError = true;
                bErrorLog = false;
                bInvalid = true;
            }

            if(bToValidate){
                //Validates if IATACODE is empty and if a Active Change code exists
                //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
                if(String.isEmpty(au.IATACode__c)){
                    accErrors += 'IATACode empty - Agency:' + au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                    bError = true;
                    bErrorLog = true;
                    bInvalid = true;
                }

                //Validates if billing address is empty 
                //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
                if(AMS_Utils.isAddressEmpty(au, 'Billing')){
                    accErrors += '\nBilling address empty - Agency: '+au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                    bError = true;
                    bErrorLog = true;
                    bInvalid = true;
                }

                //Validates Hierarchy (null top parent cannot be sent to SAP except for HO, AO)
                //result: on Fail - will create the Agency Update Record in "Invalid" Status and will NOT create a Log entry
                //Site type EP, AO, SP, AA & HO are all considered as HO in PI. - Jitender
                if(au.Top_Parent__c == null && !AMS_Utils.LocationTypeAllHOTypes.contains(au.Location_Type__c)){
                    accErrors += '\nHO Id empty - Agency: '+au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                    bError = true;
                    bErrorLog = true;     
                    bInvalid = true;          
                }

                //Validates if In case change code created will be sent with C or T (change or terminate) to sap check if the account is in status 
                //      “New application pending” and if yes, do not mark the account for update
                //result: on Fail - will NOT create the Agency Update Record Status and will NOT create a Log entry
                if(au.Status__c != null && au.Status__c.equalsIgnoreCase('New application pending') && sRecId != 'A'){
                    bError = true;
                    bErrorLog = false;
                    bInvalid = false;
                }

                //Validates if CASS number field is not empty for all accounts that are C, R , I=Import, Q=Courier?? (need to check from where these values are)
                //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
                if(String.isEmpty(au.CASS_Number__c) && AMS_Utils.LocationClassCARGO.contains(au.Location_Class__c)){
                    accErrors += '\nCASS Number empty - Agency:' + au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                    bError = true;
                    bErrorLog = true;
                    bInvalid = true;
                }

                //Validates if Check that check digit is not empty
                //result: on Fail - will create the Agency Update Record in "Invalid" Status and will create a Log entry
                if(String.isEmpty(au.Check_Digit__c)){
                    accErrors += '\nCheck Digit empty - Agency:' + au.Name+' ('+au.IATACode__c+'-'+au.id+'): Active Change Code - ' + sChangeCode ;
                    bError = true;
                    bErrorLog = true;
                    bInvalid = true;
                }
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
                tlogList.add(tlog);   
            }
        }

        try {
            insert tlogList;
        }catch (Exception ex) {
                System.debug('____ [AMS_AgencyUpdateHelper - agencyUpdate] Log writing error: ' + ex.getMessage());
        }

        //remove agencies that already have an agency update record
        agencyIds.removeAll(agenciesAlreadyUpdated);
        //remove agencies that have 2 Change codes that cancel each other (ex: an "A" and a "D")
        agencyIds.removeAll(agenciesUpdateNotToCreate);
        agencyIds.removeAll(setToRemoveAgencyUpdate);
        //remove agencies that had Shipping validation errors 
        agencyIds.removeAll(agenciesValidateError);
        //remove agencies that have been updated on integration with SAP 
        agencyIds.removeAll(accSentToExternalSystemFlag);

        

        //create the Agency Update records - with "Update" status
        for(Id toCreate : agencyIds){
            
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
            if( !setToRemoveAgencyUpdate.contains(toUpdate.Account__c) && !agenciesValidateError.contains( toUpdate.Account__c ) ){    
                agencyUpdateToUpdate.add(toUpdate);
            }
        }

        agencyUpdateToUpdate.addAll(toRemoveAgencyUpdate);

        System.debug('____ [AMS_AgencyUpdateHelper - agencyUpdate] agencyUpdateToInsert: ' + agencyUpdateToInsert);
        System.debug('____ [AMS_AgencyUpdateHelper - agencyUpdate] invalidAgencyUpdateToInsert: ' + invalidAgencyUpdateToInsert);
        System.debug('____ [AMS_AgencyUpdateHelper - agencyUpdate] agencyUpdateToUpdate: ' + agencyUpdateToUpdate);

        if(agencyUpdateToInsert.size() > 0)
            insert agencyUpdateToInsert;

        if(invalidAgencyUpdateToInsert.size() > 0)
            insert invalidAgencyUpdateToInsert;    


        if(agencyUpdateToUpdate.size() > 0) update agencyUpdateToUpdate;  

        return;
    }

    public static void accountUpdate(List<AMS_Agency_Updates__c> sentUpdates) {   
        Set<Account> setIntegratedAccounts = new Set<Account>();
        List<Account> integratedAccountsNoDuplicates = new List<Account>();
        for(AMS_Agency_Updates__c updatedAgency : sentUpdates){
            setIntegratedAccounts.add(new Account(Id = updatedAgency.Account__c, Sent_to_External_System__c = true, Last_Integration_Date__c = datetime.now()));
        }

        //we can't add the accounts directly in the list to avoid duplicates
        //needs to be in a list since we can't use set in dml operations
        integratedAccountsNoDuplicates.addAll(setIntegratedAccounts);

        update integratedAccountsNoDuplicates;
    }
    
}