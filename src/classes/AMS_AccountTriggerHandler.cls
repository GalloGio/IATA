public class AMS_AccountTriggerHandler {
    
    public static Set<String> minorChangesAccountFields = new Set<String> {
                'phone',
                'fax',
                'email__c',
                'website',
                'mobile__c',
                'shippingaddress',
                'manager_first_name__c',
                'manager_last_name__c',
                'tradename__c',
                'shippingstreet',
                'shippingcity',
                'shippingcountry',
                'shippingstate',
                'shippingpostalcode',
                'VAT_number__c',
                'VAT_number_2__c'
            };

    public static boolean processMinorChangesValidationFlag = true;

    public static Integer runningVCU = 0;

    public static void handleBeforeInsert(List<Account> accs){
        Set<String> disallowedSources = new Set<String>();
        disallowedSources.add('AIMS1');
        disallowedSources.add('AIMS2');
        disallowedSources.add('AIMS3');
        disallowedSources.add('WebStar');
        disallowedSources.add('DataLoader');
        for(Account ag : accs){
	if(!disallowedSources.contains(ag.Source_System__c))
       	{
		if(ag.Sector__c == AMS_Utils.SECTOR_PASSENGER || ag.Sector__c == AMS_Utils.SECTOR_CARGO){

			setCassNumberOnHO(ag);

                    if(ag.Cass_Number__c!=null && ag.Cass_number__c.isNumeric()){
                        ag.Cass_Number__c = AMS_AgencyHelper.resizeNumericString(ag.Cass_Number__c,3);
                    }
                }
            }
        }
    }

    public static void handleAfterInsert(List<Account> accs){
        //Operations assignment update:
        //we want to set all operation to a dedicated Operation based on their Countries
        List<Account> operationHelpercandidate = new List<Account>();

        for(Account ag: accs){
            if(ag.Sector__c == 'Travel Agent' || ag.Sector__c == 'Cargo Agent'){
                if(ag.IATA_ISO_Country__c!=null && ag.IATACode__c !=null ){
                    system.debug('[AMS_AgencyTrigger] updated Primary Address for Agency '+ag.Id);
                    operationHelpercandidate.add(ag);
                }
            }
        }

        if(operationHelpercandidate != null && operationHelpercandidate.size()>0){
            system.debug('[AMS_AgencyTrigger] updating Operation for '+operationHelpercandidate.size()+' Agencies');
            AMS_AgencyHelper.updateAgenciesOperations(operationHelpercandidate);
        }     
    }

    public static void handleBeforeUpdate(List<Account> accs, Map<Id,Account> oldMap){
        //resizeNumericString
        for(Account  ag: accs){
            if(ag.Sector__c == AMS_Utils.SECTOR_PASSENGER || ag.Sector__c == AMS_Utils.SECTOR_CARGO){
                
                if(ag.Cass_Number__c!=null && ag.Cass_number__c.isNumeric() && oldMap.get(ag.Id).Cass_number__c!=ag.Cass_number__c){
                    ag.Cass_Number__c = AMS_AgencyHelper.resizeNumericString(ag.Cass_Number__c,3);
                }
            }
        }

       System.debug('Start CASS verification');
       verifyCassNumberUniqueness(accs,oldMap);
       System.debug('End CASS verification');

       if(processMinorChangesValidationFlag){
            System.debug('Handling minor changes');
            processMinorChangesValidationFlag = false;
            handleManualMinorChanges(accs,oldMap);
       }else{
            System.debug('Not Handling minor changes');
       }

    }

    public static void handleAfterUpdate(List<Account> accs, Map<Id,Account> oldMap){
        
        handleAgenciesOperations(accs,oldMap);

    }

    public static void handleAgenciesOperations(List<Account> accs, Map<Id,Account> oldMap){

        //Operations assignment update:
        //we want to set all operation to a dedicated Operation based on their Countries
        List<Account> operationHelpercandidate = new List<Account>();
        List<Account> agencies = new List<Account>();
        /*
            //cannot be working on creation because need to have a primary address linked
        */

        for(Account ag:accs){
            if(ag.Sector__c == 'Travel Agent' || ag.Sector__c == 'Cargo Agent')
            {
                if(verifyFieldChanges(ag, oldMap.get(ag.Id)))    
                {
                    agencies.add(ag);
                }
                //consider agency with iata code with NEW primary Address  OR agencies with Address with new iata code
                if((ag.IATA_ISO_Country__c!= oldMap.get(ag.Id).IATA_ISO_Country__c && ag.IATACode__c!=null) || (ag.IATA_ISO_Country__c!=null && ag.IATACode__c!=null && oldMap.get(ag.Id).IATACode__c != ag.IATACode__c)){
                    system.debug('[AMS_AgencyTrigger] updated Primary Address for Agency '+ag.Id);
                    operationHelpercandidate.add(ag);
                }
            }
        }

        //FM - 22-09-2016 - stop creating "agency update" Records
        //if(agencies != null && agencies.size()>0)
        //    AMS_AgencyUpdateHelper.agencyUpdate(agencies);

        if(operationHelpercandidate != null && operationHelpercandidate.size()>0){
            system.debug('[AMS_AgencyTrigger] updating Operation for '+operationHelpercandidate.size()+' Agencies');
            AMS_AgencyHelper.updateAgenciesOperations(operationHelpercandidate);
        }


    }

    public static void handleManualMinorChanges(List<Account> accs, Map<Id,Account> oldMap){

        accs = filterByAgencyRecordType(accs);

        Map<String, Schema.SObjectField> accountFields = AMS_Utils.getObjectFields('Account');

        List<AccountChangesStruct> accountChangesList = new List<AccountChangesStruct>();
        
        //LF: enable minor changes only if the ISO Country has the flag OSCAR_enabled__c enabled
        Set<Id> countries = new Set<Id>();
        Map<Id, boolean> countryIdToMinorChangeEnabled = new Map<Id,boolean>();
        for(Account acct : accs)
            if(acct.IATA_ISO_Country__c!=null)
                countries.add(acct.IATA_ISO_Country__c);
        if(countries.size()>0)
            for(IATA_ISO_Country__c iic : [SELECT Name, OSCAR_enabled__c FROM IATA_ISO_Country__c WHERE ID IN :countries])
                countryIdToMinorChangeEnabled.put(iic.Id, iic.OSCAR_enabled__c);
        //LF: end change
        
        
        for(Account acct : accs){
            
            //LF: enable minor changes only if the ISO Country has the flag OSCAR_enabled__c enabled
            if(countryIdToMinorChangeEnabled.get(acct.IATA_ISO_Country__c)!=true)
                continue;
            //LF: end change
        

            List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges = new List<AMS_RecordCreatorWebservice.AccountChanges>();

            for (String fieldName : accountFields.keySet()) {
                
                String fieldToSearch = String.valueOf(fieldName);

                if(minorChangesAccountFields.contains(fieldToSearch.toLowerCase())){

                        if(acct.get(fieldName) <> oldMap.get(acct.Id).get(fieldName)){

                            System.debug('Account being changed for the field ' + fieldName + ' so lets create AACC.');

                            String accountFieldName = fieldName;
                            String accountNewValue = String.valueOf(acct.get(fieldName));
                            String accountOldValue = String.valueOf(oldMap.get(acct.Id).get(fieldName));

                            AMS_RecordCreatorWebservice.AccountChanges acctChange = new AMS_RecordCreatorWebservice.AccountChanges(accountFieldName,accountNewValue,accountOldValue);

                            accountChanges.add(acctChange);
                        }

                }
            }

            AccountChangesStruct struct = new AccountChangesStruct(accountChanges,acct);
            accountChangesList.add(struct);
        }

         if(!accountChangesList.isEmpty()){
                System.debug('Number of accounts to be created AACC:' + accountChangesList.size());
                createMinorChangesChangeCode(accountChangesList);
         }

    }

    private static List<Account> filterByAgencyRecordType(List<Account> accts){

        ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;

        List<Account> toReturn = new List<Account>();

        for(Account acct: accts){

            if(acct.recordTypeId == standardRT)
                toReturn.add(acct);

        }


        return toReturn;
    }


    private static void createMinorChangesChangeCode(List<AccountChangesStruct> accountChanges){

        // get the Account and creates a change code (Agency_Applied_Change_code__c)
        // Notify the Agent via email using predefined email template
        Boolean processedTN = false;

        List<Account> accountsToProcess = new List<Account>();
        List<AMS_OSCAR_JSON.ChangeCode> changeCodesToProcess = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<AMS_OSCAR__c> oscarsToProcess = new List<AMS_OSCAR__c>();

        for(AccountChangesStruct actChange: accountChanges){
            
            processedTN = false;

            AMS_OSCAR_JSON.ChangeCode changeCodeTN = null;
            AMS_OSCAR_JSON.ChangeCode changeCode = null;

            Account account = actChange.acct;


            if(AMS_RecordCreatorWebservice.containsTradeName(actChange.changes)){

                changeCodeTN = AMS_RecordCreatorWebservice.generateChangeCodeTN(null, account.Status__c == 'Approved' );

                accountsToProcess.add(account);
                changeCodesToProcess.add(changeCodeTN);
                oscarsToProcess.add(null);

                processedTN = true;
            }


            if(actChange.changes.size() > 1 ||  ( actChange.changes.size() == 1 && !processedTN)){

                changeCode = AMS_RecordCreatorWebservice.generateChangeCode(null);
            
                accountsToProcess.add(account);
                changeCodesToProcess.add(changeCode);
                oscarsToProcess.add(null);
            }

        }

        AMS_Utils.createAAChangeCodes(changeCodesToProcess, oscarsToProcess, accountsToProcess,false);

    }

    public class AccountChangesStruct {

        private List<AMS_RecordCreatorWebservice.AccountChanges> changes{get;set;}
        private Account acct{get;set;}

        public AccountChangesStruct(List<AMS_RecordCreatorWebservice.AccountChanges> changes, Account acct){

            this.changes = changes;
            this.acct = acct;

        }

    }

    public static void setCassNumberOnHO(Account ag){
        if(ag.Sector__c == 'Cargo Agent'  && ag.Location_Type__c=='HO' && ag.CASS_Number__c==null){
            ag.CASS_Number__c ='000';
        }
    }

    private static void verifyCassNumberUniqueness(List<Account> accs, Map<Id,Account> oldMap){

        // When editing cass number, this is a validation to check if the new cass number already exist or not in the hierarchy.
        // We should not save a cass number that already exist in the hierarchy cause in this case we can have duplicated 
        // iata code and iata code need to be unique.

        //let's divide the Accounts between hierarchies, but only for those of have a change of cass number

        System.debug('Entering verifyCassNumberUniqueness run number ' + runningVCU++);

        Map<Id,Account> accountsSet = new Map<Id,Account>();
 
        for(Account  ag: accs){
            if(ag.Cass_Number__c !=null && oldMap.get(ag.Id).Cass_number__c != ag.Cass_number__c){

                System.debug('Agency with Id ' + ag.Id + ' and Name ' + ag.Name + ' has changed its cass number from ' + oldMap.get(ag.Id).Cass_number__c + ' to ' + ag.Cass_number__c);
                
                accountsSet.put(ag.Id,ag);
            }
        }

        if(accountsSet.isEmpty())
            return;

        Map<Id, List<Account>> hierarchiesPerAccount = new Map<Id, List<Account>>();

        List<AMS_Agencies_relationhip__c> relationshipLst = [SELECT Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__c in :accountsSet.keySet()];
        
        Set<Id> relationshipSet = new Set<Id>();

        for(AMS_Agencies_relationhip__c rel : relationshipLst){
            relationshipSet.add(rel.Hierarchy__c);
        }

        relationshipLst = [SELECT Hierarchy__c, Child_Account__c, Child_Account__r.Cass_Number__c, Child_Account__r.Name from AMS_Agencies_relationhip__c where Hierarchy__c in :relationshipSet];
        

        for(AMS_Agencies_relationhip__c rel: relationshipLst){

            if(!hierarchiesPerAccount.containsKey(rel.Hierarchy__c)){
                
                List<Account> accts = new List<Account>();
                
                if(accountsSet.containsKey(rel.Child_Account__c))
                    accts.add(accountsSet.get(rel.Child_Account__c));
                else
                    accts.add(rel.Child_Account__r);
                
                hierarchiesPerAccount.put(rel.Hierarchy__c, accts);

            }else{

                List<Account> accts = hierarchiesPerAccount.get(rel.Hierarchy__c);
                
                if(accountsSet.containsKey(rel.Child_Account__c))
                    accts.add(accountsSet.get(rel.Child_Account__c));
                else
                    accts.add(rel.Child_Account__r);

                hierarchiesPerAccount.put(rel.Hierarchy__c, accts);
            }

        }


        for(Id hierarchy : hierarchiesPerAccount.keySet()){

            String debubStr = 'The hierarchy with id ' + hierarchy + ' has the following accounts: ';

            List<Account> accounts = hierarchiesPerAccount.get(hierarchy);

            for(Account act: accounts){
                debubStr += ' ' + act.Id + '('+act.Cass_Number__c+'); '; 
            }

            System.debug(debubStr);

        }


        // now we should have a complete structure with the Hierarchies and Accounts, so Let's see if there is any repetitions

        for(Id hierarchy : hierarchiesPerAccount.keySet()){

            Set<String> cassNumbers = new Set<String>();
            
            List<Account> accounts = hierarchiesPerAccount.get(hierarchy);

            // we want to validate just the accounts that were changed
            For(Account acct: accounts){

                if(!accountsSet.containsKey(acct.Id))
                    continue; //skipp because this wasn't changed ...

                if(acct.Cass_Number__c != null){

                    //let's find out if there is another Account in this set with that Cass number

                    for(Account account: accounts){
                        if(account.Id <> acct.Id){ // don't want to compare an account to itself
                            if(acct.Cass_Number__c == account.Cass_Number__c){
                                System.debug('The hierarchy ' + hierarchy + ' already has an agency with that cass number ('+acct.Cass_Number__c+').');
                                acct.addError('The hierarchy ' + hierarchy + ' already has an agency with that cass number ('+acct.Cass_Number__c+').');
                            }
                        }
                    }
                }
            }
        }

    }
    
    
	
    /** This method is called to verify if the Account field changes should create a new record into AMS Agency Updates table. The scenarios are:
     *  1) Status__c changes => Create a new record
     *  2) Status__c DOES NOT change && another field value changes => Create a new record
     *  3) All fields remain the same => No records are created
     *     Scenario no. 3 sounds stupid, but it can happen, because Dataloader pushes data into Accounts, causing the triggers to run, and this class
     *     previously was always firing AMS_AgencyUpdateHelper.agencyUpdate(agencies). The result was unintentional records to getting created.
     */
    public static boolean verifyFieldChanges(Account newRecord, Account oldRecord)
    {
        Set<String> ignoredFields = new Set<String>{'LastModifiedById', 'LastModifiedDate', 'SystemModstamp'};
        Map <String, Schema.SObjectField> AccountFieldsMap = schema.SObjectType.Account.fields.getMap();
        List <Schema.SObjectField> accountFields = accountFieldsMap.values();
        List <String> accountAPIFieldNames = new List<String>();
        for (Schema.SObjectField field : accountFields)
        {
            accountAPIFieldNames.add(field.getDescribe().getName());
        }
        
        boolean valueChanged = false;

        for(String field : accountAPIFieldNames)
        {
            System.debug('*************** field: '+field);
            
            if(!ignoredFields.contains(field))
            {
                if(newRecord.get(field) != oldRecord.get(field))
                {
                    System.debug('*************** field that CHANGED: '+field);
                    valueChanged = true;
                }
            }
        }
        if(valueChanged)
        {
            return true;
        }
        return false;
    }
}