public class vfIECEBC_TemplateCreation extends vfIECEBC_Controller
{
	public String audience { get; set; }

	public List<EBC_Template__c> globalTemplates {
		get {

			if(globalTemplates == null) {
				globalTemplates = [
					SELECT
						Id,
						Name,
						(Select Id, Name From Attachments where Name = '/edres/_full.png')
					FROM EBC_Template__c
					WHERE
						Recordtype.DeveloperName = 'Global' AND
						Audience__c = :audience AND
						(NOT External_Id__c LIKE '%customhtml-%')
				];
			}

			return globalTemplates;
		}
		set;
	}
	public List<EBC_Template__c> userEditableTemplates {
		get {
			if (userEditableTemplates == null) {
				System.debug(billingAccount.Id);
				System.debug(audience);
				userEditableTemplates = [
					Select
						Id,
						Name,
						CreatedDate,
						LastModifiedDate
					from EBC_Template__c
					where Is_Reusable__c = true
						and Billing_Account__c = :billingAccount.Id
						and RecordType.DeveloperName != 'Global'
						and (Audience__c = :audience or Audience__c = 'Neutral')
				];
			}
			return userEditableTemplates;
		}
		set;
	}
	public Id selectedTemplate{get;set;}
	public vfIECEBC_TemplateCreation()
	{
		selectedTemplate = null;
		//getUserSavedTemplates();
	}
}
