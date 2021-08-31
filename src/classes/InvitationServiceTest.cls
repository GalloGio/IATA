@IsTest
private class InvitationServiceTest {
	@TestSetup
	static void makeData(){
		//also creates an account as part of testsetup
		insert TestDataFactory_Invitations.createDefaultInvitations(1);
	}

	@IsTest
	static void testInviteUsers(){
		Id portalApplicationId = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0).Id;
		//existing invitation
		Invitation__c existingInvitation = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(portalApplicationId, new Set<String>{TestDataFactory_Invitations.EMAILADDRESS}, new Set<Id>{}).get(0);

		//encode existing invitation__c records to encodedinvitation
		List<InvitationService.EncodedInvitation> invitationRequestList = new List<InvitationService.EncodedInvitation>();
		InvitationService.EncodedInvitation invitationRequest = new InvitationService.EncodedInvitation();
		invitationRequest.Id = existingInvitation.Id;
		invitationRequest.emailAddress = existingInvitation.Email__c;
		invitationRequest.portalApplicationId = existingInvitation.ServiceId__c;
		invitationRequest.userRole = existingInvitation.Role_Name__c;
		invitationRequest.accountId = existingInvitation.Account__c;
		invitationRequestList.add(invitationRequest);

		InvitationService.EncodedInvitation invitationRequest2 = new InvitationService.EncodedInvitation();
		
		invitationRequest2.emailAddress = existingInvitation.Email__c + 'second';
		invitationRequest2.portalApplicationId = existingInvitation.ServiceId__c;
		invitationRequest2.userRole = existingInvitation.Role_Name__c;
		invitationRequest2.accountId = existingInvitation.Account__c;
		invitationRequestList.add(invitationRequest2);

		InvitationService.inviteUsers(invitationRequestList);

		List<Invitation__c> invitationList = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(portalApplicationId, new Set<String>{''}, new Set<Id>{existingInvitation.Account__c});
		boolean isInvited = true;
		for(Invitation__c invitation : invitationList){
			if(!invitation.Status__c.equals('Active')){
				isInvited = false;
				break;
			}
		}
		System.assert(isInvited);
		System.assertEquals(2, invitationList.size());
	}

	@IsTest
	static void testCancelInvitation(){
		Id portalApplicationId = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0).Id;
		//existing invitation
		Invitation__c existingInvitation = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(portalApplicationId, new Set<String>{TestDataFactory_Invitations.EMAILADDRESS}, new Set<Id>{}).get(0);

		//encode existing invitation__c records to encodedinvitation
		List<InvitationService.EncodedInvitation> invitationRequestList = new List<InvitationService.EncodedInvitation>();
		InvitationService.EncodedInvitation invitationRequest = new InvitationService.EncodedInvitation();
		invitationRequest.Id = existingInvitation.Id;
		invitationRequest.emailAddress = existingInvitation.Email__c;
		invitationRequest.portalApplicationId = existingInvitation.ServiceId__c;
		invitationRequest.userRole = existingInvitation.Role_Name__c;
		invitationRequest.accountId = existingInvitation.Account__c;
		invitationRequestList.add(invitationRequest);
		InvitationService.cancelInvitation(invitationRequestList);

		List<Invitation__c> invitationList = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(portalApplicationId, new Set<String>{''}, new Set<Id>{existingInvitation.Account__c});
		boolean isInvitationCancelled = true;
		for(Invitation__c invitation : invitationList){
			if(!invitation.Status__c.equals('Cancelled')){
				isInvitationCancelled = false;
				break;
			}
		}
		System.assert(isInvitationCancelled);
		System.assertEquals(1, invitationList.size());
	}

	@IsTest
	static void testGetInvitationList(){
		Portal_Applications__c portalApplication = [SELECT Id FROM Portal_Applications__c WHERE Name = :TestDataFactory_PortalApplications.DEFAULTSERVICENAME];
		List<InvitationService.EncodedInvitation> encodedInvitationList = InvitationService.getInvitationList(portalApplication.Id);
		System.assertEquals(1, encodedInvitationList.size(), ' Expected 1 Portal Service');
	}

	//InvitationService.getInvitableRoles cannot be tested correctly because it relies 
	//on custom metadata configuration that may not always be present in the org because
	//it is configuration data and not reference data. This test class just calls the method 
	//with no meaningful assertions.
	@IsTest
	static void testGetInvitableRoles(){
		Id portalApplicationId = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0).Id;
		try{
			List<String> invitableRoleList = InvitationService.getInvitableRoles(portalApplicationId);
			System.assertNotEquals(null, invitableRoleList);
		} catch(Exception e){
			System.assert(false);
		}
	}

	@IsTest
	static void testInvitationRequestEquals(){
		InvitationService.EncodedInvitation invitationRequest1 = new InvitationService.EncodedInvitation();

		Portal_Applications__c portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		Account account = [SELECT Id FROM Account LIMIT 1];

		invitationRequest1.emailAddress = 'testEmailAddress';
		invitationRequest1.portalApplicationId = portalApplication.Id;
		invitationRequest1.userRole = 'testUserRole';
		invitationRequest1.accountId = account.Id;

		InvitationService.EncodedInvitation invitationRequest2 = new InvitationService.EncodedInvitation();
		invitationRequest2.emailAddress = 'testEmailAddress';
		invitationRequest2.portalApplicationId = portalApplication.Id;
		invitationRequest2.userRole = 'testUserRole';
		invitationRequest2.accountId = account.Id;

		System.assertEquals(invitationRequest1, invitationRequest2);
	}

	@IsTest
	static void testEncodeInvitation(){
		Id serviceId = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0).Id;
		Id accountId = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0).Id;
		List<Invitation__c> invitationList = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(serviceId, new Set<String>{''}, new Set<Id>{accountId});
		Invitation__c invitation = invitationList.get(0);
	
		List<InvitationService.EncodedInvitation> encodedInvitationList = InvitationService.encodeInvitation(invitationList);
		InvitationService.EncodedInvitation encodedInvitation = encodedInvitationList.get(0);

		System.assertEquals(invitation.ServiceId__c, encodedInvitation.portalApplicationId);
		System.assertEquals(invitation.Account__c, encodedInvitation.accountId);
		System.assertEquals(invitation.Email__c, encodedInvitation.emailAddress);
		System.assertEquals(invitation.Role_Name__c, encodedInvitation.userRole);
		System.assertEquals(invitation.Status__c, encodedInvitation.status);
	}

	@IsTest
	static void testDecodeInvitation(){
		Id serviceId = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0).Id;
		Id accountId = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0).Id;
		List<Invitation__c> invitationList = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(serviceId, new Set<String>{''}, new Set<Id>{accountId});
		Invitation__c invitation = invitationList.get(0);

		InvitationService.EncodedInvitation encodedInvitation = new InvitationService.EncodedInvitation();
		encodedInvitation.accountId = invitation.Account__c;
		encodedInvitation.emailAddress = invitation.Email__c;
		encodedInvitation.portalApplicationId = invitation.ServiceId__c;
		encodedInvitation.status = invitation.Status__c;
		encodedInvitation.userRole = invitation.Role_Name__c;

		List<InvitationService.EncodedInvitation> encodedInvitationList = new List<InvitationService.EncodedInvitation>{encodedInvitation};
		invitationList = InvitationService.decodeInvitation(encodedInvitationList);
	}

	@IsTest
	static void testIsServiceAdministrator(){
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Portal_Applications__c portalApplication = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0);
		portalApplication.Functional_Role__c = functionalRole;
		update portalApplication;

		Account account = [SELECT Id FROM Account].get(0);

		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = account.Id;
		insert contact;

		User user = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
		insert user;

		Account_Role__c accountRole = new Account_Role__c(Account__c = account.Id);
		accountRole.Functional_Role__c = functionalRole;
		insert accountRole;
		
		Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c(
			Contact__c = contact.Id,
			Status__c = accountContactRoles.STATUSACTIVE,
			Functional_Role__c = functionalRole,
			Account_Role__c = accountRole.Id,
			Is_Service_Administrator__c = TRUE
		);
		insert accountContactRole;

		Map<Id,Boolean> userIdIsServiceAdminMap = InvitationService.isServiceAdministrator(portalApplication.Id, new List<Id>{user.Id});
		System.assert(!userIdIsServiceAdminMap.isEmpty());
		System.assert(userIdIsServiceAdminMap.get(user.Id));
	}

	@IsTest
	static void testCheckForInvitations(){
		//create domain classes
		Invitations invitations = new Invitations();
		PortalApplications portalApplications = new PortalApplications();
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

		Portal_Applications__c portalApplication = portalApplications.createDefaultPortalApplications(1).get(0);
		portalApplication.Name = 'Test Portal Application';
		portalApplication.Functional_Role__c = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		insert portalApplication;

		Account account = [SELECT Id FROM Account LIMIT 1];

		//create contact with test email address
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = account.Id;
		insert contact;

		User user = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
		user.Contact = contact;
		user.Email = contact.Email;
		insert user;

		//get test invitation
		Invitation__c invitation = [SELECT Id, Email__c, ServiceId__c, Status__c FROM Invitation__c LIMIT 1];
		//update to match email address of contact
		invitation.Email__c = contact.Email;
		//update to match service Id to the inserted portalapplication
		invitation.ServiceId__c = portalApplication.Id;
		invitation.Status__c = invitations.ACTIVE;
		update invitation;

		//assert that PSA record is created for inserted contact and service with status active
		InvitationService.checkForInvitations(portalApplication.Id, user);
		Portal_Application_Right__c portalApplicationRight = [SELECT Id, Right__c FROM Portal_Application_Right__c WHERE Contact__c = :contact.Id AND Portal_Application__c = :portalApplication.Id].get(0);
		System.assertEquals(portalApplicationRights.ACCESSGRANTED, portalApplicationRight.Right__c);
	}

	@IsTest
	static void testGetUserContactRoleAccountId(){
		String functionalRole = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		Account account = [SELECT Id FROM Account LIMIT 1];
		contact.AccountId = account.Id;
		insert contact;

		User user = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
		insert user;

		Account_Role__c accountRole = TestDataFactory_AccountRoles.createAccountRoles(new List<Account>{account}, functionalRole).get(0);
		insert accountRole;

		Account_Contact_Role__c accountContactRole = TestDataFactory_AccountContactRoles.createDefaultAccountContactRole(contact.Id, accountRole.Id);
		accountContactRole.Functional_Role__c = functionalRole;
		insert accountContactRole;

		Portal_Applications__c portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		insert portalApplication;
		System.assertEquals(account.Id, InvitationService.getUserContactRoleAccountId(user.Id, portalApplication.Id));
	}
}