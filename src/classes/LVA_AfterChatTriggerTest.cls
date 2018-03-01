@isTest
public class LVA_AfterChatTriggerTest {
	
    @isTest
    static void testBulkCommentsAndAttachments() {
        
        List<Case> bulkCases = new List<Case>();
        List<LiveChatTranscript> lct = new List<LiveChatTranscript>();
        Set<Id> caseIds = new Set<Id>();
        
        user objUser = new user(lastname='b', email='aa@mail.com',username='aa+222@mail.com',License_Cost_Center__c = 'ISE006CH01', TimeZoneSidKey = 'GMT', EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',LocaleSidKey  ='en_US',alias='guest',profileid=[select id from profile where name = 'IDFS Americas - Hub Staff' limit 1][0].id);
        insert objUser;
        system.runAs(objUser){
            Account a = new Account();
            a.Name = 'Account Name';
            insert a;
            
            Contact con = new Contact();
            con.FirstName = 'FirstName';
            con.LastName = 'LastName';
            con.Email = 'aa@aa.com';
            con.AccountId = a.Id;
            insert con;
            
            
            
            Id recordTypeID = [select id from recordtype where name = 'Cases - Europe' limit 1][0].id;
            //10 because of trigger NewAttachment
            for(integer i=0; i<10; i++){
                bulkCases.add(new Case(Subject='Case ' + i, 
                                       RecordTypeId = recordTypeID, 
                                       Status='Open', 
                                       Origin='Chat',
                                       ContactId = con.Id));
            }
            
            insert bulkCases;
            
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
            
            for(Case c : bulkCases){
                System.debug(c.Case_Thread_ID__c);
                caseIds.add(c.id);
                lct.add(new LiveChatTranscript(AccountId = a.Id,
                                               Body = '<p align="center">Chat Started: Monday, August 28, 2017, 11:05:42 (+0000)</p><p align="center">Chat Origin: AirlineEnglish</p><p align="center">Agent Beatrice M</p>( 6s ) Beatrice M: Hello! <br>My name is Beatrice and I&#39;m here to help you<br>( 22s ) Beatrice M: Hello<br>( 52s ) First: Hello<br>( 1m 3s ) First: My problem was solved tahnks<br>',
                                               SupervisorTranscriptBody = 'Supervisor whisper aaaaaa',
                                               ContactId = con.Id,
                                               CaseId = c.Id,
                                               LiveChatVisitorId = lcv.Id));
            }
            test.startTest();
            insert lct;
            test.stopTest();
        }
        
        System.assertEquals(10, [select id, commentBody from CaseComment where ParentId in :caseIds].size());
        System.assertEquals(10, [select Id, Body, ContentType from Attachment where ParentId in :caseIds].size());
    }
    
    @isTest
    static void testNoCommentsAndAttachments() {
        
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
                                       LiveChatVisitorId = lcv.Id));
        
        insert lct;
        
        System.assertEquals(0, [select id, commentBody from CaseComment].size());
    }
    
    @isTest 
    static void addPDFtoRecordNullCaseTestMethod() { 
        
        List<Case> bulkCases = new List<Case>();
        List<LiveChatTranscript> lcts = new List<LiveChatTranscript>();
        List<Id> lctIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        
        test.startTest();
            User objUser = new user(lastname='b', email='aa@mail.com',username='aa+111@mail.com',License_Cost_Center__c = 'ISE006CH01', TimeZoneSidKey = 'GMT', EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',LocaleSidKey  ='en_US',alias='guest',profileid=[select id from profile where name = 'IDFS Americas - Hub Staff' limit 1][0].id);
            insert objUser;
            System.runAs(objUser){
                Account a = new Account();
                a.Name = 'Account Name';
                insert a;
                
                Contact con = new Contact();
                con.FirstName = 'FirstName';
                con.LastName = 'LastName';
                con.Email = 'aa@aa.com';
                con.AccountId = a.Id;
                insert con;
                
                
                
                Id recordTypeID = [select id from recordtype where name = 'Cases - Europe' limit 1][0].id;
                for(integer i=0; i<10; i++){
                    bulkCases.add(new Case(Subject='Case ' + i, 
                                           RecordTypeId = recordTypeID, 
                                           Status='Open', 
                                           Origin='Chat',
                                           ContactId = con.Id));
                }
                
                insert bulkCases;
                
                LiveChatVisitor lcv = new LiveChatVisitor();
        		insert lcv;
                
                for(Case c : bulkCases){
                    caseIds.add(c.Id);
                    lcts.add(new LiveChatTranscript(AccountId = a.Id,
                                                    Body = '<p align="center">Chat Started: Monday, August 28, 2017, 11:05:42 (+0000)</p><p align="center">Chat Origin: AirlineEnglish</p><p align="center">Agent Beatrice M</p>( 6s ) Beatrice M: Hello! <br>My name is Beatrice and I&#39;m here to help you<br>( 22s ) Beatrice M: Hello<br>( 52s ) First: Hello<br>( 1m 3s ) First: My problem was solved tahnks<br>',
                                                    SupervisorTranscriptBody = 'Supervisor whisper aaaaaa',
                                                    ContactId = con.Id,
                                                    LiveChatVisitorId = lcv.Id));
                }
                
                
                insert lcts;
                
                for(LiveChatTranscript lct : lcts){
                    lctIds.add(lct.Id);
                }
            }
        test.stopTest();
        
		System.assertEquals(0, [select Id, Body, ContentType, Name from Attachment where ParentId in :caseIds].size());
    }
}