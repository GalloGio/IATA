@isTest
public class Pardot_API_RequestMock_Test implements HttpCalloutMock {
		protected Integer code = 200;
		protected String status = 'OK';
    	protected String method;

		public Pardot_API_RequestMock_Test(String method) {
			this.code = code;
			this.status = status;
			this.method = method;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
            String body = '';
            if(method == 'MOCK_AUTHENTIFICATION_ERROR')
                 body = returnApiKeyFailure();
            else if(method == 'MOCK_AUTHENTIFICATION' || req.getEndpoint().contains('api/login/'))
                 body = returnApiKey();
            else if(method == 'MOCK_READ_PROSPECT' || method == 'MOCK_UPDATE_PROSPECT')
                body = returnProspect();
			resp.setBody(body);

			return resp;
	    }

        private String returnApiKey(){  
            String xml = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<rsp stat="ok" version="1.0">'+
            '<api_key>c87a3ac1de96a5910d105f0300f2a708</api_key>'+
            '<version>4</version>'+
            '</rsp>';
            return xml;
        }
    	
    private String returnApiKeyFailure(){  
            String xml = '<?xml version="1.0" encoding="UTF-8"?>'+
            'Invalid api key';
            return xml;
        }
            
        private String returnProspect(){
            String xml = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<rsp stat="ok" version="1.0">'+
            '<prospect>'+
            '<id>56308118</id>'+
            '<salutation>Mr.</salutation>'+
            '<first_name>TEST GDPR PORTAL9</first_name>'+
            '<last_name>TEST GDPR PORTAL9</last_name>'+
            '<email>iata.fred.dev+1@gmail.com</email>'+
            '<company>Agency 1</company>'+
            '<job_title></job_title>'+
            '<department></department>'+
            '<country></country>'+
            '<city></city>'+
            '<territory></territory>'+
            '<zip></zip>'+
            '<phone></phone>'+
            '<fax></fax>'+
            '<industry></industry>'+
            '<crm_contact_fid>0030D000006hNvAQAU</crm_contact_fid>'+
            '<salesforce_fid>0030D000006hNvAQAU</salesforce_fid>'+
            '<opted_out>1</opted_out>'+
            '<Area_of_Interest>'+
            '<value>Airline management</value>'+
            '<value>Cargo</value>'+
            '</Area_of_Interest>'+
            '<lists>'+
            '<list_subscription>'+
            '<id>362373050</id>'+
            '<list>'+
            '<id>95394</id>'+
            '<name>Air pulse newsletter</name>'+
            '<is_public>true</is_public>'+
            '<is_dynamic>false</is_dynamic>'+
            '<title>Air pulse newsletter</title>'+
            '<description></description>'+
            '</list>'+
            '</list_subscription>'+
            '<list_subscription>'+
            '<id>362373052</id>'+
            '<list>'+
            '<id>95398</id>'+
            '<name>Alexander de Juniac’s blog</name>'+
            '<is_public>true</is_public>'+
            '<is_dynamic>false</is_dynamic>'+
            '<title>Alexander de Juniac’s blog</title>'+
            '<description></description>'+
            '</list>'+
            '</list_subscription>'+
            '</lists>'+
            '</prospect>'+
            '</rsp>';
            return xml;
        }
    
}