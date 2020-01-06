/****************************************************************************************************
	Created by CGI, Thai 2015-10-16
		Mock for call out test for shipping charges and taxes
****************************************************************************************************/

@isTest(seeAllData=false)
global class SAP_Freight_and_Tax_Mock implements WebServiceMock {
	//*** variables used to build response
	public static String returnError;
	public static String returnOK;

	global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction
					   , String requestName, String responseNS, String responseName, String responseType) {
		List<String> returnData;
		SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response wsResponse = new SAP_Freight_and_Tax.DT_SFDC_TaxShippingCalc_Response();

		//*** build response
		if (returnError != null) {
			SAP_Freight_and_Tax.Error_element responseError = new SAP_Freight_and_Tax.Error_element();
			returnData = (List<String>) JSON.deserialize(returnError, List<String>.class);
			responseError.Type_x = returnData[0];
			responseError.Code = returnData[1];
			responseError.Message = returnData[2];
			wsResponse.Error = responseError;
		} else {
			SAP_Freight_and_Tax.CalculationResult_element responseOK = new SAP_Freight_and_Tax.CalculationResult_element();
			returnData = (List<String>) JSON.deserialize(returnOK, List<String>.class);
			responseOK.ProductNumber = returnData[0];
			responseOK.ShippingCharge = Decimal.valueOf(returnData[1]);
			responseOK.Tax = Decimal.valueOf(returnData[2]);
			wsResponse.CalculationResult = new List<SAP_Freight_and_Tax.CalculationResult_element> { responseOK };
		}

		//*** complete mock with response
		response.put('response_x', wsResponse);
	} //*** end of "doInvoke"

} //*** end of class
