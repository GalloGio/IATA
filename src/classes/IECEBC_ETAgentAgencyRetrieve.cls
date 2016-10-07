public class IECEBC_ETAgentAgencyRetrieve {
    
    // get list of Agents
    Public static List<ID_Card__c> getAgents(){
        
        List<ID_Card__c> agents = [Select Id, email__c from ID_Card__c LIMIT 5];        
        return agents;                
    }
    
    // get list of Agencies
    public static List<GDP_Products_Account_View__c> getAgencies(){
        
        List<GDP_Products_Account_View__c> agencies = [Select Id, Email_Address__c from GDP_Products_Account_View__c LIMIT 5];        
        return agencies;
    }
}