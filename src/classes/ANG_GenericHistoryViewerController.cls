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

            String tmpOld = history.get('Old_Value__c') != null ? String.valueOf(history.get('Old_Value__c')) : '<blank>';
            String tmpNew = history.get('New_Value__c') != null ? String.valueOf(history.get('New_Value__c')) : '<blank>';

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
        //(2017/03/29 note: test classes do not create history record in the standard history table and
        //we cannot insert records in these tables, this is why this code is not covered)
        for(Sobject history : standardHistoryRecords){

            String tmpOld = history.get('OldValue') != null ? String.valueOf(history.get('OldValue')) : '<blank>';
            String tmpNew = history.get('NewValue') != null ? String.valueOf(history.get('NewValue')) : '<blank>';

            String trackedFieldApiName = (String)history.get('Field'); String trackedFieldLabel = trackedFieldApiName;
            System.debug('trackedFieldApiName ' + trackedFieldApiName);

            if(trackedFieldApiName != 'created' && trackedFieldApiName != 'RecordType') trackedFieldLabel = objFieldsMap.get(trackedFieldApiName).getDescribe().getLabel();

            //for some reason record type changes generate 2 records in history table???!!! one has the values with Ids of the record types
            //and the other has the value with the label of the record type. we just want to keep the one with the names
            if(trackedFieldLabel == 'RecordType' && tmpOld.startsWith('012')) continue;
            else mergedHistoric.add(new GenericHistoryWrapper(history.get('CreatedById'),mapUserNamesPerId.get((Id)history.get('CreatedById')),String.valueOf(history.get('CreatedDate')),tmpOld,tmpNew,trackedFieldLabel,false));
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
            if (this.createdDate < compareToDate.createdDate || this.fieldName == 'created') {
                returnValue = 1;
            } else if (this.createdDate > compareToDate.createdDate) {
                returnValue = -1;
            }
            
            return returnValue;       
        }

    }

}

