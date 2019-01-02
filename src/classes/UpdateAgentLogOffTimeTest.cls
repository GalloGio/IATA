// *************************************
// Vanja Djurdjevic | vanja.djurdjevic@b-i.com
// 20/11/2018
// 
// *************************************
@isTest
public class UpdateAgentLogOffTimeTest {
    @isTest public static void updateTimeLoggedOff() {
        Agents__c a = new Agents__c(Name='test-agent', Logged_on__c=false);
        insert a;
        Test.startTest();
        UpdateAgentLogOffTime.AgentUpdateTime(new List<Id>{a.Id});
        Test.stopTest();
    }
}