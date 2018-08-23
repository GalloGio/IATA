/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This class is the test class for the clsICCSSuspendAirlineButtonController class.
 */

@isTest
private class clsICCSSuspendAirlineBtnControllerTest {

    static testMethod void testMyController() {
        
        PageReference pageRef = Page.ICCSSuspendAirlineButton;
        Test.setCurrentPage(pageRef);
        
        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create a new Product
        Product2 p = new Product2(Name = 'BSP', Family = 'ICCS');
        insert p;
        
        // Create a new ICCS Product Country for this product
        ICCS_Product_Country__c pct = new ICCS_Product_Country__c(Product__c = p.Id, Country__c = country.Id);
        insert pct;
        
        // Create a few ICCS Product Currencies for this ICCS Product Country
        ICCS_Product_Currency__c pcr1 = new ICCS_Product_Currency__c(CurrencyIsoCode = 'USD', ICCS_Product_Country__c = pct.Id, ICCS_Code__c = 'BSPFR1', Status__c = 'Active');
        insert pcr1;
        
        ICCS_Product_Currency__c pcr2 = new ICCS_Product_Currency__c(CurrencyIsoCode = 'EUR', ICCS_Product_Country__c = pct.Id, ICCS_Code__c = 'BSPFR2', Status__c = 'Active');
        insert pcr2;
        
        ICCS_Product_Currency__c pcr3 = new ICCS_Product_Currency__c(CurrencyIsoCode = 'GBP', ICCS_Product_Country__c = pct.Id, ICCS_Code__c = 'BSPFR3', Status__c = 'Active');
        insert pcr3;
        
        // Create an Airline HQ account for it
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        // Create a new ICCS Bank Account for the airline
        ICCS_Bank_Account__c ba = new ICCS_Bank_Account__c(Name = 'QR1234', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd');
        insert ba;
        
        // Create several Product Assignment records
        Product_Assignment__c pa = new Product_Assignment__c(CurrencyIsoCode = 'EUR', Account__c = a.Id, ICCS_Bank_Account__c = ba.Id, ICCS_Product_Currency__c = pcr1.Id, 
        								Status__c = 'Active');
		insert pa;
		
		pa = new Product_Assignment__c(CurrencyIsoCode = 'EUR', Account__c = a.Id, ICCS_Bank_Account__c = ba.Id, ICCS_Product_Currency__c = pcr2.Id, 
        								Status__c = 'Active');
		
		insert pa;
		pa = new Product_Assignment__c(CurrencyIsoCode = 'EUR', Account__c = a.Id, ICCS_Bank_Account__c = ba.Id, ICCS_Product_Currency__c = pcr3.Id, 
        								Status__c = 'Active');
        insert pa;
		
        
		ApexPages.StandardController controller = new ApexPages.StandardController(a);   
		clsICCSSuspendAirlineButtonController testCtrl = new  clsICCSSuspendAirlineButtonController(controller);
		
 		PageReference returnPage =  testCtrl.suspendAirline();
 		
 		system.assertEquals(returnPage.getParameters().get('success'),'true');
 		
 		List<Product_Assignment__c> deactivated = [SELECT Id FROM Product_Assignment__c WHERE Status__c  = 'Inactive'];
 		List<Product_Assignment__c> active = [SELECT Id FROM Product_Assignment__c WHERE Status__c  = 'Active'];
 		
 		system.assertEquals(3,deactivated.size());
 		system.assertEquals(0,active.size());
 		
 		a = [SELECT Id, ICCS_Membership_Status__c FROM Account WHERE Id = :a.Id];
 		system.assertEquals('Inactive', a.ICCS_Membership_Status__c);
      
    }
}