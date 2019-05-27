public with sharing class PortalSupportReachUsCreateNewCaseCtrl {
    
    private final static Integer MAX_RESULTS = 100;
    
    //Searches accounts on user input on the IATA Codes field. MAX RESULTS set to 100 as a Limit for the search (let's NOT destroy salesforce)
    @AuraEnabled(Cacheable=true)
    public static List<PortalLookupSearchResult> searchAccounts(String searchTerm) {
        // Prepare query paramters
        searchTerm = '%' + searchTerm + '%';
        
        User user   = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact con = DAL_ISSP.getContact(user.ContactId);
        
        ID accountId = con.AccountId;
        
        // Execute search query
        List<Account> searchResults = [SELECT Id,
                                       IATAcode__c,
                                       BillingCity
                                       FROM Account
                                       WHERE (Id =:accountId 
                                              OR ParentId =:accountId 
                                              OR Parent.ParentId =:accountId 
                                              OR Parent.Parent.ParentId =:accountId 
                                              OR Parent.Parent.Parent.ParentId =:accountId 
                                              OR Parent.Parent.Parent.Parent.ParentId =:accountId)
                                       AND 
                                       (
                                           (IATAcode__c != null) 								   
                                           AND 
                                           (IATAcode__c like :searchTerm OR BillingCity like :searchTerm)
                                       )
                                       LIMIT :MAX_RESULTS];
        
        
        // Prepare results
        List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();
        
        // Extract Accounts & convert them into PortalLookupSearchResult (check this class for more info)
        String accountIcon = 'standard:account';
        Account [] accounts = searchResults;
        for (Account account : accounts) {
            if(account.BillingCity ==null) {
                results.add(new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account • '+ 'Lisbon'));
            }else{
                results.add(new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account • '+ account.BillingCity));
            }
        }
        
        return results;
    }

    //Grabs the related accounts of the user once he gets to the page.
    @AuraEnabled(Cacheable=true)
    public static List<PortalLookupSearchResult> getRelatedAccounts(){
        User user   = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact con = DAL_ISSP.getContact(user.ContactId);
        
        ID accountId = con.AccountId;
        
        // Execute search query
        List<Account> searchResults = [SELECT Id,
                                       IATAcode__c,
                                       BillingCity
                                       FROM Account
                                       WHERE (Id =:accountId 
                                              OR ParentId =:accountId 
                                              OR Parent.ParentId =:accountId 
                                              OR Parent.Parent.ParentId =:accountId 
                                              OR Parent.Parent.Parent.ParentId =:accountId 
                                              OR Parent.Parent.Parent.Parent.ParentId =:accountId)
                                       AND IATAcode__c != null 						
                                       LIMIT :MAX_RESULTS];
        // Prepare results
        List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();
        
        // Extract Accounts & convert them into PortalLookupSearchResult (check this class for more info)
        String accountIcon = 'standard:account';
        Account [] accounts = searchResults;
        for (Account account : accounts) {
            if(account.BillingCity ==null) {
                results.add(new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account • '+ 'Lisbon'));
            }else{
                results.add(new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account • '+ account.BillingCity));
            }
        }
        
        return results;
    }

    //Searches contacts on user input on the Email Recipient field.
    @AuraEnabled(Cacheable=true)
    public static List<PortalLookupSearchResult> searchContacts(String searchTerm) {
        // Prepare query paramters
        searchTerm = '%' + searchTerm + '%';
       // Execute search query
        User user   = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact con = DAL_ISSP.getContact(user.ContactId);

        List<Contact> searchResults = [SELECT Id, Name, Email 
                                        FROM Contact 
                                        WHERE Email != :con.Email 
                                        AND (Email like :searchTerm OR Name like :searchTerm)
                                        LIMIT :MAX_RESULTS];

        // Prepare results
        List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();
        
        // Extract Contacts & convert them into PortalLookupSearchResult (check this class for more info)
        String contactIcon = 'standard:contact';
        Contact [] contacts = searchResults;
        for (Contact contact : contacts) {
                results.add(new PortalLookupSearchResult(contact.Id, 'Contact', contactIcon, contact.Email, contact.Name));
        }
        
        return results;
    }

//Grabs the related contacts of the user once he gets to the page.
@AuraEnabled(Cacheable=true)
    public static List<PortalLookupSearchResult> getRelatedContacts(){
        // Execute search query
        User user   = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact con = DAL_ISSP.getContact(user.ContactId);

        List<Contact> searchResults = [SELECT Id, Name, Email FROM Contact WHERE Email != :con.Email LIMIT :MAX_RESULTS];

        // Prepare results
        List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();
        
        // Extract Contacts & convert them into PortalLookupSearchResult (check this class for more info)
        String contactIcon = 'standard:contact';
        Contact [] contacts = searchResults;
        for (Contact contact : contacts) {
                results.add(new PortalLookupSearchResult(contact.Id, 'Contact', contactIcon, contact.Email, contact.Name));
        }
        
        return results;
    }

    //Checks if the user has an Agent profile. (He could be after Neo you know...)
    @AuraEnabled(Cacheable=true)
    public static Boolean isAgentProfile() {
        User user = [SELECT Profile_Name__c FROM User WHERE ID =: Userinfo.getUserId() LIMIT 1];
        
        if(user.Profile_Name__c.contains('ISS Portal Agency')){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Creates a Case once the user reaches the page and sends it over to the JS for further editting. 
    @AuraEnabled(Cacheable=true)
    public static Case createCase(String countryiso) {
        Case newCase = new Case();
        
        User user   = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact contact = DAL_ISSP.getContact(user.ContactId);
        
        Map<String,String> recordTypeCountry = PortalSupportReachUsCtrl.getCaseTypeAndCountry(contact, countryiso);
        
        if(recordTypeCountry != null) {
            
            newCase.RecordTypeId = recordTypeCountry.get('RecordType');
            newCase.Region__c = recordTypeCountry.get('Region');
            newCase.BSPCountry__c = recordTypeCountry.get('Country') == null ? '' : recordTypeCountry.get('Country');
            newCase.Status = 'Open';
            newCase.CaseArea__c = 'Customer Portal';
            newCase.Country_concerned_by_the_query__c = recordTypeCountry.get('Country') == null ? '' : recordTypeCountry.get('Country');
            newCase.Origin = 'Portal';
            
            if(countryiso == null || countryiso == '') {
                newCase.IFAP_Country_ISO__c = contact.Account.Country_ISO_Code__c;
            }else{
                newCase.IFAP_Country_ISO__c = countryiso;
            }
            return newCase;
        }else{
            throw new System.AuraHandledException('Error. No Record Type detected. Case cannot be created');
        }
    }
    
    //Inserts the Case. But sets a savepoint in case the Emails do not exist.
    @AuraEnabled
    public static Case insertCase(Case caseToInsert, List<String> recipientsToAdd) {
        try{
            Savepoint sp = Database.setSavepoint();

            Database.insert(caseToInsert);

            Set<String> setRecipients = new Set<String>();
            for(String recipient : recipientsToAdd ){
                setRecipients.add(recipient);
            }  

            list<String> listWrongEmails = new list<String>();
            if(!setRecipients.isEmpty()){
                list<Contact> listContact = [SELECT Id, Email FROM Contact WHERE Email IN :setRecipients];

                for(String email : recipientsToAdd){
                    if (!isEmailInContactList(email, listContact)) {
                        listWrongEmails.add(email);
                    }
                }
                if (!listWrongEmails.isEmpty()) {
                    Database.rollback(sp);
                    throw new AuraHandledException(Label.ISSP_CCOther_Wrong_Emails.replace('{0}',String.valueOf(listWrongEmails)));
                }else{
                    String emailsForCase = createCaseTeamMemberList(caseToInsert, listContact);
                    caseToInsert.E2CP__AdditionalCC__c = emailsForCase;
                    Database.update(caseToInsert);
                }
            }
        }
        catch(DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
        return [SELECT Id, CaseNumber FROM Case WHERE id =: caseToInsert.Id LIMIT 1];
    }
    
    //Checks if the emails are according to what is in the database.
    private static Boolean isEmailInContactList(String email, list<Contact> listContact) {
        for (Contact contact: listContact) {
            if (email == contact.Email) {
                return true;
            }
        } 
        return false;
    }
    
    //Creates a CaseTeamMember with the contacts (related to the emails of course)
    private static String createCaseTeamMemberList(Case cse, list<Contact> listContact) {
        list<CaseTeamMember > listCaseTeam = new list<CaseTeamMember>();
        list<String> listEmail = new list<String>();
        String IdTeamRole = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role' LIMIT 1].Id;
        for (Contact contact: listContact) {
            
            listCaseTeam.add(new CaseTeamMember(
                ParentId = cse.Id,
                MemberId = contact.Id,
                TeamRoleId = IdTeamRole
            ));
            listEmail.add(contact.Email);
        }
        insert listCaseTeam;
        String stringEmails = String.join(listEmail,',');
        return stringEmails;
    }
}