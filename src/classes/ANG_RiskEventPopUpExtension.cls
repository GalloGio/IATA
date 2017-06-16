public class ANG_RiskEventPopUpExtension {

	private final ANG_Agency_Risk_Event__c risk;

    public ANG_RiskEventPopUpExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) stdController.addFields(new List<String>{'ANG_Source_Id__c', 'ANG_Risk_Type__c'});
        this.risk = (ANG_Agency_Risk_Event__c)stdController.getRecord();
    }

    public List<Account> getAccounts() {
        return [SELECT Id, Name, IATACode__c, Location_Type__c FROM Account WHERE Id IN (SELECT ANG_AccountId__c FROM ANG_Agency_Risk_Event__c WHERE ANG_Source_Id__c = :risk.ANG_Source_Id__c AND ANG_Risk_Type__c = :risk.ANG_Risk_Type__c)];
    }
}