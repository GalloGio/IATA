@IsTest
public class TestDataFactory_PortalApplications {
	public static final String DEFAULTSERVICENAME = 'Test Service';

	@TestSetup
	static void makeData(){
	}

	public static List<Portal_Applications__c> createDefaultPortalApplication (Integer numberOfRecords){
		List<Portal_Applications__c> portalApplicationList = new List<Portal_Applications__c>();
		for(Integer x = 0; x < numberOfRecords; x++){
			Portal_Applications__c portalApplication = new Portal_Applications__c(Name = DEFAULTSERVICENAME, Functional_Role__c = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue());
			portalApplicationList.add(portalApplication);
		}
		return portalApplicationList;
	}
}