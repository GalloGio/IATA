/**

	Project: eCommerce Enhancements
	   File: trgIECPayment.cls
	Subject: Trigger on Zuora Payments.
	History: 2017-05-11, asantos, Initial Release.

*/
trigger trgIECPayment on Zuora__Payment__c (before insert, before update, after insert, after update, after delete) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert || Trigger.isUpdate) {
			trgHndlrIECPayment.OnBeforeInsertOrUpdate(Trigger.new, Trigger.oldMap);
		}
	}

	if (Trigger.isAfter) {
		if (Trigger.isInsert || Trigger.isUpdate) {
			trgHndlrIECPayment.OnAfterInsertOrUpdate(Trigger.newMap, Trigger.oldMap);
		}

		if (Trigger.isDelete) {
			trgHndlrIECPayment.OnAfterDelete(Trigger.oldMap);
		}
	}
}