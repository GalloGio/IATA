public with sharing class ANG_ProgressBarHelper {

    private static final String PROGRESS = 'inProgress';
    private static final String DONE = 'done';
    private static final String NOT_DONE = 'notDone';
    private static final String ERROR = 'error';

    public List<ANG_ProgressNode> progressNodes{get; set;}
    public ANG_ProgressNode selectedNode{get;set;}

    public ANG_ProgressBarHelper(Case cse) {
        this.progressNodes = new List<ANG_ProgressNode>();

        ANG_ProgressBarSetting__mdt setting = getProgressBarSetting(cse);
        if (setting==null) {
            System.debug('ANG_ProgressBarHelper: No valid ANG_ProgressBarSetting__mdt found.');
            return;
        }

        System.debug('ANG_ProgressBarHelper: Using setting ' + setting);
        list<ANG_ProgressBarStep__mdt > listSteps = [
            SELECT MasterLabel,
                   Description__c,
                   ValueProgress__c,
                   ValueOk__c,
                   ValueError__c,
                   IconProgress__c,
                   IconOk__c,
                   IconError__c,
                   IconNotDone__c,
                   Is_Visible__c,
                   Order__c
            FROM ANG_ProgressBarStep__mdt
            WHERE Parent__c = :setting.Id
            ORDER BY Order__c ASC];

        for(ANG_ProgressBarStep__mdt step : listSteps) {
            System.debug('ANG_ProgressBarHelper: Processing step ' + step);

            if(step.Is_Visible__c==null || processStatus(step.Is_Visible__c, cse.Id)) {

                Boolean isDone = false;
                Boolean isError = false;
                Boolean isProgress = processStatus(step.ValueProgress__c, cse.Id);

                if(!isProgress) {
                    isDone = processStatus(step.ValueOk__c, cse.Id);
                }

                if(!isProgress && !isDone) {
                    isError = processStatus(step.ValueError__c, cse.Id);
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
                    new ANG_ProgressNode(step, status);
                this.progressNodes.add(node);

                // Select first node in progress
                if(this.selectedNode==null && status==PROGRESS) {
                    this.selectedNode = node;
                }

            }
        }
    }

    /**
        Finds the Progress bar setting matching the input case, if exists
    **/
    private ANG_ProgressBarSetting__mdt getProgressBarSetting(Case cse) {
        list<ANG_ProgressBarSetting__mdt> listSetting =[
            SELECT Id, Condition__c
            FROM ANG_ProgressBarSetting__mdt
            WHERE RecordType__c = :cse.RecordType.DeveloperName];

        for (ANG_ProgressBarSetting__mdt setting: listSetting) {
            String query = 'SELECT Id FROM Case WHERE Id=\'' + cse.Id + '\'';
            if (setting.Condition__c!=null) {
                query+= ' AND ' + setting.Condition__c;
            }
            System.debug('Test Setting ' + setting + ' with query: ' + query);
            List<sObject> listResult = Database.query(query);
            if (!listResult.isEmpty()) return setting;
        }
        return null;
    }

    /**
        Executes a condition for a specific step
    **/
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