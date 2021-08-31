@IsTest
public class TestDataFactory_Invitations {
	public static final String EMAILADDRESS = 'email.address@domain.xyz';

	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Portal_Applications__c portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		insert portalApplication;
	}

	public static List<Invitation__c> createDefaultInvitations(Integer numberOfRecords){
		makeData();
		Invitations invitations = new Invitations();
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		Portal_Applications__c portalApplication = PortalApplicationSelector.selectFunctionalRoleMapByServiceNameSet(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).values().get(0);

		List<Invitation__c> invitationList = invitations.createDefaultInvitation(numberOfRecords);
		for(Invitation__c invitation : invitationList){
			invitation.Email__c = EMAILADDRESS;
			invitation.ServiceId__c = portalApplication.Id;
			invitation.Account__c = account.Id;
			invitation.Status__c = invitations.ACTIVE;
		}
		return invitationList;
	}
}