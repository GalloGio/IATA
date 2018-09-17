@isTest //(SeeAllData=true)

private class ANG_RiskEventMigrationHelperTest {

	private static map<string,ANG_Risk_Event_Type__c> reMap{get;set;}
	@testSetup static void setup(){

		List<ANG_Risk_Event_Type__c> eventTypes = new List<ANG_Risk_Event_Type__c>(); 
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Auth. Cash Payment', ANG_Risk_ID__c = '1', ANG_Expiration__c = 24,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=true));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Common ownership default', ANG_Risk_ID__c = '10', ANG_Expiration__c = 24,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Prejudiced collection', ANG_Risk_ID__c = '11', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Late/Short payment', ANG_Risk_ID__c = '2', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Wrong currency payment', ANG_Risk_ID__c = '3', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Payment Default', ANG_Risk_ID__c = '4', ANG_Expiration__c = 24,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=true));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Fail Financial Statements', ANG_Risk_ID__c = '5', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=30,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Major change (owner or legal)', ANG_Risk_ID__c = '6', ANG_Expiration__c = 24,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Unreported Major Change', ANG_Risk_ID__c = '7', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Change HE location', ANG_Risk_ID__c = '8', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Fail Financial Security', ANG_Risk_ID__c = '9', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false));
		insert eventTypes;

		
	}

	static{

		ANG_RiskEventMigrationHelperTest.reMap= new map<string,ANG_Risk_Event_Type__c>();
		for(ANG_Risk_Event_Type__c ret:[select id,name from ANG_Risk_Event_Type__c ] ){
			ANG_RiskEventMigrationHelperTest.reMap.put(ret.id,ret);
		}
	}

	@isTest
	public static void authCashPaymentTest() {
		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc = new Agency_Applied_Change_code__c(
				Account__c = a.id,
				Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_FIN,
				Bulletin_Information__c ='branch'
				);
		insert cc;

		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 0);

		cc.Bulletin_Information__c='';
		update cc;
		
		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_AUTH_CASH_PAYMENT);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

	}

//-------------NEED TO TEST WITHDRAW PART----------------
	@isTest
	public static void lateShortPaymentTest() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_OV1
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

	}

//-------------NEED TO TEST WITHDRAW PART----------------
	@isTest
	public static void paymentDefaultTest() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RCR
												);
		insert cc;

		Agency_Applied_Change_code__c cc1 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RCR,
												PreviousReason__c = '50'
												);
		insert cc1;

		Agency_Applied_Change_code__c cc2 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RCR,
												PreviousReason__c = '53'
												);
		insert cc2;

		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_PAYMENT_DEFAULT);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

	}

	@isTest
	public static void failFinancialStatementsTest() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR ,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_SC2,
												Date_time_of_change__c =system.today().addDays(-10)
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(ANG_RiskEventMigrationHelperTest.reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c , ANG_Risk_Helper.STATUS_ACTIVE);
		system.assertEquals(listRisks.get(0).ANG_Limit_Cash_Conditions__c , false);

	}
	@isTest
	public static void failFinancialStatementsTestWithCashCondition() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR ,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_SC2,
												Date_time_of_change__c =system.today().addDays(-40)
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(ANG_RiskEventMigrationHelperTest.reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c , ANG_Risk_Helper.STATUS_ACTIVE);
		system.assertEquals(listRisks.get(0).ANG_Limit_Cash_Conditions__c , true);

	}
	@isTest
	public static void failFinancialStatementsTestWithoutCashConditionDueFRresult() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;



		Contact cont= new Contact(
        		lastName='lastName',
        		Financial_Assessment_Contact__c=true,
                AccountId = a.Id, 
        		email='test@test.com'
        	);
        insert cont;
		 
		 Case cFS = new Case(
        		Subject = 'rception case',
        		AccountId = a.Id, 
        		contactId=cont.Id,
        		Status = 'Open', 
        		Assessment_Performed_Date__c= system.today(),
        		Financial_Review_Result__c='Satisfactory - New Financial Security',
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review'),
                IFAP_Area__c='asda44'
                 );
        insert cFS;

        Test.startTest();
		Case caseSIdra = new Case(
							BSP_CASS__c = 'BSP',
							parentId=cFS.id,
							RecordTypeid=RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA_Lite'),
							Status = 'Open',
							Origin = 'IATA Internal User',
							Subject = 'subject');

		insert caseSIdra;

		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR ,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_FC2,
												Date_time_of_change__c =system.today().addDays(-40),
												SIDRA_Case__c = caseSIdra.id 
												);
		
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(ANG_RiskEventMigrationHelperTest.reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c , ANG_Risk_Helper.STATUS_ACTIVE);
		system.assertEquals(listRisks.get(0).ANG_Limit_Cash_Conditions__c , false);

	}

//-----------should test all types maybe-------------
	@isTest
	public static void majorChange1Test() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_CCF
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);


	}

	@isTest
	public static void majorChange2Test() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_MCF,
												Bulletin_Information__c = 'aaa aaa aa major aaa aa'
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

	}

	@isTest
	public static void unreportedChangeTest() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);

		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NOT,
												Reason_Code__c = '60',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCAC
												);
		insert cc;
		
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);
	
		//withdraw Unreported Change

		Agency_Applied_Change_code__c ccntw
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NTW,
												PreviousReason__c = '60'
												);
		insert ccntw;

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE);
		system.assertEquals(ANG_Risk_Helper.STATUS_WITHDRAWN,listRisks.get(0).ANG_Event_Status__c);
	
		// Inverted order - generate NTW first and then NOT

		Case c = createCase();
		insert c;

		 ccntw
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NTW,
												PreviousReason__c = '60',
												SIDRA_Case__c = c.id 
												);
		insert ccntw;

		 helper = new ANG_RiskEventMigrationHelper(setAccs);
		 listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE);
		system.assertEquals(ANG_Risk_Helper.STATUS_WITHDRAWN,listRisks.get(0).ANG_Event_Status__c);
		//withdraw Unreported Change

		Agency_Applied_Change_code__c ccNOT 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NOT,
												Reason_Code__c = '60',
												SIDRA_Case__c = c.id, 
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCAC
												);
		insert ccNOT;
		
		

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 2);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE);
		system.assertEquals(ANG_Risk_Helper.STATUS_WITHDRAWN,listRisks.get(0).ANG_Event_Status__c);

		system.assertEquals(reMap.get(listRisks.get(1).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE);
		system.assertEquals(ANG_Risk_Helper.STATUS_WITHDRAWN,listRisks.get(1).ANG_Event_Status__c);

	}



	@isTest
	public static void failFinancialSecurity1Test() {
		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
												Reason_Code__c = '61',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

		//withdraw risk event

		Agency_Applied_Change_code__c ccntw = new Agency_Applied_Change_code__c(
				Account__c = a.id,
				Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RWD,
				PreviousReason__c = '61'
		);
		insert ccntw;

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);
		
			// Invert CC order 
		Case c = createCase();
		insert c;

		 cc = new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
												Reason_Code__c = '61',
												SIDRA_Case__c = c.id, 
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC
												);

		ccntw = new Agency_Applied_Change_code__c(
				Account__c = a.id,
				Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RWD,
				SIDRA_Case__c = c.id,
				PreviousReason__c = '61'
		);
		insert new list<Agency_Applied_Change_code__c>{ccntw,cc};

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 2);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);
		system.assertEquals(reMap.get(listRisks.get(1).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(1).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);
	}

	@isTest
	public static void failFinancialSecurity2Test() {
		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
												Reason_Code__c = 'Review',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW,
												Bulletin_Information__c = 'aaa aaa aa bank aaa aa'
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

		//withdraw risk event

		Agency_Applied_Change_code__c ccntw = new Agency_Applied_Change_code__c(
				Account__c = a.id,
				Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RWD,
				PreviousReason__c = 'Review',
				Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW,
				Bulletin_Information__c = 'aaa aaa aa bank aaa aa'
		);
		insert ccntw;

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);


		// Invert CC order 
		Case c = createCase();
		insert c;

		 cc = new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
												Reason_Code__c = 'Review',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW,
												Bulletin_Information__c = 'aaa aaa aa bank aaa aa',
												SIDRA_Case__c = c.id 
												);

		ccntw = new Agency_Applied_Change_code__c(
				Account__c = a.id,
				Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RWD,
				PreviousReason__c = 'Review',
				Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW,
				Bulletin_Information__c = 'aaa aaa aa bank aaa aa',
				SIDRA_Case__c = c.id 
		);
		insert new list<Agency_Applied_Change_code__c>{ccntw,cc};

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 2);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);
		system.assertEquals(reMap.get(listRisks.get(1).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY);
		system.assertEquals(listRisks.get(1).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);

	}

	@isTest
	public static void commonOwnershipDefaultTest() {
		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RCR,
												PreviousReason__c = '54'
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		//creates 2: common ownership and payment default
		system.assertEquals(listRisks.size() , 2);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_COMMON_OWNERSHIP_DEFAULT);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

		system.assertEquals(reMap.get(listRisks.get(1).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_PAYMENT_DEFAULT);
		system.assertEquals(listRisks.get(1).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);


	}

	@isTest
	public static void prejudicedCollectionTest() {
		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
												Reason_Code__c = '63',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_PREJUDICED_COLLECTION
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

		Agency_Applied_Change_code__c ccRWD 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RWD,
												PreviousReason__c = '63',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_PREJUDICED_COLLECTION
												);
		insert ccRWD;

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);

		 // Invert CC order 
		 
		 
		 Case c = createCase();
		insert c;


		 cc= new Agency_Applied_Change_code__c(Account__c = a.id,
			Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
			Reason_Code__c = '63',
			SIDRA_Case__c = c.id,
			Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_PREJUDICED_COLLECTION
			);

		 ccRWD= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RWD,
												PreviousReason__c = '63',
												SIDRA_Case__c = c.id,
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_PREJUDICED_COLLECTION
												);
		insert new list<Agency_Applied_Change_code__c>{ccRWD,cc};

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 2);
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION);
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);

		system.assertEquals(reMap.get(listRisks.get(1).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION);
		system.assertEquals(listRisks.get(1).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);





	}

	@isTest
	public static void removeWithdrawalLateShortPaymentTest() {
		//run two times for each to insert the witdraw and then confirm that list is empty 

		//------------------------------FOR LATE/SHORT PAYMENT--------------------------

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;

		Case c = createCase();
		insert c;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRW,
												SIDRA_Case__c = c.id 
												);
		insert cc;

		Agency_Applied_Change_code__c cc1 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_OV1,
												SIDRA_Case__c = c.id 
												);
		insert cc1;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();
		
		system.assertEquals(1, listRisks.size());
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT);
		system.assertEquals(ANG_Risk_Helper.STATUS_WITHDRAWN, listRisks.get(0).ANG_Event_Status__c);

		// Invert CC order 

		Case c2 = createCase();
		insert c2;

		cc= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRW,
												SIDRA_Case__c = c2.id 
												);
		

		 cc1 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_OV1,
												SIDRA_Case__c = c2.id 
												);

		insert new list<Agency_Applied_Change_code__c>{cc1,cc};

		helper = new ANG_RiskEventMigrationHelper(setAccs);
		listRisks = helper.convertChangeCodesToRiskEvents();
		
		system.assertEquals(2, listRisks.size());
		system.assertEquals(reMap.get(listRisks.get(0).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT);
		system.assertEquals(ANG_Risk_Helper.STATUS_WITHDRAWN, listRisks.get(0).ANG_Event_Status__c);
		system.assertEquals(reMap.get(listRisks.get(1).ANG_Risk_Type__c).name, ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT);
		system.assertEquals(ANG_Risk_Helper.STATUS_WITHDRAWN, listRisks.get(1).ANG_Event_Status__c);
	}

	@isTest
	public static void removeWithdrawalFailFinancialStatementsTest() {
		//-----------------NTW----------------------------------
		Set<Account> setAccs = new set<Account>();
		List<Agency_Applied_Change_code__c> listCCs = new List<Agency_Applied_Change_code__c>(); 
		Account a = createAccount(true);
		insert a;

		Case c = createCase();
		insert c;

		setAccs.add(a);

		//SIDRA

		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRW,
												SIDRA_Case__c = c.id,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_SC2
												);
		listCCs.add(cc);								

		Agency_Applied_Change_code__c cc1 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_SC2,
												SIDRA_Case__c = c.id 

												);
		listCCs.add(cc1);

		Case csl = createCase();
		insert csl;
		
		Agency_Applied_Change_code__c cc6
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRR,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_SC2,
												SIDRA_Case__c = csl.id 
												);
		listCCs.add(cc6);

		Agency_Applied_Change_code__c cc7 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_IRW,
												Irregularity_Type__c = ANG_Risk_Helper.CHANGE_CODE_IRR_SC2,
												SIDRA_Case__c = csl.id 
												);
		listCCs.add(cc7);

		insert listCCs;

		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(2, listRisks.size());
		system.assertEquals(listRisks.get(0).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);
		system.assertEquals(listRisks.get(1).ANG_Event_Status__c, ANG_Risk_Helper.STATUS_WITHDRAWN);

	}

	static testMethod void testForecast() {
		Account a = createAccount(true);
		a.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
		a.Status__c = AMS_Utils.ACC_S9_APPROVED;
		insert a;
		Agency_Applied_Change_code__c cc = new Agency_Applied_Change_code__c(Account__c = a.Id, Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_FIN);
		insert cc;
		
		ANG_RiskEventMigrationHelper.getRiskForecast(new Set<Account>{a});

		System.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_PASSED , a.ANG_HE_RiskHistoryAssessment__c);
		System.assertEquals(true, a.ANG_HE_CashCondition__c);
		
		//final results are null because we didn't insert calculations
		System.assertEquals(null, a.ANG_HE_RiskStatus__c);
	}

	public static Account createAccount(Boolean isHE){
		IATA_ISO_Country__c isoTest = new IATA_ISO_Country__c(Name = 'Iso Country Name Test', 
															CurrencyIsoCode = 'EUR', 
															ISO_Code_Numeric__c = 620, 
															ISO_Code__c = 'PT',
															AIMS_Area_ID__c='1',
															ANG_Enable_NewGen__c = true);
		insert isoTest;
		
		Account c = new Account(
						Name ='Test Name', 
						IATA_ISO_Country__c = isoTest.id, 
						Type = 'IATA Passenger Sales Agent',
            			Sector__c='Travel Agent', 
						Location_Type__c = (isHE ? AMS_Utils.HE : 'HO'), 
						Location_Class__c = 'P',
						iataCode__C='99999999',
						BillingCountry='Iso Country Name Test'						
            			
					);

		return c;
	}
           
            

	public static Case createCase(){
		Id SIDRARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA').getRecordTypeId();
		
		Case c = new Case(RecordTypeid = SIDRARecordTypeId,
							BSP_CASS__c = 'BSP',
							Status = 'Open',
							Origin = 'IATA Internal User',
							Subject = 'subject',
							IATAcode__c	 = 'webiata code');

 		return c;
	}
}
