/**
 * Created by Manuel Conde on 04/04/2017.
 */
global class OneIdProvisioningDaemon implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        System.debug('Subject ' + email.subject);

        //Awake up
        processEverything();
        result.success = true;
        result.message = 'OK. Received';

        return null;
    }


    private void processEverything(){

        //1) get One_Id_User_Applications__c Started
        List<One_Id_User_Applications__c> workToProcess = [select id,Application__c,Application__r.Connected_App_Provisioning_Name__c, Application__r.PermissionSet_Provisioning__c, Identity_User__c,One_Id_App_Bundle__c,One_Id_Service_Provider_Config__c,Provisioning_Status__c
                from One_Id_User_Applications__c where Provisioning_Status__c = 'Started' limit 100] ;

        List<Id> usrList = new List<Id>();
        List<Id> permissionsetToAssign = new List<Id>();

        if(!workToProcess.isEmpty()){
            Set<String> permissionsetToAssignNames = new Set<String>();

            for(One_Id_User_Applications__c anUap : workToProcess){
                permissionsetToAssignNames.add(anUap.Application__r.PermissionSet_Provisioning__c);
            }

            Map<String, Id> mapPerm = new Map<String, Id>();

            List<PermissionSet> listOfPermS = [SELECT id, name FROM PermissionSet WHERE name = :permissionsetToAssignNames];

            for(PermissionSet ap : listOfPermS){
                mapPerm.put(ap.name, ap.id);
            }
            if(!mapPerm.isEmpty()){
                for(One_Id_User_Applications__c anUap : workToProcess){
                    if(mapPerm.containsKey(anUap.Application__r.PermissionSet_Provisioning__c)) {
                        usrList.add(anUap.Identity_User__c);
                        permissionsetToAssign.add(mapPerm.get(anUap.Application__r.PermissionSet_Provisioning__c));
                        anUap.Provisioning_Status__c = 'Requested';
                    }
                }

                if(!usrList.isEmpty()){
                    update workToProcess;
                    LightningConnectedAppHelper.massAssignPermissionSets(usrList, permissionsetToAssign);

                }
            }

        }

    }
}