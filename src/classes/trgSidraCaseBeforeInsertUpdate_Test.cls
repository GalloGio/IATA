@isTest
public class trgSidraCaseBeforeInsertUpdate_Test {
	public final static string SMALLAMOUNT = 'Small Amount (<50USD)';
	public final static string MINORPOLICY = 'Minor error policy';


	@isTest
	static void TestSidraCases() {
		Case aCase;
		integer c = 0;
		ID SidraPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');

		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			Settlement_Model__c = 'Funds Received'
		);

		insert bspSG;
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
									IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
									IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
									IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
									Enable_Minor_Changes_from_Portal__c = true, AMS_Settlement_System__c = bspSG.id,
									Local_language_Agency_details_required__c = true);
		insert country;

		Account account1 = new Account(IATACode__c = '1234567');    // 7 digits
		account1.Name = 'Test account';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.Location_Type__c = 'HO';
		account1.IATA_ISO_Country__c = country.id;
		insert account1;


		Contact con = new Contact();
		con.FirstName = 'Dummy';
		con.LastName = 'Contact';
		con.Type_of_Contact__c = 'IFAP Contact';
		con.AccountId = account1.Id;
		con.Email = 'some@email.org';
		con.Financial_Assessment_Contact__c = true;
		insert con;

		List<Case> cases = new List<Case>();

		// TEST Workflow rule:
		// IF Short_Payment_Amount__c < 50 USD --> SET IRR_Withdrawal_Reason__c = SMALLAMOUNT
		// IF Short_Payment_Amount__c < MIN( 5% * Billing_Amount__c, 150000 USD)  --> SET IRR_Withdrawal_Reason__c = MINORPOLICY
		// SET IRR_Withdrawal_Reason__c = SMALLAMOUNT


		// SMALLAMOUNT
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 200,
							Short_Payment_Amount__c = 50,
							CurrencyExchangeRateUSD__c = 1,
							SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
							BSP_CASS__c = 'BSP'
						  ));

		// NOT SMALLAMOUNT
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 20000,
							Short_Payment_Amount__c = 6000,
							CurrencyExchangeRateUSD__c = 1,
							SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
							BSP_CASS__c = 'BSP'
						  ));

		// MINORPOLICY
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 200000,
							Short_Payment_Amount__c = 10000,
							CurrencyExchangeRateUSD__c = 1,
							SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
							BSP_CASS__c = 'BSP'
						  ));

		// NOT MINORPOLICY
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 200000,
							Short_Payment_Amount__c = 10100,
							CurrencyExchangeRateUSD__c = 1,
							SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
							BSP_CASS__c = 'BSP'
						  ));

		// MINORPOLICY
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 4000000,
							Short_Payment_Amount__c = 150000,
							CurrencyExchangeRateUSD__c = 1,
							SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
							BSP_CASS__c = 'BSP'
						  ));

		// NOT MINORPOLICY
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 4000000,
							Short_Payment_Amount__c = 160000,
							CurrencyExchangeRateUSD__c = 1,
							SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
							BSP_CASS__c = 'BSP'
						  ));

		insert cases;

		Test.StartTest();
		cases = [SELECT Id, Subject,  IRR_Withdrawal_Reason__c FROM Case];
		integer countSA = 0, countMP = 0, countN = 0;
		for (Case cs : cases) {
			system.debug('=========== ' + cs.Subject + ' --> ' + cs.IRR_Withdrawal_Reason__c);
			if (cs.IRR_Withdrawal_Reason__c == SMALLAMOUNT)  countSA++;
			else if (cs.IRR_Withdrawal_Reason__c == MINORPOLICY) countMP++;
			else    countN++;
		}

		system.assertEquals(1, countSA);
		system.assertEquals(2, countMP);
		system.assertEquals(3, countN);


		// From the fourth case with SMALL AMOUNT, IRR_Withdrawal_Reason__c will be set to null and Action_needed_Small_Amount__c will be set to true
		insert new Case(    ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 4000000,
							Short_Payment_Amount__c = 5,
							CurrencyExchangeRateUSD__c = 1,
							SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
							BSP_CASS__c = 'BSP'
					   );

		Case theCase;
		for (Case cs : cases) {
			if (cs.IRR_Withdrawal_Reason__c != SMALLAMOUNT) {
				theCase = cs;
				break;
			}
		}

		theCase.Billing_Amount__c = 400000;
		theCase.Short_Payment_Amount__c = 500;
		update theCase;


		cases = [SELECT Id, Subject, IRR_Withdrawal_Reason__c FROM Case ORDER BY Subject];
		countSA = 0; countN = 0; countMP = 0;
		for (Case cs : cases) {
			if (cs.IRR_Withdrawal_Reason__c == SMALLAMOUNT)  countSA++;
			else if (cs.IRR_Withdrawal_Reason__c == MINORPOLICY) countMP++;
			else    countN++;
		}

		system.assertEquals(1, countSA);
		system.assertEquals(2, countMP);
		system.assertEquals(4, countN);



		cases = [SELECT Id, IRR_Withdrawal_Reason__c, Action_needed_Small_Amount__c
				 FROM Case
				 WHERE Subject = 'TestCase Sidra Small Amount 6' OR ID = :theCase.Id];
		//system.debug(LoggingLevel.ERROR, '==================== '+cases+' ===========================');
		system.assertEquals(2, cases.size());
		system.assertEquals(true, cases[0].Action_needed_Small_Amount__c);
		system.assertEquals(true, cases[1].Action_needed_Small_Amount__c);
		system.assertEquals(null, cases[0].IRR_Withdrawal_Reason__c);
		system.assertEquals(null, cases[1].IRR_Withdrawal_Reason__c);


		cases = [SELECT Id, IRR_Withdrawal_Reason__c, Action_needed_Small_Amount__c
				 FROM Case
				 WHERE Action_needed_Small_Amount__c = true
						 AND IRR_Withdrawal_Reason__c = null];
		system.assertEquals(2, cases.size());
	}


	// test new filter: only count minor error policy cases after the last reinstatement
	@isTest
	static void TestSidraCases_2() {
		Case aCase;
		integer c = 0;
		ID SidraPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');

		Account account1 = new Account(IATACode__c = '1234567');    // 7 digits
		account1.Name = 'Test account';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.Location_Type__c = 'HO';
		insert account1;


		Contact con = new Contact();
		con.FirstName = 'Dummy';
		con.LastName = 'Contact';
		con.Type_of_Contact__c = 'IFAP Contact';
		con.AccountId = account1.Id;
		con.Email = 'some@email.org';
		con.Financial_Assessment_Contact__c = true;
		insert con;

		List<Case> cases = new List<Case>();

		// TEST Workflow rule:
		// IF Short_Payment_Amount__c < 50 USD --> SET IRR_Withdrawal_Reason__c = SMALLAMOUNT
		// IF Short_Payment_Amount__c < MIN( 5% * Billing_Amount__c, 150000 USD)  --> SET IRR_Withdrawal_Reason__c = MINORPOLICY
		// SET IRR_Withdrawal_Reason__c = SMALLAMOUNT


		// SMALLAMOUNT
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 200,
							Short_Payment_Amount__c = 50,
							CurrencyExchangeRateUSD__c = 1,
							BSP_CASS__c = 'BSP',
							Late_Payment_Date__c = Date.today(),
							SIDRA_exchange_rate_updated__c = true
						  ));


		// MINORPOLICY
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 2000,
							Short_Payment_Amount__c = 100,
							CurrencyExchangeRateUSD__c = 1,
							BSP_CASS__c = 'BSP',
							Late_Payment_Date__c = Date.today(),
							SIDRA_exchange_rate_updated__c = true
						  ));


		// MINORPOLICY
		cases.add(new Case( ContactId = con.Id,
							AccountId = con.accountId,
							Subject = 'TestCase Sidra Small Amount ' + c,
							Origin = 'Web',
							RecordTypeId = SidraPcaseRecordTypeID,
							Description = 'description ' + c++,
							Billing_Amount__c = 4000000,
							Short_Payment_Amount__c = 150000,
							CurrencyExchangeRateUSD__c = 1,
							BSP_CASS__c = 'BSP',
							Late_Payment_Date__c = Date.today(),
							SIDRA_exchange_rate_updated__c = true
						  ));


		insert cases;

		Test.StartTest();

		Case rei = new Case( ContactId = con.Id,
							 AccountId = con.accountId,
							 Subject = 'TestCase Sidra Small Amount ' + c,
							 Origin = 'Web',
							 RecordTypeId = SidraPcaseRecordTypeID,
							 Description = 'description ' + c++,
							 Billing_Amount__c = 4000000,
							 Short_Payment_Amount__c = 160000,
							 CurrencyExchangeRateUSD__c = 1,
							 SIDRA_exchange_rate_updated__c = true,
							 BSP_CASS__c = 'BSP',
							 Update_AIMS_REI_DEFWITH__c = Datetime.now(),
							 REI_ApprovalRejectin__c = 'Approved',
							Late_Payment_Date__c = Date.today(),
							 DEF_Withdrawal_Approval_Rejection__c = '');
		insert rei;

		// The fourth case with SMALL AMOUNT
		// Check that, because of the reinstatement case, Action_needed_Small_Amount__c is not set to true
		Case testcase = new Case(    ContactId = con.Id,
									 AccountId = con.accountId,
									 Subject = 'TestCase Sidra Small Amount ' + c,
									 Origin = 'Web',
									 RecordTypeId = SidraPcaseRecordTypeID,
									 Description = 'description ' + c++,
									 Billing_Amount__c = 4000000,
									 Short_Payment_Amount__c = 5,
									 CurrencyExchangeRateUSD__c = 1,
									 SIDRA_exchange_rate_updated__c = true,
							Late_Payment_Date__c = Date.today(),
									 BSP_CASS__c = 'BSP'
								);
		insert testcase;

		update testCase;

		Test.stopTest();

		cases = [SELECT Id, IRR_Withdrawal_Reason__c, Action_needed_Small_Amount__c FROM Case WHERE ID = :testcase.Id];
		system.assertEquals(false, cases[0].Action_needed_Small_Amount__c);
	}

	@isTest
	static void TestSidraCases_3() {
		Case aCase;
		integer c = 0;
		ID SidraPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');

		Account account1 = new Account(IATACode__c = '1234567');    // 7 digits
		account1.Name = 'Test account';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.Location_Type__c = 'HO';
		insert account1;


		Contact con = new Contact();
		con.FirstName = 'Dummy';
		con.LastName = 'Contact';
		con.Type_of_Contact__c = 'IFAP Contact';
		con.AccountId = account1.Id;
		con.Email = 'some@email.org';
		con.Financial_Assessment_Contact__c = true;
		insert con;

		Case testcase = new Case(
			ContactId = con.Id,
			AccountId = con.accountId,
			Subject = 'TestCase Sidra Small Amount ' + c,
			Origin = 'Web',
			RecordTypeId = SidraPcaseRecordTypeID,
			Description = 'description ' + c++,
			Billing_Amount__c = 4000000,
			Short_Payment_Amount__c = 5,
			CurrencyExchangeRateUSD__c = 1,
			SIDRA_exchange_rate_updated__c = true,
			Late_Payment_Date__c = Date.today(),
			BSP_CASS__c = 'BSP',
			Update_AIMS_Repayment_agreed__c = null
		);
		insert testcase;

		Test.StartTest();

		//update Update_AIMS_Repayment_agreed__c without any Repayment Instalment
		try {
			testCase.Update_AIMS_Repayment_agreed__c = DateTime.now();
			update testCase;
			System.assert(false,'Exception expected');
		} catch(Exception e) {
			System.assert(true);
		}

		//update Update_AIMS_Repayment_agreed__c WITH a Repayment Instalment
		Case_Detail__c caseDetail = new Case_Detail__c(
			Case__c = testCase.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Detail__c','Repayment_Instalment')
		);
		insert caseDetail;
		testCase.Update_AIMS_Repayment_agreed__c = DateTime.now();
		update testCase;

		Test.stopTest();
	}

}
