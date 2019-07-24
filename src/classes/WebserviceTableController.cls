public with sharing class WebserviceTableController {

	@AuraEnabled(cacheable = true)
	public static String getJSON(String endpoint, String method, Integer okStatusCode, String jsonBody){

		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod(method);

		if(method == 'POST'){
			req.setBody(jsonBody);
		}

		try{
			Http http = new Http();
			HTTPResponse res = http.send(req);
			if (res.getStatusCode() == okStatusCode) {
				return res.getBody();
		    } else throw new AuraHandledException(JSON.serializePretty(res));

		}catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}
}