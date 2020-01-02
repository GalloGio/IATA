/****************************************************************************************************
	Created by Kevin Ky 2015-10-09
		Email object to send mass email
		targetObjectId must be Contact or User
		whatId must be standard or custom object id
		templateId email template id
		recipients list of email addresses
****************************************************************************************************/
global without sharing class Mail_DTO {

	public Mail_DTO(){}

	public string targetObjectId;
	public string whatId;
	public string templateId;
	public string orgWideEmailAddressId;
	public list<string> recipients;

}
