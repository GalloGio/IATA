@isTest
private class AMS_OSCAR_MassActionTest {

	@testSetup static void setup() {
		/*** Set IATA ISO Country ***/
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Country';
		country.ISO_Code__c = 'CC';
		country.ISO_Code_Numeric__c = 11;
		country.Region__c = 'Europe';
		insert country;

		/*** Set Account ***/
		Account acc = new Account();
		acc.Name = 'Name';
		acc.Legal_name__c = 'Legal';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		acc.IATA_ISO_Country__c = country.Id;
		insert acc;

		/*** Set Contact ***/
		Contact con = new Contact();
		con.FirstName = 'First';
		con.LastName = 'Last';
		con.User_Portal_Status__c = 'Approved Admin';
		con.Email = 'test@mail.com';
		con.AccountId = acc.Id;
		insert con;
	}
	
	@isTest static void test_process_pci() {
		Account acc = [SELECT Id FROM Account];
		Test.startTest();
		
		AMS_OSCAR__c oscar = new AMS_OSCAR__c();
		oscar.RecordTypeId = AMS_Utils.RECTYPE_CERT;
		oscar.Account__c = acc.Id;
		oscar.Process__c = AMS_Utils.PCI_COMPLIANT;
		insert oscar;

		Case cse = new Case();
		cse.Subject = 'PCI DSS Compliant';
		cse.OSCAR__c = oscar.Id;
		cse.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
		cse.CaseArea__c = 'Accreditation Process';
		cse.Reason1__c = 'PCI DSS Compliant';
		cse.Region__c = 'Europe';
		insert cse;

		AMS_PCI_Compliant_Mass_OSCAR_CreationCtr ctr = new AMS_PCI_Compliant_Mass_OSCAR_CreationCtr();
		ctr.operation = 'PCI_C';
		ctr.csvFileContent = 'Record Id\n' + oscar.Id;
		ctr.uploadFile();
		Test.stopTest();
	}
	
	@isTest static void test_create_vr() {
		Account acc = [SELECT Id FROM Account];
		Test.startTest();		
		AMS_PCI_Compliant_Mass_OSCAR_CreationCtr ctr = new AMS_PCI_Compliant_Mass_OSCAR_CreationCtr();
		ctr.operation = 'CVR';
		ctr.csvFileContent = 'Record Id\n' + acc.Id;
		ctr.uploadFile(); 
		Test.stopTest();
	}
	
}