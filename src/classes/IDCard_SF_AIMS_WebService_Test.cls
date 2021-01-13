@isTest
private class IDCard_SF_AIMS_WebService_Test {

    static testMethod void ExtractIdCardInfoTest() {

        // Create IDCardApplication, Account, Contact & ID Card Object
        Account aAccount = CreateAccountTest();
        list<Contact> lstContacts = CreateListOfContactTest();
        ID_Card_Application__c aApplication = CreateAIdCardApplication();
        ID_Card__c aCard = CreateAIDCardTest();
        
        for (Contact aContact : lstContacts){
            aContact.AccountId = aAccount.Id;
        }

        aCard.Related_Contact__c = lstContacts[0].Id;
        aCard.ID_Card_Application__c = aApplication.Id;
        
        update lstContacts;
        update aCard;
        
        IDCard_SF_AIMS_WebService.ExtractIdCardInfo();
    }
    
    static testMethod void SetMustSynchWithAIMSFlagToFalseTest()
    {
                // Create IDCardApplication, Account, Contact & ID Card Object
        Account aAccount = CreateAccountTest();
        Contact aContact = CreateContactTest();
        list<Contact> lstContacts = CreateListOfContactTest();
        ID_Card_Application__c aApplication = CreateAIdCardApplication();
        ID_Card__c aCard = CreateAIDCardTest();
        
        aContact.AccountId = aAccount.Id;
        
        for (Contact theContact : lstContacts){
            theContact.AccountId = aAccount.Id;
        }
        aCard.Related_Contact__c = aContact.Id;
        aCard.ID_Card_Application__c = aApplication.Id;
        
        update lstContacts;
        update aCard;
        
        list<string> idCardsIds = new list<string>();
        list<Decimal> contactsIds = new list<Decimal>();
        
        idCardsIds.add(aCard.Id);
        contactsIds.add(aContact.VER_Number__c);
        string retValue = IDCard_SF_AIMS_WebService.SetMustSynchWithAIMSFlagToFalse(idCardsIds);      
       
        /*        
        aCard.Start_Date_Agency_Month__c = 'MARCH';         
        aCard.Start_Date_Agency_Month__c = 'APRIL';       
        aCard.Start_Date_Agency_Month__c = 'MAY';         
        aCard.Start_Date_Agency_Month__c = 'JUNE';         
        aCard.Start_Date_Agency_Month__c = 'JULY';        
        aCard.Start_Date_Agency_Month__c = 'AUGUST';        
        aCard.Start_Date_Agency_Month__c = 'SEPTEMBER';         
        aCard.Start_Date_Agency_Month__c = 'OCTOBER';        
        aCard.Start_Date_Agency_Month__c = 'NOVEMBER';         
        aCard.Start_Date_Agency_Month__c = 'DECEMBER';
        */
        
        
        
        //string retValue = IDCard_SF_AIMS_WebService.SetMustSynchWithAIMSFlagToFalse(idCardsIds, contactsIds);
    }

    static testMethod void UpdateSFIdCardsTest(){
        Account aAccount = CreateAccountTest();
        Contact aContact = CreateContactTest();
        ID_Card_Application__c aApplication = CreateAIdCardApplication();
        ID_Card__c aCard = CreateAIDCardTest();
        
        aContact.AccountId = aAccount.Id;
        aCard.Related_Contact__c = aContact.Id;
        aCard.ID_Card_Application__c = aApplication.Id;
        
        update aContact;
        update aCard;
        
        IDCard_SF_AIMS_WebService.UpdateSFIdCards('34342', 'Toto the clown','1234567', '2013-06-06', '2014-06-06', aCard.Id, 'Valid ID Card');
    }
    
    private static Account CreateAccountTest()
    {   IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account aAccount = new Account();
        aAccount.Name = 'Unit Test Account 1';
        aAccount.IATACode__c = '12345678';
        aAccount.Industry = 'Travel Agent';
        aAccount.Type = 'IATA Passenger Sales Agent';
        aAccount.BillingCity = 'Montreal';
        aAccount.BillingCountry = 'Canada';
        aAccount.BillingPostalCode = 'H4G 2S4';
        aAccount.BillingState = 'Quebec';
        aAccount.BillingStreet = '666 Sherbrooke';
        aAccount.RecordTypeID = rectypeid; //'012w0000000QBMW';
        aAccount.IATA_ISO_Country__c = country_fr.Id;
        
        insert aAccount;
        
        return aAccount;
    }
    
    private static Contact CreateContactTest()
    {   
        Contact aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 1';
        aContact.Date_of_Birth__c = date.valueOf('1981-05-25');
        aContact.VER_Number__c = Decimal.valueof('9936764367');
        aContact.UIR__c = '54334';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'January';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = '35 h or more';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail@blablaemail.com';
        aContact.Phone = '5151515151';
        
        insert aContact;
        
        return aContact;
    }
    
    
    private static integer vernumber = 0;
    private static integer getVernumber (){
             vernumber =  vernumber +1;
        return vernumber;
    }
    
    
    
    private static list<Contact> CreateListOfContactTest()
    {   
        list<Contact> lstContacts = new list<Contact>();
        
        Contact aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 2';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'January';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = '35 h or more';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail14@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 3';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'February';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = '25-34 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail13@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 4';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'March';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = '20-24 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail11@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 5';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'April';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail10@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 6';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'May';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail9@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 7';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'June';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail8@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 8';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'July';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail7@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 9';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'August';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail6@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 10';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'September';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail4@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 11';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'October';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail3@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 12';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'November';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail1@blablaemail.com';
        aContact.Phone = '5151515151';
        lstContacts.add(aContact);
        
        aContact = new Contact();
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 13';
        aContact.Date_of_Birth__c = date.valueOf('1981-03-12');
        aContact.VER_Number__c = getvernumber();
        aContact.UIR__c = 'AU000661';
        aContact.Solicitation_Flag__c = true;
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Start_Date_Agency_Year__c = Decimal.valueOf('2000');
        aContact.Start_Date_Agency_Month__c = 'December';
        aContact.Start_Date_Industry__c = double.valueOf('1998');
        aContact.Duties__c = 'Sales';
        aContact.Position__c = 'Director';
        aContact.Hours_per_week__c = 'Less than 20 h';
        aContact.RecordTypeId = '012w0000000QBMh';
        aContact.Email = 'testemail2@blablaemail.com';
        aContact.Phone = '5151515151';
        
        lstContacts.add(aContact);
        
        insert lstContacts;
        
        return lstContacts;
    }
    
    private static ID_Card__c CreateAIDCardTest()
    {       
        ID_Card__c aIdCard = new ID_Card__c();
        aIdCard.FirstName__c = 'Test';
        aIdCard.LastName__c = 'Contact 1';
        aIdCard.Name_on_ID_Card__c = 'Test IDCard';
        aIdCard.Nature_of_ID_Card__c = 'Nenew';
        aIdCard.Card_Status__c = 'Approved';
        aIdCard.Type_of_ID_Card__c = 'Passenger';
        aIdCard.Photo_Flag__c = 'Digital';
        aIdCard.Photo__c = 'AU000661';
        aIdCard.Card_Variation_Code__c ='2';
        aIdCard.Card_Code__c = 'TACB';
        aIdCard.MustSyncWithAIMS__c = true;     
        aIdCard.Hours_per_week__c = '35h or more';
        aIdCard.Start_Date_Agency_Month__c = 'DECEMBER';
        aIdCard.Start_Date_Agency_Year__c = '2000';
        aIdCard.Date_of_Birth__c = Date.newInstance(1985, 06, 23);
        insert aIdCard;
        
        return aIdCard;
    }

    private static ID_Card__c CreateValidIDCardTest()
    {       
        ID_Card__c aIdCard = new ID_Card__c();
        aIdCard.FirstName__c = 'Test';
        aIdCard.LastName__c = 'Contact 1';
        aIdCard.Agency_Name__c = 'Test IDCard';
        aIdCard.Agency_IATA_Code__c = '12345678';
        aIdCard.Name_on_ID_Card__c = 'Test IDCard';
        aIdCard.Nature_of_ID_Card__c = 'Nenew';
        aIdCard.Card_Status__c = 'Approved';
        aIdCard.Type_of_ID_Card__c = 'Passenger';
        aIdCard.Photo_Flag__c = 'Digital';
        aIdCard.Photo__c = 'AU000661';
        aIdCard.Card_Variation_Code__c ='2';
        aIdCard.Card_Code__c = 'TACB';
        aIdCard.CIN__c = 'TACB';
        aIdCard.MustSyncWithAIMS__c = true;     
        aIdCard.Hours_per_week__c = '35h or more';
        aIdCard.Start_Date_Agency_Month__c = 'DECEMBER';
        aIdCard.Start_Date_Agency_Year__c = '2000';
        aIdCard.Start_Date_Industry__c = '2000';
        aIdCard.Valid_To_Date__c = Date.newInstance(2099, 06, 23);
        aIdCard.VER_Number__c = '5036048956';
        aIdCard.Date_of_Birth__c = Date.newInstance(1985, 06, 23);
        insert aIdCard;
        
        return aIdCard;
    }
    
    private static ID_Card_Application__c CreateAIdCardApplication()
    {       
        ID_Card_Application__c aApplication = new ID_Card_Application__c();
        aApplication.Title__c = 'Mr';
        aApplication.First_Name__c = 'Test';
        aApplication.Last_Name__c = 'Contact 1';
        aApplication.Approving_Manager_s_Email__c = 'manager@admin.ad';
        aApplication.Approving_Manager_s_Name__c = 'Manager';
        aApplication.Date_of_Birth__c = Date.newInstance(1980,12,12);
        aApplication.Displayed_Name__c = 'Test Contact 1';
        aApplication.Type_of_application__c = 'Renew';
        aApplication.Gender__c = 'M';
        aApplication.Solicitation_Flag__c = true;
        aApplication.IATA_Code__c = '1234567';
        aApplication.Start_Date_Agency_Year__c = '2000';
        aApplication.Start_Date_Agency_Month__c = 'January';
        aApplication.Start_Date_Industry__c = '1998';
        aApplication.Duties_in_Current_Agency__c = 'Sales';
        aApplication.Position_in_Current_Agency__c = 'Director';
        aApplication.Hours_worked__c = '35 h or more';
        aApplication.Email_admin__c = 'dummyemail@mlail.com';
        insert aApplication;
        
        return aApplication;
    }



    static testMethod void GetIdCardPrintInfoTest1() {

        // Create IDCardApplication, Account, Contact & ID Card Object
        Account aAccount = CreateAccountTest();
        list<Contact> lstContacts = CreateListOfContactTest();
        ID_Card_Application__c aApplication = CreateAIdCardApplication();
        ID_Card__c aCard = CreateAIDCardTest();
        
        for (Contact aContact : lstContacts){
            aContact.AccountId = aAccount.Id;
        }

        aCard.Related_Contact__c = lstContacts[0].Id;
        aCard.ID_Card_Application__c = aApplication.Id;
        
        update lstContacts;
        update aCard;
        
        IDCard_SF_AIMS_WebService.GetIdCardPrintInfo('WW');
    }

    static testMethod void GetIdCardPrintInfoTest2() {

        test.startTest();
        // Create IDCardApplication, Account, Contact & ID Card Object
        Account aAccount = CreateAccountTest();
        list<Contact> lstContacts = CreateListOfContactTest();
        ID_Card_Application__c aApplication = CreateAIdCardApplication();
        ID_Card__c aCard = CreateValidIDCardTest();
        
        for (Contact aContact : lstContacts){
            aContact.AccountId = aAccount.Id;
        }

        aCard.Related_Contact__c = lstContacts[0].Id;
        aCard.ID_Card_Application__c = aApplication.Id;
        
        update lstContacts;
        update aCard;
        test.stopTest();
        
        IDCard_SF_AIMS_WebService.GetIdCardPrintInfo('WW');
    }


    static testMethod void GDResponseWebServicesTest() {
        
        string STATUSNOPHOTO = 'ERROR Picture Missing';
        string STATUSREJECTED = 'ERROR Rejected by G&D';
        string CSVALID = 'Valid ID Card';

        test.startTest();
        // Create IDCardApplication, Account, Contact & ID Card Object
        Account aAccount = CreateAccountTest();
        list<Contact> lstContacts = CreateListOfContactTest();
        ID_Card_Application__c aApplication = CreateAIdCardApplication();
        ID_Card__c aCard = CreateValidIDCardTest();
        
        for (Contact aContact : lstContacts){
            aContact.AccountId = aAccount.Id;
        }

        aCard.Related_Contact__c = lstContacts[0].Id;
        aCard.ID_Card_Application__c = aApplication.Id;
        
        update lstContacts;
        update aCard;

        //IDCard_SF_AIMS_WebService.UpdateSFIdCards(null, null, null, null, null, aCard.Id, null);
        test.stopTest();
        
//aCard = [SELECT Id, Card_Status__c, Related_Contact__r.UIR__c FROM ID_Card__c WHERE Id = :aCard.Id];
//system.assertEquals('54668', aCard.Related_Contact__r.UIR__c);
        // LogMissingPhotoErrors
        list<String> lstIdCardIds = new list<String>();
        lstIdCardIds.add(aCard.Id);
        IDCard_SF_AIMS_WebService.LogMissingPhotoErrors(lstIdCardIds);

        aCard = [SELECT Id, Card_Status__c FROM ID_Card__c WHERE Id = :aCard.Id];
        system.assertEquals(STATUSNOPHOTO, aCard.Card_Status__c);

        IDCard_SF_AIMS_WebService.SetMustSynchWithAIMSFlagToFalse(lstIdCardIds);

        // UpdatePrintedIdCard
        IDCard_SF_AIMS_WebService.UpdatePrintedIdCard('02-3 3362 3FLIGHT CENTRE TRAVEL                                            BRISBA                          LEVEL 3, 545 QUEEN STREET                                                                       BRISBANE                      4000      GRAHAM TURNER       0381/730381/7311/17  TUR49G062651MI1AU 5036000661     AU000661            AUSTRALIA                 AUWW11281N                                                                                                   ');
        aCard = [SELECT Id, Card_Status__c FROM ID_Card__c WHERE Id = :aCard.Id];
        system.assertEquals(CSVALID, aCard.Card_Status__c);

        aCard.Received_From_AIMS__c = null;
        update aCard;

        // UpdateRejectedIdCards
        IDCard_SF_AIMS_WebService.UpdateRejectedIdCards(new list<String>{'AU000661201611210118'});
        aCard = [SELECT Id, Card_Status__c FROM ID_Card__c WHERE Id = :aCard.Id];
        system.assertEquals(STATUSREJECTED, aCard.Card_Status__c);


        // LogSystemError
        list<IEC_Error_Log__c> lstLogs = [SELECT Id FROM IEC_Error_Log__c];
        system.assertEquals(0, lstLogs.size());

        IDCard_SF_AIMS_WebService.LogSystemError('test error', 'Amazon S3', '<input data>', '<full error message>');

        lstLogs = [SELECT Id FROM IEC_Error_Log__c];
        system.assertEquals(1, lstLogs.size());
        
    }


}