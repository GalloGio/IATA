@isTest
private class OneId_Fred_AccountSelection_CTRL_TEST {
	public static Invitation__c invitation {get;set;}
	public static User communityUser {get;set;}
	public static Contact communityUserContact {get;set;}
	public static Account icaoMember {get;set;}

	@testSetup
    static void setup() {

		List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'One_Id_Service_Provider_Config__c' AND DeveloperName = 'Service_Provider'];

        //Create config service object
        One_Id_Service_Provider_Config__c serviceConfig = new One_Id_Service_Provider_Config__c();
        serviceConfig.Customer_Type_Activation__c = 'Aircraft Operator;ICAO Member State';
        serviceConfig.Service_Provider_Name__c = 'FRED';
        serviceConfig.RecordTypeId = recordTypes[0].Id;
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
        

        // Insert an invitation
        invitation = new Invitation__c(AccountId__c=accs[2].Id); // the verifier account inserted previously
        insert invitation;

        // Create a community user
        Id p = [select id from profile where name='ISS Portal (Partner)'].id;
        icaoMember = accs[1] ;
        communityUserContact = new Contact(LastName ='contact1',AccountId = icaoMember.Id);
        insert communityUserContact;
        communityUser = new User(alias = 'contact1', email='contact1@noemail.com',
                emailencodingkey='UTF-8', lastname='contact1', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = communityUserContact.Id,
                License_Cost_Center__c = 'ISF005CH01',
                timezonesidkey='America/Los_Angeles', username='contact1@noemail.com');
        insert communityUser;
        
        
    }

    @isTest 
    static void initPage() {
    	invitation = [SELECT Id, AccountId__c FROM Invitation__c LIMIT 1][0];

	//Boolean isVerifierInvitation, String invitationId
    communityUser = [SELECT Id FROM User WHERE lastname = 'contact1' LIMIT 1][0];
	       OneId_Fred_AccountSelection_CTRL.initParams(false, null);	       
	       OneId_Fred_AccountSelection_CTRL.initParams(true, invitation.Id);
	       system.runAs(communityUser) {
	            OneId_Fred_AccountSelection_CTRL.initParams(false, null);
	       }
	
      
    }
    @isTest 

    static void Base_CTRLTest() {
    	Base_CTRL.loadConfig('FRED');

    	Base_CTRL.loadConfig(null);
    }

	@isTest 
    static void registration() {
    	icaoMember = [SELECT Id, Name, Legal_name__c, Reason_for_creation__c, ownerId, recordtypeid,Category__c, Category_Other_Value__c,BillingCountry, IATA_ISO_Country__c, IATA_ISO_Billing_State__c, IATA_ISO_Shipping_State__c FROM Account WHERE name = 'Air France' LIMIT 1][0];
    	communityUser = [SELECT Id FROM User WHERE lastname = 'contact1' LIMIT 1][0];
    	Contact c = new Contact(LastName ='contact2',AccountId = icaoMember.Id, email='mytest@test.com');
    	// As guest
    	OneId_Fred_AccountSelection_CTRL.registration(icaoMember, c, 'ICAO Member State', true, true, null);
    	system.runAs(communityUser) {
            //Account acc, Contact con, String selectedCustomerType, Boolean isGuest, Boolean createPrimary, Integer userTypeToCreate
       		OneId_Fred_AccountSelection_CTRL.registration(icaoMember, c, 'ICAO Member State', false, false, null);
       }
       OneId_Fred_AccountSelection_CTRL.permissionSetAssignenent(UserInfo.getUserId(), true, 1);
    }

    @isTest 
    static void registrationII() {
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'Canada',ISO_Code__c ='CN' );
        insert isoCountry;
        
        
        Account acc = new Account(
                name= 'Air France', 
                recordTypeId = [SELECT Id FROM RecordType WHERE developerName = 'IATA_Airline'][0].Id,
                IATA_ISO_Country__c = isoCountry.Id,
                Legal_name__c = 'legal',
                BillingCity = 'test',
                BillingCountry = 'Canada',
                BillingStreet = 'some street',
                Category__c = 'Travel Agent'
        );
        insert acc;
       //icaoMember = [SELECT Id, Name, Legal_name__c, Reason_for_creation__c, ownerId, recordtypeid,Category__c, Category_Other_Value__c,BillingCountry, IATA_ISO_Country__c, IATA_ISO_Billing_State__c, IATA_ISO_Shipping_State__c FROM Account WHERE name = 'Air France' LIMIT 1][0];
        communityUser = [SELECT Id FROM User WHERE lastname = 'contact1' LIMIT 1][0];
        Contact c = new Contact(LastName ='contact2',AccountId = acc.Id, email='mytest@test.com');
        // As guest
        
            OneId_Fred_AccountSelection_CTRL.registration(acc, c, 'ICAO Member State', false, true, null);       
        
    }


    @isTest 
    static void search() {
    	
       //String customerType, String userInput
       OneId_Fred_AccountSelection_CTRL.getAccountsByType('Aircraft Operator', 'Air france');
       OneId_Fred_AccountSelection_CTRL.getAccountsByType('ICAO Member State', 'FR');
       OneId_Fred_AccountSelection_CTRL.getCustomerTypeBySP('FRED');
    }
}