public class ANG_RiskEventPopUpExtension {

	private final ANG_Agency_Risk_Event__c risk;

    public ANG_RiskEventPopUpExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) stdController.addFields(new List<String>{'ANG_Source_Id__c', 'ANG_Risk_Type__c', 'ANG_Issued_Date__c', 'ANG_Event_Status__c', 'ANG_Risk_Id__c'});
        this.risk = (ANG_Agency_Risk_Event__c)stdController.getRecord();
    }

    public List<ANG_Agency_Risk_Event__c> getRiskEvents() {
    	if(risk.ANG_Event_Status__c == ANG_Risk_Helper.STATUS_MIGRATED && risk.ANG_Risk_ID__c == '6') return [SELECT ANG_Name_Link_FF__c, ANG_AccountId__r.Name, ANG_AccountId__r.IATACode__c, ANG_AccountId__r.Location_Type__c FROM ANG_Agency_Risk_Event__c WHERE ANG_Issued_Date__c = :risk.ANG_Issued_Date__c AND ANG_Risk_Type__c = :risk.ANG_Risk_Type__c];
        return [SELECT ANG_Name_Link_FF__c, ANG_AccountId__r.Name, ANG_AccountId__r.IATACode__c, ANG_AccountId__r.Location_Type__c FROM ANG_Agency_Risk_Event__c WHERE ANG_Source_Id__c = :risk.ANG_Source_Id__c AND ANG_Risk_Type__c = :risk.ANG_Risk_Type__c];
    }
}
