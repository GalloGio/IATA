public class ANG_RiskAssessmentEngine{

	@TestVisible private static final String APPLY_CEILING_SUM = 'CEILING[Σ(RF)*0.0075]';
	@TestVisible private static final String APPLY_SUM_ONLY = 'Σ(RF)';
	@TestVisible private static final String REMITTANCE_FREQUENCY_VALUES_REC_TYPE_NAME = 'Remittance_Frequency_Values';

	private static map<id,ang_agency_risk_calculation__c> risCalcMap{ // map risk event Calculations
		get{
			if(ANG_RiskAssessmentEngine.risCalcMap==null) setMaps();
			return ANG_RiskAssessmentEngine.risCalcMap;
		}
		set;
	}

	private static map<id,ang_agency_risk_calculation__c> risCalAdjcMap{ //map adjusted risk calculations
		get{
			if(ANG_RiskAssessmentEngine.risCalAdjcMap==null) setMaps();
			return ANG_RiskAssessmentEngine.risCalAdjcMap;
		}
		private set;
	}

	private static Map<String, ANG_Agency_Risk_Calculation__c> riskCalcRulesMulticountryMap {
		get{
			if(riskCalcRulesMulticountryMap == NULL) setMaps();
			return riskCalcRulesMulticountryMap;
		}
		set;
	}

	private static Map<String, Decimal> nbrOfRemittancesPerFrequencyMap {
		get{
			if(nbrOfRemittancesPerFrequencyMap == NULL) setMaps();
			return nbrOfRemittancesPerFrequencyMap;
		}
		set;
	}

	private static void setMaps(){ // method to populate the risk event calculation maps1
		ANG_RiskAssessmentEngine.risCalcMap = new map<id,ang_agency_risk_calculation__c>();
		ANG_RiskAssessmentEngine.risCalAdjcMap = new map<id,ang_agency_risk_calculation__c>();
		riskCalcRulesMulticountryMap = new Map<String, ANG_Agency_Risk_Calculation__c>();
		nbrOfRemittancesPerFrequencyMap = new Map<String, Decimal>();
		for(ang_agency_risk_calculation__c arc:[select id, ANG_Occurrence_Num__c, ANG_Accreditation_Model__c, ANG_Adjusted__c, ANG_RF_Sum_Type__c, ANG_Remittance_Frequency__c, RecordType.DeveloperName, (select id,ANG_Parent_Occurences__c,ANG_Occurrence_Num__c,ANG_Remittance_Frequency__c, ANG_Min_Range__c, ANG_Max_Range__c from ANG_Adjustments__r) from ang_agency_risk_calculation__c where recordtype.name='Rules' or recordtype.developername = 'Remittance_Frequency_Values' order by RecordType.Name, ANG_Occurrence_Num__c asc]){

			if(arc.RecordType.DeveloperName == REMITTANCE_FREQUENCY_VALUES_REC_TYPE_NAME){
				nbrOfRemittancesPerFrequencyMap.put(arc.ANG_Remittance_Frequency__c, arc.ANG_Occurrence_Num__c);
			}
			else if(arc.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY){
				riskCalcRulesMulticountryMap.put(arc.ANG_Adjusted__c, arc);
			}
			else if(arc.ANG_Occurrence_Num__c == 0){
				ANG_RiskAssessmentEngine.risCalAdjcMap.put(arc.id,arc);
			}
			else {
				ANG_RiskAssessmentEngine.risCalcMap.put(arc.id,arc);
			}
		}
	}

	public class AccHelperClass{  //helper class to store account Info
		private integer nrAdjustedRE;
		private boolean hasCashCondition;
		private boolean hasLimitCashCondition;
		private string remitanceFrequency;
		private string accreditationModel;
		private string financialReviewResult;
		private string status;
		private Id acctId;
		private Id topParent;

		public AccHelperClass(Integer nAdjs, boolean hasCashCond,boolean hasLimitCashCond,String remitFreq, String accrModel, String financialReviewRes,String stats, Id acctId, Id topParent){
			nrAdjustedRE=nAdjs;
			hasCashCondition=hasCashCond;
			hasLimitCashCondition=hasLimitCashCond;
			remitanceFrequency=remitFreq;
			accreditationModel=accrModel;
			financialReviewResult=financialReviewRes;
			status=stats;
			this.acctId = acctId;
			this.topParent = topParent;
			System.debug(loggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - AccHelperClass constructor] this - ' + this);
		}
	}

	private map<id,AccHelperClass> accInfoMap{ //map adjusted risk calculations
		get{
			if(accInfoMap==null){
				accInfoMap = new map<id,AccHelperClass>();
				for(account acc:[select id,name, Top_Parent__c, remittance_frequency__c,ANG_Limit_Cash_Condition__c,ANG_Accreditation_Model__c,Financial_Review_Result__c,status__c,(select id,ANG_Risk_Type__r.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c,ANG_Limit_Cash_Conditions__c from All_Risk_Events__r where ANG_Event_Status__c=:Ang_Risk_Helper.STATUS_ACTIVE) from account where id in :accCalcMap.keySet()]){
					integer nAdjs=0;
					boolean hasCashCond=false;
					for(ANG_Agency_Risk_Event__c are:acc.All_Risk_Events__r){
						if(are.ANG_Risk_Type__r.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c=='Yes') nAdjs++;
						hasCashCond=hasCashCond||are.ANG_Limit_Cash_Conditions__c;
					}
					accInfoMap.put(acc.id,new AccHelperClass(nAdjs,hasCashCond,acc.ANG_Limit_Cash_Condition__c,acc.remittance_frequency__c,acc.ANG_Accreditation_Model__c,acc.Financial_Review_Result__c,acc.status__c, acc.Id, acc.Top_Parent__c));

				}
			}
			return accInfoMap;
		}
		private set;
	}




	private map<id,Map<id,integer>> accCalcMap{ //map containning accounts RE occurences for assessment
		get{
			if(accCalcMap ==null) accCalcMap= new map<id,Map<id,integer>>();
			return accCalcMap;
		}
		private set;
	}

	private boolean breakCicle{
		get{
			if(breakCicle==null) breakCicle=false;
			return breakCicle;
		}
		set;
	} // assist variable to skip cicle




	//============================FORECASTING VARIABLES ==========================================
	private map<string,ang_risk_event_type__c> reType2CalcMap{ //map adjusted risk calculations
		get{
			if(reType2CalcMap==null){
				reType2CalcMap = new map<string,ang_risk_event_type__c>();
				for(ang_risk_event_type__c ret:[select id,ANG_Risk_ID__c,ANG_Agency_Risk_Calculation__c,ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c,Limit_Cash_conditions__c from ang_risk_event_type__c]){
					reType2CalcMap.put(ret.id,ret);
					reType2CalcMap.put(ret.ANG_Risk_ID__c,ret);
				}
			}
			return reType2CalcMap;
		}
		private set;
	}

	private account forecastAccount{ //referenced account to have risk history forecasted
		get;private set;
	}

	private map<id,integer> forecastCalcMap{  //calculation/occurence number map in the forecast
		get;private set;
	}
	private integer nrAdjustedRe{ // nr adjusted RE in the forecast
		get;private set;
	}

	//============================ END FORECASTING VARIABLES=========================================



	//============================ CONSTRUCTORS ====================================================

	public ANG_RiskAssessmentEngine(map<id,Map<id,integer>> AccMap){ // account -> calculation- Occurrence nr
		if(AccMap ==null) return;
		accCalcMap.putAll(AccMap);
		string accId=null;
		map<id,integer> calcTempMap= new map<id,integer>();
		for(AggregateResult reRec:[select ang_HE_accountid__c,ang_risk_type__r.ANG_Agency_Risk_Calculation__c calcId,count(id) counter from ang_agency_risk_event__c where ang_HE_accountid__c in :AccMap.keySet() AND ANG_Event_Status__c= :Ang_Risk_Helper.STATUS_ACTIVE group by ang_HE_accountid__c,ang_risk_type__r.ANG_Agency_Risk_Calculation__c]){
			if(accId==null)accId=String.valueOf(reRec.get('ang_HE_accountid__c'));
			else if(accId!=reRec.get('ang_HE_accountid__c')){
				accCalcMap.remove(accId);
				accCalcMap.put(accId,calcTempMap);
				calcTempMap= new map<id,integer>();
				accId=String.valueOf(reRec.get('ang_HE_accountid__c'));
			}
			calcTempMap.put((id)reRec.get('calcId'),Integer.valueOf(reRec.get('counter')));
		}
		if(accId !=null){
			accCalcMap.remove(accId);
			accCalcMap.put(accId,calcTempMap);
		}

		for(id accountId:accInfoMap.KeySet()){
			if(accCalcMap.containsKey(accountId) && (accInfoMap.get(accountId).accreditationModel== AMS_Utils.ACCREDITATIONMODEL_LEGACY ||  accInfoMap.get(accountId).accreditationModel==AMS_Utils.ACCREDITATIONMODEL_CASHLESS || accInfoMap.get(accountId).status== AMS_Utils.ACC_S0_TERMINATED)){
				accCalcMap.remove(accountId);
			}
		}
	}

	public ANG_RiskAssessmentEngine(map<account,list<ang_agency_risk_event__c>> accRiskEventsMap){
		//list<string>> accRiskEventsMap -> list of strings containg the risk Type Id or de risk type UniqueKey
		for(account acc:accRiskEventsMap.KeySet()){
			if(acc.ANG_Accreditation_Model__c==AMS_Utils.ACCREDITATIONMODEL_LEGACY ||  acc.ANG_Accreditation_Model__c==AMS_Utils.ACCREDITATIONMODEL_CASHLESS || acc.status__c== AMS_Utils.ACC_S0_TERMINATED){
				accCalcMap.put(acc.id,null);// to return the assessment
				continue;
			}

			boolean hasCashCond=false;
			integer nrAdjustedRe=0;
			map<id,integer> tempCalcMap = new map<id,integer>();
			for(ang_agency_risk_event__c are:(list<ang_agency_risk_event__c>)accRiskEventsMap.get(acc)){
				ang_risk_event_type__c ret=(ang_risk_event_type__c)reType2CalcMap.get(are.ANG_Risk_Type__c);
				id calcId=ret.ANG_Agency_Risk_Calculation__c;
				if(tempCalcMap.containsKey(calcId)){
					Integer nOcc=(integer)tempCalcMap.get(calcId)+1;
					tempCalcMap.remove(calcId);
					tempCalcMap.put(calcId,nOcc);
				}else{
					tempCalcMap.put(calcId,1);
				}
				if(ret.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c==ANG_Risk_Helper.ADJ_YES){
					nrAdjustedRe+=1;
				}
				hasCashCond=hasCashCond||are.ANG_Limit_Cash_Conditions__c;
			}
			accCalcMap.put(acc.id,tempCalcMap);
			accInfoMap.put(acc.id,new AccHelperClass(nrAdjustedRe,hasCashCond,acc.ANG_Limit_Cash_Condition__c,acc.remittance_frequency__c,acc.ANG_Accreditation_Model__c,acc.Financial_Review_Result__c,acc.status__C, acc.Id, acc.Top_Parent__c));
		}
	}

	//============================ END CONSTRUCTORS ====================================================

	//============================ PUBLIC METHODS ====================================================

	public void assessment(){
		update assessAccounts();
	}

	public list<account> forecastAssessment(){
		return assessAccounts();
	}


	//============================ END PUBLIC METHODS ====================================================

	//============================ PRIVATE METHODS ====================================================

	private list<account> assessAccounts(){
		list<account> AccUpdList= new list<account>();

		Map<Id, decimal> multicountryRemittancesMap = fetchMulticountryHierarchyRemittances();

		for(string accKey:accCalcMap.keySet()){ // iterate Accounts
			AccHelperClass acct = accInfoMap.get(accKey);
			//Skip incorrect updates of HE risk fields on child accounts
			//We should only update those fields on top parent locations
			if(acct.topParent != NULL){
				continue;
			}
			Account updAcc=new Account(id=accKey);
			AccUpdList.add(updAcc);
			map<id,integer> groupingMap = accCalcMap.get(accKey);
			updAcc.ANG_HE_RiskHistoryAssessment__c=calculateRiskHistoryAssessment(groupingMap, acct, multicountryRemittancesMap);
			updAcc.ANG_HE_CashCondition__c=calculateCashCondition(accKey);
			updAcc.Financial_Review_Result__c=acct.financialReviewResult;
		}
		ANG_Risk_Helper.updateRiskStatus(AccUpdList);
		for(account a : AccUpdList) a.ANG_HE_CashCondition__c = a.ANG_Limit_Cash_Condition__c || accInfoMap.get(a.id).hasCashCondition;

		return AccUpdList;
	}

	private String calculateRiskHistoryAssessmentMulticountry(map<id,integer> groupingMap, AccHelperClass acct, Map<Id, decimal> multicountryRemittancesMap){

		Boolean processAdjustedOnly = true;

		// Process first all the rules except Adjusted Only
		for(string reRec: groupingMap.keySet()){

			integer accParentOccs = groupingMap.get(reRec);

			if(ANG_RiskAssessmentEngine.risCalcMap.containsKey(reRec)){

				if(accParentOccs >= ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Occurrence_Num__c){
					return ANG_Risk_Helper.RISK_ASSESSMENT_FAILED;
				}
				else if(ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Adjustments__r.size() > 0 && accParentOccs > 0){
					System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - calculateRiskHistoryAssessment] Multicountry - Processing Mixed Risk Events');
					ANG_Agency_Risk_Calculation__c arc = riskCalcRulesMulticountryMap.get(ANG_Risk_Helper.ADJ_MIXED);
					if(isMulticountryRiskAssessmentFailed(acct, arc, multicountryRemittancesMap)){
						return ANG_Risk_Helper.RISK_ASSESSMENT_FAILED;
					}
					processAdjustedOnly = false;
				}
			}

		}

		if(processAdjustedOnly){
			//Process the adjusted only rules
			for(string reRec: groupingMap.keySet()){

				integer accParentOccs = groupingMap.get(reRec);

				if(risCalAdjcMap.containsKey(reRec) && risCalAdjcMap.get(reRec).ANG_Adjustments__r.size() > 0 && accParentOccs > 0){

					System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - calculateRiskHistoryAssessment] Multicountry - Processing Adjusted Only Risk Events');
					ANG_Agency_Risk_Calculation__c arc = riskCalcRulesMulticountryMap.get(ANG_Risk_Helper.ADJ_YES);
					if(isMulticountryRiskAssessmentFailed(acct, arc, multicountryRemittancesMap)){
						return ANG_Risk_Helper.RISK_ASSESSMENT_FAILED;
					}

				}

			}
		}

		return ANG_Risk_Helper.RISK_ASSESSMENT_PASSED;

	}

	private String calculateRiskHistoryAssessment(map<id,integer> groupingMap, AccHelperClass acct, Map<Id, decimal> multicountryRemittancesMap){

		String result = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED;

		if(groupingMap==null){
			return result;
		}

		if(acct.accreditationModel == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY){
			return calculateRiskHistoryAssessmentMulticountry(groupingMap, acct, multicountryRemittancesMap);
		}

		for(string reRec: groupingMap.keySet()){ // iterate groupings
			integer accParentOccs=groupingMap.get(reRec);
			if(ANG_RiskAssessmentEngine.risCalcMap.containsKey(reRec)){ //validate REC
				if( accParentOccs>=ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Occurrence_Num__c){ // if fails assessment
					result=ANG_Risk_Helper.RISK_ASSESSMENT_FAILED;
					break;
				}else if(ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Adjustments__r.size()>0){

					for(ang_agency_risk_calculation__c arca: ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Adjustments__r){
						if(arca.ANG_Remittance_Frequency__c== acct.remitanceFrequency && arca.ANG_Parent_Occurences__c ==accParentOccs && arca.ANG_Occurrence_Num__c <= acct.nrAdjustedRE){
							result=ANG_Risk_Helper.RISK_ASSESSMENT_FAILED;
							breakCicle=true;
							break;
						}
					}

				}
				if(breakCicle){ // break cicle since account already failed assessment
					breakCicle=false;
					break;
				}
			}
			if(risCalAdjcMap.containsKey(reRec) && risCalAdjcMap.get(reRec).ANG_Adjustments__r.size()>0 ){ //validate adjusted REC

				for(ang_agency_risk_calculation__c arca: risCalAdjcMap.get(reRec).ANG_Adjustments__r){
					if(arca.ANG_Remittance_Frequency__c==acct.remitanceFrequency && arca.ANG_Occurrence_Num__c <= acct.nrAdjustedRE){
						result=ANG_Risk_Helper.RISK_ASSESSMENT_FAILED;
						breakCicle=true;
						break;
					}

				}

				if(breakCicle){ // break cicle since account already failed assessment
					breakCicle=false;
					break;
				}

			}
		}
		return result;
	 }


	private boolean calculateCashCondition(id accId){
		return accInfoMap.get(accId).hasCashCondition||accInfoMap.get(accId).hasLimitCashCondition;
	}

	private Map<Id, decimal> fetchMulticountryHierarchyRemittances(){

		Set<Id> accountIdSet = new Set<Id>();

		for(Id acctId : accInfoMap.keySet()){
			AccHelperClass acct = accInfoMap.get(acctId);
			if(acct.accreditationModel == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY){
				if(acct.topParent != NULL){
					accountIdSet.add(acct.topParent);
				}
				else {
					accountIdSet.add(acctId);
				}
			}
		}

		if(accountIdSet.isEmpty()){
			return new Map<Id, decimal>();
		}

		List<Account> acctLst = new List<Account>(
			[SELECT
				Id,
				Top_Parent__c,
				Location_Type__c,
				Remittance_Frequency__c
			 FROM Account
			 WHERE
				 (Id IN :accountIdSet OR Top_Parent__c IN :accountIdSet)
			 AND RecordType.DeveloperName = 'IATA_Agency'
			 AND Location_Type__c IN (:AMS_Utils.GE, :AMS_Utils.HE)
			 AND Status__c <> NULL
			 AND Status__c NOT IN (
				 '',
				 :AMS_Utils.ACC_S0_TERMINATED,
				 :AMS_Utils.ACC_S1_NOTACCREDITED,
				 :AMS_Utils.ACC_S3_NOTINOPERATION,
				 :AMS_Utils.ACC_S4_LISTED,
				 :AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING
			 )
			]
		);

		Map<Id, decimal> remittancesPerHierarchy = new Map<Id, decimal>();

		for(Account acct : acctLst){
			decimal nbrOfRemittances = 0;

			if(String.isNotBlank(acct.Remittance_Frequency__c)){
				nbrOfRemittances = nbrOfRemittancesPerFrequencyMap.get(acct.Remittance_Frequency__c);
			}

			Id acctId = acct.Top_Parent__c != NULL ? acct.Top_Parent__c : acct.Id;

			decimal currentRemittances = remittancesPerHierarchy.get(acctId);

			if(currentRemittances == NULL){
				currentRemittances = 0;
			}

			remittancesPerHierarchy.put(acctId, currentRemittances + nbrOfRemittances);
		}

		return remittancesPerHierarchy;

	}

	/**
	 * Verifies if the risk assessment for multicountry agents should fail
	 * considering the total number of remittances on each hierarchy and
	 * the configuration agency risk calculation rules
	 *
	 * @param  acct                    agency wrapper containing account info
	 * @param  arc                     agency risk calculation rule config record
	 * @param  remittancesPerHierarchy total number of remittances per hierarchy (aggregated by top parent)
	 * @return                         true if the assessment should be "Passed" or false if "Failed"
	 */
	private Boolean isMulticountryRiskAssessmentFailed(AccHelperClass acct, ANG_Agency_Risk_Calculation__c arc, Map<Id, decimal> remittancesPerHierarchy){

		integer occurrences = acct.nrAdjustedRE;

		Id accountId = acct.acctId;
		if(acct.TopParent != NULL){
			accountId = acct.topParent;
		}

		decimal nbrOfRemitances = remittancesPerHierarchy.get(accountId);

		System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] AccountId: ' + accountId);
		System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Number of remittances: ' + nbrOfRemitances);

		if(arc.ANG_RF_Sum_Type__c == APPLY_CEILING_SUM){
			System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Sum Type RF: ' + APPLY_CEILING_SUM);

			decimal calcRes = (nbrOfRemitances * 0.0075).setScale(4);

			System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] calcRes: ' + calcRes);

			//Fails if the calculated number (calcRes) is less than 3
			//and there were at least 3 RE occurrences
			if(calcRes < 3 && occurrences >= 3){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Assessment Failed on condition \'calcRes < 3 && occurrences >= 3\'');
				return true;
			}
			//Passes if at most there were 2 RE occurrences and
			//the calculated number (calcRes) is less than 3
			else if(calcRes < 3){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Assessment Passed on condition \'calcRes < 3\'');
				return false;
			}
			//Fails if the calculated number (calcRes) is greater than 120
			//and there were more than 120 RE occurrences
			else if(calcRes > 120 && occurrences > 120){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Assessment Failed on condition \'calcRes > 120 && occurrences > 120\'');
				return true;
			}
			//Passes if at most there were 120 RE occurrences and
			//the calculated number (calcRes) is greater than 120
			else if(calcRes > 120){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Assessment Passed on condition \'calcRes > 120\'');
				return false;
			}
			//Otherwise fails if the number of occurences
			//are greater or equal to the ceiling of the calculated number (calcRes)
			else if(occurrences >= Math.ceil(calcRes)){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Assessment Failed on condition \'occurrences >= Math.ceil(calcRes)\'');
				return true;
			}

		}
		else if(arc.ANG_RF_Sum_Type__c == APPLY_SUM_ONLY){
			for(ANG_Agency_Risk_Calculation__c arcAdj : arc.ANG_Adjustments__r){
				if(arcAdj.ANG_Min_Range__c <= nbrOfRemitances && arcAdj.ANG_Max_Range__c >= nbrOfRemitances){
					System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Considering configuration range [' + arcAdj.ANG_Min_Range__c + ':' +  arcAdj.ANG_Max_Range__c + ']');
					if(occurrences >= arcAdj.ANG_Occurrence_Num__c){
						System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - isMulticountryRiskAssessmentFailed] Assessment Failed on condition \'occurrences >= arcAdj.ANG_Occurrence_Num__c\'');
						return true;
					}
				}
			}
		}

		return false;

	}

	 //============================ END PRIVATE METHODS ====================================================
 }
