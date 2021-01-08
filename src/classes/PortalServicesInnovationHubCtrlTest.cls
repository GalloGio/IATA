@isTest
public class PortalServicesInnovationHubCtrlTest {
    
    @TestSetup
	static void testSetup(){
		Id accountAirlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Id iHubRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Innovation_Hub');
        Id iHubDetailProviderRT = RecordTypeSingleton.getInstance().getRecordTypeId('IH_Account_Role_Detail__c', 'Provider');
        Id iHubDetailConsumerRT = RecordTypeSingleton.getInstance().getRecordTypeId('IH_Account_Role_Detail__c', 'Consumer');
        Id iHubDetailProAndConsRT = RecordTypeSingleton.getInstance().getRecordTypeId('IH_Account_Role_Detail__c', 'Consumer_and_Provider');
       
		Account newAcc1 = new Account(Name='Account Test Airline 1', Site = 'Site Test 1', Sector__c = 'Airline',IATACode__c = '123', RecordTypeId = accountAirlineRT);
		Account newAcc2 = new Account(Name='Account Test Airline 2', Site = 'Site Test 2', Sector__c = 'Airline',IATACode__c = '1234', RecordTypeId = accountAirlineRT);
        Account newAcc3 = new Account(Name='Account Test Airline 3', Site = 'Site Test 3', Sector__c = 'Airline',IATACode__c = '12345', RecordTypeId = accountAirlineRT);
        insert new List<Account>{newAcc1, newAcc2,newAcc3};
        
        Contact newCon1 = new Contact(AccountId = newAcc1.Id, FirstName = 'John', LastName = 'Doe', Email = 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon2 = new Contact(AccountId = newAcc2.Id, FirstName = 'John 1', LastName = 'Doe 1', Email = 'testemailNEW@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon3 = new Contact(AccountId = newAcc3.Id, FirstName = 'Jane', LastName = 'Doe 1', Email = 'janedoetest@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		insert new List<Contact>{newCon1, newCon2,newCon3};
        
        Account_Role__c ar1 = new Account_Role__c(Account__c = newAcc1.Id,Account_Name__c = 'Test Role 1', RecordTypeId = iHubRT);
        Account_Role__c ar2 = new Account_Role__c(Account__c = newAcc2.Id,Account_Name__c = 'Test Role 2', RecordTypeId = iHubRT);
        Account_Role__c ar3 = new Account_Role__c(Account__c = newAcc3.Id,Account_Name__c = 'Test Role 3', RecordTypeId = iHubRT);
        insert new List<Account_Role__c>{ar1, ar2,ar3};
        
        IH_Account_Role_Detail__c ihubDetail1 = new IH_Account_Role_Detail__c(Account_Role__c = ar1.Id,Company_name__c = 'Test Provider',
                                                                              Funding_Stage__c = 'Seed',Focus_Areas__c = 'Marketing',
                                                                              Tags_of_categories__c = 'Health',Technology__c = 'IOT',
                                                                              Logo_File_Id__c = 'test', Published__c = true,
                                                                              RecordTypeId = iHubDetailProviderRT);  
        IH_Account_Role_Detail__c ihubDetail2 = new IH_Account_Role_Detail__c(Account_Role__c = ar2.Id,Company_name__c = 'Test Consumer',
                                                                              Published__c = true, RecordTypeId = iHubDetailConsumerRT);  
        IH_Account_Role_Detail__c ihubDetail3 = new IH_Account_Role_Detail__c(Account_Role__c = ar3.Id,Company_name__c = 'Test Consumer & Provider',
                                                                              Published__c = true, RecordTypeId = iHubDetailProAndConsRT);  

        insert new List<IH_Account_Role_Detail__c>{ihubDetail1, ihubDetail2,ihubDetail3};
	}
    
    @isTest 
    static void testTabs() {
        List<Contact> contacts = [SELECT AccountId, FirstName,LastName, Email, User_Portal_Status__c, Status__c FROM Contact];
        System.debug('***** ' + contacts.size());
        Test.startTest();
        
        User newUser1 = ISSP_ObjectFactory.createPortalUser(contacts[0]);
        User newUser2 = ISSP_ObjectFactory.createPortalUser(contacts[1]);
        User newUser3 = ISSP_ObjectFactory.createPortalUser(contacts[2]);
            
        System.runAs(newUser1){
        	List<PortalServicesInnovationHubCtrl.TabWrapper> tw1 = PortalServicesInnovationHubCtrl.getInnovationHubTabs();
        	System.assertEquals(tw1.size(),2);
        }
        
        System.runAs(newUser2){
        	List<PortalServicesInnovationHubCtrl.TabWrapper> tw2 = PortalServicesInnovationHubCtrl.getInnovationHubTabs();
        	System.assertEquals(tw2.size(),0);
        }
        
        System.runAs(newUser3){
        	List<PortalServicesInnovationHubCtrl.TabWrapper> tw3 = PortalServicesInnovationHubCtrl.getInnovationHubTabs();
        	System.assertEquals(tw3.size(),0);
        }
        
        //List<PortalServicesInnovationHubCtrl.TabWrapper> tw4 = PortalServicesInnovationHubCtrl.getInnovationHubTabs();
        //System.assertEquals(tw4.size(),0);
        Test.stopTest();	
	}
    
    @isTest 
    static void testProviderCards() {
        IH_Account_Role_Detail__c provider = [SELECT Id,Company_name__c FROM IH_Account_Role_Detail__c WHERE Company_name__c = 'Test Provider' LIMIT 1];
        Test.startTest();
        //PortalWrapperClasses.ListCardsAndPropertiesWrapper pw1 = PortalServicesInnovationHubCtrl.getProviderPropertiesAndCardsList();
        //PortalWrapperClasses.ListCardsAndPropertiesWrapper pw2 = PortalServicesInnovationHubCtrl.getProviderPropertiesAndEditCardsList();     
		Test.stopTest();
	}
    
    @isTest 
    static void testSearchProviders() {
        PortalServicesInnovationHubCtrl.filterWrapper fw = new PortalServicesInnovationHubCtrl.filterWrapper();       
        fw.fundingStage = 'Seed';
        fw.technologies = new List<String>{'IOT'};
        fw.focusAreas = new List<String>{'Marketing'};
        fw.categories = new List<String>{'Health'};

        String filters = JSON.serialize(fw);
        
        Test.startTest();
        List<PortalServicesInnovationHubCtrl.ProviderWrapper> p1 = PortalServicesInnovationHubCtrl.getLstProviders('Test',filters); 
        System.assertEquals(p1.size(),1);
		Test.stopTest();
	}

}