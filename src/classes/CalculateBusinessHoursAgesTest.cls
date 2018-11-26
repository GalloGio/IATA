@isTest
private class CalculateBusinessHoursAgesTest {

    static void inserTestData() {

        list<Stop_Status__c> stopThisOnes = new list<Stop_Status__c> { new Stop_Status__c(name = 'With Customer' ,
                    Status_Bucket__c = 'With Customer'),
                                     new Stop_Status__c(name = 'Escalated Internally' ,
                                             Status_Bucket__c = 'Escalated Internally'),
                                     new Stop_Status__c(name = 'Escalated Externally' ,
                                             Status_Bucket__c = 'Escalated Externally')
        };
        insert stopThisOnes;

        BusinessHours  businessSicily = [ SELECT Id from BusinessHours where IsDefault  = true];

        Case c = new Case(

            Status = 'Open',
            BusinessHoursId = businessSicily.id,
            Short_Payment_Date__c = date.today()
        );

        insert c;

    }

    static testMethod void myUnitTest() {

        inserTestData();

        Account a = new Account(name = 'test', recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') );
        insert a;
        Contact con = new Contact(accountid = a.id, FirstName = 'Name', LastName = 'Test', phone = '321321', recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact') );
        insert con;

        Case myCase = [select  id, Short_Payment_Date__c, status, First_closure_date__c, ClosedSameDay__c, Short_Payment_Next_Business_Date__c, CreatedDate , contactId, AccountId
                       from Case limit 1];

        system.assertNotEquals(null, myCase.Short_Payment_Next_Business_Date__c);
        system.assertNotEquals(myCase.Short_Payment_Date__c, myCase.Short_Payment_Next_Business_Date__c);

        mycase.Status = 'Closed';

        myCase.AccountId = a.id;
        myCase.ContactID = con.id;

		myCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
		
        system.debug('ANTES DO UPDATE mycase.RecordTypeId    ++++++++++++++++++++++' +  mycase.RecordTypeId);
        system.debug('ANTES DO UPDATE mycase.ClosedSameDay__c    ++++++++++++++++++++++' +  mycase.ClosedSameDay__c);
        system.debug('ANTES DO UPDATE mycase.First_closure_date__c     ++++++++++++++++++++++' +  mycase.First_closure_date__c);
        system.debug('ANTES DO UPDATE mycase.Status     ++++++++++++++++++++++' +  mycase.Status);

        //throw new transformationException( ' adc '   + myCase.AccountId + '   con ' + myCase.ContactId) ;

        update mycase;

        Case newcase = [SELECT Status, id, RecordTypeId, ClosedSameDay__c, First_closure_date__c from Case WHERE id = : mycase.id];

        system.debug('depois DO UPDATE mycase.RecordTypeId    ++++++++++++++++++++++' +  newcase.RecordTypeId);
        system.debug('depois DO UPDATE mycase.ClosedSameDay__c    ++++++++++++++++++++++' +  newcase.ClosedSameDay__c);
        system.debug('depois DO UPDATE mycase.First_closure_date__c     ++++++++++++++++++++++' +  newcase.First_closure_date__c);
        system.debug('depois DO UPDATE mycase.Status     ++++++++++++++++++++++' +  newcase.Status);

        system.assertEquals(newcase.ClosedSameDay__c, 'Yes');

    }
    
     static void inserTestData2() {

        BusinessHours  defaultBusinessHours = [ SELECT Id from BusinessHours where IsDefault  = true];
        ID casesEurRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope') ;
        
        Account a = new Account(Name = 'test', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') );
        insert a;
        
        Contact con = new Contact(AccountId = a.id, FirstName = 'Name', LastName = 'Test', Email = 'test@test.com', phone = '321321', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact') );
        insert con;
        
        Case c = new Case(ContactId = con.Id, Status = 'Open', BusinessHoursId = defaultBusinessHours.id, RecordTypeId = casesEurRT);
        insert c;

    }

    static testMethod void testUpdateOnFirstContactWClient() {
    
        inserTestData2();
        
        Test.startTest();
        
        Case myCase = [select  Id, contact.Email, ContactId, First_Contact_with_Client__c, First_Contact_w_Client_in_Business_Hours__c from Case limit 1];
        
        system.assertNotEquals(null, myCase.contact.Email);
        
        EmailMessage email = new EmailMessage(ParentId=myCase.Id, FromAddress = 'test@test.org', FromName='Yo',Subject='Subject',ToAddress = myCase.contact.Email, Incoming = false);
        insert email;
        
        myCase = [select  Id, contact.Email, ContactId, First_Contact_with_Client__c, First_Contact_w_Client_in_Business_Hours__c from Case limit 1];
        
        Test.stopTest();
        
        system.assertNotEquals(null, myCase.First_Contact_with_Client__c);
        system.assertNotEquals(null, myCase.First_Contact_w_Client_in_Business_Hours__c);
    
    }
    
}