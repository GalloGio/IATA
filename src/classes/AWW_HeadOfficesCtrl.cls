public with sharing class AWW_HeadOfficesCtrl {

    public List<AccountWrapper> headOffices {get;set;}

    @AuraEnabled
    public static Boolean getUserAccessRightsAMPAgencyManagement() {
        List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN ('AMP_Agency_Management')
        ];

        if(permissions.isEmpty()) {
            return false;
        } else {
            return (permissions[0].PermissionSet.Name == 'AMP_Agency_Management' ? true : false);
        }
    }
    
    public AWW_HeadOfficesCtrl (ApexPages.StandardController stdController) {
        Account acc = (Account) stdController.getRecord();
        this.headOffices = getHeadOffices(acc.Id);
    }

    @AuraEnabled
    public static List<AccountWrapper> getHeadOffices(Id accountId) {
        List<Account> accounts =  [SELECT Name, IATACode__c, Location_Type__c, Location_Class__c, IATA_ISO_Country__r.Name, Top_Parent__c
                                   FROM Account 
                                   WHERE World_Wide_Account__c = :accountId ORDER BY Name];

        List<AccountWrapper> res = new List<AccountWrapper>();
        for(Account acc : accounts) {
            res.add(new AccountWrapper(acc));
        }

        return res;
    }

    @AuraEnabled
    public static List<AccountWrapper> searchAccounts(String key, Id accountId, String typeOperation){
        List<AccountWrapper> res = new List<AccountWrapper>();
        Set<String> locationTypes = new Set<String> {'GE', 'HE', 'HO', 'AO'};
        String queryStr = 'SELECT Name, IATACode__c, Location_Type__c, Location_Class__c, IATA_ISO_Country__r.Name, Top_Parent__c ';
        queryStr += 'FROM Account ';

        if(typeOperation == 'add') {
            queryStr += 'WHERE World_Wide_Account__c <> :accountId AND Top_Parent__c = null AND ';
        } else {
            queryStr += 'WHERE World_Wide_Account__c = :accountId AND ';
        }

        queryStr += '(Name LIKE \'%' + key +'%\' OR IATACode__c LIKE \'%' + key +'%\')';
        queryStr += ' AND Location_Type__c IN :locationTypes';

        List<Account> accs = (List<Account>) Database.query(queryStr);
        for(Account acc : accs) {
            res.add(new AccountWrapper(acc));
        }

        return res;
    }

    @AuraEnabled
    public static Response applyChangesToHierarchy(Id parentId, List<Id> childIds, String operationType){
        List<Account> accounts = new List<Account>();
        Id valueToApply = operationType == 'add' ? parentId : null;
        for(Id accountId : childIds) {
            accounts.add(new Account(Id= accountId, World_Wide_Account__c= valueToApply));
        }

        try {
            update accounts;
            return new Response(true, 'Success');
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAgencyHierarchy(Id topParentId) {
        List<Account> accounts = [SELECT Id, Name,  Location_Type__c, Location_Class__c, IATACode__c, toLabel(Sector__c), 
                                    toLabel(Category__c), IATA_ISO_Country__r.Name, Top_Parent__c, ParentId
                                  FROM Account
                                  WHERE Id = :topParentId OR Top_Parent__c = :topParentId
                                  ORDER BY Top_Parent__c, ParentId, Name ASC NULLS FIRST];

        Hierarchy gHierarchy = new Hierarchy();
        Map<Id,HierarchyNode> mapNodes = new Map<Id,HierarchyNode>();
        for(Account acc : accounts) {
            mapNodes.put(acc.Id, new HierarchyNode(acc));
        }

        for(Account acc : accounts) {
            HierarchyNode node = mapNodes.get(acc.Id);
            
            if(acc.ParentId <> null) {
                HierarchyNode parentNode = mapNodes.get(acc.ParentId);
                parentNode.childNodes.add(node);
                gHierarchy.expandedNodes.add(acc.ParentId);
            } else {
                gHierarchy.hierarchyNodes.add(node);
            }          
        }

        String res = JSON.serialize(gHierarchy);
        res = res.replaceAll('childNodes', '_children');
        res = res.replaceAll(',"_children":\\[\\]','');
        return res;
    }

    public class AccountWrapper {
        @AuraEnabled public Id topParentId {get;set;}
        @AuraEnabled public Id accountId {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String accountLink {get;set;}
        @AuraEnabled public String locationType {get;set;}
        @AuraEnabled public String iataCode {get;set;}
        @AuraEnabled public String country {get;set;}

        public AccountWrapper(Account acc) {
            this.topParentId = acc.Top_Parent__c;
            this.accountId = acc.Id;
            this.accountName = acc.Name;
            this.accountLink = '/' + acc.Id;
            this.locationType = acc.Location_Type__c;
            this.iataCode = acc.IATACode__c;
            this.country = acc.IATA_ISO_Country__c == null ? '' : acc.IATA_ISO_Country__r.Name;
        }
    }

    public class Response {
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get;set;}

        public Response(Boolean isSuccess, String message) {
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }

    public class Hierarchy {
        @AuraEnabled List<HierarchyNode> hierarchyNodes {get;set;}
        @AuraEnabled Set<Id> expandedNodes {get;set;}

        public Hierarchy() {
            this.hierarchyNodes = new List<HierarchyNode>();
            this.expandedNodes = new Set<Id>();
        }
    }

    public class HierarchyNode {
        @AuraEnabled public Id accountId {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String accountLink {get;set;}
        @AuraEnabled public String locationType {get;set;}
        @AuraEnabled public String locationClass {get;set;}
        @AuraEnabled public String iataCode {get;set;}
        @AuraEnabled public String sector {get;set;}
        @AuraEnabled public String category {get;set;}
        @AuraEnabled public String country {get;set;}
        @AuraEnabled List<HierarchyNode> childNodes {get;set;}

        public HierarchyNode(Account acc) {
            this.accountId = acc.Id;
            this.accountName = acc.Name;
            this.accountLink = '/' +  acc.Id;
            this.locationType = acc.Location_Type__c;
            this.locationClass = acc.Location_Class__c;
            this.iataCode = acc.IATACode__c;
            this.sector = acc.Sector__c;
            this.category = acc.Category__c;
            this.country = acc.IATA_ISO_Country__c <> null ? acc.IATA_ISO_Country__r.Name : '';
            this.childNodes = new List<HierarchyNode>();
        }
    }
    
}