@isTest
public class SidraLiteManagerTest {

	private static final String PASSENGER = 'P';
	private static final String CARGO = 'R';
	private static final String TIDS_AGENT = 'T';
	private static final Map<String,String> MAP_TYPES = new Map<String,String>{
		PASSENGER => 'IATA Passenger Sales Agent',
		CARGO => 'IATA Cargo Agent',
		TIDS_AGENT => 'TIDS Agent'
	};

	public static Case createIFAPPassenger() {
		return createParentCase(SidraLiteManager.RECORDTYPE_IFAP, PASSENGER);
	}

	public static Case createIFAPCargo() {
		return createParentCase(SidraLiteManager.RECORDTYPE_IFAP, CARGO);
	}

	public static Case createSMAPPassenger() {
		return createParentCase(SidraLiteManager.RECORDTYPE_SMAP, PASSENGER);
	}

	public static Case createOSCARPassenger() {
		return createParentCase(SidraLiteManager.RECORDTYPE_OSCAR, PASSENGER);
	}

	public static Case createSAAMPassenger() {
		return createParentCase(SidraLiteManager.RECORDTYPE_SAAM, PASSENGER);
	}

	public static Case createSAAMCargo() {
		return createParentCase(SidraLiteManager.RECORDTYPE_SAAM, CARGO);
	}

	public static Case createSAAMAgent() {
		return createParentCase(SidraLiteManager.RECORDTYPE_SAAM, TIDS_AGENT);
	}

	public static Case createInvoicingPassenger() {
		return createParentCase(SidraLiteManager.RECORDTYPE_INVOICING, PASSENGER);
	}

	public static Case createInvoicingAgent() {
		return createParentCase(SidraLiteManager.RECORDTYPE_INVOICING, TIDS_AGENT);
	}

	public static Case createInvoicingCargo() {
		return createParentCase(SidraLiteManager.RECORDTYPE_INVOICING, CARGO);
	}

	public static Case createCNSAgent() {
		return createParentCase(SidraLiteManager.RECORDTYPE_CNS, CARGO);
	}

	private static Case createParentCase(Id recordtypeID, String type) {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name = 'Canada',
			ISO_Code__c = 'CA',
			AIMS_Area_Name__c = 'Canada',
			AIMS_Area_ID__c = '1',
			CNS_Country__c = (recordtypeId == SidraLiteManager.RECORDTYPE_CNS),
			ANG_Enable_NewGen__c = (recordtypeId == SidraLiteManager.RECORDTYPE_CNS)
		);
		insert country;

		Account account = new Account(
			Name = 'Test account',
			BillingCity = 'Montreal',
			BillingCountry = 'Canada',
			BillingStreet = 'some street',
			IATA_ISO_Country__c = country.Id,
			Location_Type__c = 'HO',
			IATACode__c = '1234567',
			Location_Class__c = type==TIDS_AGENT?PASSENGER: type
		);
		account.Type = MAP_TYPES.get(account.Location_Class__c);
		insert account;

		IATA_ISO_Country__c[] associatedCountry = [Select i.Name, i.Id From IATA_ISO_Country__c i where Name = :account.BillingCountry];
		System.assert((associatedCountry != null && associatedCountry.size() > 0));

		Contact contact = new Contact(
			RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'),
			FirstName = 'Dummy',
			LastName = 'Contact',
			Type_of_Contact__c = 'IFAP Contact',
			AccountId = account.Id,
			Email = 'some@email.org',
			Financial_Assessment_Contact__c = true
		);
		insert contact;

		Case cse;

		if(recordtypeId == SidraLiteManager.RECORDTYPE_CNS) {
			cse = new Case(
				RecordtypeId = recordtypeId,
				ContactId = contact.Id,
				AccountId = account.Id,
				Origin = 'IATA Internal User'
			);
		}
		else {
			cse = new Case(
			RecordtypeId = recordtypeId,
			BSPCountry__c = 'Canada',
			Subject = 'Test Case 1',
			Status = 'Agent to be Notified',
			Origin = 'Agent Financial Review Notification',
			Priority = 'Normal',
			Financial_Review_Type__c = 'New applications',
			IFAP_Financial_Year__c = String.valueOf(Date.today().year()),
			Deadline_Date__c = Date.today().addMonths(1),
			Agent_Code__c = '1234567',
			ContactId = contact.Id,
			AccountId = account.Id,
			Description = 'Test Case 1',
			Start_Date_of_Sales_Period__c = Date.today(),
			End_Date_of_Sales_Period__c = Date.today(),
			Next_Remittance_Date__c = Date.today(),
			Has_the_agent_paid_invoice__c = 'Not paid'
		);
		}


		if (type==TIDS_AGENT) {
			account.Location_Class__c = TIDS_AGENT;
			account.Type = MAP_TYPES.get(TIDS_AGENT);
			update account;
		}
		return cse;
	}

	private static Case createSIDRALite() {
		Case cse = new Case(
			RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE
		);
		return cse;
	}


	private static Case createIFAPCase() {
		Case cse = new Case(
			RecordtypeId = SidraLiteManager.RECORDTYPE_IFAP
		);
		return cse;
	}


	@isTest
	public static void testInsertSMAP() {
		Case smapCase = createSMAPPassenger();
		insert smapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.Reason1__c = 'Financial Security Request';
		sidraCase.ParentId = smapCase.Id;
		sidraCase.accountId = smapCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_CertificateDGR() {
		Case saamCase = createSAAMPassenger();
		saamCase.Reason1__c = 'Certificate DGR';
		saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_CertificateDGRDefaultPrev() {
		Case saamCase = createSAAMPassenger();
		saamCase.Reason1__c = 'Certificate DGR';
		saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		//set account as inactive
		Account acc = [Select Status__c from Account where id = :saamCase.accountId];
		acc.Status__c = 'Cash basis/no commission';
		update acc;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_AnnualFeesPassenger() {
		Case saamCase = createSAAMPassenger();
		saamCase.Reason1__c = 'Annual Fees';
		saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_AnnualFeesCargo() {
		Case saamCase = createSAAMCargo();
		saamCase.Reason1__c = 'Annual Fees';
		saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_AnnualFeesAgent() {
		Case saamCase = createSAAMAgent();
		saamCase.Reason1__c = 'Annual Fees';
		saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_AnnualFessAccountInactive() {
		Case saamCase = createSAAMAgent();
		saamCase.Reason1__c = 'Annual Fees';
		saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;
		//set account as inactive
		Account acc = [Select Status__c from Account where id = :saamCase.accountId];
		acc.Status__c = 'Cash basis/no commission';
		update acc;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_FSPassenger() {
		Case saamCase = createSAAMPassenger();
		saamCase.Reason1__c = 'Financial Security Renewal';
		saamCase.Bank_Guarantee_deadline__c = Date.today().addDays(-1);
		saamCase.Bank_Guarantee_received__c = null;
		saamCase.Bank_Guarantee_amount__c = '1';
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_FSCargo() {
		Case saamCase = createSAAMCargo();
		saamCase.Reason1__c = 'Financial Security Renewal';
		saamCase.Bank_Guarantee_deadline__c = Date.today().addDays(-1);
		saamCase.Bank_Guarantee_received__c = null;
		saamCase.Bank_Guarantee_amount__c = '1';
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_FSAccountInactive() {
		Case saamCase = createSAAMCargo();
		saamCase.Reason1__c = 'Financial Security Renewal';
		saamCase.Bank_Guarantee_deadline__c = Date.today().addDays(-1);
		saamCase.Bank_Guarantee_received__c = null;
		saamCase.Bank_Guarantee_amount__c = '1';
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		//set account as inactive
		Account acc = [Select Status__c from Account where id = :saamCase.accountId];
		acc.Status__c = 'Cash basis/no commission';
		update acc;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertSAAM_Other() {
		Case saamCase = createSAAMPassenger();
		insert saamCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = saamCase.Id;
		sidraCase.accountId = saamCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true,'Exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_PassengerAnnualFees() {
		Case invoicingCase = createInvoicingPassenger();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_PassengerAdminCharges() {
		Case invoicingCase = createInvoicingPassenger();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_CargoAgentAnnualFees() {
		Case invoicingCase = createInvoicingCargo();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Account account = [Select Category__c from Account where id = :invoicingCase.accountId];
		account.Category__c = 'IATA Cargo Agent';
		update account;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_CargoAgentAdminCharges() {
		Case invoicingCase = createInvoicingCargo();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Account account = [Select Category__c from Account where id = :invoicingCase.accountId];
		account.Category__c = 'IATA Cargo Agent';
		update account;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_CargoCASSAnnualFees() {
		Case invoicingCase = createInvoicingCargo();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Account account = [Select Category__c from Account where id = :invoicingCase.accountId];
		account.Category__c = 'CASS Associate';
		update account;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_CargoCASSAdminCharges() {
		Case invoicingCase = createInvoicingCargo();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Account account = [Select Category__c from Account where id = :invoicingCase.accountId];
		account.Category__c = 'CASS Associate';
		update account;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_AgentAnnualFees() {
		Case invoicingCase = createInvoicingAgent();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertInvoicing_AgentAdminCharges() {
		Case invoicingCase = createInvoicingAgent();
		invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
		insert invoicingCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = invoicingCase.Id;
		sidraCase.accountId = invoicingCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertOSCAR() {
		Case oscarCase = createOSCARPassenger();
		insert oscarCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = oscarCase.Id;
		sidraCase.accountId = oscarCase.accountId;

		Test.startTest();
		insert sidraCase;
		Test.stopTest();
	}

	@isTest
	public static void testInsertIFAPWithFALetterSent() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = false;
		ifapCase.Status = 'Financial Statements Uploaded';
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true,'Exception thrown: ' + e.getMessage());
		}
		Test.stopTest();

	}

	@isTest
	public static void testInsertIFAPWithFSLetterSent() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FS_Letter_Sent__c = false;
		ifapCase.Status = 'Financial Security Requested';
		//ifapCase.FS_Second_Deadline_Date__c = Date.today();
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		//Action
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testInsertIFAPCheckParentStatus() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Action Needed';
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFirstFSDeadlineOnly() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Second_Deadline_Date__c = Date.today();
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFSDeadlineIsEmpty() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Deadline_Date__c = null;
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFSDeadlineIsFutureDate() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Deadline_Date__c = Date.today().addDays(1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFirstFADeadlineOnly() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Statements Uploaded';
		ifapCase.Deadline_Date__c = Date.today().addDays(-1);
		ifapCase.FA_Second_Deadline_Date__c = Date.today();
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFADeadlineIsEmpty() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Statements Uploaded';
		ifapCase.Deadline_Date__c = null;
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFASanityCheck() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Sanity Check Failure';
		ifapCase.Deadline_Date__c = null;
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFAFinancialReview() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Change Deficiency';
		ifapCase.Deadline_Date__c = null;
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFADeadlineIsFutureDate() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Statements Uploaded';
		ifapCase.Deadline_Date__c = Date.today().addDays(1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFSWrongBSPValue() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;
		sidraCase.BSP_CASS__c = '';

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFSWrongCASSValue() {
		Case ifapCase = createIFAPCargo();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;
		sidraCase.BSP_CASS__c = '';

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFSWrongReasonValue() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;
		sidraCase.BSP_CASS__c = 'BSP';

		Test.startTest();
		try {
			insert sidraCase;
			System.assert(false,'Exception required');
		} catch (Exception e) {
			System.assert(true);
		}
		Test.stopTest();
	}

	@isTest
	public static void testIFAPFSPassengerOK() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;
		sidraCase.BSP_CASS__c = 'BSP';
		sidraCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';

		Test.startTest();
		insert sidraCase;
		Test.stopTest();

		//sidraCase = [Select Propose_Irregularity__c from Case Where id = :sidraCase.Id];
		//System.assertEquals(Date.today(),sidraCase.Propose_Irregularity__c);

		ifapCase = [Select FirstFSnonComplianceDate__c, FS_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
		System.assertEquals(Date.today(),ifapCase.FirstFSnonComplianceDate__c);
		System.assertEquals(Date.today().addDays(31),ifapCase.FS_Second_Deadline_Date__c);
	}

	@isTest
	public static void testIFAPFSCargoOK() {
		Case ifapCase = createIFAPCargo();
		ifapCase.FS_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Security Requested';
		ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;
		sidraCase.BSP_CASS__c = 'CASS';
		sidraCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';

		Test.startTest();
		insert sidraCase;
		Test.stopTest();

		sidraCase = [Select Propose_Irregularity__c from Case Where id = :sidraCase.Id];

		ifapCase = [Select FirstFSnonComplianceDate__c, FS_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
		System.assertEquals(Date.today().addDays(30),ifapCase.FS_Second_Deadline_Date__c);
	}

	@isTest
	public static void testIFAPFAPassengerOK() {
		Case ifapCase = createIFAPPassenger();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Statements Uploaded';
		ifapCase.Deadline_Date__c = Date.today().addDays(-1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;
		sidraCase.BSP_CASS__c = 'BSP';
		sidraCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';

		Test.startTest();
		insert sidraCase;
		Test.stopTest();

		ifapCase = [Select FirstFAnonComplianceDate__c, FA_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
		System.assertEquals(Date.today(),ifapCase.FirstFAnonComplianceDate__c);
		System.assertEquals(Date.today().addDays(31),ifapCase.FA_Second_Deadline_Date__c);
	}

	@isTest
	public static void testIFAPFACargoOK() {
		Case ifapCase = createIFAPCargo();
		ifapCase.FA_Letter_Sent__c = true;
		ifapCase.Status = 'Financial Statements Uploaded';
		ifapCase.Deadline_Date__c = Date.today().addDays(-1);
		insert ifapCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = ifapCase.Id;
		sidraCase.accountId = ifapCase.accountId;
		sidraCase.BSP_CASS__c = 'CASS';
		sidraCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';

		Test.startTest();
		insert sidraCase;
		Test.stopTest();

		ifapCase = [Select FirstFAnonComplianceDate__c, FA_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
		System.assertEquals(Date.today(),ifapCase.FirstFAnonComplianceDate__c);
		System.assertEquals(Date.today().addDays(30),ifapCase.FA_Second_Deadline_Date__c);
	}

	@isTest
	public static void testgetRelatedCaseSAAM() {
		Case parentCase = createSAAMPassenger();
		parentCase.Reason1__c = 'Certificate DGR';
		parentCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
		insert parentCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = parentCase.Id;
		sidraCase.accountId = parentCase.accountId;
		insert sidraCase;

		Test.startTest();
		SidraLiteManager.getRelatedCase(parentCase);
		Test.stopTest();
	}

	@isTest
	public static void testgetRelatedCaseInvoicingAnnualFees() {
		Case parentCase = createInvoicingPassenger();
		parentCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
		insert parentCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = parentCase.Id;
		sidraCase.accountId = parentCase.accountId;
		insert sidraCase;

		Test.startTest();
		SidraLiteManager.getRelatedCase(parentCase);
		Test.stopTest();
	}

	@isTest
	public static void testgetRelatedCaseInvoicingAdminCharges() {
		Case parentCase = createInvoicingPassenger();
		parentCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
		insert parentCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = parentCase.Id;
		sidraCase.accountId = parentCase.accountId;
		insert sidraCase;

		Test.startTest();
		SidraLiteManager.getRelatedCase(parentCase);
		Test.stopTest();
	}

	@isTest
	public static void testgetRelatedCaseSMAP() {
		Case parentCase = createSMAPPassenger();
		insert parentCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = parentCase.Id;
		sidraCase.accountId = parentCase.accountId;
		sidraCase.SIDRA_lite_Reason__c = 'Financial Security Non-compliance';
		insert sidraCase;

		Test.startTest();
		SidraLiteManager.getRelatedCase(parentCase);
		Test.stopTest();
	}

	@isTest
	public static void testgetRelatedCaseOSCAR() {
		Case parentCase = createOSCARPassenger();
		insert parentCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = parentCase.Id;
		sidraCase.accountId = parentCase.accountId;
		insert sidraCase;

		Test.startTest();
		SidraLiteManager.getRelatedCase(parentCase);
		Test.stopTest();
	}

	@isTest
	public static void testgetRelatedCaseERROR() {
		Case parentCase = new Case();
		insert parentCase;
		SidraLiteManager.BLOCK_EXECUTION = false;

		Test.startTest();
		SidraLiteManager.getRelatedCase(parentCase);
		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = parentCase.Id;
		sidraCase.accountId = parentCase.accountId;
		insert sidraCase;
		SidraLiteManager.getRelatedCase(parentCase);
		Test.stopTest();
	}

	@isTest
	public static void testcreateSidraForChinaAE() {

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name = 'China',
			ISO_Code__c = 'CN',
			AIMS_Area_Name__c = 'China',
			AIMS_Area_ID__c = '1',
			ANG_Enable_NewGen__c = true
		);
		insert country;

		Account accountHE = new Account(
			Name = 'Test account HE',
			BillingCity = 'China',
			BillingCountry = 'China',
			BillingStreet = 'some street',
			IATA_ISO_Country__c = country.Id,
			Location_Type__c = 'HE',
			IATACode__c = '1234567',
			Location_Class__c = PASSENGER,
			Type = MAP_TYPES.get(PASSENGER)
		);
		insert accountHE;

		Account accountAE = new Account(
			Name = 'Test account AE',
			ParentId = accountHE.id,
			BillingCity = 'China',
			BillingCountry = 'China',
			BillingStreet = 'some street',
			IATA_ISO_Country__c = country.Id,
			Location_Type__c = 'AE',
			IATACode__c = '1234567',
			Location_Class__c = PASSENGER,
			Type = MAP_TYPES.get(PASSENGER)
		);
		insert accountAE;


		Case oscarCase = createOSCARPassenger();
		oscarCase.AccountId = AccountAE.id;
		insert oscarCase;

		SidraLiteManager.BLOCK_EXECUTION = false;

		Case sidraCase = createSIDRALite();
		sidraCase.ParentId = oscarCase.Id;
		sidraCase.accountId = oscarCase.accountId;
		sidraCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
		insert sidraCase;

		case c = [SELECT Group_Single_Agent__c FROM CASE WHERE ID = :sidraCase.id];

		System.assertEquals('Single Agent', c.Group_Single_Agent__c);

	}

	//ACAMBAS - WMO-483: Begin
	@isTest
	public static void testSIDRACaseForCNS() {
		User testUser = getCNSUser();
		configureUserToCNS(testUser);

		System.RunAs(testUser) {
			Case cnsCase = createCNSAgent();
			insert cnsCase;
			SidraLiteManager.BLOCK_EXECUTION = false;

			Case sidraLiteCase = createSIDRALite();
			sidraLiteCase.ParentId = cnsCase.Id;
			sidraLiteCase.accountId = cnsCase.accountId;
			sidraLiteCase.CNSCase__c = true;
			sidraLiteCase.SIDRA_Lite_Reason__c = 'CNS Collection';

			Test.startTest();
			insert sidraLiteCase;
			Test.stopTest();

			sidraLiteCase = [Select CNSCase__c, SIDRA_Lite_Reason__c from Case Where id = :sidraLiteCase.Id];
			System.assertEquals(true, sidraLiteCase.CNSCase__c);
			System.assertEquals('CNS Collection', sidraLiteCase.SIDRA_Lite_Reason__c);
		}
	}


	@isTest
	public static void testIFAPCaseForCNS() {
		User testUser = getCNSUser();
		configureUserToCNS(testUser);

		System.RunAs(testUser) {
			Case cnsCase = createCNSAgent();
			insert cnsCase;
			SidraLiteManager.BLOCK_EXECUTION = false;

			Case iFAPCase = createIFAPCase();
			iFAPCase.ParentId = cnsCase.Id;
			iFAPCase.accountId = cnsCase.accountId;
			iFAPCase.CNSCase__c = true;

			Test.startTest();
			insert iFAPCase;
			Test.stopTest();

			iFAPCase = [Select CNSCase__c, SIDRA_Lite_Reason__c from Case Where id = :iFAPCase.Id];
			System.assertEquals(true, iFAPCase.CNSCase__c);
		}
	}


	public static User getCNSUser() {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		User testUser = New User(
			Alias = 'cnsUser', Email='cnsuser@test.com',
			EmailEncodingKey='UTF-8', LastName='CNSTest2', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='cnsuser@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);
		insert testUser;

		return testUser;
	}


	public static void configureUserToCNS(User testUser) {
		Group cnsGroup = [SELECT Id FROM Group WHERE DeveloperName = 'CNS_Collection_Process_Group' LIMIT 1];

		GroupMember gm = new GroupMember(UserOrGroupId = testUser.Id,
										 GroupId = cnsGroup.Id);
		insert gm;


		PermissionSet cnsPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CNS_Collection_Process_Super_User' LIMIT 1];

		List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
		PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = cnsPermissionSet.Id,
																	AssigneeId = testUser.Id);
		permissionSetList.add(psa);
		upsert permissionSetList;
	}
	//ACAMBAS - WMO-483: End

}
