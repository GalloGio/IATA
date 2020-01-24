/**
	* Description: This is an email utility class to handle sending dynamic content through Email Notification Object
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
	public without sharing class IECEmailUtility {

	/**
	 * Send email using message wrapper for dynamic content
	 * @param ToName Name of the email recepient
	 * @param ToEmail Email address of the recepient
	 * @param EmailTemplateName Email template to be used for that email
	 * @param Body Dynamic body that will be embedded in the email template
	 * @param ConfirmationNumber Transaction confirmation number
	 * @param PaymentMethod payment method used in the order
	 * @param Subtotal order subtotal before tax
	 * @param Tax order applicable taxes
	 * @param Total order total value with taxes
	 */
	public static void sendEmail(String ToName, String ToEmail, String EmailTemplateName, String Body, String BodyTitle, String ConfirmationNumber, String PaymentMethod, Decimal Subtotal, Decimal Tax, Decimal Total) {
		insert new IEC_Email_Notification__c(
			Name__c = ToName
			, To_Email__c = ToEmail
			, Email_Template__c = EmailTemplateName
			, Body__c = Body
			, Body_Title__c = BodyTitle
			, Confirmation_Number__c = ConfirmationNumber
			, Payment_Method__c = PaymentMethod
			, Subtotal__c = IECUtil.DecimalToString(Subtotal)
			, Tax__c = IECUtil.DecimalToString(Tax)
			, Total__c = IECUtil.DecimalToString(Total)
			, Order_Date__c = DateTime.now().format('MMM d, yyyy')
		);
	}

	/**
	 * Checks whether there is already an email sent to this user and email template
	 * @param ToEmail Email address of the recepient
	 * @param EmailTemplateName Email template to be used for that email
	 */
	public static Boolean notificationExistsToday(String ToEmail, String EmailTemplateName) {
		List<IEC_Email_Notification__c > lstEmails =
			[SELECT Id
			FROM IEC_Email_Notification__c
			WHERE To_Email__c = :ToEmail
				AND Email_Template__c = :EmailTemplateName
				AND CreatedDate = TODAY];

		return lstEmails.size() > 0;
	}
}
