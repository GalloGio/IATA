public with sharing class PortalApplications {
	public List<Portal_Applications__c> records { get; private set; }

	public PortalApplications() {
		records = new List<Portal_Applications__c>();
	}

	public PortalApplications(List<Portal_Applications__c> portalApplicationsList) {
		records = portalApplicationsList.clone();
	}

	//return a 'default' Invitation record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<Portal_Applications__c> createDefaultPortalApplications(Integer numberOfRecords){
		for(Integer x = 0; x < numberOfRecords; x++){
			Portal_Applications__c portalApplication = (Portal_Applications__c) Schema.getGlobalDescribe().get('Portal_Applications__c').newSObject();
			portalApplication.RecordTypeId = Schema.SObjectType.Portal_Applications__c.getRecordTypeInfosByDeveloperName().get('ISS_Portal_Application').getRecordTypeId();
			records.add(portalApplication);
		}
		return records;
	}

	public class PortalApplicationDomainException extends Exception {}
}