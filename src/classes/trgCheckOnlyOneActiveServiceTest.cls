@isTest
private class trgCheckOnlyOneActiveServiceTest {

  private static String testServiceName = new list<String>(AirlineSuspensionChildCaseCreationBatch.SET_VALID_PARITICIPATIONS).get(0);

  static testMethod void runPositive() {
 
       ID recTypeBranCons = [SELECT ID FROM Recordtype where developername = 'IATA_Airline_BR'  and sobjecttype ='Account'][0].id;
       ID recTypeHqSer  =  [SELECT ID FROM Recordtype where developername = 'IATA_Airline'  and sobjecttype ='Account'][0].id; 
      
      
       account HQ= new account(
                               recordtypeId = recTypeHqSer  ,
                               name = 'HQ',IATACODE__C = 'ASDASD'
                               );         
       insert HQ;
       
       
       account HQ2= new account(
                               recordtypeId = recTypeHqSer  ,
                               name = 'HQ',IATACODE__C = 'ASDASD'
                               );         
       insert HQ2;
       
       account Consumer = new account(
                               ParentId = HQ.id,
                               recordtypeId = recTypeBranCons ,
                               name = 'CONSUMER',IATACODE__C = 'ASASDASD'
                               );         
       insert Consumer ;
       
       Services_Rendered__c ser1 = new Services_Rendered__c(
                                                               Services_Rendered_to_Airline__c = Consumer.id,
                                                               Services_Rendered_By__c =HQ.id ,
                                                               Services_Rendered_Status__c = 'Active',
                                                               Services_Rendered_Type__c = testServiceName
                                                                );
      insert ser1;
      
      
      Services_Rendered__c ser2 = new Services_Rendered__c(
                                                               Services_Rendered_to_Airline__c = Consumer.id,
                                                               Services_Rendered_By__c =HQ2.id ,
                                                               Services_Rendered_Status__c = 'Active',
                                                               Services_Rendered_Type__c = testServiceName);
    
     
      insert ser2;
      
      list<Services_Rendered__c> listRetrieved = [SELECT id FROM Services_Rendered__c];
      
      system.assertEquals(2,listRetrieved.size());
    
    }
    
  static testMethod void runNegativeTestCases2() {
 
       ID recTypeBranCons = [SELECT ID FROM Recordtype where developername = 'IATA_Airline_BR'  and sobjecttype ='Account'][0].id;
       ID recTypeHqSer  =  [SELECT ID FROM Recordtype where developername = 'IATA_Airline'  and sobjecttype ='Account'][0].id; 
      
      
       account HQ= new account(
                               recordtypeId = recTypeHqSer  ,
                               name = 'HQ',IATACODE__C = 'ASDASD'
                               );         
       insert HQ;
       
       
       account Consumer = new account(
                               ParentId = HQ.id,
                               recordtypeId = recTypeBranCons ,
                               name = 'CONSUMER',IATACODE__C = 'ASDSDASD'
                               );         
       insert Consumer ;
       
       list<Services_Rendered__c> lista = new list<Services_Rendered__c>();
       Services_Rendered__c ser1 = new Services_Rendered__c(
                                                               Services_Rendered_to_Airline__c = Consumer.id,
                                                               Services_Rendered_By__c =HQ.id ,
                                                               Services_Rendered_Status__c = 'Active',
                                                               Services_Rendered_Type__c = testServiceName
                                                                );
      lista.add(ser1);
      
      
      Services_Rendered__c ser2 = new Services_Rendered__c(
                                                               Services_Rendered_to_Airline__c = Consumer.id,
                                                               Services_Rendered_By__c =HQ.id ,
                                                               Services_Rendered_Status__c = 'Active',
                                                               Services_Rendered_Type__c = testServiceName
      
                                                                );
                                                                
                                                                
                                                                lista.add(ser2);
     try {
     
      insert lista;
      
      list<Services_Rendered__c> listRetrieved = [SELECT id FROM Services_Rendered__c];
      
      system.assertEquals(13123123,listRetrieved.size());}catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('The data you are trying to insert has duplicates') ? true : false;            
            System.AssertEquals(expectedExceptionThrown, true);            
            }       
    
    }  
    
     static testMethod void runNegativeTestCases() {
 
       ID recTypeBranCons = [SELECT ID FROM Recordtype where developername = 'IATA_Airline_BR'  and sobjecttype ='Account'][0].id;
       ID recTypeHqSer  =  [SELECT ID FROM Recordtype where developername = 'IATA_Airline'  and sobjecttype ='Account'][0].id; 
      
      
       account HQ= new account(
                               recordtypeId = recTypeHqSer  ,
                               name = 'HQ',IATACODE__C = 'ASDASD'
                               );         
       insert HQ;
       
       
 
       
       account Consumer = new account(
                               ParentId = HQ.id,
                               recordtypeId = recTypeBranCons ,
                               name = 'CONSUMER',IATACODE__C = 'ASASDASD'
                               );         
       insert Consumer ;
       
       Services_Rendered__c ser1 = new Services_Rendered__c(
                                                               Services_Rendered_to_Airline__c = Consumer.id,
                                                               Services_Rendered_By__c =HQ.id ,
                                                               Services_Rendered_Status__c = 'Active',
                                                               Services_Rendered_Type__c = testServiceName
                                                                );
      insert ser1;
      
      
      Services_Rendered__c ser2 = new Services_Rendered__c(
                                                               Services_Rendered_to_Airline__c = Consumer.id,
                                                               Services_Rendered_By__c =HQ.id ,
                                                               Services_Rendered_Status__c = 'Active',
                                                               Services_Rendered_Type__c = testServiceName
                                                                );
     try {
     
      insert ser2;
      
      list<Services_Rendered__c> listRetrieved = [SELECT id FROM Services_Rendered__c];
      
      system.assertEquals(12312311,listRetrieved.size());
      
      }catch(Exception e){

            Boolean expectedExceptionThrown =  e.getMessage().contains('Error:Service already exists!') ? true : false;            
            System.AssertEquals(expectedExceptionThrown, true);            
            }       
    
    }
   
  }