public with sharing class AWW_AccountPlanCtrl {


    @AuraEnabled
    public static Boolean getUserAccessRightsAMPIssuesAndPriorities() {
        List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN ('AMP_Issues_and_Priorities')
        ];

        if(permissions.isEmpty()) {
            return false;
        } else {
            return (permissions[0].PermissionSet.Name == 'AMP_Issues_and_Priorities' ? true : false);
        }
    }
    
    @AuraEnabled
    public static List<ObjectiveWrapper> getObjectives(Id accountId){
        List<ObjectiveWrapper> res = new List<ObjectiveWrapper>();
        for(Objective__c record : AMP_KeyAccountPlanExtension.getObjectives(accountId)) {
            res.add(new ObjectiveWrapper(record));
        }

        return res;
    }

    @AuraEnabled
    public static void upsertRecord(ObjectiveWrapper wrapper){
        Objective__c o = wrapper.convertToSFRecord();
        upsert o;
    }

    @AuraEnabled
    public static void deleteRecord(Objective__c record){
        delete record;
    }
    
    public class ObjectiveWrapper {
        @AuraEnabled public Id accountId {get;set;}
        @AuraEnabled public Id recordId {get;set;}
        @AuraEnabled public String objectiveName {get;set;}
        @AuraEnabled public String division {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public Date endDate {get;set;}
        @AuraEnabled public Id issueId {get;set;}
        @AuraEnabled public String issueName {get;set;}
        @AuraEnabled public String comments {get;set;}

        public ObjectiveWrapper() {}

        public ObjectiveWrapper(Objective__c record) {
            this.accountId = record.Account__c;
            this.recordId = record.Id;
            this.objectiveName = record.Name;
            this.division = record.Division__c;
            this.description = record.Details__c;
            this.status = record.Status__c;
            this.endDate = record.Deadline__c;
            this.issueId = record.Account_Issue_or_Priority__c;
            if(this.issueId <> null) {
                this.issueName = record.Account_Issue_or_Priority__r.Name;
            }
            this.comments = record.Benefits_to_Account__c;
        }

        public Objective__c convertToSFRecord() {
            Objective__c record = new Objective__c();
            record.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Key_Account_Plan');
            record.Account__c = this.accountId;
            record.Id = this.recordId;
            record.Name = this.objectiveName;
            record.Division__c = this.division;
            record.Details__c = this.description;
            record.Status__c = this.status;
            record.Deadline__c = this.endDate;
            record.Account_Issue_or_Priority__c = this.issueId;
            record.Benefits_to_Account__c = this.comments;
            return record;
        }
    }

}