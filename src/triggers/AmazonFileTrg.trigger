trigger AmazonFileTrg on AmazonFile__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {


    if(Trigger.isAfter && Trigger.isUndelete) {
    	AmazonFileTrgHelper.AfterUndelete(trigger.NewMap);
    } else if (Trigger.isAfter && Trigger.isInsert){
      AmazonFileTrgHelper.validateAttachmentIsCase_DGR_Certification((List<AmazonFile__c>) trigger.new); //FM 20-12-2017 - AMSU28  
    }else if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
    	AmazonFileTrgHelper.checkEFRequiredFields(trigger.NewMap);
    }
}