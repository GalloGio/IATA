/*
 * Created by Miguel Jacinto on 03/12/2018.
 */
public with sharing class  ISSP_CurrencyCenterReportingActionsCtrl {

	//ACAMBAS - WMO-545: Begin

	public static final String APP_NAME = 'Currency Center';
	public Portal_Application_Right__c appRight {get; set;}
	private User currentUser;

	public ISSP_CurrencyCenterReportingActionsCtrl() {
		this.currentUser = [
			Select Id, ContactId, Contact.AccountId, Contact.Account.Status__c,
				Contact.Account.Sector__c,Contact.Name,
				Contact.Account.Country_ISO_Code__c
			From User
			Where id = :UserInfo.getUserId()];

		String strId = this.currentUser.ContactId;

		this.appRight = [
				Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c, Right__c, Enable_Notifications__c,
						ICCS_Currency_Center_Current_Visit__c, ICCS_Currency_Center_Previous_Visit__c
				From Portal_Application_Right__c
				Where ContactId__c = :strId.left(15)
				And Portal_Application__r.Name = :APP_NAME];
	}

	public Pagereference updateAppRight() {
		update this.appRight;
		return null;
	}

	//ACAMBAS - WMO-545: End
}
