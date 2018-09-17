@isTest
private class ANG_ActivatePortalUsersTest {
	
    @testSetup static void setup()
    {
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Westeros', ISO_Code__c = 'TS', ANG_Enable_NewGen__c = true);       
        insert isoc;

        IATA_ISO_State__c isos = new IATA_ISO_State__c(Name= 'Winterfell', ISO_Code__c = 'TS', IATA_Iso_Country__c = isoc.Id);
   		insert isos;

        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
   		Account acc1 = new Account(RecordTypeId = agencyRT, Name = 'Stardust Travels', Sector__c = 'Travel Agent',  Category__c = 'IATA Passenger Sales Agent', IATA_ISO_Country__c = isoc.id, Iso_State__c = isos.id, Location_Type__c = 'HE', Location_Class__c = 'P', Reason_for_creation__c = 'Account is missing');
        insert acc1;

        Contact c1 = new Contact(AccountId = acc1.id, FirstName='Name', Lastname='LastName', Email = 'unique@email.com', Community__c = 'ISS Customer Portal', Phone = '3424322343');
        insert c1;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = acc1.Id);
        oscar.Account__c = acc1.Id;
        oscar.Process__c = 'ANG.NEW.HE.LITE.1.0';
        oscar.RecordTypeId = AMS_Utils.getId('AMS_OSCAR__c', 'ANG_New_HE');
        oscar.Status__c = 'Open';
        insert oscar;
        
        Case testCase = new Case();
        testCase.AccountId = acc1.Id;
        testCase.Account_Concerned__c = acc1.Id;
        testCase.BSPCountry__c = 'Westeros';
        testCase.CaseArea__c = 'Accreditation Process';
        testCase.ContactId = c1.Id;
        testCase.Origin = 'Email';
        testCase.OSCAR__c = oscar.Id;
        testCase.Reason1__c = 'New HE lite';
        testCase.RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication');
        testCase.Region__c = 'Europe';
        testCase.Status = 'Open';
        insert testCase;
        
        AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c();
        onlineAccreditation.SAAM_Case__c = testCase.Id;
        onlineAccreditation.Account_Name__c = acc1.Name;
        insert onlineAccreditation;

        oscar.Oscar_Communication_Case_Id__c = testCase.Id;
        oscar.AMS_Online_Accreditation__c = onlineAccreditation.Id;
        update oscar;
        
        AMS_Accreditation_Contact__c ac = new AMS_Accreditation_Contact__c();
        ac.AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id;
        ac.Company__c = acc1.id;
        ac.First_name__c = 'NameToUse';
        ac.Last_name__c = 'Last';
        ac.Job_title__c = 'ABC';
        ac.Mobile__c = '+4112345678';
        ac.Phone__c = '3424322343';
        ac.Email__c = 'unique@email.com';
        ac.RecordTypeId = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person');
        ac.Portal_administrator__c = true;
        ac.Contact__c = c1.id;
        insert ac;

        List<ISSP_CS__c> cs = new List<ISSP_CS__c>();
        cs.add(new ISSP_CS__c(Name = 'ISS_Portal_Agency_Delegated_Admin',value__c = '00ew0000001QRzC'));
        cs.add(new ISSP_CS__c(Name = 'Host',value__c = 'portal.iata.org'));
        insert cs;

    }
    
	@isTest static void createPortalUserForNonExistingContact()
	{

		AMS_OSCAR__c oscar = [SELECT Id, RPM_Approval__c FROM AMS_OSCAR__c limit 1];

		Test.startTest();

		AMS_OSCAR_Webservice.copyDataToAccount(oscar.Id);

		Test.stopTest();

		Contact c = [SELECT Id, Email FROM Contact WHERE Email = 'unique@email.com'];

		User u = [SELECT Id, Email, ContactId FROM User WHERE Email = 'unique@email.com'];
		system.assertEquals(u.ContactId, c.Id);

	}

}