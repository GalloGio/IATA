@isTest
private class IGOMPermissionsTest {
	public static final String UNEXP_EXC_CAUGHT = 'Unexpected exception caught ';
	public static final String TEST_NAME = 'Test name ';

	@TestSetup
	static void makeData() {
        // Create two stations
		List<List<SObject>> objectsStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ);
		List<SObject> objectsStation1 = objectsStations.get(0);
		List<SObject> objectsStation2 = objectsStations.get(1);
        Account station1Account = (Account) objectsStation1.get(0);
        Account station2Account = (Account) objectsStation2.get(0);
        Contact station1Contact = (Contact) objectsStation1.get(1);
        Account_Role__c station1AccountRole = (Account_Role__c) objectsStation1.get(3);
        Account_Role__c station2AccountRole = (Account_Role__c) objectsStation2.get(3);
        IGOM_Account_Role_Detail__c station1 = (IGOM_Account_Role_Detail__c) objectsStation1.get(5);
		IGOM_Account_Role_Detail__c station2 = (IGOM_Account_Role_Detail__c) objectsStation2.get(5);
		IGOM_Contact_Role_Detail__c contactRoleDetail1 = (IGOM_Contact_Role_Detail__c) objectsStation1.get(6);
        // Add a contact with a different role in the parent station and second station
        Contact newContact1 = IGOMTestFactory.contactFactoryCreation(1, station1Account.Id).get(0);
        insert new List<Contact>{ newContact1 };
        Account_Contact_Role__c accountContactRole1 = IGOMTestFactory.createAccountContactRole(station1Account.Id, newContact1.Id, station1AccountRole.Id);
        Account_Contact_Role__c accountContactRole2 = IGOMTestFactory.createAccountContactRole(station2Account.Id, station1Contact.Id, station2AccountRole.Id);
        insert new List<Account_Contact_Role__c>{ accountContactRole1, accountContactRole2 };
        IGOM_Contact_Role_Detail__c contactRoleDetailViewer1 = IGOMTestFactory.createIGOMContactRoleDetail(accountContactRole1.Id, station1.Id, IGOMConstants.ROLES.VIEWER);
        IGOM_Contact_Role_Detail__c contactRoleDetailViewer2 = IGOMTestFactory.createIGOMContactRoleDetail(accountContactRole2.Id, station2.Id, IGOMConstants.ROLES.ACKNOWLEDGER);
        insert new List<IGOM_Contact_Role_Detail__c>{ contactRoleDetailViewer1, contactRoleDetailViewer2 };
    }

    @isTest 
    private static void testStationRolesMultipleRolesOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        Map<Id, String> stationIdToRole;
        System.runAs(contactUser) {
            stationIdToRole = IGOMPermissions.retrieveStationIdToRole();
        }

        Test.stopTest();

        Map<String, Id> accountRoleNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        System.assertEquals(2, stationIdToRole.size());
        System.assertEquals(IGOMConstants.ROLES.ADMIN, stationIdToRole.get(accountRoleNameToId.get(TEST_NAME+'0')));
        System.assertEquals(IGOMConstants.ROLES.ACKNOWLEDGER, stationIdToRole.get(accountRoleNameToId.get(TEST_NAME+'1')));
    }

    @isTest
    private static void testStationRolesSingleRoleOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        Map<Id, String> stationIdToRole;
        System.runAs(contactUser) {
            stationIdToRole = IGOMPermissions.retrieveStationIdToRole();
        }

        Test.stopTest();

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        System.assertEquals(1, stationIdToRole.size());
        System.assertEquals(IGOMConstants.ROLES.ADMIN, stationIdToRole.get(accountRoleDetailNameToId.get(TEST_NAME+'1')));
    }

    @isTest
    private static void testStationRolesNoRoleError() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        List<IGOM_Contact_Role_Detail__c> contactRoleDetails = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__r.Contact__c = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
        delete contactRoleDetails;

        Test.startTest();

        System.runAs(contactUser) {
            try {
                IGOMPermissions.retrieveStationIdToRole();
            } catch (AuraHandledException error) {
                System.assert(true);
            } catch (Exception error) {
                System.assert(false, UNEXP_EXC_CAUGHT + error);
            }
        }

        Test.stopTest();
    }

    @isTest
    private static void testStationRolesNoContactIdError() {
		User contactUser = [SELECT Id FROM User WHERE ContactId = null AND IsActive = true LIMIT 1];

        Test.startTest();

        System.runAs(contactUser) {
            try {
                IGOMPermissions.retrieveStationIdToRole();
            } catch (AuraHandledException error) {
                System.assert(true);
            } catch (Exception error) {
                System.assert(false, UNEXP_EXC_CAUGHT + error);
            }
        }

        Test.stopTest();
    }

    @isTest 
    private static void testGetPermissionsGlobalMultipleRolesOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
        contactRoleDetail.Role__c = IGOMConstants.ROLES.EDITOR;
        update contactRoleDetail;
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        Map<String, Boolean> permissions;
        System.runAs(contactUser) {
            permissions = IGOMPermissions.getPermissions(null);
        }

        Test.stopTest();

        // EDITOR + ACKNOWLEDGER permissions
        System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD), 
            permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD),
            permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.CREATE_GAP) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.CREATE_GAP), 
            permissions.get(IGOMConstants.PERMISSIONS.CREATE_GAP)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.EDIT_GAP) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.EDIT_GAP), 
            permissions.get(IGOMConstants.PERMISSIONS.EDIT_GAP)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.DOCUMENT_GAP) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.DOCUMENT_GAP), 
            permissions.get(IGOMConstants.PERMISSIONS.DOCUMENT_GAP)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.NOTIFY_GAP) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.NOTIFY_GAP), 
            permissions.get(IGOMConstants.PERMISSIONS.NOTIFY_GAP)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP), 
            permissions.get(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.PUBLISH_GAP) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.PUBLISH_GAP), 
            permissions.get(IGOMConstants.PERMISSIONS.PUBLISH_GAP)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL), 
            permissions.get(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS), 
            permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL), 
            permissions.get(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS), 
            permissions.get(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS), 
            permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS), 
            permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS)
        );
		System.assertEquals(
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.EDITOR).contains(IGOMConstants.PERMISSIONS.MANAGE_STATION) ||
            IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.MANAGE_STATION), 
            permissions.get(IGOMConstants.PERMISSIONS.MANAGE_STATION)
        );

    }

    @isTest 
    private static void testGetPermissionsGlobalSingleRoleOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        Map<String, Boolean> permissions;
        System.runAs(contactUser) {
            permissions = IGOMPermissions.getPermissions(null);
        }

        Test.stopTest();

        System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD), permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.CREATE_GAP), permissions.get(IGOMConstants.PERMISSIONS.CREATE_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.EDIT_GAP), permissions.get(IGOMConstants.PERMISSIONS.EDIT_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.DOCUMENT_GAP), permissions.get(IGOMConstants.PERMISSIONS.DOCUMENT_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.NOTIFY_GAP), permissions.get(IGOMConstants.PERMISSIONS.NOTIFY_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP), permissions.get(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.PUBLISH_GAP), permissions.get(IGOMConstants.PERMISSIONS.PUBLISH_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL), permissions.get(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL), permissions.get(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS), permissions.get(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.MANAGE_STATION), permissions.get(IGOMConstants.PERMISSIONS.MANAGE_STATION));
    }

    @isTest 
    private static void testGetPermissionsGlobalNoRoleError() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        List<IGOM_Contact_Role_Detail__c> contactRoleDetails = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__r.Contact__c = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
        delete contactRoleDetails;

        Test.startTest();

        System.runAs(contactUser) {
            try {
                IGOMPermissions.getPermissions(null);
            } catch (AuraHandledException error) {
                System.assert(true);
            } catch (Exception error) {
                System.assert(false, UNEXP_EXC_CAUGHT + error);
            }
        }

        Test.stopTest();
    }

    @isTest 
    private static void testGetPermissionsStationNoRoleError() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        delete contactRoleDetail;

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        System.runAs(contactUser) {
            try {
                IGOMPermissions.getPermissions(accountRoleDetailNameToId.get(TEST_NAME+'0'));
            } catch (AuraHandledException error) {
                System.assert(true);
            } catch (Exception error) {
                System.assert(false, UNEXP_EXC_CAUGHT + error);
            }
        }

        Test.stopTest();
    }

    @isTest 
    private static void testGetPermissionsGlobalNullRoleOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        List<IGOM_Contact_Role_Detail__c> otherContactRoleDetails = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__r.Contact__c = :contactRoleDetail.Account_Contact_Role__r.Contact__c AND Id != :contactRoleDetail.Id];
        delete otherContactRoleDetails;
        contactRoleDetail.Role__c = null;
        update contactRoleDetail;

        Test.startTest();

        Map<String, Boolean> permissions;
        System.runAs(contactUser) {
            permissions = IGOMPermissions.getPermissions(null);
        }

        Test.stopTest();

        for (Boolean permission : permissions.values()) {
            System.assertEquals(false, permission);
        }
    }

    @isTest 
    private static void testGetPermissionsStationAdminOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        Map<String, Boolean> permissions;
        System.runAs(contactUser) {
            permissions = IGOMPermissions.getPermissions(accountRoleDetailNameToId.get(TEST_NAME+'0'));
        }

        Test.stopTest();

        System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD), permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.CREATE_GAP), permissions.get(IGOMConstants.PERMISSIONS.CREATE_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.EDIT_GAP), permissions.get(IGOMConstants.PERMISSIONS.EDIT_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.DOCUMENT_GAP), permissions.get(IGOMConstants.PERMISSIONS.DOCUMENT_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.NOTIFY_GAP), permissions.get(IGOMConstants.PERMISSIONS.NOTIFY_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP), permissions.get(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.PUBLISH_GAP), permissions.get(IGOMConstants.PERMISSIONS.PUBLISH_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL), permissions.get(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL), permissions.get(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS), permissions.get(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ADMIN).contains(IGOMConstants.PERMISSIONS.MANAGE_STATION), permissions.get(IGOMConstants.PERMISSIONS.MANAGE_STATION));
    }

    @isTest 
    private static void testGetPermissionsStationViewerOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        Map<String, Boolean> permissions;
        System.runAs(contactUser) {
            permissions = IGOMPermissions.getPermissions(accountRoleDetailNameToId.get(TEST_NAME+'1'));
        }

        Test.stopTest();

        System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD), permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.CREATE_GAP), permissions.get(IGOMConstants.PERMISSIONS.CREATE_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.EDIT_GAP), permissions.get(IGOMConstants.PERMISSIONS.EDIT_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.DOCUMENT_GAP), permissions.get(IGOMConstants.PERMISSIONS.DOCUMENT_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.NOTIFY_GAP), permissions.get(IGOMConstants.PERMISSIONS.NOTIFY_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP), permissions.get(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.PUBLISH_GAP), permissions.get(IGOMConstants.PERMISSIONS.PUBLISH_GAP));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL), permissions.get(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL), permissions.get(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS), permissions.get(IGOMConstants.PERMISSIONS.CHECK_NOTIFICATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS), permissions.get(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS));
		System.assertEquals(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(IGOMConstants.ROLES.ACKNOWLEDGER).contains(IGOMConstants.PERMISSIONS.MANAGE_STATION), permissions.get(IGOMConstants.PERMISSIONS.MANAGE_STATION));
    }

    @isTest 
    private static void testContactsWithPermissionsMultipleOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        List<Id> contactRoleDetailIds;
        System.runAs(contactUser) {
            contactRoleDetailIds = IGOMPermissions.contactRoleDetailIdsWithPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD);
        }

        Test.stopTest();

        IGOM_Contact_Role_Detail__c contactRoleDetailAcknowledger = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER LIMIT 1];

        Set<Id> contactRoleDetailIdsSet = new Set<Id>(contactRoleDetailIds);
        System.assertEquals(2, contactRoleDetailIds.size());
        System.assert(contactRoleDetailIdsSet.contains(contactRoleDetail.Id));
        System.assert(contactRoleDetailIdsSet.contains(contactRoleDetailAcknowledger.Id));
    }
    
    @isTest 
    private static void testContactsWithPermissionsSingleOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        List<Id> contactRoleDetailIds;
        System.runAs(contactUser) {
            contactRoleDetailIds = IGOMPermissions.contactRoleDetailIdsWithPermission(IGOMConstants.PERMISSIONS.MANAGE_STATION);
        }

        Test.stopTest();

        System.assertEquals(1, contactRoleDetailIds.size());
        System.assert(contactRoleDetailIds.contains(contactRoleDetail.Id));
    }

    @isTest 
    private static void testContactsWithPermissionsNoneOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        List<Id> contactRoleDetailIds;
        System.runAs(contactUser) {
            contactRoleDetailIds = IGOMPermissions.contactRoleDetailIdsWithPermission(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL);
        }

        Test.stopTest();

        System.assertEquals(0, contactRoleDetailIds.size());
    }   

    @isTest 
    private static void testStationsWithPermissionsMultipleOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        List<Id> accountRoleDetailIds;
        System.runAs(contactUser) {
            accountRoleDetailIds = IGOMPermissions.stationsWithPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD);
        }

        Test.stopTest();

        Set<Id> accountRoleDetailIdsSet = new Set<Id>(accountRoleDetailIds);
        System.assertEquals(2, accountRoleDetailIds.size());
        System.assert(accountRoleDetailIdsSet.contains(accountRoleDetailNameToId.get(TEST_NAME+'0')));
        System.assert(accountRoleDetailIdsSet.contains(accountRoleDetailNameToId.get(TEST_NAME+'1')));
    }
    
    @isTest 
    private static void testStationsWithPermissionsSingleOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        List<Id> accountRoleDetailIds;
        System.runAs(contactUser) {
            accountRoleDetailIds = IGOMPermissions.stationsWithPermission(IGOMConstants.PERMISSIONS.MANAGE_STATION);
        }

        Test.stopTest();

        System.assertEquals(1, accountRoleDetailIds.size());
        System.assert(accountRoleDetailIds.contains(accountRoleDetailNameToId.get(TEST_NAME+'0')));
    }

    @isTest 
    private static void testStationsWithPermissionsNoneOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        List<Id> accountRoleDetailIds;
        System.runAs(contactUser) {
            accountRoleDetailIds = IGOMPermissions.stationsWithPermission(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL);
        }

        Test.stopTest();

        System.assertEquals(0, accountRoleDetailIds.size());
    }  
    
    @isTest 
    private static void testHasPermissionTrueStationAdminOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        Boolean hasPermission;
        System.runAs(contactUser) {
            hasPermission = IGOMPermissions.hasPermission(accountRoleDetailNameToId.get(TEST_NAME+'0'), IGOMConstants.PERMISSIONS.MANAGE_STATION);
        }

        Test.stopTest();

        System.assertEquals(true, hasPermission);
    }

    @isTest 
    private static void testHasPermissionFalseStationAdminOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 0' AND Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        Boolean hasPermission;
        System.runAs(contactUser) {
            hasPermission = IGOMPermissions.hasPermission(accountRoleDetailNameToId.get(TEST_NAME+'0'), IGOMConstants.PERMISSIONS.UPLOAD_MANUAL);
        }

        Test.stopTest();

        System.assertEquals(false, hasPermission);
    }

    @isTest 
    private static void testHasPermissionFalseStationAcknowledgerOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Map<String, Id> accountRoleDetailNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleDetailNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

        Test.startTest();

        Boolean hasPermission;
        System.runAs(contactUser) {
            hasPermission = IGOMPermissions.hasPermission(accountRoleDetailNameToId.get(TEST_NAME+'1'), IGOMConstants.PERMISSIONS.MANAGE_STATION);
        }

        Test.stopTest();

        System.assertEquals(false, hasPermission);
    }

    @isTest 
    private static void testHasPermissionTrueGlobalAcknowledgerOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        Boolean hasPermission;
        System.runAs(contactUser) {
            hasPermission = IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.MANAGE_STATION);
        }

        Test.stopTest();

        System.assertEquals(true, hasPermission);
    }

    @isTest 
    private static void testHasPermissionFalseGlobalAcknowledgerOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
            [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
            WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

        Test.startTest();

        Boolean hasPermission;
        System.runAs(contactUser) {
            hasPermission = IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL);
        }

        Test.stopTest();

        System.assertEquals(false, hasPermission);
    }

}