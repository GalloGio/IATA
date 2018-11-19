/**  
  * Description: This class contains the webservice methods for the Europa VIES validation 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  * Ref: http://ec.europa.eu/taxation_customs/vies/faqvies.do#item_16
  */

public class IECVATUtil {
	
	public static VATConfiguration GetVATConfiguration(String CountryName) {
		if (String.isBlank(CountryName)) return null;
		
		List<IATA_ISO_Country__c> lstCountry = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{CountryName});

		return (lstCountry != null && lstCountry.isEmpty()) ? null : new VATConfiguration(lstCountry.get(0));
	}
	
	// Query the VAT configuration for the country based on the country ID
	public static VATConfiguration GetVATConfiguration(Id idCountry) {

 		if (idCountry == null) return null;

		List<IATA_ISO_Country__c> lstCountry = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<ID>{idCountry});

		return (lstCountry.isEmpty()) ? null : new VATConfiguration(lstCountry.get(0));
	}
	
public static String Validate_VAT(String sCountryCode, String sVATNumber)
	{
	    VATWebService ws = new VATWebService();
	    String sErrorMessage = '';
	    
	    try

	    {	sCountryCode = (sCountryCode.contains('GR') ? 'EL' : sCountryCode);
	    	system.debug('Validate VAT # - sCountryCode : ' + sCountryCode);
         	system.debug('Validate VAT # - sVATNumber : ' + sVATNumber);
	        VATResponse res = ws.ValidateVAT(sCountryCode, ((sVATNumber.startsWithIgnoreCase(sCountryCode)) ? sVATNumber.substring(sCountryCode.length()) : sVATNumber));
	        system.debug('Validate VAT # - VIES response : ' + res);

	        if (!res.valid) 
	            sErrorMessage = String.format(Label.IEC_Invalid_VAT, new List<String>{sVATNumber});
	    }
	    catch (System.CalloutException e) {
	        if (e.getMessage().contains('SERVER_BUSY'))
	            sErrorMessage = Label.IEC_Error_VATWSBusy;
	        else
	            sErrorMessage = e.getMessage();
	    }
	    return sErrorMessage;
	} //*** end of "validateVAT"
	
	public class VATConfiguration {
		public String CountryId {get; set;}
		public String Country {get; set;}
        public String CountryCode {get; set;}
        public String Tax1Label {get; set;}
        public String Tax2Label {get; set;}
        public Boolean TaxIDMandatory {get; set;}
        public Boolean VATValidationRequired {get; set;}
        
        public Boolean ShowTax1 {get {return String.isNotBlank(Tax1Label);}}
        public Boolean ShowTax2 {get {return String.isNotBlank(Tax2Label);}}

        public VATConfiguration (IATA_ISO_Country__c Country) {
        	this.CountryId = Country.Id;
	        this.Country = Country.Name;
	        this.CountryCode = Country.ISO_Code__c;
	        this.Tax1Label = Country.Tax_1_Label__c;
	        this.Tax2Label = Country.Tax_2_Label__c;
	        this.TaxIDMandatory = Country.Tax_ID_Mandatory__c;
	        this.VATValidationRequired = Country.VAT_Validation_Required__c;
        }		
	}
	
    public class VATResponse {
        public String countryCode;
        public String vatNumber;
        public Date requestDate;
        public Boolean valid;
        public String name;
        public String address;
        private String[] countryCode_type_info = new String[]{'countryCode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] vatNumber_type_info = new String[]{'vatNumber','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] requestDate_type_info = new String[]{'requestDate','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] valid_type_info = new String[]{'valid','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] name_type_info = new String[]{'name','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','true'};
        private String[] address_type_info = new String[]{'address','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types','true','true'};
        private String[] field_order_type_info = new String[]{'countryCode','vatNumber','requestDate','valid','name','address'};
    }
    
    public class VATRequest {
        public String countryCode;
        public String vatNumber;
        private String[] countryCode_type_info = new String[]{'countryCode','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] vatNumber_type_info = new String[]{'vatNumber','urn:ec.europa.eu:taxud:vies:services:checkVat:types',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types','true','true'};
        private String[] field_order_type_info = new String[]{'countryCode','vatNumber'};
    }
    
    public class VATWebService {
        public String endpoint_x = 'http://ec.europa.eu/taxation_customs/vies/services/checkVatService';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:ec.europa.eu:taxud:vies:services:checkVat:types', 'IECVATUtil', 'urn:ec.europa.eu:taxud:vies:services:checkVat', 'IECVATUtil'};

        public IECVATUtil.VATResponse ValidateVAT(String countryCode,String vatNumber) {
            IECVATUtil.VATRequest request_x = new IECVATUtil.VATRequest();
            request_x.countryCode = countryCode;
            request_x.vatNumber = vatNumber;
            IECVATUtil.VATResponse response_x;
            Map<String, IECVATUtil.VATResponse> response_map_x = new Map<String, IECVATUtil.VATResponse>();
            response_map_x.put('response_x', response_x);
            
            if (!Test.isRunningTest()) {
	            WebServiceCallout.invoke(
	              this,
	              request_x,
	              response_map_x,
	              new String[]{endpoint_x,
	              '',
	              'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
	              'checkVat',
	              'urn:ec.europa.eu:taxud:vies:services:checkVat:types',
	              'checkVatResponse',
	              'IECVATUtil.VATResponse'}
	            );
	            response_x = response_map_x.get('response_x');
            }
            else {
            	response_x = new IECVATUtil.VATResponse();
            	response_x.valid = true;
            }

            return response_x;
        }
    }
}