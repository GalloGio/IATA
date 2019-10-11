@isTest
global class ISSP_GetIncidentWebServiceMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

   	   coreWsNettracerBagnetCom.getIncidentResponse_element respElementWrapper = new coreWsNettracerBagnetCom.getIncidentResponse_element();
       pojoCoreWsNettracerBagnetComXsd.WS_Incident respElement = 
           new pojoCoreWsNettracerBagnetComXsd.WS_Incident();
       respElement.passengers = new List<pojoCoreWsNettracerBagnetComXsd.WS_Passenger>();
       respElement.passengers.add(new pojoCoreWsNettracerBagnetComXsd.WS_Passenger());
       respElement.itineraries = new List<pojoCoreWsNettracerBagnetComXsd.WS_Itinerary>();
       respElement.itineraries.add(new pojoCoreWsNettracerBagnetComXsd.WS_Itinerary());
       respElement.items = new List<pojoCoreWsNettracerBagnetComXsd.WS_Item>();
       respElement.items.add(new pojoCoreWsNettracerBagnetComXsd.WS_Item());
       respElementWrapper.return_x = respElement;
       response.put('response_x', respElementWrapper); 
   }
}