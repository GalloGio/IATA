/**
@Author: One1link - Gavriel Talalai
@Description: One step portal user creation. The option will be available to portal
              Admins only.The option available through the "My contacts" tab click the button "create active..."
@Test class: Test_ISSP_PortalUserCreation  
*/
public with sharing class ISSP_PortalUserCreation {
    public Contact con{set;get;}
    public Contact currentCon{set;get;}
    public String retUrl{set;get;}
    private Contact newContact;
    public String countryId {set; get;}
    public String accountId {set; get;}
    public String lastName {set; get;}
    public String emailAddress {set; get;}
    public list<String> errorMessage {get; set;}

     //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    public String firstCommParam { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}
    
    public ISSP_PortalUserCreation() {
        popContact(); //Get the current contact assoc. with logged in portal user
        
        errorMessage = new list<string>();
        con = new Contact();
        if(communityName!=null && communityName=='CNS'){
            con.Community__c = 'CNS Customer Portal';
        }else{
            con.Community__c = 'ISS Customer Portal';
        }
       
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
    }
    /**
    Save the contact and creates a portal user.
    Immidiatly returns to the form to create new portal user 
    */
    public PageReference saveAndNew(){
        //Save the contact and create new portal user when possible
        Boolean res = save();
        if(!res){
            //restores the contact after rollback
            //con = newContact;
            return null;
        }
        con = newContact;
        return new PageReference('/apex/ISSP_PortalUserCreation?retUrl=' + retUrl + commParam);

    }
    /**
    Create portal user and go back to the retUrl that specified in the Url
    Parameters
    **/
    public PageReference saveActiveContact(){
        //Save the contact and create new portal user when possible
        Boolean res = save();
        if(!res){
            //restores the contact after rollback
            //con = newContact;
            return null;
        }
        return new PageReference('/ISSP_Contact?mid=M4S1&id=' + con.id + commParam);
        
    }
    public PageReference cancel(){
        return new PageReference(retUrl + firstCommParam);

    }
    public Boolean save(){
        errorMessage = new list<string>();
        
        string ErrFields = '';
        system.debug('lastName: ' + lastName);
        system.debug('emailAddress: ' + emailAddress);
        system.debug('accountId: ' + accountId);
        system.debug('con.Phone: ' + con.Phone); 
        if(lastName == null || lastName == ''){
           ErrFields += Schema.Contact.fields.LastName.getDescribe().getLabel()  + ', ';
        }
        if(emailAddress == null || emailAddress == ''){
           ErrFields += Schema.Contact.fields.Email.getDescribe().getLabel()  + ', ';
        }
        if(accountId == null || accountId == ''){
           ErrFields += Schema.Account.fields.Name.getDescribe().getLabel()  + ', ';
        }
        if(con.Phone == null || con.Phone == ''){
           ErrFields += Schema.Contact.fields.Phone.getDescribe().getLabel()  + ', ';
        }
        system.debug('ErrFields: ' + ErrFields);
        if (ErrFields != ''){
            String errorString = ErrFields + ' ' + system.Label.ISSP_Should_be_mandatory;
            errorMessage.add(errorString);
            return false;
        }
        else{
            List <Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email = :emailAddress];
            if(!contactList.isEmpty()){
                errorMessage.add('A user with the same email address alredy exists.');
                return false;
            }
        }
        
        Map<String,String> res;
        //Save Account,Iso country and prefered language in a temporary contact
        //In order to restore it after the rollback
        //newContact = customClone(con);
        //Save backup point before the contac is saved
        Savepoint sPointContact = Database.setSavepoint();
        try{
            if (countryId != null){
                con.ISO_Country__c = countryId;
            }
            if (accountId != null){
                con.AccountId = accountId;
            }
            con.LastName = lastName;
            con.Email = emailAddress;
            insert con;
            res = ISSP_PortalUserStatusChange.preformAction(con.id,'Approved User','');
            system.debug('AFTER USER CREATION: ' + res);
            con.User_Portal_Status__c = 'Approved User';
            update con;
        }
        catch(Exception e){
            //ApexPages.addMessages(e);
            errorMessage.add(e.getMessage());
            return false;
        }
        /*
        if(res.containsKey('error')){
            //if error occurred while creating a portal user erase the contact as well.
            Database.rollback(sPointContact);
            return false;
        }
        */
        return true;


    }
    private Contact customClone(Contact con){
        Contact newContact = new Contact();
        newContact.ISO_Country__c = con.ISO_Country__c;
        newContact.AccountId = con.AccountId;
        newContact.Preferred_Language__c = con.Preferred_Language__c;
        return newContact;

    }
    
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        
        List <IATA_ISO_Country__c> isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name');
        options.add(new SelectOption('', '--None--'));
        for(IATA_ISO_Country__c iso : isoList){
            options.add(new SelectOption(iso.Id,iso.Name));
        }
        return options;
    }
    
    public List<SelectOption> getAccounts() {
        List<SelectOption> options = new List<SelectOption>();
        
        List <Account> accountList = [SELECT Id, Name, IATA_ISO_Country__r.Name, Site, Sector__c, IATACode__c, Field_Head_Office__c
                                      FROM Account
                                     WHERE (Id = :currentCon.AccountId OR Top_Parent__c = :currentCon.AccountId) AND RecordType.DeveloperName IN ('IATA_Agency','IATA_Airline','IATA_Airline_BR','Standard_Account')
                                     ORDER BY RecordType.DeveloperName, Location_Type__c, Site
                                     ];
        options.add(new SelectOption('', '--None--'));
        for(Account thisAccount : accountList){
            String theLabel;
            if(thisAccount.Sector__c== 'Airline') {
                theLabel = thisAccount.Name + ' (' + thisAccount.Site + ')';
            if (thisAccount.Field_Head_Office__c == 'Headquarter'){
                theLabel = theLabel + ' - ' + thisAccount.Field_Head_Office__c;
            }
            } else {
                theLabel = thisAccount.Name + ' (' + thisAccount.IATACode__c + ')';
            }
            options.add(new SelectOption(thisAccount.Id, theLabel));
        }
        return options;
    }
    
    private void popContact(){
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        currentCon = DAL_ISSP.getContact(user.ContactId);
    }
}