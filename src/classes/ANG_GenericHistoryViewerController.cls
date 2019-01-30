public with sharing class ANG_GenericHistoryViewerController {
    
    public String trackedObjId {get;set;}
    public String trackerObjApiName {get;set;}
    public String trackedObjApiName {get;set;}

    //public List<GenericHistoryWrapper> mergedHistoric {get;set;}

    public ANG_GenericHistoryViewerController() {

    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ANG_GenericHistoryViewerController(ApexPages.StandardController stdController) {
        this.trackedObjId = stdController.getRecord().Id;
    }

    public List<GenericHistoryWrapper> getHistoryRecords() {
        return getHistoryRecords(this.trackedObjId, this.trackerObjApiName, this.trackedObjApiName);
    }

    @AuraEnabled
    public static List<GenericHistoryWrapper> getHistoryRecords(String trackedObjId, String trackerObjApiName, String trackedObjApiName) {

        System.debug('### trackedObjId: ' + trackedObjId);
        System.debug('### trackerObjApiName: ' + trackerObjApiName);
        System.debug('### trackedObjApiName: ' + trackedObjApiName);

        String theCustomQuery = 'SELECT CreatedDate, CreatedById, CreatedBy.Name, What__c, ApiName__c, New_Value__c, Old_Value__c FROM ' + trackerObjApiName + ' WHERE ' + trackedObjApiName + '__c = \'' + trackedObjId + '\' and ApiName__c != null ORDER BY CreatedDate DESC';
        System.debug('### Custom history query ' + theCustomQuery);

        //TODO: NEED TO REFINE THIS QUERY TO MAKE IT WORK FOR CUSTOM OBJECTS AS WELL, HISTORY TABLE IS DIFFERENTLY NAMED
        String theStandardQuery = 'SELECT CreatedDate, CreatedById, CreatedBy.Name, Field, NewValue, OldValue FROM ' + trackedObjApiName + 'History WHERE ' + trackedObjApiName + 'Id = \'' + trackedObjId + '\' ORDER BY CreatedDate DESC,ID DESC';
        System.debug('### Standard history query ' + theStandardQuery);

        List<SObject> customHistoryRecords = database.query(theCustomQuery);
        List<SObject> standardHistoryRecords = database.query(theStandardQuery);

        if(standardHistoryRecords.isEmpty() && Test.isRunningTest()){
            standardHistoryRecords.add(new AccountHistory(AccountId=trackedObjId,Field='Type'));
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

        List<GenericHistoryWrapper> mergedHistoric = new List<GenericHistoryWrapper>();

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
                                trackedObjId,
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
            mergedHistoric.add(new GenericHistoryWrapper(trackedObjId, history.get('CreatedById'),mapUserNamesPerId.get((Id)history.get('CreatedById')),String.valueOf(history.get('CreatedDate')),tmpOld,tmpNew,trackedFieldLabel,false,trackedFieldApiName,isLookUpValueMap.get(tmpNew) || isLookUpValueMap.get(tmpOld)));
        }

        //sort by createddate (comparable interface methods implemented in wrapper class)
        mergedHistoric.sort();

        System.debug('MERGED HISTORY: ' + mergedHistoric);

        /*Map<Id, String> oldLookupDisplayValueMap = new Map<Id, String>();
        Map<Id, String> newLookupDisplayValueMap = new Map<Id, String>();

        Map<Id, String> lookupDisplayValueMap = new Map<Id, String>();

        for(GenericHistoryWrapper hist : mergedHistoric) {
            if(hist.isLookUpValueOld) {               
                String oldLookupDisplayValue = getLookupDisplayValue(hist.lookupObject, 'Name', String.valueOf(hist.oldValue));
                //oldLookupDisplayValueMap.put(hist.Id, lookupDisplayValue);
                System.debug('### oldLookupDisplayValue: ' + oldLookupDisplayValue);
                if()
                lookupDisplayValueMap.put();            
            }
            if(hist.isLookUpValueNew) {               
                String newLookupDisplayValue = getLookupDisplayValue(hist.lookupObject, 'Name', String.valueOf(hist.newValue));
                //newLookupDisplayValueMap.put(hist.Id, lookupDisplayValue);
                System.debug('### newLookupDisplayValue: ' + newLookupDisplayValue);
            }
        }*/

        return mergedHistoric;

    }

    /*private static String getLookupDisplayValue(String obj, String field, String id) {
        String query = 'SELECT ' + field + ' FROM ' + obj + ' WHERE Id = \'' + id + '\'';

        List<SObject> queryRecords = database.query(query);

        System.debug('### getLookupDisplayValue - query ' + query);

        return String.valueOf(queryRecords.get(0).get(field));
    }*/

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

        @AuraEnabled public String fieldAPIName {get; set;}
        @AuraEnabled public Object createdById {get; set;}
        @AuraEnabled public String createdByName {get; set;}
        @AuraEnabled public String createdDate {get; set;}
        @AuraEnabled public Object oldValue {get; set;}
        @AuraEnabled public Object newValue {get; set;}
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public Boolean isCustom {get; set;}
        @AuraEnabled public Boolean isLookUpValueNew {get; set;}
        @AuraEnabled public Boolean isLookUpValueOld {get; set;}
        @AuraEnabled public sObject oldObj {get; set;}
        @AuraEnabled public sObject newObj {get; set;}
        @AuraEnabled public String lookupObject {get; set;}
        //@AuraEnabled public String Id {get; set;}
        
        public GenericHistoryWrapper(String trackedObjId, Object createdById, String createdByName, String createdDate, Object oldValue, Object newValue, String fieldName, Boolean isCustom, String fieldAPIName, boolean isLookUpValueIn){
            
            this.isLookUpValueOld = (isLookUpValueIn && oldValue != '<blank>');
            this.isLookUpValueNew = (isLookUpValueIn && newValue != '<blank>');
            
            //System.debug('Creating new GenericHistoryWrapper with values|oldValue:'+oldValue + '|newValue:'+newValue + '|fieldName:'+fieldName + '|fieldAPIName:'+fieldAPIName + '|isLookUpValue:' +isLookUpValue);

            this.fieldAPIName = fieldAPIName;
            this.createdById = createdById;
            this.createdByName = createdByName;
            this.createdDate = createdDate;
            this.oldValue = oldValue;
            this.newValue = newValue;
            
            //Id idOfTheObject = ApexPages.currentPage().getParameters().get('id');
            Id idOfTheObject = trackedObjId;
            
            //small little pirate hack :)
            if(fieldAPIName == 'RecordType') {
                fieldAPIName = 'RecordTypeId';
                this.fieldAPIName = 'RecordTypeId';
            }   
            
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

                Id lookupId = String.valueOf(oldValue);
                this.lookupObject = lookupId.getSObjectType().getDescribe().getName();
            }
            
            if(isLookUpValueNew){
                this.newObj = idOfTheObject.getSObjectType().newSObject();    
                newObj.put(String.valueOf(fieldAPIName), newValue);

                Id lookupId = String.valueOf(newValue);
                this.lookupObject = lookupId.getSObjectType().getDescribe().getName();
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