public with sharing class AMS_InspectionNotificationController {

	public AMS_Inspection__c appointment;
    public Boolean hasNoActiveInspections {get; set;} // just for test assertion purposes

    // Test coverage: AMS_InspectionHelperTest.test_checkActiveAppointments
    
    public AMS_InspectionNotificationController(ApexPages.StandardController stdController) {
        this.appointment = (AMS_Inspection__c)stdController.getRecord();
        appointment = [SELECT Id, Account__c, Account__r.Name, Account__r.Status__c FROM AMS_Inspection__c WHERE Id = :appointment.Id];
        hasNoActiveInspections = false;
    }

    public void setNotificationMessage() {
        list<AMS_Inspection__c> lstActiveInspections = [SELECT Id FROM AMS_Inspection__c WHERE Account__c = :appointment.Account__c AND Accreditation_Endorsement_Status_code__c <> '0'];

        if (lstActiveInspections.isEmpty() && appointment.Account__r.Status__c != 'Terminated') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The "' + appointment.Account__r.Name + '" agent has no active appointments left. Please terminate it.'));
            hasNoActiveInspections = true;
        }
    }
}