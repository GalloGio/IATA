public class IECEBC_ETInit {
    
    public static final String SandboxEndpoint = 'https://webservice.test.exacttarget.com/Service.asmx';
    public static final String ProductionEndpoint = 'https://webservice.exacttarget.com/Service.asmx';    
    public static final String SoapWSApi = 'http://exacttarget.com/wsdl/partnerAPI';
    public static final	String RestResourceAPI = 'https://3b-customer-portal-iata.cs87.force.com/iec/services/apexrest/Resources/';
    public static final	Integer TimeOut = 120000;
    
    
    public class Credentials{
        public String Username{get;set;}
        public String Password{get;set;} 
    }
    
    public static Credentials setCredentials(){
        Credentials cr = new Credentials();
        cr.Username = 'kejia.hu@cgi.com';
        cr.Password  = 'password1234%';         
        return cr;
    } 
}