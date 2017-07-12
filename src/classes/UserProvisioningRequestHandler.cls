/**
 * Created by Manuel Conde on 03/04/2017.
 */
public class UserProvisioningRequestHandler {

    private boolean isExecuting = false;
    private integer batchSize = 0;

    public UserProvisioningRequestHandler (boolean isExecuting, Integer size){
        System.debug('Initializing UserProvisioningRequestHandler ' + size);

        this.isExecuting = isExecuting;
        this.batchSize = size;
    }


    public void OnAfterInsert(UserProvisioningRequest[] newObjects){

        System.debug('Starting OnAfterInsert');

    }

    public void OnAfterUpdate(UserProvisioningRequest[] oldObjects, UserProvisioningRequest[] updatedObjects, Map<ID, UserProvisioningRequest> oldMapObjectMap, Map<ID, UserProvisioningRequest> newMapObjectMap){
        System.debug('Starting OnAfterUpdate');

        List<One_Id_App_Config_Detail__c> listOfApps = OneIdProvisioningDAO.getAppPermissionSetListForSSO();
        Map<String, String> connAppVPermSSO = new Map<String, String>();
        Map<String, One_Id_App_Config_Detail__c> connAppVAppConf = new Map<String, One_Id_App_Config_Detail__c>();
        Set<String> permSetSSO = new Set<String>();
        Map<String, String> permsetMap = new Map<String, String>();
        List<One_Id_User_Applications__c> toSyncUserApps = new List<One_Id_User_Applications__c>();
        List <String> userids = new List <String>();
        List <String> permissionids = new List <String> ();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Set<String> provApp = new Set<String>();
        Set<String> provBuiltApp = new Set<String>();
        Map<String, EmailTemplate> listOfEmailTemp = new Map<String, EmailTemplate>();
 
		//Mconde fix
		ID standartReplyUserID = PortalServiceAccessTriggerHandler.getStandartReplyUserID(ENV.Reply_Email);

        if(!listOfApps.isEmpty()){
            for(One_Id_App_Config_Detail__c anApp : listOfApps){
                connAppVPermSSO.put(anApp.Connected_App_Provisioning_Name__c, anApp.PermissionSet_SSO__c);
                connAppVAppConf.put(anApp.Connected_App_Provisioning_Name__c, anApp);
                permSetSSO.add(anApp.PermissionSet_SSO__c);
            }

            List <PermissionSet> permsetList = [SELECT Id, name FROM PermissionSet WHERE name IN :permSetSSO];
            for(PermissionSet aPS : permsetList){
                permsetMap.put(aPS.name, aPS.id);
            }

        }
        for (UserProvisioningRequest uprov : updatedObjects) {
            provApp.add(uprov.AppName);
            provBuiltApp.add('Identity Access:'+uprov.AppName);
        }
        List<EmailTemplate> templatelIST = [Select id,name from EmailTemplate where name in : provBuiltApp];
        for(EmailTemplate eTemp : templatelIST){
            listOfEmailTemp.put(eTemp.name, eTemp);
        }

        for (UserProvisioningRequest uprov : updatedObjects) {

            One_Id_App_Config_Detail__c anAppConfig = connAppVAppConf.get(uprov.AppName);
            if(anAppConfig != null) {
                One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
                anUserApp.Application__c = anAppConfig.id;
                anUserApp.One_Id_Service_Provider_Config__c = anAppConfig.One_Id_Service_Provider_Config__r.id;
                anUserApp.One_Id_App_Bundle__c = anAppConfig.One_Id_Service_Provider_Config__r.Service_Bundle__r.id;
                anUserApp.Identity_User__c = uprov.SalesforceUserId;
                anUserApp.Provisioning_Status__c = uprov.State;
                anUserApp.User_Provisioning_Request__c = uprov.id;
                anUserApp.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
                toSyncUserApps.add(anUserApp);
            }


            UserProvisioningRequest old = oldMapObjectMap.get(uprov.id);
            if(uprov.State != old.State && uprov.State.equals('Completed') && uprov.Operation.equals('Create')){

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setTargetObjectId(uprov.SalesforceUserId);

				//Mconde Fixed
				mail.setOrgWideEmailAddressId(standartReplyUserID);

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

                String whichPermSetSSO = connAppVPermSSO.get(uprov.AppName);
                system.debug('Current PermissionSet SSO: ' + whichPermSetSSO);


                String permissiontoassign = permsetMap.get(whichPermSetSSO);
                system.debug('@@@permissiontoassign: ' + permissiontoassign);

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
            system.debug('Error: ' +e.getMessage());
        }
    }
}