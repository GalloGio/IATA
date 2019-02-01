public with sharing class ANG_ProgressBarHelper {

    private static final String PROGRESS = 'inProgress';
    private static final String DONE = 'done';
    private static final String NOT_DONE = 'notDone';
    private static final String ERROR = 'error';

    public List<ANG_ProgressNode> progressNodes{get; set;}
    public ANG_ProgressNode selectedNode{get;set;}

    public ANG_ProgressBarHelper(String recordType, Id sobjectId) {

        recordType = '%' + recordType + '%';

        List<ANG_ProgressBarSetting__mdt> settings = [
            SELECT MasterLabel,
                RecordType__c,
                Description__c,
                ValueProgress__c,
                ValueOk__c,
                ValueError__c,
                Is_Visible__c,
                Order__c
            FROM ANG_ProgressBarSetting__mdt
            WHERE RecordType__c LIKE : recordType
            ORDER BY Order__c ASC];

        progressNodes = new List<ANG_ProgressNode>();

        for(ANG_ProgressBarSetting__mdt setting : settings) {

            if(setting.Is_Visible__c==null || processStatus(setting.Is_Visible__c, sobjectId)) {

                Boolean isDone = false;
                Boolean isError = false;
                Boolean isProgress = processStatus(setting.ValueProgress__c, sobjectId);

                if(!isProgress) {
                    isDone = processStatus(setting.ValueOk__c, sobjectId);
                }

                if(!isProgress && !isDone) {
                    isError = processStatus(setting.ValueError__c, sobjectId);
                }

                String status;
                if(isProgress) {
                    status = PROGRESS;
                } else if(isDone) {
                    status = DONE;
                } else if(isError) {
                    status = ERROR;
                } else {
                    status = NOT_DONE;
                }

                ANG_ProgressNode node =
                    new ANG_ProgressNode(setting.MasterLabel, setting.Description__c, status, setting.Order__c);
                progressNodes.add(node);

                // Select first node in progress
                if(this.selectedNode==null && status==PROGRESS) {
                    this.selectedNode = node;
                }

            }
        }
    }

    private Boolean processStatus(String condition, Id sobjectId) {
        String query = 'SELECT Id'
        + ' FROM ' + sobjectId.getSobjectType()
        + ' WHERE Id = \'' + sobjectId + '\'';
        if (!String.isEmpty(condition)) {
            query += ' AND (' + condition + ')';
        }
        try {
            List<sObject> listResult = Database.query(query);
            return !listResult.isEmpty();
        } catch (Exception e) {
            System.debug('processStatus returned false because there was an error in the query: ' + query);
            return false;
        }
    }
}