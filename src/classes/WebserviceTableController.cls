public with sharing virtual class WebserviceTableController {

	@AuraEnabled
	public static String getJSON(String handler, String endpoint, String method, String jsonBody){
		WebserviceTableController c;
		if(String.isNotEmpty(handler)){
			c = (WebserviceTableController) Type.forName(handler).newInstance();
		}else c = new WebserviceTableController();

		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod(method);

		if(method == 'POST' && String.isNotEmpty(jsonBody)){
			req.setBody(jsonBody);
		}

		Http http = new Http();
		HTTPResponse res = http.send(req);
		System.debug(LoggingLevel.FINE, '___ cls [WebserviceTableController - getJSON] - res: '+res);
		System.debug(LoggingLevel.FINE, '___ cls [WebserviceTableController - getJSON] - response body: '+res.getBody());
		
		return c.handle(res);
	}

	protected virtual String handle(HTTPResponse res){
		if (res.getStatusCode() == 200) return res.getBody();
		else throw new AuraHandledException(String.valueOf(res));
	}


	public class DataPrivacy extends WebserviceTableController{
		protected override String handle(HTTPResponse res){
			if (res.getStatusCode() == 200) return res.getBody(); //results found, return list
			else if(res.getStatusCode() == 404)	return '[]'; //404 means no result found. return empty list
			else throw new AuraHandledException(String.valueOf(res));
		}
	}


}