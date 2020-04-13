@isTest
public class PASSSCIMUser_Test {

	@isTest
	static void PASSSCIMUser_fillUpSCIMMessage_Test() {
		PASSSCIMUser pScimUser = new PASSSCIMUser('name', 'familyname', 'givenname', 'externalid', 'email@email.com');

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', Region__c = 'Europe')  ;
		insert ctry ;

		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;

		String SECTORPAX = 'Travel Agent';
		String CATEGORYPAX = 'IATA Passenger Sales Agent';
		String LOCCLASSPAX = 'P';
		Account acc = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id,
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO',
						 Status__c = AMS_Utils.ACC_S9_APPROVED);
		insert acc;

		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = acc.Id;
		insert contact;

		User testUser = New User(
				Alias = 'standt', Email='email@email.com',
				ContactId = contact.Id,
				EmailEncodingKey='UTF-8', LastName='Testinglaz', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = '00ew0000001QoBp',
				TimeZoneSidKey='America/Los_Angeles', UserName='testlazusername@test.com',
				License_Cost_Center__c = 'ISF005CH01',
				IsActive = true
		);
		insert testUser;

		ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');
		AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = acc.Id, Process__c = 'MAJOR.CHANGES');
		insert theOscar;

		ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = 'Change of shareholding - ' + acc.Name, OSCAR__c = theOscar.Id,
											AccountId = acc.Id );
		insert theCommunicationCase;

		AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = acc.Name, IATAcode__c = acc.IATAcode__c, Branch_Office_Country__c = acc.IATA_ISO_Country__c,
														   SAAM_Case__c = theCommunicationCase.Id, Location_Class__c = acc.Location_Class__c, Location_Type__c = acc.Location_Type__c);
		insert theStagingAcc;

		Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT ID, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c from AMS_OSCAR__C where Account__c =: acc.Id]);

		AMS_Person__c powner = new AMS_Person__c(First_Name__c='Person', Lastname__c='Owner', Email__c='person@owner.it');
		insert powner;

		// Create the Staging area for the Contact
		ID rtPerson = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

		List<AMS_Accreditation_Contact__c> theStagingConts= new List<AMS_Accreditation_Contact__c>();
		theStagingConts.add(new AMS_Accreditation_Contact__c(
			First_name__c = contact.FirstName, Last_Name__c = contact.LastName, Email__c = contact.Email, Contact__c = contact.Id, Agency_owner__c = true,
			AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Financial_interest__c = 50, RecordTypeId=rtPerson, PASS_Admin__c = true));
		insert theStagingConts;
		System.debug('MMSA:: theStagingConts: ' + theStagingConts);

		pScimUser.fillUpSCIMMessage('email@email.com');
	}

	@isTest
	static void PASSSCIMUser_fillUpSCIMMessage_Test2() {
		PASSSCIMUser pScimUser = new PASSSCIMUser('name', 'familyname', 'givenname', 'externalid', 'email@email.com');

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', Region__c = 'Europe')  ;
		insert ctry ;

		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;

		String SECTORPAX = 'Travel Agent';
		String CATEGORYPAX = 'IATA Passenger Sales Agent';
		String LOCCLASSPAX = 'P';
		Account acc = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id,
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO',
						 Status__c = AMS_Utils.ACC_S9_APPROVED);
		insert acc;

		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = acc.Id;
		insert contact;

		User testUser = New User(
				Alias = 'standt', Email='email@email.com',
				ContactId = contact.Id,
				EmailEncodingKey='UTF-8', LastName='Testinglaz', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = '00ew0000001QoBp',
				TimeZoneSidKey='America/Los_Angeles', UserName='testlazusername@test.com',
				License_Cost_Center__c = 'ISF005CH01',
				IsActive = true
		);
		insert testUser;

		ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');
		AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = acc.Id, Process__c = 'MAJOR.CHANGES');
		insert theOscar;

		ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = 'Change of shareholding - ' + acc.Name, OSCAR__c = theOscar.Id,
											AccountId = acc.Id );
		insert theCommunicationCase;

		AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = acc.Name, IATAcode__c = acc.IATAcode__c, Branch_Office_Country__c = acc.IATA_ISO_Country__c,
														   SAAM_Case__c = theCommunicationCase.Id, Location_Class__c = acc.Location_Class__c, Location_Type__c = acc.Location_Type__c);
		insert theStagingAcc;

		Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT ID, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c from AMS_OSCAR__C where Account__c =: acc.Id]);

		AMS_Person__c powner = new AMS_Person__c(First_Name__c='Person', Lastname__c='Owner', Email__c='person@owner.it');
		insert powner;

		// Create the Staging area for the Contact
		ID rtPerson = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

		List<AMS_Accreditation_Contact__c> theStagingConts= new List<AMS_Accreditation_Contact__c>();
		theStagingConts.add(new AMS_Accreditation_Contact__c(
			First_name__c = contact.FirstName, Last_Name__c = contact.LastName, Email__c = contact.Email, Contact__c = contact.Id, Agency_owner__c = true,
			AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Financial_interest__c = 50, RecordTypeId=rtPerson, PASS_Admin__c = false));
		insert theStagingConts;
		System.debug('MMSA:: theStagingConts: ' + theStagingConts);

		pScimUser.fillUpSCIMMessage('email@email.com');
	}
}