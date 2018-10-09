@isTest
public class ISSP_ICCS_ReportsControllerTest {

    private static User createPartnerUser(String serviceStatus){
    	// Create ICCS portal application if it doesn't exist
    	if(ISSP_ICCS_Utils.getIccsPortalApplication() == null){
			insert new Portal_Applications__c(Name = 'ICCS');
    	}
    	
    	// Create missing ICCS Notification Templates
		List<Notification_Template__c> missingNotificationTemplates = new List<Notification_Template__c>();
		for(String templateIdentifier : ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.keySet()){
			if(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(templateIdentifier) == null){
				missingNotificationTemplates.add(new Notification_Template__c(
					Identifier__c = templateIdentifier,
					Expire_in_days__c = 2
				));
			}
		}
		
		if(!missingNotificationTemplates.isEmpty()){			
			insert missingNotificationTemplates;
			for(Notification_Template__c template : [select Name, Identifier__c from Notification_Template__c where Identifier__c in : ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.keySet()]){
				ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.put(template.Identifier__c, template.Name);
			}
		}
		
    	// Create ICCS Default Report Notification Template if missing
		List<Notification_Template__c> defaultReportNotificationTemplate = [select Id from Notification_Template__c where Identifier__c =: ISSP_ICCS_Utils.ICCS_DEFAULT_REPORT_NOTIFICATION_TEMPLATE];
		if(defaultReportNotificationTemplate.isEmpty()){
			insert new Notification_Template__c(
				Identifier__c = ISSP_ICCS_Utils.ICCS_DEFAULT_REPORT_NOTIFICATION_TEMPLATE,
				Expire_in_days__c = 2
			);
		}
		

		// Create missing ICCS roles
		Map<String, Connected_App_Roles__c> existingRoles = Connected_App_Roles__c.getAll();
		
		Set<String> requiredRoles = new Set<String>{ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY, ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1, ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY, ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION};
		
        Connected_App_Roles__c signatory = new Connected_App_Roles__c(Name = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY, Description__c = 'ICCS Service', Role__c = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY);

		List<Connected_App_Roles__c> newRoles = new List<Connected_App_Roles__c>();

		for(String requiredRole : requiredRoles){
			if(! existingRoles.keySet().contains(requiredRole)){
				newRoles.add(new Connected_App_Roles__c(Name = requiredRole, Description__c = 'ICCS Service', Role__c = requiredRole));
			}
		}
        insert newRoles;

        Profile p = [Select ID, Name from Profile Where Name = 'ISS Portal (Partner)'];

        Map<String,Schema.RecordtypeInfo> aRtMap = Account.sObjectType.getDescribe().getRecordtypeinfosbyname();

        Account a = New Account(
            Recordtypeid = aRTMap.get('Airline Headquarters').getRecordtypeid(), 
            Name = 'TestPortalAccount',
            ICCS_Membership_Status__c = serviceStatus,
            IATACode__c = '724',
            Airline_designator__c = 'LX');
        
        insert a;

        List<Folder> folders = [select Id from Folder where DeveloperName = 'ICCS_Portal_Service'];
        
        Document doc = new Document(
            Name = 'test ICCS document',
            Body = Blob.valueOf('test'),
            FolderId = folders[0].id,
            IsPublic = true
        );
        
        insert doc;

        Contact c = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test', 
            Email = 'test@test.tes',
            AccountID = a.id);
        
        insert c;

        user u = New User(
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'Test-First',
            LastName = 'Test-Last',
            Alias = 'test',
            email = 'test' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = p.id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = c.id

            );
        
        insert u;

        Portal_Application_Right__c portalUser = new Portal_Application_Right__c(Contact__c = c.Id, Right__c = ISSP_ICCS_Utils.ACCESS_GRANTED,  ANG_Portal_Service_Role__c = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY, Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id);

		insert portalUser;
        
        return u;
    }
    
    static testMethod void testReports(){
        
        User partnerUser = createPartnerUser(ISSP_ICCS_Utils.ICCS_MEMBERSHIP_MEMBER);

        Test.startTest();

		// Create page controller
        ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Set the necessary Component controllers
        ISSP_ICCS_HomepageController homepageController = new ISSP_ICCS_HomepageController();
		homepageController.pageController = pageController;
		
		pageController.previousComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.PROFILE;
        ISSP_ICCS_ProfileController profileController = new ISSP_ICCS_ProfileController();
		profileController.pageController = pageController;

		pageController.previousComponent = ISSP_ICCS_Utils.Page.PROFILE;
		pageController.currentComponent = ISSP_ICCS_Utils.Page.REPORTS;
        ISSP_ICCS_ReportsController reportsController = new ISSP_ICCS_ReportsController();
		reportsController.pageController = pageController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;

		// Navigate to Profile
        pageController.navigateToProfile();

		List<Portal_Service_User_Preference__c> userPreferences = [	select 	Id, 
																				Portal_Service_Access__c,
																				Portal_Service_Access__r.Contact__c,
																				Portal_Service_Access__r.Top_Account__c,
																				Category__c,
																				Subscribed__c
																		from 	Portal_Service_User_Preference__c];

		System.assert(userPreferences.size() == 0);

		profileController.updateReportsNotificationChoice();
		
		userPreferences = [	select 	Id, 
									Portal_Service_Access__c,
									Portal_Service_Access__r.Contact__c,
									Portal_Service_Access__r.Top_Account__c,
									Category__c,
									Subscribed__c
							from 	Portal_Service_User_Preference__c];

		System.assert(userPreferences.size() > 0);

		// Navigate to Reports
        pageController.navigateToReports();


 		// Get Report Types list       
        List<ISSP_ICCS_ReportsController.ReportTypeWrapper> reportTypesList = reportsController.types;

		Boolean isReportTypeListExpandable = reportsController.isReportTypeListExpandable;

		reportsController.expandCollapseReportTypesList();
		
		reportTypesList = reportsController.types;
        
        System.assert(reportTypesList.size() > 0);

		ISSP_ICCS_ReportsController.ReportTypeWrapper wrappedReportType = reportTypesList[0];
		
		System.assert(!reportsController.secondRefreshRequired);

		// Update subscription for one report type
		wrappedReportType.updateReportsSelection();
		
		System.assert(reportsController.secondRefreshRequired);
		
		reportsController.completeRefresh();

		System.assert(!reportsController.secondRefreshRequired);

		System.assert(wrappedReportType.isSelected);

		wrappedReportType.updateReportsSelection();
		reportsController.completeRefresh();

		System.assert(! wrappedReportType.isSelected);

		wrappedReportType.updateReportsSelection();
		reportsController.completeRefresh();

		// Select the second report type
		wrappedReportType = reportTypesList[1];
		wrappedReportType.updateReportsSelection();
		reportsController.completeRefresh();

		Integer reportTypes = 0;
		Integer selectedReportTypes = 0;
		
		for(ISSP_ICCS_ReportsController.ReportTypeWrapper wrappedReportType2 : reportTypesList){
			reportTypes++;
			if(wrappedReportType2.isSelected){
				selectedReportTypes++;
			}

			System.assert(wrappedReportType2.reportType.code == '30F' || wrappedReportType2.reportType.code == '31F');

		}
		
		System.assertEquals(reportTypes, selectedReportTypes);
		System.assertEquals(2, selectedReportTypes);

		// Get Reports list
		List<ISSP_ICCS_ReportsController.ReportWrapper> reportsList = reportsController.reportsList;
		
		System.assert(reportsList.size() > 0);
		
		ISSP_ICCS_ReportsController.ReportWrapper wrappedReport = reportsList[0];

		ISSP_ICCS_CoreRest.Report report = wrappedReport.report;
		String reportName = report.name;
		String reportParticipantCode = report.participantCode;
		String reportCycleId = report.cycleId;
		String reportTypeDescription = report.type.description;
		String reportUploadDate = report.uploadDate;
		
		System.assert(report.availableFormats.size() > 0);
		
		String format = report.availableFormats[0].format;
	
		wrappedReport.selectedMimetype = report.availableFormats[0].mimetype;
		
		wrappedReport.getReport();
		

		reportsController.selectedPage = 1;

		System.assert(reportsController.reportTypes.size() > 1);

		reportsController.selectedReportType = reportsController.reportTypes[1].getValue();

		System.assert(reportsController.cycles.size() > 1);

		reportsController.selectedCycleId = reportsController.cycles[1].getValue();

		reportsController.selectedFromDate = '1900-01-01';
		reportsController.selectedToDate = '2100-01-01';

		reportsController.deleteReportsList();
		
		Integer numberOfPages = reportsController.numberOfPages;


		// Test report notification

        List<Account> accounts = [select Id from Account where Name = 'TestPortalAccount'];

		System.assert(accounts.size() > 0);

		ISSP_WS_CreateNotification.languageMessage inputMessage = new ISSP_WS_CreateNotification.LanguageMessage();
		inputMessage.languageCode = 'en_US';

		ISSP_WS_CreateNotification.inputData inputData = new ISSP_WS_CreateNotification.inputData();
	
    	inputData.requestingSystem = 'ICCS Core';
    	inputData.serviceName = ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME;
    	inputData.templateName = '30F';
    	inputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>{inputMessage};
    	inputData.replaceStr = 	'%CYCLE_ID%!2017#013|' + 
    							'%SF_ACCOUNT_ID%!' + accounts[0].Id + '|' +  
    							'%START_DATE%!2017-05-22|' + 
    							'%END_DATE%!2017-05-23';
	    	
    	ISSP_WS_CreateNotification.ResponseOne response =  ISSP_WS_CreateNotification.createNotification(inputData);
    	
    	pageController.navigateToHomepage();

        Test.stopTest();
    }
}