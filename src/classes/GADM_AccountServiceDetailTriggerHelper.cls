public without sharing class GADM_AccountServiceDetailTriggerHelper {


    public static void publishEvents(Map<Id, GADM_Account_Service_Detail__c> oldMap, Map<Id, GADM_Account_Service_Detail__c> newMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {

        Map<String, List<GADM_Account_Service_Detail__c>> tempMap = findTriggerObjects(oldMap, newMap, isInsert, isUpdate, isDelete);

        List<GADM_Account_Service_Detail__c> toInsert = new List<GADM_Account_Service_Detail__c>();
        List<GADM_Account_Service_Detail__c> toUpdate = new List<GADM_Account_Service_Detail__c>();
        List<GADM_Account_Service_Detail__c> toDelete = new List<GADM_Account_Service_Detail__c>();

        List<GADM_Account_Service_Detail__c> toInsertGadmAccountServiceDetail = new List<GADM_Account_Service_Detail__c>();
        List<GADM_Account_Service_Detail__c> toUpdateGadmAccountServiceDetail = new List<GADM_Account_Service_Detail__c>();
        List<GADM_Account_Service_Detail__c> toDeleteGadmAccountServiceDetail = new List<GADM_Account_Service_Detail__c>();

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
            if(tempMap.get('Insert_GadmAccountServiceDetail') != null) {
                toInsertGadmAccountServiceDetail = tempMap.get('Insert_GadmAccountServiceDetail');
            }
            if(tempMap.get('Update_GadmAccountServiceDetail') != null) {
                toUpdateGadmAccountServiceDetail = tempMap.get('Update_GadmAccountServiceDetail');
            }
            if(tempMap.get('Delete_GadmAccountServiceDetail') != null) {
                toDeleteGadmAccountServiceDetail = tempMap.get('Delete_GadmAccountServiceDetail');
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

            if(! toInsertGadmAccountServiceDetail.isEmpty()) {
                Map<Id, GADM_Account_Service_Detail__c> objMap = new Map<Id, GADM_Account_Service_Detail__c>(toInsertGadmAccountServiceDetail);
                PlatformEvents_Helper.publishEvents(objMap, 'GadmAccountServiceDetail__e', 'GADM_Account_Service_Detail__c', true, false, false, false);
            }
            if(! toUpdateGadmAccountServiceDetail.isEmpty()) {
                Map<Id, GADM_Account_Service_Detail__c> objMap = new Map<Id, GADM_Account_Service_Detail__c>(toUpdateGadmAccountServiceDetail);
                PlatformEvents_Helper.publishEvents(objMap, 'GadmAccountServiceDetail__e', 'GADM_Account_Service_Detail__c', false, true, false, false);
            }
            if(! toDeleteGadmAccountServiceDetail.isEmpty()) {
                Map<Id, GADM_Account_Service_Detail__c> objMap = new Map<Id, GADM_Account_Service_Detail__c>(toDeleteGadmAccountServiceDetail);
                PlatformEvents_Helper.publishEvents(objMap, 'GadmAccountServiceDetail__e', 'GADM_Account_Service_Detail__c', false, false, true, false);
            }

        }


    }


    private static Map<String, List<GADM_Account_Service_Detail__c>> findTriggerObjects(Map<Id, GADM_Account_Service_Detail__c> oldMap, Map<Id, GADM_Account_Service_Detail__c> newMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        Map<String, List<GADM_Account_Service_Detail__c>> toReturn = new Map<String, List<GADM_Account_Service_Detail__c>>();

        //insert trigger
        if(isInsert) {
            List<GADM_Account_Service_Detail__c> toInsert = new List<GADM_Account_Service_Detail__c>();
            List<GADM_Account_Service_Detail__c> toInsertGadmAccountServiceDetails = new List<GADM_Account_Service_Detail__c>();
            for(GADM_Account_Service_Detail__c detail : newMap.values()) {
                if(detail.Service_Name__c == 'GADM') {
                    if((detail.External_Actor_Id__c != null && detail.External_Actor_Id__c != '')) {
                        toInsert.add(detail);
                    }
                    if(detail.Expected_amount_of_data_submissions__c != null) {
                        toInsertGadmAccountServiceDetails.add(detail);
                    }
                }
            }
            if(! toInsert.isEmpty()) {
                toReturn.put('Insert', toInsert);
            }
            if(! toInsertGadmAccountServiceDetails.isEmpty()) {
                toReturn.put('Insert_GadmAccountServiceDetail', toInsertGadmAccountServiceDetails);
            }
        }

        //delete trigger
        if(isDelete) {
            List<GADM_Account_Service_Detail__c> toDelete = new List<GADM_Account_Service_Detail__c>();
            for(GADM_Account_Service_Detail__c detail : oldMap.values()) {
                if(detail.Service_Name__c == 'GADM') {
                    toDelete.add(detail);
                }
            }
            toReturn.put('Delete',toDelete);
            toReturn.put('Delete_GadmAccountServiceDetail',toDelete);
        }

        //update trigger
        if(isUpdate) {
            List<GADM_Account_Service_Detail__c> toUpdate = new List<GADM_Account_Service_Detail__c>();
            List<GADM_Account_Service_Detail__c> toDelete = new List<GADM_Account_Service_Detail__c>();
            List<GADM_Account_Service_Detail__c> toInsert = new List<GADM_Account_Service_Detail__c>();

            //events for External_Actor_Id__c
            for(GADM_Account_Service_Detail__c accountServiceDetail : newMap.values()) {
                if(accountServiceDetail.Service_Name__c != 'GADM') {continue;}

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

            List<GADM_Account_Service_Detail__c> toUpdateGadmAccountServiceDetails = new List<GADM_Account_Service_Detail__c>();
            List<GADM_Account_Service_Detail__c> toDeleteGadmAccountServiceDetails = new List<GADM_Account_Service_Detail__c>();
            List<GADM_Account_Service_Detail__c> toInsertGadmAccountServiceDetails = new List<GADM_Account_Service_Detail__c>();

            //events for Expected_amount_of_data_submissions__c
            for(GADM_Account_Service_Detail__c accountServiceDetail : newMap.values()) {
                if(accountServiceDetail.Service_Name__c != 'GADM') {continue;}

                GADM_Account_Service_Detail__c oldObj = oldMap.get(accountServiceDetail.Id);

                if(oldObj.Expected_amount_of_data_submissions__c == accountServiceDetail.Expected_amount_of_data_submissions__c) {
                    continue;
                }

                if(oldObj.Expected_amount_of_data_submissions__c == null && accountServiceDetail.Expected_amount_of_data_submissions__c != null) {
                    toInsertGadmAccountServiceDetails.add(accountServiceDetail);
                }else if(accountServiceDetail.Expected_amount_of_data_submissions__c == null) {
                    toDeleteGadmAccountServiceDetails.add(accountServiceDetail);
                }else if(oldObj.Expected_amount_of_data_submissions__c != accountServiceDetail.Expected_amount_of_data_submissions__c) {
                    toUpdateGadmAccountServiceDetails.add(accountServiceDetail);
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

            if(! toUpdateGadmAccountServiceDetails.isEmpty()) {
                toReturn.put('Update_GadmAccountServiceDetail', toUpdateGadmAccountServiceDetails);
            }
            if(! toDeleteGadmAccountServiceDetails.isEmpty()) {
                toReturn.put('Delete_GadmAccountServiceDetail', toDeleteGadmAccountServiceDetails);
            }
            if(! toInsertGadmAccountServiceDetails.isEmpty()) {
                toReturn.put('Insert_GadmAccountServiceDetail', toInsertGadmAccountServiceDetails);
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



    public static void checkGadmDuplicates(Boolean isInsert, Boolean isUpdate,  Map<Id, GADM_Account_Service_Detail__c> oldMap, List<GADM_Account_Service_Detail__c> newObjects) {

        Set<Id> accountRoleServiceIds = new Set<Id>();

        if(isInsert) {
            for(GADM_Account_Service_Detail__c detail : newObjects) {
                if(detail.Service_Name__c == 'GADM') {
                    accountRoleServiceIds.add(detail.Account_Role_Service__c);
                }
            }
        }

        if(isUpdate) {
            for(GADM_Account_Service_Detail__c detail : newObjects) {
                GADM_Account_Service_Detail__c oldObj = oldMap.get(detail.Id);
                if(detail.Service_Name__c == 'GADM') {
                    if((oldObj.Account_Role_Service__c != detail.Account_Role_Service__c) || (oldObj.Service_Name__c != detail.Service_Name__c)) {
                        accountRoleServiceIds.add(detail.Account_Role_Service__c);
                    }
                }
            }
        }


        List<GADM_Account_Service_Detail__c> existingList = [SELECT Id, Account_Role_Service__c, Service_Name__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__c = :accountRoleServiceIds AND Service_Name__c = 'GADM'];


        Map<Id, List<GADM_Account_Service_Detail__c>> serviceToDetailsMap = new Map<Id, List<GADM_Account_Service_Detail__c>>();
        for(GADM_Account_Service_Detail__c detail : existingList) {
            if(serviceToDetailsMap.get(detail.Account_Role_Service__c) == null) {
                serviceToDetailsMap.put(detail.Account_Role_Service__c, new List<GADM_Account_Service_Detail__c>{detail});
            }else{
                serviceToDetailsMap.get(detail.Account_Role_Service__c).add(detail);
            }
        }


        if(! serviceToDetailsMap.isEmpty()) {
            for(GADM_Account_Service_Detail__c detail : newObjects) {
                if(serviceToDetailsMap.get(detail.Account_Role_Service__c) != null) {
                    List<GADM_Account_Service_Detail__c> detailsList = serviceToDetailsMap.get(detail.Account_Role_Service__c);
                    String ids = '[' + detailsList[0].Id;
                    for(Integer i = 1 ; i < detailsList.size(); i++) {
                        ids += ',' + detailsList[i].Id;
                    }
                    ids += ']';
                    detail.addError('Duplicate record found! ' + ids);
                }
            }

        }

    }

}