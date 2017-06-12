public class ANG_RiskAssessmentEngine{
    
    private map<id,ang_agency_risk_calculation__c> risCalcMap{ // map risk event Calculations
        get{
            if(risCalcMap==null) setMaps();
            return risCalcMap;
        }
        set;
    }

    private map<id,ang_agency_risk_calculation__c> risCalAdjcMap{ //map adjusted risk calculations
        get{
            if(risCalAdjcMap==null) setMaps();
            return risCalAdjcMap;
        }
        private set;
    }

    private void setMaps(){ // method to populate the risk event calculation maps
        risCalcMap = new map<id,ang_agency_risk_calculation__c>();
        risCalAdjcMap = new map<id,ang_agency_risk_calculation__c>();
        for(ang_agency_risk_calculation__c arc:[select id,ANG_Occurrence_Num__c,(select id,ANG_Parent_Occurences__c,ANG_Occurrence_Num__c,ANG_Remittance_Frequency__c from ANG_Adjustments__r) from ang_agency_risk_calculation__c where recordtype.name='Rules' order by ANG_Occurrence_Num__c asc]){
            if(arc.ANG_Occurrence_Num__c ==0){
                risCalAdjcMap.put(arc.id,arc);    
            }else{
                risCalcMap.put(arc.id,arc);
            }
        }
    }

    private map<id,account > accInfoMap{ //map adjusted risk calculations
        get{
            if(accInfoMap==null){
                accInfoMap = new map<id,account>();
                for(account acc:[select id,name, remittance_frequency__c,ANG_Accreditation_Model__c ,(select id from All_Risk_Events__r where  ANG_Risk_Type__r.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c ='Yes' AND ANG_Event_Status__c='Active') counter from account where id in :accCalcMap.keySet()]){
                    accInfoMap.put(acc.id,acc);
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
    private map<id,ang_risk_event_type__c> reTypeId2CalcMap{ //map adjusted risk calculations
        get{
            if(reTypeId2CalcMap==null){
                reTypeId2CalcMap = new map<id,ang_risk_event_type__c>();
                reTypeKeyId2CalcMap = new map<string,ang_risk_event_type__c>();
                for(ang_risk_event_type__c ret:[select id,ANG_Risk_ID__c,ANG_Agency_Risk_Calculation__c,ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c from ang_risk_event_type__c]){
                    reTypeId2CalcMap.put(ret.id,ret);
                    reTypeKeyId2CalcMap.put(ret.ANG_Risk_ID__c,ret);
                }
            }
            return reTypeId2CalcMap;
        }
        private set;
    }

    private map<string,ang_risk_event_type__c> reTypeKeyId2CalcMap{ //map adjusted risk calculations
        get{
            if(reTypeKeyId2CalcMap==null){
                reTypeId2CalcMap = new map<id,ang_risk_event_type__c>();
                reTypeKeyId2CalcMap = new map<string,ang_risk_event_type__c>();
                for(ang_risk_event_type__c ret:[select id,ANG_Risk_ID__c,ANG_Agency_Risk_Calculation__c,ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c from ang_risk_event_type__c]){
                    reTypeId2CalcMap.put(ret.id,ret);
                    reTypeKeyId2CalcMap.put(ret.ANG_Risk_ID__c,ret);
                }
            }
            return reTypeKeyId2CalcMap;
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
        for(AggregateResult reRec:[select ang_HE_accountid__c,ang_risk_type__r.ANG_Agency_Risk_Calculation__c calcId,count(id) counter from ang_agency_risk_event__c where ang_HE_accountid__c in :AccMap.keySet() AND ANG_Event_Status__c='Active' group by ang_HE_accountid__c,ang_risk_type__r.ANG_Agency_Risk_Calculation__c]){
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
            if(accCalcMap.containsKey(accountId) && (accInfoMap.get(accountId).get('ANG_Accreditation_Model__c')=='Legacy' ||  accInfoMap.get(accountId).get('ANG_Accreditation_Model__c')=='Cashless')){
                accCalcMap.remove(accountId);
            }

        }
    }

    public ANG_RiskAssessmentEngine(list<ANG_Agency_Risk_Event__c> reList, Account acc, list<String> newReKeyIdList){
        nrAdjustedRe=0;

        forecastAccount=acc;

        forecastCalcMap = new map<id,integer>();

        //MAP <config ID; integer>
        for(ANG_Agency_Risk_Event__c are:reList){
            if(are.ANG_Risk_Type__c==null || are.ANG_Event_Status__c!='Active')continue;
            ang_risk_event_type__c ret=(ang_risk_event_type__c)reTypeId2CalcMap.get(are.ANG_Risk_Type__c);
            id calcId=ret.ANG_Agency_Risk_Calculation__c;
            if(forecastCalcMap.containsKey(calcId)){
                Integer nOcc=(integer)forecastCalcMap.get(calcId)+1;
                forecastCalcMap.remove(calcId);
                forecastCalcMap.put(calcId,nOcc);
            }else{
                forecastCalcMap.put(calcId,1);
            }
            if(ret.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c=='Yes'){
                nrAdjustedRe+=1;
            }
        }

        for(String retKey : newReKeyIdList){
            if(!reTypeKeyId2CalcMap.containsKey(retKey))continue;
            ang_risk_event_type__c ret=(ang_risk_event_type__c)reTypeKeyId2CalcMap.get(retKey);
            id calcId=ret.ANG_Agency_Risk_Calculation__c;
            if(forecastCalcMap.containsKey(calcId)){
                Integer nOcc=(integer)forecastCalcMap.get(calcId)+1;
                forecastCalcMap.remove(calcId);
                forecastCalcMap.put(calcId,nOcc);
            }else{
                forecastCalcMap.put(calcId,1);
            }
            if(ret.ANG_Agency_Risk_Calculation__r.ANG_Adjusted__c=='Yes'){
                nrAdjustedRe+=1;
            }
        }

    }

    //============================ END CONSTRUCTORS ====================================================

    //============================ PUBLIC METHODS ====================================================

    public void assessment(){
        list<account> AccUpdList= new list<account>();
        for(string accKey:accCalcMap.keySet()){ // iterate Accounts 
            Account updAcc=new Account(id=accKey,ANG_HE_RiskHistoryAssessment__c='Passed');
            Integer accParentOccs=0;
            map<id,integer> groupingMap = accCalcMap.get(accKey);
            
            if(groupingMap==null){
                AccUpdList.add(updAcc);
                continue;
            }
            updAcc.ANG_HE_RiskHistoryAssessment__c=calculateRiskHistoryAssessment(groupingMap,(String)accInfoMap.get(accKey).get('remittance_frequency__c'),accInfoMap.get(accKey).All_Risk_Events__r.size());            
            AccUpdList.add(updAcc);  
        }
        update AccUpdList;
    }

    public String forecastAssessment(){
        return calculateRiskHistoryAssessment(forecastCalcMap,forecastAccount.Remittance_frequency__c,nrAdjustedRe);
    }

    //============================ END PUBLIC METHODS ====================================================

    //============================ PRIVATE METHODS ====================================================
     private String calculateRiskHistoryAssessment(map<id,integer> groupingMap,String remiFreq, Integer nrAdjusRe){
        String result ='Passed';
        for(string reRec: groupingMap.keySet()){ // iterate groupings
            integer accParentOccs=groupingMap.get(reRec);                
            if(risCalcMap.containsKey(reRec)){ //validate REC
                if( accParentOccs>=risCalcMap.get(reRec).ANG_Occurrence_Num__c){ // if fails assessment
                    result='Failed';
                    break;
                }else if(risCalcMap.get(reRec).ANG_Adjustments__r.size()>0){                        
                    for(ang_agency_risk_calculation__c arca: risCalcMap.get(reRec).ANG_Adjustments__r){
                        if(arca.ANG_Remittance_Frequency__c==remiFreq && arca.ANG_Parent_Occurences__c ==accParentOccs && arca.ANG_Occurrence_Num__c <= nrAdjusRe){
                            result='Failed';
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
                            result='Failed';      
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
     //============================ END PRIVATE METHODS ====================================================

}