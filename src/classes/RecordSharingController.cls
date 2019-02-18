public with sharing class RecordSharingController { 

    /* 
    * @description Method used to return a list of record shared with others Salesforce instances, using Salesforce to Salesforce.
    * @params recordId Case recordId.
    * @return List<ConnectionWrapper> Wrapper Class to populate a datatable with information of two sObjects, PartnerNetworkConnection and PartnerNetworkRecordConnection.
    */

    @AuraEnabled(cacheable=true)
    public static List<ConnectionWrapper> getNetworkRecordConnection(Id recordId) {
        List<PartnerNetworkRecordConnection> recordConnection;
        Map<Id, PartnerNetworkConnection> networkConnection;
        List<ConnectionWrapper> connectionInfo = new List<ConnectionWrapper>();
        Set<Id> connectionIds = new Set<Id>();

        recordConnection = [   
            SELECT Id, ConnectionId, StartDate, Status
            FROM PartnerNetworkRecordConnection
            WHERE LocalRecordId = :recordId
        ];

        if(!recordConnection.isEmpty()) {
            for(PartnerNetworkRecordConnection rec :recordConnection) {
                connectionIds.add(rec.ConnectionId);
            }

            networkConnection = new Map<Id, PartnerNetworkConnection>([
                SELECT ConnectionName, PrimaryContactId
                FROM PartnerNetworkConnection
                WHERE Id IN :connectionIds
            ]);

            for(PartnerNetworkRecordConnection rec :recordConnection) {
                PartnerNetworkConnection connectionRef = networkConnection.get(rec.ConnectionId);
                connectionInfo.add(new ConnectionWrapper(
                    rec.Status, 
                    connectionRef.ConnectionName,
                    connectionRef.PrimaryContactId, 
                    rec.StartDate,
                    rec.Status == 'Sent' ? false : true,
                    rec.Id)
                );
            }
        }

        return connectionInfo;
    }

    /* 
    * @description Method used to return a list of Org connections using Salesforce to Salesforce.
    * @params void
    * @return List<PartnerNetworkConnection> Collection of Org connections, with "Accepted" status.
    */

    @AuraEnabled
    public static List<PartnerNetworkConnection> getNetworkConnection() {
        List<PartnerNetworkConnection> networkConnection = new List<PartnerNetworkConnection>();
        
        networkConnection = [
            SELECT Id, ConnectionName, ConnectionStatus 
            FROM PartnerNetworkConnection 
            WHERE ConnectionStatus = 'Accepted'
        ];

        return networkConnection;
    }

    /* 
    * @description Method used to stop (delete) sharing of a Case object, with another Org. 
    * @description Salesforce provides a delete method to do this, automatically changing the Status to "Inactive".
    * @params recordConnectionId Id of a PartnerNetworkRecordConnection Object, related to the Case record.
    * @return void
    */

    @AuraEnabled
    public static void stopSharingConnection(Id recordConnectionId) {
        PartnerNetworkRecordConnection con = new PartnerNetworkRecordConnection(
            Id = recordConnectionId
        );

        delete con;
    }

    /* 
    * @description Method used to start (create) a new record sharing with another Org.
    * @params connectionId Collection of Org connections using Salesforce to Salesforce
    * @params localRecordId Case recordId
    * @params sendEmail Boolean to indicate if an email will be sent to the connection's representative that you have forwarded the record to them 
    * @return void
    */

    @AuraEnabled
    public static void insertRecordConnection(List<Id> connectionId, Id localRecordId, Boolean sendEmail) {
        List<PartnerNetworkRecordConnection> recordsConnection = new List<PartnerNetworkRecordConnection>();

        for(Id connection : connectionId) {
            recordsConnection.add(
                new PartnerNetworkRecordConnection(
                    ConnectionId = connection,
                    LocalRecordId = localRecordId,
                    SendClosedTasks = false,
                    SendOpenTasks = false,
                    SendEmails = sendEmail,
                    ParentRecordId = null
                )
            );
        }         

        insert recordsConnection;    
    }

    /* 
    * @description Method used to return a user permission, PermissionsManagePartnerNetConn, indicating if the logged user can forward a record to an Org connection
    * @params void
    * @return Boolean
    */

    @AuraEnabled(cacheable=true)
    public static Boolean getUserPermission() {
        Boolean userPermission;
        
        userPermission = [
            SELECT PermissionsManagePartnerNetConn
            FROM Profile
            WHERE Id IN (SELECT ProfileId FROM User WHERE Id = :UserInfo.getUserId())
        ].PermissionsManagePartnerNetConn;

        return userPermission;
    }    

    /* 
    * @description Wrapper Class to create a representative of two sObjects, PartnerNetworkConnection and PartnerNetworkRecordConnection
    */

    public class ConnectionWrapper {
        @AuraEnabled
        public String connectionStatus {get;set;}
        @AuraEnabled
        public String connectionName {get;set;}
        @AuraEnabled
        public Id connectionOwner {get;set;}
        @AuraEnabled
        public Datetime connectionDate {get;set;}
        @AuraEnabled
        public Boolean connectionActive {get;set;}
        @AuraEnabled
        public Id recordConnectionId {get;set;}
        
            public ConnectionWrapper(String connectionStatus, String connectionName, Id connectionOwner, Datetime connectionDate, Boolean connectionActive, Id recordConnectionId) {
                this.connectionStatus = connectionStatus;
                this.connectionName = connectionName;
                this.connectionOwner = connectionOwner;
                this.connectionDate = connectionDate;
                this.connectionActive = connectionActive;
                this.recordConnectionId = recordConnectionId;
            }        
    }    
}