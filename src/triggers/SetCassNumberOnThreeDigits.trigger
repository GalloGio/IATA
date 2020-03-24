trigger SetCassNumberOnThreeDigits on AMS_Agency__c (before insert, before update) {
//resizeNumericString
	for(AMS_Agency__c  ag:Trigger.new){
		if(ag.Cass_Number__c!=null && ag.Cass_number__c.isNumeric() && (trigger.isInsert ||trigger.oldMap.get(ag.Id).Cass_number__c!=ag.Cass_number__c)){
			ag.Cass_Number__c = AMS_AgencyHelper.resizeNumericString(ag.Cass_Number__c,3);
		}
	}
}
