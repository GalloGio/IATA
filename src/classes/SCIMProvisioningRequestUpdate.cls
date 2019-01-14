@RestResource(urlMapping='/SCIMProvisioningRequestUpdate/*')
global class SCIMProvisioningRequestUpdate {
    
    @httpPost
    global static void doPost(String userName, boolean active,String appConfigKey){
       List<User> userList;
       User u;
       Portal_Application_Right__c ServiceRq;
        List<Portal_Application_Right__c> ServiceRqList;
       UserProvAccount UPA;
       string errorMsgInvalidCtx='';
       One_Id_User_Applications__c OneIdUsrAppRow;
       SCIMServProvManager IFGProvManagHandler;
       
       System.debug('basto1p - doPost username=' + userName);
       System.debug('basto1p - doPost ConnectedApp Name appKey=' + appConfigKey);
       System.debug('basto1p - doPost active=' + active);

        //UPA=[select ConnectedApp,SalesforceUser from UserProvAccount where ConnectedApp.name=:appKey and ConnectedApp.name=:userName];
        //string permissionSetNameToRemove='IFG_Provisioning_Prod';
        
        userList=[select ContactId from user where email=:userName or userName =:userName];

        System.debug('basto1p - doPost userList=' + userList);

        if (userList.size()==1){
            u=userList[0];
        }
        /*
        else if (userList.size()>1){
            SCIMServProvManager.SCIMException e = new SCIMServProvManager.SCIMException(
                    SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1,
                    'User Object: TOO MANY RECORDS found for the given user key='+userName);
            throw e;
        }
        */
        else if (userList.size()<1){
            SCIMServProvManager.SCIMException e = new SCIMServProvManager.SCIMException(
                    SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1,
                    'User Object: RECORD NOT FOUND  for the given user key='+userName);
            throw e;
        }
        
        IFGProvManagHandler=new SCIMServProvManager(appConfigKey);
        system.debug('basto1p - IFGProvManagHandler='+IFGProvManagHandler);

        ServiceRqList=
            [Select p.Name, p.Application_Name__c, p.Right__c, p.PortalServiceTranslatedName__c , p.Portal_Application__r.Description__c,
                 p.Portal_Application__r.Cannot_be_managed_by_portal_admin__c, p.Portal_Application__r.Requestable__c, p.Application_icon_del__c, 
                 p.Portal_Application__r.New_Window__c,p.Technical_Provisioning_Status__c, Portal_Application__r.SCIM_App_Name__c, 
                 p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, 
                 p.My_Apps__c, p.Contact__c,p.Contact__r.Name, p.Contact__r.AccountId, p.Application_Start_URL__c ,
                 p.Case_creation_record_Type__c,p.Access_Status_Reason__c, p.Contact__r.User_Portal_Status__c
             From Portal_Application_Right__c p 
             where p.Contact__r.Id = :u.ContactId 
             and p.Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
             and p.Portal_Application__r.SCIM_App_Name__c=:appConfigKey
            ]; 
        
        System.debug('basto1p - SCIMProvisioningRequestUpdate.doPost  ServiceRqList=' + ServiceRqList);
        
        if (ServiceRqList.size()==1){
            ServiceRq=ServiceRqList[0];

            errorMsgInvalidCtx='Calling REST Assynchronous service in a invalid context '+
                                         'current Provisioning STATUS='+ServiceRq.Technical_Provisioning_Status__c+
                                         '; Received User Active Flag='+active;
            
            System.debug('basto1p - Will conced final ACCESS GRANTED.'); 
            if (active==true){
                //test current status External REST Call with Active=false shall be only possible
                //when already granted by IATA
                if (ServiceRq.Technical_Provisioning_Status__c != SCIMServProvManager.TECH_STS_IATA_ACCESS_GRANTED)
                {
                    SCIMServProvManager.SCIMException e = new SCIMServProvManager.SCIMException(
                            SCIMServProvManager.ERR_SCIM_REST_INVALID_CONTEXT,
                            errorMsgInvalidCtx);
                    throw e;
                }
                else
                {
                    IFGProvManagHandler.setExternalAccessGranted(ServiceRq, u.Id);
                }
            }
            else
            {
                //test current status External REST Call with Active=false shall be only possible
                //when already granted by IATA
                if (ServiceRq.Technical_Provisioning_Status__c != SCIMServProvManager.TECH_STS_IATA_ACCESS_GRANTED)
                {
                    SCIMServProvManager.SCIMException e = new SCIMServProvManager.SCIMException(
                            SCIMServProvManager.ERR_SCIM_REST_INVALID_CONTEXT,
                            errorMsgInvalidCtx);
                    throw e;
                }
                else{
                    IFGProvManagHandler.setExternalAccessDenied(ServiceRq);
                }
            }
            System.debug('basto1p - end update Row in aplication right.');

        }
        else if (ServiceRqList.size()>1){
            SCIMServProvManager.SCIMException e = new SCIMServProvManager.SCIMException(
                    SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1,
                    'Portal Service Access rights TOO MANY RECORDS found for the given appKey and username/email composed key='+u.ContactId+appConfigKey+SCIMServProvManager.PROV_TYP_SCIM);
            throw e;
        }
        else if (ServiceRqList.size()<1){
            SCIMServProvManager.SCIMException e = new SCIMServProvManager.SCIMException(
                    SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1,
                    'Portal Service Access rights RECORD NOT FOUND for the given appKey and username/email composed key='+u.ContactId+appConfigKey+SCIMServProvManager.PROV_TYP_SCIM);
            throw e;
        }

    }
}