/**
  * Description: Trigger for before Insert/Update/Delete on Attachments related to  Terms_and_Conditions__c
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
 */
trigger trgIECTnCAttachments on Attachment (before delete, before insert, before update) {

	Terms_and_Conditions__c oRelatedTnC = null;

	// insert
	if (Trigger.isInsert) {

		for (Attachment attach: Trigger.new) {

			if ( attach.ParentId.getSobjectType() != Terms_and_Conditions__c.SobjectType)
				continue;

			// check if the Attachment is related to a T&C object
			List<Terms_and_Conditions__c> lstTnC = [SELECT Id, Effective_Start_Date__c, Product_Information__r.Id FROM Terms_and_Conditions__c WHERE Id = :attach.ParentId];
			if (lstTnC == null || lstTnC.size() == 0)
				continue;

			oRelatedTnC = lstTnC.get(0);

			// check if an attachment already exist for this T&C
			List<Attachment> lstExistingAttachments = [SELECT Id, Body, Name, ParentId FROM Attachment WHERE ParentId = :oRelatedTnC.Id AND Id <> :attach.Id];

			if (lstExistingAttachments.size() > 0) {
				attach.addError(Label.IEC_Error_AttachAlreadyExistForTnC);
				continue;
			}
		}
	}
	// update
	else if (Trigger.isUpdate) {

		for (Attachment attach: Trigger.new) {

			if (attach.ParentId.getSobjectType() != Terms_and_Conditions__c.SobjectType)
				continue;

			// check if the Attachment is related to a T&C object
			List<Terms_and_Conditions__c> lstTnC = [SELECT Id, Effective_Start_Date__c, Product_Information__r.Id FROM Terms_and_Conditions__c WHERE Id = :attach.ParentId];
			if (lstTnC == null || lstTnC.size() == 0)
				continue;

			oRelatedTnC = lstTnC.get(0);

			// check if the related T&C has already been accepted by a customer
			if (IECProductManager.hasTnCBeenAcceptedByACustomer((String)oRelatedTnC.Id)) {
				attach.addError(Label.IEC_Error_CannotModifyTnC);
				continue;
			}
		}
	}
	// delete
	else if (Trigger.isDelete) {

		for (Attachment attach: Trigger.old) {

			if (attach.ParentId.getSobjectType() != Terms_and_Conditions__c.SobjectType)
				continue;

			// check if the Attachment is related to a T&C object
			List<Terms_and_Conditions__c> lstTnC = [SELECT Id, Effective_Start_Date__c, Product_Information__r.Id FROM Terms_and_Conditions__c WHERE Id = :attach.ParentId];
			if (lstTnC == null || lstTnC.size() == 0)
				continue;

			oRelatedTnC = lstTnC.get(0);

			// check if the related T&C has already been accepted by a customer
			if (IECProductManager.hasTnCBeenAcceptedByACustomer(oRelatedTnC.Id)) {
				attach.addError(Label.IEC_Error_CannotModifyTnC);
				continue;
			}
			else if(oRelatedTnC.Effective_Start_Date__c != null) {
				attach.addError(Label.IEC_Error_AttachCannotDeleteWhenEffectiveDate);
			}
		}
	}

}
