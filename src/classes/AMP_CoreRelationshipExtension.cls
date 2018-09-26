public with sharing class AMP_CoreRelationshipExtension {

private final Account myAccount;
// public List<Participant__c> lsParticipants {get;set;}

public class Participant {
public String groupId {get; set;}
public String groupName {get; set;}
public String salutation {get; set;}
public String firstName {get; set;}
public String lastName {get; set;}
public String role {get; set;}
public String title {get; set;}
public String representing {get; set;}
}



public List<AMP_WrapperParticipant> lsParticipantWrappers {get; set;}

public AMP_CoreRelationshipExtension(ApexPages.StandardController stdController) {
	this.myAccount = (Account)stdController.getRecord();
	// lsParticipants = getParticipants();
	// acc = (Account)stdController.getRecord();
	Id accountId;
	if(this.myAccount.Id != null) {
		accountId = this.myAccount.Id;
	} else {
		accountId =  ApexPages.currentPage().getParameters().get('accountId');
	}
	lsParticipantWrappers = getParticipantWrappers(accountId);
}

@AuraEnabled
public static List<String> getGroupNames() {
	List<AMPCoreGroups__c> lsCoreGroups = [SELECT Name, Order__c from AMPCoreGroups__c ORDER BY Order__c ASC];
	List<String> groupNames = new List<String>();

	for(AMPCoreGroups__c a : lsCoreGroups) {
		groupNames.add(a.Name);
	}

	return groupNames;
}

@AuraEnabled
public static List<LocalGovernance__c> getGroups() {
	List<String> groupNames = AMP_CoreRelationshipExtension.getGroupNames();                //new List<String>();
	// List<AMPCoreGroups__c> lsCoreGroups = AMPCoreGroups__c.getAll().Values();
	// lsCoreGroups.sort();
	// Integer min = 0;
	// while (min <= lsCoreGroups.size()) {
	//
	//      for(AMPCoreGroups__c a : lsCoreGroups) {
	//              if( a.Order__c == min) groupNames.add(a.Name);
	//      }
	//      min++;
	// }
	return [SELECT Id, Name FROM LocalGovernance__c WHERE Name IN : groupNames];
}

@AuraEnabled
public static List<Participant__c> getParticipants(Id accountId) {
	List<String> groupNames = getGroupNames();
	String accountId15 = String.valueOf(accountId).substring(0, 15);
	List<Participant__c> lsParticipants = new List<Participant__c>();
	lsParticipants =
	[SELECT Id, Local_Governance__c, Local_Governance__r.Name,      Participant_Type__c,
	 Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName,
	 Contact__r.Title, Contact__r.Email, Representing__c, Hidden_Account_Id__c,
	 Local_Governance__r.Group_Owner__r.Name, Local_Governance__r.Group_Owner_Text__c
	 FROM Participant__c
	 WHERE (Hidden_Account_Id__c = :accountId15 OR Representing__c = :accountId15)
	 AND Local_Governance__r.Active__c = true
	                                     AND Local_Governance__r.Name IN :groupNames];

	// for case sensitivity
	List<Participant__c> filteredList = new List<Participant__c>();
	for(Participant__c p : lsParticipants) {if(accountId15.equals(p.Hidden_Account_Id__c)  || accountId15.equals(p.Representing__c)) filteredList.add(p); }

	return filteredList;
}

@AuraEnabled
public static List<AMP_WrapperParticipant> getParticipantWrappers(Id accountId) {

	List<LocalGovernance__c> lsGroups = getGroups();
	List<LocalGovernance__c> lsGroupsOrder = new List<LocalGovernance__c>();

	List<Participant__c> lsParticipants = getParticipants(accountId);

	for(String groupstr : getGroupNames()) {
		for(LocalGovernance__c lgroup : lsGroups) {
			if(groupstr == lgroup.Name)
			{
				lsGroupsOrder.add(lgroup);
			}
		}
	}

	List<AMP_WrapperParticipant> lsParticipantWrappers = new List<AMP_WrapperParticipant>();
	// for(String groupname : groupNames) {
	for(LocalGovernance__c grp : lsGroupsOrder) {
		Boolean found = false;
		for(Participant__c pa : lsParticipants) {
			if(pa.Local_Governance__c == grp.Id) {
				AMP_WrapperParticipant p = new AMP_WrapperParticipant();
				p.groupId = pa.Local_Governance__c;
				p.groupName = grp.name;
				p.role = pa.Participant_Type__c.replaceAll('^\\d+\\s','');                // remove leading number from participant type;
				p.salutation = pa.Contact__r.Salutation;
				p.firstName = pa.Contact__r.FirstName;
				p.lastName = pa.Contact__r.LastName;
				p.title = pa.Contact__r.Title;
				p.representing = pa.Representing__c;
				p.found = true;
				found = true;
				lsParticipantWrappers.add(p);
				// break;
			}
		}
		if(!found) {
			AMP_WrapperParticipant p = new AMP_WrapperParticipant();
			p.groupId = grp.Id;
			p.groupName = grp.name;
			p.found = false;
			p.role = 'not at this time';
			lsParticipantWrappers.add(p);
		}
	}
	System.debug(lsParticipantWrappers);
	return lsParticipantWrappers;

}
}