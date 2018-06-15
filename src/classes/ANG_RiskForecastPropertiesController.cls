public with sharing class ANG_RiskForecastPropertiesController {

    public Case myCase{get;set;}

    public String riskOpt{get; set;}

    public String newRiskStatus{get;set;}

    public Boolean newCashCondition{get;set;}

    public map<string,ang_risk_event_type__c> riskEventTypeMap{
        get{
            if(riskEventTypeMap == null){
                riskEventTypeMap= new map<string,ang_risk_event_type__c>();
                for(ang_risk_event_type__c ret :[select id,ANG_Risk_ID__c,Limit_Cash_conditions__c from ang_risk_event_type__c])
                    riskEventTypeMap.put(ret.ANG_Risk_ID__c,ret);
            }
            return riskEventTypeMap;
        }
        set;
    }

    public Boolean displayPopup {get;set;}

    public ANG_RiskForecastPropertiesController(ApexPages.StandardController stdController) {
        this.myCase = (Case)stdController.getRecord();
        riskOpt = null;

        this.myCase = [Select Id, SIDRA_Lite_Reason__c, Account.Name, Account.ANG_CashCondition__c, Account.ANG_RiskStatus__c, RecordTypeId, Account.Location_Type__c, Account.Remittance_frequency__c, Account.ANG_Accreditation_Model__c, Account.Status__c, Account.Financial_Review_Result__c, OSCAR__r.Process__c, OSCAR__r.ANG_Type_Of_Change__c from Case where Id =:myCase.Id];
    }

    public list<selectoption> getriskOption(){

                list<selectoption> options= new list<selectoption>();

                options.add(new selectoption('Select Risk Option', 'Select Risk Option'));

                if(myCase.RecordTypeId == AMS_Utils.RECTYPE_SIDRALITE){

                    options.add(new selectoption('5','Fail Financial Statements'));
                    options.add(new selectoption('7','Unreported Major Change'));
                    options.add(new selectoption('9','Fail Financial Security'));
                    options.add(new selectoption('10','Common ownership default'));
                    options.add(new selectoption('11','Prejudiced collection'));

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

                    options.add(new selectoption('2','Late/Short payment'));
                    options.add(new selectoption('3','Wrong currency payment'));
                    options.add(new selectoption('4','Payment Default'));
                
                }

                if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NEWHESTANDARD){

                    options.add(new selectoption('1','Auth. Cash Payment'));

                    riskOpt = '1';
                
                }

                if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NGCHANGES){

                    options.add(new selectoption('1','Auth. Cash Payment'));
                    options.add(new selectoption('6','Major change (owner or legal)'));

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

                return options;

        }

    public boolean getcanExecuteForecast(){

        return riskOpt != null && riskOpt != 'Select Risk Option';

    }

    public void doStuff(){
            // get riskOpt value and forecast risk
            
            System.debug('Starting forecasting for account ' + myCase.AccountId);

            List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Created_from__c, ANG_Event_Status__c, ANG_Expiration_Date__c, ANG_expiration_date_ff__c, ANG_Expired__c, ANG_HE_AccountId__c, ANG_Account_IATA_Code__c, ANG_Issued_Date__c, ANG_Manual__c, ANG_Name_Link_FF__c, ANG_Source__c, ANG_CaseId__c, ANG_ChangeCode__c, ANG_Source_Id__c, ANG_OscarId__c, ANG_Risk_Type__c, ANG_Risk_ID__c, ANG_UniqueKey__c, ANG_Risk_Type__r.ANG_Risk_ID__c,ANG_Limit_Cash_Conditions__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c = :myCase.AccountId and ANG_Event_Status__c = 'Active' ];

            Account a = new Account(id = myCase.AccountId);
            a.Location_Type__c = myCase.Account.Location_Type__c;
            a.Remittance_frequency__c = myCase.Account.Remittance_frequency__c;
            a.ANG_Accreditation_Model__c = myCase.Account.ANG_Accreditation_Model__c;
            a.Status__c = myCase.Account.Status__c;
            a.Financial_Review_Result__c = myCase.Account.Financial_Review_Result__c;

            Map<Account,List<ang_agency_risk_event__c>> mapAccountListStuff = new Map<Account,List<ang_agency_risk_event__c>>();

            riskEvents.add(
                new ANG_Agency_Risk_Event__c(
                    ANG_Risk_Type__c=riskEventTypeMap.get(riskOpt).id,
                    ANG_Limit_Cash_Conditions__c =riskEventTypeMap.get(riskOpt).Limit_Cash_conditions__c
                )
            );
            mapAccountListStuff.put(a,riskEvents);

            list<account> acclist = new ANG_RiskAssessmentEngine(mapAccountListStuff).forecastAssessment();

            newCashCondition = acclist.get(0).ANG_HE_CashCondition__c;
            newRiskStatus = acclist.get(0).ANG_HE_RiskStatus__c;

            System.debug('New cashCondition:'+newCashCondition);
            System.debug('New newRiskStatus:'+newRiskStatus);

    }

    
    /*
    public static String fetchRiskStatus(String financialReviewResult, String riskHistoryAssessment){

        ID riskStatusAssessmentRT = AMS_Utils.getRecordType('ANG_Agency_Risk_Calculation__c', 'Risk_Status_Assessment').Id;

        List<ANG_Agency_Risk_Calculation__c> arcList = [SELECT Id, ANG_Financial_Review_Result__c , ANG_Risk_History_Assessment__c,ANG_Risk_History__c from ANG_Agency_Risk_Calculation__c where recordTypeId = :riskStatusAssessmentRT];
        
        Map<String,String> calculationTable = new Map<String,String>();

        For(ANG_Agency_Risk_Calculation__c arc: arcList)
            calculationTable.put(arc.ANG_Financial_Review_Result__c + arc.ANG_Risk_History_Assessment__c , arc.ANG_Risk_History__c);

        System.debug('Fetching Risk history with values ' + financialReviewResult + ' and ' + riskHistoryAssessment);

        String toReturn = calculationTable.get(financialReviewResult + riskHistoryAssessment);

        System.debug('Returning ' + toReturn);
        
        return toReturn;

    }
    */

    /*
    public String fetchRiskHistoryAssessment(Account acct, String choosenRiskEventType, List<ANG_Agency_Risk_Event__c> riskEvents){

        return new ANG_RiskAssessmentEngine(riskEvents, acct, new list<String>{choosenRiskEventType}).forecastAssessment();

    }
    */

    /*
    public boolean fetchCashCondition(String choosenRiskEventType){

        List<ANG_Risk_Event_Type__c> retList = [SELECT Id , Limit_Cash_conditions__c from ANG_Risk_Event_Type__c where ANG_Risk_ID__c = :choosenRiskEventType];

        if(retList.isEmpty())
            return null;
        else
            return retList.get(0).Limit_Cash_conditions__c;
    }*/

    public void showPopup(){
        
        displayPopup = true;
        doStuff();
    
    }
    
    public void closePopup() {
        displayPopup = false;
        
    }
    
    public PageReference redirectPopup(){
        displayPopup = false;
        
        return null;        
    }
}