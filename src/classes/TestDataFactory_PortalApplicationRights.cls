@IsTest
public class TestDataFactory_PortalApplicationRights {
	public static final String GRANTED = 'Access Granted';
	public static final String DENIED = 'Access Denied';

	public static Portal_Application_Right__c createPortalApplicationRight(Id portalApplicationId, Id contactId){
		Portal_Application_Right__c portalApplicationRight = new Portal_Application_Right__c(Portal_Application__c = portalApplicationId, Contact__c = contactId);
		return portalApplicationRight;
	}
}