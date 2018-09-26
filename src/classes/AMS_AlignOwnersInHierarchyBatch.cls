/* Used only by IATA Support team to align owners hierarchy in all the BR, according to HO owners and roles 

Please, do Not try this if you do not aware of the process

*/

 global class AMS_AlignOwnersInHierarchyBatch implements Database.Batchable<sObject>, Database.Stateful {
 
    //public List<AMS_Account_Role__c> newOwners { get; set; }
    String query;
    // The map with all HO -> Child Accounts
    Map<Id, List<Id>> accountsToRepopulateOwnersMap = new Map<Id, List<Id>>();

    List<Id> accountsToDeleteRoles = new List<Id>();
    
    global AMS_AlignOwnersInHierarchyBatch(String parentAccountId) {

        query ='SELECT Id, '+
                    '(SELECT Hierarchy__c, Parent_Account__r.Top_Parent__r.Id, Parent_Account__c, Child_Account__c, '+
                    'Child_Account__r.Status__c, Child_Account__r.Top_Parent__r.Id, Child_Account__r.Cass_Number__c, Child_Account__r.Name '+
                    'from AMS_Agencies_relationships__r '+
                    'where Child_Account__r.Status__c != \'Terminated\') '+
                'FROM AMS_Agencies_Hierarchy__c '+
                'WHERE Id In '+
                    '(SELECT Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c =\'' + parentAccountId + '\')';

            System.debug('## query: '+query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('batch start');

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<AMS_Agencies_Hierarchy__c> scope) {

        List<AMS_Agencies_relationhip__c> relationshipLst = new List<AMS_Agencies_relationhip__c>();

        System.debug('batch scope: ' + scope);

        // get all the relationships to extract the accounts involved
        for(AMS_Agencies_Hierarchy__c h : scope) 
                for(AMS_Agencies_relationhip__c rel : h.AMS_Agencies_relationships__r)
            relationshipLst.add(rel);

        System.debug('batch relationshipLst: ' + relationshipLst);

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

    }


    global void finish(Database.BatchableContext BC) {

        //rerender to view if possible

        // now that we have divided HO and Child accounts, let's clean all the previous owners and create new ones.
        //List<AMS_Account_Role__c> accRoleList = [SELECT Id from AMS_Account_Role__c where Account__C in:accountsToDeleteRoles and active__c = true and Account__r.Status__c != 'Terminated'];
        List<AMS_Account_Role__c> accRoleList = Database.query( AMS_QueryUtils.getAllFieldQuery('AMS_Account_Role__c',null, + 'Account__c in :accountsToDeleteRoles and active__c = true and Account__r.Status__c != \'Terminated\'', false) );
        
        System.debug('batch finish accountsToDeleteRoles: ' + accountsToDeleteRoles);
        System.debug('batch finish accRoleList: ' + accRoleList);

        if(!accRoleList.isEmpty() && accRoleList.size() > 800){

            List<AMS_Account_Role__c> accRoleListAux = new List<AMS_Account_Role__c>();

            Integer sizeList = accRoleList.size();
            System.debug('batch finish sizeList: ' + sizeList);
            
            for(Integer i=sizeList; accRoleList.size() > 0; i--) {

                if(accRoleListAux.size() < 800){

                    if(accRoleList.get(0) != null)
                    {
                        accRoleListAux.add(accRoleList.get(0));
                        accRoleList.remove(0);

                    } else {

                        delete accRoleListAux;

                    }
                    

                } else {

                    System.debug('batch finish delete accRoleListAux: ' + accRoleListAux.size());

                    delete accRoleListAux;
                    accRoleListAux = new List<AMS_Account_Role__c>();
                    
                    System.debug('batch finish deleted accRoleListAux: ' + accRoleListAux.size());

                }

            }

        } else if(!accRoleList.isEmpty()){

            delete accRoleList;

        }

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

        System.debug('batch finish rolesToInsert: ' + rolesToInsert);

        if(!rolesToInsert.isEmpty() && rolesToInsert.size() > 800){

            List<AMS_Account_Role__c> rolesToInsertAux = new List<AMS_Account_Role__c>();

            Integer sizeInsertList = rolesToInsert.size();
            System.debug('batch finish sizeInsertList: ' + sizeInsertList);
            
            for(Integer i=sizeInsertList; rolesToInsert.size() > 0; i--) {

                if(rolesToInsertAux.size() < 800){

                    if(rolesToInsert.get(0) != null)
                    {
                        rolesToInsertAux.add(rolesToInsert.get(0));
                        rolesToInsert.remove(0);

                    } else {

                        insert rolesToInsertAux;

                    }

                } else {

                    System.debug('batch finish insert rolesToInsertAux: ' + rolesToInsertAux);

                    insert rolesToInsertAux;
                    rolesToInsertAux = new List<AMS_Account_Role__c>();

                }

            }

        } else if(!rolesToInsert.isEmpty()){

            insert rolesToInsert;

        }

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


}