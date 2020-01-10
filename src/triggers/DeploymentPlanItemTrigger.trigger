trigger DeploymentPlanItemTrigger on Deployment_Plan_Item__c (before insert, before update) {
	DeploymentPlanItemHelper.validateItem(Trigger.new);
}
