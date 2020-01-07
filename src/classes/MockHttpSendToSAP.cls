/****************************************************************************************************
		Created by Kevin Ky 2015-08-26
		generat Mock response from ProductAvailabilityCheck_Soap class
****************************************************************************************************/
@isTest
global class MockHttpSendToSAP implements WebServiceMock{

	global void doInvoke(Object stub, Object request, Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS, String responseName,String responseType) {

				 ProductAvailabilityCheck_Soap.DT_SFDC_ProductAvailabilityCheck_Response respElement =  new ProductAvailabilityCheck_Soap.DT_SFDC_ProductAvailabilityCheck_Response();
				 list<ProductAvailabilityCheck_Soap.ProductAvailability_element> lstElements = new list<ProductAvailabilityCheck_Soap.ProductAvailability_element>();
				 ProductAvailabilityCheck_Soap.ProductAvailability_element respEle = new ProductAvailabilityCheck_Soap.ProductAvailability_element();
				 respEle.MaterialNumber = '1245-78';
				 respEle.Status = 'OS+D';
				 respEle.AvailableDate = String.valueOf(date.today());
				 lstElements.add(respEle);

				 respElement.ProductAvailability = lstElements;

				 response.put('response_x', respElement);
		 }

}
