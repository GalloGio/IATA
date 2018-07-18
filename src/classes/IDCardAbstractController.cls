public abstract class IDCardAbstractController {

    protected String selectedLanguage;
    
    public String Language {get; set;}
    
    public Boolean keyAccount {get; set;} 
    
    public Boolean personalPurchase  {get; set;}
    
    public static String IDCARD_PORTAL_LANG = 'idcard_portal_lang';
    
    public string errMsg = '';
    
    public boolean hasError = false;
    
    public  String iataCodeParameter{get;set;}
    
    public String vernumParameter{get; set;}
    
    public boolean mustRedirect {get;set;}
    
    public Map<String,Managed_agency__c> keyContactForAccountList {get;set;}
    
    public Map<String,Managed_agency__c> delegateKeyContactForAccountList {get;set;}
    
    public Map<String,Managed_agency__c> keyContactAndDelegateForAccountList {get;set;}
    
    public Integer availableIataCodeSize  {get;set;}
    
    public map<string,string> pagesurl{get; private set;} 
    
    public String getSelectedLanguage() {
        return selectedLanguage;
    }
    public void setSelectedLanguage(String s) {
        selectedLanguage = s;
    }
    
    
    
    public List<SelectOption> getLangItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('en_US','English'));
        options.add(new SelectOption('es','Español'));
        options.add(new SelectOption('fr','Français'));
        return options;
    }

    public List<SelectOption> getIataCodesItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(String iatacode :keyContactAndDelegateForAccountList.keySet()){
        	if(options.size()<1000)
            options.add(new SelectOption(iatacode,keyContactAndDelegateForAccountList.get(iatacode).account__r.Name ));
        }
        return options;
    }

    public void initialize(boolean secure){
        initialize();
        if(secure && vernumParameter==null){
            mustRedirect = true;
        }
    }

    public void initialize(){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'VER = '+IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_VER))));
        
        
        mustRedirect = false;
        pagesurl = new  map<string,string>();
        pagesurl.put('host' ,  ApexPages.currentPage().getHeaders().get('Host'));
        pagesurl.put('url' ,  apexpages.currentpage().getURL() );
        pagesurl.put('url2' ,  URL.getSalesforceBaseUrl().toExternalForm());  
        if (Site.getPathPrefix() != null)
            pagesurl.put('prefix' , Site.getPathPrefix());  
        else  pagesurl.put('prefix' ,'');  
        availableIataCodeSize = 0;
        // check to see if the language was stored in a cookie
        system.debug('[IDCardAbstractController] INITIALIZATION from ABstract ');
        Cookie langCookie = ApexPages.currentPage().getCookies().get(IDCARD_PORTAL_LANG);
        
        Cookie aCookie = ApexPages.currentPage().getCookies().get(IDCardUtil.PARAM_IATACODE);
        if (aCookie != null) 
          iataCodeParameter = aCookie.getValue();
          else iataCodeParameter = null;
        
        aCookie = ApexPages.currentPage().getCookies().get(IDCardUtil.PARAM_VER);
        if (aCookie != null) 
          vernumParameter = aCookie.getValue();
        else vernumParameter = null;
        
        hasError = false;
        if (langCookie == null) 
        {
            Language = 'en_US';
            selectedLanguage = Language;
            //selectedLanguage = null;
        }
        else 
        {
            Language = langCookie.getValue();
            selectedLanguage = Language;
        }       
        system.debug('[IDCardAbstractController] INIT OK');
        initialiateKeyContactList();
    }
    
    public boolean isKeyContactForIATAode(String iataCode){
        if(keyContactForAccountList==null)
            initialiateKeyContactList();
            return keyContactAndDelegateForAccountList.containskey(iataCode);
    }
    
    private void initialiateKeyContactList(){
        keyContactForAccountList = new Map<String,Managed_agency__c>();
        delegateKeyContactForAccountList = new Map<String,Managed_agency__c>();
        keyContactAndDelegateForAccountList = new Map<String,Managed_agency__c>();
        if(isKeyAccount(iataCodeParameter,vernumParameter)){
          /*  List<Managed_agency__c> allList = [select m.Id, m.Account__c, m.Account__r.Name, m.Account__r.IATACode__c,  m.Account__r.BillingCountry, m.delegate__c ,
                                                      m.Account__r.Type, m.Account__r.BillingState, m.Account__r.ID_Card_KeyAccount_features__c, m.Contact__r.Email, m.Contact__r.Name,
                                                      m.Account__r.ID_Card_Key_Account_Discount__c, m.Account__r.Short_Name__c
                                                from Managed_agency__c m where m.contact__r.Ver_Number_2__c = :vernumParameter ORDER BY m.Account__r.Short_Name__c, m.Account__r.IATACode__c];
           */ 
            
            for(Managed_agency__c ma:[select m.Id, m.Account__c, m.Account__r.Name, m.Account__r.IATACode__c,  m.Account__r.BillingCountry, m.delegate__c ,
                                                      m.Account__r.Type, m.Account__r.BillingState, m.Account__r.ID_Card_KeyAccount_features__c, m.Contact__r.Email, m.Contact__r.Name,
                                                      m.Account__r.ID_Card_Key_Account_Discount__c, m.Account__r.Short_Name__c
                                                from Managed_agency__c m where m.contact__r.Ver_Number_2__c = :vernumParameter ORDER BY m.Account__r.Short_Name__c, m.Account__r.IATACode__c]){
                keyContactAndDelegateForAccountList.put( ma.Account__r.IATACode__c, ma);
                if(ma.delegate__c)
                    delegateKeyContactForAccountList.put( ma.Account__r.IATACode__c, ma);
                else 
                    keyContactForAccountList.put( ma.Account__r.IATACode__c, ma);
            }
        }
        availableIataCodeSize = keyContactAndDelegateForAccountList.size();
    }
    
    public boolean getContactIsKeyOrDelegate(){
        return (keyContactAndDelegateForAccountList.keyset().size()>0);
    }
    
    /**
    return the IATA code for current Session
    */
    public String getIATACode(){
        if(iataCodeParameter!=null)
            return iataCodeParameter;
        return IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
    }
    
    public boolean isKeyAccount(String iataCode, String verNumber){
        Contact c;
        try{
            c = [select Account.IDCard_Key_Account__c,Account.ID_Card_KeyAccount_features__c  from Contact where Account.IATACode__c = :iataCode AND VER_Number_2__c = :verNumber limit 1];
        }catch(Exception e){
        	keyAccount = false;
            return false;
        }
        keyAccount = c.Account.IDCard_Key_Account__c==true;
        personalPurchase = (c.Account.ID_Card_KeyAccount_features__c != null && c.Account.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase));
        
        return keyAccount;
    }   
    
    public boolean isKeyAccount(String iataCode){
        Account acc;
        try{
            acc = [select IDCard_Key_Account__c, ID_Card_KeyAccount_features__c  from Account where IATACode__c = :iataCode limit 1];
        }catch(Exception e){
            keyAccount = false;
            return false;
        }
        keyAccount = acc.IDCard_Key_Account__c==true;
        personalPurchase = (acc.ID_Card_KeyAccount_features__c != null && acc.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase));
        
        return keyAccount;
    }   

    public boolean getHasError() {
        return hasError;
    }
    
    public string getErrMsg() {
        return errMsg;
    }
    
    public Pagereference rediredctoToLogin(){
        if(mustRedirect){
            Pagereference lpage = Page.IDCardLogin;
            lpage.setRedirect(true);
            return lpage;
        }
        return null;
    }
    
    public Pagereference logout(){
        pagesurl = null;
        iataCodeParameter = null;
        vernumParameter = null;
        availableIataCodeSize = 0;
        keyContactForAccountList = null;
        delegateKeyContactForAccountList = null;
        keyContactAndDelegateForAccountList = null;
        ApexPages.currentPage().setCookies(new Cookie[]{});
        mustRedirect = true;
        return rediredctoToLogin();
    }
}