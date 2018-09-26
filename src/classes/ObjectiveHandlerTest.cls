@isTest
public class ObjectiveHandlerTest {

	public static Objective__c getDivisionObjective() {
		return new Objective__c(
			RecordtypeId = ObjectiveHandler.MAP_RT.get('Division').id,
			Name = 'testName',
			Division__c = 'FDS',
			Forecast_Deadline__c = Date.parse('12/31/2015')
		);
	}

	public static Objective__c getRegionObjective() {
		return new Objective__c(
			RecordtypeId = ObjectiveHandler.MAP_RT.get('Region').id,
			Name = 'testName',
			Division__c = 'FDS',
			Region__c = 'Americas',
			Forecast_Deadline__c = Date.parse('12/31/2015')
		);
	}

	public static Objective__c getAreaObjective() {
		return new Objective__c(
			RecordtypeId = ObjectiveHandler.MAP_RT.get('Area').id,
			Name = 'testName',
			Division__c = 'FDS',
			Region__c = 'Americas',
			Area__c = 'Brazil',
			Forecast_Deadline__c = Date.parse('12/31/2015')
		);
	}

	public static Objective__c getAccountObjective() {
		String rtAirlaine = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();

		Account account = new Account(
			Name = 'testAccount',
			RecordtypeId = rtAirlaine
		);
		insert account;

		return new Objective__c(
			RecordtypeId = ObjectiveHandler.MAP_RT.get('Account').id,
			Name = 'testName',
			Division__c = 'FDS',
			Region__c = 'Americas',
			Area__c = 'Brazil',
			Account__c = account.Id,
			Forecast_Deadline__c = Date.parse('12/31/2015')
		);
	}

	/** TEST METHODS **/
	public static testMethod void testSetDivisionObjectiveName() {
		Objective__c objective = getDivisionObjective();

		Test.startTest();
		insert objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-testName-2015');
	}

	public static testMethod void testSetRegionObjectiveName() {
		Objective__c objective = getRegionObjective();

		Test.startTest();
		insert objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-Americas-testName-2015');
	}

	public static testMethod void testSetAreaObjectiveName() {
		Objective__c objective = getRegionObjective();

		Test.startTest();
		insert objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-Americas-testName-2015');
	}

	public static testMethod void testSetAccountObjectiveName() {
		Objective__c objective = getAccountObjective();

		Test.startTest();
		insert objective; 
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.debug(result.Name);
		System.assert(result.Name == 'FDS-testAccount-testName-2015');
	}

	public static testMethod void testSetAccountObjectiveName80() {
		Objective__c objective = getAccountObjective();
		Account account = [Select Name from Account where id = :objective.Account__c];
		Test.startTest();        
		update account;
		insert objective;		 
		Test.stopTest();

		Objective__c result = [Select Name, Account__r.name from Objective__c where id = :objective.Id];
		System.assert(result.name == 'FDS-testAccount-testName-2015');
	}

	public static testMethod void testSetAccountObjectiveNameWithNoAccount() {
		Objective__c objective = getAccountObjective();
		objective.Account__c = null;

		Test.startTest();
		insert objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-testName-2015');
	}

	public static testMethod void testUpdateDivisionObjectiveName() {
		Objective__c objective = getDivisionObjective();
		insert objective;

		Test.startTest();
		objective.Name = 'testName2';
		update objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-testName2-2015');
	}

	public static testMethod void testUpdateRegionObjectiveName() {
		Objective__c objective = getRegionObjective();
		insert objective;

		Test.startTest();
		objective.Name = 'testName2';
		update objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-Americas-testName2-2015');
	}

	public static testMethod void testUpdateAreaObjectiveName() {
		Objective__c objective = getRegionObjective();
		insert objective;

		Test.startTest();
		objective.Name = 'testName2';
		update objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-Americas-testName2-2015');
	}

	public static testMethod void testUpdateAccountObjectiveName() {
		Objective__c objective = getAccountObjective();
		insert objective;

		Test.startTest();
		objective.Name = 'testName2';
		update objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.debug(result.Name);
		System.assert(result.Name == 'FDS-testAccount-testName2-2015');
	}

	public static testMethod void testUpdateAccountObjectiveNameWithNoAccount() {
		Objective__c objective = getAccountObjective();
		objective.Account__c = null;
		insert objective;

		Test.startTest();
		objective.Name = 'testName2';
		update objective;
		Test.stopTest();

		Objective__c result = [Select Name from Objective__c where id = :objective.Id];
		System.assert(result.Name == 'FDS-testName2-2015');
	}

	public static testMethod void testFieldAllSubobjectivesInInsert_RegionEmptyCase() {
		Objective__c objective = getDivisionObjective();
		objective.Cascade_To_Region__c = '';

		Test.startTest();
		insert objective;
		Test.stopTest();

		Objective__c result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == true);
	}

	public static testMethod void testFieldAllSubobjectivesInInsert_AreaEmptyCase() {
		Objective__c objective = getRegionObjective();
		objective.Cascade_To_Area__c = '';

		Test.startTest();
		insert objective;
		Test.stopTest();

		Objective__c result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == true);
	}

	public static testMethod void testFieldAllSubobjectivesInUpdate_Region() {
		Objective__c objective = getDivisionObjective();
		objective.Cascade_To_Region__c = '';
		insert objective;

		Objective__c child1 = getRegionObjective();
		child1.Parent_Objective__c  = objective.Id;
		child1.Region__c = 'Americas';
		insert child1;

		Objective__c child2 = getRegionObjective();
		child2.Parent_Objective__c  = objective.Id;
		child2.Region__c = 'Africa';
		insert child2;

		Test.startTest();

		update objective;
		Objective__c result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == true);

		objective.Cascade_To_Region__c = 'Europe';
		update objective;
		result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == false);

		objective.Cascade_To_Region__c = 'Americas';
		update objective;
		result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == true);

		objective.Cascade_To_Region__c = 'Americas;Africa';
		update objective;
		result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == true);

		objective.Cascade_To_Region__c = 'Americas;Africa;Europe';
		update objective;
		result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == false);

		Test.stopTest();
	}

	public static testMethod void testFieldAllSubobjectivesInUpdate_Area() {
		Objective__c objective = getRegionObjective();
		objective.Cascade_To_Area__c = '';
		insert objective;

		Objective__c child1 = getAreaObjective();
		child1.Parent_Objective__c  = objective.Id;
		child1.Area__c = 'India';
		insert child1;

		Objective__c child2 = getAreaObjective();
		child2.Parent_Objective__c  = objective.Id;
		child2.Area__c = 'Indonesia';
		insert child2;

		Test.startTest();

		update objective;
		Objective__c result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == true);

		objective.Cascade_To_Area__c = 'Japan';
		update objective;
		result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == false);

		objective.Cascade_To_Area__c = 'India';
		update objective;
		result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == true);

		objective.Cascade_To_Area__c = 'India;Indonesia';
		update objective;
		result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == true);

		objective.Cascade_To_Area__c = 'India;Indonesia;Japan';
		update objective;
		result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == false);

		Test.stopTest();
	}

	public static testMethod void testFieldAllSubobjectivesInUpdateInChildren_Region() {
		Objective__c objective = getDivisionObjective();
		objective.Cascade_To_Region__c = 'Europe';
		insert objective;

		Objective__c result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == false);

		Test.startTest();

		Objective__c child = getRegionObjective();
		child.Parent_Objective__c  = objective.Id;
		child.Region__c = 'Europe';
		insert child;

		Test.stopTest();

		result = [Select All_Regions_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Regions_Created__c == true);
	}

	public static testMethod void testFieldAllSubobjectivesInUpdateInChildren_Area() {
		Objective__c objective = getRegionObjective();
		objective.Cascade_To_Area__c = 'India';
		insert objective;

		Objective__c result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == false);

		Test.startTest();

		Objective__c child = getAreaObjective();
		child.Parent_Objective__c  = objective.Id;
		child.Area__c = 'India';
		insert child;

		Test.stopTest();

		result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == true);
	}

	public static testMethod void testFieldAllSubobjectivesInUpdateInChildren_DeleteArea() {
		Objective__c objective = getRegionObjective();
		objective.Cascade_To_Area__c = 'India';
		insert objective;

		Objective__c result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == false);

		Objective__c child = getAreaObjective();
		child.Parent_Objective__c  = objective.Id;
		child.Area__c = 'India';
		insert child;

		result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == true);

		Test.startTest();

		delete child;

		result = [Select All_Areas_Created__c from Objective__c where id = :objective.Id];
		System.assert(result.All_Areas_Created__c == false);

		Test.stopTest();

	}

	public static testMethod void testUpdateParentValue() {
		Objective__c objective = getDivisionObjective();
		insert objective;


		Objective__c result = [Select Children_Current_Value__c from Objective__c where id = :objective.Id];
		System.assert(result.Children_Current_Value__c == 0);


		Objective__c child = getRegionObjective();
		child.Parent_Objective__c  = objective.Id;

		Test.startTest();
		// test insert
		child.current__c = 10;
		insert child;
		result = [Select Children_Current_Value__c from Objective__c where id = :objective.Id];
		System.assert(result.Children_Current_Value__c == 10);

		// test update
		child.current__c = 20;
		update child;
		result = [Select Children_Current_Value__c from Objective__c where id = :objective.Id];
		System.assert(result.Children_Current_Value__c == 20);

		// test delete
		delete child;
		result = [Select Children_Current_Value__c from Objective__c where id = :objective.Id];
		System.assert(result.Children_Current_Value__c == 0);

		Test.stopTest();

	}
}