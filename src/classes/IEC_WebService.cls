/**
 * Class offering web services for the IEC project
 * For SAP related web services, see IECSAPWebService.cls
 */
global class IEC_WebService {

	/**
	 * Since customer portal licences can't link Quotes to Opportunities,
	 * the process calls this web service to link them.
	 */
	webService static Boolean assignOpportunityToQuote(Id quoteId) {
		try {

			// get all quotes that are not linked to Opportunities but have the Id in the temp field
			List<zqu__Quote__c> quotesToProcess =
				[Select z.zqu__Opportunity__c, z.Id, z.IEC_Opportunity_Id__c, zqu__Number__c
				 From zqu__Quote__c z
				 where z.zqu__Opportunity__c = null
					and z.IEC_Opportunity_Id__c != null
					and z.Id = :quoteId];

			List<zqu__Quote__c> lstQuotesToUpdate = new List<zqu__Quote__c>();
			for (zqu__Quote__c quote : quotesToProcess) {
				quote.zqu__Opportunity__c = quote.IEC_Opportunity_Id__c;
				quote.Name = quote.zqu__Number__c;
				lstQuotesToUpdate.add(quote);
			}
			update lstQuotesToUpdate;

			return true;
		}
		catch (Exception ex) {
			system.debug('** IEC WebService - assignOpportunityToQuote error: ' + ex.getMessage());
			return false;
		}
	}

	/**
	 * Used to bypass a SalesForce limitation (again). Because of Zuora, when a contact gets updated, the associated Quotes and Opportunities also gets updated.
	 * The problem is that the user license assigned to the eCommerce customers do not allow Edit rights on Opportunities and this throws exception whenever a
	 * Contact gets update; so we use this web service to update the Contact on behalf of the customer, via the systemintegration user (which has rights to edit Opportunities).
	 */
	webService static Boolean updateContact(Id contactId, string sFirstName, string sLastName,string sEmail, string sSalutation, string sTitle, string sPhone, string sTax1, string sTax2, string sVATCountryCode , string sIECPortalStatus) {
		try {

			List<Contact> lstContact = [SELECT FirstName, LastName, Email, Phone, Salutation, Tax_1_ID__c, Tax_2_ID__c,VAT_Country_Code__c, Title, User_IECPortal_Status__c FROM Contact WHERE Id = :contactId];
			if (lstContact == null || lstContact.isEmpty())
				return false;

			Contact cToUpdate = lstContact.get(0);
			cToUpdate.FirstName = sFirstName;
			cToUpdate.LastName = sLastName;
			cToUpdate.Email = sEmail;
			cToUpdate.Salutation = sSalutation;
			cToUpdate.Title = sTitle;
			cToUpdate.Phone = sPhone;
			cToUpdate.Tax_1_ID__c = sTax1;
			cToUpdate.Tax_2_ID__c = sTax2;
			cToUpdate.VAT_Country_Code__c = sVATCountryCode;
			cToUpdate.User_IECPortal_Status__c = sIECPortalStatus;

			update cToUpdate;

			return true;
		}
		catch (Exception ex) {
			system.debug('** IEC WEbservice - updateContact error: ' + ex.getMessage());
			return false;
		}
	}

	/**
	 * Used to bypass a SalesForce limitation preventing a portal user to update his profile.
	 */
	webService static Boolean updateUserProfile(Id userId, Id profileId) {
		try {

			User usr = new User(
				Id = userId,
				ProfileId = profileId
			);

			update usr;

			return true;
		}
		catch (Exception ex) {
			system.debug('** IEC WEbservice - updateUserProfile error: ' + ex.getMessage());
			return false;
		}
	}

}
