/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class ParticipantHelperTest {

	private static final Id RECORDTYPE_HQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	private static final Id RECORDTYPE_BR =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
	private static final Id RECORDTYPE_AG =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
	private static final Id RECORDTYPE_LOCAL_GROUP =  RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Local_Groups');

	private static User adminUser;
	private static IATA_ISO_Country__c country1;
	private static IATA_ISO_Country__c country2;
	private static Account hqAccount;
	private static Contact contact;

	@TestSetup
	static void makeData(){
		List<User> users = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1 ];
		System.assert(!users.isEmpty());
		adminuser = users[0];

		PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Local_group_owners'];
		PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = adminuser.Id);
		insert psa;

		system.runAs(adminuser){
			List<IATA_ISO_Country__c>isocs = new List<IATA_ISO_Country__c>();
			isocs.add(new IATA_ISO_Country__c(
				Name='Italy', Country_Manager__c=adminuser.id, ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy'
			));
			isocs.add(new IATA_ISO_Country__c(
				Name='France', Country_Manager__c=adminuser.id, ISO_Code__c='FR', Region__c='Europe', ISS_Office_Location__c='France'
			));
			insert isocs;

			hqAccount = new Account(Name='Lufthansa', RecordTypeId = RECORDTYPE_HQ, IATA_ISO_Country__c = isocs[0].Id);
			insert hqAccount;
			Account branch = new Account(Name='Lufthansa', RecordTypeId = RECORDTYPE_BR, IATA_ISO_Country__c = isocs[0].Id, ParentId=hqAccount.id);
			Account agency = new Account(Name='Lufthansa', RecordTypeId = RECORDTYPE_AG, IATA_ISO_Country__c = isocs[0].Id, ParentId=hqAccount.id);
			insert new list<Account>{branch, agency};

			contact = new Contact(AccountId=agency.id, FirstName='Complete', LastName='Contact', Email='myCompany@test.com', Title='Director', APJC_Participant__c = false);
			insert contact;
		}
	}

	private static void loadVars() {
		List<User> users = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1 ];
		adminUser = users[0];

		List<IATA_ISO_Country__c> listCountries = [SELECT Name, Country_Manager__c, ISO_Code__c, Region__c, ISS_Office_Location__c FROM IATA_ISO_Country__c];
		country1 = listCountries[0];
		country2 = listCountries[1];

		hqAccount = [SELECT Name, RecordTypeId, IATA_ISO_Country__c, ParentId FROM Account WHERE RecordTypeId = :RECORDTYPE_HQ];

		contact = [SELECT AccountId, FirstName, LastName, Email, Title, APJC_Participant__c FROM Contact LIMIT 1];
	}

	static testMethod void testInsertParticipant() {
		loadVars();

		system.runAs(adminuser){

			Test.startTest();

			List<LocalGovernance__c> localGovernanceList = new List<LocalGovernance__c>();

			LocalGovernance__c lg = new LocalGovernance__c();
				lg.Name = 'Name';
				lg.Cargo_Passenger__c = 'BSP';
				lg.Local_Governance_type__c = 'APJC';
				lg.Country__c = country1.Id;
				lg.Active__c = true;
				lg.RecordTypeId = RECORDTYPE_LOCAL_GROUP;

			localGovernanceList.add(lg);

			LocalGovernance__c lg2 = new LocalGovernance__c();
				lg2.Name = 'DifferentName';
				lg2.Cargo_Passenger__c = 'CASS';
				lg2.Local_Governance_type__c = 'APJC';
				lg2.Country__c = country2.Id;
				lg2.Active__c = true;
				lg2.RecordTypeId = RECORDTYPE_LOCAL_GROUP;

			localGovernanceList.add(lg2);

			insert localGovernanceList;

			Participant__c part = new Participant__c();
				part.Contact__c = contact.Id;
				part.Local_Governance__c = lg.Id;
				part.Participant_Type__c = '5 Representative';
				part.Head_Quartier__c = hqAccount.Id;
				part.Local_Group_Type__c = 'APJC';
			insert part;
			Test.stopTest();

			// check that the Contact was flagged
			contact = [SELECT Id, APJC_Participant__c FROM Contact WHERE Id = :contact.Id];
			system.assertEquals(true, contact.APJC_Participant__c);
		}

	}

	static testMethod void testDeleteParticipant() {
		loadVars();

		system.runAs(adminuser){

			List<LocalGovernance__c> localGovernanceList = new List<LocalGovernance__c>();
			
			LocalGovernance__c lg = new LocalGovernance__c();
			lg.Name = 'Name';
			lg.Cargo_Passenger__c = 'BSP';
			lg.Local_Governance_type__c = 'APJC';
			lg.Country__c = country1.Id;
			lg.Active__c = true;
			lg.RecordTypeId = RECORDTYPE_LOCAL_GROUP;
			
			localGovernanceList.add(lg);
			
			LocalGovernance__c lg2 = new LocalGovernance__c();
			lg2.Name = 'DifferentName';
			lg2.Cargo_Passenger__c = 'CASS';
			lg2.Local_Governance_type__c = 'APJC';
			lg2.Country__c = country2.Id;
			lg2.Active__c = true;
			lg2.RecordTypeId = RECORDTYPE_LOCAL_GROUP;
			
			localGovernanceList.add(lg2);
			
			insert localGovernanceList;
			
			
			Test.startTest();
			Participant__c part = new Participant__c();
			part.Contact__c = contact.Id;
			part.Local_Governance__c = lg.Id;
			part.Participant_Type__c = '5 Representative';
			part.Head_Quartier__c = hqAccount.Id;
			part.Local_Group_Type__c = 'APJC';

			// create a second participant for lg2, same contact
			Participant__c part2 = new Participant__c();
				part2.Contact__c = contact.Id;
				part2.Local_Governance__c = lg2.Id;
				part2.Participant_Type__c = '5 Representative';
				part2.Head_Quartier__c = hqAccount.Id;
				part2.Local_Group_Type__c = 'APJC';

			insert new list<Participant__c>{part, part2};

			// delete the first participant and check that the flag on the contact was NOT reset
			delete part;
			Test.stopTest();

			contact = [SELECT Id, APJC_Participant__c FROM Contact WHERE Id = :contact.Id];
			system.assertEquals(true, contact.APJC_Participant__c);

		}
	}

	static testMethod void testUndeleteParticipant() {
		loadVars();

		system.runAs(adminuser){

			List<LocalGovernance__c> localGovernanceList = new List<LocalGovernance__c>();
			
			LocalGovernance__c lg = new LocalGovernance__c();
			lg.Name = 'Name';
			lg.Cargo_Passenger__c = 'BSP';
			lg.Local_Governance_type__c = 'APJC';
			lg.Country__c = country1.Id;
			lg.Active__c = true;
			lg.RecordTypeId = RECORDTYPE_LOCAL_GROUP;
			
			localGovernanceList.add(lg);
			
			LocalGovernance__c lg2 = new LocalGovernance__c();
			lg2.Name = 'DifferentName';
			lg2.Cargo_Passenger__c = 'CASS';
			lg2.Local_Governance_type__c = 'APJC';
			lg2.Country__c = country2.Id;
			lg2.Active__c = true;
			lg2.RecordTypeId = RECORDTYPE_LOCAL_GROUP;
			
			localGovernanceList.add(lg2);
			
			insert localGovernanceList;
			
			Participant__c part = new Participant__c();
			part.Contact__c = contact.Id;
			part.Local_Governance__c = lg.Id;
			part.Participant_Type__c = '5 Representative';
			part.Head_Quartier__c = hqAccount.Id;
			part.Local_Group_Type__c = 'APJC';

			insert part;
			
			Test.startTest();
			delete part;
			undelete part;
			Test.stopTest();

		}

	}
}
