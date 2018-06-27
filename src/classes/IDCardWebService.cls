global with sharing class IDCardWebService {
     
    @RemoteAction
    public static final String WS_SUCCESS ='Success';
    @RemoteAction
    public static final String WS_FAILURE ='Failure';

    @RemoteAction
    webService static boolean SessionIsValid() {
        
        return true;
    }
    
    
    private static Map<String,String> idcardAppRT = null;
    
    /**
    This method will process and ID card applicsation :
    requirement
        - must be a single application
        - must be pending
    Will be performed:
        case creation^
        case acceptance
        case validation
        case Id card creation
    
    
    */
    @remoteAction
    webservice static String[] processKeyAccountSingleApplication(String id, String accountId,String sessionId){
        String[] result =new String[]{IDCardWebService.WS_FAILURE, ''};
        ID_Card_Application__c singleApp  = null;
        system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] Start processing Single application:  '+id+ ' and session id to use ='+sessionId);   
        try {
            string IdCardApplicationQuery = 'SELECT '+ TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap())+
                                                   '  FROM ID_Card_Application__c  '+ 
                                                   '  WHERE Id = \''+id+'\' and recordTypeId = \''+RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation')+'\''+
                                                   '  and Single_Application_Processing_Step__c = \'In Queue for processing\' '; 
            list<ID_Card_Application__c> pendingApplications = (list<ID_Card_Application__c>)(database.query(IdCardApplicationQuery));
            if(pendingApplications.size()==1){
                singleApp = pendingApplications.get(0);
                string accQuery = 'SELECT '+ TransformationHelper.getAllFields(Schema.SObjectType.Account.fields.getMap())+
                                                   '  FROM Account where IATACode__c =\''+singleApp.IATA_code__c+'\' limit 1'; 
                list<Account> accList = (list<Account>)(database.query(accQuery));        
                Account account = accList.get(0);
                
                    
                singleApp.Single_Application_Processing_Step__c = 'Locked';
        
                //specific to TMP (0 new contacts) created: need to reset the VerNum and UIR from TMP to final
                system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] the ver is '+singleApp.VER_Number__c);
                if(singleApp.VER_Number__c.startswith('Z')){
                    //IDCardUtil.generateAndAssignVERandUIR(singleApp, account);
                    List<Contact> cs = [select Id, VER_Number_2__c, UIR__c from Contact where VER_Number_2__c  = :singleApp.VER_Number__c limit 1];
                    Contact c = cs.size()==1 ? cs[0] : IDCardApplicationFactory.createContactFromApplication(singleapp,account);
                    
                    c.VER_Number_2__c = IdcardUtil.generateVER(account);
                    c.UIR__c = IdcardUtil.generateUIR(account);
                    //update c;
                    upsert c;
                    system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] upserted the contact:'+c.id+' with ver = '+c.VER_Number_2__c);
                    singleApp.VER_Number__c = c.VER_Number_2__c ;
                    singleApp.UIR__c = c.UIR__c ;
                    String picName = singleApp.Photo__c;
                    update singleApp;
                    //rename the picture
                    system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] call web service to rename picture with new name:');
                    IdCardUtil.renameIDCardPhotoOfContact(singleApp.Id,'',sessionid);   
                    
                }
                else{
                    Contact c = [select Id, VER_Number_2__c, UIR__c from Contact where VER_Number_2__c  = :singleApp.VER_Number__c limit 1];
                    singleApp.UIR__c = c.UIR__c ;
                    update singleApp;
                }
                    
                system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] Lock single App  '+id);  
                //Account account = [select Id, name,ShippingState, Type, ID_Card_KeyAccount_features__c,IATACode__c,BillingCountry from Account where IATACode__c =:singleApp.IATA_code__c limit 1];
                
                
                
                if(accountId !=null && accountId !=account.Id){
                    system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] ERROR : wrong accountID  '+accountId+'  != '+account.id+'  for app '+id);
                    singleApp.Single_Application_Processing_Step__c = IDCardUtil.single_application_status_waiting;
                    update singleApp; 
                    result[1] = 'single pending application account doesn t match with provided account ID';
                    return result;
                }
                system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] Accouint found  for app '+id);

                //create case
                system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] create case for App  '+id);
                Case aCase = IDCardUtil.createKeyAccountIdCardApplicationCase(singleApp,account);
                if(aCase.CaseNumber==null)
                    aCase = [select Id, CaseNumber, status from case where Id = :aCase.Id];
                
                //approved case and launch id card creation
                system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] approve case for App  '+id);
                IDCardUtil.UpdateCaseToApproved_Rejected(aCase.CaseNumber,true);
                 System.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication]  The case '+acase.id+' here  has status' +aCase.status );
                
                singleApp.Single_Application_Processing_Step__c = 'Processed';
                update singleApp;
                system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] unLock single App  '+id);
                
                /* INC157243
                aCase.Status = 'Closed';    
                //aCase.ID_Card_Status__c = IDCardUtil.CASECARDSTATUS_APPROVED;
                update acase;
                */
                
                result[0] = IDCardWebService.WS_SUCCESS;
                DevsTools.sendSFDevsAlertMessage('Successfull processing of ID card :'+id, 'Cause : \n ');
                System.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication]  The case has status' +aCase.status );
            }
            else  {
                result[1] = 'No single pending application matching with provided ID';
                return result;
            }
        }catch(Exception e){
        	system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] Failed to process a Single Id card application with Id  :'+id+ ' Cause : \n '+e.getMessage()+'\n'+e.getStackTraceString());    
            DevsTools.sendSFDevsAlertMessage('Failed to process a Single Id card application with Id  :'+id, 'Cause : \n '+e.getStackTraceString());
            if( singleApp !=null){
                singleApp.Single_Application_Processing_Step__c = IDCardUtil.single_application_status_waiting;
                update singleApp;
                system.debug(LoggingLevel.ERROR,'[processKeyAccountSingleApplication] unLock AFTER ERROR single App  '+id);    
            }
            result[1] = e.getMessage();
        }
        
        return result;
    }
    
}