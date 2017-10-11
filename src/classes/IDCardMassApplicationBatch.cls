/**
This class is a batch which is run when a Mass application is Paid or accepted-
It will automatically process all card in Mass update. 
Card are processed  one per one. So batch can be called several time util there n'o card to process.
each batch will lock 5 single apps to process.


*/
global class IDCardMassApplicationBatch implements Schedulable {
     
  
   private ID_Card_Application__c massApplication;
   
   private String batchName ;
   
   private String jobId ;
   
   public string SessionId = null;
   
   /**
   Consructior
   take the mass update job and th ename to run it
   */
   public IDCardMassApplicationBatch(ID_Card_Application__c massApplication, String name){ 
        this.massApplication = massApplication; 
        this.sessionId = Userinfo.getSessionId();
        this.batchName = name;
        List<ID_Card_Application__c> singlesApps = [select Id, Name, Application_Status__c ,Single_Application_Processing_Step__c from ID_Card_Application__c  where (Single_Application_Processing_Step__c = null or  Single_Application_Processing_Step__c = :IDcardUtil.single_application_status_waiting ) and Mass_order_Application__c = :massApplication.id ];
        for(ID_Card_Application__c app:singlesApps)
            app.Single_Application_Processing_Step__c = 'In Queue for processing';
        update singlesApps;
        system.debug('[IDCardMassApplicationBatch] Start batch job for App '+batchName);
        DevsTools.sendSFDevsAlertMessage('[IDCardMassApplicationBatch] Start batch job for App '+batchName,'' );
        /* Create case for Mass Application*/
        
   }
   
   public String getName(){
        return batchName;
   }
   
   /**
   USE THIS UFNCTION TO BE SURE SYSTGEM WILL BE ABLE TO RESTART JOB
   
   --> necessary to run batch over 10 cards,
   
   */ 
   @future (callout=true)
   public static void startJob(Id massApplicationId, String batchName,String sessionId ){
        string IdCardApplicationQuery = 'SELECT '+ TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap())+
                                                   '  FROM ID_Card_Application__c  '+ 
                                                   '  WHERE Id =  \''+massApplicationId+'\''; 
       
        List<ID_Card_Application__c>tmpL = (list<ID_Card_Application__c>)(database.query(IdCardApplicationQuery));
        ID_Card_Application__c   massApplication = tmpL[0];
        if(massApplication.Application_Status__c.toLowerCase().equals('pending')){
            massApplication.Application_Status__c = 'Processing';
            update massApplication;
        }
        IDCardMassApplicationBatch app = new IDCardMassApplicationBatch(massApplication,batchName);
 
        app.sessionId = sessionId;
        String s = getCRON_EXP();
        try{
            String SchJobId = system.schedule(batchName, s , app);
            system.debug('[IDCardMassApplicationBatch] initiate SchJobId '+SchJobId);
            DevsTools.sendSFDevsAlertMessage('[IDCardMassApplicationBatch] initiate SchJobId '+SchJobId, 'With param '+s);
        }catch(AsyncException e){
            //This catch is doing nothing because if the job is already scheduled there is no need to perform other actions
            system.debug(LoggingLevel.ERROR,'[IDCardMassApplicationBatch] ERROR: '+e);
        }
        
   }
    
   global void execute(SchedulableContext sc) {
        DevsTools.sendSFDevsAlertMessage('[IDCardMassApplicationBatch] Run batch job for App '+batchName,'' );
        /*
        String SCHEDULE_NAME = 'test'; 
        id cronid = System.schedule(SCHEDULE_NAME, '0 15 0-23 * * ?', new scheduledMaintenance()); 
        System.abortJob(cronid);
        */
        List<ID_Card_Application__c> singlesApps = [select Id, Name, Application_Status__c ,Single_Application_Processing_Step__c from ID_Card_Application__c  where Single_Application_Processing_Step__c = 'In Queue for processing' and Mass_order_Application__c = :massApplication.id limit 1];
        if(singlesApps.size() ==0){
            //kill current process
            try{
                DevsTools.sendSFDevsAlertMessage('[IDCardMassApplicationBatch] End of job for App '+batchName,'' );
                
                //update mass application: if previous status = Pending: go to Unpaid. 
                try{
                    if(this.massApplication.Application_Status__c.toLowerCase().equals('processing')){
                        massApplication.Application_Status__c = 'Unpaid';
                    }
                    //Else go to Completed.
                    else if(this.massApplication.Application_Status__c.toLowerCase().equals('paid')) {
                        massApplication.Application_Status__c = 'Completed';
                        IDCardMassApplicationBatch.triggerPaidMassApplication(massApplication.Id);
                        
                        List<Case> cases = [SELECT Id FROM Case WHERE Related_ID_Card_Application__c = :massApplication.id];
                        if(cases.size()>0)
                            cases[0].Status = 'Ready for production';
                        update cases[0];
                        
                    } 
                    update massApplication;
                }
                catch(FinalException fe){
                    system.debug('[IDCardMassApplicationBatch] massApplicaiton '+massApplication.Id+' is locked ');
                }
                try{
                    System.abortJob( SC.getTriggerId() );
                    system.debug('[IDCardMassApplicationBatch] definitively kill job  '+SC.getTriggerId());
                    DevsTools.sendSFDevsAlertMessage('[IDCardMassApplicationBatch]kill a job  '+SC.getTriggerId(), 'OK ');
                    
                }catch(exception e){
                    system.debug('[IDCardMassApplicationBatch] Failed to stop anjob with Id '+SC.getTriggerId());
                    DevsTools.sendSFDevsAlertMessage('[IDCardMassApplicationBatch] Failed to stop anjob with Id '+SC.getTriggerId(), 'Cause: '+e.getMessage());

                }
            }catch(Exception e){ 
                system.debug('[IDCardMassApplicationBatch] Failed to stop an Id card mass batch '+batchName);
                DevsTools.sendSFDevsAlertMessage('[IDCardMassApplicationBatch] Failed to stop an Id card mass batch '+batchName, 'Cause: '+e.getStackTraceString());
            }
        }else {
            system.debug('[IDCardMassApplicationBatch] start  job  '+SC.getTriggerId());
            for(ID_Card_Application__c app:singlesApps){
                String[] r =IDCardWebService.processKeyAccountSingleApplication(app.Id, null, this.sessionId);
                
            }
            System.abortJob( SC.getTriggerId() );
            startJob(massApplication.id,batchName, this.sessionId );
        }
   }
   
   
   /**
   Get an exp to launch a job onnext m inute
   */
   public static String  getCRON_EXP(){
        Integer sec = Datetime.now().second();
        Integer min = Datetime.now().minute();
        if(sec>45){
            sec = 8;
            min =  Datetime.now().addMinutes(1).minute();
            
        }else  {
            sec = sec + 10;
        } 
        String s = sec+ ' '+min+' * * * ?';
        system.debug('[IDCardMassApplicationBatch] cron will be launch with param '+s);
        return s;
    }
    
    @future(callout=true)
    public static void triggerPaidMassApplication(String appId){
        ID_Card_Application__c massApp = [select  Application_Status__c, Payment_Credit_Card_Number__c, Payment_Type__c, Payment_Date__c,Payment_Currency__c, Payment_Transaction_Number__c FROM ID_Card_Application__c where   Id = :appId ];
        List<ID_Card_Application__c> singlesApps = [select   Payment_Credit_Card_Number__c, Payment_Date__c, Payment_Type__c, Payment_Currency__c, Payment_Transaction_Number__c FROM ID_Card_Application__c where   Mass_order_Application__c = :appId ];
        for(ID_Card_Application__c app:singlesApps) {
                app.Payment_Credit_Card_Number__c = massApp.Payment_Credit_Card_Number__c;
                app.Payment_Type__c = massApp.Payment_Type__c;
                app.Payment_Currency__c = massApp.Payment_Currency__c;
                app.Payment_Transaction_Number__c = massApp.Payment_Transaction_Number__c;
                app.Payment_Date__c = massApp.Payment_Date__c;
                app.Application_Status__c = 'Paid';
        }                   
        update singlesApps;
    }

}