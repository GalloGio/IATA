@IsTest(seeAllData = false)
global class ProvisionKaviAccessTestWS implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
		// Create a fake response.
		// Set response values, and
		// return response.
		// Create a fake response

		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/xml');
		res.setBody('{"company": {"url": "http://api-sandbox.kavi.com/v1/company/0017E00000IrMKCQA3", "fields": {"city": null, "name": "FakeKaviAccount", "zip": null, "url": null, "country": "HR", "is_active": true, "contact": null, "interest_category": null, "state": null, "street": null, "last_modified": "2016-08-29T09:24:33.000000Z", "logo_url": null, "email_address": null, "logo_url_small": null}, "id": "0017E00000IrMKCQA3"}, "success": true}');
		res.setStatusCode(200);
		return res;

	}
}
