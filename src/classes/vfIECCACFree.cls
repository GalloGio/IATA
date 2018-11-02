public without sharing class vfIECCACFree  extends IECPageController {

    public vfIECreCAPTCHA  reCAPTCHA        {get; set;}
    public boolean bShowRECAPTCHA           {get; set;}
    public Integer iRECAPTCHACount          {get; set;}
    


    public boolean bShowAgent               {get; set;}
    public boolean bShowAgency              {get; set;}
    public String sValidationCode           {get; set;}
    public String sCASSCode                 {get; set;}
    public Boolean bshowInvalidCode         {get; set;}
    public Boolean bshowreCAPTCHAFail       {get; set;}
    public Boolean baskCASSCode             {get; set;}
    
    public String sProdCACPro               {get; set;}
    public Boolean hasPageAccess            {get; set;}
    
    public Boolean bShowNoAgencyResults     {get; set;}
    public Boolean bShowNoAgentResults      {get; set;}
    public Boolean bIsValid                 {get; set;}
    public String sAgencyCode               {get; set;}
    public String sAgentCode                {get; set;}
    //RN-INC380530
    public String whichcountry {get;set;}


    /* Each item in the result List will contain the information 
     * as list of 4 string elements and they will be in the following order:
     *
     * [0] = Label
     * [1] = Tooltip
     * [2] = Data Type (S=status, T=text, A=Address,D=Date,L=link)
     * [3] = Data Value
     */
    public List<List<String>> lResultList {get; set;}
    
    
    
    //public GDP_Account__c oAgency {get; set;}
    public GDP_Products_Account_View__c oAgency {get; set;}
    public ID_Card__c oAgent {get; set;}



    public vfIECCACFree() {

        sProdCACPro = IEC_Settings__c.getOrgDefaults().Prod_CACPro__c;
        if (!Test.isRunningTest())  findLocation();
        
        sValidationCode = '';
        bShowAgency = bShowAgent = baskCASSCode = bShowNoAgencyResults = bShowNoAgentResults = bIsValid = false;
        lResultList = new List< List<String> >();
        
        reCAPTCHA = new vfIECreCAPTCHA();
        reCAPTCHA.verified = false;
         if (whichcountry == 'CN'){
            bShowRECAPTCHA = false;
        }else{
            bShowRECAPTCHA = true;
        }
        iRECAPTCHACount = 0;
        bshowreCAPTCHAFail = false;
        bshowInvalidCode = false;
        
    }


    public Pagereference pageLoad() {

        validateAccess();
        
        return null;
    }
    
    
     public void validateCode() {
        try {            
            // Reset showing the result sections
            bShowAgency = bShowAgent = false;
            oAgency = null;
            oAgent = null;
            lResultList.clear();    
            bshowreCAPTCHAFail = false;     
            bShowNoAgencyResults = false;
            bShowNoAgentResults = false;
            sAgencyCode = '';
            sAgentCode = '';
                        
            //Test code 7: 5755500
            //Test code 8: 96826376
            //Test error: 60500296
            //Test ICCArd: 5990078523
            //Test ICCArd:  5056008908     

            //exception for China INC380530
            if (whichcountry == 'CN'){
                reCAPTCHA.verified = true;
                bShowRECAPTCHA = false;
            }else{      
                if(!Test.isRunningTest() && !reCAPTCHA.verified && !reCAPTCHA.verify()){
                    //addErrorMessage('reCAPTCHA verification Failed' );
                    bshowreCAPTCHAFail = true;
                    reCAPTCHA.verified = false;
                    bShowRECAPTCHA = true;       
                    return;
                }

                //Only increment recaptcha count if no CASS number was requested. 
                // -- when CASS number is requested, it's considered part of the previous query
                if (!baskCASSCode)
                    iRECAPTCHACount++;
                
                //Validate reCAPTCHA First
                if (iRECAPTCHACount < 20) {
                    reCAPTCHA.verified = true;
                    bShowRECAPTCHA = false;     
                }   
                else {
                    reCAPTCHA.verified = false;
                    bShowRECAPTCHA = true;  
                    iRECAPTCHACount= 0; 
                }              
        }
                

            //Trim any leading or trailing spaces
            if (sValidationCode != null)
                sValidationCode = sValidationCode.trim();
                
            //Validate numerica values only 
            Pattern isnumbers = Pattern.Compile('^[0-9]+$');
            Matcher postalMatch = isnumbers.matcher(sValidationCode);

            if(!postalMatch.Matches()){
                bshowInvalidCode = true;
                baskCASSCode = false;
                sCASSCode = ''; 
                return;         
            }   
            
            
            if (validateAccess()) {

                bshowInvalidCode = false;
                
                //sAgencyCode = (sCASSCode != null && sCASSCode != '') ? sValidationCode + sCASSCode : sValidationCode;             
                // following the IATA_Code__c + CASS_Number__c + Check_Digit__c logic
               // sAgencyCode  logic moved to if statements bellow
       
                if (sValidationCode.length() == 7) {
                    sAgencyCode = sValidationCode;
                     queryByIATACode();
                }
                else if (sValidationCode.length() == 8) {
                    sAgencyCode = (sCASSCode != null && sCASSCode != '') ? sValidationCode.substring(0,7) + sCASSCode + sValidationCode.substring(7,8) : sValidationCode;
                    queryByAgencyCode_8();
                }               
                else if (sValidationCode.length() == 11 || sValidationCode.length() == 12) {
                    sAgencyCode = (sCASSCode != null && sCASSCode != '') ? sValidationCode.substring(0,7) + sCASSCode + sValidationCode.substring(7,8) : sValidationCode;
                    //sCASSCode = '';
                    queryByAgencyCode_11();
                }
                else if (sValidationCode.length() == 10) {
                    sAgentCode = sValidationCode;
                    queryByIDCard();
                }
                else {
                    bshowInvalidCode = true;
                    baskCASSCode = false;
                    sCASSCode = '';
                }
            }
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
    }
    
    
    
    private void queryByIDCard() {
        
        //Query the Agent
        oAgent = IECApplicationsManager.anonymousSearchAgentByVER(sValidationCode, IECConstants.ProductCategory_SF_CACFREE);

        //Handling VALID/INVALID
        if (oAgent != null) {
            bShowAgent = true;
            bIsValid = (oAgent.Card_Status__c != null && oAgent.Card_Status__c != '');
            bShowNoAgentResults = !bIsValid;
        }
        else {
            bIsValid = false;
            bShowNoAgentResults = true; 
        }
        
        //Clean input texts
        baskCASSCode = false;
        sValidationCode = '';
        sCASSCode = '';     
        
        

    }

    private void queryByIATACode() {
        
        List<GDP_Products_Account_View__c> result = IECApplicationsManager.anonymousSearchAgencyByIATACode(sValidationCode, sCASSCode, null, IECConstants.ProductCategory_SF_CACFREE);
                    
        //If more than 1 result, ask for CASS code
        if (result != null && result.size() > 1) {
            baskCASSCode = true;
            return;
        }
                    
        if (result != null && result.size() > 0) {
            oAgency = result[0];
            bShowAgency = true;
            bIsValid = (oAgency.Related_Accreditation_Class__r.Status__r != null && integer.valueOf(oAgency.Related_Accreditation_Class__r.Status__r.Code__c) >= 4);
            bShowNoAgencyResults = !bIsValid;
            if (bIsValid) sAgencyCode = oAgency.Agency_Code__c;
        }
        else {
            bIsValid = false;
            bShowNoAgencyResults = true;    
        }
        
        baskCASSCode = false;
        sValidationCode = '';
        sCASSCode = '';     
    }


    
    
    private void queryByAgencyCode_8() {
        
        try {
            String sIATACode = sValidationCode.substring(0,7);
            String sCheckCode =  sValidationCode.substring(sValidationCode.length()-1,sValidationCode.length());

            List<GDP_Products_Account_View__c> result = IECApplicationsManager.anonymousSearchAgencyByIATACode(sIATACode, sCASSCode, sCheckCode, IECConstants.ProductCategory_SF_CACFREE);
                    
            //If more than 1 result, ask for CASS code
            if (result != null && result.size() > 1) {
                baskCASSCode = true;
                return;
            }
            
            if (result != null && result.size() > 0) {
                oAgency = result[0];
                bShowAgency = true;
                bIsValid = (oAgency.Related_Accreditation_Class__r.Status__r != null && integer.valueOf(oAgency.Related_Accreditation_Class__r.Status__r.Code__c) >= 4);
                bShowNoAgencyResults = !bIsValid;
                if (bIsValid) sAgencyCode = oAgency.Agency_Code__c;
            }
            else {
                bIsValid = false;
                bShowNoAgencyResults = true;    
            }
            
            baskCASSCode = false;
            sValidationCode = '';
            sCASSCode = ''; 
    
        } 
        catch (Exception ex) {
            addErrorMessage('Error ' + ex.getMessage() + '<br />' + ex.getStackTraceString());
        }
        
    }
    
    
    
    
    private void queryByAgencyCode_11() {
        
        String sIATACode = sValidationCode.substring(0,7);
        String sCheckCode =  sValidationCode.substring(sValidationCode.length()-1,sValidationCode.length());
        
          if (sValidationCode.length() == 11)
              sCASSCode = sValidationCode.substring(7,10);
            else
              sCASSCode = sValidationCode.substring(7,11);
            
            
        List<GDP_Products_Account_View__c> result = IECApplicationsManager.anonymousSearchAgencyByIATACode(sIATACode, sCASSCode, sCheckCode, IECConstants.ProductCategory_SF_CACFREE);
                    
        //If more than 1 result, ask for CASS code
        if (result != null && result.size() > 1) {
            baskCASSCode = true;
            return;
        }
        
        if (result != null && result.size() > 0) {
            oAgency = result[0];
            bShowAgency = true;
            bIsValid = (oAgency.Related_Accreditation_Class__r.Status__r != null && integer.valueOf(oAgency.Related_Accreditation_Class__r.Status__r.Code__c) >= 4);
            bShowNoAgencyResults = !bIsValid;
            if (bIsValid) sAgencyCode = oAgency.Agency_Code__c;
        }
        else {
            bIsValid = false;
            bShowNoAgencyResults = true;
        }
        
        baskCASSCode = false;
        sValidationCode = '';
        sCASSCode = ''; 

    }   
    
        
    
    private Boolean validateAccess() {

        hasPageAccess = true;
        return true;
    }

    //RN-INC380530 - find access user country
    public void findLocation(){
        ISSP_CS__c cs = ISSP_CS__c.getInstance('ipinfo_token');
        String ipinfo_token = cs.value__c;
        String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');

        String IP_LOOKUP_URL = 'https://ipinfo.io/' + ipAddress + '/json?token=' + ipinfo_token;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(IP_LOOKUP_URL);
        req.setMethod('GET');
        req.setTimeout(2000);
        HttpResponse res;
        try{
            res = h.send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            system.debug('message:' + String.valueOf(parser));
            while (parser.nextToken() != null) {
                system.debug('field name:' + JSONToken.FIELD_NAME);
                system.debug('value:' + parser.getText());
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'country')) {
                    parser.nextToken();
                    system.debug('COUNTRY:' + parser.getText());
                    whichcountry = parser.getText();
                }
            }
        }catch(Exception e){
        }
    }   
    

}