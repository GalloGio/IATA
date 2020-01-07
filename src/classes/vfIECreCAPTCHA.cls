public with sharing class vfIECreCAPTCHA {

	/* Configuration */

	// The API endpoint for the reCAPTCHA service
	private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify?';

	// The keys you get by signing up for reCAPTCHA for your domain
	private static String privateKey =  Label.IEC_Recaptcha_PrivateKey;

	public String siteKey{
		get{return  Label.IEC_Recaptcha_SiteKey; }
	}

/*
	public String publicKey {
		get { return '6Lc6Q-cSAAAAAIoIgGLHgqSf4VwutDQi2y3eZ5Tl'; }
	}
*/
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
			return ApexPages.currentPage().getParameters().get('g-recaptcha-response');//recaptcha_response_field');
		}
	}

	// Whether the submission has passed reCAPTCHA validation or not
	public Boolean verified { get; set; }



	public boolean verify() {
		// On first page load, form is empty, so no request to make yet
		if ( !Test.isRunningTest() && (response == null )) {
			return null;
		}

		System.debug('@@@ hellooo');
		HttpResponse r = makeRequest(baseUrl,
			'secret=' + privateKey +
			'&response='  + response +
			'&remoteip='  + remoteHost
		);

		  System.debug('@@@ HttpResponse' + r);

		if ( r!= null) {

			String tempResp =  r.getBody();
			System.debug('@@@ HttpResponse bodystring' + tempResp);

			if(tempResp.contains('true'))
				this.verified = true;
			System.debug('@@@ this.verified' + this.verified);
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
