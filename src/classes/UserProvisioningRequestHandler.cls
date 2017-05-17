/*
 * Created by Manuel Conde on 03/04/2017.
 * Edited by Fernando Gavinho on 16/05/2017
 
 * Handles One Id User Provisioning Requests
 */
public class UserProvisioningRequestHandler {

    private boolean isExecuting = false;
    private integer batchSize = 0;

    public UserProvisioningRequestHandler (boolean isExecuting, Integer size){
        System.debug('UserProvisioningRequestHandler --- Initializing UserProvisioningRequestHandler ' + size);

        this.isExecuting = isExecuting;
        this.batchSize = size;
    }


    public void OnAfterInsert(UserProvisioningRequest[] newObjects){

        System.debug('UserProvisioningRequestHandler --- Starting OnAfterInsert');

    }

    public void OnAfterUpdate(UserProvisioningRequest[] oldObjects, UserProvisioningRequest[] updatedObjects, Map<ID, UserProvisioningRequest> oldMapObjectMap, Map<ID, UserProvisioningRequest> newMapObjectMap){
        System.debug('UserProvisioningRequestHandler --- Starting OnAfterUpdate');

        List<One_Id_App_Config_Detail__c> listOfApps = OneIdProvisioningDAO.getAppPermissionSetListForSSO();

        if(listOfApps.isEmpty()) return; //no one Id apps are configured, no need to go further

        Map<String, One_Id_App_Config_Detail__c> connAppVAppConf = new Map<String, One_Id_App_Config_Detail__c>();
        Set<String> permSetSSO = new Set<String>();
        for(One_Id_App_Config_Detail__c anApp : listOfApps){
            connAppVAppConf.put(anApp.Connected_App_Provisioning_Name__c, anApp);
            permSetSSO.add(anApp.PermissionSet_SSO__c);
        }

        Map<String, EmailTemplate> listOfEmailTemp = new Map<String, EmailTemplate>();
        for (UserProvisioningRequest uprov : updatedObjects) {
            if(connAppVAppConf.containsKey(uprov.AppName)) listOfEmailTemp.put('Identity Access:'+uprov.AppName, null);
        }

        if(listOfEmailTemp.isEmpty()) return; //means that none of the UserProvisioningRequests on the trigger is related to a One Id app.

        for(EmailTemplate eTemp : [Select id,name from EmailTemplate where name in : listOfEmailTemp.keySet()]){
            listOfEmailTemp.put(eTemp.name, eTemp);
        }

        Map<String, String> permsetMap = new Map<String, String>();
        for(PermissionSet aPS : [SELECT Id, name FROM PermissionSet WHERE name IN :permSetSSO]){
            permsetMap.put(aPS.name, aPS.id);
        }

        List<One_Id_User_Applications__c> toSyncUserApps = new List<One_Id_User_Applications__c>();
        List<String> userids = new List<String>();
        List<String> permissionids = new List<String>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (UserProvisioningRequest uprov : updatedObjects) {

            if(!connAppVAppConf.containsKey(uprov.AppName)) continue; //means this is not an One Id app, no need to take action

            One_Id_App_Config_Detail__c anAppConfig = connAppVAppConf.get(uprov.AppName);

            One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
            anUserApp.Application__c = anAppConfig.id;
            anUserApp.One_Id_Service_Provider_Config__c = anAppConfig.One_Id_Service_Provider_Config__r.id;
            anUserApp.One_Id_App_Bundle__c = anAppConfig.One_Id_Service_Provider_Config__r.Service_Bundle__r.id;
            anUserApp.Identity_User__c = uprov.SalesforceUserId;
            anUserApp.Provisioning_Status__c = uprov.State;
            anUserApp.User_Provisioning_Request__c = uprov.id;
            anUserApp.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
            toSyncUserApps.add(anUserApp);

            if(uprov.State != oldMapObjectMap.get(uprov.id).State && uprov.State.equals('Completed') && uprov.Operation.equals('Create')){

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setTargetObjectId(uprov.SalesforceUserId);

                EmailTemplate emailT = listOfEmailTemp.get('Identity Access:'+uprov.AppName);

                if(emailT != null) {
                    mail.setTemplateId(emailT.id);
                }else{
                    mail.setSubject('Access to Service granted!');
                    mail.setPlainTextBody('Dear user,\r\n\r\nyour request to be granted access to ISAGO' + uprov.AppName +
                            ' has been accepted.\r\n\r\nThanks.');

                }
                mail.setSaveAsActivity(false);
                emailsToSend.add(mail);

                String whichPermSetSSO = anAppConfig.PermissionSet_SSO__c;
                system.debug('UserProvisioningRequestHandler --- Current PermissionSet SSO: ' + whichPermSetSSO);


                String permissiontoassign = permsetMap.get(whichPermSetSSO);
                system.debug('UserProvisioningRequestHandler --- @@@permissiontoassign: ' + permissiontoassign);

                userids.add(uprov.SalesforceUserId);
                permissionids.add(permissiontoassign);

            }
        }


        try {
            if (userids.size() != 0) {
                LightningConnectedAppHelper.massassignpermissionset(userids, permissionids);
                Messaging.sendEmail(emailsToSend);
            }

            if(!toSyncUserApps.isEmpty()){
                String serialized = JSON.serialize(toSyncUserApps);
                LightningConnectedAppHelper.syncUserApps(serialized);
            }
        }
        catch (Exception e) {
            system.debug('UserProvisioningRequestHandler --- Error: ' +e.getMessage());
        }
    }
}