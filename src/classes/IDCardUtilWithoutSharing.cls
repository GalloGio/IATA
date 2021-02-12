global without sharing class IDCardUtilWithoutSharing {
	public static string ICAName = '';
	public static id AppId = null;

	public static ID_Card_Application__c retrieveCommittedICA(id iAppId){
		ID_Card_Application__c ICAToReturn = new ID_Card_Application__c();
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		if(!lsFields.contains('RecordTypeId')) lsFields.add('recordtypeId');

		for(ID_Card_Application__c ica:database.query('select Id, Name, recordtype.Developername, ' + string.join(lsFields, ',') + ' from ID_Card_Application__c where id =\'' + iAppId + '\'')){
			for(string field:lsFields)
				ICAToReturn.put(field, ica.get(field));
			
			//ICAToReturn.id = ica.id;
			ICAName = ica.Name;
			AppId = ica.Id;
			//ICAToReturn.put('Name', ica.get('Name'));
		}
		
		return ICAToReturn;	
	}

	public static void saveCommittedICA(ID_Card_Application__c transientICA, id iAppId){
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		ID_Card_Application__c ICAToCommit = new ID_Card_Application__c();

		for(string field:lsFields)
			ICAToCommit.put(field, transientICA.get(field));
		
		ICAToCommit.Id = iAppId;

		update ICAToCommit;	
	}

	public static database.UpsertResult dbUpsertCommittedICA(ID_Card_Application__c transientICA, id iAppId){
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		ID_Card_Application__c ICAToCommit = new ID_Card_Application__c();

		for(string field:lsFields){
			ICAToCommit.put(field, transientICA.get(field));
			system.debug('DTULLO Field: ' + field + ' Value: ' +  transientICA.get(field));
		}
			
		
		system.debug('DTULLO ' + iAppId );
		
		if(iAppId!=null)
			ICAToCommit.Id = iAppId;
	
		return database.upsert(ICAToCommit);
	}

	public static void updateCheckoutCase(id idCardAppId){
		List<Case> cases = [SELECT Id FROM Case WHERE Related_ID_Card_Application__c = :idCardAppId];
		if (cases.size() > 0)
			cases[0].Status = 'Ready for production';
		update cases[0];
	}
}
