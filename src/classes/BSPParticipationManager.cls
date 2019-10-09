Global with sharing class BSPParticipationManager {
    
    webService static Agency_Applied_Change_code__c disableBSPParticipation(String accountID) {
        //Disable BSP participation - Create Agencies Applied Change code GSD (to stop GSA participation in BSP);
        //Take bulletin text from ams_change_code__c where change_code__c='GSD'
        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c();
        aacc.Account__c = accountID;
        aacc.Change_Code__c = 'GSD';
        insert aacc;

        Id BSPLinkId   = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
        List<Agency_Authorization__c> BSPLinkAuthorizations = [SELECT Id from Agency_Authorization__c 
                                                            WHERE Account__c =: accountID and RecordTypeId =:BSPLinkId
                                                            LIMIT 1];
        if(!BSPLinkAuthorizations.isEmpty()){
            BSPLinkAuthorizations[0].Status__c = 'Non-Active';
            update BSPLinkAuthorizations;
        }
        return aacc;
    }

    webService static Agency_Applied_Change_code__c enableBSPParticipation(String accountID) {
        //Disable BSP participation - Create Agencies Applied Change code GSD (to stop GSA participation in BSP);
        //Take bulletin text from ams_change_code__c where change_code__c='GSD'
        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c();
        aacc.Account__c = accountID;
        aacc.Change_Code__c = 'GSA';
        insert aacc;
        //create BSPlink authorization record with BSPlink record type. Note:  BSPlink authorization record is unique.ApexPages
        
        Id BSPLinkId   = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
        List<Agency_Authorization__c> BSPLinkAuthorizations = [SELECT Id, Status__c from Agency_Authorization__c 
                                                            WHERE Account__c =: accountID and RecordTypeId =:BSPLinkId
                                                            LIMIT 1];
        if(!BSPLinkAuthorizations.isEmpty()){
            BSPLinkAuthorizations[0].Status__c = 'Active';
            update BSPLinkAuthorizations;
        }else{
            Account acc = [SELECT Id, Email__c FROM Account 
                            WHERE ID =: accountID];
            Agency_Authorization__c aa= new Agency_Authorization__c();
            aa.Account__c = acc.Id;
            aa.Email_Used_for_BSP_Creation__c = acc.Email__c;
            aa.Status__c = 'Active';
            Insert aa;
        }   
        return aacc;
    }

    webService static Boolean checkEnableOrDisableBSPParticipation(String accountID) {
  
        Id BSPLinkId   = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
        List<Agency_Authorization__c> BSPLinkAuthorizations = [SELECT Id from Agency_Authorization__c 
                                                                WHERE Account__c =: accountID AND RecordTypeId =:BSPLinkId AND Status__c = 'Active' ];
        if(!BSPLinkAuthorizations.isEmpty()){
            return true;
        }
        return false;
    }

    webService static Boolean checkUserPermissionsBSPParticipation(String accountID){
  
        List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name =: 'ManageGSABSPParticipation'
        ];

        if(permissions.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }
    
    @AuraEnabled
    public static Boolean checkUserPermissionsBSPParticipationAura(){
        List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name =: 'ManageGSABSPParticipation'
        ];

        if(permissions.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }
    
    @AuraEnabled
    public static Boolean checkStatusAccount(String accountID){
        Account acc = [SELECT Id, Location_Class__c, Category__c, RecordType.DeveloperName FROM Account 
                            WHERE ID =: accountID];

        if(acc.RecordType.DeveloperName != 'IATA_Agency' || acc.Location_Class__c != 'G' || acc.Category__c != 'GSA General Sales Agent') {
            return false;
        } else {
            return true;
        }
    }

    @AuraEnabled
    public static Boolean checkEnableOrDisableBSPParticipationAura(String accountID){
        Id BSPLinkId   = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
        List<Agency_Authorization__c> BSPLinkAuthorizations = [SELECT Id from Agency_Authorization__c 
                                                                WHERE Account__c =: accountID AND RecordTypeId =:BSPLinkId AND Status__c = 'Active' ];
        if(!BSPLinkAuthorizations.isEmpty()){
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static void disableBSPParticipationAura(String accountID){
        //Disable BSP participation - Create Agencies Applied Change code GSD (to stop GSA participation in BSP);
        //Take bulletin text from ams_change_code__c where change_code__c='GSD'
        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c();
        aacc.Account__c = accountID;
        aacc.Change_Code__c = 'GSD';
        insert aacc;

        Id BSPLinkId   = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
        List<Agency_Authorization__c> BSPLinkAuthorizations = [SELECT Id from Agency_Authorization__c 
                                                            WHERE Account__c =: accountID and RecordTypeId =:BSPLinkId
                                                            LIMIT 1];
        if(!BSPLinkAuthorizations.isEmpty()){
            BSPLinkAuthorizations[0].Status__c = 'Non-Active';
            update BSPLinkAuthorizations;
        }
    }

    
    @AuraEnabled
    public static void enableBSPParticipationAura(String accountID){
        //Disable BSP participation - Create Agencies Applied Change code GSD (to stop GSA participation in BSP);
        //Take bulletin text from ams_change_code__c where change_code__c='GSD'
        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c();
        aacc.Account__c = accountID;
        aacc.Change_Code__c = 'GSA';
        insert aacc;
        //create BSPlink authorization record with BSPlink record type. Note:  BSPlink authorization record is unique.ApexPages
        
        Id BSPLinkId   = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
        List<Agency_Authorization__c> BSPLinkAuthorizations = [SELECT Id, Status__c from Agency_Authorization__c 
                                                            WHERE Account__c =: accountID and RecordTypeId =:BSPLinkId
                                                            LIMIT 1];
        if(!BSPLinkAuthorizations.isEmpty()){
            BSPLinkAuthorizations[0].Status__c = 'Active';
            update BSPLinkAuthorizations;
        }else{
            Account acc = [SELECT Id, Email__c FROM Account 
                            WHERE ID =: accountID];
            Agency_Authorization__c aa= new Agency_Authorization__c();
            aa.Account__c = acc.Id;
            aa.Email_Used_for_BSP_Creation__c = acc.Email__c;
            aa.Status__c = 'Active';
            Insert aa;
        }   
    }
}