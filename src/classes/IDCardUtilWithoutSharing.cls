global without sharing class IDCardUtilWithoutSharing {
	public static ID_Card_Application__c retrieveCommittedICA(id AppId){
		ID_Card_Application__c ICAToReturn = new ID_Card_Application__c();
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');

		for(ID_Card_Application__c ica:database.query('select Id, ' + string.join(lsFields, ',') + ' from ID_Card_Application__c where id =\'' + AppId + '\'')){
			for(string field:lsFields)
				ICAToReturn.put(field, ica.get(field));
			
			//ICAToReturn.id = ica.id;
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


}
