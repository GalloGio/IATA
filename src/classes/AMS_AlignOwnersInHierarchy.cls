/* Used only by IATA Support team to align owners hierarchy in all the BR, according to HO owners and roles 

Please, do Not try this if you do not aware of the process

*/

public with sharing class AMS_AlignOwnersInHierarchy {

    public String parentAccountId { get; set; }
    //public String test { get; set; }
    //public boolean isProfile { get; set; }

    public List<AMS_Account_Role__c> newOwners { get; set; }

    public Boolean statusPooler{get;set;}
    public Boolean statusBatch{get;set;}
    public Id batchJobId{get;set;}



    //Below To be completed: Limit the use of this tool to the Support Team. While not completed, do not allow permissions on this page into any profile.
    /*public void thorProfiles() {

        isProfile = false;

        List<Profile> profiles = [select ID from profile where Name IN ('System Administrator', 'Developer')];
        system.debug('Lista profiles: '+ profiles);

        String userProfile = UserInfo.getProfileId().substring(0, 15);
        system.debug('User profile: '+ userProfile);

        String currentUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;

        if (currentUserProfile == 'System Administrator' || currentUserProfile == 'Developer') {

            isProfile = true;
            system.debug('BOOLEAN: '+ isProfile);
        }
    }

    public static boolean isTHORProfile() {
    return THORPROFILES.contains(UserInfo.getProfileId().substring(0, 15));
    }*/

    
    public void alignOwnersInHierarchyByAccountId() {

        statusBatch = false;
        statusPooler = true;

        batchJobId = Database.executeBatch(new AMS_AlignOwnersInHierarchyBatch(parentAccountId), 50);
    }
        
        /*   List<AMS_Agencies_relationhip__c> relationshipLst = new List<AMS_Agencies_relationhip__c>();

        // get all the relationships to extract the accounts involved
        for(AMS_Agencies_Hierarchy__c h : [SELECT Id, (SELECT Hierarchy__c, Parent_Account__r.Top_Parent__r.Id, Parent_Account__c, Child_Account__c, Child_Account__r.Status__c, Child_Account__r.Top_Parent__r.Id, Child_Account__r.Cass_Number__c, Child_Account__r.Name from AMS_Agencies_relationships__r where Child_Account__r.Status__c != 'Terminated') FROM AMS_Agencies_Hierarchy__c WHERE Id In (SELECT Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c =:test)]) 
                for(AMS_Agencies_relationhip__c rel : h.AMS_Agencies_relationships__r)
            relationshipLst.add(rel);

        // The map with all HO -> Child Accounts
        Map<Id, List<Id>> accountsToRepopulateOwnersMap = new Map<Id, List<Id>>();

        List<Id> accountsToDeleteRoles = new List<Id>();

        for(AMS_Agencies_relationhip__c rel :relationshipLst){

            // HO Id
            Id idToFind = rel.Parent_Account__r.Top_Parent__r == null ? rel.Parent_Account__r.Id : rel.Parent_Account__r.Top_Parent__c;

            if(accountsToRepopulateOwnersMap.get(idToFind) == null){

                accountsToRepopulateOwnersMap.put(idToFind, new List<Id>{rel.Child_Account__r.Id});
            
            }else{

                accountsToRepopulateOwnersMap.get(idToFind).add(rel.Child_Account__r.Id);

            }

            accountsToDeleteRoles.add(rel.Child_Account__r.Id);
        }

        // now that we have divided HO and Child accounts, let's clean all the previous owners and create new ones.

        delete [SELECT Id from AMS_Account_Role__c where Account__C in:accountsToDeleteRoles and active__c = true and Account__r.Status__c != 'Terminated'];

        Set<Id> idsToQuery = accountsToRepopulateOwnersMap.keySet();
        
        List<AMS_Account_Role__c> allRoles= Database.query( AMS_QueryUtils.getAllFieldQuery('AMS_Account_Role__c',null, + 'Account__c =:idsToQuery and active__c = true', false) );

        // List with HO->Roles
        Map<Id,List<AMS_Account_Role__c>> rolesFromAccount = new Map<Id,List<AMS_Account_Role__c>>();

        for(AMS_Account_Role__c role: allRoles){

            if(rolesFromAccount.get(role.Account__c) == null){

                rolesFromAccount.put(role.Account__c, new List<AMS_Account_Role__c>{role});
            
            }else{

                rolesFromAccount.get(role.Account__c).add(role);

            }

        }

        // so we now have the list of HO->Childs and HO->Roles so let's fill the Childs with the Roles

        Set<Id> accountHoIdSet = accountsToRepopulateOwnersMap.keySet();

        List<AMS_Account_Role__c> rolesToInsert = new List<AMS_Account_Role__c>();

        for(Id accountHO : accountHoIdSet){

            rolesToInsert.addAll(createRoles(accountsToRepopulateOwnersMap.get(accountHo),rolesFromAccount.get(accountHO)));

        }

        if(!rolesToInsert.isEmpty())
            insert rolesToInsert;
            newOwners = rolesToInsert;
    }

    public static List<AMS_Account_Role__c> createRoles(List<Id> accountIds, List<AMS_Account_Role__c> rolesToClone){

        List<AMS_Account_Role__c> newRolesToReturn = new List<AMS_Account_Role__c>();

        for(Id acctId : accountIds)
            for(AMS_Account_Role__c role:rolesToClone){

                AMS_Account_Role__c newRole = role.clone(false,false,false,false);
                newRole.Account__c = acctId;
                newRolesToReturn.add(newRole);
        }


        return newRolesToReturn;
    }

    */

    public void checkBatchStatus() {

        System.debug('hierarchy checkBatchStatus');

        List<AsyncApexJob> aaj = [SELECT Id, Status FROM AsyncApexJob WHERE ID = :batchJobId];

        System.debug('hierarchy aaj: ' + aaj);

        if(!aaj.isEmpty()){
            if(aaj.get(0).Status == 'Completed'){
                statusPooler = false;
                statusBatch = true;    
                newOwners = [SELECT Id, Account__c, RecordTypeId, Owner_Name__c, Owner_Account__c, Percentage__c from AMS_Account_Role__c where Account__c = :parentAccountId];
                System.debug('hierarchy job completed');
            } else {
                statusBatch = false;
                System.debug('hierarchy job processing');
            }
        }

    }

}