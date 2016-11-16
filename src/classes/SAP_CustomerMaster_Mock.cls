@isTest
public class SAP_CustomerMaster_Mock implements WebServiceMock 
{
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
        response_x.Error = new SAP_CustomerMaster.Error_element();
        response_x.SAP_SoldTo = new SAP_CustomerMaster.SAP_SoldTo_element();
        response_x.SAP_BillTo = new SAP_CustomerMaster.SAP_BillTo_element(); 
        response_x.SAP_ShipTo = new SAP_CustomerMaster.SAP_ShipTo_element(); 
    
    response.put('response_x', response_x); 
   }
}