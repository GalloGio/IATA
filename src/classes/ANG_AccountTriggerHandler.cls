public class ANG_AccountTriggerHandler {

	public List<Account> triggerNew = (List<Account>) Trigger.new;
	public List<Account> triggerOld = (List<Account>) Trigger.old;

	public Map<Id, Account> newMap = (Map<Id,Account>) Trigger.newMap;
	public Map<Id, Account> oldMap = (Map<Id,Account>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
		updateRiskStatus();
	}
	public void onAfterInsert() {}

	public void onBeforeUpdate(){
		updateRiskStatus();
		manageDowngrades();
	}
	public void onAfterUpdate() {
		runRiskAssessment();
		UpdateRiskEventStatus();
		new ANG_AgencyEventsGenerator('Update',triggerNew,oldMap,triggerNew.getSObjectType(),'Account','id', 'Top_Parent__c').run();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	private void updateRiskStatus() {

		List<Account> accs = new List<Account>();
		Set<String> topLocationTypes = new Set<String>{AMS_Utils.HE, AMS_Utils.HO, AMS_Utils.AO};

		for(Account acc : triggerNew){
			if(topLocationTypes.contains(acc.Location_Type__c) && (Trigger.isInsert || hasChangedValuesAccount(oldMap.get(acc.Id), acc))){
				accs.add(acc);
			}
		}
		
		if(!accs.isEmpty()) ANG_Risk_Helper.updateRiskStatus(accs);
	}

	private void manageDowngrades() {
		List<Account> downGradeAtoB = new List<Account>();
		List<Account> downGradeBtoC = new List<Account>();

		for(Account acc : triggerNew){
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] new Risk Status - ' + acc.ANG_HE_RiskStatus__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] old Risk Status - ' + oldMap.get(acc.Id).ANG_HE_RiskStatus__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] new Cash Condition - ' + acc.ANG_CashCondition__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandler - manageDowngrades] old Cash Condition - ' + oldMap.get(acc.Id).ANG_CashCondition__c);

			if(acc.ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_B && oldMap.get(acc.Id).ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_A && acc.ANG_CashCondition__c == oldMap.get(acc.Id).ANG_CashCondition__c) downGradeAtoB.add(acc);
			if(acc.ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_C && oldMap.get(acc.Id).ANG_HE_RiskStatus__c == ANG_Risk_Helper.RISK_STATUS_B) downGradeBtoC.add(acc);
		}

		if(downGradeAtoB.isEmpty() && downGradeBtoC.isEmpty()) return;

		//fetch portal admins
		Map<Id, Id> portalAdmins = new Map<Id, Id>();
		Map<Id, Boolean> hasOwnAdmin = new Map<Id, Boolean>();

		Set<Id> involvedAccounts = new Set<Id>();
		involvedAccounts.addAll(new Map<Id, Account>(downGradeAtoB).keySet());
		involvedAccounts.addAll(new Map<Id, Account>(downGradeBtoC).keySet());

		for(Contact c : [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE User_Portal_Status__c = :ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM AND (Account.Top_Parent__c IN :involvedAccounts OR AccountId IN :involvedAccounts)]){

			//select a portal admin from the HE, if possible, or from the hierarchy if not
			if(involvedAccounts.contains(c.AccountId)) portalAdmins.put(c.AccountId, c.Id);
			else if (!portalAdmins.containsKey(c.Account.Top_Parent__c)) portalAdmins.put(c.Account.Top_Parent__c, c.Id);
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
			c.ContactId = portalAdmins.get(acc.Id);
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
		if(!newCases.isEmpty()) insert newCases;
		
		//downgrade from B to C
		if(!downGradeBtoC.isEmpty()) createVMFROscars(downGradeBtoC, portalAdmins);
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

	private static Set<Id> downgradedAccounts{
		get{
			if(downgradedAccounts == null) downgradedAccounts = new Set<Id>();
			return downgradedAccounts;
		}
		set;
	}

	private void createVMFROscars(List<Account> allAccounts, Map<Id, Id> contacts){
		//used on manageDowngrades to create VFMR oscars with all the necessary objects

		//filter accounts
		List<Account> accounts = new List<Account>();
		for(Account acc : allAccounts){
			if(downgradedAccounts.add(acc.Id)) accounts.add(acc);
		}

		if(accounts.isEmpty()) return;

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

		AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(oscars);

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
			c.OwnerId = objects.get(acc.Id).oscar.OwnerId;

			cases.add(c);
			objects.get(acc.Id).commCase = c;
		}

		//insert cases
		insert cases;

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
	    	stgArea.Remittance_frequency__c                  = acc.Remittance_frequency__c;
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
	}

	public void UpdateRiskEventStatus (){
		set<Id> inactiveAccsIdSet = new set<Id>();
		set<Id> activeAccsIdSet = new set<Id>();
		List<ANG_Agency_Risk_Event__c> riskEventsToInactiveList = new List<ANG_Agency_Risk_Event__c>();
		List<ANG_Agency_Risk_Event__c> riskEventsToActiveList = new List<ANG_Agency_Risk_Event__c>();
		List<ANG_Agency_Risk_Event__c> upsertRiskEventsList = new List<ANG_Agency_Risk_Event__c>();

		//get just account ids where status changed to Terminated 
		for(Account a : triggerNew){
		    if(a.status__c == AMS_Utils.ACC_S0_TERMINATED && oldMap.get(a.id).status__c != a.Status__c)
		        inactiveAccsIdSet.add(a.id);
		    else if( oldMap.get(a.id).status__c != a.Status__c && oldMap.get(a.id).status__c == AMS_Utils.ACC_S0_TERMINATED)
		        activeAccsIdSet.add(a.id);
		}

		
		//create set with modified Accs
		set<id> accIdSet = new set<id>(activeAccsIdSet);
		accIdSet.addAll(inactiveAccsIdSet);

		//get all related risk Events 
		List<ANG_Agency_Risk_Event__c> reToUpdateList=[select Id,ang_event_status__c,ANG_Issued_Date__c,ANG_AccountId__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c in :accIdSet and  ang_event_status__c in (:ANG_Risk_Helper.STATUS_ACTIVE, :ANG_Risk_Helper.STATUS_INACTIVE, :ANG_Risk_Helper.STATUS_TERMINATED)];
		
		for(ANG_Agency_Risk_Event__c re : reToUpdateList){
			if(inactiveAccsIdSet.contains(re.ANG_AccountId__c) 
				&& (re.ang_event_status__c == ANG_Risk_Helper.STATUS_ACTIVE || (re.ang_event_status__c == ANG_Risk_Helper.STATUS_INACTIVE && re.ANG_Issued_Date__c > system.Today()))){
			        re.ang_event_status__c = ANG_Risk_Helper.STATUS_TERMINATED;
				
			} else if (activeAccsIdSet.contains(re.ANG_AccountId__c) && re.ang_event_status__c == ANG_Risk_Helper.STATUS_TERMINATED){
		        re.ang_event_status__c = ANG_Risk_Helper.STATUS_ACTIVE;
			}

		}

		update reToUpdateList;
	}


	private void runRiskAssessment() {
        
        Map<Id,Map<Id,Integer>> involvedAccounts = new Map<Id,Map<Id,Integer>>();
        for(account acc : triggerNew){  
            if(acc.ANG_Limit_Cash_Condition__c!= oldMap.get(acc.Id).ANG_Limit_Cash_Condition__c && !acc.ANG_Limit_Cash_Condition__c) involvedAccounts.put(acc.id,new map<id,integer>());
        }

        if(involvedAccounts.isEmpty()) return;

        new ANG_RiskAssessmentEngine(involvedAccounts).assessment();
    }
}
