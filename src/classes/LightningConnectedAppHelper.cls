public without sharing class LightningConnectedAppHelper {

	//Get List of connected apps
    @AuraEnabled
    public Static List <String> ConnectedAppsList () {
    	List <String> values = new List <String>();

        try{
            List<One_Id_Service_Provider_Config__c> apps = OneIdProvisioningDAO.getAppListForAppicker();

            Set<String> uniqueApps = new Set<String>();

            if(! apps.isEmpty()) {
                for(One_Id_Service_Provider_Config__c anApp : apps) {
                    if(String.isNotEmpty(anApp.Service_Provider_Name__c)) {
                        uniqueApps.add(anApp.Service_Provider_Name__c);
                    }
                }
                values.addAll(uniqueApps);
            }
        }catch(Exception err){
            System.debug(err);
        }


	    return values;
    }

    @AuraEnabled
    public static List <Connected_App_Roles__c> getroles (String connectedapp) {

        List <Connected_App_Roles__c> values = new List <Connected_App_Roles__c>();

        try{
            List<One_Id_App_Role_Config__c> roles = OneIdProvisioningDAO.getAppRolesListForAppicker(connectedapp);

            if(! roles.isEmpty()) {

                for(One_Id_App_Role_Config__c role : roles) {
                    Connected_App_Roles__c aDummy = new Connected_App_Roles__c();
                    aDummy.Role__c = role.Role_Name__c;
                    aDummy.Description__c = role.Role_Description__c;
                    values.add(aDummy);
                }

            }
        }catch(Exception err){
            System.debug(err);
        }

    	return values;
    }

    @AuraEnabled
    public static void submit (String connectedapp, String role) {
        Savepoint sp = null;
        List<Id> permissionsetToAssign = new List<Id>();
        Set<String> permissionsetToAssignNames = new Set<String>();
        List<One_Id_User_Applications__c> userAppsIn = new List<One_Id_User_Applications__c>();


        //Portal_App_Role__c
        try {

            System.debug('connectedapp ' + connectedapp);
            System.debug('role ' + role);
            sp = Database.setSavepoint();

            if(String.isNotBlank(role)) {
                User usr = new User();
                usr.id = UserInfo.getUserId();
                usr.Portal_App_Role__c = role;
                update usr;
            }

            List<One_Id_App_Config_Detail__c> apps = OneIdProvisioningDAO.getAppPermissionSetListForAppicker(connectedapp);

            if(!apps.isEmpty()) {

                for(One_Id_App_Config_Detail__c app : apps){

                    permissionsetToAssignNames.add(app.PermissionSet_Provisioning__c);

                    One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
                    anUserApp.Application__c = app.id;
                    anUserApp.Identity_User__c = UserInfo.getUserId();
                    anUserApp.One_Id_App_Bundle__c = app.One_Id_Service_Provider_Config__r.Service_Bundle__r.id;
                    anUserApp.One_Id_Service_Provider_Config__c = app.One_Id_Service_Provider_Config__r.id;
                    anUserApp.Provisioning_Status__c = 'Started';
                    anUserApp.App_Key__c  = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
                    userAppsIn.add(anUserApp);
                }
            }



			if (!permissionsetToAssignNames.isEmpty()) {
                List<PermissionSet> listPerm = [SELECT id FROM PermissionSet WHERE name = :permissionsetToAssignNames];
                for(PermissionSet pSet : listPerm){
                    permissionsetToAssign.add(pSet.id);
                }

                if(!permissionsetToAssign.isEmpty()){
                   /* UPRs do not get inserted in the context of Community user */
                    /*
                    List<Id> usrList = new List<Id>();
                    usrList.add(UserInfo.getUserId());
                    LightningConnectedAppHelper.massAssignPermissionSets(usrList, permissionsetToAssign);
                    */
                    //Insert userAppsIn;
                    String serialized = JSON.serialize(userAppsIn);
                    LightningConnectedAppHelper.createUserApps(serialized);
                }
			}
		}
		catch (Exception e) {
            Database.rollback(sp);
			system.debug('@@@Error: ' + e.getMessage());
		}

		//system.debug(p.id);
    }

    @AuraEnabled
    public static String getPic (String connectedapp) {

        String pic = '';

        try{
            List<One_Id_Service_Provider_Config__c> bundles =
                    OneIdProvisioningDAO.getAppPicListForAppicker(connectedapp);

            if(! bundles.isEmpty()) {

                pic = bundles.get(0).App_Picture_Url__c;

            }
        }catch(Exception err){
            System.debug(err);
        }

        return pic;
    }

    @AuraEnabled
    public static String getAppDescription (String connectedapp) {
       	String description = '';

        try {

            List<One_Id_Service_Provider_Config__c> bundles = OneIdProvisioningDAO.getAppDescListForAppicker(connectedapp);

            if(!bundles.isEmpty()){

                description = bundles.get(0).Description__c;

            }

        }catch(Exception err){
            System.debug(err);
        }

    	return description;
    }

/*
    //@future
    public static void assignpermissionset (String permissionsetid, String connectedappprovisioning) {
    	try {
    		PermissionSetAssignment p = new permissionsetassignment ();
			p.AssigneeId = UserInfo.getUserId();
			p.PermissionSetId = permissionsetid;

			//To test Flow
			//p.permissionsetId = '0PS260000004lYz';
    		database.insert(p);
    		
		    UserProvisioningRequest u = new UserProvisioningRequest();
            u.SalesforceUserId = userinfo.getuserid();
            u.operation = 'Create';
            u.State = 'New';
            u.ApprovalStatus = 'NotRequired';
             
            //Manuel Conde
            //u.External_User_Role__c = role;
            
            system.debug('@@@connectedappprovisioning: ' +connectedappprovisioning);
            ConnectedApplication ca = [SELECT id FROM ConnectedApplication WHERE Name = :connectedappprovisioning];
            //ConnectedApplication ca = [SELECT id FROM ConnectedApplication WHERE Name = 'shdjfkhsdjk'];
            system.debug('@@@@ca: ' +ca);
            u.connectedAppId = ca.id;
            //u.connectedAppId = '0H4260000004DqXCAU';
            system.debug('@@@connectedappId: ' +u.connectedAppId);
            database.insert(u);
    		
    		
    		
    		system.debug('@@@@inserted: ' +p.id);
    	}

    	catch (Exception e) {
    		system.debug('@@@Error: ' + e.getMessage());
    	}

    }
    */

    //New: Manuel
    @future
    public static void massAssignPermissionSets (List <Id> userids, List <Id> permissionsetids) {

        List <PermissionSetAssignment> toInsert = new List <PermissionSetAssignment>();

        System.debug('userids ' + userids);
        System.debug('permissionsetids ' + permissionsetids);
        for (Id anId : userids) {

            for(Id pSet : permissionsetids) {
                PermissionSetAssignment p = new permissionsetassignment ();
                p.AssigneeId = anId;
                p.PermissionSetId = pSet;
                toinsert.add(p);
            }
        }
        try{
            database.insert(toinsert, false);
        }
        catch (Exception e) {
            system.debug(e);
        }

    }

    @future
    public static void massassignpermissionset (List <String> userids, List <String> permissionsetids) {
    	List <PermissionSetAssignment> toinsert = new List <PermissionSetAssignment>();
    	for (integer i=0;i<userids.size();i++) {
    		PermissionSetAssignment p = new permissionsetassignment ();
			p.AssigneeId = userids[i];
			p.PermissionSetId = permissionsetids[i];
    		toinsert.add(p);
    	}
    	try{
    		database.insert(toinsert);
    	}
    	catch (Exception e) {
    		system.debug('@@@Error: ' +e.getMessage());
    	}

    }

    @future
    public static void createUserApps(String jsonList){
        List<String> recipients = new List<String>();
        List<String> ccs = new List<String>();
        if(String.isNotBlank(jsonList)){

            List<One_Id_User_Applications__c> userAppsIn = (List<One_Id_User_Applications__c>)JSON.deserialize(jsonList, List<One_Id_User_Applications__c>.class);



            try {
                if(!userAppsIn.isEmpty()) {
                    insert userAppsIn;

                    //Send email to daemon
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    recipients.add(SCIM_Prov_Connector__c.getOrgDefaults().Processor_Email__c);
                    mail.setSubject('Awake up to work');
                    mail.setToAddresses(recipients);
                    ccs.add(SCIM_Prov_Connector__c.getOrgDefaults().FYI_Email__c);
                    mail.setCcAddresses(ccs);
                    mail.setPlainTextBody('Text');
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    System.debug(r);

                }


            } catch (DmlException e) {
                System.debug(e.getMessage());
            }


        }

    }

    //@future
    public static void syncUserApps(String jsonList){

        if(String.isNotBlank(jsonList)){
            System.debug('jsonList ' + jsonList);
            List<One_Id_User_Applications__c> userAppsIn = (List<One_Id_User_Applications__c>)JSON.deserialize(jsonList, List<One_Id_User_Applications__c>.class);

            try {
                Map<String, One_Id_User_Applications__c> mapOfApps = new Map<String, One_Id_User_Applications__c>();
                List<One_Id_User_Applications__c> toUpdate = new List<One_Id_User_Applications__c>();
                if(!userAppsIn.isEmpty())

                    for(One_Id_User_Applications__c anUsrApp : userAppsIn){
                        mapOfApps.put(anUsrApp.App_Key__c, anUsrApp);
                    }
                    System.debug('keySet ' + mapOfApps.keySet());
                    List<One_Id_User_Applications__c> allList = [select id, User_Provisioning_Request__c,App_Key__c from One_Id_User_Applications__c where App_Key__c in :mapOfApps.keySet()];

                    for(One_Id_User_Applications__c anApp : allList){
                        One_Id_User_Applications__c toUp = new One_Id_User_Applications__c();
                        toUp.id = anApp.id;
                        toUp.User_Provisioning_Request__c = mapOfApps.get(anApp.App_Key__c).User_Provisioning_Request__c;
                        toUpdate.add(toUp);
                    }

                    if(!toUpdate.isEmpty()) update toUpdate;

            } catch (DmlException e) {
                System.debug(e.getMessage());
            }

        }

    }

    public static String OneIdBuildUserAppKey(One_Id_User_Applications__c usrApp){
        String theKey = '';
        if(String.isNotBlank(usrApp.Identity_User__c) && String.isNotBlank(usrApp.One_Id_App_Bundle__c ) &&
                String.isNotBlank(usrApp.One_Id_Service_Provider_Config__c ) && String.isNotBlank(usrApp.Application__c)){
                theKey = usrApp.Identity_User__c + '_' + usrApp.One_Id_App_Bundle__c + '_' + usrApp.One_Id_Service_Provider_Config__c + '_' +usrApp.Application__c;

        }

        return theKey;

    }
/*
    @future(callout=true)
    public static void updatecommunitylicense (String userid, String profileid) {


    	String remoteURL = 'https://iata--platenrico.cs81.my.salesforce.com/services/apexrest/LightningUpdateLicenseType?_HttpMethod=PATCH';
        HTTPRequest httpRequest = new HTTPRequest();
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());

        httpRequest.setBody('{"userId":'+UserInfo.getUserId()+'"profileId":'+profileId+'}');
        httpRequest.setEndpoint(remoteURL);
        HTTPResponse httpResponse = new Http().send(httpRequest);
    }
*/
}