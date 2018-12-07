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
private class AddCampaignMemberControllerTest {


    static testMethod void myUnitTest() {
		// Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create a new Product
        Product2 p = new Product2(Name = 'BSP', Family = 'ICCS');
        insert p;
        
        // Create a new ICCS Product Country for this product
        ICCS_Product_Country__c pct = new ICCS_Product_Country__c(Product__c = p.Id, Country__c = country.Id);
        insert pct;
        
        // Create a new ICCS Product Currency for this ICCS Product Country
        ICCS_Product_Currency__c pcr = new ICCS_Product_Currency__c(CurrencyIsoCode = 'USD', ICCS_Product_Country__c = pct.Id, ICCS_Code__c = 'BSPFR1', Status__c = 'Active');
        insert pcr;
        
        // Create an Airline HQ account & a contact for it
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        
        // Create a new ICCS Bank Account for the airline
        ICCS_Bank_Account__c ba = new ICCS_Bank_Account__c(Name = 'QR1234', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd');
        insert ba;
        
        
        //Create a new Campaign
        /*
        List<User> us = [SELECT Id FROM User  WHERE (Profile.Name = 'FDS ICCS Administrator' OR Profile.Name = 'FDS ICCS User') AND isActive=true limit 1];
        Campaign cmp = new Campaign(Name='Campaign',isActive=true);
        if(us.size()>0)
	        system.runAs(us[0]){
		        insert cmp;
	        }
        else
        	insert cmp;
       	*/
       	Campaign cmp = new Campaign(Name='Campaign',isActive=true);
       	insert cmp;
        	
        Product_Assignment__c pa = new Product_Assignment__c(Account__c=a.id,ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba.id);
        insert pa;
        
        
        //////////////////////////
        test.startTest();
        //initialize the controller
        AddCampaignMemberController acm = new AddCampaignMemberController(new ApexPages.StandardController(pcr));
        acm.getCampaignPicklistValues();
        
        //if no campaign is selected it won't add any contact
        acm.AddMembers();
        system.assertEquals(0,[SELECT Id FROM CampaignMember WHERE CampaignId = :cmp.id].size());
        
        //I add a campaign but there are no contacts
        acm.CampaignId = cmp.id;
        acm.AddMembers(); 
		system.assertEquals(0,[SELECT Id FROM CampaignMember WHERE CampaignId = :cmp.id].size());
        
        //everything is ok so it should add the contact as a campaign member
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id, ICCS_Contact__c = true);
        insert c;
        acm.AddMembers();
        //if(us.size()>0) 

		//system.assertEquals(1,[SELECT Id FROM CampaignMember WHERE CampaignId = :cmp.id].size());
        
        // if i add it again there should not be duplicates
        acm.AddMembers();
        //if(us.size()>0) 
		//system.assertEquals(1,[SELECT Id FROM CampaignMember WHERE CampaignId = :cmp.id].size());
        
        test.stopTest();
    }
}