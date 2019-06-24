public without sharing class GADM_AccountServiceDetailTriggerHelper {


    public static void publishEvents(Map<Id, GADM_Account_Service_Detail__c> oldMap, Map<Id, GADM_Account_Service_Detail__c> newMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {

        Map<String, List<GADM_Account_Service_Detail__c>> tempMap = findTriggerObjects(oldMap, newMap, isInsert, isUpdate, isDelete);

        List<GADM_Account_Service_Detail__c> toInsert = new List<GADM_Account_Service_Detail__c>();
        List<GADM_Account_Service_Detail__c> toUpdate = new List<GADM_Account_Service_Detail__c>();
        List<GADM_Account_Service_Detail__c> toDelete = new List<GADM_Account_Service_Detail__c>();

        if(! tempMap.isEmpty()) {
            if(tempMap.get('Insert') != null) {
                toInsert = tempMap.get('Insert');
            }
            if(tempMap.get('Update') != null) {
                toUpdate = tempMap.get('Update');
            }
            if(tempMap.get('Delete') != null) {
                toDelete = tempMap.get('Delete');
            }

            if(! toInsert.isEmpty()) {
                Map<Id, Account_Contact_Role__c> related = getRelatedAccountContactRoles(toInsert);
                if(! related.isEmpty()) {
                    PlatformEvents_Helper.publishEvents(related, 'AccountContactRole__e', 'Account_Contact_Role__c', true, false, false, false);
                }
            }

            if(! toUpdate.isEmpty()) {
                Map<Id, Account_Contact_Role__c> related = getRelatedAccountContactRoles(toUpdate);
                if(! related.isEmpty()) {
                    PlatformEvents_Helper.publishEvents(related, 'AccountContactRole__e', 'Account_Contact_Role__c', false, true, false, false);
                }
            }

            if(! toDelete.isEmpty()) {
                Map<Id, Account_Contact_Role__c> related = getRelatedAccountContactRoles(toDelete);
                if(! related.isEmpty()) {
                    PlatformEvents_Helper.publishEvents(related, 'AccountContactRole__e', 'Account_Contact_Role__c', false, false, true, false);
                }
            }

        }


    }


    private static Map<String, List<GADM_Account_Service_Detail__c>> findTriggerObjects(Map<Id, GADM_Account_Service_Detail__c> oldMap, Map<Id, GADM_Account_Service_Detail__c> newMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        Map<String, List<GADM_Account_Service_Detail__c>> toReturn = new Map<String, List<GADM_Account_Service_Detail__c>>();

        if(isInsert) {
            List<GADM_Account_Service_Detail__c> toInsert = new List<GADM_Account_Service_Detail__c>();
            for(GADM_Account_Service_Detail__c detail : newMap.values()) {
                if(detail.External_Actor_Id__c != null && detail.External_Actor_Id__c != '') {
                    toInsert.add(detail);
                }
            }
            if(! toInsert.isEmpty()) {
                toReturn.put('Insert', toInsert);
            }
        }

        if(isDelete) {
            toReturn.put('Delete',oldMap.values());
        }

        if(isUpdate) {
            List<GADM_Account_Service_Detail__c> toUpdate = new List<GADM_Account_Service_Detail__c>();
            List<GADM_Account_Service_Detail__c> toDelete = new List<GADM_Account_Service_Detail__c>();
            List<GADM_Account_Service_Detail__c> toInsert = new List<GADM_Account_Service_Detail__c>();

            for(GADM_Account_Service_Detail__c accountServiceDetail : newMap.values()) {
                GADM_Account_Service_Detail__c oldObj = oldMap.get(accountServiceDetail.Id);

                if(oldObj.External_Actor_Id__c == accountServiceDetail.External_Actor_Id__c) {
                    continue;
                }

                if((oldObj.External_Actor_Id__c == null || oldObj.External_Actor_Id__c == '') && (accountServiceDetail.External_Actor_Id__c != null && accountServiceDetail.External_Actor_Id__c != '')) {
                    toInsert.add(accountServiceDetail);
                }else if(accountServiceDetail.External_Actor_Id__c == null || accountServiceDetail.External_Actor_Id__c == '') {
                    toDelete.add(accountServiceDetail);
                }else if(oldObj.External_Actor_Id__c != accountServiceDetail.External_Actor_Id__c) {
                    toUpdate.add(accountServiceDetail);
                }

            }

            if(! toUpdate.isEmpty()) {
                toReturn.put('Update', toUpdate);
            }
            if(! toDelete.isEmpty()) {
                toReturn.put('Delete', toDelete);
            }
            if(! toInsert.isEmpty()) {
                toReturn.put('Insert', toInsert);
            }
        }

        return toReturn;
    }



    private static Map<Id, Account_Contact_Role__c> getRelatedAccountContactRoles(List<GADM_Account_Service_Detail__c> details) {

        Map<Id, Account_Contact_Role__c> toReturn = new Map<Id, Account_Contact_Role__c>();

        Set<Id> accountRoleServiceIds = new Set<Id>();
        for(GADM_Account_Service_Detail__c detail : details) {
            accountRoleServiceIds.add(detail.Account_Role_Service__c);
        }


        if(! accountRoleServiceIds.isEmpty()) {
            List<Account_Role_Service__c> accountRoles = [SELECT Id, Account_Role__c FROM Account_Role_Service__c WHERE Id = :accountRoleServiceIds];

            if(! accountRoles.isEmpty()) {

                Set<Id> accountRoleIds = new Set<Id>();
                for(Account_Role_Service__c service : accountRoles) {
                    accountRoleIds.add(service.Account_Role__c);
                }

                if(! accountRoleIds.isEmpty()) {

                    Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
                    Map<Id, Account_Contact_Role__c> accountContactRolesMap = new Map<Id, Account_Contact_Role__c>([SELECT Id, RecordTypeId FROM Account_Contact_Role__c WHERE Contact_Roles__r.Name = 'GADM User' AND RecordTypeId = :groupRecordTypeId AND Account_Role__c = :accountRoleIds AND Service_Rendered__c = 'GADM']);

                    if(! accountContactRolesMap.isEmpty()) {
                        toReturn = accountContactRolesMap;
                    }

                }

            }


        }

        return toReturn;

    }

}