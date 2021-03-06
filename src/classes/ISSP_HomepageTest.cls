@isTest
private class ISSP_HomepageTest {

	@testSetup static void customSettingSetup() {
		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c insuranceApp = portalApplicationList.get(0);
		insuranceApp.Name = 'Insurance Providers';
		insuranceApp.ANG_Restrict_by_Agency_Category__c = 'IATA Passenger Sales Agent; IATA Cargo Agent';
		insuranceApp.Agency__c = true;

		Portal_Applications__c otherApp = portalApplicationList.get(1);
		otherApp.Name = 'Other';
		otherApp.Agency__c = true;
		otherApp.ANG_Accredited_Agents_Only__c = true;
		otherApp.ANG_Restrict_by_Agency_Sector__c = 'Travel Agent';
		insert portalApplicationList;
	}

	@isTest static void testServiceList() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'Portugal', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
									IATA_COUNTRY_EN__c = 'testEN', IATA_Country_FR__c = 'testFR', IATA_Country_ZH__c = 'testZH',
									IATA_Country_IT__c = 'testIT', IATA_Country_JP__c = 'testJP', ISO_Code__c = 'pt',
									IATA_Country_PT__c = 'testPT', IATA_Country_SP__c = 'testSP', Case_BSP_Country__c = 'test', Region__c = 'Europe',
									Informatica_Value__c = 'test', Hide_Tax_Number_VAT__c = true, ANG_Enable_NewGen__c = true,
									AMS_Default_State__c = 'PT');
		insert country;

		Account a = new Account(Name = 'agency',
								RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
								Location_Type__c = 'HE',
								Location_Class__c = 'P',
								Status__c = 'Approved',
								Sector__c = 'Travel Agent',
								Category__c = 'IATA Passenger Sales Agent',
								IATA_ISO_Country__c = country.Id);
		insert a;

		Contact c = ISSP_ObjectFactory.createNewContact();
		c.Email = 'hey@hdasoojdihu.com';
		c.AccountId = a.Id;
		c.Financial_Assessment_Contact__c = true;
		insert c;

		User newUser = ISSP_ObjectFactory.createPortalUser(c);
		c.OwnerId = newUser.Id;
		update c;

		Test.startTest();
		System.runAs(newUser) {
			ISSP_Homepage ctrl = new ISSP_Homepage();
		}
		Test.stopTest();
	}

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
			//FAQkav.To_display_on_Homepage__c=true;
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

			Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
			app.Name = 'Test Method App';
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
		update con2;
		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Name = 'test app';
		insert app;
		Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
		insert appRight;

		User newUser3 = ISSP_ObjectFactory.createPortalUser(con3);
		con3.OwnerId = newUser3.Id;

		User newUser4 = ISSP_ObjectFactory.createPortalUser(con4);
		con4.OwnerId = newUser4.Id;

		User newUser5 = ISSP_ObjectFactory.createPortalBasicAirlineUser(con5);
		con5.OwnerId = newUser5.Id;

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
			system.AssertEquals(ctrl.isPortalNavigationBar,true);
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
			
			Case caseSIdra = new Case(
				BSP_CASS__c = 'BSP',
				RecordTypeid=RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'SIDRA_Lite'),
				Status = 'Open',
				Origin = 'IATA Internal User',
				Subject = 'subject');

			insert caseSIdra;
			ctrl.checkCookies(caseSIdra.Id);
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
