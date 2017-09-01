public class ANG_AgencyAChangeCodeTriggerHandler{
	public List<Agency_Applied_Change_code__c> triggerNew = (List<Agency_Applied_Change_code__c>) Trigger.new;
	public List<Agency_Applied_Change_code__c> triggerOld = (List<Agency_Applied_Change_code__c>) Trigger.old;

	public Map<Id, Agency_Applied_Change_code__c> newMap = (Map<Id,Agency_Applied_Change_code__c>) Trigger.newMap;
	public Map<Id, Agency_Applied_Change_code__c> oldMap = (Map<Id,Agency_Applied_Change_code__c>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
	}
	public void onAfterInsert() {
		 new ANG_AgencyEventsGenerator('Create',triggerNew,null,triggerNew.getSObjectType(),'ChangeCode','account', 'account').run();
	}

	public void onBeforeUpdate(){
	}
	
	public void onAfterUpdate() {
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	private void checkAndGenerateAgencyEventRecord(String opType,list<sObject> newRecList,map<id,sObject>oldRecMap,Schema.SObjectType sobjTp,string cmType,string accField, string topParentField){
		list<ANG_CalloutMapping__c> calloutmappingList= new list<ANG_CalloutMapping__c>();
		set<string> insertedRecordsSet = new set<string>();
		list<AMS_Agency_Updates__c> agencyEventsList = new list<AMS_Agency_Updates__c>();	

		for(ANG_CalloutMapping__c cm: ANG_CalloutMapping__c.getAll().values()){
			if(cm.Type__c== cmType) calloutmappingList.add(cm);
		}

		for(sObject obj: newRecList){
			for(ANG_CalloutMapping__c cm:calloutmappingList){
				if((cmType=='ChangeCode' && String.valueOf(obj.get('Change_Code__c')) == cm.Change_Code__c) || (oldMap!= null &&  String.valueOf(obj.get(cm.field__c)) != String.valueOf(oldMap.get(String.valueOf(obj.get('id'))).get(cm.field__c)))){
					if(!insertedRecordsSet.contains(String.valueOf(cm.Action__c=='PUT'?obj.get(accField):obj.get(topParentField))+opType)){
						AMS_Agency_Updates__c auRec = new AMS_Agency_Updates__c(
							Account__c = String.ValueOf(cm.Action__c=='PUT'?obj.get(accField):obj.get(topParentField)), 
							Update_Type__c = opType,
							Integration_System__c='Mulesoft',
							Change_Code__c=cmType=='ChangeCode'?String.valueOf(obj.get('Change_Code__c')):'',
							ConfigurationID__c=cm.id
						);
						insertedRecordsSet.add(String.valueOf(auRec.account__c)+auRec.Update_Type__c);
						agencyEventsList.add(auRec);
					}
				}
			}
		}
		if(agencyEventsList.size()>0)insert agencyEventsList;
	}
}