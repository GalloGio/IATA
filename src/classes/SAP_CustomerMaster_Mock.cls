@isTest
public class SAP_CustomerMaster_Mock implements WebServiceMock 
{
	//*** variables used to build response
	public static String returnError;
	public static String returnOK;
  public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

      SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response response_x = new SAP_CustomerMaster.DT_SFDC_CustomerMasterUpdate_Response();
		
		//*** build response
		if (returnError != null)
		{
			response_x.Error = new SAP_CustomerMaster.Error_element();
			response_x.Error.Message = returnError;
		}
		else
		{
			List<String> returnData = (List<String>) JSON.deserialize(returnOK, List<String>.class);
			response_x.SAP_SoldTo = new SAP_CustomerMaster.SAP_SoldTo_element();
			response_x.SAP_SoldTo.SAPSoldToID = returnData[0];
			response_x.SAP_BillTo = new SAP_CustomerMaster.SAP_BillTo_element(); 
			response_x.SAP_BillTo.SAPBillToID = returnData[1];
			response_x.SAP_ShipTo = new SAP_CustomerMaster.SAP_ShipTo_element(); 
			response_x.SAP_ShipTo.SAPShipToID = returnData[2];
		}
    
    response.put('response_x', response_x); 
   }
}