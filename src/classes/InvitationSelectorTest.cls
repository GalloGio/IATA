@IsTest
private class InvitationSelectorTest {
	@TestSetup
	static void makeData(){
		insert TestDataFactory_Invitations.createDefaultInvitations(1);
	}

	@IsTest
	static void testSelectIdById(){
		Invitation__c invitation = [SELECT Id FROM Invitation__c WHERE Email__c = :TestDataFactory_Invitations.EMAILADDRESS];
		System.assertEquals(invitation.Id, InvitationSelector.selectIdById(new Set<Id>{invitation.Id}).get(0).Id, 'Expected Id to be ' + invitation.Id);
	}
	
	@IsTest
	static void testSelectByServiceIdAndEmailSetOrAccountSet(){
		Invitation__c expectedInvitation = [SELECT Id, ServiceId__c, Email__c, Account__c, Role_Name__c, Status__c FROM Invitation__c WHERE Email__c = :TestDataFactory_Invitations.EMAILADDRESS];
		Invitation__c actualInvitation = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(
			expectedInvitation.ServiceId__c,
			new Set<String>{expectedInvitation.Email__c}, 
			new Set<Id>{expectedInvitation.Account__c}
		).get(0);
		
		System.assertEquals(expectedInvitation.ServiceId__c, actualInvitation.ServiceId__c);
		System.assertEquals(expectedInvitation.Email__c, actualInvitation.Email__c);
		System.assertEquals(expectedInvitation.Account__c, actualInvitation.Account__c);
		System.assertEquals(expectedInvitation.Role_Name__c, actualInvitation.Role_Name__c);
		System.assertEquals(expectedInvitation.Status__c, actualInvitation.Status__c);
	}

	@IsTest
	static void testSelectMapByServiceIdEmailSetAndStatus(){
		//List<Invitation__c> selectMapByServiceIdEmailSetAndStatus(Id serviceId, Set<String> emailAddressSet, String status)
		Invitation__c invitation = [SELECT Id, Email__c, ServiceId__c, Status__c FROM Invitation__c LIMIT 1];
		Invitation__c retreivedInvitation = InvitationSelector.selectMapByServiceIdEmailSetAndStatus(invitation.ServiceId__c, new Set<String>{invitation.Email__c}, invitation.Status__c).get(0);
		System.assertNotEquals(null, retreivedInvitation);
	}


	@IsTest
	static void testSelectInvitationsByEmailSetAndStatus(){
		Invitations invitations = new Invitations();
		Invitation__c invitation = [SELECT Id, Email__c, Status__c FROM Invitation__c LIMIT 1];
		invitation.Status__c = invitations.ACTIVE;
		update invitation;

		System.assertEquals(1, InvitationSelector.selectInvitationsByEmailSetAndStatus(new Set<String>{invitation.Email__c}, invitations.ACTIVE).size());
	}

	@IsTest
	static void testSelectQuery(){
		Invitation__c expectedInvitation = [SELECT Id, Email__c FROM Invitation__c WHERE Email__c = :TestDataFactory_Invitations.EMAILADDRESS];
		Invitation__c actualInvitation = InvitationSelector.selectQuery('Id, Email__c', 'Email__c = \'' + TestDataFactory_Invitations.EMAILADDRESS + '\' AND Id ', new Set<Id>{expectedInvitation.Id}).get(0);
		System.assertEquals(TestDataFactory_Invitations.EMAILADDRESS, actualInvitation.Email__c, 'Unexpected email address: ' + actualInvitation.Email__c);
	}
}