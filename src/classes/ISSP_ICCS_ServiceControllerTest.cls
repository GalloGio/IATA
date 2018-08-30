@isTest
public class ISSP_ICCS_ServiceControllerTest {

    private static User createPartnerUser(String serviceStatus, String userRole){
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

        Map<String,Schema.RecordtypeInfo> aRtMap = Account.sObjectType.getDescribe().getRecordtypeinfosbyname();

        Account a = New Account(
            Recordtypeid = aRTMap.get('Airline Headquarters').getRecordtypeid(), 
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

        Contact c = New Contact(
            FirstName = 'Portal', 
            LastName = 'Test', 
            Email = 'test@test.tes',
            User_Portal_Status__c = ISSP_ICCS_Utils.PORTAL_STATUS_APPROVED,
            AccountID = a.id);
        
        insert c;

		Portal_Application_Right__c userRights = new Portal_Application_Right__c(
			ANG_Portal_Service_Role__c = userRole,
			Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id,
			Contact__c = c.Id,			
			Right__c = 'Access Granted'
		);
		
		insert userRights;

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

        return u;
    }

    static testMethod void testService() {

        User partnerUser = createPartnerUser('Inactive', 'Signatory');

        Test.startTest();
        
		ISSP_ICCS_ServiceController pageController = new ISSP_ICCS_ServiceController(partnerUser.Id);

		// Increase code coverage

        Boolean b = pageController.isAgency 
                    | pageController.isAirline 
                    | pageController.isMembershipProspect
                    | pageController.isMembershipWithdrawn
                    | pageController.isMembershipActive
                    | pageController.isMembershipMember
                    | pageController.isMembershipInactive
                    | pageController.isMembershipSuspended
                    | pageController.isMembershipNone
                    | pageController.isPortalStatusApproved
                    | pageController.isPortalStatusAdmin
                    | pageController.isPortalStatusInactive
                    | pageController.isPortalStatusPending
                    | pageController.isPortalStatusRegAdmin
                    | pageController.isSignatoryUser
                    | pageController.isLevel1User
                    | pageController.isReadOnlyUser
                    | pageController.isRegistrationUser
                    | pageController.isPortalStatusNone
                    | pageController.displayHomepage
                    | pageController.displayProfile
                    | pageController.displayServiceMgmt
                    | pageController.displayCycleMgmt
                    | pageController.displayReports
                    | pageController.displayCases
                    | pageController.displayCaseProcesses
                    | pageController.displaySiEdit
                    | pageController.displayNoa
                    | pageController.displayAccessDenied
                    | pageController.displayRegistration
                    | pageController.displayBankAccount
                    | pageController.displayPartNew
                    | pageController.displayPartDel
					| pageController.displayDeactivation
					| pageController.displayAspUpd;
					
		Integer activeParticipations = pageController.activeParticipations;
		Integer opportunities = pageController.opportunities;
		Integer numberOfBankAccounts = pageController.numberOfBankAccounts;
		
		Map<String, Document> downloadableDocumentsMap = pageController.downloadableDocumentsMap;

		String s = pageController.pricingPolicyFileUniqueName + pageController.fxPolicyFileUniqueName + pageController.registrationZipFileUniqueName;

        Test.stopTest();
    }
    

}