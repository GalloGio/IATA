/****************************************************************************************************
	Created by Kevin Ky 2016-08-19
	Class to handle Renwal notice errors and log them in a custom object
****************************************************************************************************/
public without sharing class IEC_RenewalNotice_Svc {

	public static IEC_Renewal_notice_log__c logError(String sMessage, String sErrorMessage, Id idOrder, Id campaign, Id member, Boolean bInsert) {

		IEC_Renewal_notice_log__c renewalNotice = new IEC_Renewal_notice_log__c(
			Campaign__c = campaign,
			Error_Message__c = sErrorMessage,
			Message__c = sMessage,
			Member__c = member,
			Order__c = idOrder
		);

		if(bInsert) Insert renewalNotice;

		return renewalNotice;

	}
}
