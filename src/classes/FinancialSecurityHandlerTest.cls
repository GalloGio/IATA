@isTest
private class FinancialSecurityHandlerTest {
    static testMethod void test() {
        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create an Airline HQ account
        //Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency'); //For PROD
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'); //For SIT and PREP


        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', RecordTypeId = AirlineHQ_RT_Id, Type = 'IATA Passenger Sales Agent');
        insert a;        
        
        Account b = new Account(Name = 'Qatar Airways',parent = a, Airline_designator__c = 'QR', RecordTypeId = AirlineHQ_RT_Id, Type = 'IATA Passenger Sales Agent');
        

        Contact co1 = new Contact(AccountId = a.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
        Contact co2 = new Contact(AccountId = a.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
        Contact co3 = new Contact(AccountId = a.id, Firstname = 'teste3', Lastname='test3', Phone = '911111113', MobilePhone = '911111113', Email = 'test3@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved');
        
        List<Contact> cos = new List<Contact>{co1,co2}; 
        insert cos;

        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
        insert fi;
        
        // create a reception case
        Case c = new Case(Subject = 'rception case', AccountId = a.Id, Status = 'Open', 
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE') ); //For SIT and PREP
            //RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('InternalCasesEuropeSCE') ); //For PROD
        insert c;
                
        // Create a new Financial Security
        Financial_Security__c fs = new Financial_Security__c(Region__c = 'Americas', Security_status__c = 'Active', Account__c = a.Id, CurrencyIsoCode = 'USD', Amount__c = 100,
                        Expiry_date__c = Date.today().addYears(2), Financial_Institution__c = fi.Id, Security_Type__c = 'Cross Border Guarantee', 
                        Validity_Start_Date__c = Date.today().addDays(-2), Reception_Case__c = c.Id, Reception_Date__c = Date.today(), Reasonforrequest__c = 'New Application');
        insert fs;
        
        List<Case> lstCases = [SELECT Id FROM Case LIMIT 10];
        system.assertEquals(1, lstCases.size());
        
        system.assertEquals(null, fs.Renewal_Case__c);
        
        // update the FS record to trigger the creation of the renewal Case
        fs.Security_Status__c = 'Close to Expiry Date';
        update fs;      
        
        // check that the renewal case has been created and linked to the FS record
        fs = [SELECT Id, Renewal_Case__c,Region__c FROM Financial_Security__c WHERE Id = :fs.Id];
        if (userinfo.getProfileId() != '00e20000000h0gFAAQ' || (userinfo.getProfileId() == '00e20000000h0gFAAQ' && Test.isRunningTest()) ) {
        	system.assertNotEquals(null, fs.Renewal_Case__c);
            lstCases = [SELECT Id FROM Case LIMIT 10];
        	system.assertEquals(2, lstCases.size());
        } else {
            system.assertEquals(null, fs.Renewal_Case__c);
        }  
        
        FinancialSecurityUtil.sendEmailAlert(null, fs, null, null);

        delete fs;
        undelete fs;
    }   
}