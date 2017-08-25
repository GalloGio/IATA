public with sharing class ISSP_ANG_RHC {

	public Contact contact {get;set;}
	private static final String ICE_SERVICE = ISSP_Portal_Service_Ids__c.getInstance().ICE_E_Statements__c;
	public ANG_RHC_Information__c remittanceFrequency {get;set;}
	public Boolean hasRightAccessIceService { get {
		if (hasRightAccessIceService != null) {
			return hasRightAccessIceService;
		} else {
			hasRightAccessIceService = hasRightAccess(ICE_SERVICE);
			return hasRightAccessIceService;
		} 
	} set;}

	public ISSP_ANG_RHC() {
		setContact();
		initializeRemittanceFrequency();
	}

	private Boolean hasRightAccess(String service) {
		if (this.contact != null) {
			List <Portal_Application_Right__c> appRightList = [
				SELECT Id 
				  FROM Portal_Application_Right__c
			     WHERE Contact__c = :this.contact.Id
				   AND Right__c = :AMS_Utils.PORTAL_APP_ACCESS_GRANTED
				   AND Portal_Application__c = :service
			];
			return !appRightList.isEmpty();
		}
		return false;
	}

	private void setContact() {
		List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :Userinfo.getUserId()];
		Id contactId = userList.isEmpty() ? null : userList[0].ContactId;
		List<Contact> contactList = [SELECT Id, Account.Id, Account.Remittance_frequency__c FROM Contact WHERE Id = :contactId];
		this.contact = contactList.isEmpty() ? null : contactList[0];
	}

	private void initializeRemittanceFrequency() {
		List<ANG_RHC_Information__c> remittanceFrequencyList = [
			SELECT Id, 
				   ANG_RHC_Amount__c, 
				   ANG_ConsumedRHC__c, 
				   ANG_ConsumedRHC_Percent__c, 
				   ANG_ConsumedRHC_Last_Update__c, 
				   ANG_Financial_Security__c
			  FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c = :this.contact.Account.Id
		];
		this.remittanceFrequency = remittanceFrequencyList.isEmpty() ? null : remittanceFrequencyList[0];
	}
	
}