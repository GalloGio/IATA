public without sharing class RemoteInvocationTriggerHandler {

    //Trigger variables
    public List<Remote_Invocation__c> triggerNew = (List<Remote_Invocation__c>) Trigger.new;
    public List<Remote_Invocation__c> triggerOld = (List<Remote_Invocation__c>) Trigger.old;
    public Map<Id, Remote_Invocation__c> newMap = (Map<Id,Remote_Invocation__c>) Trigger.newMap;
    public Map<Id, Remote_Invocation__c> oldMap = (Map<Id,Remote_Invocation__c>) Trigger.oldMap;

    //Remote Invocation Request Types
    public static final String NEWGEN_EASY_PAY = 'ANG_IEP_MODEL_A';
    public static final String TIP_IFG_REPORT  = 'TIP_IFG_REPORT';
    public static final String NEWGEN_GDI_ENDO  = 'GDI_ENDORSEMENT';

    //Remote Invocation Status
    public static final String REMOTE_INVOCATION_STATUS_INITIALIZING = 'Initializing';
    public static final String REMOTE_INVOCATION_STATUS_PROGRESS     = 'In Progress';

    //Remote Invocation Recordtypes
    public static final ID RECTYPE_NEWGEN = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', NEWGEN_EASY_PAY);
    public static final ID RECTYPE_TIP    = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', TIP_IFG_REPORT);
    public static final ID RECTYPE_GDI    = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', NEWGEN_GDI_ENDO);

    //to store the remote invocations with errors
    public Set<ID> remoteInvocationWithErrors;

    private Map<String,Account> mapIATACodeAccs;

    private Map<String,String> mapTypeRecordtype = new Map<String,String>{  NEWGEN_EASY_PAY => RECTYPE_NEWGEN,
                                                                            TIP_IFG_REPORT  => RECTYPE_TIP,
                                                                            NEWGEN_GDI_ENDO => RECTYPE_GDI};

    //private final List<String> typesToProcess = new List<String>{'ANG_IEPRemoteInvocation','ANG_GDIRemoteInvocation'};
     private Map<String,String> typesToProcess = new Map<String,String>{  NEWGEN_EASY_PAY => 'ANG_IEPRemoteInvocation',
                                                                            NEWGEN_GDI_ENDO => 'ANG_GDIRemoteInvocation'};

    public RemoteInvocationTriggerHandler(){
    }

    public void handleAfterInsert(){
        handlePlatformEvent();
    }

    public void handleAfterUpdate(){
        handlePlatformEvent();
        processInvocationsInProgress(NEWGEN_GDI_ENDO);
        
    }

    public void handleAfterDelete(){
        handlePlatformEvent();
    }

    public void handleAfterUndelete(){
        handlePlatformEvent();
    }

    public void handleBeforeInsert(){
        assignRecordtypeToRequest();
    }

    public void handleBeforeUpdate(){
        processInvocationsInProgress(NEWGEN_EASY_PAY);
        handleAutomaticUploadReports();
    }


    public void assignRecordtypeToRequest(){
        for(Remote_Invocation__c er : triggerNew){
            er.recordtypeid = mapTypeRecordtype.get(er.Request_Type__c);
        }
    }

    public void handlePlatformEvent(){
        for(Remote_Invocation__c re : triggerNew){

            //if oldmap doesn't contain id, trigger is insert. Note: this method only runs on after, id is allways populated 
            if((oldMap == null || ( oldMap != null && oldMap.get(re.id).Status__c != re.Status__c)) && (re.Status__c == 'Completed' || re.Status__c == 'Failed'))
                PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'RemoteInvocation__e', 'Remote_Invocation__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
        }
    }

    public void processInvocationsInProgress(string whatToProcess){
        
        Set<Remote_Invocation__c> IEPToProcess = new Set<Remote_Invocation__c>();
        Set<Remote_Invocation__c> GDIToProcess = new Set<Remote_Invocation__c>();
        
        for(Remote_Invocation__c re :  triggerNew){
            if(re.Status__c == REMOTE_INVOCATION_STATUS_PROGRESS && oldMap.get(re.Id).Status__c == REMOTE_INVOCATION_STATUS_INITIALIZING){
                if(whatToProcess==NEWGEN_GDI_ENDO && re.Request_Type__c==NEWGEN_GDI_ENDO)
                    GDIToProcess.add(re);
                
                if(whatToProcess==NEWGEN_EASY_PAY && re.Request_Type__c==NEWGEN_EASY_PAY)
                    IEPToProcess.add(re);
            }
        }
        
        if(IEPToProcess.isEmpty() && GDIToProcess.isEmpty()) return; // move along, nothing to see here ...

        // Get the Type corresponding to the class name
        Type t = Type.forName(typesToProcess.get(whatToProcess));

        ANG_RemoteInvocationINT processor = (ANG_RemoteInvocationINT)t.newInstance();

        if(whatToProcess==NEWGEN_GDI_ENDO){
            processor.doProcess(GDIToProcess);
        }

        if(whatToProcess==NEWGEN_EASY_PAY){
            processor.doSanityCheck(IEPToProcess);
            processor.doProcess(IEPToProcess);
        }
    }

    public void handleAutomaticUploadReports() {

        //
        // Get all remote invocations that were updated to In Progress by mulesoft.
        //
        List<Remote_Invocation__c> remoteInvocationInProgressList = new List<Remote_Invocation__c>();
        Set<Id> riSet = new Set<Id>();
        Set<String> airLineCodes = new Set<String>();

        for(Remote_Invocation__c ri : triggerNew) {
            //
            // ONLY TIP AUTOMATIC REPORTS
            //
            if(oldMap.get(ri.id).Status__c == TIP_Utils.REMOTE_INVOCATION_STATUS_INITIALIZING && 
                ri.Status__c == TIP_Utils.REMOTE_INVOCATION_STATUS_IN_PROGRESS && 
                ri.Request_Type__c == TIP_Utils.REQUEST_TYPE_TIP_AUTO_REPORTS
              ) {
                remoteInvocationInProgressList.add(ri);
                riSet.add(ri.Id);
                airLineCodes.add(ri.Internal_ID__c);
            }
        }


        if(remoteInvocationInProgressList.size() != 0) {

            List<Account> accounts = [Select Id, IATACode__c From Account Where IATACode__c In :airLineCodes And RecordTypeId = :AMS_Utils.RECTYPE_AIRLINE];

            Map<String, Id> airLineCodeAccountId = new Map<String, Id>();

            Set<Id> accountsSet  = new Set<Id>();
            for(Account a : accounts) {
                airLineCodeAccountId.put(a.IATACode__c, a.Id);
                accountsSet.add(a.id);           
            }

            List<ISSP_External_Report__c> existingExternalReportsList = [Select id, Account__c
                                                               From ISSP_External_Report__c
                                                              Where Account__c In :accountsSet
                                                                And Report_ID__c = :TIP_Utils.REPORT_TYPE_TIP_AUTO_REPORTS];


            Map<Id, ISSP_External_Report__c> accountExternalReportMap = new Map<Id, ISSP_External_Report__c>();

            for(ISSP_External_Report__c er : existingExternalReportsList) {
                accountExternalReportMap.put(er.Account__c, er);
            }

            List<Remote_Invocation_Artefact__c> riaList = [Select id, Remote_Invocation__c, Object_ID_Created__c, Status__c From Remote_Invocation_Artefact__c Where Remote_Invocation__c In : riSet];

            Map<Id, List<Remote_Invocation_Artefact__c>> riRiaListMap = new Map<Id, List<Remote_Invocation_Artefact__c>>();

            for(Remote_Invocation_Artefact__c ria : riaList) {

                if(riRiaListMap.get(ria.Remote_Invocation__c) == null) {
                    List<Remote_Invocation_Artefact__c> aux = new List<Remote_Invocation_Artefact__c>();
                    aux.add(ria);

                    riRiaListMap.put(ria.Remote_Invocation__c, aux);
                } else {
                    riRiaListMap.get(ria.Remote_Invocation__c).add(ria);
                }
            }

            List<RemoteInvocationExternalReportWrapper> remoteInvocationExternalReportWrapperList = new List<RemoteInvocationExternalReportWrapper>();

            String auxStatus = '';
            String auxErrorMessage = '';


            //
            // For each remoted invocation that were update to In Progress we need to create a External Report
            //
            Integer tempId = 0;
            for(Remote_Invocation__c ipRi : remoteInvocationInProgressList) {

                Id auxAccountId = airLineCodeAccountId.get(ipRi.Internal_ID__c);

                if(auxAccountId == null) {
                    auxStatus = TIP_Utils.REMOTE_INVOCATION_STATUS_FAILED;
                    auxErrorMessage = 'The account : ' + ipRi.Internal_ID__c + ' does not exist';

                    remoteInvocationExternalReportWrapperList.add(
                        new remoteInvocationExternalReportWrapper(
                            tempId,
                            ipRi,
                            null
                        )
                    );
                }

                if(auxAccountId != null) {
                    ISSP_External_Report__c auxEr = accountExternalReportMap.get(auxAccountId); 

                    if(auxEr == null) {
                        auxEr = new ISSP_External_Report__c (
                                        Account__c = auxAccountId,
                                        Report_ID__c = TIP_Utils.REPORT_TYPE_TIP_AUTO_REPORTS
                                    );
                    }

                    remoteInvocationExternalReportWrapperList.add(
                        new remoteInvocationExternalReportWrapper(
                            tempId,
                            ipRi,
                            auxEr
                        )
                    );
                }

                tempId++;

            }

            List<ISSP_External_Report__c> externalReportsToInsert = new List<ISSP_External_Report__c>();
            Map<Integer, RemoteInvocationExternalReportWrapper> tempIdWrapperMap = new Map<Integer, RemoteInvocationExternalReportWrapper>();

            for(RemoteInvocationExternalReportWrapper rierw : remoteInvocationExternalReportWrapperList) {
                if(rierw.er != null) externalReportsToInsert.add(rierw.er);
                tempIdWrapperMap.put(rierw.tempId, rierw);
            }

            //
            // We are creating an external report for each 
            //
            if(externalReportsToInsert.size() != 0 || auxStatus != '') {

                if(auxStatus == '') {
                    try {
                        upsert externalReportsToInsert;

                        //
                        // All good
                        //
                        auxStatus = TIP_Utils.REMOTE_INVOCATION_STATUS_COMPLETED;

                    } catch(DmlException de) {
                        //
                        // Error!!!
                        //
                        System.debug('ERROR : ' + de.getMessage());
                        auxStatus = TIP_Utils.REMOTE_INVOCATION_STATUS_FAILED;
                        auxErrorMessage = de.getMessage();
                    }
                }

                //
                // Update the remote_invocation with the result status
                // Update the artifacts with the correct External Report ID
                //
                List<Remote_Invocation__c> riToUpdate = new List<Remote_Invocation__c>();
                List<Remote_Invocation_Artefact__c> riaToUpdate = new List<Remote_Invocation_Artefact__c>();

                for(Integer key : tempIdWrapperMap.keySet()) {
                    RemoteInvocationExternalReportWrapper rierw = tempIdWrapperMap.get(key);
                    
                    List<Remote_Invocation_Artefact__c> riaList2 = riRiaListMap.get(rierw.ri.Id);
                    rierw.ri.Status__c = auxStatus;

                    riToUpdate.add(rierw.ri);

                    for(Remote_Invocation_Artefact__c ria : riaList2) {
                        if(rierw.er != null) ria.Object_ID_Created__c = rierw.er.Id;

                        if(auxStatus == TIP_Utils.REMOTE_INVOCATION_STATUS_FAILED) {
                            ria.Request_Result__c = TIP_Utils.REMOTE_INVOCATION_ARTEFACT_STATUS_FAILED;
                        } else if(auxStatus == TIP_Utils.REMOTE_INVOCATION_STATUS_COMPLETED) {
                            ria.Request_Result__c = TIP_Utils.REMOTE_INVOCATION_ARTEFACT_STATUS_COMPLETED;
                        }

                        ria.Status_Detail__c = auxErrorMessage;
                        riaToUpdate.add(ria);
                    }
                }

                update riaToUpdate;  
            }
        }
    }

    public class RemoteInvocationExternalReportWrapper {
        public Integer tempId {get; set;}
        public Remote_Invocation__c ri {get; set;}
        public ISSP_External_Report__c er {get; set;}

        public RemoteInvocationExternalReportWrapper(Integer tempId, Remote_Invocation__c ri, ISSP_External_Report__c er) {
            this.tempId = tempId;
            this.ri = ri;
            this.er = er;
        }
    }
}