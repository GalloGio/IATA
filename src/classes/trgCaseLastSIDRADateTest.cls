@isTest
public class trgCaseLastSIDRADateTest{
     
    static testMethod void testAllMethod()
    {    	
        ID iFDSRecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('Cases - Americas');
    	ID iFAPRecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');       
    	ID sidraRecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        //contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        
        insert contact1;
        
        Case case1 = new Case();
        case1.ContactId = contact1.Id;
        case1.RecordTypeId = sidraRecordTypeID;
        //#case1.AccountId = account1.Id;
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        case1.BSPCountry__c = 'Canada';
        insert case1;
        
        Case case3 = new Case();
        case3.ContactId = contact1.Id;
        case3.RecordTypeId = sidraRecordTypeID;
        //case3.AccountId = account1.Id;
        case3.Subject = 'Test Case 1';
        case3.Description = 'Test Case 1';
        case3.BSPCountry__c = 'Canada';
        insert case3;      
        
    }
    
    static testMethod void testAllMethod2()
    {
        ID iFDSRecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('Cases - Americas');
    	ID iFAPRecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');       
    	ID sidraRecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');
        System.debug('********* ' + sidraRecordTypeId);
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Location_Type__c = 'HO';     
        
       insert account1;
        
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';        
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        
        insert contact1;
        
        Case case1 = new Case();
        case1.ContactId = contact1.Id;
        case1.RecordTypeId = sidraRecordTypeID;
        case1.AccountId = account1.Id;
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        case1.BSPCountry__c = 'Canada';
        insert case1;      
        
        case1.Instant_Survey_Last_survey_sent__c = Date.Today();
        case1.BSPCountry__c = 'France';  
        case1.RecordTypeId = iFDSRecordTypeId;
        case1.IFAP_Financial_Year__c = '2005';
        update case1;    
               
    }
    
}