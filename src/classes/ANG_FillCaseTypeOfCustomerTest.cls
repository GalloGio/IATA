@isTest
public class ANG_FillCaseTypeOfCustomerTest {

    static testmethod void ANG_FillCaseTypeOfCustomerTestCase1() {
      
      	Test.startTest();
		
        Account a = new Account(Name = 'test1', location_type__c = 'SA');
		insert a;
        
        List<String> result = ANG_FillCaseTypeOfCustomer.fillCaseTypeOfCustomer(new List<Id>{a.id});
		System.assertEquals('IATA Travel Agent', result[0]);
    	Test.stopTest();
      	
    }

    static testmethod void ANG_FillCaseTypeOfCustomerTestCase2() {
      
      	Test.startTest();

		Account a = new Account(Name = 'test2', location_type__c = 'HO' , category__c = 'GSSA Cargo');
		insert a;        
        
        List<String> result = ANG_FillCaseTypeOfCustomer.fillCaseTypeOfCustomer(new List<Id>{a.id});
		System.assertEquals('GSSA Cargo', result[0]);
    	Test.stopTest();
      	
    }
}