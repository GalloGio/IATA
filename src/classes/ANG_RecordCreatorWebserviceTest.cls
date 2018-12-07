@isTest
private class ANG_RecordCreatorWebserviceTest {
	
    private static void createNewGenData(){
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='PT', Region__c='Europe', ISS_Office_Location__c='Portugal', ANG_Enable_NewGen__c=true);
        insert ctry;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account acct = new Account();

		acct.NAME = 'Lions Travel 8';
		acct.TYPE = 'Non-IATA Passenger Agent';
		acct.RECORDTYPEID = accountRT;
		acct.BILLINGCOUNTRY = 'Portugal';
		acct.INDUSTRY = 'Travel Agent';
		acct.CURRENCYISOCODE = 'USD';
		acct.TRADENAME__C = 'Lions Travel 8';
		acct.IATA_MEMBER__C = false;
		acct.LOCATION_TYPE__C = 'HE';
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
		acct2.LOCATION_TYPE__C = 'AE';
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

		System.debug('Accounts created');

		Contact co1 = new Contact(AccountId = acct.Id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		
		Contact co2 = new Contact(AccountId = acct2.Id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		
		List<Contact> contacts = new List<Contact>{co1,co2};
		insert contacts;

		System.debug('Contacts created');

		ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

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
	
	@isTest static void createAccreditation() {

		createNewGenData();

		Test.startTest();
		
		List<Account> acctLst = [SELECT Id, Name, ParentId from Account];

		Account acct = acctLst.get(0);

		System.debug('Got first account with id:' + acct.Id + ' and with name:' + acct.Name + ' and parent Id:' + acct.ParentId);

		Case caseCom = [SELECT Id from Case where AccountId = : acct.Id];

		AMS_Pax_Accreditation_Form__c accr = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom.Id];

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(acct.Id,accr.Id,'ANG.NEW.HE.STANDARD.1.0',caseCom.Id);

		System.debug('First Oscar created is ' +  oscarId);

		List<AMS_OSCAR__c> oscarLst = [SELECT Id from AMS_OSCAR__c];

		System.assertEquals(oscarLst.size(),1);

		Account acct2 = acctLst.get(1);

		System.debug('Got second account with id:' + acct2.Id + ' and with name:' + acct2.Name + ' and parent Id:' + acct2.ParentId);

		Case caseCom2 = [SELECT Id, Account_Concerned__c from Case where AccountId = :acct2.Id];

		AMS_Pax_Accreditation_Form__c accr2 = [SELECT Id from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseCom2.Id];

		String oscarId2 = AMS_RecordCreatorWebservice.createAccreditation(acct2.Id,accr2.Id,'ANG.NEW.AE.1.0',caseCom2.Id);

		System.debug('Second Oscar created is ' +  oscarId);

		List<AMS_OSCAR__c> oscarLst2 = [SELECT Id from AMS_OSCAR__c];

		System.assertEquals(oscarLst2.size(),2);

		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id from AMS_Agencies_Hierarchy__c ];

		System.assertEquals(hierarchies.size(),1);

		List<AMS_Agencies_relationhip__c> relations = [SELECT Id from AMS_Agencies_relationhip__c ];

		System.assertEquals(hierarchies.size(),1);


		


		Test.stopTest();

	}


}