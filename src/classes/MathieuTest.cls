// Implement the interface using a list of Account sObjects
// Note that the initialState variable is declared as final
global class MathieuTest implements Database.Batchable<sObject> {
    //[SELECT Customer_Name__c,MAX(Segment__c),SUM(Load_Count__c) FROM Snapshot__c GROUP BY Customer_Name__c ORDER BY SUM(Load_Count__c) ASC];
    String query = 'Select Id, Email_Address__c, CreatedDate From GDP_Products_Account_View__c Where Email_Address__c != null GROUP BY Email_Address__c ORDER BY CreatedDate ASC';
    
    global MathieuTest() {}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here 
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, 
                        List<sObject> batch) {
                            // Access initialState here 
                            
                        }
    
    global void finish(Database.BatchableContext BC) {
        // Access initialState here 
        
    }
}
/*
global class MathieuTest {
    
    @RemoteAction @ReadOnly
    global static void test(String x) {
        //[Select Email_Address__c From GDP_Products_Account_View__c Where Email_Address__c != null]
        
        List<GDP_Products_Account_View__c> gpavs = [Select Email_Address__c From GDP_Products_Account_View__c Where Email_Address__c != null];
        
        List<String> emails = new List<String>();
        for(GDP_Products_Account_View__c av : gpavs) {
            emails.add(av.Email_Address__c);
        }
        
        System.debug(emails);
        System.debug(new Set<String>(emails));
        
        
        

    }
}
*/