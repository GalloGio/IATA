@isTest
private class CaseProcessTypeHelperTest {

    @testSetup static void setup() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name= 'Portugal',
            ISO_Code__c= 'PT',
            ISO_Code_Numeric__c= 11,
            Region__c= 'Europe'
        );
        insert country;

        Account acc = new Account(
            Name= 'Test Ag',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
            IATA_ISO_Country__c= country.Id,
            Location_Type__c= 'HO',
            Location_Class__c= 'P',
            Sector__c= 'Travel Agent',
            Category__c= 'IATA Passenger Sales Agent',
            IATACode__c= '145362'
        );
        insert acc;

        Contact con = new Contact(
            FirstName= 'Test',
            Lastname= 'Contact',
            Email= 'test.contact@yopmail.com',
            AccountId= acc.Id
        );
        insert con;

        Case cse = new Case(
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case','OSCAR_Communication'),
            Subject= 'New HO Test',
            Region__c= 'Europe',
            Closed_by_Role__c= 'Test Class User',
            AccountId= acc.Id,
            ContactId= con.Id,
            CaseArea__c= 'Accreditation Process'
        );
        insert cse;

        AMS_Pax_Accreditation_Form__c stgArea = new AMS_Pax_Accreditation_Form__c(
            SAAM_Case__c= cse.Id
        );
        insert stgArea;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c','NEW'),
            AMS_Online_Accreditation__c= stgArea.Id,
            Account__c= acc.Id
        );
        insert oscar;

		AMS_OSCAR_reset_dossier_reception__c resetDossierReceptionDateStatus = new AMS_OSCAR_reset_dossier_reception__c();
		resetDossierReceptionDateStatus.Name = 'Closed_Rejected';
		resetDossierReceptionDateStatus.Status__c = 'Closed_Rejected';
		insert resetDossierReceptionDateStatus;
    }

    @isTest static void testKPICalculation() {
        Test.startTest();
        AMS_OSCAR__c oscar = [SELECT Id, Accreditation_Process_Type__c, AMS_Online_Accreditation__r.SAAM_Case__c  FROM AMS_OSCAR__c LIMIT 1];
        oscar.Status__c = 'Closed_Rejected';
        update oscar;
        
        Case cse = new Case(
            Id= oscar.AMS_Online_Accreditation__r.SAAM_Case__c,
            Reason1__c= 'New HO',
            Status= 'Closed_Rejected'
        );
        update cse;

		cse = [SELECT Id, KPI_Calculation__c, Oscar__c FROM Case LIMIT 1];
		oscar = [SELECT Id, Accreditation_Process_Type__c, Status__c FROM AMS_OSCAR__c LIMIT 1];
        Case_Process_Type__mdt process = [SELECT Type__c FROM Case_Process_Type__mdt process WHERE Reason__c = 'New HO'];

        System.assertNotEquals(null, cse.KPI_Calculation__c);

		oscar.Status__c = 'Open';
		update oscar;

		cse.Status = 'Open';
		cse.Oscar__c = oscar.Id;
		update cse;
        Test.stopTest();
    }

}