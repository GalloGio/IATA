@isTest
public class IDCardLoginControllerTest {

    private static IDCardTestData testData;

    private static IDCardLoginController idCardLoginController;
    private static PageReference controllerPage;
    private static PageReference nextPage;
    private static List<Contact> relatedContact;

    public static void TestIDCardLoginController() {

        testData = new IDCardTestData();

        List<ID_Card_Application__c> idCardAppToInsert = new List<ID_Card_Application__c>();

        Id idCardAppRT =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        testData.IDCards_IDCardApplications[3].RecordTypeId = idCardAppRT;
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[1]);
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[3]);

        insert idCardAppToInsert;

        Id contactId1 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[1]);
        Id contactId3 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);

        relatedContact = [SELECT Id, LastName, FirstName, VER_Number__c, VER_Number_2__c, IATA_Code__c, Account.RecordType.Name, Account.Status__c, Date_of_Birth__c, Account.BillingCountry FROM Contact WHERE Id IN (:contactId1, :contactId3)];

        System.debug('## relatedContact[0]: ' + relatedContact[0]);
        System.debug('## relatedContact[1]: ' + relatedContact[1]);
        Set<Id> relatedContactAccountId = new Set<Id> {relatedContact[0].AccountId, relatedContact[1].AccountId};

        List<Account> accs = [SELECT Id, Status__c, IDCard_Key_Account__c, IATACode__c FROM Account WHERE id in :relatedContactAccountId];
        for (Account acc : accs) {
            acc.IDCard_Key_Account__c = true;
        }
        update accs;

        List<ID_Card__c> idCardToInsert = new List<ID_Card__c>();

        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[1], relatedContact[0]));
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], relatedContact[1]));
        insert idCardToInsert;
        System.debug('-------------------------- Contacts = ' + relatedContact[0].VER_Number__c + ' ' + relatedContact[0].Account.RecordType.Name + ' ' +  relatedContact[0].Account.Status__c +
                     '\n-------------------------- Contacts = ' + relatedContact[1].VER_Number__c + ' ' + relatedContact[1].Account.RecordType.Name + ' ' +  relatedContact[1].Account.Status__c);
        system.debug('Billing Country: ' + relatedContact[0].Account.BillingCountry + 'IATA_Code__c: ' + relatedContact[0].IATA_Code__c + 'FirstName: ' + relatedContact[0].FirstName);
        system.debug('Billing Country: ' + relatedContact[1].Account.BillingCountry + 'IATA_Code__c: ' + relatedContact[1].IATA_Code__c + 'FirstName: ' + relatedContact[1].FirstName);

        //insert Case
        Id caseRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
        Case pendingCase = new Case();
        pendingCase.ContactId = relatedContact[1].Id;
        pendingCase.Status = 'new';
        pendingCase.RecordTypeId = caseRTId;
        pendingCase.Subject = 'test';
        pendingCase.Origin = 'Email';
        pendingCase.AccountId = relatedContact[1].AccountId;
        insert pendingCase;

        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCardLogin;
        Test.setCurrentPage(controllerPage_NoCookies);
        IDCardLoginController idCardLogingController_NoCookies = new IDCardLoginController();

        // TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang', 'en_US', null, -1, false);
        ISSP_CS__c cs = new ISSP_CS__c(name = 'ipinfo_token', value__c = '871e08ecd39325');
        insert cs;
        controllerPage = Page.IDCardLogin;
        controllerPage.setCookies(new Cookie[] {languageCookies});
        Test.setCurrentPage (controllerPage);
        idCardLoginController = new IDCardLoginController();
        idCardLoginController.getLangItems();
        idCardLoginController.findLocation();
		idCardLoginController.fakemethod();
    }

    @isTest
    public static void TestVerify() {
        TestIDCardLoginController();

        Test.startTest();

        // IATACode is Null
        IdCardLoginController.IATACodeLocation = '';
        nextPage = idCardLoginController.verify();
        System.assert(checkMessages(ApexPages.getMessages(), Label.IDCard_IATACodeRequired), 'Label.IDCard_IATACodeRequired message should be added');

        // IATACode has less than 8 digits
        IdCardLoginController.IATACodeLocation = '123';
        nextPage = idCardLoginController.verify();
        System.assert(checkMessages(ApexPages.getMessages(), Label.IDCard_IATACodeNot8Digits), 'Label.IDCard_IATACodeNot8Digits message should be added');

        // VER is null
        IdCardLoginController.IATACodeLocation = relatedContact[1].IATA_Code__c;
        nextPage = idCardLoginController.verify();
        System.assert(checkMessages(ApexPages.getMessages(), Label.IDCard_VERrequired), 'Label.IDCard_VERrequired message should be added');

        // VER and IATA Code not numeric
        IdCardLoginController.IATACodeLocation = 'abcdefgh';
        IdCardLoginController.VERNumber = 'abcdefgh';
        nextPage = idCardLoginController.verify();
        System.assert(checkMessages(ApexPages.getMessages(), Label.IDCard_NumericFieldError), 'Label.IDCard_NumericFieldError message should be added');

        // IATACode and VER are valid
        Account acc = [SELECT id, IATACode__c, IATA_ISO_Country__c, IDCard_Key_Account__c , Status__c, BillingCountry FROM Account WHERE id = :relatedContact[1].AccountId];
        IdCardLoginController.IATACodeLocation = acc.IATACode__c;
        IdCardLoginController.VERNumber = relatedContact[1].VER_Number__c + '';

        // managedAccountList size is bigger than 0: method returns PageReference
        Managed_agency__c managedAccount = new Managed_agency__c (Contact__c = relatedContact[1].Id, Account__c = relatedContact[1].AccountId);
        insert managedAccount;
        System.assertEquals(String.valueOf(idCardLoginController.verify()).substringBefore('?') + ']', String.valueOf(Page.IDCard_PortalKeyContact), 'IDCard_PortalKeyContact PageReference should be returned');

        // managedAccountList size is = 0
        delete managedAccount;

        // VER not found - contact list == null
        IdCardLoginController.VERNumber = '784512369';
        nextPage = idCardLoginController.verify();
        System.assert(checkMessages(ApexPages.getMessages(), Label.IDCard_NoContactsFound), 'Label.IDCard_NoContactsFound message should be added');

        // VER found - contact list > 0
        IdCardLoginController.VERNumber = relatedContact[1].VER_Number__c + '';

        IATA_ISO_Country__c country = [SELECT Id, AIMS_Area_Name__c, Name, ISO_Code_Numeric__c, AIMS_Area_ID__c, ISO_Code__c
                                       FROM IATA_ISO_Country__c
                                       WHERE AIMS_Area_Name__c = :acc.BillingCountry LIMIT 1][0];

        List<Price_Table__c> priceTables = [SELECT Type_Class_of_Agent__c, Expedite__c, Name, ISO_Country__c
                                            FROM Price_Table__c
                                            WHERE ISO_Country__r.Id = :country.Id];

        // delete price table to delete country
        delete priceTables;

        // country not found
        delete country;
        IATAIsoCountryDAO.resetMapIataIsoCountry();

        nextPage = idCardLoginController.verify();

        System.assert(checkMessages(ApexPages.getMessages(),'ISO Country not found for the following Account:' + idCardLoginController.IATACodeLocation ), 'ISO Country not found message should be added');

        // country found
        country.id = null;
        insert country;

        //Work around to reset the static Iata Iso Country maps
        IATAIsoCountryDAO.resetMapIataIsoCountry();

        // ID_Card__c.Blacklisted = true;
        String IDCardQuery = 'Select Id, Blacklisted__c, Card_Status__c From ID_Card__c where Related_Contact__c  = \'' + relatedContact[1].Id + '\' order by createddate desc';
        ID_Card__c[] cards = Database.query(IDCardQuery);
        cards[0].Blacklisted__c = true;
        update cards;
        nextPage = idCardLoginController.verify();
        System.assert(checkMessages(ApexPages.getMessages(), 'Your IATA/IATAN ID Card has been blacklisted'), 'ID Card blacklisted message should be added');

        // ID_Card__c.Blacklisted = false;
        // listPriceTables is empty
        cards[0].Blacklisted__c = false;
        update cards;
        nextPage = idCardLoginController.verify();
        System.assert(checkMessages(ApexPages.getMessages(), 'Price Table not found for the following Country:' + country.name), 'Price Table not found message should be added');

        // insert Price_Table__c
        for (Price_Table__c pt : priceTables) {
            pt.Id = null;
            pt.ISO_Country__c = country.Id;
        }
        insert priceTables;

        // pendingCase is not null
        nextPage = idCardLoginController.verify();
        System.assertEquals(String.valueOf(idCardLoginController.verify()).substringBefore('?') + ']', String.valueOf(Page.IDCard_PendingCase_Details), 'IDCard_PendingCase_Details PageReference should be returned');

        // delete case: pendingCase is null
        Case pendingCase = [SELECT Id FROM Case WHERE Contact.Id = :relatedContact[1].Id LIMIT 1][0];
        delete pendingCase;

        // pendingIdCardsApp is not empty
        System.assertEquals(String.valueOf(idCardLoginController.verify()).substringBefore('?') + ']', String.valueOf(Page.IDCard_PendingIdCardApp_Details), 'IDCard_PendingIdCardApp_Details PageReference should be returned');

        // pendingIdCardsApp is empty
        ID_Card_Application__c pendingIdCardApp = [Select id, VER_Number__c, IATA_Code__c, Application_Status__c, RecordType.Name FROM ID_Card_Application__c
                WHERE RecordType.Name = 'Single ID Card Operation'
                                        AND VER_Number__c = :relatedContact[1].VER_Number__c + '' LIMIT 1][0];

        pendingIdCardApp.Application_Status__c = 'Paid';
        update pendingIdCardApp;

        // account status = 'terminated'
        acc.Status__c = 'Terminated';
        update acc;
        System.assertEquals(String.valueOf(idCardLoginController.verify()).substringBefore('?') + ']', String.valueOf(Page.IDCard_Portal), 'IDCard_Portal PageReference should be returned');

        // account status = 'approved'
        acc.Status__c = 'Approved';
        update acc;

        // cover captcha
        ApexPages.currentPage().getParameters().put('g-recaptcha-response', 'test');

        // login verified
        System.assertEquals(String.valueOf(idCardLoginController.verify()).substringBefore('?') + ']', String.valueOf(Page.IDCard_MultipleAgency_Details), 'IDCard_MultipleAgency_Details PageReference should be returned');
        Test.stopTest();
    }

    @isTest
    public static void TestVerifyAlternative() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TestIDCardLoginController();

        idCardLoginController.FNAME = '';
        idCardLoginController.LNAME = '';
        idCardLoginController.IATACodeLocation2 = '';
        idCardLoginController.DOB = '';
        // IATACode, Firstname, Lastname and Date of birth are null
        nextPage = idCardLoginController.verifyAlternative();

        controllerPage.getParameters().put('recaptcha_challenge_field', 'challengeTest');
        controllerPage.getParameters().put('recaptcha_response_field', 'responseTest');
        idCardLoginController.reset();
        string t = idCardLoginController.publicKey;
        idCardLoginController.setSelectedLanguage('en_US');
        t = idCardLoginController.getSelectedLanguage();
        idCardLoginController.FNAME = '';
        idCardLoginController.LNAME = '';
        idCardLoginController.IATACodeLocation2 = '';
        idCardLoginController.DOB = '';
        nextPage = idCardLoginController.verifyAlternative();

        // Invalid Account
        Test.startTest();
        Date dateTemp = testData.IDCards_IDCardApplications[0].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = testData.IDCards_IDCardApplications[0].IATA_Code__c;
        idCardLoginController.FNAME = testData.IDCards_IDCardApplications[0].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[0].Last_Name__c;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();
        nextPage = idCardLoginController.verifyAlternative();

        // Multiple Agent
        dateTemp = relatedContact[1].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = relatedContact[1].IATA_Code__c;
        idCardLoginController.FNAME = relatedContact[1].FirstName;
        idCardLoginController.LNAME = relatedContact[1].LastName;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();
        nextPage = idCardLoginController.verifyAlternative();

        // New ID Application
        dateTemp = testData.IDCards_IDCardApplications[2].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = testData.IDCards_IDCardApplications[2].IATA_Code__c;
        idCardLoginController.FNAME = testData.IDCards_IDCardApplications[2].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[2].Last_Name__c;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();
        nextPage = idCardLoginController.verifyAlternative();


        // New ID Application for limited keyAccount
        dateTemp = testData.IDCards_IDCardApplications[2].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = testData.IDCard_keyAccounts[1].IATACode__c;
        idCardLoginController.FNAME = testData.IDCards_IDCardApplications[2].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[2].Last_Name__c;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();
        nextPage = idCardLoginController.verifyAlternative();

        //unlimited key acocunt
        dateTemp = testData.IDCards_IDCardApplications[2].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = testData.IDCard_keyAccounts[0].IATACode__c;
        idCardLoginController.FNAME = testData.IDCards_IDCardApplications[2].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[2].Last_Name__c;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();
        nextPage = idCardLoginController.verifyAlternative();

        // Wrong Date of Birth format
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year() + '2';
        nextPage = idCardLoginController.verifyAlternative();
        Test.stopTest();
    }

    //Checks if ApexPages.Message contains a specific message
    private static Boolean checkMessages(List<ApexPages.Message> pageMessages, String expectedMessage) {
        for (ApexPages.Message message : pageMessages) {
            if (message.getDetail().contains(expectedMessage)) {
                return true;
            }
        }
        return false;
    }
}
