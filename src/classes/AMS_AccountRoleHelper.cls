public class AMS_AccountRoleHelper {

	public List<AMS_Account_Role__c> triggerNew = (List<AMS_Account_Role__c>) Trigger.new;
	public List<AMS_Account_Role__c> triggerOld = (List<AMS_Account_Role__c>) Trigger.old;

	public Map<Id, AMS_Account_Role__c> newMap = (Map<Id,AMS_Account_Role__c>) Trigger.newMap;
	public Map<Id, AMS_Account_Role__c> oldMap = (Map<Id,AMS_Account_Role__c>) Trigger.oldMap;

	public Id ownerRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

	private List<String> aimsLegacySystems{
		get{
			if(aimsLegacySystems == null) aimsLegacySystems = new List<String>{'AIMS', 'AIMS1', 'AIMS2', 'AIMS3'};
			return aimsLegacySystems;
		}
		set;
	}

	public void aimsOwnerMerge(){

		System.debug(loggingLevel.Debug, '\n____ [cls AMS_AccountRoleHelper - aimsOwnerMerge] ************ start ');

		List<AMS_Account_Role__c> ownersToCheck = new List<AMS_Account_Role__c>();
		Id ownerRecType = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		for(AMS_Account_Role__c owner : triggerNew){
		    if(owner.Percentage__c != null && owner.Owner_Sequence__c != null && owner.RecordTypeId == ownerRecTypeId) ownersToCheck.add(owner);
		}

		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - aimsOwnerMerge] ownersToCheck - ' + ownersToCheck);
		if(ownersToCheck.isEmpty()) return;

		List<AMS_Account_Role__c> ownersToMerge = getAIMSOwners(ownersToCheck);

		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - aimsOwnerMerge] ownersToMerge - ' + ownersToMerge);
		if(ownersToMerge.isEmpty()) return;

		mergeOwners(ownersToMerge);
		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - aimsOwnerMerge] ************ end \n');
	}

	private List<AMS_Account_Role__c> getAIMSOwners(List<AMS_Account_Role__c> ownersToCheck) {
		List<AMS_Account_Role__c> aimsOwners = new List<AMS_Account_Role__c>();

		Map<Id, AMS_Account_Role__c> fullOwners = new Map<Id, AMS_Account_Role__c>([SELECT Id, Account__c, Person__r.Legacy_System__c FROM AMS_Account_Role__c WHERE Active__c = true AND Id IN :ownersToCheck AND (Person__r.Legacy_System__c IN :aimsLegacySystems OR Legacy_System__c IN :aimsLegacySystems)]);

		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - getAIMSOwners] fullOwners - ' + fullOwners);

		for(AMS_Account_Role__c owner : ownersToCheck){
			AMS_Account_Role__c fullOwner = fullOwners.get(owner.Id);
			if(fullOwner != null) aimsOwners.add(fullOwner);
		}

		return aimsOwners;
	}

	private void mergeOwners(List<AMS_Account_Role__c> ownersToMerge) {
		Set<Id> accounts = new Set<Id>();
		for(AMS_Account_Role__c owner : ownersToMerge) accounts.add(owner.Account__c);

		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] accounts - ' + accounts);

		List<AMS_Account_Role__c> ownersToDelete = new List<AMS_Account_Role__c>();
		List<AMS_Account_Role__c> ownersToUpdate = new List<AMS_Account_Role__c>();
		List<AMS_Person__c> personsToDelete = new List<AMS_Person__c>();
		List<AMS_Person__c> personsToUpdate = new List<AMS_Person__c>();

		String tempOwnerName = '';
		String tempPersonName = '';
		for(Account acc : [SELECT Id, (SELECT Id, Percentage__c, Owner_Name__c, Person__c, Person__r.Name FROM AMS_Account_Roles1__r WHERE RecordTypeId = :ownerRecTypeId ORDER BY Owner_Sequence__c ASC) FROM Account WHERE Id IN :accounts]){

			System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] acc - ' + acc);

			for(AMS_Account_Role__c owner : acc.AMS_Account_Roles1__r){

				System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] owner - ' + owner);
				System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] tempOwnerName - ' + tempOwnerName);
				System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] tempPersonName - ' + tempPersonName);

				if(owner.Percentage__c == null){
					tempOwnerName += owner.Owner_Name__c + ' ';
					tempPersonName += owner.Person__r.Name + ' ';
					ownersToDelete.add(owner);
					if(owner.Person__c != null) personsToDelete.add(new AMS_Person__c(Id = owner.Person__c));
				}else{
					if(tempOwnerName != ''){
						owner.Owner_Name__c = tempOwnerName + owner.Owner_Name__c;
						ownersToUpdate.add(owner);
						tempOwnerName = '';
					}
					if(tempPersonName != ''){
						if(owner.Person__c != null) personsToUpdate.add(new AMS_Person__c(Id = owner.Person__c, Name = tempPersonName+owner.Person__r.Name));
						tempPersonName = '';
					}
				}
			}
		}

		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] ownersToDelete - ' + ownersToDelete);
		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] personsToDelete - ' + personsToDelete);
		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] ownersToUpdate - ' + ownersToUpdate);
		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountRoleHelper - mergeOwners] personsToUpdate - ' + personsToUpdate);

		if(!ownersToDelete.isEmpty()) delete ownersToDelete;
		if(!personsToDelete.isEmpty()) delete personsToDelete;
		if(!ownersToUpdate.isEmpty()) update ownersToUpdate;
		if(!personsToUpdate.isEmpty()) update personsToUpdate;
	}


	/*** AMSU-171 ***/
	public static void calculateCoveredOwnership(List<AMS_Account_Role__c> records, Map<Id,AMS_Account_Role__c> oldMap) {
		Id ownerRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		Set<Id> accountIds = new Set<Id>();
		for(AMS_Account_Role__c record : records) {
			Boolean checkAccount = oldMap == null || (record.Percentage__c != oldMap.get(record.Id).Percentage__c);
			Boolean changeActive = oldMap == null || (record.Active__c != oldMap.get(record.Id).Active__c);
			if((record.Active__c || changeActive) && record.RecordTypeId == ownerRecordTypeId && (checkAccount || changeActive)) {
				accountIds.add(record.Account__c);
			}
		}

		if(accountIds.isEmpty()) {
			return;
		}

		List<Account> accounts = [SELECT Id, Covered_Ownership__c, (SELECT Percentage__c FROM AMS_Account_Roles1__r WHERE Active__c = true AND RecordTypeId = :ownerRecordTypeId)
								  FROM Account
								  WHERE Id IN :accountIds];

		List<Account> accountsToUpdate = new List<Account>();
		for(Account acc : accounts) {
			Double totalCovered = 0;
			for(AMS_Account_Role__c owner : acc.AMS_Account_Roles1__r) {
				totalCovered += owner.Percentage__c != null ? owner.Percentage__c : 0;
			}
			if(totalCovered != acc.Covered_Ownership__c) {
				acc.Covered_Ownership__c = totalCovered;
				accountsToUpdate.add(acc);
			}
		}

		if(!accountsToUpdate.isEmpty()) {
			update accountsToUpdate;
		}
	}

}
