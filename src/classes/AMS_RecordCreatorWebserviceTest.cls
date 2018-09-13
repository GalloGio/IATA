@isTest
private class AMS_RecordCreatorWebserviceTest {
	
    @testSetup static void setup(){
		
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        insert ctry;

		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');

		Account acct = new Account();

		acct.NAME = 'Lions Travel 8';
		acct.TYPE = 'Non-IATA Passenger Agent';
		acct.RECORDTYPEID = accountRT;
		acct.BILLINGCOUNTRY = 'Greece';
		acct.INDUSTRY = 'Travel Agent';
		acct.CURRENCYISOCODE = 'USD';
		acct.TRADENAME__C = 'Lions Travel 8';
		acct.IATA_MEMBER__C = false;
		acct.LOCATION_TYPE__C = 'HO';
		acct.LEGAL_NAME__C = 'Lions Travel 8';
		acct.SHORT_NAME__C = 'Lions Travel 8';
		acct.IATA_ISO_COUNTRY__C = ctry.Id;
		acct.CATEGORY__C = 'IATA Passenger Sales Agent';
		acct.SECTOR__C = 'Travel Agent';
		acct.LOCATION_CLASS__C = 'P';
		acct.COMPANY_TYPE__C = 'A';
		acct.IN_A_AIRPORT__C = false;
		acct.REASON_FOR_CREATION__C = 'Created by customer';

		insert acct;

		System.debug('First Account created is ' + acct.Id);

		Account acct2 = new Account();

		acct2.NAME = 'Lions Travel 9';
		acct2.TYPE = 'Non-IATA Passenger Agent';
		acct2.RECORDTYPEID = accountRT;
		acct2.BILLINGCOUNTRY = 'Greece';
		acct2.INDUSTRY = 'Travel Agent';
		acct2.CURRENCYISOCODE = 'USD';
		acct2.TRADENAME__C = 'Lions Travel 9';
		acct2.IATA_MEMBER__C = false;
		acct2.LOCATION_TYPE__C = 'BR';
		acct2.LEGAL_NAME__C = 'Lions Travel 9';
		acct2.SHORT_NAME__C = 'Lions Travel 9';
		acct2.IATA_ISO_COUNTRY__C = ctry.Id;
		acct2.CATEGORY__C = 'IATA Passenger Sales Agent';
		acct2.SECTOR__C = 'Travel Agent';
		acct2.LOCATION_CLASS__C = 'P';
		acct2.COMPANY_TYPE__C = 'A';
		acct2.IN_A_AIRPORT__C = false;
		acct2.REASON_FOR_CREATION__C = 'Created by customer';
		acct2.ParentId = acct.Id;

		insert acct2;


		//List<Account> accts = new List<Account>{acct,acct2};
		//insert accts;

		System.debug('Accounts created');

		Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');

		Contact co1 = new Contact(AccountId = acct.Id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		
		Contact co2 = new Contact(AccountId = acct2.Id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		
		List<Contact> contacts = new List<Contact>{co1,co2};
		insert contacts;

		System.debug('Contacts created');

		ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

		Case oscarCase = new Case(RecordTypeId = rtCommCase, AccountId = acct.Id, Account_Concerned__c = acct.Id, ContactId = co1.Id);

		Case oscarCase2 = new Case(RecordTypeId = rtCommCase, AccountId = acct2.Id, Account_Concerned__c = acct2.Id, ContactId = co2.Id);

		List<Case> cases = new List<Case>{oscarCase,oscarCase2};
		insert cases;

		System.debug('Cases created');

		AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = oscarCase.id);
        
		AMS_Pax_Accreditation_Form__c accre2 = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = oscarCase2.id);
        
        List<AMS_Pax_Accreditation_Form__c> acredts = new List<AMS_Pax_Accreditation_Form__c>{accre,accre2};

		insert acredts;

		System.debug('Accreditations created');


    }
	
	@isTest static void createMinorChangesTradeNameChangeCode() {

		Test.startTest();
		
		Account acct = [SELECT Id from Account LIMIT 1];

		insert new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'CADM', Change_Code__c = 'CAD');
		insert new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'CTA', Change_Code__c = 'CTA');

		AMS_RecordCreatorWebservice.AccountChanges acctChange1 = new AMS_RecordCreatorWebservice.AccountChanges('TradeName__c','Old TradeName Value','New TradeName Value');
		AMS_RecordCreatorWebservice.AccountChanges acctChange2 = new AMS_RecordCreatorWebservice.AccountChanges('Email__c','Old Email Value','New Email Value');
		AMS_RecordCreatorWebservice.AccountChanges acctChange3 = new AMS_RecordCreatorWebservice.AccountChanges('In_a_Airport__c', 'true','false');

		List<AMS_RecordCreatorWebservice.AccountChanges> changes = new List<AMS_RecordCreatorWebservice.AccountChanges>();

		changes.add(acctChange1);
		changes.add(acctChange2);
		changes.add(acctChange3);

		AMS_RecordCreatorWebservice.createMinorChangesChangeCode(acct.Id, changes);

		List<Agency_Applied_Change_code__c> aaccList = [SELECT id from Agency_Applied_Change_code__c where Account__c = :acct.Id];

		System.assertEquals(aaccList.size() , 2);

		Test.stopTest();
	}

	
	@isTest static void createMinorChangesChangeCode() {

		Test.startTest();
		
		Account acct = [SELECT Id from Account LIMIT 1];

		insert new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'CADM', Change_Code__c = 'CAD');

		AMS_RecordCreatorWebservice.AccountChanges acctChange1 = new AMS_RecordCreatorWebservice.AccountChanges('Name','Old Name Value','New Name Value');
		AMS_RecordCreatorWebservice.AccountChanges acctChange2 = new AMS_RecordCreatorWebservice.AccountChanges('Email__c','Old Email Value','New Email Value');
		AMS_RecordCreatorWebservice.AccountChanges acctChange3 = new AMS_RecordCreatorWebservice.AccountChanges('In_a_Airport__c', 'true','false');

		List<AMS_RecordCreatorWebservice.AccountChanges> changes = new List<AMS_RecordCreatorWebservice.AccountChanges>();

		changes.add(acctChange1);
		changes.add(acctChange2);
		changes.add(acctChange3);

		AMS_RecordCreatorWebservice.createMinorChangesChangeCode(acct.Id, changes);

		List<Agency_Applied_Change_code__c> aaccList = [SELECT id from Agency_Applied_Change_code__c where Account__c = :acct.Id];

		System.assertEquals(aaccList.size() , 1);

		AMS_RecordCreatorWebservice.testsendNotification(acct.Id,changes);

		Test.stopTest();
	}

	@isTest static void createAccreditation() {

		Test.startTest();
		
		List<Account> acctLst = [SELECT Id, Name, ParentId from Account];

		Account acct = acctLst.get(0);

		System.debug('Got first account with id:' + acct.Id + ' and with name:' + acct.Name + ' and parent Id:' + acct.ParentId);

		Case caseCom = [SELECT Id from Case where AccountId = : acct.Id];

		AMS_Pax_Accreditation_Form__c accr = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom.Id];

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(acct.Id,accr.Id,'NEW.HO.1.0',caseCom.Id);

		System.debug('First Oscar created is ' +  oscarId);

		List<AMS_OSCAR__c> oscarLst = [SELECT Id from AMS_OSCAR__c];

		System.assertEquals(oscarLst.size(),1);

		Account acct2 = acctLst.get(1);

		System.debug('Got second account with id:' + acct2.Id + ' and with name:' + acct2.Name + ' and parent Id:' + acct2.ParentId);

		Case caseCom2 = [SELECT Id, Account_Concerned__c from Case where AccountId = :acct2.Id];

		AMS_Pax_Accreditation_Form__c accr2 = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom2.Id];

		String oscarId2 = AMS_RecordCreatorWebservice.createAccreditation(acct2.Id,accr2.Id,'NEW.BR',caseCom2.Id);

		System.debug('Second Oscar created is ' +  oscarId);

		List<AMS_OSCAR__c> oscarLst2 = [SELECT Id from AMS_OSCAR__c];

		System.assertEquals(oscarLst2.size(),2);

		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id from AMS_Agencies_Hierarchy__c ];

		System.assertEquals(hierarchies.size(),1);

		List<AMS_Agencies_relationhip__c> relations = [SELECT Id from AMS_Agencies_relationhip__c ];

		System.assertEquals(hierarchies.size(),1);


		


		Test.stopTest();

	}

	@isTest static void createAccreditationChangeOfName() {
		
		Test.startTest();
		
		List<Account> acctLst = [SELECT Id, Name, ParentId from Account];

		Account acct = acctLst.get(0);

		System.debug('Got first account with id:' + acct.Id + ' and with name:' + acct.Name + ' and parent Id:' + acct.ParentId);

		Case caseCom = [SELECT Id from Case where AccountId = : acct.Id];

		AMS_Pax_Accreditation_Form__c accr = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom.Id];

		accr.Notify_Change_Legal_Details__c = true;
		accr.Scope_of_Change__c = 'HO Only';

		update accr;

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(acct.Id,accr.Id,'MAJOR.CHANGES',caseCom.Id);

		List<AMS_OSCAR__c> oscarLst = [SELECT Id, Type_of_change__c from AMS_OSCAR__c];

		System.assertEquals(oscarLst.size(),1);

		AMS_OSCAR__c oscar = oscarLst.get(0);

		System.assertEquals(oscar.Type_of_change__c,'Name');

		Test.stopTest();
	}

	@isTest static void createAccreditationChangeOfOwnerShipAllBranches() {

		List<Account> acctLst = [SELECT Id, Name, ParentId from Account];

		Account acct = acctLst.get(0);

		Account acct2 = acctLst.get(1);

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy test');

		insert h;


		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		
		IATA_ISO_Country__c ctry = [SELECT ID FROM IATA_ISO_Country__c LIMIT 1];

		Account acct3 = new Account();

		acct3.NAME = 'Lions Travel 3';
		acct3.TYPE = 'Non-IATA Passenger Agent';
		acct3.RECORDTYPEID = accountRT;
		acct3.BILLINGCOUNTRY = 'Greece';
		acct3.INDUSTRY = 'Travel Agent';
		acct3.CURRENCYISOCODE = 'USD';
		acct3.TRADENAME__C = 'Lions Travel 3';
		acct3.IATA_MEMBER__C = false;
		acct3.LOCATION_TYPE__C = 'BR';
		acct3.LEGAL_NAME__C = 'Lions Travel 3';
		acct3.SHORT_NAME__C = 'Lions Travel 3';
		acct3.IATA_ISO_COUNTRY__C = ctry.Id;
		acct3.CATEGORY__C = 'IATA Passenger Sales Agent';
		acct3.SECTOR__C = 'Travel Agent';
		acct3.LOCATION_CLASS__C = 'P';
		acct3.COMPANY_TYPE__C = 'A';
		acct3.IN_A_AIRPORT__C = false;
		acct3.REASON_FOR_CREATION__C = 'Created by customer';
		acct3.IATACode__c = '1234567';
		acct3.ParentId = acct.Id;

		Account acct4 = new Account();

		acct4.NAME = 'Lions Travel 4';
		acct4.TYPE = 'Non-IATA Passenger Agent';
		acct4.RECORDTYPEID = accountRT;
		acct4.BILLINGCOUNTRY = 'Greece';
		acct4.INDUSTRY = 'Travel Agent';
		acct4.CURRENCYISOCODE = 'USD';
		acct4.TRADENAME__C = 'Lions Travel 4';
		acct4.IATA_MEMBER__C = false;
		acct4.LOCATION_TYPE__C = 'BR';
		acct4.LEGAL_NAME__C = 'Lions Travel 4';
		acct4.SHORT_NAME__C = 'Lions Travel 4';
		acct4.IATA_ISO_COUNTRY__C = ctry.Id;
		acct4.CATEGORY__C = 'IATA Passenger Sales Agent';
		acct4.SECTOR__C = 'Travel Agent';
		acct4.LOCATION_CLASS__C = 'P';
		acct4.COMPANY_TYPE__C = 'A';
		acct4.IN_A_AIRPORT__C = false;
		acct4.REASON_FOR_CREATION__C = 'Created by customer';
		acct4.IATACode__c = '7654321';
		acct4.ParentId = acct.Id;

		insert new List<Account>{acct3,acct4};

		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Child_Account__c = acct3.Id, Parent_Account__c = acct.Id, Hierarchy__c = h.Id);

		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Child_Account__c = acct4.Id, Parent_Account__c = acct.Id, Hierarchy__c = h.Id);

		AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Child_Account__c = acct2.Id, Parent_Account__c = acct.Id, Hierarchy__c = h.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel2,rel3,rel};

		Test.startTest();

		System.debug('Got first account with id:' + acct.Id + ' and with name:' + acct.Name + ' and parent Id:' + acct.ParentId);

		Case caseCom = [SELECT Id from Case where AccountId = : acct.Id];

		AMS_Pax_Accreditation_Form__c accr = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom.Id];

		accr.Notify_Change_Ownership__c  = true;

		accr.Scope_of_Change__c = 'HO - All Branches';

		accr.Agency_Codes_Concerned__c = '7654321,1234567';

		update accr;

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(acct.Id,accr.Id,'MAJOR.CHANGES',caseCom.Id);

		List<AMS_OSCAR__c> oscarLst = [SELECT Id, Type_of_change__c from AMS_OSCAR__c];

		System.assertEquals(oscarLst.size(),1);

		AMS_OSCAR__c oscar = oscarLst.get(0);

		System.assertEquals(oscar.Type_of_change__c,'Ownership to non-IATA Agent');

		Test.stopTest();
	}

	@isTest static void createAccreditationChangeOfOwnerShipSelectedBranches() {

		List<Account> acctLst = [SELECT Id, Name, ParentId from Account];

		Account acct = acctLst.get(0);

		Account acct2 = acctLst.get(1);

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy test');

		insert h;

		//insert rel;

		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		
		IATA_ISO_Country__c ctry = [SELECT ID FROM IATA_ISO_Country__c LIMIT 1];

		Account acct3 = new Account();

		acct3.NAME = 'Lions Travel 3';
		acct3.TYPE = 'Non-IATA Passenger Agent';
		acct3.RECORDTYPEID = accountRT;
		acct3.BILLINGCOUNTRY = 'Greece';
		acct3.INDUSTRY = 'Travel Agent';
		acct3.CURRENCYISOCODE = 'USD';
		acct3.TRADENAME__C = 'Lions Travel 3';
		acct3.IATA_MEMBER__C = false;
		acct3.LOCATION_TYPE__C = 'BR';
		acct3.LEGAL_NAME__C = 'Lions Travel 3';
		acct3.SHORT_NAME__C = 'Lions Travel 3';
		acct3.IATA_ISO_COUNTRY__C = ctry.Id;
		acct3.CATEGORY__C = 'IATA Passenger Sales Agent';
		acct3.SECTOR__C = 'Travel Agent';
		acct3.LOCATION_CLASS__C = 'P';
		acct3.COMPANY_TYPE__C = 'A';
		acct3.IN_A_AIRPORT__C = false;
		acct3.REASON_FOR_CREATION__C = 'Created by customer';
		acct3.IATACode__c = '1234567';
		acct3.ParentId = acct.Id;

		Account acct4 = new Account();

		acct4.NAME = 'Lions Travel 4';
		acct4.TYPE = 'Non-IATA Passenger Agent';
		acct4.RECORDTYPEID = accountRT;
		acct4.BILLINGCOUNTRY = 'Greece';
		acct4.INDUSTRY = 'Travel Agent';
		acct4.CURRENCYISOCODE = 'USD';
		acct4.TRADENAME__C = 'Lions Travel 4';
		acct4.IATA_MEMBER__C = false;
		acct4.LOCATION_TYPE__C = 'BR';
		acct4.LEGAL_NAME__C = 'Lions Travel 4';
		acct4.SHORT_NAME__C = 'Lions Travel 4';
		acct4.IATA_ISO_COUNTRY__C = ctry.Id;
		acct4.CATEGORY__C = 'IATA Passenger Sales Agent';
		acct4.SECTOR__C = 'Travel Agent';
		acct4.LOCATION_CLASS__C = 'P';
		acct4.COMPANY_TYPE__C = 'A';
		acct4.IN_A_AIRPORT__C = false;
		acct4.REASON_FOR_CREATION__C = 'Created by customer';
		acct4.IATACode__c = '7654321';
		acct4.ParentId = acct.Id;

		insert new List<Account>{acct3,acct4};

		AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Child_Account__c = acct2.Id, Parent_Account__c = acct.Id, Hierarchy__c = h.Id);

		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Child_Account__c = acct3.Id, Parent_Account__c = acct.Id, Hierarchy__c = h.Id);

		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Child_Account__c = acct4.Id, Parent_Account__c = acct.Id, Hierarchy__c = h.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel2,rel3,rel};

		Test.startTest();

		System.debug('Got first account with id:' + acct.Id + ' and with name:' + acct.Name + ' and parent Id:' + acct.ParentId);

		Case caseCom = [SELECT Id from Case where AccountId = : acct.Id];

		AMS_Pax_Accreditation_Form__c accr = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom.Id];

		accr.Notify_Change_Ownership__c  = true;

		accr.Scope_of_Change__c = 'HO - Selected Branches';

		accr.Agency_Codes_Concerned__c = '7654321,1234567';

		update accr;

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(acct.Id,accr.Id,'MAJOR.CHANGES',caseCom.Id);

		List<AMS_OSCAR__c> oscarLst = [SELECT Id, Type_of_change__c from AMS_OSCAR__c];

		System.assertEquals(oscarLst.size(),1);

		AMS_OSCAR__c oscar = oscarLst.get(0);

		System.assertEquals(oscar.Type_of_change__c,'Ownership to non-IATA Agent');
//DTULLO: Added Record Type
		List<AMS_Process_Detail__c> details = [SELECT Id from AMS_Process_Detail__c where OSCAR__c = :oscarId and RecordType.Developername = 'Agency_Involved'];

		System.assertEquals(details.size(),2);

		Test.stopTest();
	}





	@isTest static void createAccreditationOwners() {

		List<Account> acctLst = [SELECT Id, Name, ParentId from Account];

		Account acct = acctLst.get(0);

		Account acct2 = acctLst.get(1);

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy test');

		insert h;

		//insert rel;

		
		
		IATA_ISO_Country__c ctry = [SELECT ID FROM IATA_ISO_Country__c LIMIT 1];

		AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Child_Account__c = acct2.Id, Parent_Account__c = acct.Id, Hierarchy__c = h.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel};

		Test.startTest();

		System.debug('Got first account with id:' + acct.Id + ' and with name:' + acct.Name + ' and parent Id:' + acct.ParentId);

		Case caseCom = [SELECT Id from Case where AccountId = : acct.Id];

		AMS_Pax_Accreditation_Form__c accr = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom.Id];

		accr.Notify_Change_Ownership__c  = true;

		accr.Scope_of_Change__c = 'HO - Selected Branches';

		accr.Agency_Codes_Concerned__c = '7654321,1234567';

		update accr;

		Id previousOwner = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');
		Id previousCompanyOwner = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');

		AMS_Accreditation_Contact__c acontact1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accr.Id, Company__c = acct.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC', Mobile__c='+1112345678', Phone__c='3424322343', Email__c='uni123que@email2.com', RecordTypeId=previousOwner);

		AMS_Accreditation_Contact__c acontact2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accr.Id, Company__c = acct.Id, First_name__c='NameToUse2', Last_name__c='Last2', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique2@email2.com', RecordTypeId=previousCompanyOwner);

		insert new List<AMS_Accreditation_Contact__c>{acontact1,acontact2};

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(acct.Id,accr.Id,'MAJOR.CHANGES',caseCom.Id);

		List<AMS_Accreditation_Contact__c> contactsCreated = [SELECT Id from AMS_Accreditation_Contact__c where RecordType.DeveloperName IN ('Company','Current_Company_Owner','Current_Owner','Person','Trained_Staff') and AMS_Pax_Accreditation_Form__c = :accr.Id];

		System.assertEquals(contactsCreated.size(),2);

		Test.stopTest();
	}

	@isTest static void createAccreditationForSA() {

		IATA_ISO_Country__c ctry = [SELECT id from IATA_ISO_Country__c limit 1];
            
        Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');

		Account acct = new Account();

		acct.NAME = 'Lions Travel 8 HO';
		acct.TYPE = 'Non-IATA Passenger Agent';
		acct.RECORDTYPEID = accountRT;
		acct.BILLINGCOUNTRY = 'Italy';
		acct.INDUSTRY = 'Travel Agent';
		acct.CURRENCYISOCODE = 'USD';
		acct.TRADENAME__C = 'Lions Travel 8 HO';
		acct.IATA_MEMBER__C = false;
		acct.LOCATION_TYPE__C = 'HO';
		acct.LEGAL_NAME__C = 'Lions Travel 8 HO legal name';
		acct.SHORT_NAME__C = 'Lions Travel 8 HO short name';
		acct.IATA_ISO_COUNTRY__C = ctry.Id;
		acct.CATEGORY__C = 'IATA Passenger Sales Agent';
		acct.SECTOR__C = 'Travel Agent';
		acct.LOCATION_CLASS__C = 'P';
		acct.COMPANY_TYPE__C = 'A';
		acct.IN_A_AIRPORT__C = false;
		acct.REASON_FOR_CREATION__C = 'Created by customer';

		
		insert acct;

		Contact co1 = new Contact(AccountId = acct.Id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'testd1@test.com', Financial_Assessment_Contact__c = false);
		
		Contact co2 = new Contact(AccountId = acct.Id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test2d1@test.com', Financial_Assessment_Contact__c = false);
		
		List<Contact> contacts = new List<Contact>{co1,co2};

		insert contacts;

		AMS_Account_Role__c role = new AMS_Account_Role__c();
		role.Owner_Name__c = 'Contact 1';
		role.Contact__c = co1.Id;
		role.Account__c = acct.Id;
		role.Percentage__c = 50;

		AMS_Account_Role__c role2 = new AMS_Account_Role__c();
		role2.Owner_Name__c = 'Contact 2';
		role2.Contact__c = co2.Id;
		role2.Account__c = acct.Id;
		role2.Percentage__c = 50;

		List<AMS_Account_Role__c> roles = new List<AMS_Account_Role__c>{role,role2};

		insert roles;

		System.debug('Contacts created');

		ID rtSAAMCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SAAM').getRecordTypeId();

		Case saamCase = new Case(RecordTypeId = rtSAAMCase, AccountId = acct.Id, Account_Concerned__c = acct.Id, ContactId = co1.Id);

		insert saamCase;

		Test.startTest();

		AMS_RecordCreatorWebservice.createAccreditationForSA(saamCase.Id);

		List<Account> accounts = [SELECT Id from Account where ParentId = :acct.Id];

		System.assertEquals(1,accounts.size());

		List<AMS_Pax_Accreditation_Form__c> accreditationForms = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :saamCase.Id];

		System.assertEquals(1,accreditationForms.size());

		List<AMS_Accreditation_Contact__c> accreditationContacts = [SELECT Id from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c = :accreditationForms.get(0).Id];

		System.assertEquals(2,accreditationContacts.size());

		List<AMS_Agencies_relationhip__c> relationShips = [SELECT Id from AMS_Agencies_relationhip__c where Parent_Account__c = :acct.Id and Child_Account__c = :accounts.get(0).Id];

		System.assertEquals(1,relationShips.size());

		Test.stopTest();
	}

	@isTest static void createOptinOptOut() {

		List<Account> acctLst = [SELECT Id, Name, ParentId from Account];

		Account acct = acctLst.get(0);

		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		acct.RecordTypeId = accountAgencyRT;
		acct.IATACODE__c = '1234567';
		update acct;

		Test.startTest();

		Case caseCom = [SELECT Id from Case where AccountId = : acct.Id];

		AMS_Pax_Accreditation_Form__c accr = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom.Id];

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(acct.Id,accr.Id,'ANG.FS.OPTINOUT',caseCom.Id);
		
		Test.stopTest();
	}
}