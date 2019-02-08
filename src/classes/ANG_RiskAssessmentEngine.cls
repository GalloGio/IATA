public class ANG_RiskAssessmentEngine{
    
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

    private static void setMaps(){ // method to populate the risk event calculation maps
        ANG_RiskAssessmentEngine.risCalcMap = new map<id,ang_agency_risk_calculation__c>();
        ANG_RiskAssessmentEngine.risCalAdjcMap = new map<id,ang_agency_risk_calculation__c>();
        for(ang_agency_risk_calculation__c arc:[select id,ANG_Occurrence_Num__c,(select id,ANG_Parent_Occurences__c,ANG_Occurrence_Num__c,ANG_Remittance_Frequency__c from ANG_Adjustments__r) from ang_agency_risk_calculation__c where recordtype.name='Rules' order by ANG_Occurrence_Num__c asc]){
            if(arc.ANG_Occurrence_Num__c ==0){
                ANG_RiskAssessmentEngine.risCalAdjcMap.put(arc.id,arc);    
            }else{
                ANG_RiskAssessmentEngine.risCalcMap.put(arc.id,arc);
            }
        }
    }

    public class accHelperClass{  //helper class to store account Info
        private integer nrAdjustedRE;
        private boolean hasCashCondition;
        private boolean hasLimitCashCondition;
        private string remitanceFrequency;
        private string accreditantionModel;
        private string financialReviewResult;
        private string status;
        public accHelperClass(Integer nAdjs, boolean hasCashCond,boolean hasLimitCashCond,String remitFreq, String accrModel, String financialReviewRes,String stats){
            nrAdjustedRE=nAdjs;
            hasCashCondition=hasCashCond;
            hasLimitCashCondition=hasLimitCashCond;
            remitanceFrequency=remitFreq;
            accreditantionModel=accrModel;
            financialReviewResult=financialReviewRes;
            status=stats;
            System.debug(loggingLevel.FINE, '____ [cls ANG_RiskAssessmentEngine - accHelperClass constructor] this - ' + this);
        }
    }

    private map<id,accHelperClass> accInfoMap{ //map adjusted risk calculations
        get{
            if(accInfoMap==null){
                accInfoMap = new map<id,accHelperClass>();
                for(account acc:[select id,name, remittance_frequency__c,ANG_Limit_Cash_Condition__c,ANG_Accreditation_Model__c,Financial_Review_Result__c,status__c,(select id,ANG_Risk_Type__r.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c,ANG_Limit_Cash_Conditions__c from All_Risk_Events__r where ANG_Event_Status__c=:Ang_Risk_Helper.STATUS_ACTIVE) from account where id in :accCalcMap.keySet()]){
                    integer nAdjs=0;
                    boolean hasCashCond=false;
                    for(ANG_Agency_Risk_Event__c are:acc.All_Risk_Events__r){
                        if(are.ANG_Risk_Type__r.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c=='Yes') nAdjs++;
                        hasCashCond=hasCashCond||are.ANG_Limit_Cash_Conditions__c;
                    }
                    accInfoMap.put(acc.id,new accHelperClass(nAdjs,hasCashCond,acc.ANG_Limit_Cash_Condition__c,acc.remittance_frequency__c,acc.ANG_Accreditation_Model__c,acc.Financial_Review_Result__c,acc.status__c));

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
            if(accCalcMap.containsKey(accountId) && (accInfoMap.get(accountId).accreditantionModel== AMS_Utils.ACCREDITATIONMODEL_LEGACY ||  accInfoMap.get(accountId).accreditantionModel==AMS_Utils.ACCREDITATIONMODEL_CASHLESS || accInfoMap.get(accountId).status== AMS_Utils.ACC_S0_TERMINATED)){
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
            accInfoMap.put(acc.id,new accHelperClass(nrAdjustedRe,hasCashCond,acc.ANG_Limit_Cash_Condition__c,acc.remittance_frequency__c,acc.ANG_Accreditation_Model__c,acc.Financial_Review_Result__c,acc.status__C));
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
        for(string accKey:accCalcMap.keySet()){ // iterate Accounts 
            Account updAcc=new Account(id=accKey);
            AccUpdList.add(updAcc);         
            map<id,integer> groupingMap = accCalcMap.get(accKey);
            updAcc.ANG_HE_RiskHistoryAssessment__c=calculateRiskHistoryAssessment(groupingMap,(String)accInfoMap.get(accKey).remitanceFrequency,accInfoMap.get(accKey).nrAdjustedRE);            
            updAcc.ANG_HE_CashCondition__c=calculateCashCondition(accKey);
            updAcc.Financial_Review_Result__c=accInfoMap.get(accKey).financialReviewResult;
        }
        ANG_Risk_Helper.updateRiskStatus(AccUpdList);
        for(account a : AccUpdList) a.ANG_HE_CashCondition__c = a.ANG_Limit_Cash_Condition__c || accInfoMap.get(a.id).hasCashCondition;
        
        return AccUpdList;  
    }
 
     private String calculateRiskHistoryAssessment(map<id,integer> groupingMap,String remiFreq, Integer nrAdjusRe){
        String result =ANG_Risk_Helper.RISK_ASSESSMENT_PASSED;
        if(groupingMap==null)return result;
        for(string reRec: groupingMap.keySet()){ // iterate groupings
            integer accParentOccs=groupingMap.get(reRec);                
            if(ANG_RiskAssessmentEngine.risCalcMap.containsKey(reRec)){ //validate REC
                if( accParentOccs>=ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Occurrence_Num__c){ // if fails assessment
                    result=ANG_Risk_Helper.RISK_ASSESSMENT_FAILED;
                    break;
                }else if(ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Adjustments__r.size()>0){                        
                    for(ang_agency_risk_calculation__c arca: ANG_RiskAssessmentEngine.risCalcMap.get(reRec).ANG_Adjustments__r){
                        if(arca.ANG_Remittance_Frequency__c==remiFreq && arca.ANG_Parent_Occurences__c ==accParentOccs && arca.ANG_Occurrence_Num__c <= nrAdjusRe){
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
            if(risCalAdjcMap.containsKey(reRec)){ //validate adjusted REC
                if(risCalAdjcMap.get(reRec).ANG_Adjustments__r.size()>0 ){
                    for(ang_agency_risk_calculation__c arca: risCalAdjcMap.get(reRec).ANG_Adjustments__r){
                        if(arca.ANG_Remittance_Frequency__c==remiFreq && arca.ANG_Occurrence_Num__c <= nrAdjusRe){
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
        }
        return result;
     }


    private boolean calculateCashCondition(id accId){
        return accInfoMap.get(accId).hasCashCondition||accInfoMap.get(accId).hasLimitCashCondition;
    }
     //============================ END PRIVATE METHODS ====================================================
 }