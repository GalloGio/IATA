public with sharing class EF_InvitationCtrl {
	@AuraEnabled(cacheable=true)
	public static Portal_Applications__c getService() {
		return [SELECT Id FROM Portal_Applications__c WHERE Name = 'E&F APPS'];
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, String> getAccountRoles(Id contactId) {
		Map<String, String> accountToRoles = new Map<String, String>();

		List<E_and_F_Account_Role_Detail__c> accountRoles = EF_Helper.getAccountContactRoles(contactId);
		for(E_and_F_Account_Role_Detail__c role : accountRoles) {
			accountToRoles.put(role.Account_Role__r.Account_Name__c, role.Account_Role__c+':'+role.Account_Role__r.Account__c);
		}
		return accountToRoles;
	}

	@AuraEnabled
	public static void createInvite(Map<String, String> fields){
		//sending to a helper, because of sharing
		EF_Helper.createInvite(fields);

		sendEmail(fields.get('Email__c'), fields.get('ServiceId__c'));
	}

	private static void sendEmail(String emailAddress, String serviceId) {

		List<User> userList = [SELECT Id, ContactId FROM User WHERE Email =: emailAddress];

		Id toWhom = UserInfo.getUserId();
		if(!userList.isEmpty()) toWhom = userList[0].Id;

		PortalRegistrationFirstLevelCtrl.sendEmailVF(emailAddress, 'Welcome_to_E_F', generateParams(serviceId), toWhom);
	}

	private static Map<String,String> generateParams(String serviceId){
		String headerImageName = Label.CSP_Email_Header_Image;
		String footerImageName = Label.CSP_Email_Footer_Image;
		String headerImageUrl;
		String footerImageUrl;
		Map<String,Id> docNameIdMap = new Map<String,Id>();
		for(Document doc : [Select id, name From Document Where name = :headerImageName or name= :footerImageName]){
			docNameIdMap.put(doc.name,doc.id);
		}

		URL base = System.URL.getSalesforceBaseUrl();
		String documentURL = base.getProtocol()+'://'+base.getHost().remove('-api' )+'/servlet/servlet.ImageServer?id=#id#&oid='+userinfo.getorganizationid();
		if(docNameIdMap.get(headerImageName) != null) headerImageUrl = documentURL.replace('#id#', docNameIdMap.get(headerImageName));
		if(docNameIdMap.get(footerImageName) != null) footerImageUrl = documentURL.replace('#id#', docNameIdMap.get(footerImageName));

		String invitationLink = CSP_Utils.generateURl('manage-service', null, null, new Map<String, String>{'serviceId' => serviceId});

		Map<String, String> params = new map<String, String>{
				'!!HeaderUrl!'                                   => headerImageUrl,
				'!!FooterUrl!'                                   => footerImageUrl,
				'!!invitationLink!'                              => invitationLink
		};

		return params;
	}

}