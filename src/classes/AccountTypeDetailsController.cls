public class AccountTypeDetailsController {

	 /* public PageReference save() {
				return null;
		}


public String parentAccountId {
get;
set{parentAccountId =value;AccountTypeDetailsController();}
}


// public List<Account> aList {get; set;}
 public List<Account_For__c> aList {get; set;}
 public List<Contact_For__c> cfList {get; set;}
 //public List<Services_Rendered__c> sPaxList {get; set;}
 public List<Services_Rendered_Contact__c> sPaxList {get; set;}
 public List<Services_Rendered__c> sHOList {get; set;}
 public List<Services_Rendered__c> testList {get; set;}


		public void AccountTypeDetailsController() {
				try{
				//String parentAccountId =Apexpages.currentPage().getParameters().get('parentAccountId');
				 System.debug('parameter: ' + parentAccountId);
						 aList = [Select  status__c,Account_for_IATA_Process__c,name,Account_for_IATA_Division__c,Account_for_IATA_Department__c from Account_For__c where (Related_Account__c =: +parentAccountId or Related_Account__r.Parent.Id =: +parentAccountId)];
						 cfList = [Select  status__c,Contact_for_IATA_Process__c,name,Account_for_IATA_Division__c,Account_for_IATA_Department__c,Related_contact__r.id, Yes_No__c from Contact_For__c where (Related_Contact__c =: +parentAccountId)];// or Related_Account__r.Parent.Id =: +parentAccountId) and status__c = 'Active'];

						 //sPaxList = [Select GSA_Type__c,Services_Rendered_By__r.Services_Rendered_Country__c,Services_Rendered_By__r.Services_Rendered_Country_GSA__c,Services_Rendered_Status__C,Services_Rendered_to_Airline__r.Parent.id,Services_Rendered_to_Airline__r.Parent.Name,Services_Rendered_to_Airline__r.Name,Services_Rendered_to_Airline__r.BillingCountry,Services_rendered_By__r.Name,Services_rendered_By__r.Parent.id, Services_Rendered_Type__c, Services_Rendered_By__r.billingcountry, Name from Services_Rendered__c where (Services_Rendered_to_Airline__c =: +parentAccountId OR Services_Rendered_by__c =: +parentAccountId) and services_rendered_status__c = 'Active'];// and gsa_type__c = 'PAX / GSA'];
						 //sHOList = [Select GSA_Type__c,Services_Rendered_By__r.Services_Rendered_Country__c,Services_Rendered_By__r.Services_Rendered_Country_GSA__c,Services_Rendered_Status__C,Services_Rendered_to_Airline__r.Parent.id,Services_Rendered_to_Airline__r.Parent.Name,Services_Rendered_to_Airline__r.Name,Services_Rendered_to_Airline__r.BillingCountry,Services_rendered_By__r.Name,Services_rendered_By__r.Parent.id, Services_Rendered_Type__c, Services_Rendered_By__r.billingcountry, Name from Services_Rendered__c where (Services_Rendered_To_Airline__r.Parentid =: +parentAccountId OR Services_Rendered_by__r.Parentid =: +parentAccountId) and services_rendered_status__c = 'Active'];// and gsa_type__c = 'Cargo / GSSA'];
					 //sPaxList = [Select yes_no__c, GSA_Type__c,Services_Rendered_By__r.Services_Rendered_Country__c,Services_Rendered_By__r.Services_Rendered_Country_GSA__c,Services_Rendered_Status__C,Services_Rendered_to_Airline__r.Parent.id,Services_Rendered_to_Airline__r.Parent.Name,Services_Rendered_to_Airline__r.Name,Services_Rendered_to_Airline__r.BillingCountry,Services_rendered_By__r.Name,Services_rendered_By__r.Parent.id, Services_Rendered_Type__c, Services_Rendered_By__r.billingcountry, Name from Services_Rendered_Contact__c where (Services_Rendered_to_Airline__c =: +parentAccountId OR Services_Rendered_by__c =: +parentAccountId) and services_rendered_status__c = 'Active'];// and gsa_type__c = 'PAX / GSA'];
					 sPaxList = [Select yes_no__c, GSA_Type__c,Contact__r.id,Services_Rendered_By__r.Services_Rendered_Country__c,Services_Rendered_By__r.Services_Rendered_Country_GSA__c,Services_Rendered_Status__C,Services_Rendered_to_Airline__r.Parent.id,Services_Rendered_to_Airline__r.id,Services_Rendered_to_Airline__r.Parent.Name,Services_Rendered_to_Airline__r.Name,Services_Rendered_to_Airline__r.BillingCountry,Services_rendered_By__r.Name,Services_rendered_By__r.Parent.id, Services_Rendered_Type__c, Services_Rendered_By__r.billingcountry, Name from Services_Rendered_Contact__c where contact__r.id =: +parentAccountId and services_rendered_status__c = 'Active'];// and gsa_type__c = 'PAX / GSA'];


				}catch(Exception ex)    {


				}
		}
		*/

}
