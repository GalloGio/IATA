public with sharing class RecordSharingController { 

    @AuraEnabled(cacheable=true) 
    
    public static List<ConnectionWrapper> getNetworkRecordConnection(Id recordId) {
        List<PartnerNetworkRecordConnection> recordConnection = new List<PartnerNetworkRecordConnection>();
        Map<Id, PartnerNetworkConnection> networkConnection = new Map<Id, PartnerNetworkConnection>();
        List<ConnectionWrapper> connectionInfo = new List<ConnectionWrapper>();
        Set<Id> connectionIds = new Set<Id>();

        recordConnection = [   
            SELECT Id, ConnectionId, StartDate, Status
            FROM PartnerNetworkRecordConnection
            WHERE LocalRecordId = :recordId
        ];

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

        return connectionInfo;
    }

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

    @AuraEnabled
    public static void stopSharingConnection(Id recordConnectionId) {
        PartnerNetworkRecordConnection con = new PartnerNetworkRecordConnection(
            Id = recordConnectionId
        );

        SavePoint sp = Database.setSavePoint();
        try {
            delete con;
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }

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

        SavePoint sp = Database.setSavePoint();
        try {
            insert recordsConnection;
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }     
    }
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