@isTest //(SeeAllData=true)

private class ANG_RiskEventMigrationHelperTest {


	@testSetup static void setup(){

		List<ANG_Risk_Event_Type__c> eventTypes = new List<ANG_Risk_Event_Type__c>(); 
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Auth. Cash Payment', ANG_Risk_ID__c = '1', ANG_Expiration__c = 24));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Common ownership default', ANG_Risk_ID__c = '10', ANG_Expiration__c = 24));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Prejudiced collection', ANG_Risk_ID__c = '11', ANG_Expiration__c = 12));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Late/Short payment', ANG_Risk_ID__c = '2', ANG_Expiration__c = 12));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Wrong currency payment', ANG_Risk_ID__c = '3', ANG_Expiration__c = 12));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Payment Default', ANG_Risk_ID__c = '4', ANG_Expiration__c = 24));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Fail Financial Statements', ANG_Risk_ID__c = '5', ANG_Expiration__c = 12));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Major change (owner or legal)', ANG_Risk_ID__c = '6', ANG_Expiration__c = 24));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Unreported Major Change_Code__c', ANG_Risk_ID__c = '7', ANG_Expiration__c = 12));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Change HE location', ANG_Risk_ID__c = '8', ANG_Expiration__c = 12));
		eventTypes.add(new ANG_Risk_Event_Type__c(Name = 'Fail Financial Security', ANG_Risk_ID__c = '9', ANG_Expiration__c = 12));
		insert eventTypes;
	}

	@isTest
	public static void authCashPaymentTest() {
		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_FIN 
												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);

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

	}

	@isTest
	public static void failFinancialStatementsTest() {

		Set<Account> setAccs = new set<Account>();
		Account a = createAccount(true);
		insert a;
		setAccs.add(a);
		Agency_Applied_Change_code__c cc 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NOT ,
												Reason_Code__c = '61',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC

												);
		insert cc;
		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(listRisks.size() , 1);

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
		
		system.assertEquals(0, listRisks.size());
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
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NTW,
												SIDRA_Case__c = c.id 
												);
		listCCs.add(cc);

		Agency_Applied_Change_code__c cc1 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NOT,
												Reason_Code__c = '61',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC,
												SIDRA_Case__c = c.id 

												);
		listCCs.add(cc1);


		//OSCAR
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Name = 'Oscar');
		insert oscar;

		Agency_Applied_Change_code__c cc2 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NTW,
												OSCAR__c = oscar.id 
												);
		listCCs.add(cc2);

		Agency_Applied_Change_code__c cc3 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NOT,
												Reason_Code__c = '61',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC,
												OSCAR__c = oscar.id 

												);
		listCCs.add(cc3);


		//-----------------RVW----------------------------------
		//SIDRA
		Agency_Applied_Change_code__c cc4 = new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
												SIDRA_Case__c = c.id 
												);
		listCCs.add(cc4);

		Agency_Applied_Change_code__c cc5 = new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NOT,
												Reason_Code__c = '61',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC,
												SIDRA_Case__c = c.id 

												);
		listCCs.add(cc5);

		//OSCAR

		Agency_Applied_Change_code__c cc6
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_RVW,
												OSCAR__c = oscar.id 
												);
		listCCs.add(cc6);

		Agency_Applied_Change_code__c cc7 
			= new Agency_Applied_Change_code__c(Account__c = a.id,
												Change_Code__c = ANG_Risk_Helper.CHANGE_CODE_NOT,
												Reason_Code__c = '61',
												Reason_Description__c = ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC,
												OSCAR__c = oscar.id 

												);
		listCCs.add(cc7);

		insert listCCs;

		ANG_RiskEventMigrationHelper helper = new ANG_RiskEventMigrationHelper(setAccs);
		List<ANG_Agency_Risk_Event__c> listRisks = helper.convertChangeCodesToRiskEvents();

		system.assertEquals(0, listRisks.size());

	}

	public static Account createAccount(Boolean isHE){
		IATA_ISO_Country__c isoTest = new IATA_ISO_Country__c(Name = 'Iso Country Name Test', 
															CurrencyIsoCode = 'EUR', 
															ISO_Code_Numeric__c = 620, 
															ISO_Code__c = 'PT');
		insert isoTest;
		
		Account c = new Account(Name ='Test Name', 
								IATA_ISO_Country__c = isoTest.id, 
								Sector__c = 'Airline', 
								Location_Type__c = (isHE ? AMS_Utils.HE : 'HO'), 
								Location_Class__c = 'P'
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