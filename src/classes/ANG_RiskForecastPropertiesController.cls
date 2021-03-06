public with sharing class ANG_RiskForecastPropertiesController {

	@TestVisible
	private static final String CONVERSION_TO_MULTICOUNTRY_OPT = 'ConversionToMulticountry';

	@TestVisible
	private static final String CONVERSION_MC_TO_ST_OPT = 'ConversionMCToST';

	@TestVisible
	private static final String NOT_APPLICABLE = 'N/A';

	public Case myCase{get;set;}
	public String riskOpt{get; set;}
	public String newRiskStatus{get;set;}
	public Boolean newCashCondition{get;set;}
	public Boolean displayPopup {get;set;}

	public Map<String,ANG_Risk_Event_Type__c> riskEventTypeMap{
		get{
			if(riskEventTypeMap == null){
				riskEventTypeMap= new Map<String,ANG_Risk_Event_Type__c>();
				for(ANG_Risk_Event_Type__c ret :[SELECT id,ANG_Risk_ID__c,Limit_Cash_conditions__c FROM ANG_Risk_Event_Type__c])
					riskEventTypeMap.put(ret.ANG_Risk_ID__c,ret);
			}
			return riskEventTypeMap;
		}
		set;
	}


	public ANG_RiskForecastPropertiesController(ApexPages.StandardController stdController) {
		this.myCase = [SELECT Id, SIDRA_Lite_Reason__c, Account.Name, Account.Identify_as_Multicountry_Key_Hierarchy__c, Account.ParentId,
						   Account.Top_Parent__c, Account.ANG_CashCondition__c, Account.ANG_RiskStatus__c, RecordTypeId, Account.Location_Type__c,
						   Account.Remittance_frequency__c, Account.ANG_Accreditation_Model__c, Account.Status__c, Account.Financial_Review_Result__c,
						   OSCAR__r.Process__c, OSCAR__r.ANG_Type_Of_Change__c, OSCAR__r.ANG_FA_Opt_out__c, OSCAR__r.ANG_Change_Entity_Location__c,
						   OSCAR__r.Change_of_Entity_Location_within_EU__c, OSCAR__r.Parent_OSCAR__c
					   FROM Case
					   WHERE Id = :stdController.getId()];
	}

	public List<SelectOption> getriskOption(){

		List<SelectOption> options= new List<SelectOption>();

		//options.add(new SelectOption('SELECT Risk Option', 'SELECT Risk Option'));

		if(myCase.RecordTypeId == AMS_Utils.RECTYPE_SIDRALITE){

			options.add(new SelectOption('SELECT Risk Option', 'SELECT Risk Option'));

			options.add(new SelectOption('5','Fail Financial Statements'));
			options.add(new SelectOption('7','Unreported Major Change'));
			options.add(new SelectOption('9','Fail Financial Security'));
			options.add(new SelectOption('10','Common ownership default'));
			options.add(new SelectOption('11','Prejudiced collection'));

			if(myCase.SIDRA_Lite_Reason__c == 'Financial Review Non-compliance'
				|| myCase.SIDRA_Lite_Reason__c ==  'Financial Review Non-compliance (OSCAR Change)'
				|| myCase.SIDRA_Lite_Reason__c ==  'Sanity Check failure of financial statement')
				riskOpt ='5';

			else if (myCase.SIDRA_Lite_Reason__c == 'Financial Security Non-compliance'
					|| myCase.SIDRA_Lite_Reason__c == 'Financial Security Non-compliance (OSCAR Change)')
				riskOpt ='9';

			else if (myCase.SIDRA_Lite_Reason__c == 'Late/Absence of Notification of Change' )
				riskOpt ='7';

			else if (myCase.SIDRA_Lite_Reason__c == 'Prejudiced Collection of Funds' )
				riskOpt ='11';
		}

		if(myCase.RecordTypeId == AMS_Utils.RECTYPE_SIDRA){

			options.add(new SelectOption('SELECT Risk Option', 'SELECT Risk Option'));

			options.add(new SelectOption('2','Late/Short payment'));
			options.add(new SelectOption('3','Wrong currency payment'));
			options.add(new SelectOption('4','Payment Default'));

			riskOpt = '1';

		}

		if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NEWHESTANDARD && myCase.OSCAR__r.ANG_Change_Entity_Location__c){

			options.add(new SelectOption('8','Change of Entity\'s location'));

			riskOpt = '1';
		}

		if (myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM
			&& (myCase.OSCAR__r.Process__c == AMS_Utils.NEWGESTANDARD
				|| (myCase.OSCAR__r.Process__c == AMS_Utils.NEWHESTANDARD && !myCase.OSCAR__r.ANG_Change_Entity_Location__c
					&& !myCase.OSCAR__r.Change_of_Entity_Location_within_EU__c)
				|| (isConversionMCToST() && !isParentOscar()))) {

			options.add(new SelectOption('1','Auth. Cash Payment'));
			riskOpt = '1';
		}

		if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NGCHANGES){

			options.add(new SelectOption('SELECT Risk Option', 'SELECT Risk Option'));

			options.add(new SelectOption('1','Auth. Cash Payment'));
			options.add(new SelectOption('6','Major change (owner or legal)'));
			options.add(new SelectOption(NOT_APPLICABLE, 'No applicable Risk Event'));

			if(myCase.OSCAR__r.ANG_Type_Of_Change__c != null){
				List<String> majorChanges = new List<String>{
					AMS_Utils.ANG_OWNERSHIP,
					AMS_Utils.ANG_MAJOR_SHAREHOLDING,
					AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY,
					AMS_Utils.ANG_HIERARCHY,
					AMS_Utils.ANG_LEGAL_NAME,
					AMS_Utils.ANG_LEGAL_STATUS
				};

				if(ANG_AgencyChangesHelper.containsChange(majorChanges,myCase.OSCAR__r.ANG_Type_Of_Change__c)) riskOpt = '6';
				if(ANG_AgencyChangesHelper.containsChange(new List<String>{AMS_Utils.ANG_ACCREDITATION_TYPE},myCase.OSCAR__r.ANG_Type_Of_Change__c)) riskOpt = '1';
			}
		}

		if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NGOPTINOUT){

			options.add(new SelectOption('OptInOut', 'Opt-In/Opt-Out'));
			riskOpt = 'OptInOut';
		}

		if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NGCONVERSIONTOMULTICOUNTRY){
			options.add(new SelectOption(CONVERSION_TO_MULTICOUNTRY_OPT, 'Conversion to Multicountry'));
			riskOpt = CONVERSION_TO_MULTICOUNTRY_OPT;
		}

		if (isConversionMCToST() && isParentOscar()) {
			options.add(new SelectOption(CONVERSION_MC_TO_ST_OPT, 'Conversion GoGlobal to GoStandard'));
			riskOpt = CONVERSION_MC_TO_ST_OPT;
		}

		return options;
	}

	public boolean getcanExecuteForecast(){

		return riskOpt != null && riskOpt != 'SELECT Risk Option';

	}

	public void forecast(){
		// get riskOpt value and forecast risk

		System.debug('Starting forecasting for account ' + myCase.AccountId);

		Account acct = getAccountForForecast();

		List<ANG_Agency_Risk_Event__c> riskEvents = new List<ANG_Agency_Risk_Event__c>();

		if (riskOpt != CONVERSION_TO_MULTICOUNTRY_OPT
			|| (riskOpt == CONVERSION_TO_MULTICOUNTRY_OPT && !acct.Identify_as_Multicountry_Key_Hierarchy__c)) {

			riskEvents = [SELECT Id, ANG_Risk_Type__c, ANG_Risk_ID__c, ANG_Limit_Cash_Conditions__c
						  FROM ANG_Agency_Risk_Event__c
						  WHERE ANG_AccountId__c = :acct.Id
							  AND ANG_Event_Status__c = 'Active'];

			if (riskOpt != 'OptInOut' && riskOpt != CONVERSION_TO_MULTICOUNTRY_OPT && riskOpt != CONVERSION_MC_TO_ST_OPT
				&& riskOpt != NOT_APPLICABLE) {
				riskEvents.add(
					new ANG_Agency_Risk_Event__c(
						ANG_Risk_Type__c=riskEventTypeMap.get(riskOpt).id,
						ANG_Limit_Cash_Conditions__c =riskEventTypeMap.get(riskOpt).Limit_Cash_conditions__c
					)
				);
			}

		}

		Map<Account,List<ANG_Agency_Risk_Event__c>> riskEventsPerAccount = new Map<Account,List<ANG_Agency_Risk_Event__c>>();
		riskEventsPerAccount.put(acct, riskEvents);

		List<Account> accList = new ANG_RiskAssessmentEngine(riskEventsPerAccount).forecastAssessment();

		newCashCondition = accList.get(0).ANG_HE_CashCondition__c;
		newRiskStatus = (riskOpt == 'OptInOut' && myCase.OSCAR__r.ANG_FA_Opt_out__c == 'Opt-Out') ? 'Not Applicable' : accList.get(0).ANG_HE_RiskStatus__c;

		displayPopup = true;
	}

	private Account getAccountForForecast() {
		Account baseAccount = myCase.Account;
		if (baseAccount.Top_Parent__c != null) {
			baseAccount = [SELECT Id, Location_Type__c, Remittance_frequency__c, ANG_Accreditation_Model__c, Status__c, Financial_Review_Result__c,
							   ParentId, Top_Parent__c, Identify_as_Multicountry_Key_Hierarchy__c
						   FROM Account
						   WHERE Id = :baseAccount.Top_Parent__c];
		}

		Account acct = new Account(Id = baseAccount.Id);
		acct.Location_Type__c = baseAccount.Location_Type__c;
		acct.Remittance_frequency__c = baseAccount.Remittance_frequency__c;
		acct.ANG_Accreditation_Model__c = baseAccount.ANG_Accreditation_Model__c;
		acct.Status__c = baseAccount.Status__c;
		acct.Financial_Review_Result__c = baseAccount.Financial_Review_Result__c;
		acct.ParentId = baseAccount.ParentId;
		acct.Top_Parent__c = baseAccount.Top_Parent__c;
		acct.Identify_as_Multicountry_Key_Hierarchy__c = baseAccount.Identify_as_Multicountry_Key_Hierarchy__c;
		return acct;
	}

	public void closePopup() {
		displayPopup = false;
	}

	private boolean isConversionMCToST() {
		return myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NGCONVERSIONMCTOST;
	}
	
	private boolean isParentOscar() {
		return myCase.OSCAR__r.Parent_OSCAR__c == null;
	}
}
