@isTest
public inherited sharing class IGOMStationUtilTest {

    @TestSetup
    static void makeData(){
        IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE).get(0);

        List<Compliance_Review_Part__c> complianceReviewParts = IGOMTestFactory.createExampleComplianceReviewData();

		Id contactRoleDetailId = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1].Id;
		// Generate notifications
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		IGOM_Contact_Role_Procedure_Compliance__c noti11 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetailId, complianceReviewParts.get(3).Id);
		IGOM_Contact_Role_Procedure_Compliance__c noti12 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetailId, complianceReviewParts.get(5).Id);
		notI11.Notification_Status__c = IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED;
		notifications.addAll(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ notI11, noti12 });
		insert notifications;
    }
    
    /**
     * @description Test the getIGOMAccountRoleDetailByIds for a single station.
     */
    @isTest
    public static void getIGOMAccountRoleDetailByIdsTest_Success(){
        List<IGOMStationUtil.Station> stations;
        Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
        Test.startTest();
        stations = IGOMStationUtil.getIGOMAccountRoleDetailByIds(new List<Id>{stationId});
        Test.stopTest();

        System.assertEquals(1, stations.size());
        System.assertEquals(stationId, stations.get(0).Id);
    }
    
    /**
     * @description Test the getIGOMAccountRoleDetailByIds for multiple stations.
     */
    @isTest
    public static void getIGOMAccountRoleDetailByIdsTest_BulkSuccess(){
        List<IGOMStationUtil.Station> stations;
        Test.startTest();
        List<List<SObject>> airlineStations = IGOMTestFactory.generateIGOMUserFactory(10, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE);
        
        List<Id> stationIds = new List<Id>();
        for (List<SObject> airlineStation : airlineStations) {
            stationIds.add(airlineStation.get(5).Id);
        }

        stations = IGOMStationUtil.getIGOMAccountRoleDetailByIds(stationIds);
        Test.stopTest();

        System.assertEquals(10, stations.size());
    }

    /**
     * @description Test the getIGOMAccountRoleDetailByIds for a non IGOM_AccountRoleDetail id.
     */
    @isTest
    public static void getIGOMAccountRoleDetailByIdsTest_Error(){
        List<IGOMStationUtil.Station> stations;
        Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
        Test.startTest();
        stations = IGOMStationUtil.getIGOMAccountRoleDetailByIds(new List<Id>{accRoleId});
        Test.stopTest();
        System.assertEquals(0, stations.size());
    }

    /**
     * @description Test the getOwnStations for the active user.
     */
    @isTest
    public static void getOwnStationsTest_Success(){
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User u = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

        Map<Id, IGOMStationUtil.Station> ownStations;
        Test.startTest();
        System.runAs(u){
            ownStations = IGOMStationUtil.getOwnStations();
        }
        Test.stopTest();
        System.assertEquals(1, ownStations.keySet().size());
    }

    /**
     * @description Test the getOwnStation for the active user.
     */
    @isTest
    public static void getOwnStationTest_Success(){
        Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User u = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

        IGOMStationUtil.Station ownStation;
        Test.startTest();
        System.runAs(u){
            ownStation = IGOMStationUtil.getOwnStation(stationId);
        }
        Test.stopTest();
        System.assertNotEquals(null, ownStation);
        System.assertEquals(stationId, ownStation.id);
    }

    /**
     * @description Test the getOwnStation for the active user when the parameter is not related to that user.
     */
    @isTest
    public static void getOwnStationTest_Error(){
        Test.startTest();
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User u = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
        List<SObject> airlineStation2 = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE).get(0);
        
        IGOM_Account_Role_Detail__c accRole2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);

        IGOMStationUtil.Station ownStation;
        try {
            System.runAs(u){
                ownStation = IGOMStationUtil.getOwnStation(accRole2.Id);
            }
        } catch (AuraHandledException ahe) {
            System.assertEquals(null, ownStation);
        }
        Test.stopTest();
    }

    /**
     * @description Test the getStationsData for the Variations page when the method works propperly.
     */
    @isTest
    public static void getStationsDataTest_Variations_Success(){
        Test.startTest();
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
        List<SObject> airlineStation2 = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE).get(0);

        List<IGOMStationUtil.Station> stations;
        
        System.runAs(user){
            stations = IGOMStationUtil.getStationsData('Variations');
        }
        Test.stopTest();

        System.assertEquals(5, stations.size());
    }

    /**
     * @description Test the getStationsData for the Variations page when the user only has permission to see their own data.
     */
    @isTest
    public static void getStationsDataTest_Variations_OnlySeeOwnData(){
        Test.startTest();
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

        List<SObject> airlineStation2 = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE).get(0);

        List<IGOMStationUtil.Station> stations;
        System.runAs(user){
            stations = IGOMStationUtil.getStationsData('Variations');
        }
        Test.stopTest();

        System.assertEquals(1, stations.size());
    }

    /**
     * @description Test the getStationsData for the Variations page when the user has no permission to see the data.
     */
    @isTest
    public static void getStationsDataTest_Variations_Error(){
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = null;
		update contactRoleDetail;
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
        
        List<IGOMStationUtil.Station> stations;
        Test.startTest();
        try {
            System.runAs(user){
                stations = IGOMStationUtil.getStationsData('Variations');
            }
        } catch (AuraHandledException ahe) {
            System.assertEquals(null, stations);
        }
        Test.stopTest();
    }

    /**
     * @description Test the getStationsData for the Dashboard page when the method works propperly.
     */
    @isTest
    public static void getStationsDataTest_Dashboard_Success(){
        Test.startTest();
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
        List<SObject> airlineStation2 = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE).get(0);

        List<IGOMStationUtil.Station> stations;
        
        System.runAs(user){
            stations = IGOMStationUtil.getStationsData('Dashboard');
        }
        Test.stopTest();

        System.assertEquals(5, stations.size());
    }

    /**
     * @description Test the getStationsData for the Dashboard page when the user only has permission to see their own data.
     */
    @isTest
    public static void getStationsDataTest_Dashboard_OnlySeeOwnData(){
        Test.startTest();
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

        List<SObject> airlineStation2 = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE).get(0);

        List<IGOMStationUtil.Station> stations;
        System.runAs(user){
            stations = IGOMStationUtil.getStationsData('Dashboard');
        }
        Test.stopTest();

        System.assertEquals(1, stations.size());
    }

    /**
     * @description Test the getStationsData for the Dashboard page when the user has no permission to see the data.
     */
    @isTest
    public static void getStationsDataTest_Dashboard_Error(){
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = null;
		update contactRoleDetail;
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
        
        List<IGOMStationUtil.Station> stations;
        Test.startTest();
        try {
            System.runAs(user){
                stations = IGOMStationUtil.getStationsData('Dashboard');
            }
        } catch (AuraHandledException ahe) {
            System.assertEquals(null, stations);
        }
        Test.stopTest();
    }
}