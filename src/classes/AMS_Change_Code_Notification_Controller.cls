public with sharing class AMS_Change_Code_Notification_Controller {

	public String caseId {get; set;}

    public AMS_Change_Code_Notification_Controller(ApexPages.StandardController stdController) {
        caseId = stdController.getId(); //ApexPages.currentPage().getParameters().get('Id');
    }

    public void setNotificationMessage() {

        list<Case> lstCases = [SELECT Id, RecordType.DeveloperName, OSCAR__c FROM Case WHERE Id = :caseId];

        if (!lstCases.isEmpty()) {
            list<Agency_Applied_Change_code__c> lstRecentChangeCodes = new list<Agency_Applied_Change_code__c>();
            Datetime dateRange = Datetime.now().addMinutes(-1);
            Boolean isOscar = false;

            if (lstCases[0].RecordType.DeveloperName == 'OSCAR_Communication' && lstCases[0].OSCAR__c != null) {
                // OSCAR Communication Cases - change code linked to the oscar
                lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE OSCAR__c = :lstCases[0].OSCAR__c AND CreatedDate > :dateRange];
                isOscar = true;

            } else if (lstCases[0].RecordType.DeveloperName == 'SIDRA' || lstCases[0].RecordType.DeveloperName == 'SIDRA_Lite') {
                // SIDRA Cases - change code linked to the case
                lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE SIDRA_Case__c = :lstCases[0].Id AND CreatedDate > :dateRange];
            }

            if (!lstRecentChangeCodes.isEmpty()) {
                String codes = '';

                for (Agency_Applied_Change_code__c cc : lstRecentChangeCodes) {
                    // create the link to the newly applied code: std hyper link for normal interface, javascript for console (the oscar is supposed to only be open in console mode)
                    codes += (codes == '' ? '' : ', ') + '<a href="' + (isOscar ? 'javascript:srcUp(\'' : '') + '/' + cc.Id + (isOscar ? '\');' : '') + '"' + (isOscar ? '' : ' target="_blank" ') + '>' + cc.Change_Code__c + '</a>';
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AMS_New_Change_Code_Notification + codes));
            }
        }

    }
}