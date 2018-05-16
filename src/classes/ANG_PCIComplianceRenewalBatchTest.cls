@isTest
public with sharing class ANG_PCIComplianceRenewalBatchTest {
	
	@isTest static void testPCIComplianceRenewaOSCARcreation() {
		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', 
															Region__c = 'Americas', 
															Case_BSP_Country__c= 'Canada',
															ANG_Enable_NewGen__c = true
															);
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, 
			Sent_to_external_system__c = true, 
			IATACode__c = '12345678', 
			Location_Class__c='P',
			Status__c= AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
			Is_PCI_compliant__c = 'Yes',
			Location_Type__c = AMS_Utils.HE,
			ANG_PCI_compliance_expiry_date__c = Date.today().addDays(90)
		);


		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', 
									Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin',
									Preferred_Language__c = 'English', Financial_Assessment_Contact__c = false);	
		insert co1;

		Test.startTest();
		
		Database.executeBatch(new ANG_PCIComplianceRenewalBatch(),200);

		Test.stopTest();

		System.assertEquals([SELECT Id FROM AMS_OSCAR__c WHERE Account__c = :a1.Id AND Process__c = :AMS_Utils.NGFOP].size(), 1, 'FOP oscar was not created');
	}

	@isTest static void testPCIComplianceRenewaOSCARcreationNoContact() {

		//create custom settings for support email
		SalesforceSupportEmails__c supportEmail = new SalesforceSupportEmails__c(name='test', Support_Email__c='test@iata.org');
		insert supportEmail;

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', 
															Region__c = 'Americas', 
															Case_BSP_Country__c= 'Canada',
															ANG_Enable_NewGen__c = true
															);
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, 
			Sent_to_external_system__c = true, 
			IATACode__c = '12345678', 
			Location_Class__c='P',
			Status__c= AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
			Is_PCI_compliant__c = 'Yes',
			Location_Type__c = AMS_Utils.HE,
			ANG_PCI_compliance_expiry_date__c = Date.today().addDays(90)
		);

		agencylist.add(a1);
		insert agencylist;

		Test.startTest();
		
		Database.executeBatch(new ANG_PCIComplianceRenewalBatch(),200);

		Test.stopTest();

		System.assertEquals([SELECT Id FROM AMS_OSCAR__c WHERE Account__c = :a1.Id AND Process__c = :AMS_Utils.NGFOP].size(), 0, 'NO FOP OSCAR should be created');
	}

	@isTest
    public static void testBatchScheduler(){
    	Test.startTest();
    	ANG_PCIComplianceRenewalScheduler sch = new ANG_PCIComplianceRenewalScheduler ();
    	String cronExp = '0 0 7 1/1 * ? *'; 
    	system.schedule('Test ANG_PCIComplianceRenewalScheduler', cronExp, sch);
    	test.StopTest();
    }
}