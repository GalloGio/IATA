public class AMS_AccountTriggerHandler {

    public static Set<String> minorChangesAccountFields = new Set<String> {
                'phone',
                'fax',
                'email__c',
                'website',
                'mobile__c',
                'manager_first_name__c',
                'manager_last_name__c',
                'tradename__c',
                'solicitation_flag__c',
                'location_category__c'
                
            };
    public static Set<String> minorchangesRestrictedForCNS = new Set<String>{'tradename__c'};

    public static boolean processMinorChangesValidationFlag = true;
    public static boolean minorChangesComingFromOSCAR = false;
    public static boolean comingFromOSCARforRemoveTradeName = false;

    public static Integer runningVCU = 0;

    public static void handleBeforeInsert(List<Account> accs){
    	System.debug('[AMS_AccountTriggerHandler] Before Insert');
        Set<String> disallowedSources = new Set<String>();
        disallowedSources.add('AIMS1');
        disallowedSources.add('AIMS2');
        disallowedSources.add('AIMS3');
        disallowedSources.add('WebStar');
        disallowedSources.add('DataLoader');
        
        List<Id> parentIds = new List<Id>();
        for(Account ac: accs){
        	if((ac.Location_Type__c == 'AE' || ac.Location_Type__c == 'HE') && (ac.Location_Class__c == 'P' || ac.Location_Class__c == 'D'))
        		parentIds.add(ac.ParentId);
        }
        
        //since ParentId is a hierarchy field and not a lookup, we need a Id -> Account map
        List<Account> aList = [select id, name, Top_Parent__c, ParentId, Location_Type__c, Location_Class__c, IATA_ISO_Country__c, IATA_ISO_Country__r.AMS_Settlement_System__c, IATA_ISO_Country__r.name, ANG_IsNewGenAgency__c from account where (Id in :parentIds OR ParentId in :parentIds) AND ANG_IsNewGenAgency__c = true AND (Top_Parent__r.Location_Type__c = 'GE' OR Location_Type__c = 'GE')];
        
        Map<Id,Account> aAccounts = new Map<Id,Account>();
        for(Account pa : aList)
        	aAccounts.put(pa.Id, pa);

		//Mapping MC hierarchy subtrees. Parent Account -> direct children accounts
		Map<Id,List<Account>> accMap = new Map<Id,List<Account>>();
        accMap = accountMapBuild(aList);
        
        for(Account ag : accs){
            validateCharacters(ag);//AMSU-179
	    System.debug('[AMS_AccountTriggerHandler]ag: ' + ag);
            if(!disallowedSources.contains(ag.Source_System__c)){
                if(ag.Sector__c == AMS_Utils.SECTOR_PASSENGER || ag.Sector__c == AMS_Utils.SECTOR_CARGO){
                    setCassNumberOnHO(ag);

                    if(ag.Cass_Number__c!=null && ag.Cass_number__c.isNumeric()){
                        ag.Cass_Number__c = AMS_AgencyHelper.resizeNumericString(ag.Cass_Number__c,3);
                    }
                }
            }
            
            //NEWGEN-4815
            System.debug('[AMS_AccountTriggerHandler] if(accMap.containsKey(ag.ParentId)): '+ accMap.containsKey(ag.ParentId));
            if(accMap.containsKey(ag.ParentId)){    
            	System.debug('[AMS_AccountTriggerHandler] ag.Location_Type__c =  ' + ag.Location_Type__c);
            	
            	//SENAIO 1
            	if(ag.Location_Type__c == 'HE'){
            		
            		if(aAccounts.get(ag.parentId).Location_Type__c != 'GE')
            			ag.addError('HE Accounts must have a GE Parent Account');
            		
            		for(Account brotherAccount1: accMap.get(ag.ParentId)){
            		
            			if(brotherAccount1.Id != null && (brotherAccount1.IATA_ISO_Country__r.AMS_Settlement_System__c == ag.IATA_ISO_Country__r.AMS_Settlement_System__c))
            				ag.addError('The BSP is already in the multicountry hierarchy, the new agency can only be an AE in that BSP');
            		}
            	}
            	//SENARIO 2
            	else if(ag.Location_Type__c == 'AE'){
            		System.debug('[AMS_AccountTriggerHandler] Is inside else');
            		
					//restrictions caused by the parent account
            		if(aAccounts.get(ag.parentId).Location_Type__c == 'AE')
            			ag.addError('AE Accounts must have a GE or HE Parent Account');
            		
            		else if(aAccounts.get(ag.parentId).IATA_ISO_Country__r.AMS_Settlement_System__c != ag.IATA_ISO_Country__r.AMS_Settlement_System__c)
            			ag.addError('The BSP is not in the multicountry hierarchy yet, the new agency can only be an HE in that BSP');
            		
            		//restriction caused by simbing accounts
            		for(Account brotherAccount2: accMap.get(ag.ParentId)){
            			
            			if(((brotherAccount2.IATA_ISO_Country__r.AMS_Settlement_System__c == ag.IATA_ISO_Country__r.AMS_Settlement_System__c && brotherAccount2.Location_Type__c == 'HE') || ag.IATA_ISO_Country__r.AMS_Settlement_System__c != aAccounts.get(ag.parentId).IATA_ISO_Country__r.AMS_Settlement_System__c) && brotherAccount2.Id != null)
            				ag.addError('The BSP is not in the multicountry hierarchy yet, the new agency can only be an HE in that BSP');
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
            validateCharacters(ag);//AMSU-179
            if(ag.Sector__c == AMS_Utils.SECTOR_PASSENGER || ag.Sector__c == AMS_Utils.SECTOR_CARGO){
                
                if(ag.Cass_Number__c!=null && ag.Cass_number__c.isNumeric() && oldMap.get(ag.Id).Cass_number__c!=ag.Cass_number__c){
                    ag.Cass_Number__c = AMS_AgencyHelper.resizeNumericString(ag.Cass_Number__c,3);
                }
            }
            if(ag.Status__c!= null && ag.Status__c!=oldMap.get(ag.Id).Status__c)
                ag.Date_Organisation_Status_attained__c = Date.today();
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

       AMS_Utils.startIntegration(accs,oldMap);

    }

    public static void handleAfterUpdate(List<Account> accs, Map<Id,Account> oldMap){
        
        handleAgenciesOperations(accs,oldMap);
        handleDDUpdates(accs, oldMap);
        // copy information to related regulation objects if Is_your_firm_handling_Dangerous_Goods__c changed
        copyHandlingInformationToRegulations(accs, oldMap);

    }

    public static void validateCharacters(Account acc) {
        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        if(acc.RecordTypeId == agencyRT) {
            List<String> errors = AMS_Utils.validateCharacters(acc, AMS_Utils.ACCOUNT_FIELDS_TO_VALIDATE);
            if(!errors.isEmpty()) {
                String error = String.join(errors, '\r\n');
                acc.addError(error);
            }
        }
    }

    public static void handleAgenciesOperations(List<Account> accs, Map<Id,Account> oldMap){

        //Operations assignment update:
        //we want to set all operation to a dedicated Operation based on their Countries
        List<Account> operationHelpercandidate = new List<Account>();
        //List<Account> agencies = new List<Account>();
        /*
            //cannot be working on creation because need to have a primary address linked
        */

        for(Account ag:accs){
            if(ag.Sector__c == 'Travel Agent' || ag.Sector__c == 'Cargo Agent')
            {
                // DNG - This is not used anymore since that agencies object is not used ...
                /*
                if(verifyFieldChanges(ag, oldMap.get(ag.Id)))    
                {
                    agencies.add(ag);
                }
                */
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

        accs = filterValidAgencies(accs);

        Map<String, Schema.SObjectField> accountFields = AMS_Utils.getObjectFields('Account');

        List<AccountChangesStruct> accountChangesList = new List<AccountChangesStruct>();
 
        Map<String, Schema.SobjectField> accountDescription =Account.getSObjectType().getDescribe().fields.getMap();
        for(Account acct : accs){
            //LF: enable minor changes only if the ISO Country has the flag OSCAR_enabled__c enabled
            if(!acct.Country_OSCAR_Enabled__c) continue;
            //LF: end change
        

            List<AMS_RecordCreatorWebservice.AccountChanges> accountChanges = new List<AMS_RecordCreatorWebservice.AccountChanges>();

            for (String fieldName : accountFields.keySet()) {
                
                String fieldToSearch = String.valueOf(fieldName);

                if(minorChangesAccountFields.contains(fieldToSearch.toLowerCase())){

                        if(acct.get(fieldName) <> oldMap.get(acct.Id).get(fieldName)){
                            if(acct.CNS_Agency__c == true && !minorChangesComingFromOSCAR && minorchangesRestrictedForCNS.contains(fieldName)){
                                acct.addError('Change of '+accountDescription.get(fieldName).getDescribe().getLabel()+' is not allowed for CNS agencies directly on account level: a new  OSCAR is required to modify this information.');
                                
                                continue;
                            }

                            System.debug('Account being changed for the field ' + fieldName + ' so lets create AACC.');

                            String accountFieldName = fieldName;
                            String accountNewValue = String.valueOf(acct.get(fieldName));
                            String accountOldValue = String.valueOf(oldMap.get(acct.Id).get(fieldName));

                            AMS_RecordCreatorWebservice.AccountChanges acctChange = new AMS_RecordCreatorWebservice.AccountChanges(accountFieldName,accountOldValue,accountNewValue);

                            accountChanges.add(acctChange);
                        }

                }
            }

            AccountChangesStruct struct = new AccountChangesStruct(accountChanges,acct);
            if(acct.Source_System__c == null || String.isBlank(acct.Source_System__c) || acct.Source_System__c.toUpperCase() != 'WEBSTAR') {
            accountChangesList.add(struct);
            }
        }

         if(!accountChangesList.isEmpty()){
                System.debug('Number of accounts to be created AACC:' + accountChangesList.size());
                createMinorChangesChangeCode(accountChangesList);
         }

    }

    private static List<Account> filterValidAgencies(List<Account> accts){

        ID standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;

        List<Account> toReturn = new List<Account>();

        for(Account acct: accts){

            //only accredited agencies can generate minor change codes
            if(acct.recordTypeId == standardRT && acct.Accreditation_date__c != null)
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
		
		map<id, list<Agency_Applied_Change_code__c>> mapAccntCC = new map<id, list<Agency_Applied_Change_code__c>>();
        set<id> setAccntId = new set<id>();
        for(AccountChangesStruct actChange: accountChanges)
        	setAccntId.add(actChange.acct.Id);
		
		for(Agency_Applied_Change_code__c aacc: [SELECT Reason_Code__c, Reason_Description__c, Account__c FROM Agency_Applied_Change_code__c WHERE Account__c in :setAccntId AND Active__c = TRUE]){
			if(mapAccntCC.containsKey(aacc.Account__c))
				mapAccntCC.get(aacc.Account__c).add(aacc);
			else
				mapAccntCC.put(aacc.Account__c, new Agency_Applied_Change_code__c[]{aacc});
		}
		
        for(AccountChangesStruct actChange: accountChanges){
            
            processedTN = false;

            AMS_OSCAR_JSON.ChangeCode changeCodeTN = null;
            AMS_OSCAR_JSON.ChangeCode changeCode = null;

            Account account = actChange.acct;
            //DTULLO: Dunno who did this below... keep it for the future: NEVER Put a SOQL Query inside a loop!
            //List<Agency_Applied_Change_code__c> accountActiveChangeCode = [SELECT Reason_Code__c, Reason_Description__c FROM Agency_Applied_Change_code__c WHERE Account__c =: account.Id AND Active__c = TRUE];
			List<Agency_Applied_Change_code__c> accountActiveChangeCode = new List<Agency_Applied_Change_code__c>();
			if(mapAccntCC.containsKey(account.Id))
				accountActiveChangeCode = mapAccntCC.get(account.Id);
            system.debug(LoggingLevel.ERROR, 'LF: createMinorChangesChangeCode() check change! Is CNS ? '+actChange.isCNS());

            if(!comingFromOSCARforRemoveTradeName && AMS_RecordCreatorWebservice.containsTradeName(actChange.changes) ){

                changeCodeTN = AMS_RecordCreatorWebservice.generateChangeCodeTN(null, account.Status__c == 'Approved' );

                if(accountActiveChangeCode.size() > 0){
                    changeCodeTN.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
                    changeCodeTN.reasonDesc = accountActiveChangeCode[0].Reason_Description__c;
                }

                accountsToProcess.add(account);
                changeCodesToProcess.add(changeCodeTN);
                oscarsToProcess.add(null);

                processedTN = true;

            } 


            if(!comingFromOSCARforRemoveTradeName && (actChange.changes.size() > 1 ||  ( actChange.changes.size() == 1 && !processedTN))){

                changeCode = AMS_RecordCreatorWebservice.generateChangeCode(null);
            
                if(accountActiveChangeCode.size() > 0){
                    changeCode.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
                    changeCode.reasonDesc = accountActiveChangeCode[0].Reason_Description__c;
                }

                accountsToProcess.add(account);
                changeCodesToProcess.add(changeCode);
                oscarsToProcess.add(null);
            }

        }

        List<AMS_ChangeCodesHelper.ObjectChangesStruct> objectChanges = AMS_ChangeCodesHelper.convertAccountToObjectChanges(accountChanges);


        AMS_ChangeCodesHelper.createAAChangeCodes( objectChanges, changeCodesToProcess, oscarsToProcess, accountsToProcess,false);

    }

    public class AccountChangesStruct {

        public List<AMS_RecordCreatorWebservice.AccountChanges> changes{get;set;}
        public Account acct{get;set;}

        public AccountChangesStruct(List<AMS_RecordCreatorWebservice.AccountChanges> changes, Account acct){

            this.changes = changes;
            this.acct = acct;

        }

        public boolean isCNS(){
            return acct.CNS_Agency__c == true;
        }

    }

    public static void setCassNumberOnHO(Account ag){
        if(ag.Sector__c == 'Cargo Agent'  && ag.Location_Type__c=='HO' && ag.CASS_Number__c==null){
            // Salvatore don't hate me for this if==true, but it may be null!
            if(ag.CNS_Country__c == true)
                ag.CASS_Number__c ='001';
            else
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

        List<AMS_Agencies_relationhip__c> relationshipLst = new List<AMS_Agencies_relationhip__c>();

        for(AMS_Agencies_Hierarchy__c h : [SELECT Id, (SELECT Hierarchy__c, Child_Account__c, Child_Account__r.Cass_Number__c, Child_Account__r.Name from AMS_Agencies_relationships__r) FROM AMS_Agencies_Hierarchy__c WHERE Id In (SELECT Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__c in :accountsSet.keySet())]) 
            relationshipLst.addAll(h.AMS_Agencies_relationships__r);
        

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

    //This method applies the Due Diligence status from the account on all open Oscars
    public static void handleDDUpdates(List<Account> accs, Map<Id,Account> oldMap){

        Set<Id> accountsToCheck = new Set<Id>();
        accountsToCheck.add(RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'));
        accountsToCheck.add(RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'));


        Set<String> closedStatus = new Set<String>{
            'Closed', 'Closed_Not Accepted', 'Closed_Rejected', 'Closed_Withdrawn'
        };

        Map<String, String> ddStatus = new Map<String, String>{
            'Cleared' => 'Passed',
            'Sanctioned. Please contact compliance' => 'Failed'
        };

        Map<Id,Account> ddAccounts = new Map<Id,Account>();
        for(Account acc : accs){
            if(acc.Due_Diligence_Status__c != oldMap.get(acc.Id).Due_Diligence_Status__c
                && ddStatus.containsKey(acc.Due_Diligence_Status__c)
                && accountsToCheck.contains(acc.RecordTypeId)){

                ddAccounts.put(acc.Id, acc);
            }
        }

        if(ddAccounts.isEmpty()) return;

        System.debug(loggingLevel.FINE, '____ [cls AMS_AccountTriggerHandler - handleDDUpdates] ddAccounts - ' + ddAccounts.keySet());

        List<AMS_OSCAR__c> oscars = [SELECT Id, Account__c  FROM AMS_OSCAR__c WHERE Account__c IN :ddAccounts.keySet() AND Status__c NOT IN :closedStatus];
        for(AMS_OSCAR__c oscar : oscars){
            Account acc = ddAccounts.get(oscar.Account__c);

            oscar.STEP17__c = ddStatus.get(acc.Due_Diligence_Status__c);
        }

        if(!oscars.isEmpty()) update oscars;
    }

    private static void copyHandlingInformationToRegulations(List<Account> newAccs, Map<Id,Account> oldMapAccs){

        Set<Id> changedAccIds = new Set<Id>();
        List<AMS_Agency_Regulation__c> certs;

        for(Account acc :newAccs){

            if((acc.Sector__c == AMS_Utils.SECTOR_CARGO || acc.Sector__c == AMS_Utils.CATEGORY_CASSASSOCIATE) && acc.Is_your_firm_handling_Dangerous_Goods__c != oldMapAccs.get(acc.Id).Is_your_firm_handling_Dangerous_Goods__c){
                changedAccIds.add(acc.Id);
            }
        }

        if(!changedAccIds.isEmpty()){
            certs = new List<AMS_Agency_Regulation__c>();
            for(AMS_Agency_Regulation__c cert :[SELECT id, 	Is_your_firm_handling_Dangerous_Goods__c, Handling_Account__c, Account__r.Is_your_firm_handling_Dangerous_Goods__c FROM AMS_Agency_Regulation__c WHERE Account__c in :changedAccIds]){
                cert.Is_your_firm_handling_Dangerous_Goods__c = cert.Account__r.Is_your_firm_handling_Dangerous_Goods__c;//force run of workflow: AMS 90 days DGR Expiration Reminder - if Is_your_firm_handling_Dangerous_Goods__c == 'Yes'
                certs.add(cert);
            }
        }

        if(certs != null && !certs.isEmpty()){
            update certs;
        }
    }
    
    private static Map<Id,List<Account>> accountMapBuild(List<Account> accList){
    	Map<Id,List<Account>> toReturn = new Map<Id,List<Account>>();
    	List<Account> children;
    	
    	for(Account dad :accList){
    		children = new List<Account>();
    		for(Account child: accList){
    			
    			if(child.ParentId == dad.id)
    				children.add(child);
    		}
    		toReturn.put(dad.Id,children);
    	}
    	 	
    	return toReturn;
    }
}