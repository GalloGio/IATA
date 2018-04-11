public with sharing class OperationalCalendarHandler {
    
    public static void beforeInsert(list<Operational_Calendar__c> listNew) {
        populateMissingFields(listNew);
    }
    
    
    /**
        Populates some calendar fields when they are empty
        This happens when the data comes from the external service and it's
        inserted by MuleSoft 
    **/
    private static void populateMissingFields(list<Operational_Calendar__c> listOperations) {
        list<String> listISSOperationNames = new list<String>();
        list<CalendarFields> listCalendarFields = new list<CalendarFields>();
        for (Operational_Calendar__c operation: listOperations) {
            CalendarFields calendarFields = new CalendarFields(operation);
            listCalendarFields.add(calendarFields);
            listISSOperationNames.add(calendarFields.ISSOperationName);
        }
        map<String,Id> mapISSoperations = new map<String,Id>();
        for (AMS_Settlement_System__c ISSOperation: [SELECT Id,Name FROM AMS_Settlement_System__c WHERE Name IN :listISSOperationNames]) {
            mapISSoperations.put(ISSOperation.Name, ISSOperation.Id);
        }
        
        //populate Calendar fields from class CalendarFields
        for (CalendarFields calendarFields: listCalendarFields) {
            Id ISSoperationId = mapISSoperations.get(calendarFields.issOperationName);
            calendarFields.setISSOperation(ISSoperationId);
            calendarFields.setCurrency();
            calendarFields.setFrequency();
            calendarFields.setOperationType();
            calendarFields.setOperationPeriodCode();
        }
    }
    
    public static final map<String,String> MAP_BSP_OPERATION_TYPES = new map<String,String>{
        'I' => 'BSP International',
        'D' => 'BSP Domestic'
    };
    public static final map<String,String> MAP_CASS_OPERATION_TYPES = new map<String,String>{
        'E' => 'CASS Export',
        'I' => 'CASS Import'
    };
    /**
        Class to manage the calculated fields for an Operational_Calendar__c record
    **/
    public class CalendarFields {
        public String country;
        public String bspCass;
        public String currencyCode;
        public String operationType;
        public String frequency;
        public String ISSOperationName;
        public Operational_Calendar__c operation;
        
        public CalendarFields(Operational_Calendar__c operation) {
            this.operation = operation;
            if (String.isBlank(operation.Operation_Code__c)) return;
            list<String> listParts = operation.Operation_Code__c.split('_');
            if (listParts.size()<5) return;
            this.country = listParts[0];
            if (listParts[1]=='BSP') {
                this.bspCass = 'BSP';
                this.operationType = MAP_BSP_OPERATION_TYPES.get(listParts[4]);
            }
            if (listParts[1]=='CAS') {
                this.bspCass = 'CASS';
                this.operationType = MAP_CASS_OPERATION_TYPES.get(listParts[2]);
            }
            this.ISSOperationName = this.bspCass + '-' + this.country;
            this.currencyCode = listParts[3];
            this.frequency = operation.Period_Code__c.right(1);
        }
        
        public void setISSOperation(Id ISSOperationId) {
            if (String.isBlank(operation.ISS_operation__c)) {
                operation.ISS_operation__c = ISSOperationId;
            }
        }
        
        public void setCurrency() {
            if (String.isBlank(operation.Operation_Currency__c)) {
                operation.Operation_Currency__c = this.currencyCode;
            }
        }
        
        public void setFrequency() {
            if (String.isBlank(operation.Frequency_code__c)) {
                operation.Frequency_code__c = this.frequency;
            }
        }
        
        public void setOperationType() {
            if (String.isBlank(operation.Operation_Type__c)) {
                operation.Operation_Type__c = this.operationType;
            }
        }
        
        public void setOperationPeriodCode() {
            if (String.isBlank(operation.Operation_Period_code__c)) {
                operation.Operation_Period_code__c = this.operation.Operation_Code__c + '__RM_' + this.operation.Period_Code__c;
            }
        }
    }

}