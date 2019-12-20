@isTest
public class trgAIMSAccountBeforeUpdate_Test{

	// Test Method #1
	static testmethod void UpdateAccountTest1(){



		Account account1 = new Account();

		account1.RecordTypeId = '012w0000000QBMb';
		account1.Is_AIMS_Account__c = True;
		account1.name = 'Test Account AIMS BEFORE UPDATE';
		account1.BillingCountry = 'Canada';
		account1.BillingCity = 'Montreal';
		account1.BillingState = 'Quebec';
		account1.IATACode__c = '123456';
		account1.Email__c = 'test1@test.com';
		account1.Is_AIMS_Account__c = true;
		account1.Reason_for_creation__c = 'apex test';

		insert account1;



		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com.preprod',
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = p.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='testrunas@testorg.com.preprod',License_Cost_Center__c='ISF005CH01');
		u.Profile = p;
		test.startTest();
		System.runAs(u) {
			try{
				account1.TradeName__c = 'a';
				account1.BillingStreet = 'b';
				account1.BillingState = 'c';
				account1.ShippingCity = 'd';
				account1.Accreditation_date__c = Date.today();
				account1.Description = 'e';
				account1.BillingPostalCode = 'f';
				account1.Source_System__c = 'g';
				account1.Fax = 'h';
				account1.Rating = 'i';
				account1.Name = 'j';
				account1.Phone = 'k';
				account1.IATACode__c = 'l';
				account1.ShippingStreet = 'm';
				account1.Location_Type__c = 'n';
				account1.AIMS_ID__c = 'o';
				account1.Type = 'p';
				account1.Status__c = 'q';
				account1.ShippingCountry = 'r';
				account1.VAT_Number_2__c = 's';
				account1.VAT_Number__c = 't';
				account1.ShippingPostalCode = 'u';
				account1.Website = 'v';
				account1.BillingCountry = 'w';
				account1.Email__c = 'test2@test.com';
				account1.Expiry_Date__c = Date.today().addYears(1);
				account1.Site = 'z';
				account1.BillingCity = 'aa';
				account1.Financial_Year_End__c = 'bb';
				account1.Fin_statements_submission_deadline__c = 'cc';
				account1.Short_Name__c = 'dd';
				account1.Accumulated_Irregularities__c = 2;
				//account1.Is_AIMS_Account__c = false;

				update account1;
			}
			catch (DMLException e){
				system.assert(e.getMessage().contains('Update failed'), e.getMessage());
			}
			test.stopTest();
	   }

	}
}
