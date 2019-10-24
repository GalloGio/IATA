/**
 * Created by LBERB on 22/10/2019.
 */

/**
 * Handle Contact (Contact, Account Contact Role, Address Role Business Context) synchronization logic to SAP/DMS
 */
public with sharing class ContactSyncUtils extends SObjectSyncUtils {

    public class ContactSyncException extends Exception {
    }

    private static Map<String, List<String>> FIELDS_TO_CHECK_ON_UPDATE = new Map<String, List<String>>{
            'Contact' => new List<String>{
                    'Title',
                    'FirstName',
                    'LastName',
                    'Phone',
                    'Email'
            },
            'Account_Contact_Role__c' => new List<String>{
                    'Functional_Role__c',
                    'Contact__c'
            },
            'Address_Role_Business_Context__c' => new List<String>{
                    'Account_Activation_Context_Status__c'
            }
    };

    public ContactSyncUtils() {
        this.fieldsToCheckOnUpdate.putAll(FIELDS_TO_CHECK_ON_UPDATE);
    }

    /**
     * Handle synchronize logic between Salesforce and SAP/DMS
     *
     * @param sobjIdsByAccountIds
     * @param eventType (Insert, Update, Delete, Undelete)
     */
    public void doSynchronisation(List<SObject> sObjects, String eventType) {
        System.debug('ContactSyncUtils.doSynchronisation() - ' + eventType);

        System.debug('sObjects.size() : ' + sObjects.size());
        System.debug('sObjects : ' + sObjects);
        if (sObjects.size() == 0) {
            return;
        }

        PlatformEventUtils.clear();

        System.debug('Processing data');
        Set<String> doneKeys = new Set<String>();
        String key;
        for (Account_Contact_Role__c accountContactRole : getACRFromSObjects(sObjects)) {
            // Only one platform event per Contact in a same Account
            key = accountContactRole.Contact__c + '|' + accountContactRole.Account__c;
            if(!doneKeys.contains(key)) {
                doneKeys.add(key);

                PlatformEventUtils.add(new AccountContactRole__e(
                        EventType__c = eventType,
                        RecordType__c = accountContactRole.RecordType.DeveloperName,
                        RecordId__c = accountContactRole.Id
                ));
            }
        }


        Boolean isFullSuccess = PlatformEventUtils.send();
    }


    /**
     * Get a list of Account Contact Role from the given @sObjects (Contact, Account Contact Role, Address Role Business Context)
     *
     * @param sObjects
     *
     * @return List of Account Contact Role
     */
    private List<Account_Contact_Role__c> getACRFromSObjects(List<SObject> sObjects){
        System.debug('getACRFromSObjects()');

        Set<Id> ids = new Set<Id>();

        String query = 'SELECT Id, RecordType.DeveloperName, Contact__c, Account_Role__r.Account__c';
        query += ' FROM Account_Contact_Role__c';
        query += ' WHERE ';

        // Context is observed by the current where clause
        switch on sObjects.get(0){
            when Contact contact {
                System.debug('from Contact');
                query += 'Contact__c';

                for (SObject sobj : sObjects) {
                    ids.add(sobj.Id);
                }
            }
            when Account_Contact_Role__c  accountContactRole {
                System.debug('from Account Contact Role');
                query += 'Id';

                for (SObject sobj : sObjects) {
                    ids.add(sobj.Id);
                }
            }
            when Address_Role_Business_Context__c addressRoleBusinessContext {
                System.debug('from Address Role Business Context');
                query += 'Account_Role__r.Account__c';

                for(Address_Role_Business_Context__c addressRoleBusinessContext : [
                        SELECT Address_Role__r.Address__r.Account__c
                        FROM Address_Role_Business_Context__c
                        WHERE Id IN :sObjects
                ]){
                    ids.add(addressRoleBusinessContext.Address_Role__r.Address__r.Account__c);
                }
            }
            when else {
                // TODO throw exception with Custom Label
                throw new ContactSyncException(String.format('This process does not support the SObject {0}', new List<String>{sObjects.get(0).getSObjectType().getDescribe().getName()}));
            }
        }

        query += ' IN :ids';

        query += ' ORDER BY Account_Role__r.Account__c DESC, Contact__c DESC, Id DESC';
        System.debug('query : ' + query);
        System.debug('ids : ' + ids);

        // Apply filter : only one platform event per Contact in a same Account
        List<Account_Contact_Role__c> accountContactRoles = new List<Account_Contact_Role__c>();

        Set<String> doneKeys = new Set<String>();
        String key;
        for (Account_Contact_Role__c accountContactRole : Database.query(query)) {
            key = accountContactRole.Contact__c + '|' + accountContactRole.Account_Role__r.Account__c;
            if(!doneKeys.contains(key)) {
                doneKeys.add(key);

                accountContactRoles.add(accountContactRole);
            }
        }

        return accountContactRoles;
    }
}