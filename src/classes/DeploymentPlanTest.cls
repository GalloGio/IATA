@isTest
private class DeploymentPlanTest {

	static testMethod void myUnitTest() {
		Deployment_Plan__c plan = new Deployment_Plan__c ();
		insert plan;

		PageReference pageRef = Page.DeploymentItems_Manager;
		Test.setCurrentPageReference(pageRef);
		ApexPages.CurrentPage().getparameters().put('PlanID', plan.id);

		ApexPages.StandardController sc = new ApexPages.standardController(plan);

		Test.startTest();
		DeploymentItems_Manager dm = new DeploymentItems_Manager(sc);

		dm.di.section__c = 'LAYOUT';
		dm.di.related_object__c = 'Deployment_Plan__c';
		dm.componentlist = 'DeploymentItems_Manager';
		dm.save();

		dm.di.section__c = 'CUSTOM_OBJECT_TRANSLATION';
		dm.save();

		dm.di.section__c = 'CustomField';
		dm.save();

		dm.di.section__c = 'RecordType';
		dm.save();

		dm.di.section__c = 'FIELDSET';
		dm.save();

		dm.di.section__c = 'EMAIL_TEMPLATE';
		dm.save();

		dm.di.section__c = 'PROFILE';
		dm.save();

		dm.di.section__c = 'CustomObject';
		dm.save();

		dm.di.section__c = 'Report';
		dm.save();

		dm.di.section__c = 'ListView';
		dm.save();

		dm.di.section__c = 'CustomObjectTranslation';
		dm.save();

		dm.di.section__c = 'WorkflowRule';
		dm.save();

		dm.di.section__c = 'WorkflowFieldUpdate';
		dm.save();

		dm.di.section__c = 'CustomObjectCriteriaBasedSharingRule';
		dm.save();

		dm.di.section__c = 'CustomObjectOwnerSharingRule';
		dm.save();

		dm.di.section__c = 'EmailTemplate';
		dm.save();

		dm.di.section__c = 'ValidationRule';
		dm.save();

		dm.di.section__c = 'ApprovalProcess';
		dm.save();

		dm.di.section__c = 'WebLink';
		dm.save();

		pageRef = Page.GeneratePackage;
		Test.setCurrentPageReference(pageRef);
		ApexPages.CurrentPage().getparameters().put('PlanID', plan.id);

		sc = new ApexPages.standardController(plan);
		GeneratePackageExtension ge = new GeneratePackageExtension(sc);

	}
}
