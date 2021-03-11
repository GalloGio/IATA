public with sharing class PortalApplicationRights {
	public static final String ACCESSREQUESTED = 'Access Requested';
	public static final String ACCESSGRANTED = 'Access Granted';
	public static final String ACCESSDENIED = 'Access Denied';
	public static final String ACCESSPENDING = 'Pending';
	public static final String ACCESSPENDINGPROVISIONING = 'Pending Provisioning';

	public List<Portal_Application_Right__c> records { get; private set; }

	public PortalApplicationRights(){
		records = new List<Portal_Application_Right__c>();
		// initialise();
	}
	public PortalApplicationRights(List<Portal_Application_Right__c> portalApplicationRightList){
		records = portalApplicationRightList.clone();
		// initialise();
	}
	
	// perform any domain class initialisation logic
	// private void initialise(){
	// }

	// public void onAfterInsert(){
	// }
	// public void onAfterUpdate(){
	// }
	// public void onAfterDelete(){
	// }
	// public void onAfterUndelete(){
	// }
	
	// public void onBeforeInsert(){
	// }
	// public void onBeforeDelete(){
	// }
	
	public class PortalApplicationRightDomainException extends Exception {}
}