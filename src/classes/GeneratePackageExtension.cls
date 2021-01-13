public with sharing class GeneratePackageExtension {

	private final Deployment_Plan__c plan;
	private final Set<String> dotSeparator;
	private final Set<String> dashSeparator;
	private final Set<String> slashSeparator;

	public String xml {get;set;}
	public String xmlDestructive {get;set;}

	// The extension constructor initializes the private member
	// variable mysObject by using the getRecord method from the standard
	// controller.
	public GeneratePackageExtension(ApexPages.StandardController stdController) {
		plan = (Deployment_Plan__c)stdController.getRecord();
		dotSeparator = generateDotSet();
		dashSeparator = generateDashSet();
		slashSeparator = generateSlashSet();

		generatePackages();
	}

	private void generatePackages() {
		xml = generateXml(retrieveItems(false));
		xmlDestructive = generateXml(retrieveItems(true));
	}

	private Map<String, List<Deployment_Plan_Item__c>> retrieveItems(Boolean forDeletion) {
		List<Deployment_Plan_Item__c> items = [select Element__c, Related_Object__c, Section__c from Deployment_Plan_Item__c where Deployment_Plan__c = :plan.Id and For_Deletion__c = :forDeletion];

		Map<String, List<Deployment_Plan_Item__c>> groupedItems = new Map<String, List<Deployment_Plan_Item__c>>();
		for (Deployment_Plan_Item__c item : items) {
			List<Deployment_Plan_Item__c> lst;
			if (groupedItems.containsKey(item.Section__c)) {
				lst = groupedItems.get(item.Section__c);
			} else {
				lst = new List<Deployment_Plan_Item__c>();
			}
			lst.add(item);
			groupedItems.put(item.Section__c, lst);
		}

		return groupedItems;
	}

	private Set<String> generateDotSet() {
		Set<String> s = new Set<String>();
		s.add(DeploymentPlanItemHelper.CUSTOM_FIELD);
		s.add(DeploymentPlanItemHelper.LISTVIEW);
		s.add(DeploymentPlanItemHelper.FIELDSET);
		s.add(DeploymentPlanItemHelper.WORKFLOW_RULE);
		s.add(DeploymentPlanItemHelper.WORKFLOW_FIELD_UPDATE);
		s.add(DeploymentPlanItemHelper.CUSTOM_OBJECT_CRITERIA_BASED_SHARING_RULE);
		s.add(DeploymentPlanItemHelper.CUSTOM_OBJECT_OWNER_SHARING_RULE);
		s.add(DeploymentPlanItemHelper.RECORD_TYPE);
		s.add(DeploymentPlanItemHelper.VALIDATION_RULE);
		s.add(DeploymentPlanItemHelper.APPROVAL_PROCESS);
		s.add(DeploymentPlanItemHelper.WEB_LINK);
		return s;
	}

	private Set<String> generateDashSet() {
		Set<String> s = new Set<String>();
		s.add(DeploymentPlanItemHelper.LAYOUT);
		s.add(DeploymentPlanItemHelper.CUSTOM_OBJECT_TRANSLATION);
		return s;
	}

	private Set<String> generateSlashSet() {
		Set<String> s = new Set<String>();
		s.add(DeploymentPlanItemHelper.EMAIL_TEMPLATE);
		s.add(DeploymentPlanItemHelper.REPORT);
		return s;
	}

	private String generateXml(Map<String, List<Deployment_Plan_Item__c>> items) {
		DOM.Document doc = new DOM.Document();

		dom.XmlNode pckg = doc.createRootElement('Package', 'http://soap.sforce.com/2006/04/metadata', '');

		String currentSection = null;
		for (String section : items.keySet()) {
			List<Deployment_Plan_Item__c> lst = items.get(section);
			dom.XmlNode type = pckg.addChildElement('types', null, null);
			for (Deployment_Plan_Item__c item : lst) {
				type.addChildElement('members', null, null).addTextNode(generateMember(item));
			}
			type.addChildElement('name', null, null).addTextNode(section);
		}
		pckg.addChildElement('version', null, null).addTextNode('35.0');
		return doc.toXmlString();
	}

	private String generateMember(Deployment_Plan_Item__c item) {
		if (dashSeparator.contains(item.Section__c)) {
			return item.Related_Object__c + '-' + item.Element__c;
		} else if (dotSeparator.contains(item.Section__c)) {
			return item.Related_Object__c + '.' + item.Element__c;
		} else if (slashSeparator.contains(item.Section__c)) {
			return item.Related_Object__c + '/' + item.Element__c;
		} else {
			return item.Element__c;
		}
	}
}
