@isTest
private class CaseBeforeTriggerTest {
	
	@isTest static void unitTest1() {
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID CSRcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('BSPlink Customer Service Requests (CSR)');
        Id RT_Fin_Sec_Monitoring_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Security_Monitoring');
        ID SIDRAcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
        insert isoCountry;

        BusinessHours bHourObj = new BusinessHours();
        bHourObj = [Select id, name from BusinessHours where name =: 'EUR - France'];

        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        insert a;
         
        Contact con =new contact(lastname = 'pluto' ,
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true);
        insert con;
                                
        test.startTest();
        
        // Insert correctly a case
        Case cas = new Case(recordtypeID = CSRcaseRecordTypeID,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          Case_Creator_Email__c = 'gianluigi.test@gmail.com',
                          Accelya_Request_Type__c = 'General Queries',
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id                         
        );
        insert cas; 
        // Insert correctly a case
        Case cas1 = new Case(recordtypeID = RT_Fin_Sec_Monitoring_Id,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Country_concerned_by_the_query__c = 'suisse',
                          Case_Creator_Email__c = 'gianluigi.test@gmail.com',
                          Accelya_Request_Type__c = 'General Queries',
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id,
                          BusinessHoursId = bHourObj.id                      
        );
        insert cas1; 

        Case cas2 = new Case(recordtypeID = SIDRAcaseRecordTypeID,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          DPC_Software__c = 'Multicarta',
                          parentid = cas.id,
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id,
                          CS_Contact_Result__c = 'Agent closed'
                          //Update_AIMS_IRR__c = system.now(),
                          //Update_AIMS_DEF__c = system.now(),
                          //Update_AIMS_IRRWITH__c = system.now(),
                          //Update_AIMS_REI_DEFWITH__c = system.now(),
                          //Update_AIMS_TER__c = system.now(),
                          //IRR_Withdrawal_Reason__c = 'Small Amount (<50USD)'
        );
        insert cas2; 
        
        cas1.First_closure_date__c = system.today();
        cas1.First_Business_Day__c = system.today();
        cas1.Short_Payment_Date__c = system.today();

        update cas1;
    }



}