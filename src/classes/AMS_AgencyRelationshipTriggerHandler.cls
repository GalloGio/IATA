public class AMS_AgencyRelationshipTriggerHandler {

    public static boolean isToRunTrigger = true;
    public static boolean AMS_HierarchyProcess = false;
    public static Set<Account> accsToUpdateSet = new Set<Account>();


    public static void handleAfterInsert(List<AMS_Agencies_relationhip__c> rels) {

        Map<Id, AMS_Agencies_Hierarchy__c> mainHierarchies = getRelationshipHierarchies(rels);

        List<String> relationChildrenIds = getRelationshipChildAccountIds(rels);

        setStandardHierarchyRelationship(rels, mainHierarchies, null);

        //look for relation with same children than trigger content and in same main H but not concerned by this trigger
        List<AMS_Agencies_relationhip__c > oldrelation2delete = [select id from AMS_Agencies_relationhip__c  where Child_Account__c in :relationChildrenIds and (not Id in :Trigger.newMap.keyset()) and Hierarchy__c in :mainHierarchies.keySet() ];

        if (oldrelation2delete != null && oldrelation2delete.size() > 0)
            delete oldrelation2delete ;

        updateCASSNumber(rels);

    }

    public static void handleAfterUpdate(List<AMS_Agencies_relationhip__c> rels, Map<Id, AMS_Agencies_relationhip__c> oldMap) {

        Map<Id, AMS_Agencies_Hierarchy__c> mainHierarchies = getRelationshipHierarchies(rels);

        List<String> relationChildrenIds = getRelationshipChildAccountIds(rels);

        //FM - 22-09-2016 - stop creating "agency update" Records
        //AMS_AgencyUpdateHelper.agencyRelathionshipUpdate(rels);

        setStandardHierarchyRelationship(rels, mainHierarchies, oldMap);

    }

/*
    public static void handleAfterDelete(List<AMS_Agencies_relationhip__c> rels) {

        Set<Id> accountsInTheOldHierarchy = new Set<Id>();
        for (AMS_Agencies_relationhip__c rel : rels) {
            accountsInTheOldHierarchy.add(rel.Parent_Account__c);
            accountsInTheOldHierarchy.add(rel.Child_Account__c);
        }

        //setAccountsWithoutHierarchyToHO(accountsInTheOldHierarchy);

    }
*/

    public static Map<Id, AMS_Agencies_Hierarchy__c> getRelationshipHierarchies(List<AMS_Agencies_relationhip__c> rels) {
        List<String> hierarchiesIds = new List<String>();
        Id rtMain = Schema.SObjectType.AMS_Agencies_Hierarchy__c.getRecordTypeInfosByName().get('MAIN').getRecordTypeId();
        for (AMS_Agencies_relationhip__c r : rels) {
            hierarchiesIds.add(r.Hierarchy__c);

        }

        return new Map<Id, AMS_Agencies_Hierarchy__c>( [select Id from AMS_Agencies_Hierarchy__c where recordTypeId = :rtmain and Id in :hierarchiesIds]);
    }

    public static List<String> getRelationshipChildAccountIds(List<AMS_Agencies_relationhip__c> rels) {
        List<String> relationChildrenIds = new List<String>();
        for (AMS_Agencies_relationhip__c r : rels)
            relationChildrenIds.add(r.Child_Account__c);

        return relationChildrenIds;
    }


    // when a main hierarchy is set, this method will update the standard hierarchy and the location type
    public static void setStandardHierarchyRelationship(List<AMS_Agencies_relationhip__c> rels, Map<Id, AMS_Agencies_Hierarchy__c> mainHierarchies, Map<Id, AMS_Agencies_relationhip__c> oldMap) {
        AMS_HierarchyProcess = true;

        system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> start!');

        // retrieve all the account involved in the updated relationships (received from the trigger)
        Set<Id> accountIds = new Set<Id>();
        for (AMS_Agencies_relationhip__c rel : rels) {
            system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> look at rel ' + rel.Parent_Account__c + ' to ' + rel.Child_Account__c);
            //if (mainHierarchies.get(rel.Hierarchy__c) != null ){
            accountIds.add(rel.Parent_Account__c);
            accountIds.add(rel.Child_Account__c);
            //}
        }

        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id, Id> accountsTopParent = new Map<Id, Id>();
        // retrieve all the hierarchies for the relationships received from the trigger
        // for each hierarchy I extract the parent (I may process twice the same hierarchy but I add the parent to a set so that I am sure I get parents only once)
        for (List<AMS_Agencies_relationhip__c> hier : AMS_HierarchyHelper.getAccountsHierarchies(accountIds).values()) {

            system.debug('setStandardHierarchyRelationship() --> list of rels in hierarchy ' + hier);
            Id hierarchyTopParent = AMS_HierarchyHelper.getHierarchyHO(hier);
            parentAccountIds.add(hierarchyTopParent);

            accountsTopParent.put(hierarchyTopParent, null);

            for(AMS_Agencies_relationhip__c rel: hier){

                if(rel.Parent_Account__c != hierarchyTopParent && accountIds.contains(rel.Parent_Account__c))
                    accountsTopParent.put(rel.Parent_Account__c, hierarchyTopParent);
                
                if(accountIds.contains(rel.Child_Account__c))
                    accountsTopParent.put(rel.Child_Account__c, hierarchyTopParent);

            }
        }

        system.debug('setStandardHierarchyRelationship Hierarchy top parent map ' + accountsTopParent);

        // retrieve all the accounts: the ones directly involved in the relationship changes + the HO of those hierarchies
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT ParentId, Location_Type__c, IATAcode__c, Name, Top_Parent__c
                FROM Account
                WHERE Id IN :accountIds  OR Id IN :parentAccountIds
                ORDER BY IATAcode__c]);

        for(Account acc: accounts.values()){
            system.debug('setStandardHierarchyRelationship Account Id: '+ acc.Id + ' Name ' + acc.Name);
        }
        
        for(Id account: accountsTopParent.keySet()){
            system.debug('setStandardHierarchyRelationship Acc Id ' + account + ' Name ' + accounts.get(account).Name);
            accounts.get(account).Top_Parent__c = accountsTopParent.get(account);
            system.debug('CHECK setStandardHierarchyRelationship Acc Id ' + account + ' Name ' + accounts.get(account).Name + ' Id ' + accounts.get(account).Id + ' parent ' + accounts.get(account).ParentId + ' top parent ' + accounts.get(account).Top_Parent__c);

        }
        
        Map<Id, Account> accountsInitialState = new Map<Id, Account>();

        Map<Id, String> accountsInitialLocType = new Map<Id, String>();
        Map<Id, String> hierarchyHOLocType = new Map<Id, String>();

        //need to keep a backup of the data to know the original Location Type of the accounts
        for (Account a : accounts.values()){
            accountsInitialLocType.put(a.Id, a.Location_Type__c);
            accountsInitialState.put(a.Id, a.clone());
        }

        // for each relationship, I update parentid and location type on the accounts
        for (AMS_Agencies_relationhip__c rel : rels) {
            system.debug('setStandardHierarchyRelationship() --> retrieve parent ' + rel.Parent_Account__c + ' and child ' + rel.Child_Account__c);
    
            // whatever is the level of the relationship I update parentid and location type of the child
            accounts.get(rel.Child_Account__c).ParentId = rel.Parent_Account__c;


            //when an SA is switched with a BR or an HO we must update the location type
            //also when an SA parent changes from BR to HO its Location type must change to BR

            //the following logic is not to be applied when a change of location is being performed on an SA
            //verify if there was an update on the relation. only in this situation the location type needs to be updated
            if(AMS_OSCARTriggerHandler.keepSALocationTypeFlag == false && oldMap != null){
                        
                String newParentOldLocType = accountsInitialLocType.get(rel.Parent_Account__c);
                String newChildOldLocType = accountsInitialLocType.get(rel.Child_Account__c);

                if (rel.Parent_Account__c != oldMap.get(rel.Id).Parent_Account__c && rel.Child_Account__c != oldMap.get(rel.Id).Child_Account__c) {
                    System.debug('Parent Location type Change to : ' + newChildOldLocType);
                    accounts.get(rel.Parent_Account__c).Location_Type__c = newChildOldLocType;
                    System.debug('Child Location type Change to : ' + newParentOldLocType);
                    accounts.get(rel.Child_Account__c).Location_Type__c = newParentOldLocType;
                }

                //parent of relation changed, the child remains the same and its location type is SA.
                //This means the SA was reparented from a BR to an HO/AO, so we need to change the location type from SA to BR
                if (
                    rel.Child_Account__c == oldMap.get(rel.Id).Child_Account__c
                    && newChildOldLocType == AMS_Utils.SA
                    && rel.Parent_Account__c != oldMap.get(rel.Id).Parent_Account__c
                    && (accounts.get(rel.Parent_Account__c).Location_Type__c == AMS_Utils.HO || accounts.get(rel.Parent_Account__c).Location_Type__c == AMS_Utils.AO)
                    && newParentOldLocType != AMS_Utils.SA
                ) {
                    accounts.get(rel.Child_Account__c).Location_Type__c = AMS_Utils.BR;
                    System.debug('setStandardHierarchyRelationship() --> SA being passed to a new HO - '+accounts.get(rel.Child_Account__c).Name + ' to HO '+accounts.get(rel.Parent_Account__c).Name);
                }
            }


            //if (accounts.get(rel.Child_Account__c).Location_Type__c == AMS_Utils.HO) accounts.get(rel.Child_Account__c).Location_Type__c = AMS_Utils.BR;
            if(accounts.get(rel.Child_Account__c).Location_Type__c == AMS_Utils.HO){
                accounts.get(rel.Child_Account__c).Location_Type__c = AMS_Utils.BR;
                hierarchyHOLocType.put(rel.Parent_Account__c, AMS_Utils.HO);
            }
            if(accounts.get(rel.Child_Account__c).Location_Type__c == AMS_Utils.AO){
                accounts.get(rel.Child_Account__c).Location_Type__c = AMS_Utils.BR;
                hierarchyHOLocType.put(rel.Parent_Account__c, AMS_Utils.AO);
            }
            
        }

        system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> look for accountIds ' + accountIds);
        system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> look for parentAccountIds ' + parentAccountIds);

        //set HO accounts parentID and Location type
        for (Account a : accounts.values()) {
            if (parentAccountIds.contains(a.Id)) {
                a.ParentId = null;
                if(a.Location_Type__c != AMS_Utils.HO  && a.Location_Type__c != AMS_Utils.AO){
                    if(hierarchyHOLocType.get(a.Id)!=null)
                        a.Location_Type__c = hierarchyHOLocType.get(a.Id);
                    else
                        a.Location_Type__c = 'HO';
                }
                system.debug('setStandardHierarchyRelationship() --> update parent account ' + a.Name + ' with Parentid = ' + a.ParentId + ', Location type = ' + a.Location_Type__c);
            }
            system.debug('setStandardHierarchyRelationship() --> found account ' + a.Name + ' with id ' + a.id + ' and location type = ' + a.Location_Type__c);

        }

        List<Account> accsToUpdate = new List<Account>();

        for (Account acc : accounts.values()) {
            //if (acc.ParentId == null) {
            if(acc.Location_Type__c != accountsInitialState.get(acc.Id).Location_Type__c || acc.ParentId != accountsInitialState.get(acc.Id).ParentId || acc.Top_Parent__c != accountsInitialState.get(acc.Id).Top_Parent__c){
                accsToUpdate.add(acc);
                system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> account ' + acc.Name + ' with id ' + acc.id + ', parent id = ' + acc.ParentId + ' and location type = ' + acc.Location_Type__c);
                system.debug(LoggingLevel.ERROR, 'CHECK setStandardHierarchyRelationship() --> account ' + acc.Name + ' with id ' + acc.id + ', parent id = ' + acc.ParentId + ' and Top parent = ' + acc.Top_Parent__c);
            }
        }
        
        accsToUpdateSet.addAll(accsToUpdate);

        system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> FIRST UPDATE');
        update accsToUpdate;
        /*accsToUpdate = new List<Account>();

        for (Account acc : accounts.values()) {
            if (acc.ParentId != null) {
                accsToUpdate.add(acc);
                system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> account ' + acc.Name + ' with id ' + acc.id + ', parent id = ' + acc.ParentId + ' and location type = ' + acc.Location_Type__c);
            }
        }

        system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> SECOND UPDATE');
        update accsToUpdate;*/
        system.debug(LoggingLevel.ERROR, 'setStandardHierarchyRelationship() --> end!');

    }

    /*updates the CASS Number on branch based on the number of BR in the hierarchy
    * if no BR exists in the hierarchy CASS Num of the BR will be 002 otherwise CASS Num will be
    * the next unattributed Cass Number for that hierarchy
    */
    public static void updateCASSNumber(List<AMS_Agencies_relationhip__c> rels) {

        Map<Id, List<Integer>> hierarchyAvailableCass = new Map<Id, List<Integer>>();

        //this map saves the position on the list of available Cass number on a hierarchy that we need to get the CASS Number from
        Map<Id, Integer> aux = new Map<Id, Integer>();
        Set<Id> hierarchyIds = new Set<Id>();

        //Get all hierarchies that will contain the relationships being inserted
        for (AMS_Agencies_relationhip__c r : rels)
            if (!hierarchyIds.contains(r.Hierarchy__c))
                hierarchyIds.add(r.Hierarchy__c);

        //Get all the relations in the hierarchies
        List<AMS_Agencies_relationhip__c> relationsInHierarchy = [select Id, Child_Account__c, Parent_Account__c, Hierarchy__c from AMS_Agencies_relationhip__c where Hierarchy__c in :hierarchyIds];

        //list to save all child accounts from all the hierarchies in the context
        Set<Id> allAccountsInHierarchies = new Set<Id>();

        for (AMS_Agencies_relationhip__c r : relationsInHierarchy){
            allAccountsInHierarchies.add(r.Child_Account__c);
            allAccountsInHierarchies.add(r.Parent_Account__c);
        }

        Map<Id, Account> accounts = new Map<Id, Account>([select Id, CASS_Number__c, Sector__c, CNS_Agency__c from Account where Id in :allAccountsInHierarchies]);

        //Build mapping between hierarchy and the available CASS Numbers for it
        for (Id hId : hierarchyIds) {

            Set<Account> accountsInHierarchy = new Set<Account>();

            if (hierarchyAvailableCass.get(hId) == null) {
                //get all the accounts for this hierarchy
                boolean isCNS = false;
                for (AMS_Agencies_relationhip__c r : relationsInHierarchy)
                    if (r.Hierarchy__c == hId) {
                        Account acc = accounts.get(r.Child_Account__c);
                        accountsInHierarchy.add(acc);
                        Account accParent = accounts.get(r.Parent_Account__c);
                        accountsInHierarchy.add(accParent);
                        isCNS = acc.CNS_Agency__c;
                    }

                Set<Integer> availableCassNumbers = getAvailableCassNumbers(accountsInHierarchy,isCNS);
                List<Integer> availableCassOrdered = new List<Integer>(availableCassNumbers);
                availableCassOrdered.sort();

                hierarchyAvailableCass.put(hId, availableCassOrdered);

            }
        }

        List<Account> accToUpdate = new List<Account>();
        //add Cass Number to the child accounts of the relationships being inserted
        for (AMS_Agencies_relationhip__c r : rels) {

            Account acc = accounts.get(r.Child_Account__c);
            if (acc.Sector__c == AMS_Utils.SECTOR_CARGO && acc.CASS_Number__c == null) {
                List<Integer> cassNumbersAvailable = hierarchyAvailableCass.get(r.Hierarchy__c);

                //if no CASS Numbers are available the CASS will be left empty!!
                if (cassNumbersAvailable.size() > 0 && aux.get(r.Hierarchy__c) != -1) {

                    //find the position in the List of available CASS that should be used
                    if (aux.get(r.Hierarchy__c) == null)
                        aux.put(r.Hierarchy__c, 0);

                    Integer cassNumberPos = aux.get(r.Hierarchy__c);

                    acc.CASS_Number__c = AMS_AgencyHelper.resizeNumericString('' + cassNumbersAvailable.get(cassNumberPos), 3);

                    if (cassNumberPos + 1 < cassNumbersAvailable.size())
                        cassNumberPos++;
                    else
                        cassNumberPos = -1;

                    aux.put(r.Hierarchy__c, cassNumberPos);

                    accToUpdate.add(acc);
                }
            }
        }

        if (accToUpdate.size() > 0)
            update accToUpdate;

    }

    public static Set<Integer> getAvailableCassNumbers(Set<Account> accounts, boolean isCNS) {
        Set<Integer> availableCASS = new Set<Integer>();

        for (Integer i = (isCNS == true ? 1 : 0); i < 1000; i++)
            availableCASS.add(i);

        for (Account acc : accounts)
            if (acc.CASS_Number__c != null)
                availableCASS.remove(Integer.valueof(acc.CASS_Number__c));

        return availableCASS;
    }

/*
    public static void setAccountsWithoutHierarchyToHO(Set<Id> accountIds) {
        system.debug('setAccountsWithoutHierarchyToHO() --> accountIds = ' + accountIds);
        Map<Id, List<AMS_Agencies_relationhip__c>>  hierarchies = AMS_HierarchyHelper.getAccountsHierarchies(accountIds);
        Set<Id> accountToSetAsHO = new Set<Id>();
        for (Id accountId : hierarchies.keySet()) {
            if (hierarchies.get(accountId) == null || hierarchies.get(accountId).size() == 0)
                accountToSetAsHO.add(accountId);
        }

        system.debug('setAccountsWithoutHierarchyToHO() --> accountToSetAsHO = ' + accountToSetAsHO);

        if (accountToSetAsHO.size() > 0) {
            List<Account> newHOs = [SELECT ParentId, Location_Type__c FROM Account WHERE Id IN :accountToSetAsHO];
            for (Account a : newHOs) {
                a.ParentId = null;
                a.Location_Type__c = AMS_Utils.HO;
            }

            system.debug('setAccountsWithoutHierarchyToHO() --> newHOs = ' + newHOs);
            if (newHOs.size() > 0)
                update newHOs;
        }
    }
*/

    public static List<AMS_Agencies_relationhip__c> filterRelationsByAMS(List<AMS_Agencies_relationhip__c> rels){

        List<AMS_Agencies_relationhip__c> relsToReturn = new List<AMS_Agencies_relationhip__c>();

        for(AMS_Agencies_relationhip__c rel: rels){
            if(!rel.Is_Newgen_Relation__c)
                relsToReturn.add(rel);
        }

        return relsToReturn;

    }
}