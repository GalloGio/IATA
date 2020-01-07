@isTest
private class AWW_AgencyManagmentTest2 {

	@isTest static void testAccountGroups() {
		User testUser = New User(
			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = UserInfo.getProfileId(),
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);

		insert testUser;

		PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Local_group_owners'];
		PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = testUser.Id);
		insert psa;

		System.runAs(testUser) {
			Test.startTest();
			IATA_ISO_Country__c country = new IATA_ISO_Country__c(
				Name= 'Portugal',
				ISO_Code__c= 'PT',
				ISO_Code_Numeric__c= 11
			);
			insert country;
			Account wwAccount = new Account(
				Name= 'World Wide Account',
				RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Agency_WW_HQ'),
				IATA_ISO_Country__c= country.Id
			);
			insert wwAccount;

			Account agency = new Account(
				Name= 'Test Ag',
				RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
				IATA_ISO_Country__c= country.Id,
				World_Wide_Account__c= wwAccount.Id,
				Location_Type__c= 'HO',
				Location_Class__c= 'P',
				Sector__c= 'Travel Agent',
				Category__c= 'IATA Passenger Sales Agent',
				IATACode__c= '145362'
			);
			insert agency;

			Contact c = new Contact(
				AccountId= agency.Id,
				FirstName= 'FirstName',
				LastName= 'LastName',
				Title= 'Mr.',
				Email= 'email@test.com',
				Membership_Function__c= 'Training'
			);
			insert c;
			LocalGovernance__c topGroup = new LocalGovernance__c(
				RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Reg_Div_Groups'),
				Country__c= [SELECT Id FROM IATA_ISO_Country__c].Id,
				Active__c= true,
				Division__c= 'FDS',
				Region__c= 'Europe',
				Name= 'Test 1'
			);
			insert topGroup;
			LocalGovernance__c localGroup = new LocalGovernance__c(
				RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Local_Groups'),
				Country__c= [SELECT Id FROM IATA_ISO_Country__c].Id,
				Active__c= true,
				Division__c= 'FDS',
				Region__c= 'Europe',
				Name= 'Test 1',
				AM_Under__c= topGroup.Id
			);
			insert localGroup;
			Participant__c p = new Participant__c(
				Representing__c= agency.Id,
				Local_Group_Type__c= 'CAPJC',
				Local_Governance__c	= localGroup.Id,
				Contact__c= c.Id
			);
			insert p;
			Test.stopTest();

			AWW_AccountGroupsCtrl.getParticipants(wwAccount.Id, true);
		}
	}

}
