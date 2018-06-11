@isTest
private class OneId_Fred_AddNewUser_CTRL_TEST {
		public static Invitation__c invitation {get;set;}
	public static User communityUser {get;set;}
	public static Contact communityUserContact {get;set;}
	public static Account icaoMember {get;set;}

	@testSetup
    static void setup() {
        //Create config service object
        One_Id_Service_Provider_Config__c serviceConfig = new One_Id_Service_Provider_Config__c();
        serviceConfig.Customer_Type_Activation__c = 'Aircraft Operator;ICAO Member State';
        serviceConfig.Service_Provider_Name__c = 'FRED';
        Insert serviceConfig;
        
        //Create ICAO, Aircraft operators and verifier accounts
        insert new IATA_ISO_Country__c(ISO_Code__c='FR');
        IATA_ISO_Country__c isoCountry = [select id from IATA_ISO_Country__c WHERE ISO_Code__c = 'FR'][0];
        list<Account> accs = new list<Account>{
        	new Account(
        		name= 'Air France', 
        		recordTypeId = [SELECT Id FROM RecordType WHERE developerName = 'IATA_Airline'][0].Id,
        		IATA_ISO_Country__c = isoCountry.Id
        		
        	),
        	new Account(
        		name= 'FR',
        		recordTypeId = [SELECT Id FROM RecordType WHERE developerName = 'ICAO_Member_State'][0].Id,
        		IATA_ISO_Country__c = isoCountry.Id
        		
        	),
        	new Account(
        		name= 'Verifier1',
        		recordTypeId = [SELECT Id FROM RecordType WHERE developerName = 'Verifiers'][0].Id,
        		IATA_ISO_Country__c = isoCountry.Id
        		
        	)
        };
        Insert accs;
        

       
        // Create a community user
        Id p = [select id from profile where name='FRED Portal (Partner)'].id;
        icaoMember = accs[1] ;
        communityUserContact = new Contact(LastName ='contact1',AccountId = icaoMember.Id);
        insert communityUserContact;
        communityUser = new User(alias = 'contact1', email='contact1@noemail.com',
                emailencodingkey='UTF-8', lastname='contact1', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = communityUserContact.Id,
                timezonesidkey='America/Los_Angeles', username='contact1@noemail.com');
        insert communityUser;
        
        
    }

    @isTest 
    static void loadComponent() {
       OneId_Fred_AddNewUser_CTRL.isFredPrimaryUser();
       OneId_Fred_AddNewUser_CTRL.getroles('FRED_SSO');
    }
}