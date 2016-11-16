@isTest
public class ISSP_WS_KAVI_Test {

	@testSetup static void setup_data() {
		insert new ISSP_Kavi_Settings__c(Name = 'CLIENT KEY',Value__c = 'api_test');
		insert new ISSP_Kavi_Settings__c(Name = 'CLIENT SECRET',Value__c = '12345678910abcdef');
		insert new ISSP_Kavi_Settings__c(Name = 'X KAVI SITE',Value__c = 'iata.test.kavi.com');
		insert new ISSP_Kavi_Settings__c(Name = 'ENDPOINT',Value__c = 'https://api-test.kavi.com');
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		Contact contact;
    	system.runAs(thisUser){	
    		for(Integer i=1;i<3;i++){
				Account acc = ISSP_ObjectFactory.createNewAccount();
				acc.Field_Head_Office__c = 'HeadQuarter';  
		            
				insert acc;

				contact = ISSP_ObjectFactory.createNewContact();
		        
		        if(i==2)
		        	contact.Email = 'ytest@gmail.com';

		        contact.AccountId = acc.Id;
		        insert contact;
		         
		        User newUser = new User(alias = 'dsfsdfds', 
			                            email = contact.email, 
			                            emailencodingkey = 'UTF-8', 
			                            firstname = contact.firstName, 
			                            lastname = contact.lastname, 
			                            languagelocalekey = 'en_US', 
			                            localesidkey = 'en_US', 
			                            contactId = contact.Id,
			                            timezonesidkey = 'Asia/Dubai',
			                            username = contact.email+'dfgdf',
			                            PortalRole = 'Manager',
			                            CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
			                            ProfileId = ISSP_Constant.TEST_User_ProfileID,
			                            IsActive = true);
		    	insert newUser;

		    }
    	

         	Portal_Applications__c app = new Portal_Applications__c(Name = 'Standards Setting Workspace'); 
        	insert app;
	
			Portal_Application_Right__c par = new Portal_Application_Right__c();
	        par.Contact__c = contact.Id;
	        par.Portal_Application__c = app.Id;
	        par.Right__c = 'Access Granted';
	        par.kavi_user__c = true;
	        insert par;
	        
         }
	}

	public static testMethod void update_account() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	system.runAs(thisUser){
			List<Account> accountsList = [SELECT Id, BillingCity FROM Account Order By Id];

			if(accountsList.size()>0){
				accountsList[1].BillingCity = 'Haifa';
				update accountsList[1];
			}
		}

	}

	public static testMethod void update_user() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	system.runAs(thisUser){
			List<Contact> contactsList = [SELECT Id, lastname FROM Contact Order By Id];

			if(contactsList.size()>1){
				User theUser = [select Id,ContactId,languagelocalekey,email,firstname,lastname,Title,IsActive,IsPortalEnabled,username from User where ContactId=:contactsList[1].Id ];
				ISSP_WS_KAVI.updateKaviUsers(new Set<String> {contactsList[1].Id}, new LIST<User>{theUser});
			}
		}

	}

	public static testMethod void change_contact_account() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	system.runAs(thisUser){
			List<Account> accountsList = [SELECT Id FROM Account Order By Id];

			List<Contact> contactsList = [SELECT Id, AccountId FROM Contact Order By Id];

			if(contactsList.size()>1){
				for(Account acc:accountsList){
					if(acc.Id != contactsList[1].AccountId){
						contactsList[1].AccountId = acc.Id;
						break;
					}
				}
				update contactsList[1];
			}
		}

	}
		
}