public with sharing class PortalServiceAssignmentTriggerHandler {
	public static void updatePortalServices(Set<Id> apps){
		String recordTypeId = Schema.getGlobalDescribe().get('Portal_Service_Assignment__c').getDescribe().getRecordTypeInfosByName().get('Country Assignment').getRecordTypeId();
		List<Portal_Applications__c> applications = [SELECT Id, ANG_Country_Coverage__c, 
													(SELECT Id, ISO_Code__c FROM Portal_Service_Assignments__r WHERE RecordTypeId =: recordTypeId) 
													FROM Portal_Applications__c 
													WHERE Id =: apps
													AND (NOT Name Like '%EasyPay%')];
		for(Portal_Applications__c app : applications){
			String coverage = '';
			if(app.Portal_Service_Assignments__r != null && !app.Portal_Service_Assignments__r.isEmpty()){
				for(Portal_Service_Assignment__c ass : app.Portal_Service_Assignments__r){
					coverage = coverage + ass.ISO_Code__c + ',';
				}
				coverage = coverage.removeEnd(',');
			}
			app.ANG_Country_Coverage__c = coverage;
		}
		update applications;
	}
}
