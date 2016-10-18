public with sharing class AMS_OSCAR_TestDataFactory
{
	public static void createOSCARtestData()
	{
		AMS_Person__c per = new AMS_Person__c(Name = 'teste', User__c = UserInfo.getUserId());
		insert per;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.IATACode__c = '1234567';
		insert account;
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		insert a1;
        
		AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id);
		insert OSCAR;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		//Case c = new Case(OSCAR__c = OSCAR.Id, recordtypeid = caseRT.get('OSCAR_Communication'));
		//insert c;
		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
		insert aacc;
		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;


        //create oscar history custom setting
        List<AMS_OSCAR_HistoryFields__c> customsettings = new List<AMS_OSCAR_HistoryFields__c>();
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'Welcome_Pack_Sent__c', HasExternalLabel__c = false, FieldName__c ='Welcome Pack Sent'));

		insert customsettings;

		

		
	}

	public static void createOSCARwithInspectionsTestData()
	{
		AMS_Person__c per = new AMS_Person__c(Name = 'teste', User__c = UserInfo.getUserId());
		insert per;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		Account account = new Account();
		account.Name = 'TestAccount';
		account.Type = 'Airport';
		account.IATACode__c = '1234567';
		insert account;
		
		List<Account> accountList = new List<Account>();
		
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='9876543',Name='Test2 Agency',Short_Name__c='Test2 Agency');

		accountList.add(a1);
		accountList.add(a2);

		insert accountList;
        
		AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id, Process__c = AMS_Utils.new_HO);
		insert OSCAR;

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		//Case c = new Case(OSCAR__c = OSCAR.Id, recordtypeid = caseRT.get('OSCAR_Communication'));
		//insert c;
		
		List<Agency_Applied_Change_code__c> aaccList = new List<Agency_Applied_Change_code__c>();
		
		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
		Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a2.id);
		aaccList.add(aacc1);
		aaccList.add(aacc2);

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		Contact co2 = new Contact(AccountId = a2.id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		
		List<Contact> coList = new List<Contact>();
		
		coList.add(co1);
		coList.add(co2);

		insert coList;
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;


        //create oscar history custom setting
        List<AMS_OSCAR_HistoryFields__c> customsettings = new List<AMS_OSCAR_HistoryFields__c>();
		customsettings.add(new AMS_OSCAR_HistoryFields__c(Name = 'Welcome_Pack_Sent__c', HasExternalLabel__c = false, FieldName__c ='Welcome Pack Sent'));

		insert customsettings;

		//Create Inspections connected to OSCAR
		
		AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'DOM');
		insert ao;

		AMS_OSCAR__c OSCAR_GSA = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id, Process__c =AMS_Utils.new_GSA);
		
		insert OSCAR_GSA;

		Case oscarCase_GSA = new Case(Oscar__c = OSCAR_GSA.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase_GSA.AccountId = a2.Id;
        oscarCase_GSA.ContactId = co2.Id;
        insert oscarCase_GSA;

		List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '1'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '2'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '3'));
		agencyInspectionList.add(new AMS_Inspection__c(Oscar__c=OSCAR_GSA.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '8'));
		
		insert	agencyInspectionList;

	}    
}