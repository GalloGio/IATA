trigger CaseComment on CaseComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	CaseCommentHandler handler = new CaseCommentHandler();

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			Set<Id> ccIds = new Set<Id>();
			for(CaseComment cc : Trigger.new){
				ccIds.add(cc.Id);
			}
			if(!ccIds.isEmpty()){
				if(!(System.isFuture() || System.isBatch())){
					CaseCommentHandler.doAfterInsertFuture(ccIds);
				}
				else {
					CaseCommentHandler.doAfterInsert(ccIds);
				}
			}
			handler.processCaseItems(Trigger.new);
		} else if(Trigger.isUpdate){
			handler.doAfterUpdate(Trigger.newMap, Trigger.oldMap);
		} else if(Trigger.isDelete){
			handler.doAfterDelete(Trigger.oldMap);
		} else if(Trigger.isUndelete){
			handler.doAfterUndelete(Trigger.newMap);
		}
	} else if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			CaseCommentHandler.doBeforeInsert(Trigger.new);
		}
	}
}