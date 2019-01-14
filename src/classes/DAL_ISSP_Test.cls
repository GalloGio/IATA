@isTest
public with sharing class DAL_ISSP_Test {

	static testMethod void test_getUser() {
		DAL_ISSP.getUser('00511000001nKHK');
		DAL_ISSP.getUser(null);
		DAL_ISSP.getUser(UserInfo.getUserId());
		DAL_ISSP.getLoginHistoryByUserId(UserInfo.getUserId());
		DAL_ISSP.getUserListByNameOrEmail(UserInfo.getUsername());
	}
	
	static testMethod void test_getContact() {
		Contact contact = new Contact(FirstName='Name', LastName='test');
		insert contact;
		
		Contact con = DAL_ISSP.getContact(contact.Id);
		system.assertEquals('test', contact.LastName);
		DAL_ISSP.getContact(null);
		
		DAL_ISSP.getContact(contact.Id);
	}
	
	static testMethod void test_getPortalAdmins() {
		Account account = new Account(Name='test');
		insert account;
		List<AccountTeamMember> admins = ISSP_PersonalInformationWithoutSharing.getPortalAdmins(new ID[] {account.Id});
		system.assertEquals(0, admins.size());
		DAL_ISSP.getPortalAdmins(account.Id);
		//list<ID> emptyList = null;
		//ISSP_PersonalInformationWithoutSharing.getPortalAdmins(emptyList);
	}
	
	
	static testMethod void test_getCase() {
		Case cas = DAL_ISSP.getCase('');
		system.assertEquals(null, cas);
		DAL_ISSP.getCase(null);
		
		Account account = ISSP_ObjectFactory.createNewAccount();
        account.Name = 'Account1';
        insert account;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        insert contact;
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
        Case c = new Case(Subject='test 1',Status='Open', AccountId=account.id, ContactId=contact.id,Region__c = 'Europe', RecordTypeId = recordTypeId);
        insert c;
        DAL_ISSP.getCase(c.Id);
	}
}