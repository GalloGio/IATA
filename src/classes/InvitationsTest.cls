@IsTest
private class InvitationsTest {
	@TestSetup
	static void makeData(){
		insert TestDataFactory_Invitations.createDefaultInvitations(1);
	}

	@IsTest
	static void testInit(){
		Invitations invitations = new Invitations();
		System.assertEquals(0, invitations.records.size());

		List<Invitation__c> invitationList = [SELECT Id FROM Invitation__c];
		invitations = new Invitations(invitationList);
		System.assertEquals(1, invitations.records.size());
	}

	@IsTest
	static void testUpdateStatus(){
		List<Invitation__c> invitationList = [SELECT Id FROM Invitation__c];
		Invitations invitations = new Invitations(invitationList);
		invitations.updateStatus(invitations.COMPLETED);
		update invitations.records;

		System.assertEquals(invitations.COMPLETED, [SELECT Id, Status__c FROM Invitation__c].get(0).Status__c);
	}
}