/**
    This class handles trigger actions for CNS Cases
**/
global class CNSCaseManager {

    public static final Id RECORDTYPE_CNS = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CNS_Collection_Process');
    public static final Id RECORDTYPE_SIDRA_LITE = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
    public static final Id RECORDTYPE_IFAP = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

    public static Set<Id> cnsRelatedRecordTypes = new Set<Id>{RECORDTYPE_CNS, RECORDTYPE_SIDRA_LITE, RECORDTYPE_IFAP};

    public static list<Case> filterCNSCases(list<Case> listCases) {
        list<Case> cnsCaseList = new list<Case>();

        for (Case cse: listCases) {
            if (cse.RecordTypeId == RECORDTYPE_CNS) {
                cnsCaseList.add(cse);
            }
        }

        return cnsCaseList;
    }


    public static list<Case> filterCNSRelatedCases(list<Case> listCases) {
        list<Case> caseList = new list<Case>();

        for(Case cse: listCases) {
            if(cse.CNSCase__c == true && cnsRelatedRecordTypes.contains(cse.RecordTypeId)) {
                caseList.add(cse);
            }
        }

        return caseList;
    }


    webService static Boolean isUserAllowedToCreateEditCase() {
        //Group cnsGroup = [SELECT Id, Name FROM Group WHERE DeveloperName = 'CNS_Collection_Process_Group'];                   
        //List<GroupMember> cnsGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :cnsGroup.Id];
        List<GroupMember> cnsGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'CNS_Collection_Process_Group'];
                     
        Boolean userBelongsToCNSGroup = false;

        //Checks if user is an internal user and is allowed to create/edit CNS cases            
        for(GroupMember member : cnsGroupMembers) {
            if(UserInfo.getUserId() == member.UserOrGroupId && UserInfo.getUserType() != 'PowerPartner') {
                return true;
            }
        }

        return false;
    }


    public static void validateUserPermissionsForCNS(list<Case> listCases) {
        Boolean isUserAllowedForCNS = isUserAllowedToCreateEditCase();

        List<Case> cnsRelatedCases = filterCNSRelatedCases(listCases);

        for(Case c : cnsRelatedCases) {
            if(!isUserAllowedForCNS) {       
                c.addError(Label.Not_In_CNS_Group_Error);
            }
        }
    }


    public static void insertCNSCases(list<Case> listCases) {   
        list<Case> cnsCaseList = filterCNSCases(listCases);
        if (cnsCaseList.isEmpty()) return;
        
        validateUserPermissionsForCNS(cnsCaseList);

        list<Id> listAccountId = new list<Id>();

        for(Case cse: cnsCaseList) {
            listAccountId.add(cse.AccountId);
        }

        // get related Accounts
        map<Id,Account> mapAccounts = new map<Id,Account>();

        if (!listAccountId.isEmpty()) {
            mapAccounts = new map<Id,Account>(
                            [SELECT Id, Type, Status__c, IATA_ISO_Country__r.Name, Name, IATACode__c
                             FROM Account
                             WHERE id in :listAccountId]);
        }

        for(Case cse: cnsCaseList) {
            Account account = mapAccounts.get(cse.AccountId);
              
            cse.CNSCase__c = true;
            cse.Subject = 'CNS collection process - ' + account.Name + ' - ' + account.IATACode__c;

            if(cse.CS_Contact_Result__c != null) {
                cse.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
            }

            cse.SAAM_Deadline_Date__c = BusinessHours.nextStartDate('01m20000000095cAAA', Date.today().addDays(7)).date();
        }
    }


    public static void updateCNSCases(list<Case> newCases, Map<Id,Case> oldCasesMap) {
        list<Case> cnsCaseList = filterCNSCases(newCases);
        if (cnsCaseList.isEmpty()) return;
        
        validateUserPermissionsForCNS(cnsCaseList);

        for(Case cse: cnsCaseList) {
            Case oldCase = oldCasesMap.get(cse.Id);
            
            if(cse.CS_Contact_Result__c != oldCase.CS_Contact_Result__c) {
                cse.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
            }    
        }
    }
}
