public with sharing class ISSP_CompanyInformationEmaDomVal {

    /**
     * Attributes
     */
    public Contact con { get;set; }
    public String getEmaDomValUrlNew() {
        // Create new url
        PageReference pageReference = new Pagereference('/ISSP_CompanyInformation_emadomval');
        pageReference.getParameters().put('successfulInsert', 'true');

        // And return it in String
        return pageReference.getUrl();
    }

    public String getEmaDomValUrlDel() {
        // Create new url
        Pagereference pageReference = new Pagereference('/ISSP_CompanyInformation_emadomval');
        pageReference.getParameters().put('successfulDelete', 'true');

        // And return it in String
        return pageReference.getUrl();
    }

    /**
     * Main constructor
     */
    public ISSP_CompanyInformationEmaDomVal() {

        // Get right contact and update con attribute
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);

    }

    /**
     * Get valid domains
     */
    public List<Account_Domain__c> validEmailDomains {
        get {
            return AccountDomainHandler.getAccountDomains(this.con.AccountId);
        }
        set;
    }

    /**
     * Getter / Setter
     */
    @RemoteAction
    public static void setAccountDomain(String accountDomainName, String accountId) {
        AccountDomainHandler.insertAccountDomain(accountDomainName, accountId);
    }

    /**
     * Delete an AccountDomain
     */
    @RemoteAction
    public static void deleteAccountDomain(String accountDomainId) {
        AccountDomainHandler.deleteAccountDomain(accountDomainId);
    }

    /**
    * Navigate back to ISSP_CompanyInformation
    */
    public Pagereference goBackToCompanyInformation() {

        // Create new url
        Pagereference pageReference = new Pagereference('/ISSP_CompanyInformation');

        // And return it
        return pageReference;

    }

    /**
        Checks if current page can be used by current user
        A user must be admin and related account Recordtype in the available RTs in ISSP_AccountDomainPermission__c
    **/
    public PageReference checkPermission() {
        Boolean rtPermission =  ISSP_AccountDomainPermission__c.getInstance(this.con.Account.RecordType.DeveloperName) != null;
        Boolean isAdmin = (con != null && (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' ));
        if ( rtPermission && isAdmin ) {
            return null;
        } else {
            return goBackToCompanyInformation();
        }
    }

}
