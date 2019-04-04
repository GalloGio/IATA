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
    }
    
    @isTest static void testStopSharingRecordConnection() {
        List<Id> connectionsId = new List<Id>();

        Id testId = '04V000000000000000'; //valid for PartnerNetworkRecordConnection sObject

        Test.startTest();
        //It is not possible to set an existent id as parameter of the method because 
        //the PartnerNetworkRecordConnection record is dependent from an environment variable
        RecordSharingController.stopSharingConnection(testId);
        Test.stopTest();
    }
    
    @isTest static void testGetNetworkRecordConnection() {
        List<PartnerNetworkConnection> networkConnection = RecordSharingController.getNetworkConnection();
        
        Test.startTest();
        List<RecordSharingController.ConnectionWrapper> networkRecordConnection = RecordSharingController.getNetworkRecordConnection(networkConnection.get(0).Id);
        Test.stopTest();
    } 
    
    @isTest static void testConnectionWrapper() {
        List<PartnerNetworkConnection> networkConnection = RecordSharingController.getNetworkConnection();
        
        Test.startTest();
        RecordSharingController.ConnectionWrapper connectionWrapper = new RecordSharingController.ConnectionWrapper('Status', 'Name', UserInfo.getUserId(), Datetime.now(), false, networkConnection.get(0).Id);
        Test.stopTest();
    } 
}