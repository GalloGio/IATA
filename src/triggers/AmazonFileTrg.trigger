trigger AmazonFileTrg on AmazonFile__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	//domain class
	AmazonFiles amazonFiles;

	if(Trigger.isAfter){
		if(Trigger.isInsert) {
			amazonFiles = new amazonFiles(Trigger.newMap);
			amazonFiles.onAfterInsert();
			AmazonFileTrgHelper.AfterInsert(trigger.new);
			AmazonFileTrgHelper.validateAttachmentIsCase_DGR_Certification((List<AmazonFile__c>) trigger.new); //FM 06-11-2017 - AMSU28
		}
		if(Trigger.isUpdate){
			amazonFiles = new amazonFiles(Trigger.newMap);
			amazonFiles.onAfterUpdate();
			AmazonFileTrgHelper.AfterUpdate(trigger.NewMap,trigger.OldMap);
		}
		if(Trigger.isDelete){
			amazonFiles = new amazonFiles(Trigger.oldMap);
			amazonFiles.onAfterDelete();
		}
		if(Trigger.isUndelete){
			amazonFiles = new amazonFiles(Trigger.newMap);
			amazonFiles.onAfterUndelete();
			AmazonFileTrgHelper.AfterUndelete(trigger.NewMap);
		}
	} else if(Trigger.isBefore){
		if(Trigger.isInsert){
			AmazonFileTrgHelper.checkEFRequiredFields(trigger.NewMap);
			AmazonFileTrgHelper.setFileIdentifier((List<AmazonFile__c>) trigger.new); //AMSU-28;AMSU-113
			/*** AMSU-139 ***/
			if(Trigger.isUpdate) {
				AmazonFileTrgHelper.checkApprover(Trigger.new, Trigger.oldMap);
			}
			//INC543431
			AmazonFileTrgHelper.setCaseFromsObjectId(Trigger.new);
		}
		if(Trigger.isUpdate){
			AmazonFileTrgHelper.checkEFRequiredFields(trigger.NewMap);
			AmazonFileTrgHelper.setFileIdentifier((List<AmazonFile__c>) trigger.new); //AMSU-28;AMSU-113
			/*** AMSU-139 ***/
			if(Trigger.isUpdate) {
				AmazonFileTrgHelper.checkApprover(Trigger.new, Trigger.oldMap);
			}
			//INC543431
			AmazonFileTrgHelper.setCaseFromsObjectId(Trigger.new);
		}
	}
	
}