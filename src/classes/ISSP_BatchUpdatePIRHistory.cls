global class ISSP_BatchUpdatePIRHistory implements Database.Batchable<sObject>, Schedulable {
        
    private static Integer HISTORY_NUMBER_OF_MONTHS = Integer.valueOf(ISSP_CS__c.getValues('Baggage History - Number Of Months').Value__c)*(-1);
    private static String query = 'SELECT Id, Is_Archived__c, (SELECT Id, Date_Time_Proceed_to_payment__c FROM Baggage_Claims__r) FROM PIR_Form__c';
    
    global Database.querylocator start(Database.BatchableContext BC) {
    	
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){

    	Datetime expirationDate = system.now().addMonths(HISTORY_NUMBER_OF_MONTHS);
    	Boolean isExpired;
    	List<PIR_Form__c> pirFormsToUpdate = new List<PIR_Form__c>();
        
        for(sObject s : scope){
        	PIR_Form__c pirForm = (PIR_Form__c)s;
        	isExpired = true;
            if (pirForm.Baggage_Claims__r.size()==0){
                isExpired = false;
            }
            else{
                for(Baggage_Claim__c baggageClaim : pirForm.Baggage_Claims__r){
                    if (baggageClaim.Date_Time_Proceed_to_payment__c == null || baggageClaim.Date_Time_Proceed_to_payment__c >= expirationDate){
                        isExpired = false;
                        break;
                    }
                }
            }
            if (isExpired!=pirForm.Is_Archived__c){
            	pirForm.Is_Archived__c = isExpired;
            	pirFormsToUpdate.add(pirForm);
            }
        }

        update pirFormsToUpdate;

    }
    
    global void finish(Database.BatchableContext BC){   
    }

    global void execute(SchedulableContext sc) {
        ID batchprocessid = Database.executeBatch(this);
    }
}