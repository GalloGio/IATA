global without sharing class IDCardUtilWithoutSharing {
	public static string ICAName = '';
	public static id AppId = null;

	public static ID_Card_Application__c retrieveCommittedICA(id AppId){
		ID_Card_Application__c ICAToReturn = new ID_Card_Application__c();
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		if(!lsFields.contains('RecordTypeId')) lsFields.add('recordtypeId');

		for(ID_Card_Application__c ica:database.query('select Id, Name, recordtype.Developername, ' + string.join(lsFields, ',') + ' from ID_Card_Application__c where id =\'' + AppId + '\'')){
			for(string field:lsFields)
				ICAToReturn.put(field, ica.get(field));
			
			//ICAToReturn.id = ica.id;
			ICAName = ica.Name;
			AppId = ica.Id;
			//ICAToReturn.put('Name', ica.get('Name'));
		}
		
		return ICAToReturn;	
	}

	public static void saveCommittedICA(ID_Card_Application__c transientICA, id AppId){
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		ID_Card_Application__c ICAToCommit = new ID_Card_Application__c();

		for(string field:lsFields)
				ICAToCommit.put(field, transientICA.get(field));
		
		ICAToCommit.Id = AppId;

		update ICAToCommit;	
	}

	


	public static database.UpsertResult dbUpsertCommittedICA(ID_Card_Application__c transientICA, id AppId){
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		ID_Card_Application__c ICAToCommit = new ID_Card_Application__c();

		for(string field:lsFields)
			ICAToCommit.put(field, transientICA.get(field));
		
		ICAToCommit.Id = AppId;

		return database.upsert(ICAToCommit);
	}

	public static void updateCheckoutCase(id idCardAppId){
		List<Case> cases = [SELECT Id FROM Case WHERE Related_ID_Card_Application__c = :idCardAppId];
		if (cases.size() > 0)
			cases[0].Status = 'Ready for production';
		update cases[0];
	}
}
