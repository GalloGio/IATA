@isTest
private class trgCase_BeforeDeleteTest {
	   
	   static testMethod void myUnitTest() {
	   	 
	   	 
	   	 ID hqrt =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
       ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review'); 
         
       IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
            insert isoCountry;
            
       Account a = new Account( name ='IFAP ACCT',
                    industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');
       insert a;
       
       Contact con =new contact(lastname = 'pluto' ,
                    firstname = 'Name',
                    phone = '123',
                    accountid = a.id,
                    Financial_Assessment_Contact__c = true);
       insert con;
                   
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
	   	
	  Database.DeleteResult RESULT = DATABASE.DElEtE(c,false);
	  
	  string errorMessage = Result.getErrors()[0].message;
	  
		system.assertEquals(errorMessage,'Deleting an IFAP case is not allowed' );	  	
	   	
	 }

}