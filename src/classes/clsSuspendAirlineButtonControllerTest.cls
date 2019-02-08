@isTest
private class clsSuspendAirlineButtonControllerTest {

    static testMethod void testMyController() {
        
        PageReference pageRef = Page.SuspendAirlineButton;
        Test.setCurrentPage(pageRef);
  
      
        Id rtIdHq = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
                                
         Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');                      
                                
       Account headQuarter = new Account(name = 'Hq', recordTypeId = rtIdHq);       
      insert  headQuarter;
      
      list<Account> consumers = new list<Account>();
      for(integer i = 0;i<10;i++)
            consumers.add(new Account(name = 'consumer '+i , recordTypeId =rtIdBr,parentId = headQuarter.id));
     insert consumers;
     
     
     list<Services_Rendered__c> services = new list<Services_Rendered__c>();
     for(Account cons: consumers ){ 
        services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'CASS Participation',Services_Rendered_to_Airline__c = cons.id));
        services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'BSP Representation',Services_Rendered_to_Airline__c = cons.id));
        services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'THIS ONE WILL NOT FIRE !!!!',Services_Rendered_to_Airline__c = cons.id));
     
     }
     insert services;
     ApexPages.StandardController controller = new ApexPages.StandardController(headQuarter);   
     
     
     clsSuspendAirlineButtonController testCtrl = new  clsSuspendAirlineButtonController(controller);
     
     PageReference returnPage =  testCtrl.suspendAirline();
     
     system.assertEquals(returnPage.getParameters().get('success'),'true');
   //  system.assertEquals(returnPage.getParameters().get('id'),headQuarter.id);
     
     list<Services_Rendered__c> deactivated = [SELECT Id FROM Services_Rendered__c WHERE Services_Rendered_Status__c  = 'Inactive'];
     list<Services_Rendered__c> active = [SELECT Id FROM Services_Rendered__c WHERE Services_Rendered_Status__c  = 'Active'];
     
     system.assertEquals(20,deactivated.size());
     system.assertEquals(10,active.size());
      

    }
}