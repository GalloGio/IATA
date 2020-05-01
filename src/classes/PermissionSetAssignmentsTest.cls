@isTest
private class PermissionSetAssignmentsTest {
	private static PermissionSets permissionSets = new PermissionSets();
	private static String testPermissionSet1Name = 'Test_Permission_Set_1';
	private static String email = 'abc@def.cominvalid';

	@testSetup static void setup(){
		Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

		UserRole userRole = new UserRole(
			DeveloperName = 'Test_Role',
			Name = 'Test Role'
		);
		insert userRole;

		// create standard user via User domain class
		// passing in ProfileId and UserRoleId
		User standardUser = new User(
			ProfileId = standardUserProfile.Id,
			LastName = 'User',
			Alias = 'TUser',
			Username = 'tuser@def.cominvalid',
			Email='abc@def.cominvalid',
			TimeZoneSidKey = 'Europe/Berlin',
			License_Cost_Center__c = 'XXXX00XX00',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			UserRoleId = userRole.Id
		);

		//need to run as a user to be able to insert mixed DML
		//define contact to initialised running as standard user
		//and used when defining the Partner User (ContactId)
		Contact contact;
		System.runAs(standardUser){
			Account account = new Account(Name = 'Test Account');
			insert account;

			contact = new Contact(AccountId = account.Id, LastName = 'Test Contact Last Name', Email = email);
			insert contact;
		}
		
		//create community user
		UserLicense userLicense = [SELECT Id FROM UserLicense WHERE Name ='Partner Community'];
		Profile profile = [SELECT Id FROM Profile WHERE UserLicenseId = :userLicense.Id Limit 1];
		User partnerUser = new User(			 
			IsActive = true,
			Alias = 'TUser',
			ContactId = contact.Id,
			Email='abc@def.cominvalid', 
			EmailEncodingKey = 'UTF-8',                 
			LanguageLocaleKey = 'en_US',                
			LastName = 'User', 
			License_Cost_Center__c = 'XXXX00XX00',
			LocaleSidKey = 'en_US', 
			ProfileId = profile.Id,
			TimeZoneSidKey = 'Europe/Berlin',
			Username = 'tuser@def.cominvalid'
		);
		insert partnerUser;
		
		permissionSets.records.add(new PermissionSet(Name = testPermissionSet1Name, Label = 'Test Permission Set 1'));
		permissionSets.insertRecords();
	}
	@isTest static void testConstructors(){
		Test.startTest();
		List<PermissionSetAssignment> permissionSetList = new PermissionSetAssignments().records;
		System.assertEquals(0, permissionSetList.size(), 'Empty List<PermissionSetAssignent> not returned');        
		permissionSetList = new PermissionSetAssignments(new List<PermissionSetAssignment>{new PermissionSetAssignment()}).records;
		System.assertEquals(1, permissionSetList.size(), 'List<PermissionSetAssignent> of size 1 not returned');
		Test.stopTest();
	}
	@isTest static void testAssignPermissionSetsToContacts(){
		List<String> permissionSetNameList = new List<String>{testPermissionSet1Name};
		PermissionSetAssignments permissionSetAssignments = new PermissionSetAssignments();
		Contact contact = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

	@isTest static void testConstructors(){
		Test.startTest();
		List<PermissionSetAssignment> permissionSetList = new PermissionSetAssignments().records;
		System.assertEquals(0, permissionSetList.size(), 'Empty List<PermissionSetAssignent> not returned');
		permissionSetList = new PermissionSetAssignments(new List<PermissionSetAssignment>{new PermissionSetAssignment()}).records;
		System.assertEquals(1, permissionSetList.size(), 'List<PermissionSetAssignent> of size 1 not returned');
		Test.stopTest();
	}

	@isTest static void testAssignPermissionSetsToContacts(){
		List<String> permissionSetNameList = new List<String>{testPermissionSet1Name};
		PermissionSetAssignments permissionSetAssignments = new PermissionSetAssignments();
		Contact contact = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

		Test.startTest();
		permissionSetAssignments.assignPermissionSetsToContacts(permissionSetNameList, new List<Contact>{contact});
		Test.stopTest();

		User user = [SELECT Id FROM User WHERE ContactId = :contact.Id LIMIT 1];
		PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermissionSet1Name LIMIT 1];
		List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :user.Id AND PermissionSetId = :permissionSet.Id];
		System.assertEquals(1, permissionSetAssignmentList.size(), 'PermissionSet Assignment List size not equal to 1.');
	}
	@isTest static void testUnassignPermissionSetsToContacts(){
		List<String> permissionSetNameList = new List<String>{testPermissionSet1Name};
		PermissionSetAssignments permissionSetAssignments = new PermissionSetAssignments();
		Contact contact = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

		Test.startTest();
		permissionSetAssignments.assignPermissionSetsToContacts(permissionSetNameList, new List<Contact>{contact});
		permissionSetAssignments.unAssignPermissionSetsToContacts(permissionSetNameList, new List<Contact>{contact});
		Test.stopTest();
		
		User user = [SELECT Id FROM User WHERE ContactId = :contact.Id LIMIT 1];
		PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermissionSet1Name LIMIT 1];
		List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :user.Id AND PermissionSetId = :permissionSet.Id];
		System.assertEquals(0, permissionSetAssignmentList.size(), 'PermissionSet Assignment List size not equal to 0.');
	}
	@isTest static void testAddModifyPermissionSetsToContacts(){
		Contact contact = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
		PermissionSetAssignments.PermissionSetAssignmentRequest permissionSetAssignmentRequest = new PermissionSetAssignments.PermissionSetAssignmentRequest();
		permissionSetAssignmentRequest.operation = 'Add';
		permissionSetAssignmentRequest.inputPermissionSetName = testPermissionSet1Name;
		permissionSetAssignmentRequest.inputContact = contact;

		Test.startTest();
		PermissionSetAssignments.modifyPermissionSetsToContacts(new List<PermissionSetAssignments.PermissionSetAssignmentRequest>{permissionSetAssignmentRequest});
		Test.stopTest();
		
		User user = [SELECT Id FROM User WHERE ContactId = :contact.Id LIMIT 1];
		PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermissionSet1Name LIMIT 1];
		List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :user.Id AND PermissionSetId = :permissionSet.Id];
		System.assertEquals(1,permissionSetAssignmentList.size(), 'Permission set not assigned as expected.');
	}
	@isTest static void testRemoveModifyPermissionSetsToContacts(){
		Contact contact = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
		PermissionSetAssignments.PermissionSetAssignmentRequest permissionSetAssignmentRequest = new PermissionSetAssignments.PermissionSetAssignmentRequest();
		permissionSetAssignmentRequest.operation = 'Remove';
		permissionSetAssignmentRequest.inputPermissionSetName = testPermissionSet1Name;
		permissionSetAssignmentRequest.inputContact = contact;
		
		User user = [SELECT Id FROM User WHERE ContactId = :contact.Id LIMIT 1];
		PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :testPermissionSet1Name LIMIT 1];
		insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionSet.Id);
		
		List<PermissionSetAssignment> permissionSetAssignmentList1 = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :user.Id AND PermissionSetId = :permissionSet.Id];
		System.assertEquals(1, permissionSetAssignmentList1.size(), 'PermissonSetAssignment not inserted correctly.');

		Test.startTest();
		PermissionSetAssignments.modifyPermissionSetsToContacts(new List<PermissionSetAssignments.PermissionSetAssignmentRequest>{permissionSetAssignmentRequest});
		Test.stopTest();

		List<PermissionSetAssignment> permissionSetAssignmentList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :user.Id AND PermissionSetId = :permissionSet.Id];
		System.assertEquals(0, permissionSetAssignmentList.size(), 'Permission set not unassigned as expected.');
	}
}