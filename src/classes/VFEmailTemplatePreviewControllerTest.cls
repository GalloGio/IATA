@isTest
private class VFEmailTemplatePreviewControllerTest {

    @isTest
	static void testController() {
        //create data
        Id countryId = createIsoCountry();

        ID IFAPRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'IFAP');
        
        EmailTemplate__c newTemplate = new EmailTemplate__c (RecordTypeId = IFAPRecordTypeId, Name = 'testET', Template_Type__c = 'FA - Financial Assessment',
                                                    Agent_Type__c = 'IATA Cargo Agent', Template_Language__c = 'English', IATA_ISO_Country__c = countryId,
                                                    Review_Types__c = 'New', Subject__c = 'testSubject', Greeting_Line__c = 'Hello', Body_Section_1__c = 'test Body',
                                                    Signature_Details__c = 'Sample details', Is_reminder__c = false, Default_Template__c = false, Deadline_Date_Required__c = true);
        insert newTemplate;

        Account acc = new Account(Name = 'Test account', BillingCity = 'Montreal', BillingCountry = 'Canada', BillingStreet = 'some street', IATACode__c = '1234567');
        insert acc;

        Contact con = new Contact(FirstName = 'Dummy', LastName = 'Contact', Type_of_Contact__c = 'IFAP Contact', AccountId = acc.Id, Email = 'some@email.org');
        insert con;

        VFEmailTemplatePreviewController controller = new VFEmailTemplatePreviewController();
        Contact c = [Select c.Id from Contact c limit 1];
        EmailTemplate__c template = [Select et.Id from EmailTemplate__c et limit 1];

        controller.contactId = c.Id;
        controller.emailTemplateId = template.Id;
        controller.subject = 'Some subject';
        controller.financialReviewType = 'Annual';
        controller.deadlineDate = '2013-10-01';
        controller.financialYear = '2013';
    }

    private static Id createIsoCountry(){

        List<IATA_ISO_Country__c> isoCountriesCA = new List<IATA_ISO_Country__c>();
        isoCountriesCA = [SELECT Name, ISO_Code__c, Iso_Code_Numeric__c, CurrencyIsoCode, VAT_Validation_Required__c, AIMS_Area_ID__c
                            FROM IATA_ISO_Country__c
                            WHERE ISO_Code__c = 'CA' limit 1];

        if(!isoCountriesCA.isEmpty()){
            isoCountriesCA[0].name = 'Canada';
            isoCountriesCA[0].ISO_Code__c = 'CA';
            isoCountriesCA[0].ISO_Code_Numeric__c = 123; //not real code
            isoCountriesCA[0].CurrencyIsoCode = 'CAD';
            isoCountriesCA[0].AIMS_Area_ID__c = '1'; //not real code
            update isoCountriesCA[0];
            return isoCountriesCA[0].Id;
        }else{
            IATA_ISO_Country__c isoCountryCA = new  IATA_ISO_Country__c();
            isoCountryCA.name = 'Canada';
            isoCountryCA.ISO_Code__c = 'CA';
            isoCountryCA.ISO_Code_Numeric__c = 123; //not real code
            isoCountryCA.CurrencyIsoCode = 'CAD';
            isoCountryCA.AIMS_Area_ID__c = '1'; //not real code
            insert isoCountryCA;
            return isoCountryCA.Id;
        }
    }
}