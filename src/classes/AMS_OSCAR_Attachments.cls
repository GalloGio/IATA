global class AMS_OSCAR_Attachments {
    
    private Id oscId;
    public Case oscCase {get {
     
        if(this.oscCase == null) {
            
            ID oscarCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('OSCAR Communication');
            
            this.oscCase = [select Id from Case where OSCAR__c =: this.oscId and RecordTypeId =: oscarCaseRecordTypeID];
        }
        
        return this.oscCase;
    }set;}
     
    public AMS_OSCAR_Attachments(ApexPages.StandardController stdController) {

        this.oscId = stdController.getId();
    }
}