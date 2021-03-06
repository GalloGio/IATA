@isTest
private class AMS_Batch_Progress_Bar_Controller_Test
{

	@testSetup static void setup() {

		ID certRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATION'); //FM AMSU-113

		DateTime dt = system.now()+90;
		Date d = date.newinstance(dt.year(), dt.month(), dt.day());

		System.debug('d: ' + d);



		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
		countrylist.add(isoc1);
		insert countrylist;

		List<Account> agencylist = new List<Account>();
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account a1 = new Account(Name='Test1 Agency', RecordtypeId=agencyRT,
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true,
			IATACode__c = '12345678', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED,
			Is_PCI_compliant__c = 'No', ANG_PCI_compliance_expiry_date__c = d);

		agencylist.add(a1);

		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
		Contact co2 = new Contact(AccountId = a1.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
		Contact co3 = new Contact(AccountId = a1.id, Firstname = 'teste3', Lastname='test3', Phone = '911111113', MobilePhone = '911111113', Email = 'test3@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved');

		List<Contact> cos = new List<Contact>{co1,co2};
		insert cos;
	}

	@isTest
	static void batchStatusBarTest(){
		Set<Id> filteredAccounts = new Map<Id, Account>([select id from Account where Name='Test1 Agency']).keySet();

		AMS_PCI_Complaint_Batch batchClass = new AMS_PCI_Complaint_Batch(1, filteredAccounts);

		id batchInstance=database.executeBatch(batchClass);

		test.startTest();

		AMS_Batch_Progress_Bar_Controller controller = new AMS_Batch_Progress_Bar_Controller();
		controller.batchId = batchInstance;
		controller.IsCompleted  = false;
		controller.getBatchJobs();

		batchClass = new AMS_PCI_Complaint_Batch(1, filteredAccounts);
		id batchInstance2=database.executeBatch(batchClass);

		controller.batchId = batchInstance2;
		controller.getBatchJobs();

		test.stopTest();
	}//END batchStatusBarTest
}
