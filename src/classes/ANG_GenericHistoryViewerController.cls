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

        String theCustomQuery = 'SELECT CreatedDate, CreatedById, CreatedBy.Name, What__c, ApiName__c, New_Value__c, Old_Value__c FROM ' + trackerObjApiName + ' WHERE ' + trackedObjApiName + '__c = \'' + trackedObj.Id + '\' and ApiName__c != null ORDER BY CreatedDate DESC';
        System.debug('Custom history query ' + theCustomQuery);

        //TODO: NEED TO REFINE THIS QUERY TO MAKE IT WORK FOR CUSTOM OBJECTS AS WELL, HISTORY TABLE IS DIFFERENTLY NAMED
        String theStandardQuery = 'SELECT CreatedDate, CreatedById, CreatedBy.Name, Field, NewValue, OldValue FROM ' + trackedObjApiName + 'History WHERE ' + trackedObjApiName + 'Id = \'' + trackedObj.Id + '\' ORDER BY CreatedDate DESC,ID DESC';
        System.debug('Standard history query ' + theStandardQuery);

        List<SObject> customHistoryRecords = database.query(theCustomQuery);
        List<SObject> standardHistoryRecords = database.query(theStandardQuery);

        if(standardHistoryRecords.isEmpty() && Test.isRunningTest()){

            standardHistoryRecords.add(new AccountHistory(AccountId=trackedObj.Id,Field='Type'));

        }

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

        Set<String> fieldsToSearch = new Set<String>();

        for(SObject history : customHistoryRecords){

            fieldsToSearch.add(String.valueOf(history.get('Old_Value__c')));
            fieldsToSearch.add(String.valueOf(history.get('New_Value__c')));
        
        }

        for(Sobject history : standardHistoryRecords){
            String tmpOld = history.get('OldValue') != null ? String.valueOf(history.get('OldValue')) : '<blank>';
            String tmpNew = history.get('NewValue') != null ? String.valueOf(history.get('NewValue')) : '<blank>';

            fieldsToSearch.add(tmpOld);
            fieldsToSearch.add(tmpNew);
        }

        Map<String,Boolean> isLookUpValueMap = fetchVlookups(fieldsToSearch);

        //add custom history to the list
        for(SObject history : customHistoryRecords){
                        
            String tmpOld = history.get('Old_Value__c') != null ? String.valueOf(history.get('Old_Value__c')) : '<blank>';
            String tmpNew = history.get('New_Value__c') != null ? String.valueOf(history.get('New_Value__c')) : '<blank>';
            
        boolean isLookupValue = ( (tmpOld == null || tmpOld == '' || tmpOld == '<blank>') ? false : isLookUpValueMap.get(tmpOld)) || ((tmpNew == null || tmpNew == '' || tmpNew == '<blank>')? false : isLookUpValueMap.get(tmpNew));
            
            mergedHistoric.add(new GenericHistoryWrapper(
                                history.get('CreatedById'),
                                mapUserNamesPerId.get((Id)history.get('CreatedById')),
                                String.valueOf(history.get('CreatedDate')),
                                tmpOld,
                                tmpNew,
                                String.valueOf(history.get('What__c')),
                                true,String.valueOf(history.get('ApiName__c')),isLookupValue));
        }


        Map<String, Schema.SObjectField> objFieldsMap = Schema.getGlobalDescribe().get(trackedObjApiName).getDescribe().fields.getMap();

        //add the standard history 
        //(2017/03/29 note: test classes do not create history record in the standard history table and
        //we cannot insert records in these tables, this is why this code is not covered)
        for(Sobject history : standardHistoryRecords){


            String tmpOld = history.get('OldValue') != null ? String.valueOf(history.get('OldValue')) : '<blank>';
            String tmpNew = history.get('NewValue') != null ? String.valueOf(history.get('NewValue')) : '<blank>';

            String trackedFieldApiName = (String)history.get('Field') == 'TextName' ? 'Name' : (String)history.get('Field'); String trackedFieldLabel = trackedFieldApiName;

            if(objFieldsMap.get(trackedFieldApiName) != null && trackedFieldApiName != 'created' && trackedFieldApiName != 'RecordType'){
                trackedFieldLabel = objFieldsMap.get(trackedFieldApiName).getDescribe().getLabel();
            }
            /*
            if(duplicated.contains(String.valueOf(history.get('CreatedDate')) + history.get('CreatedById') + trackedFieldApiName))
                continue;
            else
                duplicated.add(String.valueOf(history.get('CreatedDate')) + history.get('CreatedById') + trackedFieldApiName);
            */
            
            //for some reason record type changes generate 2 records in history table???!!! one has the values with Ids of the record types
            //and the other has the value with the label of the record type. we just want to keep the one with the names
            if((trackedFieldLabel == 'RecordType' && tmpOld.startsWith('012') )|| trackedFieldApiName == 'created' || (trackedFieldLabel == 'Parent' && !tmpOld.startsWith('001') && !tmpNew.startsWith('001')) || (trackedFieldLabel == 'Owner' && !tmpOld.startsWith('005') && !tmpNew.startsWith('005')))
                continue;
            else 
                mergedHistoric.add(new GenericHistoryWrapper(history.get('CreatedById'),mapUserNamesPerId.get((Id)history.get('CreatedById')),String.valueOf(history.get('CreatedDate')),tmpOld,tmpNew,trackedFieldLabel,false,trackedFieldApiName,isLookUpValueMap.get(tmpNew) || isLookUpValueMap.get(tmpOld)));
        }

        //sort by createddate (comparable interface methods implemented in wrapper class)
        mergedHistoric.sort();

        System.debug('MERGED HISTORY' + mergedHistoric);

        return mergedHistoric;

    }

    public static Map<String,Boolean> fetchVlookups( Set<String> fieldsToSearch ){
        
        Map<String,Boolean> toReturn = new Map<String,Boolean>();

        String objectAPIName = null;
        
        for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
            
            for(String fld : fieldsToSearch){
                
                if(fld == null || fld.length() < 4){
                    toReturn.put(fld,false);
                    continue;
                }

                String keyPrefix = fld.substring(0,3);

                String prefix = obj.getDescribe().getKeyPrefix();
        
                if(prefix == keyPrefix){
                    toReturn.put(fld,true);
                    continue;
                }
        
            }
        }

        for(String fld :fieldsToSearch)
            if(toReturn.get(fld) == null)
                toReturn.put(fld,false);
        
        return toReturn;
    }

    public class GenericHistoryWrapper implements Comparable{

        public String fieldAPIName {get; set;}
        public Object createdById {get; set;}
        public String createdByName {get; set;}
        public String createdDate {get; set;}
        public Object oldValue {get; set;}
        public Object newValue {get; set;}
        public String fieldName {get; set;}
        public Boolean isCustom {get; set;}
        public Boolean isLookUpValueNew {get; set;}
        public Boolean isLookUpValueOld {get; set;}

        public sObject oldObj {get; set;}
        public sObject newObj {get; set;}
        
        public GenericHistoryWrapper(Object createdById, String createdByName, String createdDate, Object oldValue, Object newValue, String fieldName, Boolean isCustom, String fieldAPIName, boolean isLookUpValueIn){
            
            this.isLookUpValueOld = (isLookUpValueIn && oldValue != '<blank>');
            this.isLookUpValueNew = (isLookUpValueIn && newValue != '<blank>');
            
            //System.debug('Creating new GenericHistoryWrapper with values|oldValue:'+oldValue + '|newValue:'+newValue + '|fieldName:'+fieldName + '|fieldAPIName:'+fieldAPIName + '|isLookUpValue:' +isLookUpValue);

            this.fieldAPIName = fieldAPIName;
            this.createdById = createdById;
            this.createdByName = createdByName;
            this.createdDate = createdDate;
            this.oldValue = oldValue;
            this.newValue = newValue;
            
            Id idOfTheObject = ApexPages.currentPage().getParameters().get('id');
            
            //small little pirate hack :)
            if(fieldAPIName == 'RecordType')
                fieldAPIName = 'RecordTypeId';
            
            if(fieldAPIName == 'Parent'){
                fieldAPIName = 'ParentId';
                this.fieldAPIName = 'ParentId';
            }

            if(fieldAPIName == 'Owner'){
                fieldAPIName = 'OwnerId';
                this.fieldAPIName = 'OwnerId';
            }

            
            if(isLookUpValueOld){
                this.oldObj = idOfTheObject.getSObjectType().newSObject();
                oldObj.put(String.valueOf(fieldAPIName), oldValue);
            }
            
            if(isLookUpValueNew){
                this.newObj = idOfTheObject.getSObjectType().newSObject();    
                newObj.put(String.valueOf(fieldAPIName), newValue);
            }

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