/*
	Class Name: ISSP_AMC_MockHttp_Response_generator
	Related Classes:

	Copyright @Right IT Services

	Purpose: This class aims to create a fake response to test Http requests 

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	Filipa Martins		31-01-2019   	INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_MockHttp_Response_generator implements HttpCalloutMock{
		public Integer code;
		public String status;
		public String bodyAsString;
		public Blob bodyAsBlob;
		public Map<String, String> responseHeaders;

		/*
		Constructor method
		*/
		public ISSP_AMC_MockHttp_Response_generator(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}

		/*
		Method to generate the response
		*/
	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()){
					resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }

}