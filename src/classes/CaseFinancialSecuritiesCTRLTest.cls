@isTest
private class CaseFinancialSecuritiesCTRLTest {
        
    static testMethod void myUnitTest() {
                        
        //ID hqrt =Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
		ID hqrt =Schema.SObjectType.Account.RecordTypeInfosByName.get('Agency').RecordTypeId ;
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review'); 
         
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
            insert isoCountry;
            
		Account a = new Account(name ='IFAP ACCT',
								industry = 'pluto',
                                IATA_ISO_Country__c=isoCountry.id,
                                recordtypeID = hqrt,
                                IATACode__c ='1234567',
                                Type = 'IATA Cargo Agent',
                                billingCountry = 'suisse',Location_Type__c = 'AO');
		insert a;
             
		Financial_Institution__c inst = new Financial_Institution__c(name = 'wertgwertwet',
                                                                    Institution_Type__c = 'myType',
                                                                    Country__c = 'asd',
                                                                    Region__c = 'Europe');
        insert inst;    
                                                                               
		Contact con =new contact(lastname = 'pluto' ,
								 firstname = 'Name',
								 phone = '123',
								 accountid = a.id,
								 Financial_Assessment_Contact__c = true);
		insert con;
        
        Test.startTest();
                   
		date dead = date.today().addDays(40);
       
		Case c = new Case(recordtypeID = IFAPcaseRecordTypeID,
                 Status = 'Assessment Performed',
                 Origin = 'asd',
                 IFAP_Area__c = 'asda',
                 Financial_Review_Type__c ='bla',
                 IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                 Deadline_Date__c = dead,
                 contactid = con.id,
                 AccountId = a.id,
                 Assessment_Performed_Date__c = date.today(),
                 Financial_Review_Result__c = 'Satisfactory - No Action'                                
                 );
       
		insert c;
                
        Financial_Security__c f = new Financial_Security__c (Expiry_Date__c = date.today(),
                                                            Financial_institution__c =inst.id,
                                                            Account__c = a.id,
                                                            Region__c = 'Europe',
                                                            Reasonforrequest__c = 'Default',
                                                            Reception_Date__c = system.today(),
                                                            Security_Type__c= 'Bank Guarantee',
                                                            Reception_Case__c = c.Id);
		insert f;     
                                     
        PageReference pageRef = Page.CaseFinancialSecurities;
        Test.setCurrentPage(pageRef);
                                
        ApexPages.StandardController StanCon = new ApexPages.StandardController(c);
                      
        CaseFinancialSecuritiesCTRL myctrl = new CaseFinancialSecuritiesCTRL(StanCon);
        system.assertEquals(myctrl.fs.size(),1 ); 
        
        Test.stopTest();                   
	}
}