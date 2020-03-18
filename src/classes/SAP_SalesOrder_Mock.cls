@isTest
global class SAP_SalesOrder_Mock implements WebServiceMock
{
	global void doInvoke(
		Object stub,
		Object request,
		Map<String, Object> response,
		String endpoint,
		String soapAction,
		String requestName,
		String responseNS,
		String responseName,
		String responseType){

	SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Response response_x = new SAP_SalesOrder.DT_SFDC_SalesOrderCreate_Response();
		response_x.Error = null;
	  	response_x.SalesOrderNumber = '0002514873';

	response.put('response_x', response_x);
  }
}
