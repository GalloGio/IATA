public class ANG_AccountTriggerHandler {

    public static Boolean isExpiration{
        get{
            if(isExpiration == null) isExpiration = false;
            return isExpiration;
        }
        set;
    }

    public static void handleBeforeInsert(List<Account> accs){

        updateRiskStatus(accs, new Map<Id,Account>(), true);

    }

    public static void handleBeforeUpdate(List<Account> accs, Map<Id,Account> oldMap){

        updateRiskStatus(accs,oldMap,false);

    }



    public static void updateRiskStatus(List<Account> accs, Map<Id,Account> oldMap, Boolean isInsert){

        Set<String> topLocationTypes = new Set<String>{AMS_Utils.HE, AMS_Utils.HO, AMS_Utils.AO};
        ID riskStatusAssessmentRT = AMS_Utils.getRecordType('ANG_Agency_Risk_Calculation__c', 'Risk_Status_Assessment').Id;

        List<ANG_Agency_Risk_Calculation__c> arcList = [SELECT Id, ANG_Financial_Review_Result__c , ANG_Risk_History_Assessment__c,ANG_Risk_History__c from ANG_Agency_Risk_Calculation__c where recordTypeId = :riskStatusAssessmentRT];
        
        Map<String,String> calculationTable = new Map<String,String>();

        For(ANG_Agency_Risk_Calculation__c arc: arcList)
            calculationTable.put(arc.ANG_Financial_Review_Result__c + arc.ANG_Risk_History_Assessment__c , arc.ANG_Risk_History__c);

        for(Account acct: accs){

        	if(!topLocationTypes.contains(acct.Location_Type__c))
        		continue;

            if(acct.ANG_Accreditation_Model__c == 'Cash' || acct.ANG_Accreditation_Model__c == null){            
                if(isInsert || hasChangedValuesAccount(oldMap.get(acct.Id), acct) )
                    acct.ANG_HE_RiskStatus__c = calculationTable.get(acct.Financial_Review_Result__c + acct.ANG_HE_RiskHistoryAssessment__c);
            }
            if(acct.ANG_Accreditation_Model__c == 'Cashless')
                acct.ANG_HE_RiskStatus__c = 'Not applicable';
        } 
    }

    // used on updateRiskStatus to determine if some values have changed.
    public static boolean hasChangedValuesAccount(Account oldValue, Account newValue){

        return oldValue.Financial_Review_Result__c <> newValue.Financial_Review_Result__c || oldValue.ANG_HE_RiskHistoryAssessment__c <> newValue.ANG_HE_RiskHistoryAssessment__c;

    }
}
