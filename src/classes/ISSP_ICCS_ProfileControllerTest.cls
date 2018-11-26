@isTest
public class ISSP_ICCS_ProfileControllerTest {

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

        Account a = New Account(
            Recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
            Name = 'TestPortalAccount',
			Airline_designator__c = 'LX',
			IATACode__c = '724',
            ICCS_Membership_Status__c = serviceStatus);
        
        insert a;

        List<Folder> folders = [select Id from Folder where DeveloperName = 'ICCS_Portal_Service'];
        
        Document doc = new Document(
            Name = 'test ICCS document',
            Body = Blob.valueOf('test'),
            FolderId = folders[0].id,
            IsPublic = true
        );
        
        insert doc;

        Contact c1 = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test', 
            Email = 'test@test.tes',
            AccountID = a.id);

        Contact c2 = New Contact(
            FirstName = 'Portal 2', 
            LastName = 'Test', 
            Email = 'test@test2.tes',
            AccountID = a.id);
        
        Contact c3 = New Contact(
            FirstName = 'Portal 3', 
            LastName = 'Test', 
            Email = 'test@test3.tes',
            AccountID = a.id);
        
        insert new List<Contact>{c1,c2,c3};
        
        user u1 = New User(
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
            ContactID = c1.id

            );
        
        user u2 = New User(
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
            ContactID = c2.id

            );
        
        user u3 = New User(
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
            ContactID = c3.id

            );
        
        insert new List<User>{u1,u2,u3};

        Portal_Application_Right__c portalUser1 = new Portal_Application_Right__c(Contact__c = c1.Id, Right__c = ISSP_ICCS_Utils.ACCESS_GRANTED,  ANG_Portal_Service_Role__c = ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY, Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id);
        
        Portal_Application_Right__c portalUser2 = new Portal_Application_Right__c(Contact__c = c2.Id, Right__c = ISSP_ICCS_Utils.ACCESS_REQUESTED,  ANG_Portal_Service_Role__c = ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY, Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id);
        
        Portal_Application_Right__c portalUser3 = new Portal_Application_Right__c(Contact__c = c3.Id, Right__c = ISSP_ICCS_Utils.ACCESS_GRANTED,  ANG_Portal_Service_Role__c = ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY, New_Role_Requested__c = ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1, Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id);
        
		insert new List<Portal_Application_Right__c>{portalUser1, portalUser2, portalUser3};
        
        return u1;
    }

    static testMethod void testProfile() {
        User partnerUser = createPartnerUser('Member');

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
		pageController.currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
        ISSP_ICCS_CaseProcessesController caseProcessesController = new ISSP_ICCS_CaseProcessesController();
		caseProcessesController.pageController = pageController;

		// Back to the Homepage
		pageController.currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;

		// Navigate to Cases
        pageController.navigateToProfile();

		System.assert(!profileController.getReportsNotifications);

		profileController.updateReportsNotificationChoice();

		System.assert(profileController.getReportsNotifications);


		List<SelectOption> serviceRoles = profileController.serviceRoles;
		List<SelectOption> restrictedServiceRoles = profileController.restrictedServiceRoles;
		List<SelectOption> accessStatusesIncludingRequested = profileController.accessStatusesIncludingRequested;
		
		// handle a user who requested role ugrade
		for(ISSP_ICCS_ProfileController.UserWrapper wrappedUser : profileController.wrappedUsersList){
			if(wrappedUser.userRequestedRoleUpgrade){
				Boolean b = wrappedUser.canUserHandleRoleUpgradeRequest;
				
				wrappedUser.rejectRoleUpgrade();
				
				wrappedUser.usr.New_Role_Requested__c = ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1;
				update wrappedUser.usr;
				
				wrappedUser.acceptRoleUpgrade();
				break;
			}
		}

		// handle a user who requested access
		for(ISSP_ICCS_ProfileController.UserWrapper wrappedUser : profileController.wrappedUsersList){
			if(wrappedUser.userRequestedAccess){
				Boolean b = wrappedUser.canUserGiveLevel1Access && wrappedUser.canUserGiveReadOnlyAccess;
				b = wrappedUser.isSignatory | wrappedUser.isLevel1 | wrappedUser.isReadOnly;

				System.assert(wrappedUser.canUserModifyRole && wrappedUser.canUserModifyAccess);
				wrappedUser.updateUser();
				wrappedUser.accessStatus = ISSP_ICCS_Utils.ACCESS_GRANTED;
				wrappedUser.cancel();
				wrappedUser.denyAccess();
				wrappedUser.grantAccess();

				break;
			}
		}

		profileController.requestLevel1Access();
		
		System.assert(profileController.wrappedUsersList.size() == 3);
		
		for(ISSP_ICCS_PRofileController.UserWrapper wrappedUser : profileController.wrappedUsersList){
			if(wrappedUser.role == ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY){
				wrappedUser.updateUser();
				wrappedUser.role = ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1;
				wrappedUser.save();
				break;
			}
		}
		
/*		for(ISSP_ICCS_PRofileController.UserWrapper wrappedUser : profileController.wrappedUsersList){
			if(wrappedUser.role == ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1){
				wrappedUser.updateUser();
				wrappedUser.accessStatus = ISSP_ICCS_Utils.ACCESS_DENIED;
				wrappedUser.save();
				break;
			}
		}*/
				
		pageController.navigateToHomepage();
		
        Test.stopTest();
    }
}