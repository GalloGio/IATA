@isTest
private class ANG_OscarConversionBatchTest {
	
	@testSetup static void setup(){

		IATA_ISO_Country__c ctry1 = new IATA_ISO_Country__c (Name='FR',ISO_Code__c='FR', ANG_Enable_NewGen__c = true);

		insert new List<IATA_ISO_Country__c>{ctry1};

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'FR20', IATA_ISO_Country__c = ctry1.Id);
        insert stt;
		
		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		
		Account acctHO = new Account(IATA_ISO_Country__c = ctry1.id, RecordTypeId = accountRT,	 Category__c = 'Non-IATA Travel Agent',
									Name='Test HO',Short_Name__c='Test HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Location_type__c = 'HO', Reason_for_creation__c = 'none',
									Is_your_firm_handling_Dangerous_Goods__c='Yes', IATAcode__c = '2948221');

		insert acctHO;


	}
	
	@isTest static void testRunBatchNewHO() {

		Account acctHO = [Select Id , IATAcode__c, IATA_ISO_Country__c, RecordTypeId, Category__c, Name, Short_Name__c, Sector__c, Location_Class__c, Location_type__c, Reason_for_creation__c , Is_your_firm_handling_Dangerous_Goods__c from Account];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = acctHO.id, RecordTypeId = AMS_Utils.RECTYPE_NEW, Process__c =AMS_Utils.new_HO);
		insert oscar;
		
		Contact co1 = new Contact(AccountId = acctHO.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
		insert co1;
		
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = acctHO.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Subject = 'New HO - Test HO';
        oscarCase.Reason1__c = 'New HO';
        insert oscarCase;

         // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = acctHO.Name,
                IATAcode__c = acctHO.IATAcode__c,
                Branch_Office_Country__c = acctHO.IATA_ISO_Country__c,
                Location_Class__c = acctHO.Location_Class__c,
                Location_Type__c = acctHO.Location_Type__c,
                SAAM_Case__c = oscarCase.Id,
                Is_your_firm_handling_Dangerous_Goods__c = 'Yes');

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;

        update oscar;

		Test.startTest();

		ANG_OscarConversionBatch conversionBatch = new ANG_OscarConversionBatch('FR','');

		Database.executeBatch(conversionBatch,1);

		Test.stopTest();

		Case comCase = [SELECT Id, Subject, CaseArea__c, Reason1__c from Case LIMIT 1];
		oscar = [SELECT Id, RecordTypeId, Process__c from AMS_OSCAR__c LIMIT 1];
		stagingArea = [SELECT Id, Location_Type__c from AMS_Pax_Accreditation_Form__c LIMIT 1];

		System.assertEquals('New Head Entity - GoStandard - FR', comCase.Subject);
		System.assertEquals('Accreditation Process', comCase.CaseArea__c);
		System.assertEquals('New HE standard', comCase.Reason1__c);
		
		String RECTYPE_NEWHE= Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NG New HE').getRecordTypeId();

		System.assertEquals(RECTYPE_NEWHE, oscar.RecordTypeId);
		System.assertEquals('ANG.NEW.HE.STANDARD.1.0', oscar.Process__c);

		System.assertEquals('HE', stagingArea.Location_Type__c);

		
	}

	@isTest static void testRunBatchChanges() {

		Account acctHO = [Select Id , IATA_ISO_Country__c, IATAcode__c, RecordTypeId, Category__c, Name, Short_Name__c, Sector__c, Location_Class__c, Location_type__c, Reason_for_creation__c , Is_your_firm_handling_Dangerous_Goods__c from Account];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = acctHO.id, RecordTypeId = AMS_Utils.RECTYPE_CHANGE, Process__c =AMS_Utils.AGENCYCHANGES);
		insert oscar;
		
		Contact co1 = new Contact(AccountId = acctHO.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
		insert co1;
		
		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = acctHO.Id;
        oscarCase.ContactId = co1.Id;
        oscarCase.Subject = 'New HO - Test HO';
        oscarCase.Reason1__c = 'New HO';
        insert oscarCase;

         // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = acctHO.Name,
                IATAcode__c = acctHO.IATAcode__c,
                Branch_Office_Country__c = acctHO.IATA_ISO_Country__c,
                Location_Class__c = acctHO.Location_Class__c,
                Location_Type__c = acctHO.Location_Type__c,
                SAAM_Case__c = oscarCase.Id,
                Is_your_firm_handling_Dangerous_Goods__c = 'Yes');

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;

        update oscar;

		Test.startTest();

		ANG_OscarConversionBatch conversionBatch = new ANG_OscarConversionBatch('FR','');

		Database.executeBatch(conversionBatch,1);

		Test.stopTest();
		
	}
	
}