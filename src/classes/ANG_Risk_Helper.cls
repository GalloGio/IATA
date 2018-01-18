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
    public static final String FR_SATISFACTORY = 'Satisfactory';
    public static final String FR_UNSATISFACTORY = 'Unsatisfactory - No action';


    //ANG_Agency_Risk_Event__c - ANG_Event_Status__c
    public static final String STATUS_ACTIVE           = 'Active';
    public static final String STATUS_INACTIVE         = 'Inactive';
    public static final String STATUS_TERMINATED       = 'Inactive_TER';
    public static final String STATUS_WITHDRAWN        = 'Inactive_Withdrawn';
    public static final String STATUS_REVOKED          = 'Inactive_Revoked';
    public static final String STATUS_CHANGE_OWNERSHIP = 'Inactive_CHO';
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

 	//Account - ANG_HE_RiskHistoryAssessment__c
    public static final String SECURITY_STATUS_ACTIVE = 'Active';
    public static final String SECURITY_STATUS_CLOSE_EXPIRY_DATE = 'Close to Expiry Date';

    //set with the status of the FS to be summed
    public static final set<string> FS_STATUS_FOR_SUM_SET = new set<string>{SECURITY_STATUS_ACTIVE,SECURITY_STATUS_CLOSE_EXPIRY_DATE};
    

    //Currency Conversion Rates
    public static map<string,CurrencyType> convertionsRateMap{
		get{
			if(convertionsRateMap ==null){
				convertionsRateMap= new map<string,CurrencyType>();
				for (CurrencyType cur : [select Id,IsoCode, ConversionRate, DecimalPlaces from CurrencyType where IsActive=true]) {
					convertionsRateMap.put(cur.IsoCode.toUpperCase(), cur);
				}
			}

			return convertionsRateMap;
		}
		private set;
	}


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

    public static List<Account> updateRiskStatus(List<Account> accs){

        Id riskStatusAssessmentRT = AMS_Utils.getRecordType('ANG_Agency_Risk_Calculation__c', 'Risk_Status_Assessment').Id;
        
        Map<String,ANG_Agency_Risk_Calculation__c> calculationTable = new Map<String,ANG_Agency_Risk_Calculation__c>();
        for(ANG_Agency_Risk_Calculation__c arc: [SELECT Id, ANG_Financial_Review_Result__c , ANG_Risk_History_Assessment__c,ANG_Risk_History__c,ANG_Limit_Cash_Condition__c from ANG_Agency_Risk_Calculation__c where recordTypeId = :riskStatusAssessmentRT]){
            calculationTable.put(arc.ANG_Financial_Review_Result__c + arc.ANG_Risk_History_Assessment__c , arc);
        }

        System.debug(loggingLevel.FINE, '____ [cls ANG_Risk_Helper - updateRiskStatus] calculationTable - ' + calculationTable);

        if(!calculationTable.isEmpty()){
            for(Account acc : accs){
                ANG_Agency_Risk_Calculation__c arc = calculationTable.get(acc.Financial_Review_Result__c + acc.ANG_HE_RiskHistoryAssessment__c);
                acc.ANG_HE_RiskStatus__c = arc==null?null:arc.ANG_Risk_History__c;
                acc.ANG_Limit_Cash_Condition__c = arc==null?false:arc.ANG_Limit_Cash_Condition__c;
               
            }
        }

        return accs;
    }

    public static void createRHCInfo(Set<Id> accountIds, Boolean sumFS) {
        createRHCInfo([SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode, (SELECT Id, Security_Status__c, ANG_ConvertedAmount__c FROM Financial_Securities__r) FROM Account WHERE Id IN :accountIds], sumFS);
    }

    public static void createRHCInfo(List<Account> accounts, Boolean sumFS) {

        if(accounts.isEmpty()) return;

        List<ANG_RHC_Information__c> rhcInfos = new List<ANG_RHC_Information__c>();

        for(Account a : accounts){
            rhcInfos.add(new ANG_RHC_Information__c(
                ANG_AccountId__c = a.Id,
                RecordTypeId = RECTYPE_STDRHCINFO,
                ANG_UniqueKey__c=a.id+RHC_INFO_STD_RT,
                CurrencyIsoCode = a.IATA_ISO_Country__r.CurrencyIsoCode
            ));
        }

        insert rhcInfos;

        if(sumFS) sumFSAmount(accounts);
    }

    public static void sumFSAmount(List<Account> accounts){
    	list<ANG_RHC_Information__c> rhcInfoList= new list<ANG_RHC_Information__c>();
    	for(account acc :accounts){
			rhcInfoList.add( new ANG_RHC_Information__c(
				ANG_UniqueKey__c=acc.id+RHC_INFO_STD_RT,
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

    public static void convertFSAmount(list<Financial_Security__c> fsList,set<id> accIdSet){
		list<Financial_Security__c> tempList= new list<Financial_Security__c>();
		map<id,string> accCurMap= new map<id,string>(); // map that contains rhc account's currencyIsoCode
		for(ANG_RHC_Information__c rhc:[select ANG_AccountId__c,CurrencyIsoCode from ANG_RHC_Information__c where ANG_AccountId__c in :accIdSet]){
			accCurMap.put(rhc.ANG_AccountId__c,rhc.currencyIsoCode);
		}

		for(Financial_Security__c fs:fsList){
			string targetoCurIso =accCurMap.get(fs.account__C);
			Decimal convertedValue=ANG_Risk_Helper.currencyConverter(fs.CurrencyIsoCode,fs.Amount__c,targetoCurIso==null?fs.CurrencyIsoCode:targetoCurIso);
			if(fs.ANG_ConvertedAmount__c != convertedValue){
				fs.ANG_ConvertedAmount__c=convertedValue;
				tempList.add(fs);
			}
		}
		fsList=tempList;
	}

	public static void convertFSAmountToTargetCur(list<Financial_Security__c> fsList,string targetoCurIso){
		list<Financial_Security__c> tempList= new list<Financial_Security__c>();
		for(Financial_Security__c fs:fsList){
			Decimal convertedValue=ANG_Risk_Helper.currencyConverter(fs.CurrencyIsoCode,fs.Amount__c,targetoCurIso==null?fs.CurrencyIsoCode:targetoCurIso);
			fs.ANG_ConvertedAmount__c=convertedValue;
	    }
	}
	

    public static Decimal currencyConverter(string currentCurIso,Decimal ammount,string targetCurIso){

		if(!convertionsRateMap.containsKey(currentCurIso.toUpperCase())) throw new invalidCurrencyException(INVALID_CUR_EXCEPTION_MESSAGE+currentCurIso);
		if(!convertionsRateMap.containsKey(targetCurIso.toUpperCase()))  throw new invalidCurrencyException(INVALID_CUR_EXCEPTION_MESSAGE+targetCurIso);

		Decimal fromRate = convertionsRateMap.get(currentCurIso.toUpperCase()).ConversionRate;
		CurrencyType targetCur = convertionsRateMap.get(targetCurIso.toUpperCase());
		Decimal toRate = targetCur==null?fromRate:targetCur.ConversionRate;

		Decimal result = ammount==null?0:ammount * toRate/fromRate;
		return result.setScale(targetCur.DecimalPlaces, System.RoundingMode.HALF_UP);
	}
}