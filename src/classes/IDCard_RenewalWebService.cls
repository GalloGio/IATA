/**
 * URI: /services/apexrest/IDCard/v1/renewal/
 * Parameters: iataCode
 * Parameters: verNumber
 * Example: /services/apexrest/IDCard/v1/renewal?iataCode=xxxx&verNumber=xxxx
 */
@RestResource(urlMapping='/IDCard/v1/renewal/*')
global with sharing class IDCard_RenewalWebService
{
	@HttpPost
	global static void doPost()
	{
		try
		{
			String iataCode = RestContext.request.params.get('iataCode');
			String verNumber = RestContext.request.params.get('verNumber');
			System.debug('iataCode: ' + iataCode);
			System.debug('verNumber: ' + verNumber);

			// parse request
			String json = RestContext.request.requestBody.toString().trim();
			json = cleanJson(json);
			System.debug(json);
			IDCard_RenewalRequest r = IDCard_RenewalRequest.parse(json);

			// run the Mobile App renewal process
			IDCard_ServiceResponse response = IDCard_MobileAppRenewalService.renewCard(iataCode, verNumber, r);
			IDCard_ServiceResponse.setServiceResponse(response);
		}
		catch (Exception e)
		{
			// error occured
			IDCard_ServiceResponse sr = IDCard_ServiceResponse.makeExceptionServiceResponse(e);
			IDCard_ServiceResponse.setServiceResponse(sr);
		}
	}

	private static String cleanJson(String json)
	{
		return String.isBlank(json) ? '{}' : json;
	}
}
