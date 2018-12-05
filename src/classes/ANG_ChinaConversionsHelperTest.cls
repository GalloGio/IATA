@isTest
public class ANG_ChinaConversionsHelperTest {

	private static AMS_OSCAR__c oscar;
	private static Account accountHO;
	private static Account accountBR;
	private static Account accountSA;
	private static AMS_Agencies_Hierarchy__c h;
	private static AMS_Agencies_relationhip__c r1;
	private static AMS_Agencies_relationhip__c r2;

	private static void setupData(String typeOfChange) {

		//ACCOUNTS
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name='China', ISO_Code__c='CN', Enable_NewGen_Pilot__c=true, Region__c='China & North Asia')  ;
        insert ctry;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name='CN20', ISO_Code__c='CN20', IATA_ISO_Country__c=ctry.Id);
        insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		
		accountHO = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Name='ChinaAgencyHO', Short_Name__c='ChinaAgencyHO', Location_Class__c = 'D', Location_Type__c = 'HO', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent', Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing', Company_Type__c = 'A');
		insert accountHO;	

		accountBR = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Name='ChinaAgencyBR', Short_Name__c='ChinaAgencyBR', Location_Class__c = 'D', Location_Type__c = 'BR', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent', Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing', Company_Type__c = 'A', ParentId = accountHO.Id, Top_Parent__c = accountHO.Id);
		insert accountBR;

		accountSA = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Name='ChinaAgencySA', Short_Name__c='ChinaAgencySA', Location_Class__c = 'D', Location_Type__c = 'SA', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent', Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing', Company_Type__c = 'A');
		insert accountSA;		


		//ACCOUNT RELATIONS
		h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'hierarchy');
		insert h;

		r1 = new AMS_Agencies_relationhip__c(Hierarchy__c = h.Id, Child_Account__c = accountBR.Id, Parent_Account__c = accountHO.Id, Is_Newgen_Relation__c = false);
        insert r1;


        Contact co1 = new Contact(AccountId = accountHO.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		ID chinaRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes_China');
		oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGCHINACONVERSION, Account__c = accountHO.id, Is_using_credit_card__c = true, RecordTypeId = chinaRT, ANG_Type_Of_Change__c = typeOfChange);
		insert oscar;

		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = accountHO.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		oscar.STEP6__c = AMS_Utils.FAILED; //Sanity check
		oscar.STEP2__c = AMS_Utils.FAILED; //Approval
		oscar.STEP3__c = AMS_Utils.FAILED; //Disapproval
		oscar.STEP4__c = AMS_Utils.FAILED; //Withdrawal
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		update oscar;


		List<AMS_ChangeCodes__c> changeCodeList = new List<AMS_ChangeCodes__c>{
            new AMS_ChangeCodes__c(Name = 'DIS-CHINA-TO-NEWGEN', Change_Code__c = 'DIS', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to NewGen GoLite Disapproved'),
            new AMS_ChangeCodes__c(Name = 'DIS-CHINA-TO-LEGACY', Change_Code__c = 'DIS', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to Domestic with Cash facility disapproved'),
            new AMS_ChangeCodes__c(Name = 'CWD-CHINA-TO-NEWGEN', Change_Code__c = 'CWD', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to NewGen GoLite withdrawn'),
            new AMS_ChangeCodes__c(Name = 'CWD-CHINA-TO-LEGACY', Change_Code__c = 'CWD', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to Domestic with Cash facility withdrawn'),
            new AMS_ChangeCodes__c(Name = 'DOM', Change_Code__c = 'DOM', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Agent is upgrading from Domestic to International'),
            new AMS_ChangeCodes__c(Name = 'LGC', Change_Code__c = 'LGC', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to Domestic with Cash facility in progress'),
            new AMS_ChangeCodes__c(Name = 'LGF', Change_Code__c = 'LGF', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to Domestic with Cash facility finalized'),
            new AMS_ChangeCodes__c(Name = 'PLF', Change_Code__c = 'PLF', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to NewGen GoLite finalized'),
            new AMS_ChangeCodes__c(Name = 'PLT', Change_Code__c = 'PLT', Integration_RecId__c = 'C', Bulletin_Memo_Text__c = 'Conversion to NewGen GoLite in progress')
        };

        insert changeCodeList;	

	}



	@isTest static void convertChinaToNewGenTest() {

		setupData(AMS_Utils.CONVERTTONEWGENPILOT);

		accountSA.ParentId = accountBR.Id;
		accountSA.Top_Parent__c = accountHO.Id;
		update accountSA;

		AMS_Agencies_relationhip__c r2 = new AMS_Agencies_relationhip__c(Hierarchy__c = h.Id, Child_Account__c = accountSA.Id, Parent_Account__c = accountBR.Id, Is_Newgen_Relation__c = false);
        insert r2;

		oscar.STEP6__c = AMS_Utils.PASSED; //Sanity check
		update oscar;

		Test.startTest();

		convertChinaToNewGenStep6Test();

		oscar.STEP15__c = AMS_Utils.PASSED;
		oscar.STEP12__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = 'Authorize Approval';
		oscar.STEP2__c = AMS_Utils.PASSED; //Approval
		update oscar;

		convertChinaToNewGenStep2Test();
		
		Test.stopTest();
		
	}

	private static void convertChinaToNewGenStep6Test() {
		/*On sanity checks passed:
	      -generate change code PLT
	      -update Accreditation Type to Cashless for all the accounts in the hierarchy
	      -update the flag "Is NewGen agent" for all the accounts in the hierarchy
	      -update the location type: HO -> HE / BR,SA -> AE
			(In case there is any terminated location with location type different than HO/BR/SA, convert them to terminated AEs)
	      -update Risk status and Risk Assessment fields to Not Applicable
	      -update hierarchy & relationships
	      - */

		accountHO = [SELECT id, Location_Type__c, ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c, 
									ANG_Accreditation_Model__c, ParentId, Top_Parent__c
					 FROM Account 
					 WHERE Id = :accountHO.Id];

		accountBR = [SELECT id, Location_Type__c, ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c, 
									 ANG_Accreditation_Model__c, ParentId, Top_Parent__c
					 FROM Account 
					 WHERE Id = :accountBR.Id];

		accountSA = [SELECT id, Location_Type__c, ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c, 
									 ANG_Accreditation_Model__c, ParentId, Top_Parent__c
					 FROM Account
					 WHERE Id = :accountSA.Id];

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'PLT' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO NEWGEN GOLITE IN PROGRESS', changeCodes[0].Bulletin_Information__c);

		System.assertEquals('Cashless', accountHO.ANG_Accreditation_Model__c);
		System.assertEquals('Cashless', accountBR.ANG_Accreditation_Model__c);
		System.assertEquals('Cashless', accountSA.ANG_Accreditation_Model__c);

		System.assertEquals('HE', accountHO.Location_Type__c);
		System.assertEquals('AE', accountBR.Location_Type__c);
		System.assertEquals('AE', accountSA.Location_Type__c);

		System.assertEquals(true, accountHO.ANG_IsNewGenAgency__c);
		System.assertEquals(true, accountBR.ANG_IsNewGenAgency__c);
		System.assertEquals(true, accountSA.ANG_IsNewGenAgency__c);

		System.assertEquals('Not Applicable', accountHO.ANG_RiskStatus__c);
		System.assertEquals('Not Applicable', accountHO.ANG_RiskHistoryAssessment__c);
		System.assertEquals('Not Applicable', accountBR.ANG_RiskStatus__c);
		System.assertEquals('Not Applicable', accountBR.ANG_RiskHistoryAssessment__c);
		System.assertEquals('Not Applicable', accountSA.ANG_RiskStatus__c);
		System.assertEquals('Not Applicable', accountSA.ANG_RiskHistoryAssessment__c);

		//Confirm that old SA moved from 3rd level to 2nd level of the account hierarchy
		System.assertEquals(accountSA.ParentId, accountHO.Id);
		System.assertEquals(accountSA.Top_Parent__c, accountHO.Id);
		checkAccountRelations();
	}

	private static void convertChinaToNewGenStep2Test() {
		/*On approval:
		      -generate change code PLF
		      -create inactive FoP records for the accounts (CC and IEP as for cashless agents)*/

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'PLF' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO NEWGEN GOLITE FINALIZED', changeCodes[0].Bulletin_Information__c);


		List<Agency_Authorization__c> FoPs_list = [SELECT Account__c, ANG_FormOfPayment_ID__c, Status__c 
											  	   FROM Agency_Authorization__c
											  	   WHERE Account__c = :AccountHO.Id and (ANG_FormOfPayment_ID__c = 'CC' or ANG_FormOfPayment_ID__c = 'EP') and Status__c = 'Non-Active'];

		System.assertEquals(2, FoPs_list.size());
	}

	@isTest static void convertChinaToNewGenStep3Test() {
		/*On disapproval:
		      -generate DIS change code*/

		setupData(AMS_Utils.CONVERTTONEWGENPILOT);

		oscar.STEP3__c = AMS_Utils.PASSED; //Disapproval
		update oscar;

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'DIS' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO NEWGEN GOLITE DISAPPROVED', changeCodes[0].Bulletin_Information__c);

		
	}

	@isTest static void convertChinaToNewGenStep4Test() {
		/*On withdrawal:
		      -generate CWD change code*/
		      
		setupData(AMS_Utils.CONVERTTONEWGENPILOT);

		oscar.STEP4__c = AMS_Utils.PASSED; //Withdrawal
		update oscar;

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'CWD' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO NEWGEN GOLITE WITHDRAWN', changeCodes[0].Bulletin_Information__c);
	}


	@isTest static void convertChinaToLegacyTest() {

		Test.startTest();

		setupData(AMS_Utils.CONVERTTOLEGACY);

		convertToNewGen(accountHO);
		convertToNewGen(accountBR);

		Test.stopTest();

	
		//Risk event types
		ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(Name = 'Risk Event Type 1', ANG_Risk_ID__c = '111', ANG_Expiration__c = 2);
		insert ret;

		//Risk events
		ANG_Agency_Risk_Event__c re = new ANG_Agency_Risk_Event__c(ANG_AccountId__c = accountHO.Id, ANG_Risk_Type__c = ret.Id);
		insert re;

		//Form of payments
		Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');
		Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Non-Active', RecordTypeId = formOfPaymentRT);
		insert aa;

		oscar.STEP6__c = AMS_Utils.PASSED; //Sanity check
		update oscar;
		
		convertChinaToLegacyStep6Test();
	}


	private static void convertChinaToLegacyStep6Test() {
		/*On sanity checks passed:
			-generate change code LGC
			-delete Accreditation Type for all the accounts in the hierarchy
			-update the flag "Is NewGen agent" for all the accounts in the hierarchy
			-update the location type: HE -> HO. AE -> BR
			-set Risk status & Risk history assessment fields blank
			-delete any Risk Event
			-update hierarchy & relationships*/

		accountHO = [SELECT id, Location_Type__c, ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c, 
							ANG_Accreditation_Model__c, ParentId, Top_Parent__c
					 FROM Account 
					 WHERE Id = :accountHO.Id];

		accountBR = [SELECT id, Location_Type__c, ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c, 
							ANG_Accreditation_Model__c, ParentId, Top_Parent__c
					 FROM Account 
					 WHERE Id = :accountBR.Id];

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'LGC' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO DOMESTIC WITH CASH FACILITY IN PROGRESS', changeCodes[0].Bulletin_Information__c);

		System.assertEquals(null, accountHO.ANG_Accreditation_Model__c);
		System.assertEquals(null, accountBR.ANG_Accreditation_Model__c);

		System.assertEquals('HO', accountHO.Location_Type__c);
		System.assertEquals('BR', accountBR.Location_Type__c);

		System.assertEquals(false, accountHO.ANG_IsNewGenAgency__c);
		System.assertEquals(false, accountBR.ANG_IsNewGenAgency__c);

		System.assertEquals(null, accountHO.ANG_RiskStatus__c);
		System.assertEquals(null, accountHO.ANG_RiskHistoryAssessment__c);
		System.assertEquals(null, accountBR.ANG_RiskStatus__c);
		System.assertEquals(null, accountBR.ANG_RiskHistoryAssessment__c);

		Map<Id, Account> accountsMap = ChinaConversionsHelper.getAllHierarchyAccounts(oscar.Account__c);

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_AccountId__c
													 FROM ANG_Agency_Risk_Event__c 
													 WHERE ANG_AccountId__c in :accountsMap.keyset()];

		System.assertEquals(0, [SELECT count() FROM ANG_Agency_Risk_Event__c WHERE ANG_AccountId__c in :accountsMap.keyset()]);	
														   	
		checkAccountRelations();
	}

	private static void convertChinaToLegacyStep2Test() {
		/*On approval:
			-generate change code LGF
			-delete the FoP records for the accounts */

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'LGF' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO DOMESTIC WITH CASH FACILITY FINALIZED', changeCodes[0].Bulletin_Information__c);


		Map<Id, Account> accountsMap = ANG_ChinaConversionsHelper.getAllHierarchyAccounts(oscar.Account__c);

		List<Agency_Authorization__c> FoPs_list = [SELECT Account__c, ANG_FormOfPayment_ID__c, Status__c 
											  	   FROM Agency_Authorization__c 
											  	   WHERE Account__c in :accountsMap.keyset()];

		System.assertEquals(0, FoPs_list.size());
	}

	private static void convertChinaToLegacyStep3Test() {
		/*On disapproval:
		      -generate DIS change code*/

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'DIS' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO DOMESTIC WITH CASH FACILITY DISAPPROVED', changeCodes[0].Bulletin_Information__c);
	}

	private static void convertChinaToLegacyStep4Test() {
		/*On withdrawal:
		      -generate CWD change code*/

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'CWD' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('CONVERSION TO DOMESTIC WITH CASH FACILITY WITHDRAWN', changeCodes[0].Bulletin_Information__c);
	}


	@isTest static void convertChinaToInternationalTest() {

		Test.startTest();

		setupData(AMS_Utils.CONVERTTOINTERNATIONAL);
		convertToNewGen(accountHO);
		convertToNewGen(accountBR);

		Test.stopTest();

		Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');
		Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = oscar.Account__c, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Non-Active', RecordTypeId = formOfPaymentRT);
		insert aa;

		oscar.STEP6__c = AMS_Utils.PASSED; //Sanity check
		update oscar;

		convertChinaToInternationalStep6Test();
	}

	private static void convertChinaToInternationalStep6Test() {
		/*On sanity checks passed:
			-generate change code DOM
			-delete Accreditation Type for all the accounts in the hierarchy
			-update the flag "Is NewGen agent" for all the accounts in the hierarchy
			-update the location type: HE -> HO. AE -> BR
			-set Risk status & Risk history assessment fields blank
			-update hierarchy & relationships
			-delete the FoP records for the accounts */

		accountHO = [SELECT id, Location_Type__c, ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c, 
									ANG_Accreditation_Model__c, ParentId, Top_Parent__c
					 FROM Account 
					 WHERE Id = :accountHO.Id];

		accountBR = [SELECT id, Location_Type__c, ANG_IsNewGenAgency__c, ANG_RiskStatus__c, ANG_RiskHistoryAssessment__c, 
									 ANG_Accreditation_Model__c, ParentId, Top_Parent__c
					 FROM Account 
					 WHERE Id = :accountBR.Id];

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = 'DOM' and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];

		System.assertEquals('AGENT IS UPGRADING FROM DOMESTIC TO INTERNATIONAL', changeCodes[0].Bulletin_Information__c);

		System.assertEquals(null, accountHO.ANG_Accreditation_Model__c);
		System.assertEquals(null, accountBR.ANG_Accreditation_Model__c);

		System.assertEquals('HO', accountHO.Location_Type__c);
		System.assertEquals('BR', accountBR.Location_Type__c);

		System.assertEquals(false, accountHO.ANG_IsNewGenAgency__c);
		System.assertEquals(false, accountBR.ANG_IsNewGenAgency__c);

		System.assertEquals(null, accountHO.ANG_RiskStatus__c);
		System.assertEquals(null, accountHO.ANG_RiskHistoryAssessment__c);
		System.assertEquals(null, accountBR.ANG_RiskStatus__c);
		System.assertEquals(null, accountBR.ANG_RiskHistoryAssessment__c);

		checkAccountRelations();

		Map<Id, Account> accountsMap = ChinaConversionsHelper.getAllHierarchyAccounts(oscar.Account__c);

		List<Agency_Authorization__c> FoPs_list = [SELECT Account__c, ANG_FormOfPayment_ID__c, Status__c 
											  	   FROM Agency_Authorization__c 
											  	   WHERE Account__c in :accountsMap.keyset()];

		System.assertEquals(0, FoPs_list.size());
	}


	private static void convertToNewGen(Account a) {
		a.Location_Type__c = (a.Location_Type__c == 'HO') ? 'HE' : 'AE';
		a.ANG_Accreditation_Model__c = 'Cashless';
		update a;

		r1.Is_Newgen_Relation__c = true;
		update r1;
	}

	private static void checkAccountRelations() {
		Boolean newGenFlag = (oscar.ANG_Type_Of_Change__c == AMS_Utils.CONVERTTONEWGENPILOT) ? true : false;

		List<AMS_Agencies_relationhip__c> relations = [SELECT Is_Newgen_Relation__c, Parent_Account__c, Child_Account__c  
													   FROM AMS_Agencies_relationhip__c 
													   WHERE Hierarchy__c = :h.Id];

		for(AMS_Agencies_relationhip__c r : relations) {
			System.assertEquals(newGenFlag, r.Is_Newgen_Relation__c);
			System.assertEquals(accountHO.Id, r.Parent_Account__c);
		}
	}
}
