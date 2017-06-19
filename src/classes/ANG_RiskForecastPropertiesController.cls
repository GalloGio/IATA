public with sharing class ANG_RiskForecastPropertiesController {

    public Case myCase{get;set;}

    public String riskOpt{get; set;}

    public String newRiskStatus{get;set;}

    public Boolean newCashCondition{get;set;}

    //Case Record Types
    public static final String SIDRA      = Schema.Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('SIDRA').getRecordTypeId();
    public static final String SIDRALITE   = Schema.Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('SIDRA Lite').getRecordTypeId();

    public Boolean displayPopup {get;set;}

    public ANG_RiskForecastPropertiesController(ApexPages.StandardController stdController) {
        this.myCase = (Case)stdController.getRecord();
        riskOpt = null;

        this.myCase = [Select Id, Account.Name,Account.Remittance_frequency__c, Account.Financial_Review_Result__c, Account.ANG_CashCondition__c, Account.ANG_RiskStatus__c, recordTypeId from Case where Id =:myCase.Id];
    }

    public list<selectoption> getriskOption(){

                list<selectoption> options= new list<selectoption>();

                options.add(new selectoption('Select Risk Option', 'Select Risk Option'));

                if(myCase.recordTypeId == SIDRALITE){

                    options.add(new selectoption('1','Fail Financial Statements'));
                    options.add(new selectoption('6','Unreported change (owner or legal)'));
                    options.add(new selectoption('9','Fail Financial Security'));
                    options.add(new selectoption('10','Common ownership default'));
                    options.add(new selectoption('11','Prejudiced collection'));
                
                }

                if(myCase.recordTypeId == SIDRA){

                    options.add(new selectoption('2','Late/Short payment'));
                    options.add(new selectoption('3','Wrong currency payment'));
                    options.add(new selectoption('4','Payment Default'));
                
                }

                return options;

        }

    public boolean getcanExecuteForecast(){

        return riskOpt != null && riskOpt != 'Select Risk Option';

    }

    public void doStuff(){
            // get riskOpt value and forecast risk
            
            System.debug('Doing stuff !!');

            newCashCondition = myCase.Account.ANG_CashCondition__c ? true : fetchCashCondition(riskOpt);

            List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Created_from__c, ANG_Event_Status__c, ANG_Expiration_Date__c, ANG_expiration_date_ff__c, ANG_Expired__c, ANG_HE_AccountId__c, ANG_Account_IATA_Code__c, ANG_Issued_Date__c, ANG_Manual__c, ANG_Name_Link_FF__c, ANG_Source__c, ANG_CaseId__c, ANG_ChangeCode__c, ANG_Source_Id__c, ANG_OscarId__c, ANG_Risk_Type__c, ANG_Risk_ID__c, ANG_UniqueKey__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c = :myCase.AccountId];

            String riskHistoryAssessment = fetchRiskHistoryAssessment(myCase.Account,riskOpt,riskEvents);

            newRiskStatus = fetchRiskStatus(myCase.Account.Financial_Review_Result__c, riskHistoryAssessment);
            
            System.debug('New cashCondition:'+newCashCondition);
            System.debug('New newRiskStatus:'+newRiskStatus);

    }

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

    /*

            2) necessitamos de ter o "novo" ANG_Risk_History_Assessment__c baseado no valor do riskOpt  e de todos os Risk Events que estão atualmente na conta.
            3) com o "novo" valor do ANG_Risk_History_Assessment__c e com o valor da conta atual (account.Financial_Review_Result__c) usar um metodo baseado no ANG_AccountTriggerHandler.updateRiskStatus e recuperar o novo ANG_HE_RiskStatus__c.
            2) enquanto esperamos pelo metodo, vamos usar o valor "Failed".
    */
    public String fetchRiskHistoryAssessment(Account acct, String choosenRiskEventType, List<ANG_Agency_Risk_Event__c> riskEvents){

        return new ANG_RiskAssessmentEngine(riskEvents, acct, new list<String>{choosenRiskEventType}).forecastAssessment();

    }

    public boolean fetchCashCondition(String choosenRiskEventType){

        List<ANG_Risk_Event_Type__c> retList = [SELECT Id , Limit_Cash_conditions__c from ANG_Risk_Event_Type__c where ANG_Risk_ID__c = :choosenRiskEventType];

        if(retList.isEmpty())
            return null;
        else
            return retList.get(0).Limit_Cash_conditions__c;
    }

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