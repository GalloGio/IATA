public with sharing class AMS_Change_Code_Notification_Controller {

	public String caseId {get; set;}
    public Case currentCase {get; set;}
    public Boolean isSidra {get; set;}
    

    public AMS_Change_Code_Notification_Controller(ApexPages.StandardController stdController) {
        caseId = stdController.getId(); 
        isSidra = false;

        list<Case> lstCases = [SELECT Id, RecordType.DeveloperName, OSCAR__c FROM Case WHERE Id = :caseId];
        if (!lstCases.isEmpty()) {
            currentCase = lstCases[0];

            if (currentCase.RecordType.DeveloperName == 'SIDRA' || currentCase.RecordType.DeveloperName == 'SIDRA_Lite') 
                isSidra = true;
        }


    }

    public void setNotificationMessage() {

        list<Case> lstCases = [SELECT Id, RecordType.DeveloperName, OSCAR__c FROM Case WHERE Id = :caseId];

        if (currentCase != null) {
            list<Agency_Applied_Change_code__c> lstRecentChangeCodes = new list<Agency_Applied_Change_code__c>();
            Datetime dateRange = Datetime.now().addMinutes(-1);
            Boolean isOscar = false;

            if (currentCase.RecordType.DeveloperName == 'OSCAR_Communication' && currentCase.OSCAR__c != null) {
                // OSCAR Communication Cases - change code linked to the oscar
                lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE OSCAR__c = :currentCase.OSCAR__c AND CreatedDate > :dateRange];
                isOscar = true;

            } else if (currentCase.RecordType.DeveloperName == 'SIDRA' || currentCase.RecordType.DeveloperName == 'SIDRA_Lite') {
                // SIDRA Cases - change code linked to the case
                lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE SIDRA_Case__c = :currentCase.Id AND CreatedDate > :dateRange];
            }

            if (!lstRecentChangeCodes.isEmpty()) {
                String codes = '';

                map<String, Integer> mapCountPerChangeCode = new map<String, Integer>();
                for (Agency_Applied_Change_code__c cc : lstRecentChangeCodes) 
                    if (mapCountPerChangeCode.get(cc.Change_Code__c) != null)
                        mapCountPerChangeCode.put(cc.Change_Code__c, mapCountPerChangeCode.get(cc.Change_Code__c) + 1);
                    else
                        mapCountPerChangeCode.put(cc.Change_Code__c, 1);
                
                for (Agency_Applied_Change_code__c cc : lstRecentChangeCodes) {
                    if (mapCountPerChangeCode.get(cc.Change_Code__c) == 1) {
                        // create the link to the newly applied code: std hyper link for normal interface, javascript for console (the oscar is supposed to only be open in console mode)
                        codes += (codes == '' ? ' ' : ', ') + '<a href="' + (isOscar ? 'javascript:srcUp(\'' : '') + '/' + cc.Id + (isOscar ? '\');' : '') + '"' + (isOscar ? '' : ' target="_blank" ') + '>' + cc.Change_Code__c + '</a>';
                    } else if(mapCountPerChangeCode.get(cc.Change_Code__c) != null){
                        codes += (codes == '' ? ' ' : ', ') + mapCountPerChangeCode.get(cc.Change_Code__c) + ' x ' + cc.Change_Code__c;
                        // prevent from being displayed again next time the script iterates over the same change code in the list
                        mapCountPerChangeCode.put(cc.Change_Code__c, null);
                    }
                }



                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AMS_New_Change_Code_Notification + codes));

            } else {
                // check if we need to show any aditional notification
                List<Technical_Logs__c> notifications = [SELECT Id, Record__c, Log__c FROM Technical_Logs__c WHERE Record__c LIKE :caseId+'%' AND CreatedDate > :dateRange ORDER BY CreatedDate DESC];

                if(!notifications.isEmpty()){
                    String message = ''; 
                    for(Integer i = 0; i < notifications.size(); i++){
                        message += (i == 0 ? '' :' and ')+notifications[i].Log__c; 
                    }
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message+(notifications.size()>1?' were ' : ' was ')+'not generated, please issue Notice of Termination'));

                    //clean log records
                    delete notifications;
                }
            }
        }

    }


}