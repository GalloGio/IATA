@isTest
public class LVA_TranscriptControllerTest {
    
    @isTest
    static void LVATranscriptControllerTest() {
        
        List<Case> bulkCases = new List<Case>();
        List<LiveChatTranscript> lcts = new List<LiveChatTranscript>();
        List<Id> lctIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
		String expectedBody = '<p align="center">Chat Started: Thursday, October 26, 2017, 19:35:45 (+0200)</p><p align="center">Chat Origin: AirlineEnglishAsiaPacific</p><p align="center">Agent Kalina B</p>( 2s ) Kalina B: Hello!<br>My name is Kalina and I&#39;m here to help.<br><br>( 38s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberb<br/>erb erberberberb<br><br>( 39s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberb<br/>erb erberberberb<br><br>( 40s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberb<br/>erb erberberberb<br><br>( 42s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberb<br/>erb erberberberb sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eb<br/>erberb erberberberb<br><br>( 49s ) User: <a href="https://lar2dev-customer-portal-iata.cs88.force.com/ISSP_FAQ2Case?MainNav=Queries&amp;subNav=MyQueries&amp;mid=M1S1">link</a><br/><br>';
        test.startTest();
            User objUser = new user(lastname='b', email='aa@mail.com',username='aa+444@mail.com',License_Cost_Center__c = 'ISE006CH01', TimeZoneSidKey = 'GMT', EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',LocaleSidKey  ='en_US',alias='guest',profileid=[select id from profile where name = 'IDFS Americas - Hub Staff R&S' limit 1][0].id);
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
                
                Id recordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
                
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
													Body = '<p align="center">Chat Started: Thursday, October 26, 2017, 19:35:45 (+0200)</p><p align="center">Chat Origin: AirlineEnglishAsiaPacific</p><p align="center">Agent Kalina B</p>( 2s ) Kalina B: Hello!<br>My name is Kalina and I&#39;m here to help.<br>( 38s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberberb erberberberb<br>( 39s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberberb erberberberb<br>( 40s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberberb erberberberb<br>( 42s ) User: sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberberb erberberberb sdvsdvsdv sojflsdknf gwnwlekgn wgknwlekg lwkfnwelkf weofnwenflkn weknflweknfln ebdfbdfbweb eberberb erberberberb<br>( 49s ) User: https://lar2dev-customer-portal-iata.cs88.force.com/ISSP_FAQ2Case?MainNav=Queries&amp;subNav=MyQueries&amp;mid=M1S1<br>',
                                                    SupervisorTranscriptBody = 'Supervisor whisper aaaaaa',
                                                    ContactId = con.Id,
                                                    CaseId = c.Id,
                                                    LiveChatVisitorId = lcv.Id));
                }
                
                
                insert lcts;
                
                for(LiveChatTranscript lct : lcts){
                    lctIds.add(lct.Id);
                    PageReference transcriptPage = Page.LVA_TranscriptPdfPage;
        			transcriptPage.getParameters().put('id', lct.id);
                    Test.setCurrentPage(transcriptPage);
                    LVA_TranscriptController ltc = new LVA_TranscriptController();
                    System.assertEquals(expectedBody, ltc.lva.body);
                }
            }
        test.stopTest();
    }
}