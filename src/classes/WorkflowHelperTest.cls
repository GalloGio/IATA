@isTest
private class WorkflowHelperTest {

	@testSetup static void setup(){
		
	}

	@isTest static void  AccountUpdateIndustryTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');

		Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgencyNoType');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);

		Account acct2 = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
		
		insert new List<Account>{acct,acct2};

		Test.stopTest();

		acct = [Select Id, Industry, Type from Account where name = 'NewGenAgency'];

		System.assertEquals('Travel Agent',acct.Industry);

		acct = [Select Id, Industry, Type from Account where name = 'NewGenAgencyNoType'];

		System.assertEquals(null,acct.Industry);
	}

	@isTest static void  updateAirlineMembershipTestPositive(){
		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgencyHE');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');
		fieldsOfObject.put('IATA_Member__c',true);

		Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

		insert acct;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgencyAE');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');
		fieldsOfObject.put('ParentId',acct.Id);

		Account acctAE = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

		insert acctAE;

		Test.stopTest();
	
		acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

		System.assertEquals(true,acctAE.IATA_Member__c);

		acct.IATA_Member__c = false;
		update acct;

		update acctAE;

		acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

		System.assertEquals(false,acctAE.IATA_Member__c);

	}

	@isTest static void  updateAirlineMembershipTest(){
		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgencyHE');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');
		fieldsOfObject.put('IATA_Member__c',true);

		Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

		insert acct;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgencyAE');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');
		fieldsOfObject.put('ParentId',acct.Id);

		Account acctAE = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

		insert acctAE;

		Test.stopTest();
	
		acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

		System.assertEquals(true,acctAE.IATA_Member__c);

		acct.IATA_Member__c = false;
		update acct;

		update acctAE;

		acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

		System.assertEquals(false,acctAE.IATA_Member__c);

	}

	@isTest static void  updateLastModifiedDateByIntegrationsTest(){
		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');

		Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

		insert acct;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency2');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);

		Account acct2 = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
		

		// Create a unique UserName
		  String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';

		// This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(
			Alias = 'standt',
			Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8',
			FirstName = 'System',
			LastName='Integrations',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles',
			UserName=uniqueUserName,
			License_Cost_Center__c ='IDS005CH01'
			);

		System.runAs(u) {
			insert acct2;
		}


		Test.stopTest();
	
		acct =  [Select Id, Last_Modified_by_Source__c from Account where name = 'NewGenAgency'];
		acct2 = [Select Id, Last_Modified_by_Source__c from Account where name = 'NewGenAgency2'];

		System.assertEquals(null,acct.Last_Modified_by_Source__c);

		Date date1 = date.newinstance(System.today().year(), System.today().month(), System.today().day());
		Date date2 = date.newinstance(acct2.Last_Modified_by_Source__c.year(), acct2.Last_Modified_by_Source__c.month(), acct2.Last_Modified_by_Source__c.day());

		System.assertEquals(date1,date2);

		System.runAs(u) {
			update acct;
		}

		acct =  [Select Id, Last_Modified_by_Source__c from Account where name = 'NewGenAgency'];
		
		date1 = date.newinstance(System.today().year(), System.today().month(), System.today().day());
		date2 = date.newinstance(acct.Last_Modified_by_Source__c.year(), acct.Last_Modified_by_Source__c.month(), acct.Last_Modified_by_Source__c.day());

		System.assertEquals(date1,date2);

	}

	@isTest static void  updateWebstarAccountCategoryTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Source_System__c','webstar');

		Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

		insert acct;

		Test.stopTest();

		acct =  [Select Id, sector__c, Category__c from Account where name = 'NewGenAgency'];

		System.assertEquals('Travel Agent',acct.sector__c);
		System.assertEquals('IATAN Passenger Agent',acct.Category__c);
		
	}

	@isTest static void  updateAIMSAccountRecordtypeTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Is_AIMS_Account__c',true);
		fieldsOfObject.put('Source_System__c','webstar');

		Account acct = ANG_EntityCreator.createAccount(standardRT, ctry.Id, fieldsOfObject);

		insert acct;

		Test.stopTest();

		acct =  [Select Id, recordTypeId from Account where name = 'NewGenAgency'];

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		System.assertEquals(accountRT,acct.recordTypeId);
		
	}    

	@isTest static void  resetAccountIdCardDiscountTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('ID_Card_Key_Account_Discount__c',50);
		fieldsOfObject.put('IDCard_Key_Account__c',true);

		Account acct = ANG_EntityCreator.createAccount(standardRT, ctry.Id, fieldsOfObject);

		insert acct;

		Test.stopTest();

		acct.IDCard_Key_Account__c = false;
		update acct;

		acct =  [Select Id, ID_Card_Key_Account_Discount__c from Account where name = 'NewGenAgency'];

		System.assertEquals(0,acct.ID_Card_Key_Account_Discount__c);
		
	}    
	
	@isTest static void resetAccountTypeTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Sector__c','Airline');
		fieldsOfObject.put('ACLI_Status__c','Active Company');
		fieldsOfObject.put('Account_Type__c','Not Applicable');

		Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency2');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Sector__c','Airline');
		fieldsOfObject.put('ACLI_Status__c','Active Company');
		fieldsOfObject.put('Account_Type__c','Not Applicable');
		fieldsOfObject.put('Membership_status__c','IATA member');

		Account acct2 = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		insert new List<Account>{acct,acct2};

		Test.stopTest();

		acct =  [Select Id, Account_Type__c from Account where name = 'NewGenAgency'];

		System.assertEquals(null,acct.Account_Type__c);

		acct2 =  [Select Id, Account_Type__c from Account where name = 'NewGenAgency2'];

		System.assertEquals('Not Applicable',acct2.Account_Type__c);

	}


	@isTest static void restoreAccountTypeTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Sector__c','Airline');
		fieldsOfObject.put('ACLI_Status__c','Active Company');
		fieldsOfObject.put('Membership_status__c','IATA member');

		Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		insert new List<Account>{acct};

		Test.stopTest();

		acct =  [Select Id,Sector__c,Membership_status__c,ACLI_Status__c,Account_Type__c from Account where name = 'NewGenAgency'];

		system.debug('dudu account is:'+acct);

		System.assertEquals('Not Applicable',acct.Account_Type__c);


	}

	@isTest static void setAccountSiteTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Created by customer');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Industry','Travel Agent');
		fieldsOfObject.put('Site','Site');
		fieldsOfObject.put('Sector__c','Travel Agent');
		
		Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency2');
		fieldsOfObject.put('Short_Name__c','NewGenAgency2');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Created by customer');
		fieldsOfObject.put('Airline_designator__c','1234');
		fieldsOfObject.put('IATACode__c','1234567');
		fieldsOfObject.put('Industry','Travel Agent');
		fieldsOfObject.put('Site','Site');
		fieldsOfObject.put('Sector__c','Airline');

		Account acct2 = ANG_EntityCreator.createAccount(standardRT, ctry.Id, fieldsOfObject);
			
		insert new List<Account>{acct,acct2};

		Test.stopTest();

		acct =   [Select Id,Industry,Site,Airline_designator__c,IATACode__c, IATA_ISO_Country__r.ISO_Code__c from Account where name = 'NewGenAgency'];
		acct2 =  [Select Id,Industry,Site,Airline_designator__c,IATACode__c, IATA_ISO_Country__r.ISO_Code__c from Account where name = 'NewGenAgency2'];

		System.assertEquals('Site',acct.site);
		System.assertEquals('1234 1234567 PT',acct2.site);

	}

	@isTest static void setDataQualityHistoryTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Created by customer');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Industry','Travel Agent');

		Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		insert new List<Account>{acct};

		Test.stopTest();

		acct =   [Select Id,Data_quality_history__c from Account where name = 'NewGenAgency'];

		System.assertEquals(null, acct.Data_quality_history__c);

		acct.Comment_data_quality_feedback__c = 'XPTO';
		update acct;

		acct =   [Select Id,Data_quality_history__c from Account where name = 'NewGenAgency'];

		String formattedDate = System.now().format('YYYY-MM-dd');

		System.assertEquals(formattedDate+': XPTO', acct.Data_quality_history__c);
	}

	@isTest static void  updateAirlineTradeNameParentTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgencyHE');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');
		fieldsOfObject.put('IATA_Member__c',true);
		fieldsOfObject.put('TradeName__c','tradenameParent');

		Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		insert acct;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgencyAE');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','AE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Account is missing');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Type','IATA Passenger Sales Agent');
		fieldsOfObject.put('ParentId',acct.Id);
		fieldsOfObject.put('TradeName__c','AE Trade Name');

		Account acctAE = ANG_EntityCreator.createAccount(AMS_Utils.RECTYPE_AIRLINE_BR, ctry.Id, fieldsOfObject);

		insert acctAE;

		Test.stopTest();
	
		acctAE = [Select Id, TradeName__c, name from Account where location_type__c = 'AE'];

		System.assertEquals('tradenameParent',acctAE.TradeName__c);
		System.assertEquals('tradenameParent',acctAE.name);

		acct.TradeName__c = 'NewTradeNameParent';        
		acctAE.TradeName__c = 'XPTO';


        Profile p = [SELECT Id FROM Profile WHERE Name='Account management team'];
        
        User u = [Select id from User where ProfileId = :p.Id AND isActive = true LIMIT 1];

		System.runAs(u) {
			
			update new List<Account>{acct,acctAE};
		}

		acctAE = [Select Id, TradeName__c, name from Account where location_type__c = 'AE'];

		System.assertEquals('NewTradeNameParent',acctAE.name);

	}


	@isTest static void setAccountDDSUpdateDateTest(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Created by customer');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Industry','Travel Agent');
		fieldsOfObject.put('DDS_Status__c','No Reply');

		Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		insert new List<Account>{acct};

		Test.stopTest();

		acct =   [Select Id,DDS_Last_Update_Date__c from Account where name = 'NewGenAgency'];

		System.assertEquals(null,acct.DDS_Last_Update_Date__c);

		acct.DDS_Status__c = 'multinational';
		update acct;

		acct =   [Select Id,DDS_Last_Update_Date__c from Account where name = 'NewGenAgency'];
		
		Date date1 = date.newinstance(System.today().year(), System.today().month(), System.today().day());
		Date date2 = date.newinstance(acct.DDS_Last_Update_Date__c.year(), acct.DDS_Last_Update_Date__c.month(), acct.DDS_Last_Update_Date__c.day());

		System.assertEquals(date1,date2);

	}

	@isTest static void setACLIAccountNameTest(){

		// Create a unique UserName
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
		
		// This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User u = new User(
			Alias = 'standt',
			Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8',
			FirstName = 'System',
			LastName='Integrations',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles',
			UserName=uniqueUserName,
			License_Cost_Center__c ='IDS005CH01'
			);
		
		insert u;

		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Airline_HQ_ACLI'];
		insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
		
		Test.startTest();

		System.runAs(u) {
			
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

		Map<String,Object> fieldsOfObject;

		fieldsOfObject = new Map<String,Object>();
		fieldsOfObject.put('Name','NewGenAgency');
		fieldsOfObject.put('Short_Name__c','NewGenAgency');
		fieldsOfObject.put('Location_Class__c','P');
		fieldsOfObject.put('Location_Type__c','HE');
		fieldsOfObject.put('Remittance_frequency__c','M');
		fieldsOfObject.put('Reason_for_creation__c','Created by customer');
		fieldsOfObject.put('Company_Type__c','A');
		fieldsOfObject.put('Name_on_AOC__c','NEWNAME');

		Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

		insert new List<Account>{acct};

		Test.stopTest();

		acct =   [Select Id,Name from Account];

		System.assertEquals('NEWNAME', acct.Name);

		acct.Name_on_AOC__c = null;
		acct.Legal_name__c  = 'OLDNAME';


		update acct;
			
		acct =   [Select Id,Name from Account];

		System.assertEquals('OLDNAME', acct.Name);
		
		}


    }

    @isTest static void updateRecordSharingCriteriaTest() {

        String uniqueUserName = 'iataiwuser' + DateTime.now().getTime() + '@testorg.com';

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
        insert ctry ;

        Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        Account account = new Account();
        account.Name = 'Update Record Sharing Criteria Test';
        account.IATA_ISO_Country__c = ctry.Id;
        account.RecordTypeId = standardAccountRT;
        insert account;

        List<Contact> conListToInsert = new List<Contact>();

        Contact c1 = new Contact();
        c1.LastName = 'Contact 1';
        c1.Email = uniqueUserName + '1';
        c1.AccountId = account.Id;
        c1.Record_Sharing_Criteria__c = 'IFG Active Users';
        conListToInsert.add(c1);

        Contact c2 = new Contact();
        c2.LastName = 'Contact 2';
        c2.Email = uniqueUserName + '2';
        c2.AccountId = account.Id;
        c2.Record_Sharing_Criteria__c = 'None';
        conListToInsert.add(c2);

        Test.startTest();
        insert conListToInsert;
        Test.stopTest();

        List<Contact> conList = [SELECT Id, Record_Sharing_Criteria_AUX__c FROM Contact WHERE AccountId =: account.Id];

        System.assertEquals('IFG Active Users;', conList.get(0).Record_Sharing_Criteria_AUX__c);
        System.assertEquals(null, conList.get(1).Record_Sharing_Criteria_AUX__c);
    }

    @isTest static void keyContactOptOutTest() {

        String uniqueUserName = 'iataiwuser' + DateTime.now().getTime() + '@testorg.com';

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
        insert ctry ;

        Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        Account account = new Account();
        account.Name = 'Key Contact Opt Out Test';
        account.IATA_ISO_Country__c = ctry.Id;
        account.RecordTypeId = standardAccountRT;
        insert account;

        List<Contact> conListToInsert = new List<Contact>();

        Contact c1 = new Contact();
        c1.FirstName = 'My';
        c1.LastName = 'Contact 1';
        c1.Email = uniqueUserName + '1';
        c1.AccountId = account.Id;
        c1.CEO_CFO__c = 'CEO';
        c1.HasOptedOutOfEmail = false;
        c1.Marketing_Communications_Opt_in__c = true;
        c1.Title = 'Manager';
        c1.Membership_Function__c = 'Finance';
        conListToInsert.add(c1);

        Contact c2 = new Contact();
        c2.FirstName = 'My';
        c2.LastName = 'Contact 2';
        c2.Email = uniqueUserName + '2';
        c2.AccountId = account.Id;
        c2.HasOptedOutOfEmail = false;
        c2.Marketing_Communications_Opt_in__c = true;
        conListToInsert.add(c2);

        Test.startTest();
        insert conListToInsert;
        Test.stopTest();

        List<Contact> conList = [SELECT Id, HasOptedOutOfEmail, Marketing_Communications_Opt_in__c FROM Contact WHERE AccountId =: account.Id];

        System.assert(conList.get(0).HasOptedOutOfEmail);
        System.assert(!conList.get(0).Marketing_Communications_Opt_in__c);
        System.assert(!conList.get(1).HasOptedOutOfEmail);
        System.assert(conList.get(1).Marketing_Communications_Opt_in__c);
    }

    @isTest static void updateIDCardContactCheckboxTest() {

        String uniqueUserName = 'iataiwuser' + DateTime.now().getTime() + '@testorg.com';

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
        insert ctry ;

        Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        Account account = new Account();
        account.Name = 'Update ID Card Contact Checkbox Test';
        account.IATA_ISO_Country__c = ctry.Id;
        account.RecordTypeId = standardAccountRT;
        insert account;

        List<Contact> conListToInsert = new List<Contact>();

        Contact c1 = new Contact();
        c1.LastName = 'Contact 1';
        c1.Email = uniqueUserName + '1';
        c1.AccountId = account.Id;
        c1.ID_Card_Holder__c = false;
        conListToInsert.add(c1);

        Contact c2 = new Contact();
        c2.LastName = 'Contact 2';
        c2.Email = uniqueUserName + '2';
        c2.AccountId = account.Id;
        c2.VER_Number__c = 1234567890;
        c2.ID_Card_Holder__c = false;
        conListToInsert.add(c2);

        Test.startTest();
        insert conListToInsert;
        Test.stopTest();

        List<Contact> conList = [SELECT Id, ID_Card_Holder__c FROM Contact WHERE AccountId =: account.Id];

        System.assert(!conList.get(0).ID_Card_Holder__c);
        System.assert(conList.get(1).ID_Card_Holder__c);
    }

	@isTest static void changeCaseOriginToFaxTest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Change Case Origin To Fax Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Infofax recibido desde: Case 1 Change Case Origin To Fax Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Change Case Origin To Fax Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		casesListToInsert.add(c2);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, Origin FROM Case WHERE AccountId =: account.Id];

		System.assertEquals('Fax', casesList.get(0).Origin);
		System.assertEquals('IATA Internal User', casesList.get(1).Origin);
	}

	@isTest static void updateACCADatetimeCaseEscalatedTest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update ACCA Datetime Case Escalated Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update ACCA Datetime Case Escalated Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.Escalate_to_ACCA__c = true;
		c1.ACCA_Date_Time_New__c = null;
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update ACCA Datetime Case Escalated Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.Escalate_to_ACCA__c = false;
		c2.ACCA_Date_Time_New__c = null;
		casesListToInsert.add(c2);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, ACCA_Date_Time_New__c FROM Case WHERE AccountId =: account.Id];

		System.assertNotEquals(null, casesList.get(0).ACCA_Date_Time_New__c);
		System.assertEquals(null, casesList.get(1).ACCA_Date_Time_New__c);
	}

	@isTest static void updateACCADatetimeCaseScheduledTest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update ACCA Datetime Case Scheduled Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update ACCA Datetime Case Scheduled Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.Planned_End_CR__c = Date.today();
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update ACCA Datetime Case Scheduled Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.Planned_Start_CR__c = Date.today();
		casesListToInsert.add(c2);

		Case c3 = new Case();
		c3.Subject = 'Case 3 Update ACCA Datetime Case Scheduled Test';
		c3.Status = 'Open';
		c3.Region__c = 'Europe';
		c3.Origin = 'IATA Internal User';
		c3.CaseArea__c = 'Agency Management';
		c3.AccountId = account.Id;
		casesListToInsert.add(c3);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, ACCA_Date_Time_Scheduled__c FROM Case WHERE AccountId =: account.Id];

		System.assertNotEquals(null, casesList.get(0).ACCA_Date_Time_Scheduled__c);
		System.assertNotEquals(null, casesList.get(1).ACCA_Date_Time_Scheduled__c);
		System.assertEquals(null, casesList.get(2).ACCA_Date_Time_Scheduled__c);
	}

	@isTest static void updateACCADatetimeCaseCompletedTest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update ACCA Datetime Case Completed Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update ACCA Datetime Case Completed Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.CR_Status__c = 'Completed';
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update ACCA Datetime Case Completed Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.Escalated_Status_ACCA__c = 'Completed';
		c2.ACCA_Owner__c = UserInfo.getUserId();
		casesListToInsert.add(c2);

		Case c3 = new Case();
		c3.Subject = 'Case 3 Update ACCA Datetime Case Completed Test';
		c3.Status = 'Open';
		c3.Region__c = 'Europe';
		c3.Origin = 'IATA Internal User';
		c3.CaseArea__c = 'Agency Management';
		c3.AccountId = account.Id;
		c3.CR_Status__c = null;
		c3.Escalated_Status_ACCA__c = null;
		casesListToInsert.add(c3);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, ACCA_Date_Time_Completed__c FROM Case WHERE AccountId =: account.Id];

		System.assertNotEquals(null, casesList.get(0).ACCA_Date_Time_Completed__c);
		System.assertNotEquals(null, casesList.get(1).ACCA_Date_Time_Completed__c);
		System.assertEquals(null, casesList.get(2).ACCA_Date_Time_Completed__c);
	}

	@isTest static void updateRecordTypeToLockedTest() {

		Id DPCSystem_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request');
		Id DPCSystemsLocked_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_DPC_Systems_locked');
		Id InternalCases_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update Record Type To Locked Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update Record Type To Locked Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.RecordTypeId = DPCSystem_RT;
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update Record Type To Locked Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.RecordTypeId = InternalCases_RT;
		casesListToInsert.add(c2);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, RecordTypeId FROM Case WHERE AccountId =: account.Id];

		System.assertEquals(DPCSystemsLocked_RT, casesList.get(0).RecordTypeId);
		System.assertEquals(InternalCases_RT, casesList.get(1).RecordTypeId);
	}

	@isTest static void uncheckNewCommentforACCATest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Uncheck New Comment for ACCA Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Uncheck New Comment for ACCA Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.Escalated_Status_ACCA__c = 'Completed';
		c1.ACCA_Owner__c = UserInfo.getUserId();
		c1.New_Comment_for_ACCA__c = true;
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Uncheck New Comment for ACCA Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.Escalated_Status_ACCA__c = 'New';
		c2.New_Comment_for_ACCA__c = true;
		casesListToInsert.add(c2);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, New_Comment_for_ACCA__c FROM Case WHERE AccountId =: account.Id];

		System.assert(!casesList.get(0).New_Comment_for_ACCA__c);
		System.assert(casesList.get(1).New_Comment_for_ACCA__c);
	}

	@isTest static void updateStatusToEscalatedTest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update Status To Escalated Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update Status To Escalated Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.Escalated_Status_ACCA__c = 'Reopend by IATA';
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update Status To Escalated Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.Escalated_Status_ACCA__c = 'New';
		casesListToInsert.add(c2);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, Status FROM Case WHERE AccountId =: account.Id];

		System.assertEquals('2.0 IE approved - Escalated DPC for PQ', casesList.get(0).Status);
		System.assertEquals('Open', casesList.get(1).Status);
	}

	@isTest static void updateDPCStatusTest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update DPC Status Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update DPC Status Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.Escalated_Status_ACCA__c = 'Completed';
		c1.ACCA_Owner__c = UserInfo.getUserId();
		c1.New_Comment_for_ACCA__c = true;
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update DPC Status Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.Escalated_Status_ACCA__c = 'New';
		casesListToInsert.add(c2);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, Escalated_Status_ACCA__c FROM Case WHERE AccountId =: account.Id];

		System.assertEquals('2.0 DPC Investigating', casesList.get(0).Escalated_Status_ACCA__c);
		System.assertEquals('New', casesList.get(1).Escalated_Status_ACCA__c);
	}

	@isTest static void updateCSRScheduledTest() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update CSR Scheduled Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update CSR Scheduled Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'IATA Internal User';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.Planned_End_CR__c = Date.today();
		c1.CR_Status__c = null;
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update CSR Scheduled Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'IATA Internal User';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.Planned_Start_CR__c = Date.today();
		c2.CR_Status__c = null;
		casesListToInsert.add(c2);

		Case c3 = new Case();
		c3.Subject = 'Case 3 Update CSR Scheduled Test';
		c3.Status = 'Open';
		c3.Region__c = 'Europe';
		c3.Origin = 'IATA Internal User';
		c3.CaseArea__c = 'Agency Management';
		c3.AccountId = account.Id;
		c3.CR_Status__c = null;
		casesListToInsert.add(c3);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, CR_Status__c, Escalated_Status_ACCA__c FROM Case WHERE AccountId =: account.Id];

		System.assertEquals('Scheduled', casesList.get(0).CR_Status__c);
		System.assertEquals('Scheduled', casesList.get(1).CR_Status__c);
		System.assertEquals(null, casesList.get(2).CR_Status__c);
		System.assertEquals('CSR Scheduled', casesList.get(0).Escalated_Status_ACCA__c);
		System.assertEquals('CSR Scheduled', casesList.get(1).Escalated_Status_ACCA__c);
		System.assertEquals(null, casesList.get(2).Escalated_Status_ACCA__c);
	}

	@isTest static void updateRTExternalInternalTest() {

		Id DPCSystem_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request');
		Id InternalCases_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');
		Id OperationalManagementHO_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Case_Operational_Management_Head_Office');

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT');
		insert ctry;

		Id standardAccountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account account = new Account();
		account.Name = 'Update RT External Internal Test';
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = standardAccountRT;
		insert account;

		List<Case> casesListToInsert = new List<Case>();

		Case c1 = new Case();
		c1.Subject = 'Case 1 Update RT External Internal Test';
		c1.Status = 'Open';
		c1.Region__c = 'Europe';
		c1.Origin = 'E-mail to Case - BSPlink';
		c1.CaseArea__c = 'Agency Management';
		c1.AccountId = account.Id;
		c1.SuppliedEmail = 'internalemail@iata.test';
		c1.RecordTypeId = DPCSystem_RT;
		casesListToInsert.add(c1);

		Case c2 = new Case();
		c2.Subject = 'Case 2 Update RT External Internal Test';
		c2.Status = 'Open';
		c2.Region__c = 'Europe';
		c2.Origin = 'E-mail to Case - BSPlink';
		c2.CaseArea__c = 'Agency Management';
		c2.AccountId = account.Id;
		c2.SuppliedEmail = 'externalemail@ext.test';
		c2.RecordTypeId = DPCSystem_RT;
		casesListToInsert.add(c2);

		Test.startTest();
		insert casesListToInsert;
		Test.stopTest();

		List<Case> casesList = [SELECT Id, RecordTypeId FROM Case WHERE AccountId =: account.Id];

		System.assertEquals(InternalCases_RT, casesList.get(0).RecordTypeId);
		System.assertEquals(OperationalManagementHO_RT, casesList.get(1).RecordTypeId);
	}
}
