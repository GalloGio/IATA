/**
* Class to load custom messages on record detail page  
**/

public without sharing class DetailPageMessages {
	
    @AuraEnabled
    public static List<MessageWrapper> getMessages(Id recordId, String objectName){
        List<MessageWrapper> response = new List<MessageWrapper>();
        
        try {
            SObject record = getRecord(recordId, objectName);
            Pattern p = Pattern.compile('(?<=\\{\\!).*?(?=\\})');

            List<Detail_Page_Layout_Custom_Message__mdt> messages = [SELECT Icon__c, Message__c, Query__c, Related_Object__c, 
                                                                        Multiple_Records__c, Main_Object__c, Variant__c
                                                                    FROM Detail_Page_Layout_Custom_Message__mdt
                                                                    WHERE Main_Object__c = :objectName];          

            for(Detail_Page_Layout_Custom_Message__mdt message : messages) {
                if(Limits.getLimitQueries() == Limits.getQueries()) {
                    MessageWrapper msg = new MessageWrapper('error', 'utility:ban', 'SOQL Limit was hit, this object cannot have more custom messages configured. Please contact support.');
                    break;
                }
                createMessage(message, record, response, p);
            }            
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            MessageWrapper errorMessage = new MessageWrapper('error', 'utility:ban', 'An exception occur while retriving custom messages, please contact support.');
            response.add(errorMessage);
        }
        
        return response;
    }

    private static void createMessage(Detail_Page_Layout_Custom_Message__mdt message, SObject record, List<MessageWrapper> response, Pattern p) {
        Map<String,SObject> records = new Map<String,SObject>();
        
        String queryStr = message.Query__c.replace('{!recordId}', '\''+ ((Id) record.get('Id')) + '\'');
        queryStr += message.Multiple_Records__c ? '' : ' LIMIT 1';
        List<SObject> relatedRecords = Database.query(queryStr);
        
        for(SObject relatedRecord : relatedRecords) {
            String msg =  mergeMessage(message, record, relatedRecord, p);
            MessageWrapper msgW = new MessageWrapper(message.Icon__c, message.Variant__c, msg);
            response.add(msgW);
        }
    }

    private static String mergeMessage(Detail_Page_Layout_Custom_Message__mdt message, SObject mainRecord, SObject relatedRecord, Pattern p) {
        String res = message.Message__c;
        Matcher m = p.matcher(message.Message__c);
        while(m.find()) {
            String var = m.group();
            System.debug(var);
            List<String> fieldPath = var.split('\\.');
            SObject reference = fieldPath.remove(0) == message.Main_Object__c ? mainRecord : relatedRecord;
            res = res.replace('{!'+var+'}', getSafeValue(fieldPath, reference)); 
        }

        return res;
    }

    private static String getSafeValue(List<String> fieldPath, SObject record) {
        String returnValue = '<null>';

        Integer i=1;
        SObject currRecord = record;
        for(String node : fieldPath) {
            if(i == fieldPath.size()) {
                Object val = currRecord.get(node);
                if(val == null) {
                    break;
                }
                returnValue =  String.valueOf(val);
            } else {
                currRecord = currRecord.getSObject(node);
                if(currRecord == null) {
                    break;
                }
            }
            i++;
        }

        return returnValue;
    }

    private static SObject getRecord(Id recordId, String objectName) {
        DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keySet());

        String queryStr = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + objectName + ' WHERE Id = :recordId';

        return Database.query(queryStr)[0];
    }

    public class MessageWrapper {
        @AuraEnabled public String icon {get;set;}
        @AuraEnabled public String variant {get;set;}
        @AuraEnabled public String message {get;set;}

        public MessageWrapper(String icon, String variant, String message) {
            this.icon = icon;
            this.variant = variant;
            this.message = message;
        } 
    }
}