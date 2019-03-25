@isTest
public with sharing class RecordSharingControllerTest {

    @testSetup static void setupData() {
        Case oCase = new Case(Subject = 'TestCaseExternalConnection');

        Test.startTest();
        insert oCase;
        Test.stopTest();
    }

    @isTest static void testGetUserPermission() {
        case cs=[select id from case limit 1].get(0);
        Test.startTest();
        Boolean userPermission = RecordSharingController.getUserPermission(cs.id);
        Test.stopTest();
    }

    @isTest static void testGetNetworkConnection() {
        Test.startTest();
        List<PartnerNetworkConnection> networkConnection = RecordSharingController.getNetworkConnection();
        Test.stopTest();

        System.assertEquals(false, networkConnection.isEmpty());
    }    

    @isTest static void testInsertRecordConnection() {
        List<Id> connectionsId = new List<Id>();

        Case oCase = [SELECT Id FROM Case WHERE Subject = 'TestCaseExternalConnection' LIMIT 1];
        List<PartnerNetworkConnection> networkConnection = RecordSharingController.getNetworkConnection();
        for(PartnerNetworkConnection pnc : networkConnection) {
            connectionsId.add(pnc.Id);
        }

        Test.startTest();
        RecordSharingController.insertRecordConnection(connectionsId, oCase.Id, true);
        Test.stopTest();

        List<PartnerNetworkRecordConnection> recordConnection = [SELECT Id FROM PartnerNetworkRecordConnection WHERE LocalRecordId = :oCase.Id];
        System.assertEquals(false, recordConnection.isEmpty());
        
        List<RecordSharingController.ConnectionWrapper> connectionInfo = RecordSharingController.getNetworkRecordConnection(oCase.Id);
        System.assertEquals(false, connectionInfo.isEmpty());
    }
    
    @isTest static void testStopSharingRecordConnection() {
        List<Id> connectionsId = new List<Id>();

        Case oCase = [SELECT Id FROM Case WHERE Subject = 'TestCaseExternalConnection' LIMIT 1];
        List<PartnerNetworkConnection> networkConnection = RecordSharingController.getNetworkConnection();
        for(PartnerNetworkConnection pnc : networkConnection) {
            connectionsId.add(pnc.Id);
        }

        Test.startTest();
        RecordSharingController.insertRecordConnection(connectionsId, oCase.Id, true);

        PartnerNetworkRecordConnection recordConnection = [SELECT Id FROM PartnerNetworkRecordConnection WHERE LocalRecordId = :oCase.Id LIMIT 1];
        RecordSharingController.stopSharingConnection(recordConnection.Id);
        Test.stopTest();
        
        PartnerNetworkRecordConnection stopRecordConnection = [SELECT Status FROM PartnerNetworkRecordConnection WHERE LocalRecordId = :oCase.Id LIMIT 1];
        System.assertEquals('Inactive', stopRecordConnection.Status);
    }    
}