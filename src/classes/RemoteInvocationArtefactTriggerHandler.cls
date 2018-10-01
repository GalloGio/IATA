public with sharing class RemoteInvocationArtefactTriggerHandler {

	public static List<Remote_Invocation_Artefact__c> triggerNew = (List<Remote_Invocation_Artefact__c>) Trigger.new;
	public static List<Remote_Invocation_Artefact__c> triggerOld = (List<Remote_Invocation_Artefact__c>) Trigger.old;

	public static Map<Id, Remote_Invocation_Artefact__c> newMap = (Map<Id,Remote_Invocation_Artefact__c>) Trigger.newMap;
	public static Map<Id, Remote_Invocation_Artefact__c> oldMap = (Map<Id,Remote_Invocation_Artefact__c>) Trigger.oldMap;

	public static Map<ID, Remote_Invocation__c> remoteInvocationParents;
	public static Set<ID> remoteInvocationWithErrors;

	public static Map<String,Account> mapIATACodeAccs;
	public static Map<ID,Account> mapAccsWithIDs; //for the call to the method to create the IEP back account 


	public static void handleBeforeInsert(){
	
	}

}