public class  AmazonFileTrgHelperMultiMockUp  implements HttpCalloutMock {




	Map<String, HttpCalloutMock> requests;

	public AmazonFileTrgHelperMultiMockUp(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;
	}

	public HTTPResponse respond(HTTPRequest req) {
	  //  throw new TransformationException(' req.getEndpoint() ' + req.getEndpoint()
	  //                                         + ' req  '  +req  +     '  requests '  +requests);
		HttpCalloutMock mock = requests.get(req.getEndpoint());
		if (mock != null) {
			return mock.respond(req);
		} else {
				throw new TransformationException('HTTP callout not supported for test methods');
		}
	}

	public void addRequestMock(String url, HttpCalloutMock mock) {
		requests.put(url, mock);
	}

}
