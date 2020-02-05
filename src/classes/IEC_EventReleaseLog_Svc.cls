/**
	* Description: Utility class to handle Event release error messages and log them into a custom object for further analysis
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
public with sharing class IEC_EventReleaseLog_Svc {
	/**
	 * Logs and return an error record with all details as much as possible
	 * @param sMessage: Displayed message to the user if applicable
	 * @param sErrorMessage: The real error message behind the displayed message, like exception error message
	 * @param idOrder: Id of the related order
	 * @param idEventRelease: Id of the related Event Release
	 * @param sStage: Stage at which the error occured
	 * @param idSubscriber: Id of the related Subscriber Contact
	 * @param bInsert: Choose to whether insert the error log or just return it without insert
	 */
	public static IEC_Event_Release_Log__c logError(String sMessage, String sErrorMessage, Id idOrder, Id idEventRelease, String sStage, Id idSubscriber, Boolean bInsert) {
		return logError(sMessage, sErrorMessage, idOrder, idEventRelease, sStage, idSubscriber, null, bInsert);
	}
	public static IEC_Event_Release_Log__c logError(String sMessage, String sErrorMessage, Id idOrder, Id idEventRelease, String sStage, Id idSubscriber, Id idSubscription, Boolean bInsert) {
		// check if message exceed length of field
		if(String.isNotBlank(sMessage) && sMessage.length() > 255) { sMessage = sMessage.substring(0, 255); }

		// check if error message exceed length of field
		if(String.isNotBlank(sErrorMessage) && sErrorMessage.length() > 255) { sErrorMessage = sErrorMessage.substring(0, 255); }

		IEC_Event_Release_Log__c errorLog = new IEC_Event_Release_Log__c(
			Error_Message__c = sErrorMessage
			, Message__c = sMessage
			, Order__c = idOrder
			, IEC_Event_Release__c = idEventRelease
			, Stage__c = sStage
			, Subscriber__c = idSubscriber
			, Subscription__c = idSubscription
		);

		if (bInsert){ insert errorLog; }

		return errorLog;
	}
}
