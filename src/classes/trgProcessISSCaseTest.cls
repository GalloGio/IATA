@isTest
private class trgProcessISSCaseTest {

	@testSetup static void setupInit() {
		// create Sam case
		RecordType IFAPcaseRecordType = ams_utils.getRecordType('Case', 'IATA_Financial_Review');

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
		    Name = 'Canada',
		    ISO_Code__c = 'CA',
		    AIMS_Area_Name__c = 'Canada',
		    AIMS_Area_ID__c = '1'
		);
		insert country;

		// create test account1
		Account account1 = new Account(
		    Name = 'Test account',
		    IATACode__c = '4242424',
		    Type = 'IATA Passenger Sales Agent',
		    BillingCity = 'Montreal',
		    BillingCountry = 'Canada',
		    BillingStreet = 'some street',
		    IATA_ISO_Country__c = country.Id,
		    Location_Type__c = 'HO');
		insert account1;

		// create test contact
		Contact contact1 = new Contact(
		    FirstName = 'Dummy',
		    LastName = 'Contact',
		    Type_of_Contact__c = 'IFAP Contact',
		    AccountId = account1.Id,
		    Email = 'some@email.org',
		    Financial_Assessment_Contact__c = true);
		insert contact1;

		//create parent ifapCase
		Case ifapCase = new Case(
		    ContactId = contact1.Id,
		    AccountId = account1.Id,
		    Subject = 'ifapCase',
		    Description = 'Test ifapCase case',
		    Status = 'Open',
		    RecordTypeId = IFAPcaseRecordType.Id,
		    Reason1__c = 'New HO',
		    IFAP_Financial_Year__c = String.valueOf(Date.today().year()));
		insert ifapCase;



	}

	@isTest static void insertFirstBRuleSaamCase() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Agent Notified (Mail)';
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'New HO');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FA Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed.') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);

		}
		test.StopTest();
	}

	@isTest static void insertSecondBRuleSaamCase() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'New HO');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);

		}
		test.StopTest();
	}

	@isTest static void insertThirdBRuleSaamCase() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];

		test.StartTest();
		try {
			parentCase.Status = 'Action Needed';
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'New HO');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('A Non-compliance case cannot be created when the parent case status is ' + parentCase.Status) ? true : false;
			system.assertEquals(expectedExceptionThrown, true);

		}
		test.StopTest();
	}

	@isTest static void assignNonComplianceDatesErr() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Action Needed';
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    New_IFAP_Deadline_date__c = system.today(),
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The New IFAP Deadline date must be empty for non-compliance cases on Passenger and Domestic agents') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);

		}
		test.StopTest();
	}

	@isTest static void assignNonComplianceDatesDeadlineErr() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			//parentCase.firstFSnonComplianceDate__c = Date.today() + 1;
			parentCase.FS_Deadline_Date__c = Date.today() + 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 1st FS non-compliance case. The 1st FS Deadline is ') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void isDomestic() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void isCargoCASSnoDeadline() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void isCargoCASSDeadline() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;			
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process',
				New_IFAP_Deadline_date__c = Date.today());
			insert saamCase;
			} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}


	@isTest static void secondFSnonCompliance() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			parentCase.firstFSnonComplianceDate__c = Date.today();
			parentCase.FS_Second_Deadline_Date__c = Date.today() + 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 2nd FS non-compliance case. The 2nd FS Deadline is ') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void secondFSnonComplianceIsPassenger() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			parentCase.firstFSnonComplianceDate__c = Date.today();
			parentCase.FS_Second_Deadline_Date__c = Date.today() - 1 ;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}
	@isTest static void secondFSnonComplianceisCargoCASSnoDeadline() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			parentCase.firstFSnonComplianceDate__c = Date.today();
			parentCase.FS_Second_Deadline_Date__c = Date.today() - 1 ;
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void secondFSnonComplianceisCargoCASSDeadline() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			parentCase.firstFSnonComplianceDate__c = Date.today();
			parentCase.FS_Second_Deadline_Date__c = Date.today() - 1 ;
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;			
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process',
				New_IFAP_Deadline_date__c = Date.today());
			insert saamCase;
			} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void thirdFSnonCompliance() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Status = 'Financial Security Requested';
			parentCase.firstFSnonComplianceDate__c = Date.today();
			parentCase.secondFSnonComplianceDate__c = Date.today();
			parentCase.FS_Second_Deadline_Date__c = Date.today() + 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 3rd FS non-compliance case.') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}	

	@isTest static void firstFAnonCompliance() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Deadline_Date__c = Date.today() + 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 1st FA non-compliance case. The 1st FA Deadline is ') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void firstFAnonComplianceDomestic() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.Deadline_Date__c = Date.today() - 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 1st FA non-compliance case. The 1st FA Deadline is ') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void firstFAnonComplianceisCargoCASSnoDeadline() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.Deadline_Date__c = Date.today() -1;
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void firstFAnonComplianceisCargoCASSDeadline() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.Deadline_Date__c = Date.today() -1;
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;			
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process',
				New_IFAP_Deadline_date__c = Date.today());
			insert saamCase;
			} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void secondFAnonCompliance() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.firstFAnonComplianceDate__c = Date.today();
			parentCase.Deadline_Date__c = Date.today();
			parentCase.FA_Second_Deadline_Date__c = Date.today() + 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 2nd FA non-compliance case. The 2nd FA Deadline is ') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void secondFAnonComplianceDomestic() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.firstFAnonComplianceDate__c = Date.today();
			parentCase.Deadline_Date__c = Date.today()-2;
			parentCase.FA_Second_Deadline_Date__c = Date.today() - 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('A Non-compliance case cannot be updated when the parent case status is') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}


	@isTest static void secondFAnonComplianceCargoCASS() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.firstFAnonComplianceDate__c = Date.today();
			parentCase.Deadline_Date__c = Date.today()-2;
			parentCase.FA_Second_Deadline_Date__c = Date.today()-1;			
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The New IFAP Deadline date is mandatory when creating a 2nd non-compliance for Cargo or CASS agents.') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void secondFAnonComplianceCargoCASSDeadline() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		Account acc = [Select id, Type, IATACode__c from Account where IATACode__c = '4242424'];
		test.StartTest();
		try {
			parentCase.firstFAnonComplianceDate__c = Date.today();
			parentCase.Deadline_Date__c = Date.today()-2;
			parentCase.FA_Second_Deadline_Date__c = Date.today() -1 ;			
			acc.Type = 'CASS Associate';
			update parentCase;
			update acc;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process',
			    New_IFAP_Deadline_date__c = Date.today());
			insert saamCase;

		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}
	
	@isTest static void thirdFAnonComplianceDomestic() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.firstFAnonComplianceDate__c = Date.today();
			parentCase.Deadline_Date__c = Date.today();
			parentCase.secondFAnonComplianceDate__c = Date.today();
			parentCase.FA_Second_Deadline_Date__c = Date.today();
			parentCase.FA_Third_Deadline_Date__c = Date.today() + 1;
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 3rd FA non-compliance case. The 3rd FA Deadline is ') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}

	@isTest static void fourthFAnonComplianceDomestic() {
		RecordType SAAMcaseRecordType = ams_utils.getRecordType('Case', 'ProcessEuropeSCE');
		Case parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Account.id, c.Contact.id,  c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Subject = 'ifapCase'];
		test.StartTest();
		try {
			parentCase.firstFAnonComplianceDate__c = Date.today();
			parentCase.Deadline_Date__c = Date.today();
			parentCase.secondFAnonComplianceDate__c = Date.today();
			parentCase.FA_Second_Deadline_Date__c = Date.today();
			parentCase.Third_FA_non_Compliance_Date__c = Date.today();
			parentCase.FA_Third_Deadline_Date__c = Date.today();
			update parentCase;
			Case saamCase = new Case(
			    ContactId = parentCase.Contact.id,
			    AccountId = parentCase.Account.Id,
			    Subject = 'Test SAAM case',
			    Description = 'Test SAAM case',
			    Status = 'Open',
			    ParentId = parentCase.id,
			    RecordTypeId = SAAMcaseRecordType.Id,
			    Reason1__c = 'FA/ FS Non-Compliance',
			    Origin = 'Internal Case',
			    CaseArea__c = 'Accreditation Process');
			insert saamCase;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create a 4th FA non-compliance case.') ? true : false;
			system.assertEquals(expectedExceptionThrown, true);
		}
		test.StopTest();
	}




}