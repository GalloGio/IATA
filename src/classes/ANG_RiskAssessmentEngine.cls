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

    public ANG_RiskAssessmentEngine(map<id,Map<id,integer>> AccMap){
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
            for(string reRec: groupingMap.keySet()){ // iterate groupings
                accParentOccs=groupingMap.get(reRec);                
                if(risCalcMap.containsKey(reRec)){ //validate REC
                    if( accParentOccs>=risCalcMap.get(reRec).ANG_Occurrence_Num__c){ // if fails assessment
                        updAcc.ANG_HE_RiskHistoryAssessment__c='Failed';
                        break;
                    }else if(risCalcMap.get(reRec).ANG_Adjustments__r.size()>0){                        
                        for(ang_agency_risk_calculation__c arca: risCalcMap.get(reRec).ANG_Adjustments__r){
                            if(arca.ANG_Remittance_Frequency__c==accInfoMap.get(accKey).get('remittance_frequency__c') && arca.ANG_Parent_Occurences__c ==accParentOccs && arca.ANG_Occurrence_Num__c <= accInfoMap.get(accKey).All_Risk_Events__r.size()){
                                updAcc.ANG_HE_RiskHistoryAssessment__c='Failed';
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
                            if(arca.ANG_Remittance_Frequency__c==accInfoMap.get(accKey).get('remittance_frequency__c') && arca.ANG_Occurrence_Num__c <= accInfoMap.get(accKey).All_Risk_Events__r.size()){
                                updAcc.ANG_HE_RiskHistoryAssessment__c='Failed';      
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
            AccUpdList.add(updAcc);  
        }
        update AccUpdList;
    }
}