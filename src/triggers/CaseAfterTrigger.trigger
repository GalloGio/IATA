/*BRIEF DOCUMENTATION ON CASE TRIGGER AFTER THE CASE TRIGGER OPTIMIZATION PROGRAM (Each part refers to a detailed document)
01 - trgCaseIFAP_AfterInsertDeleteUpdateUndelete - ALL: isDelete, isInsert, isUpdate, is Undelete
02 - trgCaseLastSIDRADate - ALL: isInsert, isUpdate
03 - trgCase_ContactLastSurveyUpdate - ALL: isUpdate
04 - trgParentCaseUpdate - ALL: isInsert
05 - trgICCSManageProductAssignment - ALL: Common
06 - trgICCS_ASP_CaseClosed - ALL: Common, isUpdate
07 - trgCreateUpdateServiceRenderedRecord - ALL: Common
08 - trgCaseEscalationMailNotificationICH - ALL: Common
09 - trgCheckSISCaseRecycleBinAfterInsert - ALL: isInsert
11 - CaseBeforInsert - ALL: isInsert
12 - AMS_OSCARCaseTrigger - ALL: isInsert, isUpdate
13 - trgAccelyaRequestSetCountry - ALL: isInsert
14 - trgCase - ALL: isInsert 
*/

trigger CaseAfterTrigger on Case (after delete, after insert, after undelete, after update) {
    /*DEVELOPMENT START/STOP FLAGS*/
    boolean trgCaseIFAP_AfterInsertDeleteUpdateUndelete = true;
	boolean trgCaseLastSIDRADate = true;
	boolean trgCase_ContactLastSurveyUpdate = true;
	boolean trgParentCaseUpdate = true;
	boolean trgICCSManageProductAssignment = true;
	boolean trgICCS_ASP_CaseClosed = true;
	boolean trgCreateUpdateServiceRenderedRecord = true;
	boolean trgCaseEscalationMailNotificationICH = true;
	boolean trgCheckSISCaseRecycleBinAfterInsert = true;
	boolean CaseBeforInsert = true;
	boolean AMS_OSCARCaseTrigger = true;
	boolean trgAccelyaRequestSetCountry = true;
	boolean trgCase = true;
	
	//EM: To be removed
	if (Test.isRunningTest()) {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
	}

	if(!Test.isRunningTest()){
		trgCaseIFAP_AfterInsertDeleteUpdateUndelete = GlobalCaseTrigger__c.getValues('AT trgCaseIFAP_AfterInsertDelete').ON_OFF__c;     //55555555555555
		trgCaseLastSIDRADate = GlobalCaseTrigger__c.getValues('AT trgCaseLastSIDRADate').ON_OFF__c;                                     //55555555555555
		trgCase_ContactLastSurveyUpdate = GlobalCaseTrigger__c.getValues('AT trgCase_ContactLastSurveyUpdate').ON_OFF__c;               //44444444444444
		trgParentCaseUpdate = GlobalCaseTrigger__c.getValues('AT trgParentCaseUpdate').ON_OFF__c;                                       //33333333333333
		trgICCSManageProductAssignment = GlobalCaseTrigger__c.getValues('AT trgICCSManageProductAssignment').ON_OFF__c;                 //55555555555555
		trgICCS_ASP_CaseClosed = GlobalCaseTrigger__c.getValues('AT trgICCS_ASP_CaseClosed').ON_OFF__c;                                 //44444444444444
		trgCreateUpdateServiceRenderedRecord = GlobalCaseTrigger__c.getValues('AT trgCreateUpdateServiceRendered').ON_OFF__c;           //44444444444444
		trgCaseEscalationMailNotificationICH = GlobalCaseTrigger__c.getValues('AT trgCaseEscalationMail').ON_OFF__c;                    //44444444444444
		trgCheckSISCaseRecycleBinAfterInsert = GlobalCaseTrigger__c.getValues('AT trgCheckSISCaseRecycleBin').ON_OFF__c;                //22222222222222
		CaseBeforInsert = GlobalCaseTrigger__c.getValues('AT CaseBeforInsert').ON_OFF__c;                                               //33333333333333
		AMS_OSCARCaseTrigger = GlobalCaseTrigger__c.getValues('AT AMS_OSCARCaseTrigger').ON_OFF__c;                                     //55555555555555
		trgAccelyaRequestSetCountry = GlobalCaseTrigger__c.getValues('AT trgAccelyaRequestSetCountry').ON_OFF__c;                       //33333333333333
		trgCase = GlobalCaseTrigger__c.getValues('AT trgCase').ON_OFF__c;                                                               //33333333333333
	}
    /**********************************************************************************************************************************/
    
    /*Record type*/
    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
	Id sidraRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
	ID FSMcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Security_Monitoring');
	Id RT_ICCS_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Product_Management');
	Id RT_ICCS_BA_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Bank_Account_Management');
	Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management') ;
    Id RT_ICC_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Invoicing_Collection_Cases') ;
    ID RecId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
    Id RT_AirlineSuspension_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Suspension');
	Id RT_AirlineDeactivation_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Deactivation');
	Id RT_FundsManagement_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Funds_Management');
	Id RT_DIP_Review_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DIP_Review_Process');
	ID SISHelpDeskRecordtype = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
	ID CSRcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'BSPlink_Customer_Service_Requests_CSR');
	Id CaseSAAMId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM
    Id OscarComRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
    
/*Record type*/	
    
    /*Variables*/
    Boolean caseRecType = false;
	Boolean isSidraCasesAccountsInit = false; // This variable checks if the sidraCasesAccounts have been already initialized.
    Boolean isIFAPCase = false;
	Integer futureLimit = Limits.getFutureCalls();
	Boolean ThereAreICCSProductManagementCases = false;
	Boolean ThereAreICCSBankAccountManagementCases = false;
	List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
	boolean hasEmail = false;
	Boolean isAccelya = false;
	String CurrUser;
	/*Variables*/
     
    /*Maps, Sets, Lists*/
    set<string> casesIds = new set<string>();
    Set<Id> CaseIdsNew = new Set<Id>();
    Set<Id> accountNotificationIdSet = new Set <Id>(); //TF
    Set<Id> setASCaseIds = new Set<Id>();
	Set<Id> setDIPCaseIds = new Set<Id>();
	Set<Id> sCaseIds = new Set<Id>();
	list<Case> cases = new list<Case>();
	list<Case> ICHcases = new list<Case>();
    list<Case> IFAPcases = new list<Case>(); 
	list<Case> casesToConsider = new list<Case>();
	list<Case> casesWhoClosedCase = new list<Case>();
    list<IFAP_Quality_Issue__c> issues = new list<IFAP_Quality_Issue__c>();
    list<Account> lstAccountsToUpdate = new List<Account>();
    list<String> bspCountryList = new List<String>();
	map<Id,IFAP_Quality_Issue__c> RelatedQualityIssues = new Map<Id,IFAP_Quality_Issue__c>();
	private Map<Id,Account> sidraCasesAccounts;
    private Map<Id,Account> accountsToUpdate = new Map<Id,Account>();

    Set<Id> caseAccsSet = new Set<Id>();
    /*Maps, Sets, Lists*/
    
    /***********************************************************************************************************************************************************/
    /*Share trigger code*/
    /*trgCaseIFAP_AfterInsertDeleteUpdateUndelete Trigger*/
	if(trgCaseIFAP_AfterInsertDeleteUpdateUndelete && !CaseChildHelper.noValidationsOnTrgCAseIFAP){
		if (Trigger.isDelete) 
	    	cases = Trigger.old;
	  	else
	    	cases = Trigger.new;

		for(Case cse : cases) {
			if(cse.RecordTypeId == IFAPcaseRecordTypeID){
				casesToConsider.add(cse);
			} 
		}

		Map<Id, Account> AcctToBeUpdatedPerId = new Map<Id, Account>(); 
		if(!casesToConsider.isEmpty() && (trigger.isUpdate || trigger.isInsert)){
			
			//IFAP P5 start
			Map<Id, List<Case>> casesPerAccount = new Map<Id, List<Case>>();

			//filter IFAP cases with the correct data and aggregate them per account
			for(Case c : casesToConsider){
				Case oldCase = Trigger.isUpdate ? trigger.oldMap.get(c.Id) : null;
				if(c.status == 'Assessment Performed' && c.Financial_Review_Result__c <> null && c.Assessment_Performed_Date__c <> null &&
					(
						trigger.isInsert || 
						(c.Assessment_Performed_Date__c <> oldCase.Assessment_Performed_Date__c || c.Financial_Review_Result__c <> oldCase.Financial_Review_Result__c	|| c.status  <> oldCase.status)
					)
				){
					if(!casesPerAccount.containsKey(c.AccountId)) casesPerAccount.put(c.AccountId, new List<Case>());
					casesPerAccount.get(c.AccountId).add(c);
				}
			}

			if(!casesPerAccount.isEmpty())  {
				// throw new transformationException();

				//NewGen agents will handled by the ANG_CaseTriggerHandler, so we filter them out
				for(Account a : [SELECT Id, Assessment_Performed_Date__c, Financial_Review_Result__c FROM account WHERE Id IN :casesPerAccount.keySet() and ANG_IsNewGenAgency__c = true]){
					casesPerAccount.remove(a.Id);
				}

				//copy relevant fields to the account and store them to update later
				AcctToBeUpdatedPerId.putAll(IFAP_AfterTrigger.latestDate(casesPerAccount));
			}
		} 
		System.debug('***After checking record type ' + caseRecType);
		if(!casesToConsider.isEmpty()){
			//if(caseRecType)
			System.debug('***Do blah blah blah only for IFAP case related accounts ');
			Set<ID> acctIds = new Set<ID>();
			for (Case cse : casesToConsider) {
			//for (Case cse : cases) 
				acctIds.add(cse.AccountId);
			}

			//START - Too many SOQL fix
			Map<Id,Account> acctsToUpdate = new Map<Id,Account>([select Id,Number_of_open_Financial_Review_Cases__c, (select Id, AccountId from Cases where RecordTypeID =: IFAPcaseRecordTypeID AND (status != 'Closed' and status != 'Assessment Cancelled' and status != 'Closed Opt-out')) from Account where Id in :acctIds]);
			Set<Id> caseIds;

			for (Account acct : acctsToUpdate.values()) {
				caseIds = new Set<Id>();

				for (Case cse :acct.cases){
						caseIds.add(cse.Id);
				}
			//END - Too many SOQL fix

			//START commented - Too many SOQL fix: 
			//Re-open/ed is not considered as Closed Status anymore.
			//Map<ID, Case> casesForAccounts = new Map<ID, Case>([select Id, AccountId from Case where RecordTypeID =: IFAPcaseRecordTypeID AND (status != 'Closed' and status != 'Assessment Cancelled') AND  AccountId in :acctIds]);
			//Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select Id,Number_of_open_Financial_Review_Cases__c from Account where Id in :acctIds]);
			//List<Account> accountUpdated = new List<Account>();
			//for (Account acct : acctsToUpdate.values()) {
			//	Set<ID> caseIds = new Set<ID>();
			//	for (Case cse : casesForAccounts.values()) {
			//		if (cse.AccountId == acct.Id)
			//			caseIds.add(cse.Id);
			//	}
			//END commented - Too many SOQL fix
			
				if (acct.Number_of_open_Financial_Review_Cases__c != caseIds.size()){
					acct.Number_of_open_Financial_Review_Cases__c = caseIds.size();
					if (caseIds.size() > 0){
						acct.Has_Financial_Review_Open_Cases__c = true;
					}else{
						acct.Has_Financial_Review_Open_Cases__c = false;
					}
					if(AcctToBeUpdatedPerId.get(acct.id) == null){
						AcctToBeUpdatedPerId.put(acct.id, acct);
						}else{
						acctToBeUpdatedPerId.get(acct.id).Has_Financial_Review_Open_Cases__c = acct.Has_Financial_Review_Open_Cases__c;
					}
				}
			}
			if(!acctToBeUpdatedPerId.isEmpty() && !acctToBeUpdatedPerId.values().isEmpty()) {
				update acctToBeUpdatedPerId.values();
			}
			//IFAP P5 end  
			//Case child creation if Status = Assessment performed
			CaseChildHelper.CreateChildCase(Trigger.old, Trigger.new);
		}  
	}
	/*trgCaseIFAP_AfterInsertDeleteUpdateUndelete Trigger*/
	
	if(trigger.isInsert || trigger.isUpdate){	
	/*trgICCSManageProductAssignment Trigger*/
	/*@author: Constantin BUZDUGA, blue-infinity
	* @description: This trigger only handles ICCS Cases with the "FDS ICCS Product Management" or "FDS ICCS Bank Account Management" record types
	*    and is used to manage the Product Assignment and ICCS Bank Account objects. Upon case closure, if the case area is "ICCS - Assign Product",
	*    a new PA record is created using the info entered in the case. If a PA already exists but is inactive, it will be reactivated instead of creating a new record.
	*    If the case area is "ICCS - Remove Product", the existing PA record's status field is updated to "Inactive". If the case area is
	*    "ICCS – Update Payment Instructions", the ICCS Bank Account field at PA level is updated with the info entered in the same field
	*    at Case level. If the case area is "ICCS – Delete Bank Account", the Bank Account record's status is set to "Inactive". For the "ICCS – Update Bank Account"
	*    Case Area, the Bank Account currency is updated.*/
		if(trgICCSManageProductAssignment){	
			for (Case c : Trigger.new) {
			    // only interested in cases being closed
			    if ( c.Status == 'Closed' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Status != 'Closed') ) ) {
			    	// This trigger only handles ICCS cases, so we check there is at least one such case
			    	if (c.RecordTypeId == RT_ICCS_Id) {
			        	ThereAreICCSProductManagementCases = true;
			      	}else if (c.RecordTypeId == RT_ICCS_BA_Id) {
			        	ThereAreICCSBankAccountManagementCases = true;
			      	}
			    }
			}
			if (ThereAreICCSBankAccountManagementCases) {
				// List of trigger-related  ICCS Bank Accounts
			    List<Id> lstBankAccountIds = new List<Id>();
			    for (Case c : Trigger.new) {
			    	lstBankAccountIds.add(c.ICCS_Bank_Account__c);
			    }
			    // Create a map of all trigger-related Bank Accounts; Key = Bank Account SF Id
			    Map<Id, ICCS_Bank_Account__c> mapBankAccountsPerId = new Map<Id, ICCS_Bank_Account__c>([SELECT Id, CurrencyIsoCode, Status__c FROM ICCS_Bank_Account__c WHERE Id IN :lstBankAccountIds]);
			    // List of the BAs to be upserted
			    List<ICCS_Bank_Account__c> lstBankAccounts = new List<ICCS_Bank_Account__c>();
			    for (Case c : Trigger.new) {
			    	// Only Cases with the FDS_ICCS_Bank_Account_Management record type
			      	if (c.RecordTypeId == RT_ICCS_BA_Id && c.Status == 'Closed' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Status != 'Closed') )) {
			        	if (c.CaseArea__c == 'ICCS – Delete Bank Account') {
				          	// Inactivate the Bank Account if the case area is 'ICCS – Delete Bank Account'
				          	ICCS_Bank_Account__c ba = mapBankAccountsPerId.get(c.ICCS_Bank_Account__c);
				          	if (ba != null) {
				            	ba.Status__c = 'Inactive';
				            	lstBankAccounts.add(ba);
				          	}
						}else if (c.CaseArea__c == 'ICCS – Update Bank Account') {
				        	// Update the Bank Account currency with the Case Currency if the case area is 'ICCS – Update Bank Account'
				         	ICCS_Bank_Account__c ba = mapBankAccountsPerId.get(c.ICCS_Bank_Account__c);
				          	if (ba != null) {
				            	ba.CurrencyIsoCode = c.CurrencyIsoCode;
				            	lstBankAccounts.add(ba);
				          	}
			        	}
					} // if (c.RecordTypeId == RT_ICCS_BA.Id)
				}
			    if (!lstBankAccounts.isEmpty()) {
			    	upsert lstBankAccounts;
			    }
			}// if ThereAreICCSBankAccountManagementCases
			if (ThereAreICCSProductManagementCases) {
				// Create a map of all active services, with the key [Product-Country-Currency]
			    Map<String, ICCS_Product_Currency__c> mapProductCurrencyPerKey = new Map<String, ICCS_Product_Currency__c>();
			    List<ICCS_Product_Currency__c> lstProdCurr = [SELECT Id, Currency__c, Country__c, Product__c FROM ICCS_Product_Currency__c WHERE Status__c = 'Active'];
			    for (ICCS_Product_Currency__c pc : lstProdCurr) {
			      	mapProductCurrencyPerKey.put(pc.Product__c + '-' + pc.Country__c + '-' + pc.Currency__c, pc);
			    }
			    // Lists of trigger-related accounts and contacts
			    List<Id> lstAccountIds = new List<Id>();
			    List<Id> lstContactIds = new List<Id>();
			    for (Case c : Trigger.new) {
					lstAccountIds.add(c.AccountId);
			      	lstContactIds.add(c.ContactId);
			    }
			    // Create a map of Product Assignments related to the trigger cases' accounts, with the key [ICCS Product Currency ID - Account Id - Bank Account ID]
			    Map<String, Product_Assignment__c> mapProductAssignmentsPerKey = new Map<String, Product_Assignment__c>();
			    List<Product_Assignment__c> lstPAs = [SELECT CurrencyIsoCode, Id, Account__c, ICCS_Product_Currency__c, Status__c, ICCS_Bank_Account__c, Notice_of_Assignment__c, Amount__c 
			    		FROM Product_Assignment__c WHERE Account__c IN :lstAccountIds];
			    for (Product_Assignment__c pa : lstPAs) {
			      	mapProductAssignmentsPerKey.put(String.valueOf(pa.ICCS_Product_Currency__c) + '-' + String.valueOf(pa.Account__c) + '-' + String.valueOf(pa.ICCS_Bank_Account__c), pa);
			    }
			    // List of the PAs to be upserted
			    List<Product_Assignment__c> lstProdAssignments = new List<Product_Assignment__c>();
			    // List of all BankAccountToCase per Case
			    map<id, list<ICCS_BankAccount_To_Case__c>> caseToBAccs = new map<id, list<ICCS_BankAccount_To_Case__c>>();
			    for (ICCS_BankAccount_To_Case__c batc : [SELECT CurrencyIsoCode, Percentage__c, Case__c, ICCS_Bank_Account__c, Split_Type__c, Notice_of_Assignment__c, Amount__c  FROM ICCS_BankAccount_To_Case__c WHERE Case__c IN :Trigger.newMap.keyset()]) {
			      	if (caseToBAccs.get(batc.Case__c) == null)
			        	caseToBAccs.put(batc.Case__c, new list<ICCS_BankAccount_To_Case__c>());
			      	caseToBAccs.get(batc.Case__c).add(batc);
			    }
			    for (Case c : Trigger.new) {
			      	// Only handle cases with the IDFS_ICCS_Process record type, when they are getting closed
			      	if (c.RecordTypeId == RT_ICCS_Id && c.Status == 'Closed' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Status != 'Closed'))){
			        	if (caseToBAccs.get(c.id) == null)
			          		caseToBAccs.put(c.id, new List<ICCS_BankAccount_To_Case__c>());
			        	if (c.CaseArea__c == 'ICCS – Assign Product') {
			          		if (caseToBAccs.get(c.id).size() == 0)
			            		c.addError('If the case area is "ICCS – Assign Product" is required at least one ICCS Bank Accounts.');
			          		// Create one Product Assignment record for each Bank Account related to the case.
			          		for (ICCS_BankAccount_To_Case__c batc : caseToBAccs.get(c.id)) {
					            Product_Assignment__c pa = new Product_Assignment__c();
					            // Identify & assign the corresponding ICCS Product Currency
					            ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);
					            pa.ICCS_Product_Currency__c = tmpProdCurr.Id;
					            // Identify the related Product Assignment record
					            Product_Assignment__c existingPA = tmpProdCurr != null ? mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId) + '-' + String.valueOf(batc.ICCS_Bank_Account__c)) : null;
					            // Find out if the current product combination has been assigned in the past (but is now inactive)
					            if (existingPA != null) {
					            	pa.Id =  existingPA.Id;
					            }else{
					              	pa.Account__c = c.AccountId;
					              	pa.ICCS_Product_Currency__c = tmpProdCurr.id;
					            }
					            pa.Contact__c = c.ContactId;
					            pa.GSA_Agreement__c = c.GSA_Agreement__c;
					            pa.Notice_of_Assignment__c = batc.Notice_of_Assignment__c;
					            pa.De_Activation_Date__c = c.Process_Approved__c;
					            pa.ICCS_Bank_Account__c = batc.ICCS_Bank_Account__c;
					            pa.Status__c = 'Active';
					            pa.Split_Type__c = batc.Split_Type__c;
					            pa.Percentage__c = batc.Percentage__c;
					            pa.Amount__c = batc.Amount__c;
					            //INC178224
					            pa.CurrencyIsoCode = batc.CurrencyIsoCode;
			            		lstProdAssignments.add(pa);
			          		} //for ICCS_BankAccount_To_Case__c
			        	}else if (c.CaseArea__c == 'ICCS – Remove Product') {
				        	// Identify the corresponding ICCS Product Currency
				          	ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);
				          	// Take all the product assigment with key: ProductCurrency - AccountId   regardless to the bank account selected
				          	for (string key : mapProductAssignmentsPerKey.keyset()) {
				            	if (key.startsWith(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId) + '-')){
				              		// Identify the related Product Assignment record
				              		Product_Assignment__c pa = mapProductAssignmentsPerKey.get(key);
				              		if (pa.Status__c == 'Active') {
						                // Update the Product Assignment record
						                pa.Status__c = 'Inactive';
						                pa.De_Activation_Date__c = c.Process_Approved__c;
						                lstProdAssignments.add(pa);
				              		}
				            	}
				          	}
			        	}else if (c.CaseArea__c == 'ICCS – Update Payment Instructions') {
				        	// Identify the corresponding ICCS Product Currency
				          	ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);
			          		if (caseToBAccs.get(c.id).size() == 0) {
			            		c.addError('If the case area is "ICCS – Update Payment Instructions" is required at least one ICCS Bank Accounts.');
			            		continue;
			          		}
			          		system.debug('##############  Closing a case with casearea = update');
			          		set<id> ProdAssignmentUpdated = new set<id>();
			          		for (ICCS_BankAccount_To_Case__c batc : caseToBAccs.get(c.id)) {
			            		// Identify the related Product Assignment record
			            		Product_Assignment__c pa = tmpProdCurr != null ? mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId) + '-' + String.valueOf(batc.ICCS_Bank_Account__c)) : null;
			            		if (pa != null){
				              		// Update the payment instructions on the Product Assignment record
				              		pa.ICCS_Bank_Account__c = batc.ICCS_Bank_Account__c;
				              		pa.GSA_Agreement__c = c.GSA_Agreement__c;
				              		pa.Notice_of_Assignment__c = batc.Notice_of_Assignment__c;
				              		pa.Status__c = 'Active';
				              		pa.Split_Type__c = batc.Split_Type__c;
				              		pa.Percentage__c = batc.Percentage__c;
				              		pa.Amount__c = batc.Amount__c;
				              		//INC178224
				              		pa.CurrencyIsoCode = batc.CurrencyIsoCode;
				              		ProdAssignmentUpdated.add(pa.id);
				              		lstProdAssignments.add(pa);
			            		}else{
			              			pa = new Product_Assignment__c();
			              			pa.Contact__c = c.ContactId;
					              	pa.Account__c = c.AccountId;
					              	pa.GSA_Agreement__c = c.GSA_Agreement__c;
					              	pa.Notice_of_Assignment__c = batc.Notice_of_Assignment__c;
					              	pa.De_Activation_Date__c = c.Process_Approved__c;
					              	pa.ICCS_Bank_Account__c = batc.ICCS_Bank_Account__c;
					              	pa.Status__c = 'Active';
					              	pa.ICCS_Product_Currency__c = tmpProdCurr.id;
					              	pa.Split_Type__c = batc.Split_Type__c;
					              	pa.Percentage__c = batc.Percentage__c;
					              	pa.Amount__c = batc.Amount__c;
					              	//INC178224
					              	pa.CurrencyIsoCode = batc.CurrencyIsoCode;
				              		lstProdAssignments.add(pa);
			            		}
			          		} //for ICCS_BankAccount_To_Case__c
			          		// Inactivate all the ICCS_BankAccount_To_Case__c with this product-country-currency related to this case and I will reactivate only the ones specified by the case.
			          		for (string key : mapProductAssignmentsPerKey.keyset()) {
			            		Product_Assignment__c pa = mapProductAssignmentsPerKey.get(key);
			            		if (key.startsWith(String.valueOf(tmpProdCurr.id) + '-' + String.valueOf(c.AccountId) + '-')  && pa.Status__c == 'Active' && !ProdAssignmentUpdated.contains(pa.id)) {
			              			pa.Status__c = 'Inactive';
			              			pa.De_Activation_Date__c = c.Process_Approved__c;
			              			lstProdAssignments.add(pa);
			            		}
			          		}
			        	}//else if casearea__c
			      	} //RecordTypeId == RT_ICCS_Id
			    } //for case trigger.new
			    if (!lstProdAssignments.isEmpty()) {
			      	upsert lstProdAssignments;
			    }
			} // if there are iccs cases
			// Send the custom email notifications if the case is (re)assigned to a queue which has custom notifications configured
			CustomQueueNotifications.SendEmailNotifications (trigger.new, trigger.OldMap, trigger.isInsert, trigger.isUpdate);
		}

		/*trgICCSManageProductAssignment Trigger*/
		
		/*trgICCS_ASP_CaseClosed Trigger*/
		//@author: Constantin BUZDUGA, blue-infinity
		// @description: This trigger only handles ICCS Cases with the "FDS ASP Management" record type and is used to update the fields Authorized Signatories, Ongoing Request for Documents
		// and Collection Case Indicator at Account level when the case is closed.
		if(trgICCS_ASP_CaseClosed){ 
			for (Case c : Trigger.new) {
		    	if (c.AccountId != null){
			        // If the Case has just been closed
			        if ( c.RecordTypeId == RT_ICCS_ASP_Id  &&  c.isClosed  &&  !Trigger.oldMap.get(c.Id).isClosed && c.AccountId != null ) {
			            Account a = new Account(Id = c.AccountId, Document_Std_Instruction__c = c.Process_Approved__c, Ongoing_Request_for_Documents__c = false);
			            lstAccountsToUpdate.add( a );
			        }
			        // If the case has just been created and is open, check the Ongoing Request for Documents box at account level
			        if ( c.RecordTypeId == RT_ICCS_ASP_Id && !c.isClosed && Trigger.isInsert) {
			            Account a = new Account(Id = c.AccountId, Ongoing_Request_for_Documents__c = true);
			            lstAccountsToUpdate.add( a );
			        }
			        // Set / unset the Collection Case Indicator
			        if (c.RecordTypeId == RT_ICC_Id && c.CaseArea__c == 'Collection' && (c.Reason1__c == 'Debt Recovery' || c.Reason1__c == 'Annual Fees')) {
			        	// TF - Open debts notification to Admins
			        	if (Trigger.isInsert){
			        		if (!ISSP_UserTriggerHandler.preventOtherTrigger){
			                	accountNotificationIdSet.add(c.AccountId);//TF
			                	system.debug('adding account for insert: ' + c.AccountId);
			                }
			        	}
			        	else if (Trigger.isUpdate){
			        		Case oldCase = trigger.oldMap.get(c.Id);
			        		if (c.AccountId != oldCase.AccountId){
			        			if (!ISSP_UserTriggerHandler.preventOtherTrigger){
			                		accountNotificationIdSet.add(c.AccountId);//TF
			                		system.debug('adding account for update: ' + c.AccountId);
			                	}
			        		}
			        	}
			            if (c.IsClosed && c.Has_the_agent_paid_invoice__c != null && c.Has_the_agent_paid_invoice__c != 'Not paid') {
			                    Account a = new Account(Id = c.AccountId, Collection_Case_Indicator__c = '');
			                    lstAccountsToUpdate.add( a );
			            }else{
			                    Account a = new Account(Id = c.AccountId, Collection_Case_Indicator__c = 'Pending dues');
			                    lstAccountsToUpdate.add( a );
			            }
			        }
		    	} // if AccountId
		    } //for case trigger.new
			if (!lstAccountsToUpdate.isEmpty()) {
		        update lstAccountsToUpdate;
		        //+++TF
		        if (!accountNotificationIdSet.isEmpty()) {
		        	ISSP_UserTriggerHandler.preventOtherTrigger = true;
		        	system.debug('accountNotificationIdSet: ' + accountNotificationIdSet);
		        	List <Contact> contactNotificationList = [SELECT Id FROM Contact WHERE User_Portal_Status__c = 'Approved Admin' 
		        			AND (AccountId IN :accountNotificationIdSet OR Account.Top_Parent__c IN :accountNotificationIdSet)];
					if (!contactNotificationList.isEmpty()){
						if (ISSP_Notifications_Trigger__c.getValues('Outstanding invoice') != null){
							String templateId = ISSP_Notifications_Trigger__c.getValues('Outstanding invoice').Notification_Template_Id__c;
							system.debug('templateId: ' + templateId);
							if (templateId != '' && templateId != null){
								List<Notification_template__c> lstNotificationTemplate = [SELECT Name, Message__c, Admins_Users__c, Alert_Contact_By_Email__c, CriticalNotification__c, 
										Due_date__c, Expire_in_days__c, Language__c, Master_Notification_template__c, Notification_color__c, Subject__c, Type__c 
						                FROM Notification_template__c WHERE Id = :templateId];
								if (!lstNotificationTemplate.isEmpty()){
									system.debug('sending notification to: ' + contactNotificationList);
									Notification_template__c notificationTemplate = lstNotificationTemplate[0];
									ISSP_NotificationUtilities.sendNotification(contactNotificationList, notificationTemplate, null, null);
								}
							}
						}
					}
		        }//---TF
		    }
		}
		/*trgICCS_ASP_CaseClosed Trigger*/
	
		/*trgCreateUpdateServiceRenderedRecord Trigger*/
		/*Trigger that creates a Service Rendered record if the Case Area is Airline Joining / Leaving, 
		 *the case record type is "IDFS Airline Participation Process" and the case is approved*/
		if(trgCreateUpdateServiceRenderedRecord){ 
			system.debug('trgCreateUpdateServiceRenderedRecord');
			string airlineLeaving = 'Airline Leaving';
			string airlineJoining = 'Airline Joining';
			string airlineSuspension = 'Airline Suspension Process';
			String airlineChange = 'Airline Change';
			String separator = '%%%__%%%';
			Id APCaseRTID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');
			//date pretrasfomrationDate =  date.newinstance(2013, 11, 30);
			list<case> casesToTrigger = new list<Case>();
			List<Case> airlineChangeCasesToTrigger = new List<Case>();
			for(case c:trigger.new){
				if(!TransformationHelper.triggerOnCaseNSerRen &&  c.recordtypeId == APCaseRTID && (c.CaseArea__c == airlineJoining || c.CaseArea__c  == airlineLeaving || c.CaseArea__c  == airlineSuspension))
			    	casesToTrigger.add(c);
			    else if (!TransformationHelper.triggerOnCaseNSerRen && c.recordtypeId == APCaseRTID && c.CaseArea__c == airlineChange && c.reason1__c == 'IATA Easy Pay' && c.Status == 'Closed' && c.CaseArea__c == airlineChange && (trigger.isInsert || trigger.oldmap.get(c.id).Status != 'Closed'))
			    	airlineChangeCasesToTrigger.add(c);
			}

			if (!airlineChangeCasesToTrigger.isEmpty()) {
				ServiceRenderedCaseLogic.saveTheServices(airlineChangeCasesToTrigger, null);
			}

			if(!casesToTrigger.isEmpty()){
			    set<String> ServicesToCheck = new set<String>();
			    map<String,Case_Reason_Service__c> ServicesPerReason  = new map<String,Case_Reason_Service__c>();
			    list<Case> USRRcases = new list<Case>();
			    list<Case> casesValidation = new list<Case>();
			    // this custom setting contains the infos regargind the need to reparent the provider to the hq to which the consumer belongs to.
			    for(Case_Reason_Service__c ReasonServiceMapping:Case_Reason_Service__c.getall().values()) {
					ServicesPerReason.put(ReasonServiceMapping.name,ReasonServiceMapping);
					ServicesToCheck.add(ReasonServiceMapping.name);
			    }
			    string STC = '';
			    for (string s:ServicesToCheck) {
					STC += s + ', ';
			    }
			    system.debug('STC: ' + STC);
				map<Id,Id> caseIdPerAccID = new map<Id,Id>();                      
		        map<Id,Case> caseMap = new map<Id,Case>();  
		        //Initial Validation 
		        for (Case c : casesToTrigger){
		        	system.debug('REASON: '+c.reason1__c);
		        	if (ServicesToCheck.contains(c.reason1__c) && c.Status == 'Closed' && (trigger.isInsert || trigger.oldmap.get(c.id).Status != 'Closed')){
			            system.debug('483  ');
			            caseMap.put(c.id,c);
			            caseIdPerAccID.put(c.accountID,c.id);
			        } else if( !ServicesToCheck.contains(c.reason1__c)){
						c.addError(' The reason you entered is not mapped to a service. \n Please contact the administrators.\n Administration Error:Custom Setting ' );                  
		            }
		        }
		       	if(caseMap.size()>0){ //validation and at the same time change of recordtype of the accts if they were standard 
		        	map<Id,Case> casesWithErrorOnAcct = ServiceRenderedCaseLogic.changeRTtoBranchAccts(caseIdPerAccID, caseMap);
					for (Id idc : caseMap.keySet()) {
		            	if(casesWithErrorOnAcct.get(idc) <> null){  
		                	casesWithErrorOnAcct.get(idc).addError(' Errors during the validation of the Account related to the case: Wrong recordtype or not linked to a proper Headquarter ');
						}else{
							system.debug('496  ');
		                	USRRcases.add(caseMap.get(idc));
						}   
		            }
		            // putting this step just to ensure that the logic is working properly and the consumer is an airline 
		            list<Case> casesConsValid = ServiceRenderedCaseLogic.airlineConsumerValidation(USRRcases);
		            //  take a look at this just in case of mass upload of the cases it checks if within the list of cases there's 2 times the same case. start (it adds an error to the wrong ones)  
		            ServiceRenderedCaseLogic.massInsertDuplicateCheck(casesConsValid,ServicesPerReason);
		            // VALIDATION OF THE SERVICES RENDERED: WE LOOK IF WE HAVE DUPLICATES IN THE DATABASE NOT IN THE MASS ENTRY...
		            list<Case> caseWithServicesOK = ServiceRenderedCaseLogic.ServicesValidation(casesConsValid,ServicesPerReason);
		            // separating leaving case from Joining cases and then saving the services rendered             
		            if(!caseWithServicesOK.isEmpty()){
						ServiceRenderedCaseLogic.saveTheServices(caseWithServicesOK,ServicesPerReason);
		            }
				} 
			}
		} //if trgCreateUpdateServiceRenderedRecord
		/*trgCreateUpdateServiceRenderedRecord Trigger*/ 
	
		/*trgCaseEscalationMailNotificationICH Trigger*/
		if(trgCaseEscalationMailNotificationICH){
			for (Case c : trigger.new){
				if(c.recordtypeId == RecId)
			    	ICHcases.add(c);
			}
			if(ICHcases<>null && ICHcases.size()>0){
				List<Contact> Ctc = [Select id from Contact where LastName = 'ICH Help Desk'];
				EmailTemplate et=[Select id from EmailTemplate where DeveloperName='ICH_Escalation_notification_to_YMQ_ICH_support_team'];
			 	id ContactId;
			 	if(Ctc.size() > 0){
			    	ContactId = Ctc[0].Id;
			    	for (Case c : trigger.new){
			            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();         
			            CaseNotificationmail.setTargetObjectId(ContactId);        
			            CaseNotificationmail.setReplyTo(Label.ICHEmail);//'ichhelpdesk@iata.org');
			            CaseNotificationmail.setSenderDisplayName('Salesforce Support');     
			            CaseNotificationmail.setTemplateId(et.id);
			            CaseNotificationmail.setWhatId(c.Id);
			            if(Trigger.isInsert){
			                if (c.CaseArea__c == 'ICH' && c.priority == 'Priority 1 (Showstopper)'){
			                    mails.add(CaseNotificationmail);
			                    hasEmail = true;            
			                }
			            }else{
			                String oldStatus = trigger.oldMap.get(c.id).status;
			                String oldPriority = trigger.oldMap.get(c.id).priority;
			                String oldTeam = trigger.oldMap.get(c.id).assigned_to__c;        
			                if (c.CaseArea__c == 'ICH' &&(((c.status != oldStatus||c.assigned_to__c!=oldTeam) && c.status == 'Escalated' && oldPriority != 'Priority 1 (Showstopper)' 
			                		&& c.assigned_to__c == 'ICH Application Support')||(  oldPriority != c.priority && c.priority == 'Priority 1 (Showstopper)' 
			                		&& !(oldStatus == 'Escalated' && c.assigned_to__c == 'ICH Application Support' )))){
			                    mails.add(CaseNotificationmail);
			                    hasEmail = true;
			                }
			            }
			    	}
			    	if(hasEmail) Messaging.sendEmail(mails);
			 	}
			}
		}
		/*trgCaseEscalationMailNotificationICH Trigger*/
		/*Risk Event Management*/

  		if(Trigger.isUpdate){
  			List<Id> updatedIFAPS = new List<Id>();
  			for(Case c : Trigger.New){
  				if(c.RecordTypeId == IFAPcaseRecordTypeID && String.isNotBlank(c.Financial_Review_Result__c) && String.isBlank(Trigger.oldMap.get(c.Id).Financial_Review_Result__c)){
  					updatedIFAPS.add(c.Id);
  				}
  			}

  			if(!updatedIFAPS.isEmpty()){
  				List<ANG_Agency_Risk_Event__c> res = [SELECT Id, ANG_Limit_Cash_Conditions__c FROM ANG_Agency_Risk_Event__c WHERE ANG_CaseId__r.ParentId IN :updatedIFAPS AND ANG_Limit_Cash_Conditions__c = true];

  				if(!res.isEmpty()){
  					for(ANG_Agency_Risk_Event__c r : res) r.ANG_Limit_Cash_Conditions__c = false;
  					update res; 
  				}
  			}
  		}
  		/*Risk Event Management*/
  		
	}
	/*Share trigger code*/
	
	/****************************************************************************************************************************************************/
    /*Trigger.isInsert*/
	if (Trigger.isInsert) {
        /*trgCaseLastSIDRADate Trigger.isInsert*/
		if(trgCaseLastSIDRADate){
			//Code moved to a helper class: SIDRACaseHelper.cls by Javier Tena on 17/02/2017
       		SIDRACaseHelper.doAfterInsert(Trigger.newMap);
		}
		/*trgCaseLastSIDRADate Trigger.isInsert*/
		
		/*trgParentCaseUpdate Trigger.isInsert*/
		if(trgParentCaseUpdate){
			system.debug('trgParentCaseUpdate Trigger.isInsert');
			// Created Date - 16-12-2010 
			//  TO FUTURE REVIEWER....IT WILL BE NICE TO FIND OUT WHY THIS TRIGGER WAS DEVELOPED AND WHY THE CONDITION ON LINE 18 FOR ALL CASES BUT IFAP
			// PLEASE REVIEW IT...
			for(Case c: trigger.new){
				if(c.parentId != null && 
					!(c.RecordTypeId == IFAPcaseRecordTypeID || c.Reason1__c == 'FA/ FS Non-Compliance') 
					&& ( c.RecordTypeId != FSMcaseRecordTypeID)){
					IFAPcases.add(c);
				}
			}
			if(!IFAPcases.isempty()){    
				if(futureLimit < 10){ 
					if (!FutureProcessorControl.inFutureContext && !System.isBatch()){  // do not execute if in a Batch context - added 2014-12-10 Constantin Buzduga
						//Passing and calling the class according to the event     
						If(Trigger.isInsert){ 
							for(Case ObjCaseNew: IFAPcases){
								// do not execute for IFAP cases - 2012-01-13 Alexandre McGraw
								if (ObjCaseNew.RecordTypeId == IFAPcaseRecordTypeID)
									continue;
									//-------CONTROLLARE QUESTA PARTE DI CODICE--------
									CaseIdsNew.add(ObjCaseNew.Id);
							}
							if(CaseIdsNew.Size() > 0){
								clsInternalCaseDML.InternalCaseDMLMethod(CaseIdsNew, 'Insert');
							}                           
						}
					}
				}
			}
		}
		/*trgParentCaseUpdate Trigger.isInsert*/
		
		/*trgCheckSISCaseRecycleBinAfterInsert Trigger.isInsert*/
		if(trgCheckSISCaseRecycleBinAfterInsert){
			system.debug('trgCheckSISCaseRecycleBinAfterInsert Trigger.isInsert');
			boolean isCaseMustBeDeleted;
			Set<Id> SISidSet = new Set<Id>();
			
			for(Case newCaseObj : trigger.new){ 
				isCaseMustBeDeleted = false;
				//GM - IMPRO - START
				// SIS email to case
				if ((newCaseObj.Origin == 'E-mail to Case - IS Help Desk' || newCaseObj.Origin == 'E-mail to Case - SIS Help Desk') 
						&& newCaseObj.RecordTypeid != null && newCaseObj.RecordTypeid == SISHelpDeskRecordtype) {
					// Email From Address is excluded? Email Address is excluded?
					if (clsCheckOutOfOfficeAndAutoReply.IsFromAddressExcluded(newCaseObj, 'SIS') || clsCheckOutOfOfficeAndAutoReply.IsSubjectExcluded(newCaseObj, 'SIS') ) {
						if (!newCaseObj.IsDeleted){
							SISidSet.add(newCaseObj.id);
							isCaseMustBeDeleted = true;
						}
					}               
					// Delete the case
					if(isCaseMustBeDeleted){
						system.debug('Try deleting the case');
						if(!SISidSet.isEmpty()) 
							TransformationHelper.deleteSObjects(SISidSet, 'Case');
					}
				}
				//GM - IMPRO - END
			}  //for case trigger.new
		} //if trgCheckSISCaseRecycleBinAfterInsert
		/*trgCheckSISCaseRecycleBinAfterInsert Trigger.isInsert*/
		
		/*CaseBeforInsert Trigger.isInsert*/
		if(CaseBeforInsert){
			system.debug('CaseBeforInsert Trigger.isInsert');
	        ISSP_Case.preventTrigger = true;

	    //Start -commented - too many soql queries
	        //User[] users = [Select u.UserType From User u where u.Id =: UserInfo.getUserId()];
	        //system.debug('#ROW# '+users);
	        //for(Case c : trigger.new){ //GM - IMPRO - START
	        //    if(c.Origin == 'Portal'){
	        //        if (users != null && users.size() > 0){
		       //             if (users[0].UserType == 'PowerPartner' || users[0].UserType == 'Guest'){
		       //                 casesIds.add(c.Id);
		       //             }
		       //      }
		       // }
		//Stop - commented - too many soql queries
		       
		//Start - Fix too many soql queries
	        for(Case c : trigger.new){ //GM - IMPRO - START
	            if(c.Origin == 'Portal' && (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'Guest')) {
	        		system.debug('#ROW# '+UserInfo.getUserType());
	                casesIds.add(c.Id);	                    
	            }
	    //Stop - Fix too many soql queries

	            if (c.RecordTypeId == RT_AirlineSuspension_Id || c.RecordTypeId == RT_AirlineDeactivation_Id || c.RecordTypeId == RT_FundsManagement_Id) {
	                setASCaseIds.add(c.Id);
	            }else if (c.RecordTypeId == RT_DIP_Review_Id) {
	                setDIPCaseIds.add(c.Id);
	            }
	        } //GM - IMPRO - END
	        if(casesIds.size() > 0 && !Test.isRunningTest()) 
	        	ISSP_Utilities.DMLOpt(casesIds);
	        // Create Airline Suspension or DIP Details child records for the cases with the Airline Suspension RT / DIP Review Process RT
	        if (!setASCaseIds.isEmpty()) 
	        	AirlineSuspensionUtil.CreateAirlineSuspensionRecords(setASCaseIds);
	        if (!setDIPCaseIds.isEmpty()) 
	        	DIPdetailsUtil.CreateDIPDetailsRecords(setDIPCaseIds);
		}
		/*CaseBeforInsert Trigger.isInsert*/
		
		/*AMS_OSCARCaseTrigger Trigger.isInsert*/
		if(AMS_OSCARCaseTrigger){
			if(AMS_TriggerExecutionManager.checkExecution(Case.getSObjectType(), 'CaseAfterTrigger')){
				AMS_OscarCaseTriggerHelper.OSCARCaseCreationRules(trigger.New);
	        	AMS_OscarCaseTriggerHelper.populateOscarFields(trigger.New);
				AMS_OscarCaseTriggerHelper.CreateRiskChangeCode(); 
			}
		}
		/*AMS_OSCARCaseTrigger Trigger.isInsert*/

		/*trgAccelyaRequestSetCountry Trigger.isInsert*/
		if(trgAccelyaRequestSetCountry){
			Set<Id> AccelyacaseIds = new Set<Id>{};
			list<Case> caseListtoValidate = new List<Case>{};
			list<Case> caseList = new List<Case>{};
			for (Case aCase: trigger.New){
			    if (aCase.RecordTypeId == CSRcaseRecordTypeID) {
			        isAccelya = true;
			        AccelyacaseIds.add(acase.Id);
			    }else{
			        continue;
				}
			}
			if(AccelyacaseIds.size()>0)
				caseListtoValidate = [Select Id, Case_Creator_Email__c, Accelya_Request_Type__c,Applicable_to_Which_BSP_s__c,BSPCountry__c, RecordTypeId from Case where Id in :AccelyacaseIds];
			AssignmentRule AR = new AssignmentRule();
			AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
			if(isAccelya){
				System.debug('Number of cases...........: ' + AccelyacaseIds.size());
				for(Case c : caseListtoValidate){
					if(c.Case_Creator_Email__c == null || !(c.Case_Creator_Email__c.contains('@iata.org'))){
						system.debug('\nAssignment Rule Begins');
						//Creating the DMLOptions for "Assign using active assignment rules" checkbox
						Database.DMLOptions dmlOpts = new Database.DMLOptions();
						dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
						//Setting the DMLOption on Case instance
						c.setOptions(dmlOpts);
						caseList.add(c);
					}
				}
				update caseList;
			}
		}
		/*trgAccelyaRequestSetCountry Trigger.isInsert*/
		
		/*trgCase Trigger.isInsert*/
		if(trgCase){
			system.debug('trgCase Trigger.isUpdate');
			SidraLiteManager.afterInsertSidraLiteCases(Trigger.new);
		}
		/*trgCase Trigger.isInsert*/

		/*ANG Triggers*/
		new ANG_CaseTriggerHandler().onAfterInsert();
		/*ANG Triggers*/
	/*Trigger.isInsert*/
	}
	/****************************************************************************************************************************************************/    
    /*Trigger.isUpdate*/
	else if (Trigger.isUpdate) {
        /*trgCaseIFAP_AfterInsertDeleteUpdateUndelete Trigger.isUpdate*/
		if(trgCaseIFAP_AfterInsertDeleteUpdateUndelete){
			// Check if received cases are IFAP Cases
			for(Case cse : cases){
				if(cse.RecordTypeId == IFAPcaseRecordTypeID){
					caseRecType = true;
				}else{
					break;
				}
				sCaseIds.add(cse.Id);
			}
			if (caseRecType){
				List<IFAP_Quality_Issue__c> QIs = [Select Status__c , Approved_Date__c, Related_Case__c from IFAP_Quality_Issue__c where Related_Case__r.Id IN: sCaseIds and Status__c = 'Pending approval'];
				// Create the map containing the quality issue 
				if (!QIs.isEmpty()){
					for(IFAP_Quality_Issue__c issue : QIs){
						RelatedQualityIssues.put(issue.Related_Case__c, issue);
					}
				}
			}
			for(Case cse : cases) {
				if(cse.RecordTypeId == IFAPcaseRecordTypeID){
					caseRecType = true;
					//casesToConsider.add(cse);
					// Bellow logic used for Quality issue  
					Case OldCase =  Trigger.oldMap.get(cse.Id);
					// approval
					if(cse.Status == 'Quality Issue Request Approved' && OldCase.Status == 'Quality Issue Request Pending Approval'){
						IFAP_Quality_Issue__c QI = RelatedQualityIssues.get(cse.id);
						//IFAP_Quality_Issue__c QI = [Select Status__c , Approved_Date__c from IFAP_Quality_Issue__c where Related_Case__r.Id =: cse.Id and Status__c = 'Pending approval' limit 1];
						if (QI <> null){
							//update Quality issue status to Approved
							QI.Status__c = 'Approved';
							//set approval date
							QI.Approved_Date__c = system.now();
							update QI;
						}
					}
					if(cse.Status == 'Quality Issue Rejected' && OldCase.Status == 'Quality Issue Request Pending Approval'){
						IFAP_Quality_Issue__c QI = RelatedQualityIssues.get(cse.id);
						//IFAP_Quality_Issue__c QI = [ Select Status__c , Approved_Date__c from IFAP_Quality_Issue__c where Related_Case__r.Id =: cse.Id and Status__c = 'Pending approval' limit 1];
						if (QI <> null){
							//update Quality issue status to rejected
							QI.Status__c = 'Rejected';
							QI.Approved_Date__c = system.now();
							issues.add(QI);
							//update QI;
						}
					}
				}
			}
			update issues;
		}
		/*trgCaseIFAP_AfterInsertDeleteUpdateUndelete Trigger.isUpdate*/
		
		/*trgCaseLastSIDRADate Trigger.isUpdate*/
		if(trgCaseLastSIDRADate){
        	//Code moved to a helper class: SIDRACaseHelper.cls by Javier Tena on 17/02/2017
      		SIDRACaseHelper.doAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
		/*trgCaseLastSIDRADate Trigger.isUpdate*/
		
		/*trgCase_ContactLastSurveyUpdate Trigger.isUpdate*/
		if(trgCase_ContactLastSurveyUpdate){
			// This part of the code update a Case's Contact field Instant_Survey_Last_survey_sent__c, if the Case field Instant_Survey_Last_survey_sent__c is updated            
            // Get all Cases' contact and put it in a Map.
            Map<Id, Contact> casesContacts;
            Map<Id, Contact> contactToUpdate = new Map<Id, Contact>(); 
            Boolean isCasesContactsInit = false; // This variable checks if the casesContacts have been already initialized.
            for(Case thisCase:trigger.new){
                Case oldCase = Trigger.oldMap.get(thisCase.Id);                          
                if (thisCase.ContactId != null && oldCase.Instant_Survey_Last_survey_sent__c == null && thisCase.Instant_Survey_Last_survey_sent__c != null){
                    // Initialise casesContacts if it is not initialized yet. This is a way to reduced SOQL call
                    if(isCasesContactsInit == false){
                        casesContacts = new Map<Id,Contact>([SELECT Id, Instant_Survey_Last_survey_sent__c FROM Contact WHERE Id IN (SELECT ContactId From Case WHERE Id IN :Trigger.newMap.keySet())]);
                        isCasesContactsInit = true;
                    }
                    Contact caseContact = casesContacts.get(ThisCase.ContactId);
                    if (caseContact != null){                        
                        caseContact.Instant_Survey_Last_survey_sent__c = datetime.now();
                        contactToUpdate.put(caseContact.Id, caseContact); 
                    }          
                }               
            }
            if (contactToUpdate.size() > 0)
            {
                update contactToUpdate.values();
            }
		}
		/*trgCase_ContactLastSurveyUpdate Trigger.isUpdate*/
		
		/*trgICCS_ASP_CaseClosed Trigger.isUpdate*/
		if(trgICCS_ASP_CaseClosed){
			//Hold list of IEC_Subscription_History record to be inserted
			List<IEC_Subscription_History__c> IEC_SubHistory_Lst_ToInsert = new List<IEC_Subscription_History__c>();
			//Hold list of Cases record to be Updated
			List<Case> CaseToUpdate_Lst = new List<Case>();
			for (Case c : Trigger.new) {
				//If the case is Closed and Matches the following cretiria
				/* AMSU-150 added Oscar Communication record type */
		        if ((c.RecordTypeId == CaseSAAMId || c.RecordTypeId == OscarComRTId) && c.Status == 'Closed' &&  Trigger.oldMap.get(c.Id).Status != 'Closed' && c.CaseArea__c == 'Accreditation Products' 
						&& c.Reason1__c == 'PAX/CARGO Certificate' && c.Product_Category_ID__c != null && !c.Product_Category_ID__c.contains('Triggered') && Integer.valueOf(c.QuantityProduct__c) > 0){
					//Creates new IEC_Subscription_History
					IEC_Subscription_History__c  IEC_SubHistory  = new IEC_Subscription_History__c  () ;
					IEC_SubHistory.Related_Account__c			 = c.Account_Concerned__c ;
					IEC_SubHistory.Rate_Plan_Quantity__c		 = Integer.valueOf(c.QuantityProduct__c) ;
					/* IEC_SubHistory.Related_Contact__c			 = c.ContactId ; */ /* commented because of AMSU-150 */
					IEC_SubHistory.Billing_Account_Number__c	 = c.IATACodeProduct__c ;
					IEC_SubHistory.Invoice_Number__c			 = 'put any value for the moment';
					IEC_SubHistory.Billing_Street__c			 = c.Account_Concerned__r.BillingStreet ;
					IEC_SubHistory.Billing_City__c				 = c.Account_Concerned__r.BillingCity ;
					IEC_SubHistory.Billing_State__c				 = c.Account_Concerned__r.BillingState ;
					IEC_SubHistory.Billing_Zip__c				 = c.Account_Concerned__r.BillingPostalCode ;
					IEC_SubHistory.Billing_Country__c			 = c.Account_Concerned__r.BillingCountry ;
					List <Product_Category__c> ProductCategorytList = [SELECT Id, Name, Active__c,Short_Description__c FROM  Product_Category__c WHERE ID =: c.Product_Category_ID__c ORDER BY Name]; 
					IEC_SubHistory.Purchased_Product_Category__c = ProductCategorytList != null ? ProductCategorytList[0].Id : '' ;
					IEC_SubHistory.Purchased_Product_SKU__c		 = ProductCategorytList != null ? ProductCategorytList[0].Short_Description__c : '' ;
					system.debug('XOXO IEC_SubHistory ===>>>' + IEC_SubHistory);
					//Add new IEC_Subscription_History record to List
					IEC_SubHistory_Lst_ToInsert.add(IEC_SubHistory);
					//Update the Case record to indecate that this specific case is been handled
					if(c.Product_Category_ID__c != null && !c.Product_Category_ID__c.contains('Triggered')){
						Case cc = new Case(Id = c.Id , Product_Category_ID__c = c.Product_Category_ID__c + '_Triggered');
						CaseToUpdate_Lst.add(cc);
					}
		        } //if recordtype = CaseSAAMId
		    } //for case Trigger.new
			//Insert IEC_Subscription_History
			if(IEC_SubHistory_Lst_ToInsert != null && !IEC_SubHistory_Lst_ToInsert.isEmpty()){
				insert IEC_SubHistory_Lst_ToInsert ;
			}
			//Update Cases
			if(CaseToUpdate_Lst != null && !CaseToUpdate_Lst.isEmpty()){
				update CaseToUpdate_Lst ;
			}
		}
		/*trgICCS_ASP_CaseClosed Trigger.isUpdate*/
		
		/*AMS_OSCARCaseTrigger Trigger.isUpdate*/
		if(AMS_OSCARCaseTrigger){
			if(AMS_TriggerExecutionManager.checkExecution(Case.getSObjectType(), 'CaseAfterTrigger')){
				AMS_OscarCaseTriggerHelper.OSCARCaseUpdateRules(trigger.New, trigger.oldMap);
	            AMS_OscarCaseTriggerHelper.populateOscarFields(trigger.New);
				AMS_OscarCaseTriggerHelper.CreateRiskChangeCode();
			}
		}
		/*AMS_OSCARCaseTrigger Trigger.isUpdate*/

		/*ANG Triggers*/
		new ANG_CaseTriggerHandler().onAfterUpdate();
		/*ANG Triggers*/
	/*Trigger.isUpdate*/
	}
	/****************************************************************************************************************************************************/    
    /*Trigger.isDelete*/
	else if (Trigger.isDelete) {   
        /*trgCaseIFAP_AfterInsertDeleteUpdateUndelete Trigger.isDelete
		if(trgCaseIFAP_AfterInsertDeleteUpdateUndelete){
			
		}
		/*trgCaseIFAP_AfterInsertDeleteUpdateUndelete Trigger.isDelete*/

		/*ANG Triggers*/
		new ANG_CaseTriggerHandler().onAfterDelete();
		/*ANG Triggers*/
	/*Trigger.isDelete*/
	}
}