public with sharing class AWW_AccountGroupsCtrl {

    public Response wrapper {get;set;}

    public AWW_AccountGroupsCtrl (ApexPages.StandardController stdController) {
        Account acc = (Account) stdController.getRecord();
        this.wrapper = getParticipants(acc.Id, true);
    }    

    @AuraEnabled
    public static Id getReportId(){
        return [SELECT Id FROM Report WHERE DeveloperName = 'AGM_Groups_Participation_DO_NOT_EDIT' LIMIT 1].Id;
    }

    @AuraEnabled
    public static Response getParticipants(Id accountId, Boolean retrieveMainGroupParticipants){
        List<Account> relatedAccounts = [SELECT Id 
                                         FROM Account 
                                         WHERE Id = :accountId OR World_Wide_Account__c = :accountId OR 
                                            Top_Parent__r.World_Wide_Account__c = :accountId];


        String whereClause = ' AND Local_Governance__r.AM_Under__c <> null';
        List<Participant__c> participants = getParticipants(whereClause, relatedAccounts);
        Response res = processGroups(participants);
        
        if(retrieveMainGroupParticipants) {
            processMainGroupMembers(res,relatedAccounts);
        }

        return res;
    }

    private static List<Participant__c> getParticipants(String whereClause, List<Account> relatedAccounts) {
        String query = 'SELECT Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Salutation, Contact__r.Title, Participant_Type__c,' +
            'Contact__r.AM_First_Name_Latin_Char__c, Contact__r.AM_Last_Name_Latin_Char__c, Contact__r.AM_Job_Title_English__c,' +
            'Contact__r.Email,Hidden_Account_Id__c, Local_Governance__c, Local_Governance__r.Group_Owner__c,' +
            'Local_Governance__r.Name, Local_Governance__r.Mission__c, Local_Governance__r.Group_Owner__r.Name,' + 
            'Local_Governance__r.Group_Owner_Text__c, Local_Governance__r.AM_Under__r.Name, Representing__c,' + 
            'Local_Governance__r.AM_Under__r.Group_Owner__c, Local_Governance__r.AM_Under__r.Group_Owner__r.Name, Local_Governance__r.Country__c ' +
            'FROM Participant__c ';
        
        query += 'WHERE (Representing__c IN :relatedAccounts OR Contact__r.AccountId IN :relatedAccounts) AND Local_Governance__r.Active__c = true ';
        query += whereClause;
        query += ' ORDER BY Local_Governance__r.AM_Under__r.Name, Local_Governance__r.Name, Participant_Type__c';
        
        System.debug('query: ' +  query);

        return Database.query(query);
    }

    private static void processMainGroupMembers(Response res, List<Account> relatedAccounts) {
        List<AMPCoreGroups__c> coreGroups = AMPCoreGroups__c.getAll().values();
        List<String> groupNames = new List<String>();
        for(AMPCoreGroups__c coreGroup : coreGroups) {
            groupNames.add(coreGroup.Name);
        }
        
        Map<String,TopGroup> currentMainGroups = new Map<String,TopGroup>();
        for(TopGroup mainGroup : res.groups) {
            currentMainGroups.put(mainGroup.printableGoupName, mainGroup);
        }

        String whereClause = 'AND Local_Governance__r.Name IN (\'' + String.join(groupNames, '\',\'')+ '\')';
        List<Participant__c> participants = getParticipants(whereClause, relatedAccounts);
        System.debug('participants: ' + participants);
        for(Participant__c p : participants) {
            TopGroup mainGroup = currentMainGroups.get(p.Local_Governance__r.Name);
            if(mainGroup == null) {
                String ownerName = p.Local_Governance__r.Group_Owner__c == null ? '' : p.Local_Governance__r.Group_Owner__r.Name;
                mainGroup = new TopGroup(null, p.Local_Governance__r.Name, ownerName);
                currentMainGroups.put(p.Local_Governance__r.Name, mainGroup);
            }

            String role = p.Participant_Type__c == null ? '' : p.Participant_Type__c.replace('/^\\d+\\s/','');
            String salutation = p.Contact__r.Salutation;
            String firstName = p.Contact__r.FirstName;
            String lastName = p.Contact__r.LastName;
            String title = p.Contact__r.Title;
            String email = p.Contact__r.Email;
            Member m = new Member(null,role,salutation,firstName,lastName,title,email,p.Representing__c <> null);
            mainGroup.members.add(m);
        }
    }

    private static Response processGroups(List<Participant__c> participants) {
        Response res = new Response();
        Map<String,TopGroup> topGroups = new Map<String,TopGroup>();
        Map<String,LocalGroup> localGroups = new Map<String,LocalGroup>();
        Map<String,List<String>> childRelations = new Map<String,List<String>>();

        Integer index = 0;
        for(Participant__c p : participants) {
            TopGroup tg = topGroups.get(p.Local_Governance__r.AM_Under__r.Name);
            if(tg == null) {
                String ownerName = p.Local_Governance__r.AM_Under__r.Group_Owner__c == null ? '' : p.Local_Governance__r.AM_Under__r.Group_Owner__r.Name;
                tg = new TopGroup('top-group-'+index, p.Local_Governance__r.AM_Under__r.Name, ownerName);
                topGroups.put(p.Local_Governance__r.AM_Under__r.Name, tg);
                childRelations.put(tg.rowId, new List<String>());
                index++;
            }

            LocalGroup lg = localGroups.get(p.Local_Governance__r.Name);
            if(lg == null) {
                String ownerName = p.Local_Governance__r.Group_Owner__c == null ? '' : p.Local_Governance__r.Group_Owner__r.Name;
                lg = new LocalGroup('local-group-'+index,p.Local_Governance__r.Name,p.Local_Governance__c, ownerName, p.Local_Governance__r.Mission__c, p.Local_Governance__r.Country__c);
                localGroups.put(p.Local_Governance__r.Name, lg);
                tg.childrens.add(lg);
                childRelations.put(lg.rowId, new List<String>());
                childRelations.get(tg.rowId).add(lg.rowId);
                index++;
            }

            String role = p.Participant_Type__c == null ? '' : p.Participant_Type__c.replace('/^\\d+\\s/','');
            String salutation = p.Contact__r.Salutation;
            String firstName = p.Contact__r.FirstName;
            String lastName = p.Contact__r.LastName;
            String title = p.Contact__r.Title;
            String email = p.Contact__r.Email;
            Member m = new Member('member-'+index, role, salutation, firstName, lastName, title, email,  p.Representing__c <> null);
            lg.childrens.add(m);
            childRelations.get(lg.rowId).add(m.rowId);
            index++;

            res.hasRepresentatives |= p.Representing__c <> null;
        }

        res.groups = topGroups.values();
        res.expandedRows = childRelations;
        return res;
    }

    public class Response {
        @AuraEnabled public List<TopGroup> groups {get;set;}
        @AuraEnabled public Map<String,List<String>> expandedRows {get;set;}
        @AuraEnabled public Boolean hasRepresentatives {get;set;}
        @AuraEnabled public List<IATA_ISO_Country__c> countries {get;set;}

        public Response() {
            this.groups = new List<TopGroup>();
            this.expandedRows = new Map<String,List<String>>();
            this.hasRepresentatives = false;
            this.countries = new List<IATA_ISO_Country__c> {new IATA_ISO_Country__c(Name= 'All')};
            this.countries.addAll([
                SELECT Id, Name 
                FROM IATA_ISO_Country__c 
                WHERE NOT ISO_Code__c IN ('XX', 'WW') 
                ORDER BY Name ASC NULLS FIRST]);
        }

    }

    public class TopGroup {
        @AuraEnabled public String rowId {get;set;}
        @AuraEnabled public String rowId_expand {get;set;}
        @AuraEnabled public String rowId_collapse {get;set;}
        @AuraEnabled public String groupName {get;set;}
        @AuraEnabled public List<LocalGroup> childrens {get;set;}
        //only used for print
        public List<Member> members {get;set;}
        public String printableGoupName {get;set;}
        public String ownerName {get;set;}

        public TopGroup(String rowId, String groupName, String ownerName) {
            this.rowId = rowId;
            this.rowId_collapse = 'collapse_' + rowId;
            this.rowId_expand = 'expand_' + rowId;
            this.groupName = 'Under ' + groupName;
            this.printableGoupName = groupName;
            this.ownerName = ownerName;
            this.childrens = new List<LocalGroup>();
            this.members = new List<Member>();
        }
    }

    public class LocalGroup {
        @AuraEnabled public String rowId {get;set;}
        @AuraEnabled public String rowId_expand {get;set;}
        @AuraEnabled public String rowId_collapse {get;set;}
        @AuraEnabled public String groupName {get;set;}
        @AuraEnabled public String groupLink {get;set;}
        @AuraEnabled public String ownerName {get;set;}
        @AuraEnabled public String mission {get;set;}
        @AuraEnabled public List<Member> childrens {get;set;}
        @AuraEnabled public Id countryId {get;set;}
    
        public LocalGroup(String rowId, String groupName, String groupLink, String ownerName, String mission, Id countryId) {
            this.rowId = rowId;
            this.rowId_collapse = 'collapse_' + rowId;
            this.rowId_expand = 'expand_' + rowId;
            this.groupName = groupName;
            this.groupLink = '/' + groupLink;
            this.ownerName = ownerName;
            this.mission = mission;
            this.countryId = countryId;
            this.childrens = new List<Member>();
        }
    }

    public class Member {
        @AuraEnabled public String rowId {get;set;}
        @AuraEnabled public String role {get;set;}
        @AuraEnabled public String salutation {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public Boolean isRepresentative {get;set;}

        public Member(String rowId, String role, String salutation, String firstName, String lastName, String title, String email, Boolean isRepresentative) {
            this.rowId = rowId;
            this.role = role;
            this.salutation = salutation;
            this.firstName = firstName;
            this.lastName = lastName;
            this.title = title;
            this.email = email;
            this.isRepresentative = isRepresentative;
        }
    }
    
}