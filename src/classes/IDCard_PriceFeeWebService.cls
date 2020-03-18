/**
 * URI: /services/apexrest/IDCard/v1/priceFee/
 * Parameters: iataCode
 * Example: /services/apexrest/IDCard/v1/priceFee?iataCode=xxxx
 */
@RestResource(urlMapping='/IDCard/v1/priceFee/*')
global with sharing class IDCard_PriceFeeWebService
{
	@HttpGet
	global static void doGet()
	{
		try
		{
			String iataCode = RestContext.request.params.get('iataCode');
			System.debug('iataCode: ' + iataCode);

			if (String.isBlank(iataCode))
			{
				IDCard_ServiceResponse response = IDCard_ServiceResponse.makeErrorServiceResponse(Label.IDCard_IATACodeRequired);
				IDCard_ServiceResponse.setServiceResponse(response);
				return;
			}

			String acccountType = IDCard_MobileAppRenewalService.getAccountType(iataCode);
			IATA_ISO_Country__c contactCountry = IDCard_MobileAppRenewalService.getContactCountry(iataCode);

			Price_Table__c prices = IDCard_MobileAppRenewalService.getPriceTable(acccountType, contactCountry);

			IDCard_ServiceResponse response = IDCard_ServiceResponse.makeGenericServiceResponse(makeResponse(new List<Price_Table__c> { prices }));
			IDCard_ServiceResponse.setServiceResponse(response);
		}
		catch (Exception e)
		{
			// error occured
			IDCard_ServiceResponse sr = IDCard_ServiceResponse.makeExceptionServiceResponse(e);
			IDCard_ServiceResponse.setServiceResponse(sr);
		}
	}

	private static List<Map<String, Object>> makeResponse(List<Price_Table__c> prices)
	{
		List<Map<String, Object>> ret = new List<Map<String, Object>>();

		for (Price_Table__c p : prices)
		{
			Map<String, Object> m = new Map<String, Object>();
			m.put('CurrencyIsoCode', p.CurrencyIsoCode);
			m.put('Expedite_Delivery_added_to_IDCard_Price__c', p.Expedite_Delivery_added_to_IDCard_Price__c);
			m.put('Expedite__c', p.Expedite__c);
			m.put('IATA_Package__c', p.IATA_Package__c);
			m.put('ID_Card_Fee__c', p.ID_Card_Fee__c);
			m.put('Type_Class_of_Agent__c', p.Type_Class_of_Agent__c);
			m.put('Cost_of_Printer__c', p.Cost_of_Printer__c);
			ret.add(m);
		}

		return ret;
	}
}
