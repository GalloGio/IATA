@isTest
private class AMS_PCI_Batch_Remainder_Test {

	static testMethod void runStartTest() {

		Test.startTest();
		AMS_PCI_Batch_Remainder ctrl = new AMS_PCI_Batch_Remainder();
		AMS_PCI_Batch_Remainder.start('0 1 * * * ?', 1);
		AMS_PCI_Batch_Remainder.stop();
		Database.executeBatch(ctrl, 1);
		
		Case cse = (Case) JSON.deserialize('{"CreatedDate":"2018-04-13"}', Case.class);
		cse.Id = '5009E000007bz32';
		cse.Subject = 'PCI DSS Compliant';
		cse.ContactId = UserInfo.getUserId();
		cse.Contact = (Contact) JSON.deserialize('{"Name":"First Last", "Preferred_Language__c":"English", "Id":"'+cse.ContactId+'"}', Contact.class);
		List<Case> cases = new List<Case> {cse};

		List<EmailTemplate> templates = AMS_PCI_Batch_Remainder.getEmailTemplates('AMS_PCI_Compliant_reminder_%');
		Map<String, EmailTemplate> mapTemplates = new Map<String, EmailTemplate>();
		for(EmailTemplate template : templates) {
			mapTemplates.put(template.DeveloperName, template);
		}

		Map<Id,User> contactUserMap = new Map<Id,User> {UserInfo.getUserId() => new User(Id= UserInfo.getUserId(), Email= UserInfo.getUserEmail())};

		AMS_PCI_Batch_Remainder.sendNotification(cases, AMS_PCI_Batch_Remainder.getOrgEmailAddressId('agencymanagement@iata.org'), mapTemplates, contactUserMap, new List<AMS_PCI_Batch_Remainder.ResultWrapper>());
		AMS_PCI_Batch_Remainder.sendNotification(cases, AMS_PCI_Batch_Remainder.getOrgEmailAddressId('agencymanagement@iata.org'), new Map<String, EmailTemplate>(), contactUserMap, new List<AMS_PCI_Batch_Remainder.ResultWrapper>());
		ctrl.execute(null, cases);
		Test.stopTest();
	}	

}