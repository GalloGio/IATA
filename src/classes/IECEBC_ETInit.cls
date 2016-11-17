public class IECEBC_ETInit {
    
    public static final String SandboxEndpoint = 'https://webservice.test.exacttarget.com/Service.asmx';
    public static final String ProductionEndpoint = 'https://webservice.s7.exacttarget.com/Service.asmx';    
    public static final String SoapWSApi = 'http://exacttarget.com/wsdl/partnerAPI';
    public static 	String IECRestAPI {
    	get {
    		return IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/services/apexrest/';
    	}
    	set;
    }
    public static final	Integer TimeOut = 120000;
    
    
    public class Credentials{
        public String Username{get;set;}
        public String Password{get;set;} 
    }
    
    public static Credentials setCredentials(){
        Credentials cr = new Credentials();
        cr.Username = 'kejia.hu@cgi.com';
        cr.Password  = 'Alban2016%';         
        return cr;
    } 
}