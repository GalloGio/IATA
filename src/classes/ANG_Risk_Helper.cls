public with sharing class ANG_Risk_Helper{
	
	public class invalidCurrencyException extends Exception{}
	public static final String INVALID_CUR_EXCEPTION_MESSAGE = 'Invalid Currency: ';

	//---------------STATIC VARIABLES FOR ANG_* CLASSES----------------------

	public static final String RISK_STATUS_A = 'A';
	public static final String RISK_STATUS_B = 'B';
	public static final String RISK_STATUS_C = 'C';

    //RHC Information standard record type
    public static final String RHC_INFO_STD_RT = 'RHC_Information';

    //RECORDTYPES
    public static final String RECTYPE_ADJUSTMENT           = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Adjustment');          
    public static final String RECTYPE_RISKSTATUSASSESSMENT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Risk_Status_Assessment');
    public static final String RECTYPE_RULES                = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Rules');
    public static final String RECTYPE_STDRHCINFO           = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_RHC_Information__c').get(RHC_INFO_STD_RT);


	//Account - Financial_Review_Result__c
	public static final String FR_SATISFACTORY = 'Satisfactory - No Action';
	public static final String FR_UNSATISFACTORY = 'Unsatisfactory - No action';


	//ANG_Agency_Risk_Event__c - ANG_Event_Status__c
	public static final String STATUS_ACTIVE           = 'Active';
	public static final String STATUS_INACTIVE         = 'Inactive';
	public static final String STATUS_TERMINATED       = 'Inactive_TER';
	public static final String STATUS_WITHDRAWN        = 'Inactive_Withdrawn';
	public static final String STATUS_REVOKED          = 'Inactive_Revoked';
	public static final String STATUS_CHANGE_OWNERSHIP = 'Inactive_CHO';
	public static final String STATUS_INACTIVE_CASHLESS = 'Inactive_Cashless';
	public static final String STATUS_MIGRATED         = 'Inactive_Migrated';

	//RISK EVENT TYPES
	public static final String RISK_TYPE_AUTH_CASH_PAYMENT         = 'Auth. Cash Payment';
	public static final String RISK_TYPE_LATE_SHORT_PAYMENT        = 'Late/Short payment';
	public static final String RISK_TYPE_PAYMENT_DEFAULT           = 'Payment Default';
	public static final String RISK_TYPE_FAIL_FINANCIAL_STATEMENTS = 'Fail Financial Statements';
	public static final String RISK_TYPE_MAJOR_CHANGE              = 'Major change (owner or legal)';
	public static final String RISK_TYPE_UNREPORTED_CHANGE         = 'Unreported Major Change';
	public static final String RISK_TYPE_FAIL_FINANCIAL_SECURITY   = 'Fail Financial Security';
	public static final String RISK_TYPE_COMMON_OWNERSHIP_DEFAULT  = 'Common ownership default';
	public static final String RISK_TYPE_PREJUDICED_COLLECTION     = 'Prejudiced collection';


    //CHANGE CODES
    public static final String CHANGE_CODE_FIN = 'FIN';
    public static final String CHANGE_CODE_IRR = 'IRR';
    public static final String CHANGE_CODE_RCR = 'RCR';
    public static final String CHANGE_CODE_NOT = 'NOT';
    public static final String CHANGE_CODE_MCF = 'MCF';
    public static final String CHANGE_CODE_RVW = 'RVW';
    public static final String CHANGE_CODE_IRW = 'IRW';
    public static final String CHANGE_CODE_NTW = 'NTW';
    public static final String CHANGE_CODE_CCF = 'CCF';
    public static final String CHANGE_CODE_CHF = 'CHF';
    public static final String CHANGE_CODE_CNF = 'CNF';
    public static final String CHANGE_CODE_CSF = 'CSF';
	public static final String CHANGE_CODE_RWD = 'RWD';

	//CHANGE CODES REASON DESCRIPTION 
	public static final String CHANGE_CODE_DESCRIPTION_NCAC                  = 'NON COMPLIANCE TO ACCREDITATION CRITERIA';
	public static final String CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW      = 'FINANCIAL REVIEW';
	public static final String CHANGE_CODE_DESCRIPTION_PREJUDICED_COLLECTION = 'PREJUDICED COLLECTION OF FUNDS';
	public static final String CHANGE_CODE_DESCRIPTION_NCFC                  = 'NON COMPLIANCE TO FINANCIAL CRITERIA' ;

    //CHANGE CODE IRREGULARITY TYPE
    public static final String CHANGE_CODE_IRR_OV1 = 'OV1';
    public static final String CHANGE_CODE_IRR_OV2 = 'OV2';
	public static final String CHANGE_CODE_IRR_FC2 = 'FC2';
    public static final String CHANGE_CODE_IRR_SC2 = 'SC2';

	//Contact - User_Portal_Status__c
	public static final String USER_PORTAL_STATUS_APPROVED_ADIM = 'Approved Admin';

	// Case - Origin
	public static final String CASE_ORIGIN_INTERNAL_CASE = 'Internal case';

	//Case - CaseArea__c
	public static final String CASE_AREA_RISK_MANAGEMENT_PROCESS = 'Risk Management Process';
	public static final String CASE_AREA_ACCREDITATION_PROCESS = 'Accreditation Process';
	public static final String CASE_AREA_CUSTOMER_SERVICE = 'Customer Service';

	//Case - Reason1__c
	public static final String CASE_REASON_FINANCIAL_SECURITY_UPDATE = 'Financial Security Update';
	public static final String CASE_REASON_RHC_75 = 'RHC 75 Follow up';
	public static final String CASE_REASON_ADOC_REVIEW = 'Adhoc review';
	public static final String CASE_REASON_YEARLY_REVIEW = 'Yearly review';

	//Case - BSP_CASS__c
	public static final String CASE_BSP = 'BSP';    
	public static final String CASE_CASS = 'CASS';


	//Account - Remittance_frequency__c
	public static final String REMITTANCE_FREQUENCY_MONTHLY = 'M';
	public static final String REMITTANCE_FREQUENCY_DAILY = 'D';

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

	//Account - ANG_HE_RiskHistoryAssessment__c
	public static final String SECURITY_STATUS_ACTIVE = 'Active';
	public static final String SECURITY_STATUS_CLOSE_EXPIRY_DATE = 'Close to Expiry Date';
	public static final String SECURITY_STATUS_NOT_ACTIVE_YET = 'Not Active yet';

	//set with the status of the FS to be summed
	public static final Set<String> FS_STATUS_FOR_SUM_SET = new Set<String>{SECURITY_STATUS_ACTIVE,SECURITY_STATUS_CLOSE_EXPIRY_DATE};
	
	//set with the status of the FS to be moved
	public static final Set<String> FS_STATUS_FOR_MOVE_SET = new Set<String>{SECURITY_STATUS_ACTIVE,SECURITY_STATUS_CLOSE_EXPIRY_DATE,SECURITY_STATUS_NOT_ACTIVE_YET};

	//Currency Conversion Rates
	public static Map<String,CurrencyType> convertionsRateMap{
		get{
			if(convertionsRateMap ==null){
				convertionsRateMap= new Map<String,CurrencyType>();
				for (CurrencyType cur : [select Id,IsoCode, ConversionRate, DecimalPlaces from CurrencyType where IsActive=true]) {
					convertionsRateMap.put(cur.IsoCode.toUpperCase(), cur);
				}
			}

			return convertionsRateMap;
		}
		private set;
	}

	public static Set<id> accIdSet{
		get;			
		set;
	}

	 // Map that contains rhc account's currencyIsoCode		
	public static Map<id,String> accCurMap{
		get{
			if(accCurMap ==null){
				accCurMap = new Map<id,String>();
				for(ANG_RHC_Information__c rhc:[select ANG_AccountId__c,CurrencyIsoCode from ANG_RHC_Information__c where ANG_AccountId__c in :ANG_Risk_Helper.accIdSet]){
					accCurMap.put(rhc.ANG_AccountId__c,rhc.currencyIsoCode);
				}
			}
			return accCurMap;
		}
		private set;
	}

	public static void inactivateRisk (List<ANG_Agency_Risk_Event__c> riskEvents){
		if(!riskEvents.isEmpty()){
			for(ANG_Agency_Risk_Event__c riskEvent : riskEvents){
				riskEvent.ANG_HE_AccountId__c = null;
				riskEvent.ANG_Event_Status__c = STATUS_CHANGE_OWNERSHIP;
			}

			update riskEvents;
		}
	}
	
	public static void moveRiskHE(Map<Id,Id> newParents){
		List<ANG_Agency_Risk_Event__c> updateREsHE = new List<ANG_Agency_Risk_Event__c>();                 
		List<Financial_Security__c> updateFSsHE = new List<Financial_Security__c>();                 
		
		for(account acc :[select id, (Select id, ANG_HE_AccountId__c FROM All_Risk_Events__r ), (select id,Account__c from Financial_Securities__r where Security_Status__c in:FS_STATUS_FOR_MOVE_SET) from account where id in :newParents.keySet()]){
			for(ANG_Agency_Risk_Event__c risk :  acc.All_Risk_Events__r){                
				risk.ANG_HE_AccountId__c = newParents.get(risk.ANG_HE_AccountId__c);             
				updateREsHE.add(risk);                             
			}
			for(Financial_Security__c fs : acc.Financial_Securities__r){
				fs.account__c = newParents.get(fs.account__C);  
				updateFSsHE.add(fs);  
			}    
		}  

		if(!updateREsHE.isEmpty()) update updateREsHE;
		if(!updateFSsHE.isEmpty()) update updateFSsHE;
	}

	public static Map<String,ANG_Agency_Risk_Calculation__c> calculationTable{
		get{
			if(calculationTable == null || calculationTable.isEmpty()){
				calculationTable = new Map<String,ANG_Agency_Risk_Calculation__c>();

				Id riskStatusAssessmentRT = AMS_Utils.getRecordType('ANG_Agency_Risk_Calculation__c', 'Risk_Status_Assessment').Id;
				for(ANG_Agency_Risk_Calculation__c arc: [SELECT Id, ANG_Financial_Review_Result__c , ANG_Risk_History_Assessment__c,ANG_Risk_History__c,ANG_Limit_Cash_Condition__c FROM ANG_Agency_Risk_Calculation__c WHERE recordTypeId = :riskStatusAssessmentRT]){
					calculationTable.put(arc.ANG_Financial_Review_Result__c + arc.ANG_Risk_History_Assessment__c , arc);
				}
				System.debug(loggingLevel.FINE, '____ [cls ANG_Risk_Helper - updateRiskStatus] calculationTable - ' + calculationTable);
			}
			return calculationTable;
		}
		private set;
	}
	

	public static void updateRiskStatus(List<Account> accs){

		if(calculationTable.isEmpty()) return;

		for(Account acc : accs){
			System.debug(loggingLevel.FINE, '____ [cls ANG_Risk_Helper - updateRiskStatus] key - ' + (acc.Financial_Review_Result__c + acc.ANG_HE_RiskHistoryAssessment__c));
			ANG_Agency_Risk_Calculation__c arc = calculationTable.get(acc.Financial_Review_Result__c + acc.ANG_HE_RiskHistoryAssessment__c);
			acc.ANG_HE_RiskStatus__c = arc==null?null:arc.ANG_Risk_History__c;
			acc.ANG_Limit_Cash_Condition__c = arc==null?false:arc.ANG_Limit_Cash_Condition__c;
			if(acc.ANG_Limit_Cash_Condition__c) acc.ANG_HE_CashCondition__c = true;
		}
	}

	public static void sumFSAmount(List<Account> accounts){
		list<ANG_RHC_Information__c> rhcInfoList= new list<ANG_RHC_Information__c>();
		for(account acc :accounts){
			rhcInfoList.add( new ANG_RHC_Information__c(
				ANG_UniqueKey__c=acc.id+ANG_RHCHelper.RHC_INFO_STD_RT,
				ANG_AccountId__c=acc.id,
				ANG_Financial_Security__c=sumFSConvertedAmounts(acc.Financial_Securities__r)
				)
			);    		
		}
		if(!rhcInfoList.isEmpty())upsert rhcInfoList ANG_UniqueKey__c;
	}

	public static decimal sumFSConvertedAmounts(List<Financial_Security__c> fsList){
		decimal sum=0;
		if(fsList !=null){
			for(Financial_Security__c fs:fsList){
				if(FS_STATUS_FOR_SUM_SET.contains(fs.Security_Status__c)){
					sum+=fs.ANG_ConvertedAmount__c==null?0:fs.ANG_ConvertedAmount__c;
				}
			}
		}

		return sum;
	}

	public static void convertFSAmount(list<Financial_Security__c> fsList,Set<id> accIdSet){
		ANG_Risk_Helper.accIdSet=accIdSet;
		list<Financial_Security__c> tempList= new list<Financial_Security__c>();
		for(Financial_Security__c fs:fsList){
			String targetoCurIso =accCurMap.get(fs.account__C);
			Decimal convertedValue=ANG_Risk_Helper.currencyConverter(fs.CurrencyIsoCode,fs.Amount__c,targetoCurIso==null?fs.CurrencyIsoCode:targetoCurIso);
			if(fs.ANG_ConvertedAmount__c != convertedValue){
				fs.ANG_ConvertedAmount__c=convertedValue;
				tempList.add(fs);
			}
		}
		fsList=tempList;
	}

	public static void convertFSAmountToTargetCur(list<Financial_Security__c> fsList,String targetoCurIso){
		list<Financial_Security__c> tempList= new list<Financial_Security__c>();
		for(Financial_Security__c fs:fsList){
			Decimal convertedValue=ANG_Risk_Helper.currencyConverter(fs.CurrencyIsoCode,fs.Amount__c,targetoCurIso==null?fs.CurrencyIsoCode:targetoCurIso);
			fs.ANG_ConvertedAmount__c=convertedValue;
		}
	}
	

	public static Decimal currencyConverter(String currentCurIso,Decimal amount,String targetCurIso){

		if(currentCurIso == targetCurIso) return amount;

		if(!convertionsRateMap.containsKey(currentCurIso.toUpperCase())) throw new invalidCurrencyException(INVALID_CUR_EXCEPTION_MESSAGE+currentCurIso);
		if(!convertionsRateMap.containsKey(targetCurIso.toUpperCase()))  throw new invalidCurrencyException(INVALID_CUR_EXCEPTION_MESSAGE+targetCurIso);

		Decimal fromRate = convertionsRateMap.get(currentCurIso.toUpperCase()).ConversionRate;
		CurrencyType targetCur = convertionsRateMap.get(targetCurIso.toUpperCase());
		Decimal toRate = targetCur==null?fromRate:targetCur.ConversionRate;

		Decimal result = amount==null?0:amount * toRate/fromRate;
		return result.setScale(targetCur.DecimalPlaces, System.RoundingMode.HALF_UP);
	}

	public class FutureHandler implements Queueable{
		private List<ANG_Agency_Risk_Event__c> riskList;
		private Map<Id,Id> riskMap;
		private String process;
		
		
		public FutureHandler (List<ANG_Agency_Risk_Event__c> riskEvents){          
			this.riskList = riskEvents;
			process = 'Inactivate Risk Events';
		}

		public FutureHandler(Map<Id,Id> newParents){
			this.riskMap = newParents;
			process = 'Change of Ownership - Risk';
		}

		public void execute (QueueableContext context){
			if(process == 'Inactivate Risk Events') inactivateRisk(riskList);
			if(process == 'Change of Ownership - Risk') moveRiskHE(riskMap);
		}
	}

}