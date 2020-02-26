/**
  * Description: Trigger for before Insert/Update/Delete on Terms_and_Conditions__c
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
 */
trigger trgIECTermsAndConditions on Terms_and_Conditions__c (before delete, before insert, before update) {

	// insert
	if (Trigger.isInsert) {

		for (Terms_and_Conditions__c oTnC: Trigger.new) {

			// cannot specify an Effective date before having an attachment file
			if (oTnC.Effective_Start_Date__c != null && !IECProductManager.isTermsAndConditionsHasAttachment(oTnC.Id))
				oTnc.addError(Label.IEC_Error_TnCMissingAttachment);

			// cannot set an Effective Start Date in the past (only if not in Test)
			if (!Test.isRunningTest() && oTnC.Effective_Start_Date__c <= Datetime.now().addMinutes(-1))
				oTnC.addError(Label.IEC_Error_TnCEffectiveDatePast);
		}
	}
	// update
	else if (Trigger.isUpdate) {

		for (Terms_and_Conditions__c oTnC: Trigger.new) {

			// get T&C before the update
			Terms_and_Conditions__c oTnCBeforeUpdate = Trigger.oldMap.get(oTnC.Id);

			// cannot specify an Effective date before having an attachment file
			if (oTnC.Effective_Start_Date__c != null && !IECProductManager.isTermsAndConditionsHasAttachment(oTnC.Id))
				oTnc.addError(Label.IEC_Error_TnCMissingAttachment);

			// cannot set an Effective Start Date in the past (only if not in Test)
			if (!Test.isRunningTest() && oTnC.Effective_Start_Date__c != null && oTnC.Effective_Start_Date__c <= Datetime.now().addMinutes(-1) && oTnCBeforeUpdate.Effective_Start_Date__c <> oTnC.Effective_Start_Date__c)
				oTnC.addError(Label.IEC_Error_TnCEffectiveDatePast);

			// cannot update the T&C if it has already been accepted by a customer
			if (IECProductManager.hasTnCBeenAcceptedByACustomer(oTnC.Id))
				oTnC.addError(Label.IEC_Error_CannotModifyTnC);
		}
	}
	// delete
	else if (Trigger.isDelete) {

		for (Terms_and_Conditions__c oTnC: Trigger.old) {

			// cannot delete the T&C if it has already been accepted by a customer
			if (IECProductManager.hasTnCBeenAcceptedByACustomer(oTnC.Id))
				oTnC.addError(Label.IEC_Error_CannotModifyTnC);
		}
	}
}
