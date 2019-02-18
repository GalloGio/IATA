@isTest
private class ISSP_HomepageTest {
    
   
    public static testMethod void testISSP_HomepageTest() {
        
        //User adminUser = ISSP_ObjectFactory.createAdminUser();
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account topacc = ISSP_ObjectFactory.createNewAccount();
        insert topacc;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Top_Parent__c = topacc.Id;
        insert acc;
        
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,2);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Email = 'test1@test.test';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c='Pending Approval';
        insert con;
        
        //Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,3);
        
        
        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.Email = 'test2@test.test';
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c='Approved User';
        insert con2;
        
        Contact con3 = ISSP_ObjectFactory.createNewContact();
        con3.Email = 'test3@test.test';
        con3.AccountId= acc.Id;
        con3.User_Portal_Status__c='Approved Admin';
        
        
        //insert con3;
        
        FAQ__kav FAQkav;
        //Portal_news__kav Portal_newska;
        //+++kb migration vanja
        //Content__kav Contentkav;
        //How_To__kav howTokav ;  
        Test.startTest() ;
        //system.runAs(adminUser){
            
            
            
            FAQkav =  (FAQ__kav)ISSP_ObjectFactory.createSObject('FAQ__kav',false,5);
            FAQkav.Language='en_US';
            FAQkav.UrlName = 'test00qwe';
            FAQkav.Title ='Test';
            //FAQkav.PublishStatus='Online';
            FAQkav.To_display_on_Homepage__c=true;
            insert FAQkav;
            
            //Portal_newska =  (Portal_news__kav)ISSP_ObjectFactory.createSObject('Portal_news__kav',false,6);
            //Portal_newska.Language='en_US';
            //Portal_newska.UrlName = 'test1qwefghgf';
            //Portal_newska.Title = 'test001';
            //Portal_newska.PublishStatus='Online';
            //Portal_newska.To_display_on_Homepage__c=true;
            //insert Portal_newska;
            //+++kb migration vanja
            //Contentkav =  (Content__kav)ISSP_ObjectFactory.createSObject('Content__kav',false,11);
            //Contentkav.Language='en_US';
            //Contentkav.UrlName = 'test2qweghfgh';
            //Contentkav.Title='test2';
            //Contentkav.PublishStatus='Online';
            //Contentkav.To_display_on_Homepage__c=true;
            //insert Contentkav;
            
            //howTokav =  (How_To__kav)ISSP_ObjectFactory.createSObject('How_To__kav',false,12);
            //howTokav.Language='en_US';
            //howTokav.UrlName = 'test2qwesdf';
            //howTokav.Title='test2';
            //howTokav.PublishStatus='Online';
            //howTokav.To_display_on_Homepage__c=true;
            //insert howTokav;
            
        //}
        
        
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        ISSP_Constant.adminIdSet.add(ISSP_Constant.TEST_User_ProfileID);
        con.OwnerId = newUser.Id;
        update con;
        
        system.runAs(newUser){
           
            ISSP_Homepage ctrl = new ISSP_Homepage();
            ctrl.isLogined();  
            ctrl.populateVariables();
            ISSP_Homepage.KnowledgeArticleVersionWrapper kbv= new ISSP_Homepage.KnowledgeArticleVersionWrapper(FAQkav);
            //ISSP_Homepage.KnowledgeArticleVersionWrapper kbv1= new ISSP_Homepage.KnowledgeArticleVersionWrapper(Portal_newska);
            //+++kb migration vanja
            //ISSP_Homepage.KnowledgeArticleVersionWrapper kbv2= new ISSP_Homepage.KnowledgeArticleVersionWrapper(Contentkav);
            //ISSP_Homepage.KnowledgeArticleVersionWrapper kbv3= new ISSP_Homepage.KnowledgeArticleVersionWrapper(howTokav);
            //kbv2.compareTo(kbv1);
            //kbv1.compareTo(kbv2);
            
            Portal_Applications__c app = new Portal_Applications__c(Name = 'Test Method App'); 
            insert app;
            ISSP_Homepage.newAppsRequest(app.Id, con.Id);
            Notification__c noti = new Notification__c(Contact__c=con.Id);
            insert noti;
            ISSP_Homepage.archiveNotification(noti.Id);
            ctrl.getIsAdminUser();
            
        }
        
        Test.stopTest();
        
        
    }
     public static testMethod void testISSP_HomepageTest2() {
     
        ISSP_Constant.adminIdSet.add(ISSP_Constant.TEST_User_ProfileID);
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        List<Account> accList = new List<Account>();
        Account topacc = ISSP_ObjectFactory.createNewAccount();
        accList.add(topacc);
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Top_Parent__c = topacc.Id;
        acc.Industry = 'Cargo Agent';
        accList.add(acc);
        
        insert accList;

        List<Contact> conList = new List<Contact>();
        
        //Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,3);
        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.Email = 'test2@test.test';
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c='Active';
        conList.add(con2);

        //Contact con3 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,4);
        Contact con3 = ISSP_ObjectFactory.createNewContact();
        con3.Email = 'test3@test.test';
        con3.AccountId= acc.Id;
        con3.User_Portal_Status__c='Approved Admin';
        conList.add(con3);

        Contact con4 = ISSP_ObjectFactory.createNewContact();
        con4.Email = 'test4@test.test';
        con4.AccountId= acc.Id;
        con4.User_Portal_Status__c='Regional Administrator';
        conList.add(con4);

        Contact con5 = ISSP_ObjectFactory.createNewContact();
        con5.Email = 'test5@test.test';
        con5.AccountId= acc.Id;
        con5.User_Portal_Status__c='Active';
        conList.add(con5);

        insert conList;

        User newUser2 = ISSP_ObjectFactory.createPortalUser(con2);
        con2.OwnerId = newUser2.Id;
        update con2;
        Portal_Applications__c app = new Portal_Applications__c(Name = 'test app'); 
        insert app;
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
        insert appRight;    

        User newUser3 = ISSP_ObjectFactory.createPortalUser(con3);
        con3.OwnerId = newUser3.Id;
        update con3;   

        User newUser4 = ISSP_ObjectFactory.createPortalUser(con4);
        con4.OwnerId = newUser4.Id;
        update con4;
        
        User newUser5 = ISSP_ObjectFactory.createPortalBasicAirlineUser(con5);
        con5.OwnerId = newUser5.Id;
        update con5;

        update conList;

        ISSPLoginSurvey__c loginSurvey = new ISSPLoginSurvey__c ( Name='Survey Login', Survey_Link__c ='http://survey.clicktools.com/app/survey/go.jsp?iv=z3wuis18g2u6', isActive__c =true, PopupDelayTime__c=2);
        insert loginSurvey;
          
        Test.startTest() ;
        system.runAs(newUser2){
            ISSP_Homepage ctrl = new ISSP_Homepage();
            ApexPages.currentPage().getHeaders().put('USER-AGENT','Chrome');
            String ie = ctrl.isIE;
        }
        
        system.runAs(newUser3){
            ISSP_Homepage ctrl = new ISSP_Homepage();
            ApexPages.currentPage().getHeaders().put('USER-AGENT','MSIE 7.0');
            String ie = ctrl.isIE;
        }
        
        system.runAs(newUser4){
            ISSP_Homepage ctrl = new ISSP_Homepage();
        }
        
        system.runAs(newUser5){
            ISSP_Homepage ctrl = new ISSP_Homepage();
            Account account = ctrl.acct;
            String casesListView = ctrl.Cases_ListView;
            String pendingApprovalslistView = ctrl.Pending_approvals_ListView;
            String portalAdminsListView = ctrl.Portal_Admins_ListView;
            String portalregAdminsListView = ctrl.Portal_RegionalAdmins_ListView;
            String portalUsersListView = ctrl.Portal_users_ListView;
            String companycasesListView = ctrl.CompanyCases_ListView;
            String pendingApprovalsAppListview = ctrl.Pending_approvals_app_ListView;
            String  SurveyLink = ctrl.SurveyLink;
            String  SurveyName = ctrl.SurveyName;
        }
        Test.stopTest();
        
        
     }
     
     public static testMethod void testISSP_ObjectFactory() {
        ISSP_ObjectFactory.FillAllFields = true;
        //list<Account> accList = (list<Account>)ISSP_ObjectFactory.createSObjectList('Account',false,1);
     }
     
     
     public static testMethod void test_addNumberOfViews() {
     
        Contact contact = new Contact(FirstName='Name', LastName='test');
        insert contact;
        Notification__c notification = new Notification__c(Contact__c=contact.Id);
        insert notification;
        ISSP_Homepage.addNumberOfViews(notification.Id);
        
     }
}