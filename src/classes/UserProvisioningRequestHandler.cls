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
        System.debug('basto1p - BEGIN UserProvisioningRequestHandler.OnAfterUpdate');

        List<One_Id_App_Config_Detail__c> listOfApps = OneIdProvisioningDAO.getAppPermissionSetListForSSO();
		System.debug('basto1p - UserProvisioningRequestHandler.listOfApps='+listOfApps);
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
        //basto1p
        Set<Id> userProvIds=new Set<Id> ();

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
            if (connAppVAppConf.get(uprov.AppName)!=null) {
                provApp.add(connAppVAppConf.get(
                        uprov.AppName).One_Id_Service_Provider_Config__r.Service_Provider_Name__c);//list of service providers names
            }
            provBuiltApp.add('Identity Access:'+uprov.AppName);

            userProvIds.add(uprov.SalesforceUserId);
        }
        List<EmailTemplate> templatelIST = [Select id,name from EmailTemplate where name in : provBuiltApp];
        for(EmailTemplate eTemp : templatelIST){
            listOfEmailTemp.put(eTemp.name, eTemp);
        }

		system.debug('basto1p - provApp='+provApp);

        // basto1p oneID provisioning appsIds mapp
        Map <String, One_Id_User_Applications__c> myAppsUsersMap=new Map <String, One_Id_User_Applications__c>();
        List<One_Id_User_Applications__c> appUsersList=
                [SELECT Portal_Service_Access__r.Portal_Application__r.SCIM_App_Name__c,
                        Identity_User__c,
                        Id,
                 		App_Name__c,//service provider Name
                        Portal_Service_Access__r.id,
                        Portal_Service_Access__c
                FROM One_Id_User_Applications__c
                WHERE
                    Identity_User__c IN :userProvIds
                    AND App_Name__c IN :provApp
                ];
        String appUserMappKey='';
        for(One_Id_User_Applications__c appUsersRow : appUsersList){
                appUserMappKey = appUsersRow.Identity_User__c +
                                 appUsersRow.App_Name__c;
                myAppsUsersMap.put(appUserMappKey, appUsersRow);
        }

        System.debug('connAppVAppConf ' +connAppVAppConf);
        for (UserProvisioningRequest uprov : updatedObjects) {
            System.debug('basto1p - Connected App Name - uprov.AppName=:'+uprov.AppName+'; uprov.State='+uprov.State);

            //basto1p
            One_Id_App_Config_Detail__c anAppConfig = connAppVAppConf.get(uprov.AppName);
            if(anAppConfig != null) {
                String anAppkey = anAppConfig.One_Id_Service_Provider_Config__r.Service_Provider_Name__c;//App Provider Name
                String myAppUserMappKey = uprov.SalesforceUserId + anAppkey;
                system.debug('basto1p - UserProvisioningRequestHandler.FAIL myAppUserMappKey=' + myAppUserMappKey);
                system.debug('uprov ' + uprov);

                UserProvisioningRequest old = oldMapObjectMap.get(uprov.id);
                if ((Test.isRunningTest()) || (uprov.State != old.State && uprov.State.equals('Completed') && uprov.Operation.equals('Create'))) {

                        One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
                        anUserApp.Application__c = anAppConfig.id;
                        anUserApp.One_Id_Service_Provider_Config__c = anAppConfig.One_Id_Service_Provider_Config__r.id;
                        anUserApp.One_Id_App_Bundle__c =
                                anAppConfig.One_Id_Service_Provider_Config__r.Service_Bundle__r.id;
                        anUserApp.Identity_User__c = uprov.SalesforceUserId;
                        anUserApp.Provisioning_Status__c = uprov.State;
                        anUserApp.User_Provisioning_Request__c = uprov.id;
                        anUserApp.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
                        toSyncUserApps.add(anUserApp);
                    boolean isUserActive = uprov.isactive__c;
                    if (isUserActive) {
                        EmailTemplate emailT = listOfEmailTemp.get('Identity Access:' + uprov.AppName);

                        if (emailT != null || Test.isRunningTest()) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(uprov.SalesforceUserId);
							//Mconde fixed
							mail.setOrgWideEmailAddressId(standartReplyUserID);

                            
                            mail.setSaveAsActivity(false);
                            
                            if(!Test.isRunningTest()){
                                mail.setTemplateId(emailT.id);
                            	emailsToSend.add(mail);
                            }

                        }

                        String whichPermSetSSO = connAppVPermSSO.get(uprov.AppName);
                        system.debug('Current PermissionSet SSO: ' + whichPermSetSSO);

                        //if there is a relation with Portal_Service_Access object, updates its technical status
                        //(if lookup field Portal_Service_Access__c is populated)
                        //Because received a synchronous response saying user is already active (isUserActive=true)
                        //in the external entity side
                        if (myAppsUsersMap.containsKey(myAppUserMappKey)
                                && myAppsUsersMap.get(myAppUserMappKey).Portal_Service_Access__c != null) {
                            SCIMServProvManager.setPortalAccessRightProvTechStatus(uprov.SalesforceUserId,
                                    anAppkey,
                                    SCIMServProvManager.TECH_STS_EXT_ACCESS_GRANTED);
                        }

                        String permissiontoassign = permsetMap.get(whichPermSetSSO);
                        system.debug('@@@permissiontoassign: ' + permissiontoassign);

                        userids.add(uprov.SalesforceUserId);
                        permissionids.add(permissiontoassign);
                    }
                } else if (uprov.State != old.State && uprov.State.equals('Failed') &&
                        uprov.Operation.equals('Create')) {
                    system.debug('basto1p - FAILURE IF: UserProvisioningRequestHandler UserID=' +
                            uprov.SalesforceUserId);

                    SCIMServProvManager.setPortalAccessRightProvTechStatus(uprov.SalesforceUserId,
                            anAppkey,
                            SCIMServProvManager.TECH_STS_PROV_FAIL);

                    Set<id> oneIdUserAppsForReset = new Set<id>();
                    oneIdUserAppsForReset.add(myAppsUsersMap.get(myAppUserMappKey).Id);

                    SCIMServProvManager.deleteProvRelatedPermissionSets(oneIdUserAppsForReset);
                    SCIMServProvManager.deleteOneIdProvRows(oneIdUserAppsForReset);
                }
            }
            else if ((anAppConfig==null) && !String.isBlank(uprov.AppName))
            {
                System.debug('basto1p - There is no configuration for given APP uprov.AppName='+uprov.AppName);
				/*
                SCIMServProvManager.SCIMException e = new SCIMServProvManager.SCIMException(
                        SCIMServProvManager.ERR_SCIM_APP_CONFIGURATION_MISSING,
                        'uprov.AppName='+uprov.AppName);
                throw e;
                */
            }
        }
        try {
            if (userids.size() != 0) {
                LightningConnectedAppHelper.massassignpermissionset(userids, permissionids);
                if(!emailsToSend.isEmpty())
                    Messaging.sendEmail(emailsToSend);
            }
            if(!toSyncUserApps.isEmpty()){
                String serialized = JSON.serialize(toSyncUserApps);
                LightningConnectedAppHelper.syncUserApps(serialized);

            }
        }
        catch (Exception e) {
            system.debug('basto1p - UserProvisioningRequestHandler.OnAfterUpdate Error: ' +e.getMessage());
        }
        System.debug('basto1p - END UserProvisioningRequestHandler.OnAfterUpdate');
    }
}