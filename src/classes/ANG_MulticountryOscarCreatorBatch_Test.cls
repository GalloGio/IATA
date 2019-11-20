@isTest
public class ANG_MulticountryOscarCreatorBatch_Test
{
	
	@testSetup static void setup(){
	}
	
	static testMethod void executePortalMCAccreditationAE() {	

 		Id settlementRTId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
			Name = 'France',
			RecordTypeId = settlementRTId
		);

		insert settlement;

		AMS_Settlement_System__c settlement2 = new AMS_Settlement_System__c(
			Name = 'Portugal',
			RecordTypeId = settlementRTId
		);

		insert settlement2;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, Region__c = 'Europe',AMS_Settlement_System__c=settlement.Id, Multicountry_Enabled__c = true);
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
		insert stt;
		
		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true, Region__c = 'Europe',AMS_Settlement_System__c=settlement2.Id, Multicountry_Enabled__c = true);
		insert ctry2;

		IATA_ISO_State__c stt2 = new IATA_ISO_State__c(Name= 'PT', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry2.Id);
		insert stt2;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewgenAgency GE',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = AMS_Utils.GE, Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		insert a1;
		
		Account newBSPCountryAcc = new Account(IATA_ISO_Country__c = ctry2.Id, ParentId = a1.Id, Top_Parent__c = a1.Id, RecordTypeId = accountRT ,Name='NewgenAgency HE 1',Short_Name__c='NewgenAgency HE', Location_Class__c = 'P', Location_Type__c = AMS_Utils.HE, Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		insert newBSPCountryAcc;
		
		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGGE, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = AMS_Utils.RECTYPE_NEWGE);

		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
		oscarCase.AccountId = a1.Id;
		oscarCase.ContactId = co1.Id;
		oscarCase.Origin = 'Portal';
		oscarCase.reason1__c = 'New HE Multicountry';
		insert oscarCase;
		
		ID rtNew = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.getRecordTypeInfosByName().get('Travel Agent - Head Entity Standard no Cash').getRecordTypeId();

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theAccreditation.Account_Name__c='NEWGEN-559 HE5';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Country__c= ctry.Id;
		theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theAccreditation.Branch_Office_City__c='sdfsdfdf';
		theAccreditation.IATA_ISO_State__c= stt.Id;
		theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
		theAccreditation.Branch_Office_Phone__c='123123123';
		theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
		theAccreditation.Abbreviated_Address__c='sdfsdf';
		theAccreditation.Remittance_frequency__c='M';
		theAccreditation.Solicitation_Flag__c=false;
		theAccreditation.Location_Class__c='P';
		theAccreditation.Location_Type__c=AMS_Utils.GE;
		theAccreditation.SAAM_Case__c=oscarCase.Id;
		theAccreditation.ISSP_Branch_AccountId__c  = a1.Id;

		AMS_Pax_Accreditation_Form__c theSecondAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theSecondAccreditation.Account_Name__c='NEWGEN-559 NEWBSP';
		theSecondAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theSecondAccreditation.Branch_Office_Country__c= ctry2.Id;
		theSecondAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theSecondAccreditation.Branch_Office_City__c='sdfsdfdf';
		theSecondAccreditation.IATA_ISO_State__c= stt2.Id;
		theSecondAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
		theSecondAccreditation.Branch_Office_Phone__c='123123123';
		theSecondAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theSecondAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
		theSecondAccreditation.Abbreviated_Address__c='sdfsdf';
		theSecondAccreditation.Remittance_frequency__c='M';
		theSecondAccreditation.Solicitation_Flag__c=false;
		theSecondAccreditation.Location_Class__c='P';
		theSecondAccreditation.Location_Type__c='HE';
		theSecondAccreditation.SAAM_Case__c=oscarCase.Id;
		theSecondAccreditation.ISSP_Branch_AccountId__c = newBSPCountryAcc.Id;

		insert new List<AMS_Pax_Accreditation_Form__c>{theAccreditation,theSecondAccreditation};

		Set<Id> idAccountSet = new Set<Id>();
		
		For(Account acct : [Select id from Account where IATA_ISO_Country__r.Name = 'Portugal']){
			idAccountSet.add(acct.id);
		}
		
		Test.startTest();

		ANG_MulticountryOscarCreatorBatch a = new ANG_MulticountryOscarCreatorBatch(idAccountSet);

		Database.executeBatch(a, 1);
		
		Test.stopTest();

		System.assertEquals(2,[Select Id,SAAM_Case__c,HO_Account__c from AMS_Pax_Accreditation_Form__c].size());
		System.assertEquals(2,[Select Id,AMS_Online_Accreditation__c, Oscar_Communication_Case_Id__c from AMS_OSCAR__c].size());
		System.assertEquals(2,[Select Id from Case].size());

	}

	static testMethod void executeConsoleMCAccreditationAE() {		

 		Id settlementRTId = Schema.AMS_Settlement_System__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('BSP').getRecordTypeId();

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
			Name = 'France',
			RecordTypeId = settlementRTId
		);

		insert settlement;

		AMS_Settlement_System__c settlement2 = new AMS_Settlement_System__c(
			Name = 'Portugal',
			RecordTypeId = settlementRTId
		);

		insert settlement2;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, Region__c = 'Europe',AMS_Settlement_System__c=settlement.Id, Multicountry_Enabled__c = true);
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
		insert stt;
		
		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true, Region__c = 'Europe',AMS_Settlement_System__c=settlement2.Id, Multicountry_Enabled__c = true);
		insert ctry2;

		IATA_ISO_State__c stt2 = new IATA_ISO_State__c(Name= 'PT', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry2.Id);
		insert stt2;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewgenAgency GE',Short_Name__c='NewgenAgency GE', Location_Class__c = 'P', Location_Type__c = AMS_Utils.GE, Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		insert a1;
		
		Account newBSPCountryAcc = new Account(IATA_ISO_Country__c = ctry2.Id, ParentId = a1.Id, Top_Parent__c = a1.Id, RecordTypeId = accountRT ,Name='NewgenAgency HE 1',Short_Name__c='NewgenAgency HE', Location_Class__c = 'P', Location_Type__c = AMS_Utils.HE, Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');
		insert newBSPCountryAcc;
		
		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGGE, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = AMS_Utils.RECTYPE_NEWGE);

		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
		oscarCase.AccountId = a1.Id;
		oscarCase.ContactId = co1.Id;
		oscarCase.Origin = 'Internal User';
		oscarCase.reason1__c = 'New HE Multicountry';
		insert oscarCase;
		
		ID rtNew = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.getRecordTypeInfosByName().get('Travel Agent - Head Entity Standard no Cash').getRecordTypeId();

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theAccreditation.Account_Name__c='NEWGEN-559 HE5';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Country__c= ctry.Id;
		theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theAccreditation.Branch_Office_City__c='sdfsdfdf';
		theAccreditation.IATA_ISO_State__c= stt.Id;
		theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
		theAccreditation.Branch_Office_Phone__c='123123123';
		theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
		theAccreditation.Abbreviated_Address__c='sdfsdf';
		theAccreditation.Remittance_frequency__c='M';
		theAccreditation.Solicitation_Flag__c=false;
		theAccreditation.Location_Class__c='P';
		theAccreditation.Location_Type__c=AMS_Utils.GE;
		theAccreditation.SAAM_Case__c=oscarCase.Id;	

		insert new List<AMS_Pax_Accreditation_Form__c>{theAccreditation};

		Set<Id> idAccountSet = new Set<Id>();
		
		For(Account acct : [Select id from Account where IATA_ISO_Country__r.Name = 'Portugal']){
			idAccountSet.add(acct.id);
		}
		
		Test.startTest();

		ANG_MulticountryOscarCreatorBatch a = new ANG_MulticountryOscarCreatorBatch(idAccountSet);

		Database.executeBatch(a, 1);
		
		Test.stopTest();

		System.assertEquals(2,[Select Id,SAAM_Case__c,HO_Account__c from AMS_Pax_Accreditation_Form__c].size());
		System.assertEquals(2,[Select Id,AMS_Online_Accreditation__c, Oscar_Communication_Case_Id__c from AMS_OSCAR__c].size());
		System.assertEquals(2,[Select Id from Case].size());

	}
}