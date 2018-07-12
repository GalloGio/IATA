@isTest
private class AMSHierarchyRoleComparatorTest
{

	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234561',Name='Test Agency 1',Short_Name__c='Test Agency 1');
		Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Name='Test Agency 2',Short_Name__c='Test Agency 2');
		Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234563',Name='Test Agency 3',Short_Name__c='Test Agency 3');

		Account ownerAccount = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234564',Name='OwnerAccount',Short_Name__c='OwnerAccount');
		Account ownerAccount2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234565',Name='OwnerAccount2',Short_Name__c='OwnerAccount2');

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test1@test.com', Financial_Assessment_Contact__c = false);
		//Contact co2 = new Contact(AccountId = a2.id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		//Contact co3 = new Contact(AccountId = a3.id, Firstname = 'teste3', Lastname='test3', Phone = '911111111', MobilePhone = '911111111', Email = 'test3@test.com', Financial_Assessment_Contact__c = false);
		
		List<Account> accountList = new List<Account>{a1,a2,a3,ownerAccount,ownerAccount2};
		
		insert accountList;

		List<Contact> contactList = new List<Contact>{co1};

		insert contactList;
		

		Id ownerRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		Id employeeRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Employee');
		
		AMS_Account_Role__c owner1Acct1 = new AMS_Account_Role__c(Account__c = a1.Id, Contact__c = co1.Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);
		AMS_Account_Role__c owner2Acct1 = new AMS_Account_Role__c(Account__c = a1.Id, Owner_Account__c = ownerAccount.Id, Owner_Sequence__c = 2, Percentage__c = 1, recordTypeId = ownerRecTypeId);

		AMS_Account_Role__c owner1Acct2 = new AMS_Account_Role__c(Account__c = a2.Id, Contact__c = co1.Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);
		AMS_Account_Role__c owner2Acct2 = new AMS_Account_Role__c(Account__c = a2.Id, Owner_Account__c = ownerAccount.Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);

		AMS_Account_Role__c owner1Acct3 = new AMS_Account_Role__c(Account__c = a3.Id, Contact__c = co1.Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);
		AMS_Account_Role__c owner2Acct3 = new AMS_Account_Role__c(Account__c = a3.Id, Owner_Account__c = ownerAccount.Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);
		AMS_Account_Role__c emplo1Acct3 = new AMS_Account_Role__c(Account__c = a3.Id, Contact__c = co1.Id, recordTypeId = employeeRecTypeId);

		//List<AMS_Account_Role__c> ownersList = new List<AMS_Account_Role__c>{owner1Acct1,owner2Acct1,owner1Acct2,owner2Acct2,owner1Acct3,owner2Acct3,emplo1Acct3};
		List<AMS_Account_Role__c> ownersList = new List<AMS_Account_Role__c>{owner1Acct1,owner2Acct1,owner1Acct2,owner2Acct2,owner1Acct3,owner2Acct3};
		insert ownersList;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id, Process__c = AMS_Utils.new_HO);


		insert oscar;


    }

	@isTest
	static void testCorrectHierarchy()
	{
		Test.startTest();

		List<AMS_OSCAR__c> oscars = [SELECT Id FROM AMS_OSCAR__c];



		List<Account> accounts = [SELECT Id from Account where Name like 'Test Agency%'];

		Set<Id> setAccounts = new Set<Id>();

		for(Account acct : accounts)
			setAccounts.add(acct.Id);

		Map<Id,Set<Id>> inputValues = new Map<Id,Set<Id>>();

		inputValues.put(oscars[0].Id, setAccounts);

		System.debug('Starting actual test.');

		boolean result = AMS_HierarchyHelper.checkHierarchyIntegrity(inputValues);

		System.debug('Finished  test.');

		Test.stopTest();
		
		System.assertEquals(result,true);

	}

	@isTest
	static void testIncorrectHierarchy1()
	{
		Id ownerRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		
		Test.startTest();

		List<AMS_OSCAR__c> oscars = [SELECT Id FROM AMS_OSCAR__c];



		List<Account> accounts = [SELECT Id, Name from Account where Name like 'Test Agency%'];

		Set<Id> setAccounts = new Set<Id>();

		for(Account acct : accounts)
			setAccounts.add(acct.Id);

		Map<Id,Set<Id>> inputValues = new Map<Id,Set<Id>>();

		inputValues.put(oscars[0].Id, setAccounts);

		System.debug('Starting actual test.');

		List<Account> accountsOwners = [SELECT Id, Name from Account where Name like 'OwnerAccount2%'];

		if(accountsOwners.isEmpty()){
			System.assertEquals(true,false);
		}

		Account ownerAccount2 = accountsOwners[0];

		Account acct3 = null;

		for(Account a : accounts){
			if(a.name == 'Test Agency 3')
				acct3 = a;
		}

		if(acct3 == null)
			System.assertEquals(true,false);

		AMS_Account_Role__c owner3Acct3 = new AMS_Account_Role__c(Account__c = acct3.Id, Owner_Account__c = ownerAccount2.Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);

		insert owner3Acct3;

		boolean result = AMS_HierarchyHelper.checkHierarchyIntegrity(inputValues);

		System.debug('Finished  test.');

		Test.stopTest();
		
		System.assertEquals(result,false);

	}

	@isTest
	static void testIncorrectHierarchy2()
	{
		Test.startTest();

		List<AMS_OSCAR__c> oscars = [SELECT Id FROM AMS_OSCAR__c];



		List<Account> accounts = [SELECT Id, Name from Account where Name like 'Test Agency%'];

		Set<Id> setAccounts = new Set<Id>();

		for(Account acct : accounts)
			setAccounts.add(acct.Id);

		Map<Id,Set<Id>> inputValues = new Map<Id,Set<Id>>();

		inputValues.put(oscars[0].Id, setAccounts);

		System.debug('Starting actual test.');

		List<Account> accountsOwners = [SELECT Id, Name from Account where Name like 'OwnerAccount2%'];

		if(accountsOwners.isEmpty()){
			System.assertEquals(true,false);
		}

		Account ownerAccount2 = accountsOwners[0];

		Account acct3 = null;

		for(Account a : accounts){
			if(a.name == 'Test Agency 3')
				acct3 = a;
		}

		if(acct3 == null)
			System.assertEquals(true,false);

		Contact co2 = new Contact(AccountId = acct3.id, Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		
		insert co2;

		List<AMS_Account_Role__c> roleLst = [SELECT Id, Contact__c from AMS_Account_Role__c where Account__r.Id = :acct3.Id and Contact__c != null];

		if(roleLst.isEmpty())
			System.assertEquals(true,false);


		AMS_Account_Role__c roleToChange = roleLst.get(0);

		roleToChange.Contact__c = co2.Id;
		update roleToChange;

		boolean result = AMS_HierarchyHelper.checkHierarchyIntegrity(inputValues);

		System.debug('Finished  test.');

		Test.stopTest();
		
		System.assertEquals(result,false);

	}    
}