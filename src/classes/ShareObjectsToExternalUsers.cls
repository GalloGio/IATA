/**
 * Created by ppop on 6/6/2019.
 */

public with sharing class ShareObjectsToExternalUsers {
    public static void reshareNotificationsWithUsers(List<Service_Notification_Role__c> notificationRolesNew, Map<Id, Service_Notification_Role__c> notificationRolesOld){
        List<Id> rolesNotToBeReshared = new List<Id>();
        List<Id> NotificationsToBeReshared = new List<Id>();
            if(notificationRolesOld != null && notificationRolesNew != null){
                for(Service_Notification_Role__c newRole: notificationRolesNew){
                    Service_Notification_Role__c oldRole = notificationRolesOld.get(newRole.Id);
                    if(oldRole.Contact_Roles__c != newRole.Contact_Roles__c){
                        NotificationsToBeReshared.add(newRole.Service_Notification__c);
                    }
                }
            } else if (notificationRolesOld == null && notificationRolesNew != null){
                for(Service_Notification_Role__c newRole: notificationRolesNew) {
                    NotificationsToBeReshared.add(newRole.Service_Notification__c);
                }
            } else if (notificationRolesOld != null && notificationRolesNew == null){
                for(Service_Notification_Role__c oldRole: notificationRolesOld.values()) {
                    NotificationsToBeReshared.add(oldRole.Service_Notification__c);
                    rolesNotToBeReshared.add(oldRole.Id);
                }
            } else {return;}


            unshareObject(NotificationsToBeReshared, 'Service_Notification__Share');

            List<Service_Notification_Role__c> shareRoles = [SELECT Id, Service_Notification__c, Contact_Roles__c FROM Service_Notification_Role__c
            WHERE Service_Notification__c IN :NotificationsToBeReshared AND Id NOT IN : rolesNotToBeReshared];


            Map<Id, List<Id>> usersByServiceNotifications = getUsersByNotificationRoles(shareRoles);
            shareObjectWithUsers(usersByServiceNotifications, 'Service_Notification__Share');

    }

    public static void reshareContactRoleServicePermissions(List<Contact_Role_Service_Permission__c> permissionsNew, Map<Id, Contact_Role_Service_Permission__c> permissionsOld){
        List<Id> permissionsNotToBeReshared = new List<Id>();
        List<Id> PermissionsToBeReshared = new List<Id>();
        if(permissionsOld != null && permissionsNew != null){
            for(Contact_Role_Service_Permission__c newPermission: permissionsNew){
                Contact_Role_Service_Permission__c oldPermission = permissionsOld.get(newPermission.Id);
                if(oldPermission.Contact_Role_Service__c != newPermission.Contact_Role_Service__c){
                    PermissionsToBeReshared.add(newPermission.Id);
                }
            }
        } else if (permissionsOld == null && permissionsNew != null){
            for(Contact_Role_Service_Permission__c newPermission: permissionsNew) {
                PermissionsToBeReshared.add(newPermission.Id);
            }
        } else if (permissionsOld != null && permissionsNew == null){
            for(Contact_Role_Service_Permission__c oldPermission: permissionsOld.values()) {
                PermissionsToBeReshared.add(oldPermission.Id);
                permissionsNotToBeReshared.add(oldPermission.Id);
            }
        } else {return;}

        List<Contact_Role_Service_Permission__c> toBeUnShared = [SELECT Id, Contact_Role_Service__r.Contact_Role__c FROM Contact_Role_Service_Permission__c
        WHERE Id IN :PermissionsToBeReshared AND Contact_Role_Service__r.Service__r.Name = 'GADM'];

        List<Id> toBeUnsharedIds = new List<Id>();
        for(Contact_Role_Service_Permission__c permission: toBeUnShared){
            toBeUnsharedIds.add(permission.Id);
        }

        unshareObject(toBeUnsharedIds, 'Contact_Role_Service_Permission__Share');

        List<Contact_Role_Service_Permission__c> toBeShared = [SELECT Id, Contact_Role_Service__r.Contact_Role__c FROM Contact_Role_Service_Permission__c
        WHERE Id IN :PermissionsToBeReshared AND Id NOT IN : permissionsNotToBeReshared AND Contact_Role_Service__r.Service__r.Name = 'GADM'];


        Map<Id, List<Id>> usersByServiceNotifications = getUsersByContactRolePermissions(toBeShared);
        shareObjectWithUsers(usersByServiceNotifications, 'Contact_Role_Service_Permission__Share');
    }

    public static void reshareContactRoleServices(List<Contact_Role_Service__c> servicesNew, Map<Id, Contact_Role_Service__c> servicesOld){
        List<Id> servicesNotToBeReshared = new List<Id>();
        List<Id> servicesToBeReshared = new List<Id>();
        if(servicesOld != null && servicesNew != null){
            for(Contact_Role_Service__c newService: servicesNew){
                Contact_Role_Service__c oldService = servicesOld.get(newService.Id);
                if(oldService.Contact_Role__c != newService.Contact_Role__c){
                    servicesToBeReshared.add(newService.Id);
                }
            }
        } else if (servicesOld == null && servicesNew != null){
            for(Contact_Role_Service__c newService: servicesNew) {
                servicesToBeReshared.add(newService.Id);
            }
        } else if (servicesOld != null && servicesNew == null){
            for(Contact_Role_Service__c oldService: servicesOld.values()) {
                servicesToBeReshared.add(oldService.Id);
                servicesNotToBeReshared.add(oldService.Id);
            }
        } else {return;}

        List<Contact_Role_Service_Permission__c> permissionsToUnshare = [SELECT Id, Contact_Role_Service__c
                    FROM Contact_Role_Service_Permission__c
                    where Contact_Role_Service__c IN :servicesToBeReshared AND Contact_Role_Service__r.Service__r.Name = 'GADM'];

        List<Id> permissionsToUnshareIds = new List<Id>();
        for(Contact_Role_Service_Permission__c permission: permissionsToUnshare){
            permissionsToUnshareIds.add(permission.Id);
        }

        unshareObject(permissionsToUnshareIds, 'Contact_Role_Service_Permission__share');
        unshareObject(servicesToBeReshared, 'Contact_Role_Service__Share');

        List<Contact_Role_Service__c> toBeShared = [SELECT Id, Contact_Role__c FROM Contact_Role_Service__c
        WHERE Id IN :servicesToBeReshared AND Id NOT IN : servicesNotToBeReshared AND Service__r.Name = 'GADM'];

        Map<Id, List<Id>> usersByPermission = new Map<Id, List<Id>>();
        Map<Id, List<Id>> usersByServiceNotifications = getUsersByContactRoleServices(toBeShared);

        for(Contact_Role_Service_Permission__c permission: permissionsToUnshare) {
            List<Id> serviceUsers = usersByServiceNotifications.get(permission.Contact_Role_Service__c);
            if(serviceUsers != null){
                List<Id> users = usersByPermission.get(permission.Id);
                if(users == null){
                    List<Id> usrs = new List<Id>();
                    usrs.addAll(serviceUsers);
                    usersByPermission.put(permission.Id, usrs);
                } else {
                    users.addAll(serviceUsers);
                }
            }
        }

        shareObjectWithUsers(usersByPermission, 'Contact_Role_Service_Permission__share');
        shareObjectWithUsers(usersByServiceNotifications, 'Contact_Role_Service__Share');
    }

    public static void unshareObject(List<Id> objectsToBeUnshared, string objectName){
        List<string> objIds = new List<string>();
        for(Id objId: objectsToBeUnshared){
            objIds.add('\'' + (string)objId + '\'');
        }
        if(objIds != null && objIds.size() > 0) {
            string query = 'SELECT Id FROM ' + objectName + ' WHERE ParentId IN ('+string.join(objIds, ',')+')';
            List<sObject> objects = Database.query(query);
            Database.delete(objects);
        }
    }

    public static void shareObjectWithUsers(Map<Id, List<Id>> objectToUsers, string objectName){
        List<sObject> sharingRecord = new List<sObject>();

        for(Id objectId: objectToUsers.keySet()){
            List<Id> users = objectToUsers.get(objectId);
            if(users != null){
                for(Id userId: users){
                    sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                    sObj.put('AccessLevel', 'Read');
                    sObj.put('ParentID', objectId);
                    sObj.put('UserOrGroupId', userId);
                    sharingRecord.add(sObj);
                }
            }
        }

        insert sharingRecord;
    }

    public static Map<Id, List<Id>> getUsersByContactRolePermissions(List<Contact_Role_Service_Permission__c> permissions) {
        Set<Id> roleIds = new Set<Id>();
        for(Contact_Role_Service_Permission__c crsp: permissions){
            roleIds.add(crsp.Contact_Role_Service__r.Contact_Role__c);
        }

        Map<Id, List<Id>> usersByRoles = getUsersByRoles(roleIds);
        system.debug(usersByRoles);
        Map<Id, List<Id>> usersByPermission = new Map<Id, List<Id>>();

        for(Contact_Role_Service_Permission__c permission: permissions){
            if(permission.Contact_Role_Service__c != null && permission.Contact_Role_Service__r.Contact_Role__c != null){
                List<Id> users = usersByRoles.get(permission.Contact_Role_Service__r.Contact_Role__c);
                if (users != null) {
                    for (Id userId : users) {
                        List<Id> permissionsUsers = usersByPermission.get(permission.Id);
                        if (permissionsUsers == null) {
                            usersByPermission.put(permission.Id, new List<Id>{userId});
                        } else {
                            permissionsUsers.add(userId);
                        }

                    }
                }
            }
        }


        return usersByPermission;
    }

    public static Map<Id, List<Id>> getUsersByContactRoleServices(List<Contact_Role_Service__c> services) {
        Set<Id> roleIds = new Set<Id>();
        for(Contact_Role_Service__c crs: services){
            roleIds.add(crs.Contact_Role__c);
        }

        Map<Id, List<Id>> usersByRoles = getUsersByRoles(roleIds);
        system.debug(usersByRoles);
        Map<Id, List<Id>> usersByService = new Map<Id, List<Id>>();

        for(Contact_Role_Service__c service: services){
            if(service.Contact_Role__c != null){
                List<Id> users = usersByRoles.get(service.Contact_Role__c);
                if (users != null) {
                    for (Id userId : users) {
                        List<Id> serviceUsers = usersByService.get(service.Id);
                        if (serviceUsers == null) {
                            usersByService.put(service.Id, new List<Id>{userId});
                        } else {
                            serviceUsers.add(userId);
                        }

                    }
                }
            }
        }


        return usersByService;
    }

    public static Map<Id, List<Id>> getUsersByNotificationRoles(List<Service_Notification_Role__c> roles) {
        Map<Id, List<Id>> notificationToRoleIds = new Map<Id, List<Id>>();
        Set<Id> roleIds = new Set<Id>();
        for (Service_Notification_Role__c notificationRole : roles) {
            roleIds.add(notificationRole.Contact_Roles__c);
            List<Id> rolesList = notificationToRoleIds.get(notificationRole.Service_Notification__c);
            if (rolesList == null) {
                notificationToRoleIds.put(notificationRole.Service_Notification__c, new List<Id>{
                        notificationRole.Contact_Roles__c
                });
            } else {
                rolesList.add(notificationRole.Contact_Roles__c);
            }

        }

        Map<Id, List<Id>> usersByRoles = getUsersByRoles(roleIds);
        system.debug(usersByRoles);
        Map<Id, List<Id>> usersByServiceNotifications = new Map<Id, List<Id>>();

        for (Id notification : notificationToRoleIds.keySet()) {
            List<Id> notificationRoles = notificationToRoleIds.get(notification);
            if (notificationRoles != null) {
                for (Id role : notificationRoles) {
                    List<Id> users = usersByRoles.get(role);
                    if (users != null) {
                        for (Id userId : users) {
                            List<Id> notificationUsers = usersByServiceNotifications.get(notification);
                            if (notificationUsers == null) {
                                usersByServiceNotifications.put(notification, new List<Id>{userId});
                            } else {
                                notificationUsers.add(userId);
                            }

                        }
                    }
                }
            }
        }
        system.debug(usersByServiceNotifications);
        return usersByServiceNotifications;
    }

    public static Map<Id, List<Id>> getUsersByRoles(Set<Id> contactRoles) {
        List<Contact_Role_Service_Access__c> usersWithAccess = [SELECT Id, Contact_Role__r.Contact_Roles__c, Contact__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact_Roles__c IN :contactRoles AND Status__c = 'Granted'];
        Map<Id, List<Id>> contactsByRoles = new Map<Id, List<Id>>();
        Set<Id> contactIds = new Set<Id>();
        for (Contact_Role_Service_Access__c access : usersWithAccess) {
            contactIds.add(access.Contact__c);
            List<Id> contacts = contactsByRoles.get(access.Contact_Role__r.Contact_Roles__c);
            if(contacts == null){
                contactsByRoles.put(access.Contact_Role__r.Contact_Roles__c, new List<Id>{access.Contact__c});
            } else {
                contacts.add(access.Contact__c);
            }
        }

        Map<Id, List<Id>> usersByRoles = new Map<Id, List<Id>>();

        Map<Id, Id> contactToUser = new Map<Id, Id>();
        for (User u : [SELECT Id, ContactId FROM User Where ContactId IN :contactIds]) {
            contactToUser.put(u.ContactId, u.Id);
        }
        system.debug(contactToUser);
        for (Id role : contactsByRoles.keySet()) {
            List<Id> contacts = contactsByRoles.get(role);
            if (contacts != null) {
                for (Id contactId : contacts) {
                    Id userId = contactToUser.get(contactId);
                    if (userId != null) {
                        List<Id> users = usersByRoles.get(role);
                        if (users == null) {
                            usersByRoles.put(role, new List<Id>{
                                    userId
                            });
                        } else {
                            users.add(userId);
                        }
                    }
                }
            }
        }
        return usersByRoles;
    }

    public static void shareObjectsByRoleAccessChange(List<Contact_Role_Service_Access__c> roleAccessNew, Map<Id, Contact_Role_Service_Access__c> roleAccessOld){
        List<Id> unshareContactRole = new List<Id>();
        List<Id> shareContactRole = new List<Id>();
        if(roleAccessNew != null && roleAccessOld != null){
            for(Contact_Role_Service_Access__c newRole: roleAccessNew){
                Contact_Role_Service_Access__c oldRole = roleAccessOld.get(newRole.Id);
                if(oldRole.Contact_Role__c != newRole.Contact_Role__c){
                    unshareContactRole.add(oldRole.Contact_Role__c);
                    shareContactRole.add(newRole.Contact_Role__c);
                }
                if(oldRole.Status__c == 'Granted' && newRole.Status__c != 'Granted'){
                    unshareContactRole.add(newRole.Contact_Role__c);
                }
                if(oldRole.Status__c != 'Granted' && newRole.Status__c == 'Granted'){
                    shareContactRole.add(newRole.Contact_Role__c);
                }
            }
        } else if (roleAccessOld == null && roleAccessNew != null){
            for(Contact_Role_Service_Access__c newRole: roleAccessNew) {
                if(newRole.Status__c == 'Granted') {
                    shareContactRole.add(newRole.Contact_Role__c);
                }
            }
        } else if (roleAccessOld != null && roleAccessNew == null){
            for(Contact_Role_Service_Access__c oldRole: roleAccessOld.values()) {
                unshareContactRole.add(oldRole.Contact_Role__c);
            }
        } else {return;}

        List<Account_Contact_Role__c> share = [SELECT Id, Contact_Roles__c, Contact__c FROM Account_Contact_Role__c WHERE Id IN : shareContactRole];
        List<Account_Contact_Role__c> unshare = [SELECT Id, Contact_Roles__c, Contact__c FROM Account_Contact_Role__c WHERE Id IN : unshareContactRole];
        Set<Id> roles = new Set<Id>();
        Set<Id> contacts = new Set<Id>();


        for (Account_Contact_Role__c role: share){
            roles.add(role.Contact_Roles__c);
            contacts.add(role.Contact__c);
        }

        for (Account_Contact_Role__c role: unshare){
            roles.add(role.Contact_Roles__c);
            contacts.add(role.Contact__c);
        }
        Map<Id, Set<Id>> roleToObjects = getRolesRelatedObjects(roles);
        Map<Id, Id> getUsersForContacts = getUsersForContacts(contacts);

        Map<Id, Set<Id>> objectsForUserShare = new Map<Id, Set<Id>>();
        for (Account_Contact_Role__c role: share){
            Set<Id> objects = roleToObjects.get(role.Contact_Roles__c);
            Id user = getUsersForContacts.get(role.Contact__c);
            if (objects != null && user != null){
                Set<Id> objectsForUser = objectsForUserShare.get(user);
                if(objectsForUser != null){
                    objectsForUser.addAll(objects);
                } else {
                    objectsForUserShare.put(user, objects);
                }
            }
        }


        Map<Id, Set<Id>> objectsForUserUnshare = new Map<Id, Set<Id>>();
        for (Account_Contact_Role__c role: unshare){
            Set<Id> objects = roleToObjects.get(role.Contact_Roles__c);
            Id user = getUsersForContacts.get(role.Contact__c);
            if (objects != null && user != null){
                Set<Id> objectsForUser = objectsForUserUnshare.get(user);
                if(objectsForUser != null){
                    objectsForUser.addAll(objects);
                } else {
                    objectsForUserUnshare.put(user, objects);
                }
            }
        }

        unshareObjectsForUsers(objectsForUserUnshare,'Service_Notification__share');
        unshareObjectsForUsers(objectsForUserUnshare,'Contact_Role_Service__share');
        unshareObjectsForUsers(objectsForUserUnshare,'Contact_Role_Service_Permission__share');
        shareObjectsWithUsers(objectsForUserShare,'Service_Notification__share', 'Service_Notification__c');
        shareObjectsWithUsers(objectsForUserShare,'Contact_Role_Service__share', 'Contact_Role_Service__c');
        shareObjectsWithUsers(objectsForUserShare,'Contact_Role_Service_Permission__share', 'Contact_Role_Service_Permission__c');
    }

    public static void shareObjectsByRoleOnAccountContactRoleChange(List<Account_Contact_Role__c> accConRoleNew, Map<Id, Account_Contact_Role__c> accConRoleOld) {
        Map<Id, List<Id>> unshareContactRole = new Map<Id, List<Id>>();
        Map<Id, List<Id>> shareContactRole = new Map<Id, List<Id>>();
        Set<Id> contacts = new Set<Id>();

        if (accConRoleNew != null && accConRoleOld != null) {
            for (Account_Contact_Role__c newRole : accConRoleNew) {
                Account_Contact_Role__c oldRole = accConRoleOld.get(newRole.Id);
                if ((oldRole.Contact_Roles__c != newRole.Contact_Roles__c) || (oldRole.Contact__c != newRole.Contact__c)) {
                    List<Id> oldContacts = unshareContactRole.get(oldRole.Contact_Roles__c);
                    if(oldContacts==null){
                        unshareContactRole.put(oldRole.Contact_Roles__c, new List<Id>{oldRole.Contact__c});
                    } else {
                        oldContacts.add(oldRole.Contact__c);
                    }

                    List<Id> newContacts = shareContactRole.get(newRole.Contact_Roles__c);
                    if(newContacts==null){
                        shareContactRole.put(newRole.Contact_Roles__c, new List<Id>{newRole.Contact__c});
                    } else {
                        newContacts.add(newRole.Contact__c);
                    }

                    contacts.add(newRole.Contact__c);
                    contacts.add(oldRole.Contact__c);
                }
            }
        } else if (accConRoleOld == null && accConRoleNew != null) {
            for (Account_Contact_Role__c newRole : accConRoleNew) {
                    List<Id> newContacts = shareContactRole.get(newRole.Contact_Roles__c);
                    if(newContacts==null){
                        shareContactRole.put(newRole.Contact_Roles__c, new List<Id>{newRole.Contact__c});
                    } else {
                        newContacts.add(newRole.Contact__c);
                    }
                    contacts.add(newRole.Contact__c);
            }
        } else if (accConRoleOld != null && accConRoleNew == null) {
            for (Account_Contact_Role__c oldRole : accConRoleOld.values()) {
                List<Id> oldContacts = unshareContactRole.get(oldRole.Contact_Roles__c);
                if(oldContacts==null){
                    unshareContactRole.put(oldRole.Contact_Roles__c, new List<Id>{oldRole.Contact__c});
                } else {
                    oldContacts.add(oldRole.Contact__c);
                }
                contacts.add(oldRole.Contact__c);
            }
        } else {
            return;
        }

        Set<Id> roles = new Set<Id>();
        for(Id roleId: unshareContactRole.keySet()){
            roles.add(roleId);
        }

        for(Id roleId: shareContactRole.keySet()){
            roles.add(roleId);
        }
        system.debug('sharing');
        system.debug(unshareContactRole);
        system.debug(shareContactRole);

        Map<Id, List<string>> accountContactRolesAccessStatus = new Map<Id, List<string>>();
        List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Contact_Role__r.Contact_Roles__c, Status__c FROM Contact_Role_Service_Access__c WHERE Id =: roles];
        for(Contact_Role_Service_Access__c access: accesses){
            List<string> statusses = accountContactRolesAccessStatus.get(access.Contact_Role__c);
            if(statusses == null){
                accountContactRolesAccessStatus.put(access.Contact_Role__r.Contact_Roles__c, new List<string>{access.Status__c});
            } else {
                statusses.add(access.Status__c);
            }
        }



        Map<Id, Set<Id>> roleToObjects = getRolesRelatedObjects(roles);
        Map<Id, Id> getUsersForContacts = getUsersForContacts(contacts);
        system.debug('roleToObjects');
        system.debug(roleToObjects);
        system.debug(getUsersForContacts);
        Map<Id, Set<Id>> objectsForUserShare = new Map<Id, Set<Id>>();
        for (Id role : shareContactRole.keySet()) {
            List<string> statuses = accountContactRolesAccessStatus.get(role);
            if(statuses == null || (statuses != null && !statuses.contains('Granted'))){
                continue;
            }
            List<Id> contactIds = shareContactRole.get(role);
            if(contacts != null){
                for(Id contactId: contactIds){
                    Set<Id> objects = roleToObjects.get(role);
                    Id user = getUsersForContacts.get(contactId);
                    system.debug('obj+uset');
                    system.debug(user);
                    system.debug(objects);

                    if (objects != null && user != null) {
                        Set<Id> objectsForUser = objectsForUserShare.get(user);
                        if (objectsForUser != null) {
                            objectsForUser.addAll(objects);
                        } else {
                            objectsForUserShare.put(user, objects);
                        }
                    }
                }
            }
        }

        Map<Id, Set<Id>> objectsForUserUnshare = new Map<Id, Set<Id>>();
        for (Id role : unshareContactRole.keySet()) {
            List<Id> contactIds = unshareContactRole.get(role);
            if(contacts != null){
                for(Id contactId: contactIds){
                    Set<Id> objects = roleToObjects.get(role);
                    Id user = getUsersForContacts.get(contactId);
                    if (objects != null && user != null) {
                        Set<Id> objectsForUser = objectsForUserUnshare.get(user);
                        if (objectsForUser != null) {
                            objectsForUser.addAll(objects);
                        } else {
                            objectsForUserUnshare.put(user, objects);
                        }
                    }
                }
            }
        }

        system.debug(objectsForUserUnshare);
        system.debug(objectsForUserShare);
        unshareObjectsForUsers(objectsForUserUnshare, 'Service_Notification__share');
        unshareObjectsForUsers(objectsForUserUnshare, 'Contact_Role_Service__share');
        unshareObjectsForUsers(objectsForUserUnshare, 'Contact_Role_Service_Permission__share');
        shareObjectsWithUsers(objectsForUserShare, 'Service_Notification__share', 'Service_Notification__c');
        shareObjectsWithUsers(objectsForUserShare, 'Contact_Role_Service__share', 'Contact_Role_Service__c');
        shareObjectsWithUsers(objectsForUserShare, 'Contact_Role_Service_Permission__share', 'Contact_Role_Service_Permission__c');
    }

    public static void unshareObjectsForUsers(Map<Id, Set<Id>> usersToObjects, string objectName){
        List<string> conditions = new List<string>();
        for(Id userId: usersToObjects.keySet()){
            Set<Id> objects = usersToObjects.get(userId);
            if(objects != null){
                for(Id objectId: objects){
                    conditions.add('(UserOrGroupId=\''+userId+ '\' AND ParentId=\''+ objectId +'\')');
                }
            }
        }

        if(conditions != null && conditions.size() > 0) {
            string query = 'SELECT Id FROM ' + objectName + ' WHERE '+ string.join(conditions, ' OR ');
            system.debug(query);
            List<sObject> objects = Database.query(query);
            Database.delete(objects);
        }
    }

    public static void shareObjectsWithUsers(Map<Id, Set<Id>> usersToObjects, string objectName, string parentObjectName){
        List<sObject> sharingRecord = new List<sObject>();
        string objectPrefix = getObjectIdPrefix(parentObjectName);
        for(Id userId: usersToObjects.keySet()){
            Set<Id> objects = usersToObjects.get(userId);
            if(objects != null){
                for(Id objectId: objects){
                    if(!((string)objectId).startsWith(objectPrefix)){continue;}
                    sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                    sObj.put('AccessLevel', 'Read');
                    sObj.put('ParentID', objectId);
                    sObj.put('UserOrGroupId', userId);
                    sharingRecord.add(sObj);
                }
            }
        }

        insert sharingRecord;
    }

    public static string getObjectIdPrefix(string objectName){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }

    //roleID, List object Ids
    public static Map<Id, Set<Id>> getRolesRelatedObjects(Set<Id> contactRolesId){
        Map<Id, Set<Id>> roleToObjects = new Map<Id, Set<Id>>();
        List<Service_Notification_Role__c> notifications = [SELECT Service_Notification__c, Contact_Roles__c FROM Service_Notification_Role__c where Contact_Roles__c IN :contactRolesId AND Service_Notification__r.Service__r.Name = 'GADM'];
        List<Contact_Role_Service__c > services = [SELECT Id, Contact_Role__c FROM Contact_Role_Service__c where Contact_Role__c IN :contactRolesId AND Service__r.Name = 'GADM'];
        List<Contact_Role_Service_Permission__c> permissions = [SELECT Id, Contact_Role_Service__r.Contact_Role__c FROM Contact_Role_Service_Permission__c where Contact_Role_Service__r.Contact_Role__c IN :contactRolesId AND Contact_Role_Service__r.Service__r.Name = 'GADM'];

        for(Service_Notification_Role__c notification: notifications){
            Set<Id> objects = roleToObjects.get(notification.Contact_Roles__c);
            if(objects == null){
                roleToObjects.put(notification.Contact_Roles__c, new Set<Id>{notification.Service_Notification__c});
            } else {
                objects.add(notification.Service_Notification__c);
            }
        }
        for(Contact_Role_Service__c service: services){
            Set<Id> objects = roleToObjects.get(service.Contact_Role__c);
            if(objects == null){
                roleToObjects.put(service.Contact_Role__c, new Set<Id>{service.Id});
            } else {
                objects.add(service.Id);
            }
        }
        for(Contact_Role_Service_Permission__c permission: permissions){
            Set<Id> objects = roleToObjects.get(permission.Contact_Role_Service__r.Contact_Role__c);
            if(objects == null){
                roleToObjects.put(permission.Contact_Role_Service__r.Contact_Role__c, new Set<Id>{permission.Id});
            } else {
                objects.add(permission.Id);
            }
        }
        return roleToObjects;
    }
    //contact, user
    public static Map<Id, Id> getUsersForContacts(Set<Id> contactIds){
        Map<Id, Id> contactToUser = new Map<Id, Id>();
        for (User u : [SELECT Id, ContactId FROM User Where ContactId IN :contactIds]) {
            contactToUser.put(u.ContactId, u.Id);
        }

        return contactToUser;
    }
}