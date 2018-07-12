@isTest
private class AMS_AddressTriggerHandlerTest {
	
	@testSetup static void setup(){
	
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account acc1 = new Account(Status__c = 'Approved', Reason_for_creation__c = 'Headquarter is missing', Name='Test1 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
        Account acc2 = new Account(Status__c = 'Approved', Reason_for_creation__c = 'Headquarter is missing', Name='Test2 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345679', AIMS_ID__c = '12345679', Source_System__c = 'AIMS2');
        Account acc3 = new Account(Status__c = 'Approved', Reason_for_creation__c = 'Headquarter is missing', Name='Test2 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345670', AIMS_ID__c = '12345670', Source_System__c = 'AIMS2');

        insert new List<Account>{acc1,acc2,acc3};



	}

	@isTest static void insertCorrectAddress1() {


		List<Account> accounts = [SELECT Id from Account];

		Account acct1 = accounts.get(0);
		Account acct2 = accounts.get(1);

		Test.startTest();

		AMS_Address__c addr1 = new AMS_Address__c(Account__c = acct1.Id, Address_Type__c = 'Primary;Billing');
		AMS_Address__c addr2 = new AMS_Address__c(Account__c = acct1.Id, Address_Type__c = 'Mailing');
		AMS_Address__c addr3 = new AMS_Address__c(Account__c = acct1.Id, Address_Type__c = 'Registred;Old');

		AMS_Address__c addr4 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Primary;Billing');
		AMS_Address__c addr5 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Mailing');
		AMS_Address__c addr6 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Registred;Old');
		AMS_Address__c addr7 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Sales Office');

		Insert new List<AMS_Address__c>{addr1,addr2,addr3,addr4,addr5,addr6,addr7};

		Test.stopTest();
	}
	
	@isTest static void insertIncorrectAddress1() {
		
		boolean exceptionDone = false;

		List<Account> accounts = [SELECT Id from Account];

		Account acct1 = accounts.get(0);
		Account acct2 = accounts.get(1);
		Account acct3 = accounts.get(2);

		Test.startTest();

		AMS_Address__c addr1 = new AMS_Address__c(Account__c = acct1.Id, Address_Type__c = 'Primary;Billing');
		AMS_Address__c addr2 = new AMS_Address__c(Account__c = acct1.Id, Address_Type__c = 'Mailing');
		AMS_Address__c addr3 = new AMS_Address__c(Account__c = acct1.Id, Address_Type__c = 'Registred;Old');

		AMS_Address__c addr4 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Primary;Billing');
		AMS_Address__c addr5 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Mailing');
		AMS_Address__c addr6 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Registred;Old');
		AMS_Address__c addr7 = new AMS_Address__c(Account__c = acct2.Id, Address_Type__c = 'Sales Office');

		AMS_Address__c addr8 = new AMS_Address__c(Account__c = acct3.Id, Address_Type__c = 'Primary;Billing');
		AMS_Address__c addr9 = new AMS_Address__c(Account__c = acct3.Id, Address_Type__c = 'Mailing;Old');
		AMS_Address__c addr10 = new AMS_Address__c(Account__c = acct3.Id, Address_Type__c = 'Registred;Old');

		try{

			Insert new List<AMS_Address__c>{addr1,addr2,addr3,addr4,addr5,addr6,addr7,addr8,addr9,addr10};
		}
		catch(Exception e){
			exceptionDone = true;
			System.assertEquals(true,e.getMessage().contains('in the Address to insert/update is duplicated in the Account Addresses'));

		}

		System.assertEquals(true, exceptionDone);

		exceptionDone = false;

		Insert new List<AMS_Address__c>{addr1,addr2,addr3,addr4,addr5,addr6,addr7,addr8,addr9};


		List<AMS_Address__c> addrsToUpdate = [SELECT Id, Account__c, Address_Type__c from AMS_Address__c where Account__c = :acct1.Id and Address_Type__c = 'Registred;Old'];

		if(addrsToUpdate.isEmpty())
			System.assertEquals(true,false);

		AMS_Address__c addrToUpdate1 = addrsToUpdate.get(0);

		addrToUpdate1.Address_Type__c = 'Registred;Old;Mailing';

		try{

			update addrToUpdate1;
		}
		catch(Exception e){
			
			exceptionDone = true;
			System.assertEquals(true,e.getMessage().contains('in the Address to insert/update is duplicated in the Account Addresses'));

		}

		System.assertEquals(true, exceptionDone);

		List<AMS_Address__c> totalAddresses = [SELECT Id from AMS_Address__c];

		System.assertEquals(9, totalAddresses.size());

		addrsToUpdate = [SELECT Id, Account__c, Address_Type__c from AMS_Address__c where Account__c =:acct1.Id and Address_Type__c = 'Registred;Old'];

		if(addrsToUpdate.isEmpty())
			System.assertEquals(true,false);

		addrToUpdate1 = addrsToUpdate.get(0);

		addrToUpdate1.Address_Type__c = 'Registred';

		update addrToUpdate1;


		Test.stopTest();

	}
	
}