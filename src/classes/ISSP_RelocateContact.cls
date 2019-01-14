public class ISSP_RelocateContact {

    public static final Id RECORDTYPE_AGENCY = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
    public static final Id RECORDTYPE_AIRLINE_BR = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
    public static final Id RECORDTYPE_AIRLINE_HQ = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
    public static final list<Id> VALID_ACCOUNT_RT = new list<String>{RECORDTYPE_AGENCY, RECORDTYPE_AIRLINE_BR, RECORDTYPE_AIRLINE_HQ};

    public list<String> errorMessage {get;set;}
    public Contact contact{get; set;}
    public Account selectedAccount {get;set;}
    public Id selectedAccountId {get;set;}
    public map<Id,Account> mapRelatedAccount {get; set;}

    public ISSP_RelocateContact(ApexPages.StandardController stdController) {
        try {
            this.errorMessage = new list<String>();
            
            this.contact = (Contact)stdController.getRecord();
            this.contact = [
            SELECT Id, Salutation, Name, AccountId, ISO_Country__c,
            Account.Name, Account.Site, Account.IATA_ISO_Country__c, Account.Location_Type__c, Account.BillingStreet,
            Account.BillingCity, Account.BillingPostalCode, Account.BillingState, Account.BillingCountry, Account.IsPartner,
            Account.IATA_ISO_Country__r.Name
            FROM Contact
            WHERE Id = :this.contact.Id];
            
            this.mapRelatedAccount = getMapHierarchyAccounts(contact.AccountId);
            
            if (getIsMapAccountsEmpty()) {
                this.errorMessage.add(Label.ISSP_Relocate_No_Accounts);
            }
        } catch(Exception e) {
            this.contact = null;
            this.mapRelatedAccount = null;
            this.errorMessage.add('No Contact selected');
        }
    }
    
    /**
        Checks that a contact was selected
        Redirects back to Contacts page if any error found
    **/
    public PageReference initAction() {
        if (this.contact == null) {
            return getHomePage();
        }
        return null;
    }
    
    /**
        Creates a list of selectOption with all accounts in the hierarchy
    **/
    public list<SelectOption> getListOptionAccount() {
        list<SelectOption> listOption = new list<SelectOption>();
        if (!this.mapRelatedAccount.isEmpty()) {
            listOption.add(new SelectOption('',Label.ISSP_Relocate_Select_Account));
            for (Account account: this.mapRelatedAccount.values()) {
                String label = account.Site + ' ' + account.Name + ' ' + account.IATA_ISO_Country__r.Name;
                listOption.add(new SelectOption(account.Id, label));
            }
        }
        return listOption;
    }
    
    /**
        Creates a map with all Accounts in the hierarchy
    **/
    @TestVisible
    private map<Id,Account> getMapHierarchyAccounts(Id accountId) {
        // find all parents for current account
        Account account = [
            Select id, Name,
                ParentId,
                Parent.ParentId,
                Parent.Parent.ParentId,
                Parent.Parent.Parent.ParentId,
                Parent.Parent.Parent.Parent.ParentId
            From Account
            Where id = :accountId ];

        // find the top parent
        Id parentId = null;
        if (account.ParentId == null ) {
            parentId = account.Id;
        } else if (account.Parent.ParentId == null ) {
            parentId = account.ParentId;
        } else if (account.Parent.Parent.ParentId == null ) {
            parentId = account.Parent.ParentId;
        } else if (account.Parent.Parent.Parent.ParentId == null ) {
            parentId = account.Parent.Parent.ParentId;
        } else if (account.Parent.Parent.Parent.Parent.ParentId == null ) {
            parentId = account.Parent.Parent.Parent.ParentId;
        } else {
            parentId = account.Parent.Parent.Parent.Parent.ParentId;
        }

        // Get all account in the hierarchy
        return new map<Id,Account>([
            SELECT Id,Name, Site, IATA_ISO_Country__c, Location_Type__c, BillingStreet, IsPartner,
                BillingCity, BillingPostalCode, BillingState, BillingCountry, IATA_ISO_Country__r.Name
            FROM Account
            WHERE RecordTypeId IN :VALID_ACCOUNT_RT
            AND Status__c != 'Terminated'
            AND Id != :accountId
            AND ( Id = :parentId
            OR ParentId = :parentId
            OR Parent.ParentId = :parentId
            OR Parent.Parent.ParentId = :parentId
            OR Parent.Parent.Parent.ParentId = :parentId
            OR Parent.Parent.Parent.Parent.ParentId = :parentId)]);
    }
    
    /**
        Returns true if the hierarchy account map is empty
    **/
    public boolean getIsMapAccountsEmpty() {
        return this.mapRelatedAccount==null || this.mapRelatedAccount.isEmpty();
    }
    
    /**
        Finds the account selected by the user
    **/
    public Pagereference selectAccount() {
        this.selectedAccount = null;
        if (this.mapRelatedAccount!=null) {
            this.selectedAccount = this.mapRelatedAccount.get(this.selectedAccountId);
        }
        return null;
    }
    
    /**
        Updates contact with the new selected account
    **/
    public PageReference RelocateContact() {
        try {
            this.errorMessage = new list<String>();
            // set  parent account as partner user 
            if (!this.selectedAccount.IsPartner) {
                this.selectedAccount.IsPartner = true;
                update this.selectedAccount;
            } 
            // relocate contact
            this.contact.AccountId = this.selectedAccountId;
            update this.contact;
            return getReturnPage();
 
        } catch (DMLException e) {
            for (Integer i=0; i<e.getNumDml(); i++) {
                this.errorMessage.add(e.getDmlMessage(i));
            }
        } catch (Exception e) {
            this.errorMessage.add(Label.ISSP_Relocate_Failed);
            System.debug('ERROR RelocateContact ' + e.getMessage());
        }
        return null;
    }
    
    /**
        Redirects to Contacts page
    **/
    public PageReference getReturnPage(){
        return new PageReference('/ISSP_Contact?Id=' + this.contact.Id+ '&mid=M4S1');
    }

    /**
        Redirects to Main Portal Page
    **/
    public PageReference getHomePage(){
        return new PageReference('/ISSP_Homepage?mid=M0S1');
    }

}