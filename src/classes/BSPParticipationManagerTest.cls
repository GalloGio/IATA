@isTest
private class BSPParticipationManagerTest {
    @testSetup static void setup() {
    	id AgencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;
        IATA_ISO_Country__c country = New IATA_ISO_Country__c(Name='Country1', Enable_Risk_Change_Codes__c=false, iso_code__c='01');
        insert country;
        Account acc = new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=country.Id, Location_Class__c='G', Category__c = 'GSA General Sales Agent', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent');
        insert acc;  
    }
    
    @isTest static void disableBSPParticipationTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();
            id RTId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
            Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = acc.id, recordTypeId = RTId,Status__c = 'Active');   
            insert aa; 
            Agency_Applied_Change_code__c aacc = BSPParticipationManager.disableBSPParticipation(acc.id);
            System.assertEquals('GSD', aacc.Change_Code__c);
        Test.stopTest();
    }

    @isTest static void enableBSPParticipationTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();
            Agency_Applied_Change_code__c aacc = BSPParticipationManager.enableBSPParticipation(acc.id);
            System.assertEquals('GSA', aacc.Change_Code__c);
            aacc = BSPParticipationManager.enableBSPParticipation(acc.id);
            System.assertEquals('GSA', aacc.Change_Code__c);
        Test.stopTest();
    }

    @isTest static void checkEnableOrDisableBSPParticipationTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();
            Boolean aacc = BSPParticipationManager.checkEnableOrDisableBSPParticipation(acc.id);
            System.assertEquals(false, aacc);
            id RTId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
            Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = acc.id, recordTypeId = RTId,Status__c = 'Active');   
            insert aa; 
            aacc = BSPParticipationManager.checkEnableOrDisableBSPParticipation(acc.id);
            System.assertEquals(true, aacc);
        Test.stopTest();
    }

    @isTest static void checkUserPermissionsBSPParticipationTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();		
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(
			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);
		insert testUser;


		System.runAs(testUser) {
            Boolean aacc = BSPParticipationManager.checkUserPermissionsBSPParticipation(acc.id);
            System.assertEquals(false, aacc);
            PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'ManageGSABSPParticipation'];
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = testUser.Id);
            insert psa;
            aacc = BSPParticipationManager.checkUserPermissionsBSPParticipation(acc.id);
            System.assertEquals(true, aacc);
        }
        Test.stopTest();
    }

    
    @isTest static void checkUserPermissionsBSPParticipationAuraTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();		
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(
			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);
		insert testUser;


		System.runAs(testUser) {
            Boolean aacc = BSPParticipationManager.checkUserPermissionsBSPParticipationAura();
            System.assertEquals(false, aacc);
            PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'ManageGSABSPParticipation'];
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = testUser.Id);
            insert psa;
            aacc = BSPParticipationManager.checkUserPermissionsBSPParticipationAura();
            System.assertEquals(true, aacc);
        }
        Test.stopTest();
    }
    
    @isTest static void checkStatusAccountTest() {
        Account acc =[SELECT id, Location_Class__c, Category__c, RecordType.DeveloperName FROM Account LIMIT 1];
        Test.startTest();
            Boolean aacc = BSPParticipationManager.checkStatusAccount(acc.id);
            System.assertEquals(true, aacc);
            acc.Location_Class__c='P';
            update acc;
            aacc = BSPParticipationManager.checkStatusAccount(acc.id);
            System.assertEquals(false, aacc);
        Test.stopTest();
    }

    @isTest static void checkEnableOrDisableBSPParticipationAuraTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();
            Boolean aacc = BSPParticipationManager.checkEnableOrDisableBSPParticipationAura(acc.id);
            System.assertEquals(false, aacc);
            id RTId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
            Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = acc.id, recordTypeId = RTId,Status__c = 'Active');   
            insert aa; 
            aacc = BSPParticipationManager.checkEnableOrDisableBSPParticipationAura(acc.id);
            System.assertEquals(true, aacc);
        Test.stopTest();
    }

    @isTest static void disableBSPParticipationAuraTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();
            id RTId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
            Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = acc.id, recordTypeId = RTId,Status__c = 'Active');   
            insert aa; 
            BSPParticipationManager.disableBSPParticipationAura(acc.id);
        Test.stopTest();
    }

    @isTest static void enableBSPParticipationAuraTest() {
        Account acc =[SELECT id FROM Account LIMIT 1];
        Test.startTest();
            BSPParticipationManager.enableBSPParticipationAura(acc.id);
            BSPParticipationManager.enableBSPParticipationAura(acc.id);
        Test.stopTest();
    }
}