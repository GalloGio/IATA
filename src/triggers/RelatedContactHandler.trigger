trigger RelatedContactHandler on Related_Contact__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

		RelatedContactUtil.UpdateRelatedContacts(Trigger.newMap);

	} else if (Trigger.isAfter && Trigger.isDelete) {

		RelatedContactUtil.UpdateRelatedContacts(Trigger.oldMap);

	}
}
