public without sharing class LightningConnectedAppHelper {

	//Get List of connected apps
    @AuraEnabled
    public Static List <String> ConnectedAppsList () {
    	List <String> values = new List <String>();
    	//List <ConnectedApplication> conn = [SELECT Name FROM ConnectedApplication];
    	//for (integer i=0;i<conn.size();i++)
    	//	values.add(conn[i].Name);
    	List <Connected_App_Roles__c> roles = [SELECT Connected_App__c FROM Connected_App_Roles__c where Active__c = true ORDER BY Connected_App__c];
    	map <String,Integer> unique = new map <String,Integer>();
    	for (integer i=0;i<roles.size();i++) {
    		if (unique.get(roles[i].connected_app__c) == null) {
    			values.add(roles[i].connected_app__c);
    			unique.put(roles[i].connected_app__c,1);
    		}
    	}
    	return values;
    }

    @AuraEnabled
    public static List <Connected_App_Roles__c> getroles (String connectedapp) {
    	List <Connected_App_Roles__c> values = [SELECT Role__c, Description__c FROM Connected_App_Roles__c WHERE Connected_App__c = :connectedapp];
    	return values;
    }

    @AuraEnabled
    public static void submit (String connectedapp, String role) {


		String permissiontoassign;
		String connectedappprovisioning;
		List <Connected_App_Roles__c> con = [SELECT PermissionSet_Provisioning__c,Connected_App_Provisioning_Name__c FROM Connected_App_Roles__c WHERE Connected_App__c = :connectedapp AND PermissionSet_Provisioning__c != null LIMIT 1];
		if (con.size() != 0) {
			permissiontoassign = con[0].PermissionSet_Provisioning__c;
			connectedappprovisioning = con[0].Connected_App_Provisioning_Name__c;
		}


		try {
			if (!String.isBlank(permissiontoassign)) {
				String PermissionSetId = [SELECT id FROM PermissionSet WHERE label = :permissiontoassign].id;
			
				assignpermissionset(PermissionsetId,connectedappprovisioning);
			}
		}
		catch (Exception e) {
			system.debug('@@@Error: ' + e.getMessage());
		}

		//system.debug(p.id);
    }

    @AuraEnabled
    public static String getPic (String connectedapp) {
    	String pic = [SELECT App_Picture_Url__c FROM Connected_App_Roles__c WHERE Connected_App__c = :connectedapp AND App_Picture_Url__c <> '' LIMIT 1].App_Picture_Url__c;
    	return pic;
    }

    @AuraEnabled
    public static String getAppDescription (String connectedapp) {
    	String description = [SELECT Connected_App_Description__c FROM Connected_App_Roles__c WHERE Connected_App__c = :connectedapp AND Connected_App_Description__c <> '' LIMIT 1].Connected_App_Description__c;
    	return description;
    }


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
            system.debug('@@@connectedappprovisioning: ' +connectedappprovisioning);
            //ConnectedApplication ca = [SELECT id FROM ConnectedApplication WHERE Name = :connectedappprovisioning];
            //ConnectedApplication ca = [SELECT id FROM ConnectedApplication WHERE Name = 'shdjfkhsdjk'];
            //system.debug('@@@@ca: ' +ca);
            //u.connectedAppId = ca.id;
            u.connectedAppId = '0H4260000004DqXCAU';
            system.debug('@@@connectedappId: ' +u.connectedAppId);
            database.insert(u);
    		
    		
    		
    		system.debug('@@@@inserted: ' +p.id);
    	}

    	catch (Exception e) {
    		system.debug('@@@Error: ' + e.getMessage());
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

}