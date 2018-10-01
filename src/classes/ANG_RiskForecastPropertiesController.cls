public with sharing class ANG_RiskForecastPropertiesController {

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
        this.myCase = [SELECT Id, SIDRA_Lite_Reason__c, Account.Name, Account.ANG_CashCondition__c, Account.ANG_RiskStatus__c, RecordTypeId, Account.Location_Type__c, Account.Remittance_frequency__c, Account.ANG_Accreditation_Model__c, Account.Status__c, Account.Financial_Review_Result__c, OSCAR__r.Process__c, OSCAR__r.ANG_Type_Of_Change__c, OSCAR__r.ANG_FA_Opt_out__c, OSCAR__r.ANG_Change_Entity_Location__c FROM Case where Id =:stdController.getId()];
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
        }

        if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NEWHESTANDARD){

            options.add(new SelectOption('8','Change of Entity\'s location'));

            riskOpt = '1';
        }

        if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NEWHESTANDARD && !myCase.OSCAR__r.ANG_Change_Entity_Location__c){

            options.add(new SelectOption('1','Auth. Cash Payment'));

            riskOpt = '1';
        }

        if(myCase.RecordTypeId == AMS_Utils.RECTYPE_OSCARCOMM && myCase.OSCAR__r.Process__c == AMS_Utils.NGCHANGES){

            options.add(new SelectOption('SELECT Risk Option', 'SELECT Risk Option'));

            options.add(new SelectOption('1','Auth. Cash Payment'));
            options.add(new SelectOption('6','Major change (owner or legal)'));

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

        return options;
    }

    public boolean getcanExecuteForecast(){

        return riskOpt != null && riskOpt != 'SELECT Risk Option';

    }

    public void forecast(){
        // get riskOpt value and forecast risk
        
        System.debug('Starting forecasting for account ' + myCase.AccountId);

        List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Risk_Type__c, ANG_Risk_ID__c, ANG_Limit_Cash_Conditions__c FROM ANG_Agency_Risk_Event__c where ANG_AccountId__c = :myCase.AccountId and ANG_Event_Status__c = 'Active' ];

        Account a = new Account(id = myCase.AccountId);
        a.Location_Type__c = myCase.Account.Location_Type__c;
        a.Remittance_frequency__c = myCase.Account.Remittance_frequency__c;
        a.ANG_Accreditation_Model__c = myCase.Account.ANG_Accreditation_Model__c;
        a.Status__c = myCase.Account.Status__c;
        a.Financial_Review_Result__c = myCase.Account.Financial_Review_Result__c;


        if(riskOpt != 'OptInOut'){
            riskEvents.add(
                new ANG_Agency_Risk_Event__c(
                    ANG_Risk_Type__c=riskEventTypeMap.get(riskOpt).id,
                    ANG_Limit_Cash_Conditions__c =riskEventTypeMap.get(riskOpt).Limit_Cash_conditions__c
                )
            );
        }
        
        Map<Account,List<ANG_Agency_Risk_Event__c>> riskEventsPerAccount = new Map<Account,List<ANG_Agency_Risk_Event__c>>();
        riskEventsPerAccount.put(a,riskEvents);

        List<Account> accList = new ANG_RiskAssessmentEngine(riskEventsPerAccount).forecastAssessment();

        newCashCondition = accList.get(0).ANG_HE_CashCondition__c;
        newRiskStatus = (riskOpt == 'OptInOut' && myCase.OSCAR__r.ANG_FA_Opt_out__c == 'Opt-Out') ? 'Not Applicable' : accList.get(0).ANG_HE_RiskStatus__c;
        
        displayPopup = true;
    }
    
    public void closePopup() {
        displayPopup = false;
    }
}
