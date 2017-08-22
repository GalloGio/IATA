public with sharing class ISSP_ANG_RHC {

	private Contact contact;
	private static final String ICE_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().ICE_E_Statements__c;

	public ISSP_ANG_RHC() {
		
	}

	public void initActions() {
		setContact();
	}

	private Boolean hasRightAccess(String service) {
		if (this.contact != null) {
			List <Portal_Application_Right__c> appRightList = [
				SELECT Id 
				  FROM Portal_Application_Right__c
			     WHERE Contact__c = :this.contact.Id
				   AND Right__c = 'Access Granted'
				   AND Portal_Application__c = :service
			];
			return !appRightList.isEmpty();
		}
		return false;
	}

	private void setContact() {
		List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :Userinfo.getUserId()];
		Id contactId = userList.isEmpty() ? null : userList[0].ContactId;
		List<Contact> contactList = [SELECT Id, Account.Id  FROM Contact WHERE Id = :contactId];
		this.contact = contactList.isEmpty() ? null : contactList[0];
	}
}