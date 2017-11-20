public with sharing class ANG_Risk_Helper{
	

	//---------------STATIC VARIABLES FOR ANG_* CLASSES----------------------

	public static final String RISK_STATUS_A = 'A';
	public static final String RISK_STATUS_B = 'B';
	public static final String RISK_STATUS_C = 'C';


	//RECORDTYPES
	public static final String RECTYPE_ADJUSTMENT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Adjustment');			
	public static final String RECTYPE_RISKSTATUSASSESSMENT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Risk_Status_Assessment');
	public static final String RECTYPE_RULES = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Rules');


	//Account - Financial_Review_Result__c
	public static final String FR_SATISFACTORY = 'Satisfactory';
	public static final String FR_UNSATISFACTORY = 'Unsatisfactory - No action';

	//ANG_Agency_Risk_Event__c - ANG_Event_Status__c
	public static final String STATUS_ACTIVE           = 'Active';
	public static final String STATUS_INACTIVE         = 'Inactive';
	public static final String STATUS_TERMINATED       = 'Inactive_TER';
	public static final String STATUS_WITHDRAWN        = 'Inactive_Withdrawn';
	public static final String STATUS_REVOKED          = 'Inactive_Revoked';
	public static final String STATUS_CHANGE_OWNERSHIP = 'Inactive_CHO';
	public static final String STATUS_INACTIVE_CASHLESS = 'Inactive_Cashless';

	//Contact - User_Portal_Status__c
	public static final String USER_PORTAL_STATUS_APPROVED_ADIM = 'Approved Admin';

	// Case - Origin
	public static final String CASE_ORIGIN_INTERNAL_CASE = 'Internal case';

	//Case - CaseArea__c
	public static final String CASE_AREA_RISK_MANAGEMENT_PROCESS = 'Risk Management Process';
	public static final String CASE_AREA_ACCREDITATION_PROCESS = 'Accreditation Process';

	//Case - Reason1__c
	public static final String CASE_REASON_FINANCIAL_SECURITY_UPDATE = 'Financial Security Update';

	//Case - BSP_CASS__c
	public static final String CASE_BSP = 'BSP';	
	public static final String CASE_CASS = 'CASS';


	//Account - Remittance_frequency__c
	public static final String REMITTANCE_FREQUENCY_MONTHLY = 'Monthly';
	public static final String REMITTANCE_FREQUENCY_DAILY = 'Daily';

	// ANG_Agency_Risk_Calculation__c - ANG_Adjusted__c
	public static final String ADJ_YES   = 'Yes';
	public static final String ADJ_NO    = 'No';
	public static final String ADJ_MIXED = 'Mixed';

	// Case - IRR_Approval_Rejection__c
	public static final String CASE_IRR_APPROVED = 'Approved';
	public static final String CASE_IRR_REJECTED = 'Rejected';

	//Account - ANG_HE_RiskHistoryAssessment__c
	public static final String RISK_ASSESSMENT_PASSED = 'Passed';
    public static final String RISK_ASSESSMENT_FAILED = 'Failed';


	public class changeAgencyRiskEvent implements Queueable{
		private List<ANG_Agency_Risk_Event__c> riskList;
		private Map<id,id> riskMap;
		public boolean isAllHierarchy = false;
		
		
		public changeAgencyRiskEvent (List<ANG_Agency_Risk_Event__c> listAgencyRiskEventToChange){			
			this.riskList = listAgencyRiskEventToChange;
			isAllHierarchy = true;			 
		}

		public changeAgencyRiskEvent(Map<Id,Id> mapToWork){
			this.riskMap = mapToWork;
		}

		public void execute (QueueableContext context){
			if(isAllHierarchy) inactivateRisk(riskList);
			if(!isAllHierarchy) changeOfHE(riskMap);
		}
	}

	public static void inactivateRisk (List<ANG_Agency_Risk_Event__c> listAgencyRiskEventToChange){		
		List<ANG_Agency_Risk_Event__c> riskEventToUpdate = new List<ANG_Agency_Risk_Event__c>();
		
		if(!listAgencyRiskEventToChange.isEmpty()){
			for(ANG_Agency_Risk_Event__c riskEvent : listAgencyRiskEventToChange){
				riskEvent.ANG_HE_AccountId__c = null;
				riskEvent.ANG_Event_Status__c = 'Inactive_CHO';
				riskEventToUpdate.add(riskEvent);
			}
		}

		if(!riskEventToUpdate.isEmpty()) update riskEventToUpdate;
	}
	
	public static void changeOfHE(Map<Id,Id> mapToWork){
		List<ANG_Agency_Risk_Event__c> updateHE = new List<ANG_Agency_Risk_Event__c>();					
		
		for(ANG_Agency_Risk_Event__c risk : [Select id, ANG_HE_AccountId__c, ANG_AccountId__c, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c where ANG_HE_AccountId__c in :mapToWork.keySet()]){				
			risk.ANG_HE_AccountId__c = mapToWork.get(risk.ANG_HE_AccountId__c);				
			updateHE.add(risk);								
		}		

		if(!updateHE.isEmpty()) update updateHE;
	}
}