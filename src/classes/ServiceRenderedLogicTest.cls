@isTest
private class ServiceRenderedLogicTest {
    
    static void insertCustomSetting(){
    
        list<Case_Reason_Service__c> lista = new list<Case_Reason_Service__c>{
                                                                     new Case_Reason_Service__c ( name ='myReason',
                                                                                                  service__c ='CASS Participation',
                                                                                                  Provider_Required__c = false
                                                                                                  ),
                                                                     new Case_Reason_Service__c ( name ='myReason2',
                                                                                                  service__c ='BSP Representation',
                                                                                                  Provider_Required__c = false)
                                                                                };
        
          insert lista;                                                                          
    
    }
    
    
   static testMethod void joiningCaseAndStandardTestPositive() {
          insertCustomSetting();
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
                map<string,id> developerNamePerId= TransformationHelper.AccRtNamePerIds();
        
        IATA_ISO_Country__c isoCountry2 = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='dd' );
                insert isoCountry2;
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
        insert myIataIso;
        
            Account Prov = new Account(name = 'provider', billingCity = 'myCity',recordTypeid = developerNamePerId.get('IATA_Airline'),
                                        IATA_ISO_Country__c = myIataIso.id,billingCountry = 'myCountry',IATACode__c = '123');
            insert Prov;
            // nb its a standard one
            Account Cons = new Account(name = 'Consumer',
                                        parentid = prov.id,
                                         billingCity = 'myCity',IATA_ISO_Country__c = isoCountry2.id,
                                         IATACode__c = '123',
                                         billingCountry = 'myCountry', 
                                         recordTypeid = developerNamePerId.get('Standard_Account'));
            insert Cons;
            
            Contact con = new Contact (FirstName='Test', LastName='Name', email='test_joiningCaseAndStandardTestPositive@test.com', AccountId = cons.Id);
            insert con;

                        
            recordType APCaseRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IDFS_Airline_Participation_Process'];
            date dateOFApp = date.newInstance(1980, 5, 14);
                        
            Case c = new Case(CaseArea__c = 'Airline Joining',
                                RecordTypeID =  APCaseRT.id,
                                AccountId = Cons.id,
                                ContactId = con.Id,
                                Provider__c = prov.id,
                                Status = 'Closed',
                                Origin = 'me',
                                Process_Approved__c =dateOFApp,
                                reason1__c = 'myReason'
                                );
            
           
                       insert c;   
           
            Services_Rendered__c servizio = [SELECT Services_Rendered_to_Airline__c,
                                                        Services_Rendered_By__c ,
                                                        Services_Rendered_Type__c ,
                                                        Services_Rendered_Status__c ,
                                                        Source_Case__c  FROM Services_Rendered__c  limit 1];
            
            cons  = [select id, recordtypeid from account where id =: cons.id];

            system.assertEquals(developerNamePerId.get('IATA_Airline_BR'),Cons.recordtypeid);

            // to do review y this was failing
           system.assertEquals(servizio.Services_Rendered_By__c,Prov.ID);
            system.assertEquals(servizio.Services_Rendered_to_Airline__c,c.AccountId);
            system.assertEquals(servizio.Source_Case__c,c.Id);
            system.assertEquals(servizio.Services_Rendered_Status__c,'Active'); 
            
            
    } 
      
   static testMethod void joiningCaseAndStandardTestNegative() {
          insertCustomSetting();
        
                map<string,id> developerNamePerId= TransformationHelper.AccRtNamePerIds();
        
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
        insert myIataIso;
        
            Account Prov = new Account(name = 'provider', billingCity = 'myCity', IATA_ISO_Country__c = myIataIso.id,billingCountry = 'myCountry',IATACode__c = '123');
            insert Prov;
            // nb its a standard one
            Account Cons = new Account(name = 'Consumer', billingCity = 'myCity',IATA_ISO_Country__c = myIataIso.id,IATACode__c = '123',
                                                 billingCountry = 'myCountry', recordTypeid = developerNamePerId.get('Standard_Account'));
            insert Cons;
            
                        
            recordType APCaseRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IDFS_Airline_Participation_Process'];
            date dateOFApp = date.newInstance(1980, 5, 14);
                        
            Case c = new Case(CaseArea__c = 'Airline Joining',
                                RecordTypeID =  APCaseRT.id,
                                AccountId = Cons.id,
                                Provider__c = prov.id,
                                Status = 'Approved',
                                Origin = 'me',
                                Process_Approved__c =dateOFApp,
                                reason1__c = 'myReason'
                                );
              try{
           
                       insert c;   
           
           }catch(Exception e){
                
                 system.assertEquals(e.getMessage().contains(' Errors during the validation of the Accou'),true);
            
           }
            
            
    }
  
   static testMethod void joiningCaseTest() {
          insertCustomSetting();
        
                map<string,id> developerNamePerId= TransformationHelper.AccRtNamePerIds();
        
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
        insert myIataIso;
        
            Account Prov = new Account(name = 'provider', billingCity = 'myCity', IATA_ISO_Country__c = myIataIso.id,billingCountry = 'myCountry',IATACode__c = '123');
            insert Prov;

            Account Cons = new Account(name = 'Consumer', billingCity = 'myCity',IATA_ISO_Country__c = myIataIso.id,IATACode__c = '123',
                                                 billingCountry = 'myCountry', recordTypeid = developerNamePerId.get('IATA_Airline'));
            insert Cons;
            Contact con = new Contact (FirstName='Test', LastName='Name', email='test_joiningCaseAndStandardTestPositive@test.com', AccountId = cons.Id);
            insert con;

                        
            recordType APCaseRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IDFS_Airline_Participation_Process'];
            date dateOFApp = date.newInstance(1980, 5, 14);
                        
            Case c = new Case(CaseArea__c = 'Airline Joining',
                                RecordTypeID =  APCaseRT.id,
                                AccountId = Cons.id,
                                ContactId = con.Id,
                                Provider__c = prov.id,
                                Status = 'Closed',
                                Origin = 'me',
                                Process_Approved__c =dateOFApp,
                                reason1__c = 'myReason'
                                );
           
            insert c;   
            
            Services_Rendered__c servizio = [SELECT Services_Rendered_to_Airline__c,
                                                        Services_Rendered_By__c ,
                                                        Services_Rendered_Type__c ,
                                                        Services_Rendered_Status__c ,
                                                        Source_Case__c  FROM Services_Rendered__c  limit 1];
            
            system.assertEquals(servizio.Services_Rendered_By__c,Cons.ID);
            system.assertEquals(servizio.Services_Rendered_to_Airline__c,c.AccountId);
            system.assertEquals(servizio.Source_Case__c,c.Id);
            system.assertEquals(servizio.Services_Rendered_Status__c,'Active');
            
    }
    
    
    
        static testMethod void leavingCaseTest() {
         TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TransformationHelper.CalculateBusinessHoursAges = true;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;     
             insertCustomSetting();
        
                map<string,id> developerNamePerId= TransformationHelper.AccRtNamePerIds();
        
        
            IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
            insert myIataIso;
            
            Account Prov = new Account(name = 'provider', billingCity = 'myCity',IATACode__c = '123', IATA_ISO_Country__c = myIataIso.id,billingCountry = 'myCountry');
            insert Prov;

            Account Cons = new Account(name = 'Consumer', billingCity = 'myCity',IATA_ISO_Country__c = myIataIso.id,IATACode__c = '123',
                                                 billingCountry = 'myCountry', recordTypeid = developerNamePerId.get('IATA_Airline'));
            insert Cons;
            
            Contact con = new Contact (FirstName='Test', LastName='Name', email='test_joiningCaseAndStandardTestPositive@test.com', AccountId = cons.Id);
            insert con;

                                                                    
            Services_Rendered__c servizio = new Services_Rendered__c(Services_Rendered_to_Airline__c = Cons.id,
                                                                        Services_Rendered_By__c = Cons.id,
                                                                     Services_Rendered_Type__c = 'BSP Representation',
                                                                     Services_Rendered_Status__c = 'Active');
            
            insert servizio; 
                        
            recordType APCaseRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IDFS_Airline_Participation_Process'];
            date dateOFApp = date.newInstance(1980, 5, 14);

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        TransformationHelper.CalculateBusinessHoursAges = false;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;                                       
    test.startTest();
            Case c = new Case(CaseArea__c = 'Airline Leaving',
                                RecordTypeID =  APCaseRT.id,
                                AccountId = Cons.id,
                                ContactId = con.Id,
                                Provider__c = Cons.ID,
                                Status = 'Closed',
                                Origin = 'me',
                                Process_Approved__c =dateOFApp,
                                reason1__C = 'myReason2'
                                );
            insert c;   
            
            Services_Rendered__c serviziodb = [SELECT Services_Rendered_to_Airline__c,
                                                        Services_Rendered_By__c ,
                                                        Services_Rendered_Type__c ,
                                                        Services_Rendered_Status__c ,Inactivation_Airline_Participation_Case__c,
                                                        Source_Case__c  FROM Services_Rendered__c 
                                                    WHERE ID =: servizio.ID];
              test.stopTest();
            system.assertEquals(serviziodb.Inactivation_Airline_Participation_Case__c,c.Id);
            system.assertEquals(serviziodb.Services_Rendered_Status__c,'Inactive');
            
    }
  
    
}