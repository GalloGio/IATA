public without sharing class ISSP_LocalGroups {

    public static final set<String> ALLOWED_PROFILES = new set<String>{'ISS Portal Airline Delegated Admin User'};
    public list<WrapperLocalGroup> listWrapper {get;set;}

    private list<Account> listAccount;
    private User currentUser;
    public map<Id,String> mapClusterCountry;
    
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
        
        list<Participant__c> listParticipant = [
            SELECT Region__c, Country__c, Local_Group_Type__c, Cargo_Passenger__c, Participant_Type__c, Title__c, Email__c,
                Contact__c, Contact__r.Name, Local_Governance__r.Cargo_Passenger__c, Representing__c, Representing__r.Name,
                Local_Governance__r.Country__r.Name,
                Local_Governance__r.Country__r.IATA_Country_ZH__c,
                Local_Governance__r.Country__r.IATA_Country_SP__c,
                Local_Governance__r.Country__r.IATA_Country_PT__c,
                Local_Governance__r.Country__r.IATA_Country_JP__c,
                Local_Governance__r.Country__r.IATA_Country_IT__c,
                Local_Governance__r.Country__r.IATA_Country_FR__c,
                Local_Governance__r.Country__r.IATA_Contry_KR__c,
                Local_Governance__r.Country__r.IATA_COUNTRY_EN__c,
                Local_Governance__r.Cluster__c,
                Local_Governance__r.Cluster__r.Name,
                Local_Governance__r.Local_Governance_type__c,
                Local_Governance__r.Region__c,
                Local_Governance__r.Mission__c
            FROM Participant__c
            WHERE Contact__r.AccountId IN :listAccount
            AND Local_Governance__r.Recordtype.DeveloperName = :'Local_Groups'
            AND Local_Governance__r.Active__c = true
            ORDER BY Local_Governance__r.Cluster__r.Name ASC, Local_Governance__r.Country__r.Name ASC, Participant_Type__c ASC];
        
        initMapCluster(listParticipant);
        initListWrapper(listParticipant);
    }
    
    /**
        Creates a map with the clusters found in the main query with their
        country names translated to the selected language
    **/
    private void initMapCluster(list<Participant__c> listParticipant) {
        String fieldName = getIsoCountryFieldName();
        this.mapClusterCountry = new map<Id,String>();
        list<Id> listClusterId = new list<Id>();
        for (Participant__c participant: listParticipant) {
            listClusterId.add(participant.Local_Governance__r.Cluster__c);
        }
        for (Cluster_to_ISO_Country__c cc: [
                SELECT Cluster__c, IATA_ISO_Country__r.Name,
                    IATA_ISO_Country__r.IATA_Country_ZH__c,
                    IATA_ISO_Country__r.IATA_Country_SP__c,
                    IATA_ISO_Country__r.IATA_Country_PT__c,
                    IATA_ISO_Country__r.IATA_Country_JP__c,
                    IATA_ISO_Country__r.IATA_Country_IT__c,
                    IATA_ISO_Country__r.IATA_Country_FR__c,
                    IATA_ISO_Country__r.IATA_Contry_KR__c,
                    IATA_ISO_Country__r.IATA_COUNTRY_EN__c
                FROM Cluster_to_ISO_Country__c
                WHERE Cluster__c IN :listClusterId]) {
            String value = this.mapClusterCountry.get(cc.Cluster__c);
            value = value==null? '': value+', ';
            value += cc.IATA_ISO_Country__r.get(fieldName);
            this.mapClusterCountry.put(cc.Cluster__c,value);
        }
    }
    
    /**
        Transform the input list of Participants to a list of Wrappers
    **/
    private void initListWrapper(list<Participant__c> listParticipant) {
        this.listWrapper = new list<WrapperLocalGroup>();
        for (Participant__c participant: listParticipant) {
            String clusterTooltip = this.mapClusterCountry.get(participant.Local_Governance__r.Cluster__c);
            this.listWrapper.add(new WrapperLocalGroup(participant, clusterTooltip));
        }
    }
    
    /**
        Returns the field name in IATA_ISO_Country__c object that
        contains the selected translation
    **/
    public String getIsoCountryFieldName() {
        String locale = UserInfo.getLanguage();
        if (locale.startsWithIgnoreCase('ZH')) {
            return 'IATA_Country_ZH__c';
        }
        if (locale == 'es') {
            return 'IATA_Country_SP__c';
        }
        if (locale.startsWithIgnoreCase('PT')) {
            return 'IATA_Country_PT__c';
        }
        if (locale=='ja') {
            return 'IATA_Country_JP__c';
        }
        if (locale.startsWithIgnoreCase('IT')) {
            return 'IATA_Country_IT__c';
        }
        if (locale.startsWithIgnoreCase('FR')) {
            return 'IATA_Country_FR__c';
        }
        if (locale=='ko') {
            return 'IATA_Contry_KR__c';
        }
        return 'IATA_COUNTRY_EN__c';
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
    
    /**
        Return three special characters to be printed at the very beginning of a
        text file to indicate it's a unicode file
    **/
    public String getCSVHeader() {
        return EncodingUtil.convertFromHex('EFBBBF').toString();
    }
    
    public class WrapperLocalGroup {
        public Participant__c participant {get;set;}
        public String countryClusterTooltip {get;set;}
        public String groupTypeTooltip {get;set;}
        
        public WrapperLocalGroup(Participant__c p, String clusterTooltip) {
            this.participant = p;
            this.countryClusterTooltip = clusterTooltip==null? '': clusterTooltip;
            this.groupTypeTooltip = p.Local_Governance__r.Mission__c==null? '': p.Local_Governance__r.Mission__c;
        }
    }

}