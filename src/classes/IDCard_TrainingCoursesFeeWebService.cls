/**
 * URI: /services/apexrest/IDCard/v1/courseFee/
 * Parameters: iataCode
 * Example: /services/apexrest/IDCard/v1/courseFee?iataCode=xxxx
 */
@RestResource(urlMapping='/IDCard/v1/courseFee/*')
global with sharing class IDCard_TrainingCoursesFeeWebService
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
            m.put('IATA_Package__c', p.IATA_Package__c);
            m.put('Type_Class_of_Agent__c', p.Type_Class_of_Agent__c);
            ret.add(m);
        }

        return ret;
    }
}