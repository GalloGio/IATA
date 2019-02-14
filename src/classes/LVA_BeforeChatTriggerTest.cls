@isTest
public class LVA_BeforeChatTriggerTest {
    
    @isTest
    static void testCreateCaseForLiveChat() {
        Test.startTest();
        LVA_BeforeChatTriggerHandler handler = new LVA_BeforeChatTriggerHandler();
        
        handler.onAfterInsert();
        handler.onBeforeUpdate();
        handler.onAfterUpdate();
        handler.onBeforeDelete();
        handler.onAfterDelete();
        
        Account a = new Account();
        a.Name = 'Account Name';
        insert a;
        
        Contact con = new Contact();
        con.FirstName = 'FirstName';
        con.LastName = 'LastName';
        con.AccountId = a.Id;
        insert con;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        List<LiveChatTranscript> lct = new List<LiveChatTranscript>();
        lct.add(new LiveChatTranscript(AccountId = a.Id,
                                       Body = '<p align="center">Chat Started: Monday, August 28, 2017, 11:05:42 (+0000)</p><p align="center">Chat Origin: AirlineEnglish</p><p align="center">Agent Beatrice M</p>( 6s ) Beatrice M: Hello! <br>My name is Beatrice and I&#39;m here to help you<br>( 22s ) Beatrice M: Hello<br>( 52s ) First: Hello<br>( 1m 3s ) First: My problem was solved tahnks<br>',
                                       SupervisorTranscriptBody = 'Supervisor whisper aaaaaa',
                                       ContactId = con.Id,
                                       Case_Record_Type_ID__c = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope'),
                                       LiveChatVisitorId = lcv.Id));
        
        insert lct;
        Test.stopTest();
    }
}