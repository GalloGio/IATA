public without sharing class ISSP_LocalGroups {

    public static final set<String> ALLOWED_PROFILES = new set<String>{'ISS Portal Airline Delegated Admin User'};
    public static final Id RT_LOCALGROUP = [SELECT Id FROM Recordtype WHERE sObjectType = 'LocalGovernance__c' AND DeveloperName = 'Local_Groups'].Id;
    public static final list<String> LIST_FIELDNAME = new list<String>{'Region__c','Country__c','Local_Group_Type__c','Cargo_Passenger__c','Participant_Type__c','Contact__c','Title__c','Email__c'};
    public list<String> getListFieldName() { return LIST_FIELDNAME;}
    public list<Participant__c> listParticipant {get;set;}

    private list<Account> listAccount;
    private User currentUser;
    
    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

    public ISSP_LocalGroups() {
        // find current user
        this.currentUser = [
        Select Id, ContactId, Contact.AccountId, Contact.Account.Status__c, Profile.Name
        From User
        Where id = :UserInfo.getUserId()];
        
        // get HQ account
        Id parentAccountId = getMaxParentAccount(this.currentUser.Contact.AccountId);
        this.listAccount = getAllHierarchy(this.currentUser.Contact.AccountId);
        
        string queryString = 'SELECT Contact__r.Name, Local_Governance__r.Country__r.Name, Local_Governance__r.Local_Governance_type__c, Local_Governance__r.Cluster__r.Name,'
            + String.join(LIST_FIELDNAME,',')
            + ' FROM Participant__c'
            + ' WHERE Contact__r.AccountId IN :listAccount'
            + ' AND Local_Governance__r.RecordtypeId = :RT_LOCALGROUP'
            + ' AND Local_Governance__r.Active__c = true'
            + ' ORDER BY CreatedDate ';
        this.listParticipant = (list<Participant__c>)Database.query(queryString);
    }
    
    /**
        Method executed when page is loaded, it checks permissions
    **/
    public PageReference init() {
        if (ALLOWED_PROFILES.contains(this.currentUser.Profile.Name)) {
            return null;
        }
        return new PageReference('/ISSP_Homepage?mid=M0S1');
    }

    /**
        Get a list containing all account in the input account hirarchy
    **/
    private list<Account> getAllHierarchy(Id AccountId) {
        Id maxParentId = getMaxParentAccount(accountId);
        return [
            Select id, Name, ParentId
            From Account
            Where Id =:maxParentId
            Or ParentId = :maxParentId
            or Parent.ParentId = :maxParentId
            or Parent.Parent.ParentId = :maxParentId
            or Parent.Parent.Parent.ParentId = :maxParentId
            or Parent.Parent.Parent.Parent.ParentId = :maxParentId
        ];
    }
    
    /**
        Find Headquarter account (parent top account in the hierarchy)
    **/
    @TestVisible
    private Id getMaxParentAccount(Id accountId) {
        try {
            Account account = [
                Select id, Name,
                    ParentId,
                    Parent.ParentId,
                    Parent.Parent.ParentId,
                    Parent.Parent.Parent.ParentId,
                    Parent.Parent.Parent.Parent.ParentId
                From Account
                Where id = :accountId ];

            if (account.ParentId == null ) {
                return account.Id;
            }
            if (account.Parent.ParentId == null ) {
                return account.ParentId;
            }
            if (account.Parent.Parent.ParentId == null ) {
                return account.Parent.ParentId;
            }
            if (account.Parent.Parent.Parent.ParentId == null ) {
                return account.Parent.Parent.ParentId;
            }
            if (account.Parent.Parent.Parent.Parent.ParentId == null ) {
                return account.Parent.Parent.Parent.ParentId;
            }
            return account.Parent.Parent.Parent.Parent.ParentId;

        } catch (Exception e) {
            return accountId;
        }
    }
    
}