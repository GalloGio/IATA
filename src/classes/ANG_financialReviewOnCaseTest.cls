@isTest
private class ANG_financialReviewOnCaseTest {
    @testSetup static void testSetup() {
        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name = 'France', 
            ISO_Code__c = 'FR',
            AIMS_Area_ID__c='1',
            ANG_Enable_NewGen__c = true
        );
        insert country;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency');
        Account a = new Account(
            Name = 'Qatar Airways', 
            Airline_designator__c = 'QR', 
            RecordTypeId = AirlineHQ_RT_Id, 
            iataCode__C='99999999',
            BillingCountry='France',
            Location_type__C='HE',
            Location_Class__c='P',
            IATA_ISO_Country__c=country.id

        );
        insert a;        
        
        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
        insert fi;

        Contact cont= new Contact(
        		lastName='lastName',
        		Financial_Assessment_Contact__c=true,
        		email='test@test.com'
        	);
        insert cont;
        // create a reception case
        Case c = new Case(
        		Subject = 'rception case',
        		AccountId = a.Id, 
        		contactId=cont.Id,
        		Status = 'Open', 
        		Assessment_Performed_Date__c= system.today(),
        		Financial_Review_Result__c='Satisfactory - New Financial Security',
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review'),IFAP_Area__c='asda'
                 );
        insert c;
                
        // Create a new Financial Security
        Financial_Security__c fs = new Financial_Security__c(Region__c = 'Americas', Security_status__c = 'Active', Account__c = a.Id, CurrencyIsoCode = 'USD', Amount__c = 100,
                        Expiry_date__c = Date.today().addYears(2), Financial_Institution__c = fi.Id, Security_Type__c = 'Cross Border Guarantee', 
                        Validity_Start_Date__c = Date.today().addDays(-2), Reception_Case__c = c.Id, Reception_Date__c = Date.today(), Reasonforrequest__c = 'New Application');
        insert fs;

       

    }
    TestMethod static void updateCaseStatusToUpdateFinancialReview(){
    	Test.startTest();
	    	case c=[select id,Financial_Review_Result__c from case limit 1];
	    	c.status='Closed';
	        update c;
        Test.stopTest();
        system.assertEquals(c.Financial_Review_Result__c,[select Financial_Review_Result__c from account limit 1].Financial_Review_Result__c);

    } 
    TestMethod static void updateCaseStatusToNOTUpdateFinancialReview(){
    	account beforeUpdateAcc =[select Financial_Review_Result__c from account limit 1];	

    	Test.startTest();
	    	case c=[select id,Financial_Review_Result__c from case limit 1];
	    	c.status='Approved';
	        update c;
        Test.stopTest();
        account afterUpdateAcc =[select Financial_Review_Result__c from account limit 1];	

        system.assertEquals(afterUpdateAcc.Financial_Review_Result__c,beforeUpdateAcc.Financial_Review_Result__c);

    }
}