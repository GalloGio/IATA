// *************************************
// Vanja Djurdjevic | vanja.djurdjevic@b-i.com
// 20/11/2018
// 
// *************************************
@isTest
public class AgentStatusExtensionTest {
    @isTest public static void agentLoggedOnTest() {
        Agents__c agent = new Agents__c(name='test', Logged_on__c=True, User__c=UserInfo.getUserId());
        insert agent;
        Test.startTest();
        AgentStatusExtension c = new AgentStatusExtension();
        System.debug([SELECT Id, Name, User__c FROM Agents__c]);
        System.debug(UserInfo.getUserId());
        c.agent = agent;
        c.save();
        Test.stopTest();
    }
    
    @isTest public static void agentLoggedNoRegionTest() {
        Agents__c agent = new Agents__c(name='test', Logged_on__c=True, User__c=UserInfo.getUserId(), Region__c='non-existing');
        insert agent;
        Test.startTest();
        AgentStatusExtension c = new AgentStatusExtension();
        System.debug([SELECT Id, Name, User__c FROM Agents__c]);
        System.debug(UserInfo.getUserId());
        c.agent = agent;
        c.save();
        Test.stopTest();
    }
}