trigger HandleProvisioningRequest on UserProvisioningRequest (after insert, after update) {

    UserProvisioningRequestHandler handler = new UserProvisioningRequestHandler(Trigger.isExecuting, Trigger.size);
    ANG_UserProvisioningRequestHandler angHandler = new ANG_UserProvisioningRequestHandler();
    FRED_UserProvisioningRequestHandler fredHandler = new FRED_UserProvisioningRequestHandler();

    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        angHandler.OnAfterUpdate();
        fredHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }


    /*
//EM: When portal users requires access to new connected app:
//When the app permission is granted (so after the approval), assign the connected app permission set (the SSO one) to the portal user

    //Query custom setting to get association: name of the provisioning app/name of the permission set SSO (to be set)
    List <Connected_App_Roles__c> conn = [SELECT Connected_App_Provisioning_Name__c, Permission_set_SSO__c from Connected_App_Roles__c WHERE Connected_App_Provisioning_Name__c != null];

    map <String,String> assoc = new map <String,String>();
    set <String> permname = new Set <String>();
    List <String> appname = new List <String>();
    
    //Map Connected app provisioning name - name permission set SSO
    
    for (integer i=0;i<conn.size();i++) {
        assoc.put(conn[i].Connected_App_Provisioning_Name__c,conn[i].Permission_set_SSO__c);
        system.debug('@@@association conn app/perm set: ' +assoc);
        
        permname.add(conn[i].Permission_set_SSO__c);
        system.debug('@@@permission sso name: ' +conn[i].permission_set_SSO__c);

    
    }
    
    map <String,String> permmap = new map <String,String>();
    system.debug('@@@permname: ' +permname);
    //Get all the SSO permission sets to be set
    List <PermissionSet> perm = [SELECT Id, Label FROM PermissionSet WHERE Label IN :permname];
    for (integer i=0;i<perm.size();i++)
        permmap.put(perm[i].Label,perm[i].id);
    system.debug('@@@permmap: '+permmap);
    
    
    
    List <UserProvisioningRequest> usnew = Trigger.new; 
        if (Trigger.isUpdate) {
            List <UserProvisioningRequest> usold = Trigger.old;
            List <PermissionSetAssignment> toinsert = new List <PermissionSetAssignment>();
            
            List <String> userids = new List <String>();
            List <String> permissionids = new List <String> ();
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            
            for (integer i=0;i<usold.size();i++) {
                
                system.debug('@@@oldStatus: ' +usold[i].State);
                system.debug('@@@newStatus: ' +usnew[i].State);
                
                if (usold[i].State != usnew[i].State && usnew[i].State == 'Completed') {
                    //PermissionSetAssignment p = new permissionsetassignment ();
                    //p.AssigneeId = usnew[i].SalesforceUserId;
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
                    mail.setTargetObjectId(usnew[i].SalesforceUserId);
                    mail.setSubject('Access to service provided');
                    //mail.setTemplateId('00X26000000ScWf');
                    mail.setSaveAsActivity(false);   
                    mail.setPlainTextBody('Dear user,\r\n\r\nyour request to be granted access to '+usnew[i].AppName+ ' has been accepted.\r\n\r\nThanks.');
                    //mail.setWhatId('0032600000L8Ful');
                    emailsToSend.add(mail);
                    
                    String whichapplication = assoc.get(usnew[i].AppName);
                    system.debug('@@@current application: ' +whichapplication);
                    
                    String permissiontoassign = permmap.get(whichapplication);
                    system.debug('@@@permissiontoassign: ' + permissiontoassign);
                                        
                    userids.add(usnew[i].SalesforceUserId);
                    permissionids.add(permissiontoassign);
                    
                    //toinsert.add(p);    
                    
                }
           
        }
        try {
            if (userids.size() != 0)
                LightningConnectedAppHelper.massassignpermissionset(userids,permissionids);
            Messaging.sendEmail(emailsToSend);
            }
            catch (Exception e) {
                system.debug('@@@@Error: ' +e.getMessage());
            }
    }

    */
}