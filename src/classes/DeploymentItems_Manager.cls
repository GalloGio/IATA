public with sharing class DeploymentItems_Manager {

	public Deployment_Plan_Item__c di {get;set;}
	public String planname {get;set;}
	public String planid;
	public String objselected {get;set;}
	public List <SelectOption> objects {get;set;}
	public String componentList {get;set;}

	public DeploymentItems_Manager(ApexPages.StandardController controller) {
		di = new Deployment_Plan_Item__c();
		planid = ApexPages.currentPage().getParameters().get('PlanID');

		//If no results, it means that it's the Save&new button
		try {
			planname = [SELECT Name FROM Deployment_Plan__c WHERE id = :planid].Name;
		}
		catch (Exception e) {
			system.debug('@@@retURL: ' +ApexPages.currentPage().getParameters().get('retURL').substring(1));
			planname = [SELECT Name FROM Deployment_Plan__c WHERE id = :ApexPages.currentPage().getParameters().get('retURL').substring(1)].Name;
		}
		getallobjects();


	}

	public void getallobjects () {
		List<String> SObjectList = new List<string>();
		for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
   			String name = objTyp.getDescribe().getName();
			if(!name.containsignorecase('history') && !name.containsignorecase('tag')&& !name.containsignorecase('share') && !name.containsignorecase('feed'))
				SobjectList.add(name);
		}
		SobjectList.sort();
		objects = new List <SelectOption>();
		objects.add(new SelectOption('',''));
		for (integer i=0;i<SobjectList.size();i++)
			objects.add(new SelectOption(SobjectList[i],SobjectList[i]));

	}

	public PageReference Save () {
		if (String.isBlank(componentList)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify at least one component'));
			return null;
		}
		if (String.isBlank(di.Section__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a section'));
			return null;
		}
		List <Deployment_Plan_Item__c> toinsert = new List <Deployment_Plan_Item__c>();
		List <String> components = componentList.split('[\n\r]');

		for (integer i=0;i<components.size();i++) {
			if (!String.isBlank(components[i])) {
				Deployment_Plan_Item__c d = new Deployment_Plan_Item__c (related_object__c = objselected, name = components[i],Deployment_Plan__c = planid, element__c = components[i], section__c = di.section__c, for_deletion__c = di.for_deletion__c);
				toinsert.add(d);
			}
		}
		try {
			database.insert(toinsert);
			return new PageReference ('/' +planid);
		}
		catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}

	}

}
