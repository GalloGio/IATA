global without sharing class IDCardUtilWithoutSharing {
	public static string ICAName = '';
	public static id AppId = null;

	public static ID_Card_Application__c retrieveCommittedICA(id iAppId){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.retrieveCommittedICA iAppId = ' + iAppId);
		ID_Card_Application__c ICAToReturn = new ID_Card_Application__c();
		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		if(!lsFields.contains('RecordTypeId')) lsFields.add('recordtypeId');

		for(ID_Card_Application__c ica:database.query('select Id, Name, recordtype.Developername, ' + string.join(lsFields, ',') + ' from ID_Card_Application__c where id =\'' + iAppId + '\'')){
			for(string field:lsFields)
				ICAToReturn.put(field, ica.get(field));
			
			ICAName = ica.Name;
			AppId = ica.Id;
		}
		
		return ICAToReturn;	
	}

	public static void saveCommittedICA(ID_Card_Application__c transientICA, id iAppId){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.saveCommittedICA iAppId = ' + iAppId);
		map<id, ID_Card_Application__c> mapToCommit = new map<id, ID_Card_Application__c>();
		mapToCommit.put(iAppId, transientICA);
		
		saveCommittedICAS(mapToCommit);
	}

	public static database.UpsertResult dbUpsertCommittedICA(ID_Card_Application__c transientICA, id iAppId){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.dbUpsertCommittedICA iAppId = ' + iAppId);

		list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
		set<string> setBooleanFields = new set<string>();
		for(string s:Schema.getGlobalDescribe().get('ID_Card_Application__c').getDescribe().fields.getMap().keyset())
			if(string.ValueOf(Schema.getGlobalDescribe().get('ID_Card_Application__c').getDescribe().fields.getMap().get(s).getDescribe().getType())=='BOOLEAN')
				setBooleanFields.add(s.toUpperCase());

		ID_Card_Application__c ICAToCommit = new ID_Card_Application__c();

		for(string field:lsFields){
			if(setBooleanFields.contains(field.toUpperCase()) && (transientICA.get(field)==null || transientICA.get(field)==''))
				ICAToCommit.put(field, false);
			else
				ICAToCommit.put(field, transientICA.get(field));
		}
		
		system.debug(LoggingLevel.ERROR,'iAppID ' + iAppId );
		
		if(iAppId!=null)
			ICAToCommit.Id = iAppId;
		else{
			ICAToCommit.OwnerId = UserInfo.getUserId();
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule= true;
			ICAToCommit.setOptions(dmo);
		}
		return database.upsert(ICAToCommit);
	}

	public static database.UpsertResult upsertGenericObject(string objName, sObject sObjFrom, id recordId, set<string> lsFields){
		set<string> setBooleanFields = new set<string>();
		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();

		for(string s:lsFields)
			if(fieldMap.keyset().contains(s.toLowerCase()))
				if(string.ValueOf(fieldMap.get(s.toLowerCase()).getDescribe().getType())=='BOOLEAN')
					setBooleanFields.add(s);

		sObject sObjToCommit = Schema.getGlobalDescribe().get(objName).newSObject();
		for(string field:lsFields){
			if(fieldMap.keyset().contains(field.toLowerCase()))
				if(setBooleanFields.contains(field.toUpperCase()) && ( string.isblank(string.valueOf(sObjFrom.get(field)))))
					sObjToCommit.put(field, false);
				else
					sObjToCommit.put(field, sObjFrom.get(field));
		}

		if(recordId!=null)
			sObjToCommit.Id = recordId;
		else{
			sObjToCommit.put('OwnerId',UserInfo.getUserId());
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule= true;
			sObjToCommit.setOptions(dmo);
		}

		database.UpsertResult idcur = database.upsert(sObjToCommit);

		return idCur;
	}

	public static void updateCheckoutCase(id idCardAppId){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.updateCheckoutCase idCardAppId = ' + idCardAppId);

		List<Case> cases = [SELECT Id FROM Case WHERE Related_ID_Card_Application__c = :idCardAppId];
		if (cases.size() > 0)
			cases[0].Status = 'Ready for production';
		update cases[0];
	}

	
	public static void deleteApplications(set<id> setToDelete){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.deleteApplication setToDelete = ' + setToDelete);
		deleteGenericsObject(setToDelete, 'ID_Card_Application__c');
	}

	public static void deleteGenericsObject(set<id> setToDelete, string sObjectName){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.deleteGenericsObject setToDelete = ' + setToDelete);
		List<sObject> lsToDelete = database.query('select id from ' + sObjectName + ' where id in:setToDelete');
		if(!lsToDelete.isEmpty()) delete lsToDelete;
	}

	public static void deleteContacts(set<id> setToDelete){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.deleteContacts setToDelete = ' + setToDelete);
		deleteGenericsObject(setToDelete, 'Contact');
	}

	public static void saveCommittedICAS(map<id, ID_Card_Application__c> mapToCommit){
		system.debug(LoggingLevel.ERROR,'IDCardUtilWithoutSharing.saveCommittedICAS map.Keyset()  = ' + mapToCommit.keyset());
		if(!mapToCommit.isEmpty()){
			list<string> lsFields = TransformationHelper.selectAllWritableFieldsByCurrentUser('ID_Card_Application__c');
			List<ID_Card_Application__c> appsToCommit = new list<ID_Card_Application__c>();

			for(id appId:mapToCommit.keyset()){
				ID_Card_Application__c ICAToCommit = new ID_Card_Application__c();
				set<string> setPopulatedField = mapToCommit.get(appId).getPopulatedFieldsAsMap().keyset();
				for(string field:lsFields)
					if(setPopulatedField.contains(field))
						ICAToCommit.put(field, mapToCommit.get(appId).get(field));

				ICAToCommit.Id = appId;

				appsToCommit.add(ICAToCommit);
			}

			update appsToCommit;
		}
	}
}
