@isTest
private class ANG_IFAPNotificationsControllerTest {

	@isTest static void keyMulticountryIfapNotificationsTest(){

		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);
		insert bspPT;

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();
		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;
		countryPT.Multicountry_Enabled__c = true;
		insert countryPT;

		Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account accountGE = new Account();
		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = agencyRecordTypeId;
		accountGE.IATACode__c = '99999999';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountGE.Type = 'IATA Passenger Sales Agent';
		insert accountGE;

		Contact cont = new Contact(
			AccountId = accountGE.Id,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'richard.vaughan@test.com',
			Financial_Assessment_Contact__c = true
		);
		insert cont;

		Id ifapCaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

		Case ifap = new Case();
		ifap.AccountId = accountGE.Id;
		ifap.ContactId = cont.Id;
		ifap.Subject = 'IFAP Multicountry';
		ifap.Status = 'Financial Security Requested';
		ifap.RecordTypeId = ifapCaseRecordTypeId;
		ifap.IFAP_Financial_Year__c = String.valueOf(Date.today().year());
		ifap.ArchivedDate__c = Date.today();
		ifap.Financial_Review_Type__c = 'Multicountry Annual';
		insert ifap;

		Test.startTest();

		PageReference pageRef = Page.ANG_IFAP_Notifications;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdController = new ApexPages.StandardController(ifap);

		ANG_IFAPNotificationsController ctrl = new ANG_IFAPNotificationsController(stdController);

		ctrl.setNotificationMessage();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		System.assertEquals(0, pageMessages.size());

		accountGE.Identify_as_Multicountry_Key_Hierarchy__c = true;
		update accountGE;

		stdController = new ApexPages.StandardController(ifap);

		ctrl = new ANG_IFAPNotificationsController(stdController);

		ctrl.setNotificationMessage();

		findApexPagesMessage(ANG_IFAPNotificationsController.IFAP_RELATED_KEY_MULTICOUNTRY_MSG);

		Test.stopTest();
		}

		private static Boolean findApexPagesMessage(String expectedMessage){

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		System.assertNotEquals(0, pageMessages.size());

		Boolean messageFound = false;

		for(ApexPages.Message message : pageMessages){
			if(message.getDetail().contains(expectedMessage)){
				return true;
			}
		}

		return false;

	}

}
