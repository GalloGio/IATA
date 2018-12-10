@isTest
public class ANG_ChinaConversionsHelperTest {

	private static AMS_OSCAR__c oscar;
	private static Account accountHO;
	private static Account accountBR;
	private static Account accountSA;
	private static AMS_Agencies_Hierarchy__c h;
	private static Map<Id, Account> accountsMap;


	private static Map<String, Map<String, String>> changeCodesConfig {
		get {
        	return new Map<String, Map<String, String>> {
                'DIS-CHINA-TO-NEWGEN' => new Map<String, String> {
	                                    	'Change_Code' => 'DIS',
	                                    	'Bulletin_Memo_Text' => 'Conversion to NewGen GoLite Disapproved'},
                'DIS-CHINA-TO-LEGACY' => new Map<String, String> {
	                                    	'Change_Code' => 'DIS',
	                                    	'Bulletin_Memo_Text' => 'Conversion to Domestic with Cash facility disapproved'},
                'CWD-CHINA-TO-NEWGEN' => new Map<String, String> {
	                                    	'Change_Code' => 'CWD',
	                                    	'Bulletin_Memo_Text' => 'Conversion to NewGen GoLite withdrawn'},
                'CWD-CHINA-TO-LEGACY' => new Map<String, String> {
	                                    	'Change_Code' => 'CWD',
	                                    	'Bulletin_Memo_Text' => 'Conversion to Domestic with Cash facility withdrawn'},
                'DOM' => new Map<String, String> {
	                                    	'Change_Code' => 'DOM',
	                                    	'Bulletin_Memo_Text' => 'Agent is upgrading from Domestic to International'},
                'LGC' => new Map<String, String> {
	                                    	'Change_Code' => 'LGC',
	                                    	'Bulletin_Memo_Text' => 'Conversion to Domestic with Cash facility in progress'},
	            'LGF' => new Map<String, String> {
	                                    	'Change_Code' => 'LGF',
	                                    	'Bulletin_Memo_Text' => 'Conversion to Domestic with Cash facility finalized'},
	            'PLF' => new Map<String, String> {
	                                    	'Change_Code' => 'PLF',
	                                    	'Bulletin_Memo_Text' => 'Conversion to NewGen GoLite finalized'},
				'PLT' => new Map<String, String> {
	                                    	'Change_Code' => 'PLT',
	                                    	'Bulletin_Memo_Text' => 'Conversion to NewGen GoLite in progress'}
	        };
        }
        set;
    }

	private static void setupData(String typeOfChange) {

		//ACCOUNTS
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name='China', ISO_Code__c='CN', Enable_NewGen_Pilot__c=true, Region__c='China & North Asia')  ;
        insert ctry;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name='CN20', ISO_Code__c='CN20', IATA_ISO_Country__c=ctry.Id);
        insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		String locationTypeParent = (typeOfChange == AMS_Utils.CONVERTTONEWGENPILOT) ? 'HO' : 'HE';
		String locationTypeChild = (typeOfChange == AMS_Utils.CONVERTTONEWGENPILOT) ? 'BR' : 'AE';
		
		accountHO = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Name='ChinaAgencyHO', Short_Name__c='ChinaAgencyHO', Location_Class__c = 'D', Location_Type__c = locationTypeParent, Remittance_frequency__c = 'M', Sector__C = 'Travel Agent', Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing', Company_Type__c = 'A');
		insert accountHO;	

		accountBR = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Name='ChinaAgencyBR', Short_Name__c='ChinaAgencyBR', Location_Class__c = 'D', Location_Type__c = locationTypeChild, Remittance_frequency__c = 'M', Sector__C = 'Travel Agent', Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing', Company_Type__c = 'A', ParentId = accountHO.Id, Top_Parent__c = accountHO.Id);
		insert accountBR;

		if(typeOfChange == AMS_Utils.CONVERTTONEWGENPILOT) {
			accountSA = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Name='ChinaAgencySA', Short_Name__c='ChinaAgencySA', Location_Class__c = 'D', Location_Type__c = 'SA', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent', Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing', Company_Type__c = 'A', ParentId = accountBR.Id, Top_Parent__c = accountHO.Id);
			insert accountSA;	
		}

		//ACCOUNT RELATIONS
		Boolean isNewGenRelation = (typeOfChange == AMS_Utils.CONVERTTONEWGENPILOT) ? false : true;
		
		h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'hierarchy');
		insert h;

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(Hierarchy__c = h.Id, Child_Account__c = accountBR.Id, Parent_Account__c = accountHO.Id, Is_Newgen_Relation__c = isNewGenRelation);
        insert r1;

        if(typeOfChange == AMS_Utils.CONVERTTONEWGENPILOT) {
	        AMS_Agencies_relationhip__c r2 = new AMS_Agencies_relationhip__c(Hierarchy__c = h.Id, Child_Account__c = accountSA.Id, Parent_Account__c = accountBR.Id, Is_Newgen_Relation__c = isNewGenRelation);
	        insert r2;
	    }

        //CONTACTS
        Contact co1 = new Contact(AccountId = accountHO.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		//OSCAR
		ID chinaRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes_China');
		oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGCHINACONVERSION, Account__c = accountHO.id, Is_using_credit_card__c = true, RecordTypeId = chinaRT, ANG_Type_Of_Change__c = typeOfChange);
		insert oscar;

		//OSCAR CASE
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = accountHO.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

        //ACCREDITATION FORM
        AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = oscarCase.Id, Account_Name__c=accountHO.Name, Short_Name__c=accountHO.Short_Name__c );
        insert stagingArea;


        //RISK EVENTS
        if(typeOfChange != AMS_Utils.CONVERTTONEWGENPILOT) {
			ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(Name = 'Risk Event Type 1', ANG_Risk_ID__c = '111', ANG_Expiration__c = 2);
			insert ret;

			ANG_Agency_Risk_Event__c re = new ANG_Agency_Risk_Event__c(ANG_AccountId__c = oscar.Account__c, ANG_Risk_Type__c = ret.Id);
			insert re;
		}

		oscar.STEP6__c = AMS_Utils.FAILED; //Sanity check
		oscar.STEP2__c = AMS_Utils.FAILED; //Approval
		oscar.STEP3__c = AMS_Utils.FAILED; //Disapproval
		oscar.STEP4__c = AMS_Utils.FAILED; //Withdrawal
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;


		//ATTACHMENT
		Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = oscarCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert attc;

        //OWNER
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= oscar.AMS_Online_Accreditation__c,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;
        
        //CHANGE CODES
        List<AMS_ChangeCodes__c> changeCodeList = new List<AMS_ChangeCodes__c>();
        for(String ccName : changeCodesConfig.keyset()) {
        	changeCodeList.add(new AMS_ChangeCodes__c(Name = ccName, Change_Code__c = changeCodesConfig.get(ccName).get('Change_Code'), Integration_RecId__c = 'C', Bulletin_Memo_Text__c = changeCodesConfig.get(ccName).get('Bulletin_Memo_Text')));
        }
        insert changeCodeList;	

	}



	@isTest static void convertChinaToNewGenTest() {

		Test.startTest();
		setupData(AMS_Utils.CONVERTTONEWGENPILOT);
		Test.stopTest();

		convertChinaToNewGenStep6Test();
		convertChinaToNewGenStep2Test();
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

	    oscar.STEP6__c = AMS_Utils.PASSED; //Sanity check
		update oscar;

		accountsMap = ANG_ChinaConversionsHelper.getAllHierarchyAccounts(oscar.Account__c);

		checkChangeCode('PLT');
		checkAccountsChanges(accountsMap.values(), 'Cashless', true, new List<String>{'HE','AE'}, 'Not Applicable');

		//Confirm that old SA moved from 3rd level to 2nd level of the account hierarchy
		accountSA = [SELECT ParentId, Top_Parent__c
					 FROM Account
					 WHERE Id = :AccountSA.Id];

		System.assertEquals(accountSA.ParentId, accountHO.Id);
		System.assertEquals(accountSA.Top_Parent__c, accountHO.Id);
		checkAccountRelations();
	}

	private static void convertChinaToNewGenStep2Test() {
		/*On approval:
		      -generate change code PLF
		      -create inactive FoP records for the accounts (CC and IEP as for cashless agents)*/

		oscar.STEP15__c = AMS_Utils.PASSED;
		oscar.STEP12__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = 'Authorize Approval';
		oscar.STEP2__c = AMS_Utils.PASSED; //Approval
		update oscar;

		checkChangeCode('PLF');

		List<Agency_Authorization__c> FoPs_list = [SELECT Account__c, ANG_FormOfPayment_ID__c, Status__c 
											  	   FROM Agency_Authorization__c
											  	   WHERE Account__c IN :accountsMap.keyset() and (ANG_FormOfPayment_ID__c = 'CC' or ANG_FormOfPayment_ID__c = 'EP') and Status__c = 'Non-Active'];

		System.assertEquals(6, FoPs_list.size());
	}

	@isTest static void convertChinaToNewGenStep3Test() {
		/*On disapproval:
		      -generate DIS change code*/

		Test.startTest();
		setupData(AMS_Utils.CONVERTTONEWGENPILOT);
		Test.stopTest();

		oscar.STEP3__c = AMS_Utils.PASSED; //Disapproval
		update oscar;

		checkChangeCode('DIS-CHINA-TO-NEWGEN');
	}

	@isTest static void convertChinaToNewGenStep4Test() {
		/*On withdrawal:
		      -generate CWD change code*/

		Test.startTest();      	
		setupData(AMS_Utils.CONVERTTONEWGENPILOT);
		Test.stopTest();

		oscar.STEP4__c = AMS_Utils.PASSED; //Withdrawal
		update oscar;

		checkChangeCode('CWD-CHINA-TO-NEWGEN');
	}


	@isTest static void convertChinaToLegacyTest() {

		Test.startTest();
		setupData(AMS_Utils.CONVERTTOLEGACY);
		Test.stopTest();

		createFormOfPayment(oscar.Account__c, 'CC');

		convertChinaToLegacyStep6Test();
		convertChinaToLegacyStep2Test();
		convertChinaToLegacyStep3Test();
		convertChinaToLegacyStep4Test();
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

		oscar.STEP6__c = AMS_Utils.PASSED; //Sanity check
		update oscar;

		accountsMap = ANG_ChinaConversionsHelper.getAllHierarchyAccounts(oscar.Account__c);

		checkChangeCode('LGC');
		checkAccountsChanges(accountsMap.values(), null, false, new List<String>{'HO','BR'}, null);
		checkRiskEvents(accountsMap.keyset());													   	
		checkAccountRelations();
	}

	private static void convertChinaToLegacyStep2Test() {
		/*On approval:
			-generate change code LGF
			-delete the FoP records for the accounts */

		oscar.STEP15__c = AMS_Utils.PASSED;
		oscar.STEP12__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = 'Authorize Approval';
		oscar.STEP2__c = AMS_Utils.PASSED; //Approval
		update oscar;

		checkChangeCode('LGF');
		checkFormOfPayments(accountsMap.keyset());
	}

	private static void convertChinaToLegacyStep3Test() {
		/*On disapproval:
		      -generate DIS change code*/

		oscar.STEP3__c = AMS_Utils.PASSED; //Disapproval
		update oscar;

		checkChangeCode('DIS-CHINA-TO-LEGACY');
	}

	private static void convertChinaToLegacyStep4Test() {
		/*On withdrawal:
		      -generate CWD change code*/

		oscar.STEP4__c = AMS_Utils.PASSED; //Withdrawal
		update oscar;

		checkChangeCode('CWD-CHINA-TO-LEGACY');
	}


	@isTest static void convertChinaToInternationalTest() {

		Test.startTest();
		setupData(AMS_Utils.CONVERTTOINTERNATIONAL);
		Test.stopTest();

		createFormOfPayment(oscar.Account__c, 'CC');

		

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
			-delete any Risk Event
			-delete the FoP records for the accounts */

		oscar.STEP6__c = AMS_Utils.PASSED; //Sanity check
		update oscar;

		accountsMap = ANG_ChinaConversionsHelper.getAllHierarchyAccounts(oscar.Account__c);

		checkChangeCode('DOM');
		checkAccountsChanges(accountsMap.values(), null, false, new List<String>{'HO','BR'}, null);
		checkAccountRelations();
		checkRiskEvents(accountsMap.keyset());
		checkFormOfPayments(accountsMap.keyset()); 
	}


	private static void createFormOfPayment(Id accountId, String fopId) {
		Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');
		Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = accountId, ANG_FormOfPayment_ID__c = fopId, Status__c = 'Non-Active', RecordTypeId = formOfPaymentRT);
		insert aa;
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


	private static void checkFormOfPayments(Set<Id> accountIds) {
		List<Agency_Authorization__c> FoPs_list = [SELECT Account__c, ANG_FormOfPayment_ID__c, Status__c 
											  	   FROM Agency_Authorization__c 
											  	   WHERE Account__c in :accountIds];

		System.assertEquals(0, FoPs_list.size());
	}


	private static void checkRiskEvents(Set<Id> accountIds) {
		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_AccountId__c
													 FROM ANG_Agency_Risk_Event__c 
													 WHERE ANG_AccountId__c in :accountIds];

		System.assertEquals(0, [SELECT count() FROM ANG_Agency_Risk_Event__c WHERE ANG_AccountId__c in :accountIds]);
	}


	private static void checkChangeCode(String changeCodeName) {
		String changeCode = changeCodesConfig.get(changeCodeName).get('Change_Code');
		String bulletinMemo = changeCodesConfig.get(changeCodeName).get('Bulletin_Memo_Text');

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Bulletin_Information__c 
														   FROM Agency_Applied_Change_code__c 
														   WHERE Change_Code__c = :changeCode and OSCAR__c = :oscar.id and Account__c = :oscar.Account__c];										   

		System.assertEquals(bulletinMemo.toUpperCase(), changeCodes[0].Bulletin_Information__c);
	}


	private static void checkAccountsChanges(List<Account> accList, String expectedAccreditationModel, Boolean expectedNewGenAgency, List<String> expectedLocationTypes, String expectedRiskStatus) {
		for(Account a : accList) {
			System.assertEquals(expectedAccreditationModel, a.ANG_Accreditation_Model__c);
			System.assert(expectedLocationTypes.contains(a.Location_Type__c));
			System.assertEquals(expectedNewGenAgency, a.ANG_IsNewGenAgency__c);
			System.assertEquals(expectedRiskStatus, a.ANG_RiskStatus__c);
			System.assertEquals(expectedRiskStatus, a.ANG_RiskHistoryAssessment__c);
		}
	}


}