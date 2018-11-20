/**
 * Handles the login of the IFAP customer portal
 */
public class IFAP_SiteLoginController {
    
    public String username {get; set;}
    public String password {get; set;}
    
    public String Language {get; set;}
    
    public String returnURL;
    
    private static Id ORG_ID = '00D2000000008TF'; //PROD
   
    private static Id PORTAL_ID = '06020000000UPu7'; // PROD
   
    private static String SF_BASE_URL = 'https://iata.my.salesforce.com'; //PROD
    
    private static String IFAP_PORTAL_LANG = 'ifap_portal_lang';
    private boolean languageChanged = false;
    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    
    private String selectedLanguage;
    public String getSelectedLanguage() {
        return selectedLanguage;
    }
    public void setSelectedLanguage(String s) {
        selectedLanguage = s;
    }
    
    private boolean hasLoggingError = false;
    public boolean getHasLoggingError() {
        return hasLoggingError;
    }
    
    public List<SelectOption> getLangItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('en_US','English'));
        options.add(new SelectOption('es','Español'));
        options.add(new SelectOption('fr','Français'));
        options.add(new SelectOption('it','Italiano'));
        options.add(new SelectOption('ja','日本語'));
        options.add(new SelectOption('ko','한국어'));
      
        options.add(new SelectOption('zh_CN','中文（简体）'));
        options.add(new SelectOption('pt_BR','Português (Brasil)'));
        options.add(new SelectOption('ru','Русский'));
        return options;
    }
    
    public IFAP_SiteLoginController() {

        // check to see if the language was stored in a cookie
        Cookie langCookie = ApexPages.currentPage().getCookies().get(IFAP_PORTAL_LANG);
        if (langCookie == null) {
          
            Language = 'en';
           
            selectedLanguage = null;
        }
        else {
            Language = langCookie.getValue();
            selectedLanguage = Language;
            languageChanged = true;
        }       
    }
    
    public pageReference login() {

        returnURL = Apexpages.currentpage().getParameters().get('caseId');
        
        if (username == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'The username field is required.');
            ApexPages.addMessage(msg);
            return null;
        }
        if (password == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'The password field is required.');
            ApexPages.addMessage(msg);
            return null;
        }

        //Redirect to IFAP Portal
        String startUrl = SF_BASE_URL+'/secur/login_portal.jsp';
        startUrl += '?orgId='+ORG_ID + '&portalId=' +PORTAL_ID;
        startUrl += '&useSecure=true';
        startUrl += '&un=' + username;
        startUrl += '&pw='+ password;
  
        if(returnURL != null){
            startUrl += '&startURL='+ returnURL;
        }
  
        PageReference portalPage = new PageReference(startUrl);
        
        PageReference p = Site.login(username, password, startUrl);
        if (p == null) {
            
            PageReference p2 = Site.login(username, password, null);
            
            hasLoggingError = true;
            return p2;
        }
        else{
            if (!startUrl.contains('&startURL=')){
                System.debug('Portal Page => ' + portalPage);
                User[] theUser = [Select Username, ContactId, AccountId, LanguageLocaleKey From User WHERE Username =: username];
                if (theUser.size() > 0){
                    
                    // new feature: if the user has selected a different language (on the page) than the one set in the user preference, update his preferred language
                    if (selectedLanguage != null && languageChanged && selectedLanguage != theUser[0].LanguageLocaleKey) {
                        theUser[0].LanguageLocaleKey = selectedLanguage;
                        update theUser[0];
                    }
                    
                    List<Case> agentCasesIDs = [SELECT ID FROM Case WHERE recordtypeId =: IFAPcaseRecordTypeID and contactid =: theUser[0].contactId AND AccountId =: theUser[0].AccountId AND status NOT IN ('Closed')];
                    if (agentCasesIDs.size() > 0){
                        if(agentCasesIDs.size() == 1){
                            System.debug('Case ID : ' + agentCasesIDs[0].Id);
                            startUrl += '&startURL=' + agentCasesIDs[0].Id;
                            PageReference page = new PageReference(startUrl);
                            page.setRedirect(true);
                            return page;                            
                        }
                        // Else we do nothing the default landing tab is set to be the case tab                     
                    }
                }
            } 
            portalPage.setRedirect(true);
            return portalPage;
        }
        //else return portalPage;
    }
}