public without sharing class LightningConnectedAppHelper {

    //One_Id_User_Applications__c field Action Options
    public static final string OID_USER_APP_ACTION_ADD='Add';
    public static final string OID_USER_APP_ACTION_REMOVE='Remove';
    
    //One_Id_User_Applications__c field Status Options
    public static final string OID_USER_APP_STATUS_STARTED='Started';
    public static final string OID_USER_APP_STATUS_REQUESTED='Requested';
    public static final string OID_USER_APP_STATUS_FAILED='Failed';
    public static final string OID_USER_APP_STATUS_COMPLETED='Completed';
    public static final string OID_USER_APP_STATUS_DELETED='Deleted';

    
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
    public static String getAutomaticRole (String connectedapp) {
    	String automaticRole = '';
        
        if(connectedApp == 'FRED'){
            User usr = [select AccountId from User where Id =: UserInfo.getUserId()];
            
            list<PermissionSetAssignment> fredUsers = [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name in ('FRED_Primary_User', 'FRED_SSO') AND Assignee.AccountId =: usr.AccountId];

            set<Id> primariesIds = new set<Id>();
            set<Id> secondariesIds = new set<Id>();
            
            for(PermissionSetAssignment psa : fredUsers) {
                if(psa.PermissionSet.Name == 'FRED_Primary_User'){
	                primariesIds.add(psa.AssigneeId);
                }
                else{
	                secondariesIds.add(psa.AssigneeId);
                }
            }

			// Remove from the secondaries set, the users identified as primary users (they should have both permission sets assigned)
			secondariesIds.removeAll(primariesIds);

            if(primariesIds.isEmpty()){
                automaticRole = 'Primary User';
            }
            else{
                // Load  FRED limit and compare to account number
                List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'One_Id_Service_Provider_Config__c' AND DeveloperName = 'Service_Provider'];
    
                One_Id_Service_Provider_Config__c config;
    
                if(! recordTypes.isEmpty()){
                    config = [select Max_Number_Of_Primary_User__c, Max_Number_Of_Secondary_User__c FROM One_Id_Service_Provider_Config__c  WHERE Service_Provider_Name__c =: connectedapp AND RecordTypeId =: recordTypes[0].Id LIMIT 1];
                }
                else{
                    config = [select id, Max_Number_Of_Primary_User__c, Max_Number_Of_Secondary_User__c FROM One_Id_Service_Provider_Config__c  WHERE Service_Provider_Name__c =: connectedapp LIMIT 1];
                }
                
                if(secondariesIds.size() < config.Max_Number_Of_Secondary_User__c){
                    automaticRole = 'Secondary User';
                }
                
				// INC431553 : For verifiers, limits don't apply
	            List<RecordType> verifierRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Verifier'];
	            Account acc = [select RecordTypeId from Account where Id =: usr.AccountId];
				if(verifierRecordType[0].Id != acc.RecordTypeId){
                    automaticRole = 'Secondary User';
            }
        }
        }
        
        return automaticRole;
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

            /*if(String.isNotBlank(role)) {
                User usr = new User();
                usr.id = UserInfo.getUserId();
                usr.Portal_App_Role__c = role;
                update usr;
				
                
            }*/

            List<One_Id_App_Config_Detail__c> apps = OneIdProvisioningDAO.getAppPermissionSetListForAppicker(connectedapp);

            if(!apps.isEmpty()) {

                for(One_Id_App_Config_Detail__c app : apps){

                    permissionsetToAssignNames.add(app.PermissionSet_Provisioning__c);

                    One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
                    anUserApp.Application__c = app.id;
                    anUserApp.Identity_User__c = UserInfo.getUserId();
                    anUserApp.One_Id_App_Bundle__c = app.One_Id_Service_Provider_Config__r.Service_Bundle__r.id;
                    anUserApp.One_Id_Service_Provider_Config__c = app.One_Id_Service_Provider_Config__r.id;
                    anUserApp.Provisioning_Status__c = OID_USER_APP_STATUS_STARTED;
                    if(String.isNotBlank(role))
                    	anUserApp.Selected_Role__c = role;
                    
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
				
				String confCLabel = bundles.get(0).Description_Custom_Label__c;
				
				LabelTranslator translator = new LabelTranslator(); 
				
				String translatedString = translator.translate(confCLabel,UserInfo.getLanguage());				
				 
                description = translatedString;

            }
            else{
				String confCLabelNo = 'OneId_No_Apps_Availablr_for_You';
				
				LabelTranslator translatorNo = new LabelTranslator(); 
				
				String translatedStringNo = translatorNo.translate(confCLabelNo,UserInfo.getLanguage());				
				 
                description = translatedStringNo;            	
            	
            }

        }catch(Exception err){
            System.debug(err);
        }

    	return description;
    }
    @AuraEnabled
    public static String getAppTerms (String connectedapp) {
        String termsText = '';

        try {

            List<One_Id_Service_Provider_Config__c> bundles = OneIdProvisioningDAO.getAppTermsForAppicker(connectedapp);

            if(! bundles.isEmpty()) {

                termsText = bundles.get(0).TermConditions__c;

            }

        } catch(Exception err) {
            System.debug(err);
        }

        return termsText;
    }

    @AuraEnabled
    public static Boolean getAppRoleSelectibility (String connectedapp) {
        Boolean isRoleSelectable = true;

        try {
            List<One_Id_Service_Provider_Config__c> bundles = OneIdProvisioningDAO.getAppRoleSelectibilityForAppPicker(connectedapp);
            if(! bundles.isEmpty()) {
                isRoleSelectable = bundles.get(0).Is_Role_Selectable__c;
            }
        } catch(Exception err) {
            System.debug(err);
        }

        return isRoleSelectable;
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

    public static void resetSCIMProvisioning(Set<id> oneIdUserApps ){

        Set<String> permissionsetNamesToRemove = new Set<String>();
        Set<Id> usersList = new Set<Id>();
        Map<String, Id> mapPerm = new Map<String, Id>();

        if(oneIdUserApps.isEmpty()) return;

        List<One_Id_User_Applications__c> workToProcess = [select id,Action__c, Application__c,Application__r.Connected_App_Provisioning_Name__c, Application__r.PermissionSet_SSO__c, Application__r.PermissionSet_Provisioning__c, Identity_User__c,One_Id_App_Bundle__c,One_Id_Service_Provider_Config__c,Provisioning_Status__c
                from One_Id_User_Applications__c where id = :oneIdUserApps] ;

        for(One_Id_User_Applications__c anUap : workToProcess){
            permissionsetNamesToRemove.add(anUap.Application__r.PermissionSet_Provisioning__c);
            permissionsetNamesToRemove.add(anUap.Application__r.PermissionSet_SSO__c);
            usersList.add(anUap.Identity_User__c);
        }

        List<PermissionSet> listOfPermS = [SELECT id, name FROM PermissionSet WHERE name = :permissionsetNamesToRemove];

        for(PermissionSet ap : listOfPermS){
            mapPerm.put(ap.name, ap.id);
        }

        List<PermissionSetAssignment> toDelete = [SELECT AssigneeId,Id,PermissionSetId FROM PermissionSetAssignment where AssigneeId in :usersList and PermissionSetId in :mapPerm.values()];

        delete toDelete;

        //delete workToProcess;
        LightningConnectedAppHelper.deleteSObjects(oneIdUserApps);

        /*
        List<One_Id_User_Applications__c> workToDelete = [select id,Action__c, Application__c,Application__r.Connected_App_Provisioning_Name__c, Application__r.PermissionSet_SSO__c, Application__r.PermissionSet_Provisioning__c, Identity_User__c,One_Id_App_Bundle__c,One_Id_Service_Provider_Config__c,Provisioning_Status__c
                from One_Id_User_Applications__c where Identity_User__c = :usersList and Application__r.PermissionSet_SSO__c in :permissionsetNamesToRemove and Application__r.PermissionSet_Provisioning__c in :permissionsetNamesToRemove] ;

        if(!workToDelete.isEmpty()) delete workToDelete;
        */
    }

    @future
    public static void deleteSObjects(Set<id> oneIdUserApps){

        if(oneIdUserApps.isEmpty()) return;


        List<One_Id_User_Applications__c> listOne = new List<One_Id_User_Applications__c>();
        for(id anId : oneIdUserApps){
            One_Id_User_Applications__c anObj = new One_Id_User_Applications__c();
            anObj.id = anId;
            listOne.add(anObj);
        }

        delete listOne;
    }

}