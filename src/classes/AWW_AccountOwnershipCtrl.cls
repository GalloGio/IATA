public with sharing class AWW_AccountOwnershipCtrl {

	@AuraEnabled
	public static List<AccountRole> getOwners(Id accountId) {   
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		List<AMS_Account_Role__c> owners = [SELECT Id, Account__c, Account__r.Name, Owner_Account__c, Owner_Account__r.Name,
												Percentage__c, Owner_Type__c, Subsidiary_Type__c
											FROM AMS_Account_Role__c
											WHERE Account__c = :accountId AND Active__c = true AND RecordTypeId = :rtId];     
		
		List<AccountRole> res = new List<AccountRole>();
		for(AMS_Account_Role__c owner : owners) {
			res.add(new AccountRole(owner));
		}

		return res;
	}

	@AuraEnabled
	public static List<AccountRole> getSubsidiaries(Id accountId) {
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		List<AMS_Account_Role__c> owners = [SELECT Id, Account__c, Account__r.Name, Owner_Account__c, Owner_Account__r.Name,
												Percentage__c, Owner_Type__c, Subsidiary_Type__c
											FROM AMS_Account_Role__c
											WHERE Owner_Account__c = :accountId AND Active__c = true AND RecordTypeId = :rtId];     
		
		List<AccountRole> res = new List<AccountRole>();
		for(AMS_Account_Role__c owner : owners) {
			res.add(new AccountRole(owner));
		}

		return res;
	}

	@AuraEnabled 
	public static void addRecord(String request) {
		List<AccountRole> rolesRequest = (List<AccountRole>) JSON.deserialize(request, List<AccountRole>.class);

		List<AMS_Account_Role__c> sfRoles = new List<AMS_Account_Role__c>();
		for(AccountRole role : rolesRequest) {
		if(role.ownerId == null) {
			role.ownerId = createAccountRecord(role.ownerName).Id;
		}

		if(role.accountId == null) {
			role.accountId = createAccountRecord(role.accountName).Id;
		}

			sfRoles.add(role.convertToSFRecord());
		}

		upsert sfRoles;
	}

	private static Account createAccountRecord(String name) {
		Account acc = new Account(
			Name= name,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','Standard_Account'),
			Reason_for_creation__c = 'Account is missing'
		);

		insert acc;

		return acc;
	}

	@AuraEnabled 
	public static void removeRecord(Id recordId) {
		AMS_Account_Role__c record = new AMS_Account_Role__c(Id= recordId);
		delete record;
	}

	@AuraEnabled 
	public static void removeListRecords(List<Id> listIdsToRemove) {
		list<AMS_Account_Role__c> recordList = new list<AMS_Account_Role__c>();
		for(Id recordId: listIdsToRemove){
			AMS_Account_Role__c record = new AMS_Account_Role__c(Id = recordId);
			recordList.add(record);

		}
		delete recordList;
	}

	@AuraEnabled
	public static List<AccountRole> searchByOwners(String key, Id accountId) {   
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		List<AMS_Account_Role__c> owners = [SELECT Id, Account__c, Account__r.Name, Owner_Account__c, Owner_Account__r.Name,
												Percentage__c, Owner_Type__c, Subsidiary_Type__c
											FROM AMS_Account_Role__c
											WHERE Account__c = :accountId AND Active__c = true AND RecordTypeId = :rtId 
													AND (Owner_Account__r.Name LIKE : '%' + key + '%' OR Account__r.Name LIKE : '%' + key + '%')];     
		
		List<AccountRole> res = new List<AccountRole>();
		for(AMS_Account_Role__c owner : owners) {
			res.add(new AccountRole(owner));
		}

		return res;
	}

	@AuraEnabled
	public static List<AccountRole> searchBySubsidiaries(String key, Id accountId) {
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		List<AMS_Account_Role__c> owners = [SELECT Id, Account__c, Account__r.Name, Owner_Account__c, Owner_Account__r.Name,
												Percentage__c, Owner_Type__c, Subsidiary_Type__c
											FROM AMS_Account_Role__c
											WHERE Owner_Account__c = :accountId AND Active__c = true AND RecordTypeId = :rtId
												AND (Owner_Account__r.Name LIKE : '%' + key + '%' OR Account__r.Name LIKE : '%' + key + '%')];     
		
		List<AccountRole> res = new List<AccountRole>();
		for(AMS_Account_Role__c owner : owners) {
			res.add(new AccountRole(owner));
		}

		return res;
	}

	@AuraEnabled
	public static SearchWrapper searchBy(String key, Id accountId, String type) {
		String queryStr = 'SELECT Id, Name, IATACode__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name FROM Account ';
		if(type == 'Owner') {
			queryStr += 'WHERE (Name LIKE \'%' + key + '%\') '; 
		} else {
			queryStr += 'WHERE (Name LIKE \'%' + key + '%\' OR Legal_Name__c LIKE \'%' + key + '%\' OR IATACode__c  LIKE \'%' + key + '%\') ';
			queryStr += 'AND (RecordType.DeveloperName = \'IATA_Agency\' OR RecordType.DeveloperName = \'Standard_Account\') '; 
		}

		if(type == 'Owner') {
			queryStr += ' AND Id NOT IN (SELECT Owner_Account__c FROM AMS_Account_Role__c WHERE Account__c = \'' + accountId + '\')';
		} else {
			queryStr += ' AND Id NOT IN (SELECT Account__c FROM AMS_Account_Role__c WHERE Owner_Account__c = \'' + accountId + '\')';
		}

		queryStr += ' LIMIT 16';

		System.debug('queryStr: ' +  queryStr);

		List<Account> accounts = (List<Account>) Database.query(queryStr);
		SearchWrapper res = new SearchWrapper();
		res.maxSizeReached = accounts.size() > 15;
		if(res.maxSizeReached) {
			accounts.remove(15);
		}
		for(Account acc : accounts) {
			res.accounts.add(new AccountWrapper(acc));
		}

		return res;
	}

	public class SearchWrapper {
		@AuraEnabled List<AccountWrapper> accounts {get;set;}
		@AuraEnabled Boolean maxSizeReached {get;set;}

		public SearchWrapper() {
			this.accounts = new List<AccountWrapper>();
		}
	}

	public class AccountWrapper {
		@AuraEnabled Id accountId {get;set;}
		@AuraEnabled String accountLink {get;set;}
		@AuraEnabled String accountName {get;set;}
		@AuraEnabled String iataCode {get;set;}
		@AuraEnabled String country {get;set;}

		public AccountWrapper(Account acc) {
			this.accountId = acc.Id;
			this.accountLink = '/' + acc.Id;
			this.accountName = acc.Name;
			this.iataCode = acc.IATACode__c;
			this.country = acc.IATA_ISO_Country__c == null ? '' : acc.IATA_ISO_Country__r.Name;
		}
	}    

	public class AccountRole {
		@AuraEnabled Id ownershipRecordId {get;set;}
		@AuraEnabled Id accountId {get;set;}
		@AuraEnabled String accountLink {get;set;}
		@AuraEnabled String accountName {get;set;}
		@AuraEnabled Id ownerId {get;set;}
		@AuraEnabled String ownerLink {get;set;}
		@AuraEnabled String ownerName {get;set;}
		@AuraEnabled String ownerType {get;set;}
		@AuraEnabled String subsidiaryType {get;set;}
		@AuraEnabled Decimal percentageTable {get;set;}
		@AuraEnabled Decimal percentage {get;set;}

		public AccountRole() {}

		public AccountRole(AMS_Account_Role__c role) {
			this.ownershipRecordId = role.Id;
			this.accountId = role.Account__c;
			this.accountLink = '/' + this.accountId;
			this.accountName = role.Account__r.Name;
			this.ownerId = role.Owner_Account__c;
			this.ownerLink = '/' + this.ownerId;
			this.ownerName = role.Owner_Account__r.Name;
			this.ownerType = role.Owner_Type__c;
			this.subsidiaryType = role.Subsidiary_Type__c;
			if(role.Percentage__c <> null) {
				this.percentageTable = role.Percentage__c.divide(100, 4);
			}            
			this.percentage = role.Percentage__c;
		}

		public AMS_Account_Role__c convertToSFRecord() {
			system.debug('this:' + this);
			AMS_Account_Role__c record = new AMS_Account_Role__c(
				Id= this.ownershipRecordId,
				Account__c= this.accountId,
				Owner_Account__c= this.ownerId,
				Percentage__c= this.percentage,
				RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership')
			);

			return record;
		}
	}

}