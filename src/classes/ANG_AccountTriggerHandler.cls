public class ANG_AccountTriggerHandler {

	public List<Account> triggerNew = (List<Account>) Trigger.new;
	public List<Account> triggerOld = (List<Account>) Trigger.old;

	public Map<Id, Account> newMap = (Map<Id,Account>) Trigger.newMap;
	public Map<Id, Account> oldMap = (Map<Id,Account>) Trigger.oldMap;

	public static Boolean isExpiration{
		get{
			if(isExpiration == null) isExpiration = false;
			return isExpiration;
		}
		set;
	}
	public static Boolean isLastFinancialReviewUpgrade{
		get{
			if(isLastFinancialReviewUpgrade == null) isLastFinancialReviewUpgrade = false;
			return isLastFinancialReviewUpgrade;
		}
		set;
	}

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
		adjustShortName();
		updateRiskStatus();
	}
	public void onAfterInsert() {

	}

	public void onBeforeUpdate(){
		adjustShortName();
		updateRiskStatus();
		runRiskAssessment();
	}
	public void onAfterUpdate() {
		updateRiskEventStatus();
		updateRHCInformation();
		new ANG_AgencyEventsGenerator(filterByIATACode(triggerNew),oldMap,'Account','id').run();
		manageDowngrades();
		manageUpgrades();
		createIEPModelAOscars();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	public static List<Account> filterByIATACode(List<Account> changeCodes){

		List<Account> toReturn = new List<Account>();

		for(Account acct : changeCodes)
			if(acct.IATACode__c <> null)
				toReturn.add(acct);

		return toReturn;
	}

	private void adjustShortName(){

		//AND ( RecordType.DeveloperName = 'IATA_Agency', OR(ISNEW(), ISCHANGED( TradeName__c ), ISCHANGED( Name ),ISCHANGED(Short_Name__c), ISCHANGED(IATACode__c) ) )
		for(Account a : triggerNew){
			if(a.RecordTypeID != RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency'))
				continue;

			if(Trigger.isInsert || ( oldMap.get(a.Id).TradeName__c <> a.TradeName__c || oldMap.get(a.Id).Name <> a.Name || oldMap.get(a.Id).Short_Name__c <> a.Short_Name__c || oldMap.get(a.Id).IATACode__c <> a.IATACode__c)){

				if(a.TradeName__c != null && a.TradeName__c != ''){
					a.Short_Name__c = a.TradeName__c;
				}else if(a.Name != null && a.Name != ''){
					a.Short_Name__c = a.Name;
				}
			}
		}
	}

	private void updateRiskStatus() {

		List<Account> accs = new List<Account>();
		Set<String> topLocationTypes = new Set<String>{AMS_Utils.HE, AMS_Utils.GE, AMS_Utils.HO, AMS_Utils.AO};

		for(Account acc : triggerNew){
			if(topLocationTypes.contains(acc.Location_Type__c) && (Trigger.isInsert || hasChangedValuesAccount(oldMap.get(acc.Id), acc))){
				accs.add(acc);
			}
		}
		
		if(!accs.isEmpty()) ANG_Risk_Helper.updateRiskStatus(accs);
	}

	private void runRiskAssessment() {
		
		Map<Account,List<ANG_Agency_Risk_Event__c>> involvedAccounts = new Map<Account,List<ANG_Agency_Risk_Event__c>>();
		for(account acc : triggerNew){  
			if(acc.ANG_Limit_Cash_Condition__c!= oldMap.get(acc.Id).ANG_Limit_Cash_Condition__c && !acc.ANG_Limit_Cash_Condition__c) involvedAccounts.put(acc, new List<ANG_Agency_Risk_Event__c>());
		}

		if(!involvedAccounts.isEmpty()){
			for(ANG_Agency_Risk_Event__c re : [SELECT Id, ANG_HE_AccountId__c, ANG_Risk_Type__c, ANG_Limit_Cash_Conditions__c FROM ANG_Agency_Risk_Event__c WHERE ANG_HE_AccountId__c IN :involvedAccounts.keySet() AND ANG_Event_Status__c = :Ang_Risk_Helper.STATUS_ACTIVE]){
				involvedAccounts.get(newMap.get(re.ANG_HE_AccountId__c)).add(re);
			}

			for(Account a : new ANG_RiskAssessmentEngine(involvedAccounts).forecastAssessment()){
				System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - runRiskAssessment] a (after forecast) - ' + a);
				Account acc = newMap.get(a.Id);
				acc.ANG_HE_RiskHistoryAssessment__c = a.ANG_HE_RiskHistoryAssessment__c;
				acc.ANG_HE_RiskStatus__c = a.ANG_HE_RiskStatus__c;
				acc.ANG_HE_CashCondition__c = a.ANG_HE_CashCondition__c;
				acc.Financial_Review_Result__c = a.Financial_Review_Result__c;
			}
		}
	}

	private void manageDowngrades() {
		List<Account> downGradeAtoB = new List<Account>();
		List<Account> downGradeBtoC = new List<Account>();
		List<Account> createFOP = new List<Account>();

		for(Account acc : triggerNew){
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] old Risk Status - ' + oldMap.get(acc.Id).ANG_HE_RiskStatus__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] new Risk Status - ' + acc.ANG_HE_RiskStatus__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] old Cash Condition - ' + oldMap.get(acc.Id).ANG_HE_CashCondition__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] new Cash Condition - ' + acc.ANG_HE_CashCondition__c);

			if(acc.ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_B && oldMap.get(acc.Id).ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_A && acc.ANG_CashCondition__c == oldMap.get(acc.Id).ANG_CashCondition__c) downGradeAtoB.add(acc);
			if(acc.ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_C && oldMap.get(acc.Id).ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_B) downGradeBtoC.add(acc);
			if(isExpiration && acc.Guaranteed_amount__c == 0 && acc.ANG_HE_CashCondition__c && !oldMap.get(acc.Id).ANG_HE_CashCondition__c) createFOP.add(acc);
		}

		if(downGradeAtoB.isEmpty() && downGradeBtoC.isEmpty() && createFOP.isEmpty()) return;

		//fetch portal admins
		Map<Id, Id> rhcContacts = new Map<Id, Id>();

		Set<Id> involvedAccounts = new Set<Id>();
		involvedAccounts.addAll(new Map<Id, Account>(downGradeAtoB).keySet());
		involvedAccounts.addAll(new Map<Id, Account>(downGradeBtoC).keySet());
		involvedAccounts.addAll(new Map<Id, Account>(createFOP).keySet());

		Map<String, Set<Id>> allRhcContacts = ANG_ISSP_IEPMailRecipientsUtils.getRecipientsPortalServices(involvedAccounts, new Set<String>{ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE} );

		for(String accId : allRhcContacts.keySet()){
			rhcContacts.put(accId, allRhcContacts.containsKey(accId) ? new List<Id>(allRhcContacts.get(accId))[0] : null);
		}

		//create cases
		List<Case> newCases = new List<Case>();
		Id saamRecordType = AMS_Utils.RECTYPE_SAAM;

		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.useDefaultRule = true;

		for(Account acc : downGradeAtoB){
			Case c = new Case();
			c.RecordTypeId = saamRecordType;
			c.AccountId = acc.Id;
			c.ContactId = rhcContacts.get(acc.Id);
			c.Subject = (String.isEmpty(acc.Short_Name__c) ? acc.Name.left(20) : acc.Short_Name__c.left(20)) + ' - ' + acc.IATACode__c + ' - Downgrade Risk Status';
			c.Region__c = acc.Region_formula__c;
			c.BSPCountry__c = acc.BillingCountry;
			c.Origin = ANG_Risk_Helper.CASE_ORIGIN_INTERNAL_CASE;
			c.CaseArea__c = ANG_Risk_Helper.CASE_AREA_RISK_MANAGEMENT_PROCESS; 
			c.Reason1__c = ANG_Risk_Helper.CASE_REASON_FINANCIAL_SECURITY_UPDATE;
			c.Visible_on_ISS_Portal__c = false;

			//make sure that the default assignment rule is used
			c.setOptions(dmlOpts);

			newCases.add(c);
		}

		//insert new objects
		try{
			if(!newCases.isEmpty()) insert newCases;
		}catch(Exception e){
            //ServiceNow_Helper.sendRequestToSNOW('Salesforce', 'ANG_AccountTriggerHandler', 'manageDowngrades', 'SFDC', 'SFDC',  e.getMessage(), 'false', 'System', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
			ServiceNow_Helper.sendRequestToSNOWSFDC('SNOW10',e);
		}

		//downgrade from B to C
		if(!downGradeBtoC.isEmpty()) createVMFROscars(downGradeBtoC, rhcContacts);

		//downgrade of cash conditions from "Fail Financial Statements" Risk Event
		if(!createFOP.isEmpty()) createFOPOscar(createFOP, rhcContacts);
	}

	//the testing for this method is made on the ANG_ActivateDeactivateREBatch_Test class
	private void manageUpgrades() {
		if(!isExpiration && !isLastFinancialReviewUpgrade) return;

		Set<Id> toNotify = new Set<Id>();
		Set<Id> toChangeCode = new Set<Id>();

		AMS_ChangeCodes__c config = AMS_ChangeCodes__c.getInstance('UpgradedRisk');

		for(Account acc : triggerNew){
			Account oldAcc = oldMap.get(acc.Id);

			if(oldAcc.ANG_HE_RiskStatus__c != acc.ANG_HE_RiskStatus__c && (oldAcc.ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_C || acc.ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_A)){
				toNotify.add(acc.Id);
				if(isExpiration && config != null) toChangeCode.add(acc.Id);
			}

			if(oldAcc.ANG_HE_CashCondition__c != acc.ANG_HE_CashCondition__c && acc.ANG_HE_CashCondition__c == false){
				toNotify.add(acc.Id);
				if(config != null) toChangeCode.add(acc.Id);
			}
		}

		if(toChangeCode.isEmpty() && toNotify.isEmpty()) return;

		List<Agency_Applied_Change_code__c> changeCodes = new List<Agency_Applied_Change_code__c>();
		String source = UserInfo.getUserType() == 'PowerPartner' ? 'Portal' : 'Internal';

		for(Id accId : toChangeCode){
			Account acc = newMap.get(accId);
			changeCodes.add(new Agency_Applied_Change_code__c(
				Active__c = true
				, Account__c = acc.Id
				, Change_Code__c = config.Change_Code__c
				, Bulletin_Information__c = (config.Bulletin_Memo_Text__c == null) ? '' : config.Bulletin_Memo_Text__c.replace('<Risk Status>', acc.ANG_HE_RiskStatus__c).replace('<Cash Condition>', acc.ANG_HE_CashCondition__c?'Yes':'No').toUpperCase()
				, Reason_Code__c = config.Reason_Code__c
				, Reason_Description__c = config.Reason_Code_Description__c
				, Source__c = source
				, CreatedDate_User__c = AMS_ChangeCodesHelper.convertToHubEffectiveDate(system.today())
				, To_Publish_in_e_Bulletin__c = config.Published_in_bulletin__c
			));
		}

		if(!changeCodes.isEmpty()) insert changeCodes;
		
			
		List<EmailTemplate> emailTemplates = [SELECT DeveloperName,Id FROM EmailTemplate WHERE DeveloperName ='Risk_Status_Upgrade' AND isActive = true Order by DeveloperName desc];
		
		List<Notification_Template__c> notificationTemplates = [SELECT Id,Name, Identifier__c FROM Notification_Template__c WHERE Identifier__c ='Risk_Status_Upgrade'];

		if(emailTemplates.isEmpty() && notificationTemplates.isEmpty()) return;

		Map<String, Set<Id>> contactsPerAccount = ANG_ISSP_IEPMailRecipientsUtils.getRecipientsPortalServices(toNotify, new set<String>{ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE});

		if(contactsPerAccount.isEmpty()) return;

		Map<String, String> mailTargets = new Map<String, String>(); //key: contact => value: account
		List<String> notificationTargets = new List<String>();
		List<ANG_RHCHelper.Email> emails = new List<ANG_RHCHelper.Email>();
		for(Id accountId : contactsPerAccount.keySet()){
			for(Id contactId : contactsPerAccount.get(String.valueOf(accountId).substring(0, 15))){
				mailTargets.put(contactId, accountId);
				emails.add(new ANG_RHCHelper.Email(contactId, accountId, emailTemplates[0].Id));
				if(!notificationTemplates.isEmpty()) notificationTargets.add(contactId+':'+notificationTemplates[0].Name);
			}
		}

		if(!mailTargets.isEmpty() && !emailTemplates.isEmpty()) {
			if(!System.isBatch()) {
				System.enqueueJob(new ANG_RHCHelper.RiskAlertMailService(emails, null));
			} else {
				ANG_RHCHelper.sendMailUpdate(emails);
			}
		}

		List<Notification__c> notifications = new List<Notification__c>();
		for(Notification__c nt : ISSP_CreateNotification.createnotification(notificationTargets, false)){
			Account a = newMap.get(mailTargets.get(nt.Contact__c));
			nt.Message__c = nt.Message__c
							.replace('#RISK_STATUS#', a.ANG_HE_RiskStatus__c)
							.replace('#CASH_CONDITION#', (a.ANG_HE_CashCondition__c ? 'Yes' : 'No'));
			notifications.add(nt);
		}

		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageUpgrades] Notifications - ' + notifications);
		
		if(!notifications.isEmpty()) insert notifications;
	}

	public void updateRiskEventStatus (){
		set<Id> inactiveAccsIdSet = new set<Id>();
		set<Id> activeAccsIdSet = new set<Id>();
		set<Id> inactivateAcctsSet = new set<Id>();

		List<ANG_Agency_Risk_Event__c> riskEventsToInactiveList = new List<ANG_Agency_Risk_Event__c>();
		List<ANG_Agency_Risk_Event__c> riskEventsToActiveList = new List<ANG_Agency_Risk_Event__c>();
		List<ANG_Agency_Risk_Event__c> upsertRiskEventsList = new List<ANG_Agency_Risk_Event__c>();

		//get just account ids where status changed to Terminated 
		for(Account a : triggerNew){
			if(a.status__c == AMS_Utils.ACC_S0_TERMINATED && oldMap.get(a.id).status__c != a.Status__c)
				inactiveAccsIdSet.add(a.id);
			else if( oldMap.get(a.id).status__c != a.Status__c && oldMap.get(a.id).status__c == AMS_Utils.ACC_S0_TERMINATED)
				activeAccsIdSet.add(a.id);
			
			/*When changing accreditation type from Cash to Cashless, any active Risk Event should be updated to status "Inactive_Cashless"*/
			if(oldMap.get(a.id).ANG_Accreditation_Model__c == 'Cash' && a.ANG_Accreditation_Model__c == 'Cashless')
				inactivateAcctsSet.add(a.id);
		}

		
		//create set with modified Accs
		set<id> accIdSet = new set<id>(activeAccsIdSet);
		accIdSet.addAll(inactiveAccsIdSet);
		accIdSet.addAll(inactivateAcctsSet);

		//get all related risk Events 
		List<ANG_Agency_Risk_Event__c> reToUpdateList=[select Id,ang_event_status__c,ANG_Issued_Date__c,ANG_AccountId__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c in :accIdSet and  ang_event_status__c in (:ANG_Risk_Helper.STATUS_ACTIVE, :ANG_Risk_Helper.STATUS_INACTIVE, :ANG_Risk_Helper.STATUS_TERMINATED)];
		
		for(ANG_Agency_Risk_Event__c re : reToUpdateList){
			if(inactiveAccsIdSet.contains(re.ANG_AccountId__c) 
				&& (re.ang_event_status__c == ANG_Risk_Helper.STATUS_ACTIVE || (re.ang_event_status__c == ANG_Risk_Helper.STATUS_INACTIVE && re.ANG_Issued_Date__c > system.Today()))){
					re.ang_event_status__c = ANG_Risk_Helper.STATUS_TERMINATED;
				
			} else if (activeAccsIdSet.contains(re.ANG_AccountId__c) && re.ang_event_status__c == ANG_Risk_Helper.STATUS_TERMINATED){
				re.ang_event_status__c = ANG_Risk_Helper.STATUS_ACTIVE;
			}else if( inactivateAcctsSet.contains(re.ANG_AccountId__c) && re.ang_event_status__c <> ANG_Risk_Helper.STATUS_INACTIVE_CASHLESS){
				re.ang_event_status__c = ANG_Risk_Helper.STATUS_INACTIVE_CASHLESS;
			}

		}

		update reToUpdateList;
	}

	private void updateRHCInformation() {
		Map<Id, ANG_RHC_Information__c> rhcToUpdate = new Map<Id, ANG_RHC_Information__c>();
		Map<Id, Boolean> changedConditions = new Map<Id, Boolean>();
		Set<Id> changedStatus = new Set<Id>();

		//Find relevant accounts
		for(Account a : triggerNew){
			//need to check both fields as some will change the be done 
			//previously on the trigger (on on physical field), and some 
			//cases will change only the formula field (i.e.: Opt-in)
			if(a.ANG_HE_CashCondition__c != oldMap.get(a.Id).ANG_HE_CashCondition__c) changedConditions.put(a.Id, a.ANG_HE_CashCondition__c);
			else if(a.ANG_CashCondition__c != oldMap.get(a.Id).ANG_CashCondition__c) changedConditions.put(a.Id, a.ANG_CashCondition__c);
			if(a.Status__c != oldMap.get(a.Id).Status__c && oldMap.get(a.Id).Status__c == AMS_Utils.ACC_S0_TERMINATED) changedStatus.add(a.Id);

		}

		//check to see if we need the logic below
		if(changedConditions.isEmpty() && changedStatus.isEmpty()) return;

		//find rhc records
		for(ANG_RHC_Information__c r : [SELECT ANG_RHC_Amount_Equals_FS__c, CurrencyIsoCode, Id, ANG_AccountId__c, ANG_CashCondition__c, ANG_Financial_Security__c, ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RME_Amount__c, ANG_Exceeding_Financial_Security__c, ANG_RHC_Amount_Provisional__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c IN :changedStatus OR ANG_AccountId__c IN :changedConditions.keySet()]){
			rhcToUpdate.put(r.ANG_AccountId__c, r);
		}

		if(rhcToUpdate.isEmpty()) return;

		//first we set the Cash Conditions that changed
		for(Id acc : changedConditions.keySet()) if(rhcToUpdate.containsKey(acc)) rhcToUpdate.get(acc).ANG_CashCondition__c = changedConditions.get(acc);
		
		//then set the recalculated values
		List<ANG_RHC_Information__c> reactivatedRHC = new List<ANG_RHC_Information__c>();
		for(Id acc : changedStatus) if(rhcToUpdate.containsKey(acc)) reactivatedRHC.add(rhcToUpdate.get(acc));

		if(!reactivatedRHC.isEmpty()) ANG_RHCHelper.calculateRHCAmount(reactivatedRHC);
		
		//then, at last, we make the update
		if(!rhcToUpdate.isEmpty()) update rhcToUpdate.values();
	}


	// ************************************************************
	// ********************* helper methods ***********************
	// ************************************************************

	private Boolean hasChangedValuesAccount(Account oldAcc, Account newAcc){
		// used on updateRiskStatus to determine if some values have changed.

		return oldAcc.Financial_Review_Result__c != newAcc.Financial_Review_Result__c || oldAcc.ANG_HE_RiskHistoryAssessment__c != newAcc.ANG_HE_RiskHistoryAssessment__c;
	}


	private class OscarObjects{
		private AMS_OSCAR__c oscar;
		private Case commCase;
		private AMS_Pax_Accreditation_Form__c stagingArea;
	}

	private void createVMFROscars(List<Account> accounts, Map<Id, Id> contacts){
		//used on manageDowngrades to create VFMR oscars with all the necessary objects
		try{
			//to prevent errors on test classes
			if(Test.isRunningTest()){
				if(ANG_AgencyChangesConfig__c.getInstance('ChangeVFMR') == null){
					insert new ANG_AgencyChangesConfig__c(Name = 'ChangeVFMR', TC_VMFR__c = true,
									TC_Legal_status__c = false, TC_Location__c = false, TC_Location_type__c = false,
									TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false,  TC_Hierarchy__c = false,
									TC_Major_Shareholding__c = false, TC_Ownership__c = false,
									TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD');
				}
			}

			//create object reference map
			Map<Id, OscarObjects> objects = new Map<Id, OscarObjects>();

			//create oscars
			List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();
			for(Account acc : accounts){
				objects.put(acc.Id, new OscarObjects());
				AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES, Account__c = acc.Id,  Process__c = AMS_Utils.NGCHANGES, Status__c='Open');
				oscars.add(oscar);

				objects.get(acc.Id).oscar = oscar;
			}

			AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(oscars, newMap);

			// insert oscars
			insert oscars;

			//create cases
			List<Case> cases = new List<Case>();

			for(Account acc : accounts){
				Case c = new Case();

				c.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
				c.OSCAR__c = objects.get(acc.Id).oscar.Id;
				c.AccountId = acc.Id;
				c.Account_Concerned__c = acc.Id;
				c.BSPCountry__c = acc.BillingCountry;
				c.Region__c = acc.Region_formula__c;
				c.CaseArea__c = ANG_Risk_Helper.CASE_AREA_ACCREDITATION_PROCESS;
				c.ContactId = contacts.get(acc.Id);

				String oscarOwner = objects.get(acc.Id).oscar.OwnerId;
				if(!String.isEmpty(oscarOwner)) c.OwnerId = oscarOwner;

				cases.add(c);
				objects.get(acc.Id).commCase = c;
			}
			//insert cases
			insert cases;

			//populate field with operation with BSP attributes more frequent
			String remitFreq = getHighestRemittanceFrequency(accounts);

			//create staging areas
			List<AMS_Pax_Accreditation_Form__c> stgAreas = new List<AMS_Pax_Accreditation_Form__c>();
			for(Account acc : accounts){
				AMS_Pax_Accreditation_Form__c stgArea = new AMS_Pax_Accreditation_Form__c();

				stgArea.SAAM_Case__c                             = objects.get(acc.Id).commCase.Id;
				stgArea.Abbreviated_Address__c                   = acc.Abbreviated_address__c;
				stgArea.Abbreviated_name__c                      = acc.Abbreviated_name__c;
				stgArea.Accept_terms_and_conditions__c           = true;
				stgArea.Account_Name__c                          = acc.Name;
				stgArea.Billing_State__c                         = acc.BillingState;
				stgArea.Branch_Office_City__c                    = acc.BillingCity;
				stgArea.Branch_Office_Country__c                 = acc.IATA_ISO_Country__c;
				stgArea.Branch_Office_Email__c                   = acc.Email__c;
				stgArea.Branch_Office_FAX__c                     = acc.Fax;
				stgArea.Branch_Office_Phone__c                   = acc.Phone;
				stgArea.Branch_Office_Postal_code__c             = acc.BillingPostalCode;
				stgArea.Branch_Office_Street_name_number__c      = acc.BillingStreet;
				stgArea.CASS_Number__c                           = acc.CASS_Number__c;
				stgArea.IATACode__c                              = acc.IATACode__c;
				stgArea.IATA_ISO_State__c                        = acc.Iso_State__c;
				stgArea.ISSP_AMS_License_No__c                   = acc.License_Number__c;
				stgArea.ISSP_AMS_VAT_number__c                   = acc.VAT_Number__c;
				stgArea.Is_your_firm_handling_Dangerous_Goods__c = acc.Is_your_firm_handling_Dangerous_Goods__c;
				stgArea.Location_Class__c                        = acc.Location_Class__c;
				stgArea.Location_Type__c                         = acc.Location_Type__c;
				stgArea.Mobile__c                                = acc.Mobile__c;
				stgArea.Operation__c                             = acc.Operation__c;
				stgArea.Remittance_frequency__c                  = remitFreq;
				stgArea.Shipping_City__c                         = acc.ShippingCity;
				stgArea.Shipping_Country__c                      = acc.ShippingCountry;
				stgArea.Shipping_Postal_Code__c                  = acc.ShippingPostalCode;
				stgArea.Shipping_State__c                        = acc.ShippingState;
				stgArea.Shipping_Street__c                       = acc.ShippingStreet;
				stgArea.Short_Name__c                            = acc.Short_Name__c;
				stgArea.Solicitation_Flag__c                     = acc.Solicitation_Flag__c;
				stgArea.Submitted_to_IATA__c                     = true;
				stgArea.Trade_Name__c                            = acc.TradeName__c;
				stgArea.VAT_Number_2__c                          = acc.VAT_Number_2__c;
				stgArea.Website__c                               = acc.Website;
				stgArea.ISSP_AMS_Legal_Status__c                 = AMS_AgencyHelper.transformCompanyType(acc.Company_Type__c);

				stgAreas.add(stgArea);
				objects.get(acc.Id).stagingArea = stgArea;
			}

			//insert staging areas
			insert stgAreas;

			//go back to the oscars and update according data from the case and staging areas
			for(AMS_OSCAR__c oscar : oscars){
				oscar.Oscar_Communication_Case_Id__c = objects.get(oscar.Account__c).commCase.Id;
				oscar.Emails_reference_Id__c = AMS_Utils.caseRefId(UserInfo.getOrganizationId(), objects.get(oscar.Account__c).commCase.Id);
				oscar.AMS_Online_Accreditation__c = objects.get(oscar.Account__c).stagingArea.Id;
				oscar.ANG_Type_of_change__c = AMS_Utils.VFMR;

				AMS_HierarchyHelper.createProcessDetailForFullHierarchy(oscar.Id, oscar.Account__c);
			}
			
			update oscars;
		}catch(Exception e){
            //ServiceNow_Helper.sendRequestToSNOW('Salesforce', 'ANG_AccountTriggerHandler', 'createVMFROscars', 'SFDC', 'SFDC',  e.getMessage(), 'false', 'System', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
        	ServiceNow_Helper.sendRequestToSNOWSFDC('SNOW11',e);
        }
	}

	private void createFOPOscar(List<Account> accounts, Map<Id, Id> contacts) {
		try{
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - createFOPOscar] Creating FOP Oscar for '+new Map<Id, Account>(accounts).keyset());

			//create object reference map
			Map<Id, OscarObjects> objects = new Map<Id, OscarObjects>();

			//create oscars
			List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();

			for(Account a : accounts){
				objects.put(a.Id, new OscarObjects());

				AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_NEWGENFOP, Account__c = a.Id,  Process__c = AMS_Utils.NGFOP, Status__c='Open');

				oscars.add(oscar);
				objects.get(a.Id).oscar = oscar;
			}

			AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(oscars, newMap);

			// insert oscars
			insert oscars;

			//create cases
			List<Case> cases = new List<Case>();

			for(Account a : accounts){
				Case c = new Case();

				c.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
				c.OSCAR__c = objects.get(a.Id).oscar.Id;
				c.AccountId = a.Id;
				c.ContactId = contacts.get(a.Id);
				c.BSPCountry__c = a.BillingCountry;
				c.CaseArea__c = ANG_Risk_Helper.CASE_AREA_ACCREDITATION_PROCESS;
				c.Origin = 'Internal User';
				c.Reason1__c = 'FoP Management';
				c.Region__c = a.Region_formula__c;
				c.Subject = 'FoP Management - ' + a.IATACode__c + ' - ' + a.Name;
				c.Type_of_customer__c = 'IATA Travel Agent';

				String oscarOwner = objects.get(a.Id).oscar.OwnerId;
				if(!String.isEmpty(oscarOwner)) c.OwnerId = oscarOwner;

				cases.add(c);
			}

			//insert cases
			insert cases;
		}catch(Exception e){
        	//ServiceNow_Helper.sendRequestToSNOW('Salesforce', 'ANG_AccountTriggerHandler', 'createFOPOscar', 'SFDC', 'SFDC',  e.getMessage(), 'false', 'System', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
			ServiceNow_Helper.sendRequestToSNOWSFDC('SNOW12',e);
		}
	}

	/**
	returns the highest value for remittance Frequency existing on the BSP configurations related with the operation codes that are linked to the accounts
	*/
	private String getHighestRemittanceFrequency(List<Account> accs){
		
		String remitFreq = '';
		List<Id> accsIds = new List<Id>();

		for (Account a: accs)
			accsIds.add(a.Id);

		Map<Id,AMS_Agency_Operations__c> agOpMap = ANG_AgencyChangesHelper.fetchAccountAgOperationPerOpCode(accsIds);
		List<AMS_Operation__c> opCodes = ANG_AgencyChangesHelper.fetchOperationCodeConfiguration(AMS_Utils.getRecordType('AMS_Settlement_System__c','BSP').Id, agOpMap.keySet());

		Integer aux = 0;
		for(AMS_Operation__c op: opCodes){
			for(ANG_BSP_Attributes__c attr : op.BSP_Attributes__r){

				if((Integer)attr.Remittances_Per_Year__c > aux){
					aux = (Integer)attr.Remittances_Per_Year__c;
					remitFreq = attr.Remittance_Frequency__c;
				}
			}
		}

		return remitFreq;
	}

	private void createIEPModelAOscars(){

		Set<Id> iepAccounts = new Set<Id>();
		Map<Id,Account> iepModelAAccounts = new Map<Id,Account>();
		Map<Id,Account> iepModelBAccounts = new Map<Id,Account>();

		for(Account a :triggerNew){

			if(a.ANG_IEP_Status__c == 'In Progress' && oldMap.get(a.Id).ANG_IEP_Status__c != 'In Progress') 
				iepAccounts.add(a.Id);

		}

		if(iepAccounts.isEmpty()) return;

		Map<Id,Account> iepCountriesAccs = new Map<Id,Account>([SELECT Id, IATA_ISO_Country__r.ANG_IEP_Model__c FROM Account WHERE Id IN :iepAccounts AND (IATA_ISO_Country__r.ANG_IEP_Model__c = 'Model A' OR IATA_ISO_Country__r.ANG_IEP_Model__c = 'Model B')]);
		
		for(Id iepAcc: iepAccounts){

			if(iepCountriesAccs.keySet().contains(iepAcc)){

				if(iepCountriesAccs.get(iepAcc).IATA_ISO_Country__r.ANG_IEP_Model__c == 'Model A')
					iepModelAAccounts.put(iepAcc, newMap.get(iepAcc));
				else if(iepCountriesAccs.get(iepAcc).IATA_ISO_Country__r.ANG_IEP_Model__c == 'Model B')
					iepModelBAccounts.put(iepAcc, newMap.get(iepAcc));
			}

		}

		if(!iepModelAAccounts.isEmpty())
			ANG_OscarProcessHelper.createIEPAccountOscar(iepModelAAccounts, 'A');
		if(!iepModelBAccounts.isEmpty())
			ANG_OscarProcessHelper.createIEPAccountOscar(iepModelBAccounts, 'B');
	}
}
