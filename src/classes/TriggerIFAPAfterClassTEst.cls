@istest
private class TriggerIFAPAfterClassTEst {
    
    
     static testMethod void AssessmentPerformedTest() {
            
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
            Test.startTest();
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
            
            a = [SELECT ID,Assessment_Performed_Date__c ,
                        Financial_Review_Result__c
                 FROM Account 
                 WHERE Id =: a.Id limit 1];                                                       
                              
            system.assertEquals(a.Financial_Review_Result__c,c.Financial_Review_Result__c);                   
            system.assertEquals(a.Assessment_Performed_Date__c,c.Assessment_Performed_Date__c); 
            
            
            c.Assessment_Performed_Date__c = date.today().addDays(1);
            Test.stopTest();
            update c;
            
            a = [SELECT ID,Assessment_Performed_Date__c ,
                        Financial_Review_Result__c
                 FROM Account 
                 WHERE Id =: a.Id limit 1];     
                 
                 
            system.assertEquals(a.Assessment_Performed_Date__c,date.today().addDays(1));                      
                          
     
     }
     
     
     

}