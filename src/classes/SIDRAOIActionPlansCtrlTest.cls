@isTest
public class SIDRAOIActionPlansCtrlTest {


	private static Operational_Improvements__c createSidraCase(){
		Case cse = new Case(
			RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA').getRecordTypeId(),
			Late_Payment_Date__c = Date.today()
		);
		insert cse;

		Operational_Improvements__c oi = new Operational_Improvements__c(
			Related_Case_Number__c = cse.Id
		);
		insert oi;

		return oi;
	}

	static TestMethod void testController_Fail(){

		Operational_Improvements__c oi = createSidraCase();

		ApexPages.StandardController stdController = new ApexPages.StandardController(oi);

		Test.startTest();
		SIDRAOIActionPlansController controller = new SIDRAOIActionPlansController(stdController);
		Test.stopTest();
	}

	static TestMethod void testController(){

		Operational_Improvements__c oi = createSidraCase();

		ApexPages.StandardController stdController = new ApexPages.StandardController(oi);

		Test.startTest();
		SIDRAOIActionPlansController controller = new SIDRAOIActionPlansController(stdController);
		controller.edit();
		controller.cancel();
		Test.stopTest();
	}

	static TestMethod void testAddNewOperationalImprovement(){

		Operational_Improvements__c oi = createSidraCase();

		ApexPages.StandardController stdController = new ApexPages.StandardController(oi);
		SIDRAOIActionPlansController controller = new SIDRAOIActionPlansController(stdController);

		// there is no OI Action Plan at the beggining
		System.Assert(controller.listOIActionPlans.isEmpty());

		Test.startTest();

		// add one OI Action Plan
		controller.addNewActionPlan();
		System.Assert(controller.listOIActionPlans.size() == 1);
		OI_Action_Plan__c oiActionPlan = controller.listOIActionPlans.get(0);
		Test.stopTest();
	}

	static TestMethod void testSave(){

		Operational_Improvements__c oi = createSidraCase();

		OI_Action_Plan__c oiActionPlan = new OI_Action_Plan__c(
			OI__c = oi.Id
		);
		insert oiActionPlan;

		ApexPages.StandardController stdController = new ApexPages.StandardController(oi);
		SIDRAOIActionPlansController controller = new SIDRAOIActionPlansController(stdController);

		System.Assert(controller.listOIActionPlans.size() == 1);

		Test.startTest();
		//edit value in OI Action Plan
		oiActionPlan = controller.listOIActionPlans.get(0);
		oiActionPlan.Description__c = 'testSubject';
		PageReference pageref = controller.save();
		Test.stopTest();

		System.assert(pageref != null);

		OI_Action_Plan__c result = [
			Select Id, Description__c
			From OI_Action_Plan__c
			where Id = :oiActionPlan.Id
		];

		System.Assert(result.Description__c == oiActionPlan.Description__c, result.Description__c + ' != ' + oiActionPlan.Description__c);
	}


	static TestMethod void testDelete_Error(){

		Operational_Improvements__c oi = createSidraCase();

		OI_Action_Plan__c oiActionPlan = new OI_Action_Plan__c(
			OI__c = oi.Id
		);
		insert oiActionPlan;

		ApexPages.StandardController stdController = new ApexPages.StandardController(oi);
		SIDRAOIActionPlansController controller = new SIDRAOIActionPlansController(stdController);

		System.Assert(controller.listOIActionPlans.size() == 1);

		Test.startTest();
		controller.deleteLine();
		Test.stopTest();

		System.Assert(controller.listOIActionPlans.size() == 1);

	}

	static TestMethod void testDelete_Ok(){

		Operational_Improvements__c oi = createSidraCase();

		OI_Action_Plan__c oiActionPlan = new OI_Action_Plan__c(
			OI__c = oi.Id
		);
		insert oiActionPlan;

		ApexPages.StandardController stdController = new ApexPages.StandardController(oi);
		SIDRAOIActionPlansController controller = new SIDRAOIActionPlansController(stdController);

		System.Assert(controller.listOIActionPlans.size() == 1);

		Test.startTest();
		controller.actionPlanIdToDelete = controller.listOIActionPlans.get(0).Id;
		controller.deleteLine();
		Test.stopTest();

		System.Assert(controller.listOIActionPlans.size() == 0);

	}

}