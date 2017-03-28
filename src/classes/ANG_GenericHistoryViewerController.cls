public with sharing class ANG_GenericHistoryViewerController {

    public SObject trackedObj {get;set;}

    public String trackerObjApiName {get;set;}

    public String trackedObjApiName {get;set;}

    public List<GenericHistoryWrapper> mergedHistoric {get;set;}

    public ANG_GenericHistoryViewerController() {

    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ANG_GenericHistoryViewerController(ApexPages.StandardController stdController) {
        this.trackedObj = (sObject)stdController.getRecord();
    }

    public String getRecordName() {
        return 'Hello ' + (String)trackedObj.get('name') + ' (' + (Id)trackedObj.get('Id') + ')';
    }

    public List<GenericHistoryWrapper> getHistoryRecords(){

        String theCustomQuery = 'SELECT CreatedDate, CreatedById, CreatedBy.Name, What__c, New_Value__c, Old_Value__c FROM ' + trackerObjApiName + ' WHERE ' + trackedObjApiName + '__c = \'' + trackedObj.Id + '\' ORDER BY CreatedDate DESC';
        System.debug('Custom history query ' + theCustomQuery);

        //TODO: NEED TO REFINE THIS QUERY TO MAKE IT WORK FOR CUSTOM OBJECTS AS WELL, HISTORY TABLE IS DIFFERENTLY NAMED
        String theStandardQuery = 'SELECT CreatedDate, CreatedById, CreatedBy.Name, Field, NewValue, OldValue FROM ' + trackedObjApiName + 'History WHERE ' + trackedObjApiName + 'Id = \'' + trackedObj.Id + '\' ORDER BY CreatedDate DESC';
        System.debug('Standard history query ' + theStandardQuery);

        List<SObject> customHistoryRecords = database.query(theCustomQuery);
        List<SObject> standardHistoryRecords = database.query(theStandardQuery);

        Set<Id> userIds = new Set<Id>();

        //need to query all the user names
        Map<Id, String> mapUserNamesPerId = new Map<Id, String>();
        for(SObject customHist : customHistoryRecords)
            userIds.add((Id)customHist.get('CreatedById'));

        for(SObject standardHist : standardHistoryRecords)
            userIds.add((Id)standardHist.get('CreatedById'));
        

        List<User> users = new List<User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);

        for(User u: users){
            if(!mapUserNamesPerId.containsKey(u.Id))
                mapUserNamesPerId.put(u.Id, u.Name);
        }

        mergedHistoric = new List<GenericHistoryWrapper>();

        //add custom history to the list
        for(SObject history : customHistoryRecords){

            String tmpOld = '';
            String tmpNew = '';

            if( history.get('Old_Value__c') != null && (String.valueOf(history.get('Old_Value__c'))).endswith('00:00:00'))
                tmpOld = Date.valueOf(history.get('Old_Value__c')).format();
            else
                tmpOld = String.valueOf(history.get('Old_Value__c'));

            if( history.get('New_Value__c') != null && (String.valueOf(history.get('New_Value__c'))).endswith('00:00:00'))
                tmpNew = Date.valueOf(history.get('New_Value__c')).format();
            else
                tmpNew = String.valueOf(history.get('New_Value__c'));

            //if empty value - set to 'blank' string
            if(tmpOld == null)
                tmpOld = '<blank>';
            if(tmpNew == null)
                tmpNew = '<blank>';

            mergedHistoric.add(new GenericHistoryWrapper(
                                history.get('CreatedById'),
                                mapUserNamesPerId.get((Id)history.get('CreatedById')),
                                String.valueOf(history.get('CreatedDate')),
                                tmpOld,
                                tmpNew,
                                history.get('What__c'),
                                true));
        }

        Map<String, Schema.SObjectField> objFieldsMap = Schema.getGlobalDescribe().get(trackedObjApiName).getDescribe().fields.getMap();

        //add the standard history
        for(Sobject history : standardHistoryRecords){
            String tmpOld = '';
            String tmpNew = '';

            if( history.get('OldValue') != null && (String.valueOf(history.get('Oldvalue'))).endswith('00:00:00'))
                tmpOld = Date.valueOf(history.get('OldValue')).format();
            else
                tmpOld = String.valueOf(history.get('OldValue'));

            if( history.get('NewValue') != null && (String.valueOf(history.get('NewValue'))).endswith('00:00:00'))
                tmpNew = Date.valueOf(history.get('NewValue')).format();
            else
                tmpNew = String.valueOf(history.get('NewValue'));

            //if empty value - set to 'blank' string
            if(tmpOld == null)
                tmpOld = '<blank>';
            if(tmpNew == null)
                tmpNew = '<blank>';

            String trackedFieldApiName = (String)history.get('Field');
            System.debug('trackedFieldApiName ' + trackedFieldApiName);

            String trackedFieldLabel = 'Created.';

            if(trackedFieldApiName != 'created')
                trackedFieldLabel = objFieldsMap.get(trackedFieldApiName).getDescribe().getLabel();

            mergedHistoric.add(new GenericHistoryWrapper(
                                history.get('CreatedById'),
                                mapUserNamesPerId.get((Id)history.get('CreatedById')),
                                String.valueOf(history.get('CreatedDate')),
                                tmpOld,
                                tmpNew,
                                trackedFieldLabel,
                                false));
        }

        //sort by createddate (comparable interface methods implemented in wrapper class)
        mergedHistoric.sort();

        System.debug('MERGED HISTORY' + mergedHistoric);

        return mergedHistoric;

    }

    public class GenericHistoryWrapper implements Comparable{

        public Object createdById {get; set;}
        public String createdByName {get; set;}
        public String createdDate {get; set;}
        public Object oldValue {get; set;}
        public Object newValue {get; set;}
        public Object fieldName {get; set;}
        public Boolean isCustom {get; set;}

        public GenericHistoryWrapper(Object createdById, String createdByName, String createdDate, Object oldValue, Object newValue, Object fieldName, Boolean isCustom){
            this.createdById = createdById;
            this.createdByName = createdByName;
            this.createdDate = createdDate;
            this.oldValue = oldValue;
            this.newValue = newValue;
            this.fieldName = fieldName;
            this.isCustom = isCustom;
        }

        public Integer compareTo(Object compareTo) {

            GenericHistoryWrapper compareToDate = (GenericHistoryWrapper)compareTo;
            
            Integer returnValue = 0;
            if (this.createdDate < compareToDate.createdDate || this.fieldName == 'Created.') {
                returnValue = 1;
            } else if (this.createdDate > compareToDate.createdDate) {
                returnValue = -1;
            }
            
            return returnValue;       
        }

    }

}

