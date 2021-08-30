public with sharing class PortalApplicationRights {
	public final String ACCESSREQUESTED = 'Access Requested';
	public final String ACCESSGRANTED = 'Access Granted';
	public final String ACCESSDENIED = 'Access Denied';
	public final String ACCESSPENDING = 'Pending';
	public final String ACCESSPENDINGPROVISIONING = 'Pending Provisioning';

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

	//return a 'default' Portal_Application_Right__c record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<Portal_Application_Right__c> createDefaultPortalApplicationRight(Integer numberOfRecords){
		for(Integer x = 0; x < numberOfRecords; x++){
			Portal_Application_Right__c portalApplicationRight = (Portal_Application_Right__c) Schema.getGlobalDescribe().get('Portal_Application_Right__c').newSObject();
			records.add(portalApplicationRight);
		}
		return records;
	}
	
	//return a 'default' Portal_Application_Right__c record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<Portal_Application_Right__c> createDefaultPortalApplicationRight(Integer numberOfRecords){
		for(Integer x = 0; x < numberOfRecords; x++){
			Portal_Application_Right__c portalApplicationRight = (Portal_Application_Right__c) Schema.getGlobalDescribe().get('Portal_Application_Right__c').newSObject();
			records.add(portalApplicationRight);
		}
		return records;
	}

	public class PortalApplicationRightDomainException extends Exception {}
}