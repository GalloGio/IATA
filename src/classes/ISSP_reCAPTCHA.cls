public with sharing class ISSP_reCAPTCHA {
	/* Configuration */

	// The API endpoint for the reCAPTCHA service
	private static String baseUrl = 'https://www.google.com/recaptcha/api/verify';

	// The keys you get by signing up for reCAPTCHA for your domain
	private static String privateKey = ISSP_CS__c.getInstance('reCAPTCHAprivateKey').value__c;

	public String publicKey {
		get { return ISSP_CS__c.getInstance('reCAPTCHApublicKey').value__c; }
	}

	/* Implementation */


	// Create properties for the non-VF component input fields generated
	// by the reCAPTCHA JavaScript.
	public String challenge {
		get {
			return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
		}
	}
	public String response  {
		get {
			return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
		}
	}

	// Whether the submission has passed reCAPTCHA validation or not
	public Boolean verified { get; set; }



	public boolean verify() {
		System.debug('reCAPTCHA verification attempt');
		// On first page load, form is empty, so no request to make yet
		if ( !Test.isRunningTest() && (challenge == null || response == null )) {
			System.debug('reCAPTCHA verification attempt with empty form');
			return null;
		}

		HttpResponse r = makeRequest(baseUrl,
			'privatekey=' + privateKey +
			'&remoteip='  + remoteHost +
			'&challenge=' + challenge +
			'&response='  + response
		);

		if ( r!= null) {
			this.verified = (r.getBody().startsWithIgnoreCase('true'));
		}
		if(test.isRunningTest())
			return true;

		return this.verified;
	}


	/* Private helper methods */

	private static HttpResponse makeRequest(string url, string body)  {
		HttpResponse response = null;
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod('POST');
		req.setBody (body);
		try {
			Http http = new Http();
			response = http.send(req);
			System.debug('reCAPTCHA response: ' + response);
			System.debug('reCAPTCHA body: ' + response.getBody());
		} catch(System.Exception e) {
			System.debug('ERROR: ' + e);
		}
		return response;
	}

	private String remoteHost {
		get {
			String ret = '127.0.0.1';
			// also could use x-original-remote-host
			Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
			if (hdrs.get('x-original-remote-addr')!= null)
				ret =  hdrs.get('x-original-remote-addr');
			else if (hdrs.get('X-Salesforce-SIP')!= null)
				ret =  hdrs.get('X-Salesforce-SIP');
			return ret;
		}
	}

	public class YourHttpCalloutMockImpl implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('true');
			res.setStatusCode(200);
			return res;
		}
	}




}
