/**
 * @description		Test class for CW_CapabilityConflictController
 *
 * Edit Log:
 * @history			2020/06/02  |  sf-680  |  Creation.
 */
@IsTest
public with sharing class CW_CapabilityConflictControllerTest {

	@testSetup
	public static void setup() {
		Account acc = new Account(Name = 'Qatar Airways (Test)', Account_Type__c = 'Airline', Sector__c = 'Airline', Category__c = 'General Aviation', Payment_Term__c = 'Z001', Reason_for_creation__c = 'New agent');
		insert acc;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;
		
		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(
			acc.Id,
			'Test'
		);
		insert accRole;

		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(
			accRole.Id,
			airport
		);
		insert ard;

		Account_Role_Detail_Capability__c ardCap = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCap;

		ICG_Capability_Assignment_Group__c capvalcert = new ICG_Capability_Assignment_Group__c();
		capvalcert.Issue_Date__c = Date.today().addDays(-1);
		capvalcert.Expiration_Date__c = Date.today().addDays(1);
		capvalcert.ICG_Account_Role_Detail__c = ard.Id;
		insert capvalcert;

		ICG_Account_Role_Capability_Assignment__c assignment = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ard.Id, ardCap.Id);
		assignment.ICG_Capability_Assignment_Group__c = capvalcert.id;
		assignment.Is_In_Conflict__c = true;
		assignment.Deprecated__c = false;
		insert assignment;
	}
	
	@IsTest
	public static void getConflictCapabilities(){

		ICG_Account_Role_Capability_Assignment__c assignment = [SELECT Id, In_Conflict_With__c, Account_Role_Detail_Capability__c FROM ICG_Account_Role_Capability_Assignment__c  limit 1];
		String stationId = [Select id from ICG_Account_Role_Detail__c limit 1].Id;
		String nonExistingStationId = '';
		Test.startTest();
		List<ICG_Account_Role_Capability_Assignment__c> response = CW_CapabilityConflictController.getConflictCapabilities(stationId);
		List<ICG_Account_Role_Capability_Assignment__c> responseEmpty = CW_CapabilityConflictController.getConflictCapabilities(nonExistingStationId);
		System.assert(!response.isEmpty(), 'No assignments were returned');

		ICG_Account_Role_Capability_Assignment__c returnedAssignment = response[0];
		System.assertEquals(assignment.Id, returnedAssignment.Id, 'The id does not match the expected value');
		System.assertEquals(assignment.In_Conflict_With__c, returnedAssignment.In_Conflict_With__c, 'The In_Conflict_With__c does not match the expected value');
		System.assertEquals(assignment.Account_Role_Detail_Capability__c, returnedAssignment.Account_Role_Detail_Capability__c, 'The Account_Role_Detail_Capability__c does not match the expected value');
		

		System.assert(responseEmpty.isEmpty(), 'Unexpected assignments were returned');
		
		Test.stopTest();
	}

	@IsTest
	public static void solveCapabilityConflicts(){
		ICG_Account_Role_Detail__c ard = [Select Id from ICG_Account_Role_Detail__c Limit 1];
		ICG_Capability_Assignment_Group__c capvalcert = [Select Id from ICG_Capability_Assignment_Group__c Limit 1];
		List<ICG_Account_Role_Capability_Assignment__c> assignments = new List<ICG_Account_Role_Capability_Assignment__c>();

		Account_Role_Detail_Capability__c ardCapToMaintain = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCapToMaintain;
		
		Account_Role_Detail_Capability__c ardCapToAdd = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCapToAdd;

		Account_Role_Detail_Capability__c ardCapToRemove = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCapToRemove;

		Account_Role_Detail_Capability__c ardCapToReplace = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCapToReplace;

		Account_Role_Detail_Capability__c ardCapToReplaceBy = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCapToReplaceBy;

		ICG_Account_Role_Capability_Assignment__c assignmentAdd = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ard.Id, ardCapToAdd.Id);
		assignmentAdd.Is_In_Conflict__c = true;
		assignmentAdd.ICG_Capability_Assignment_Group__c = capvalcert.id;
		assignmentAdd.Deprecated__c = false;
		assignmentAdd.In_Conflict_With__c = '["' + ardCapToRemove.Id + '"]';
		assignments.add(assignmentAdd);

		ICG_Account_Role_Capability_Assignment__c assignmentReplace = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ard.Id, ardCapToReplace.Id);
		assignmentReplace.Is_In_Conflict__c = true;
		assignmentReplace.ICG_Capability_Assignment_Group__c = capvalcert.id;
		assignmentReplace.Deprecated__c = false;
		assignmentReplace.In_Conflict_With__c = '["' + ardCapToReplaceBy.Id + '"]';
		assignments.add(assignmentReplace);

		ICG_Account_Role_Capability_Assignment__c assignmentToRemove = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(ard.Id, ardCapToRemove.Id);
		assignmentToRemove.Is_In_Conflict__c = false;
		assignmentToRemove.ICG_Capability_Assignment_Group__c = capvalcert.id;
		assignmentToRemove.Deprecated__c = false;
		assignments.add(assignmentToRemove);
		insert assignments;
		
		Id emptyId;

		List<CW_CapabilityConflictController.HandledCapability> handledCapabilities = new List<CW_CapabilityConflictController.HandledCapability>();
		CW_CapabilityConflictController.HandledCapability capabilityMaintain = new CW_CapabilityConflictController.HandledCapability(ardCapToMaintain.Id, CW_CapabilityConflictController.ConflictAction.STATUS_MAINTAIN + '', emptyId);
		CW_CapabilityConflictController.HandledCapability capabilityAdd = new CW_CapabilityConflictController.HandledCapability(ardCapToAdd.Id, CW_CapabilityConflictController.ConflictAction.STATUS_ADD + '', emptyId);
		CW_CapabilityConflictController.HandledCapability capabilityRemove = new CW_CapabilityConflictController.HandledCapability(ardCapToRemove.Id, CW_CapabilityConflictController.ConflictAction.STATUS_REMOVE + '', emptyId);
		CW_CapabilityConflictController.HandledCapability capabilityReplace = new CW_CapabilityConflictController.HandledCapability(ardCapToReplace.Id, CW_CapabilityConflictController.ConflictAction.STATUS_REPLACE + '', ardCapToReplaceBy.Id);
		CW_CapabilityConflictController.HandledCapability capabilityReplacedBy = new CW_CapabilityConflictController.HandledCapability(ardCapToReplaceBy.Id, CW_CapabilityConflictController.ConflictAction.STATUS_TO_BE_REPLACED_BY + '', emptyId);
		handledCapabilities.add(capabilityMaintain);
		handledCapabilities.add(capabilityAdd);
		handledCapabilities.add(capabilityRemove);
		handledCapabilities.add(capabilityReplace);
		handledCapabilities.add(capabilityReplacedBy);

		List<ICG_Account_Role_Capability_Assignment__c> replacedAssignments = [Select Id from ICG_Account_Role_Capability_Assignment__c where Account_Role_Detail_Capability__c =: ardCapToReplace.Id];
		System.assert(!replacedAssignments.isEmpty(), 'Replace assignment should have assigments now');

		List<ICG_Account_Role_Capability_Assignment__c> replacedByAssignments = [Select Id from ICG_Account_Role_Capability_Assignment__c where Account_Role_Detail_Capability__c =: ardCapToReplaceBy.Id];
		System.assert(replacedByAssignments.isEmpty(), 'Replaced by should not have any assigments now');

		String resultJSON = CW_CapabilityConflictController.solveCapabilityConflicts(JSON.serialize(handledCapabilities));
		CW_Utilities.ResponseBody res = (CW_Utilities.ResponseBody) JSON.deserialize(resultJSON, CW_Utilities.ResponseBody.class);

		System.assert(res.success, 'The operation did not succeed.');
		System.assertEquals('Conflicting capabilities have been handled', res.message, 'The operation did not succeed. Message not corresponding');

		List<ICG_Account_Role_Capability_Assignment__c> removedAssignments = [Select Deprecated__c from ICG_Account_Role_Capability_Assignment__c where Account_Role_Detail_Capability__c =: ardCapToRemove.Id];
		System.assert(!removedAssignments.isEmpty(), 'No assignments for removed capability');
		for(ICG_Account_Role_Capability_Assignment__c assignmentRemoved : removedAssignments){
			System.assert(assignmentRemoved.Deprecated__c, 'Removed capability did not update assignment to deprecated');
		}

		List<ICG_Account_Role_Capability_Assignment__c> addedAssignments = [Select Id, In_Conflict_With__c, Account_Role_Detail_Capability__c, Deprecated__c, Is_In_Conflict__c from ICG_Account_Role_Capability_Assignment__c where Account_Role_Detail_Capability__c =: ardCapToAdd.Id];
		System.assert(!addedAssignments.isEmpty(), 'No assignments for added capability');
		for(ICG_Account_Role_Capability_Assignment__c addedAssignment : addedAssignments){
			System.assert(!addedAssignment.Is_In_Conflict__c, 'Assignment still in conflict for added capability');
			System.assertEquals(null, addedAssignment.In_Conflict_With__c, 'Assignment still has references to capabilities for conflicts');
		}

		List<Account_Role_Detail_Capability__c> shouldBeDeleted = [Select Id from Account_Role_Detail_Capability__c where Id =: ardCapToReplace.Id];
		System.assert(shouldBeDeleted.isEmpty(), 'Replace capability should be deleted');

		replacedByAssignments = [Select Id, In_Conflict_With__c, Is_In_Conflict__c from ICG_Account_Role_Capability_Assignment__c where Account_Role_Detail_Capability__c =: ardCapToReplaceBy.Id];
		System.assert(!replacedByAssignments.isEmpty(), 'Replaced by should have assigments now');

		for(ICG_Account_Role_Capability_Assignment__c replacedAssignment : replacedByAssignments){
			System.assert(!replacedAssignment.Is_In_Conflict__c, 'Assignment still in conflict for added capability');
			System.assertEquals(null, replacedAssignment.In_Conflict_With__c, 'Assignment still has references to capabilities for conflicts');
		}



	}
}