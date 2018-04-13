/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PlatformEvents_Helper_Test {

    static testMethod void Test_Platform_Event_On_Account() {
        Account a = new Account(Name='My Account');
        
        test.startTest();
        	insert a;
        
	        a.IataCode__c = '123';
        
        	update a;
        
        	delete a;

        	undelete a;

        test.stopTest();
    }
    
    
    static testMethod void Test_Platform_Event_On_Contact() {
    	Account acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        Contact a = new Contact(FirstName='test', LastName='test', AccountId=acc1.Id,
			Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
        
        test.startTest();
        	insert a;
        
	        a.phone = '123123132';
        
        	update a;
        
        	delete a;

        	undelete a;

        test.stopTest();
    }
    
    
    static testMethod void Test_LogCreation() {
    	system.assertEquals(0, [select id from ISSP_Web_Service_Log__c].size());
    	list<ISSP_Web_Service_Log__c> lsLogs = new list<ISSP_Web_Service_Log__c>();
    	test.startTest();
    	lsLogs.add(PlatformEvents_Helper.CreateLog('a','b','c','d','e'));
    	
    	insert lsLogs;
    	test.stopTest();
    	system.assertEquals(1, [select id from ISSP_Web_Service_Log__c].size());
    }
}