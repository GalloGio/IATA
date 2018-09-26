public with sharing class clsInternalCaseDML {
    public static boolean isTriggerAlreadyInvoked = false;

    @future
    public static void InternalCaseDMLMethod(Set<Id> CaseIds, string event){

        //Declaration
        Id rtID;

        String[] Recordtypes = new String[] 
        {
            'InternalCasesEuropeSCE', //'Internal Cases (IDFS ISS)'
            'CasesMENA', //'Cases - Africa & Middle East'
            'CasesAmericas',
            'ExternalCasesIDFSglobal', //'Cases - Asia & Pacific'
            'CasesEurope',
            'Cases_China_North_Asia', //Oct-27-2011 AP
            'FDS_Ad_hoc_Calendar_Change_R_S_Locked', // FDS Ad-hoc Calendar Change (R&S) Locked  // Jul-27-2015 SA INC193042
            'ComplaintIDFS', //Complaint (IDFS ISS) 
            'ID_Card_Application' // Jan-25-2016
        };
        
        Set<Id> ParentId = new Set<Id>();
        List<Id> ParentUserIds = new List<Id>();

        List<Case> lstObjCase = new List<Case>();
        List<Case> lstDMLCases = new List<Case>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        try{
            if(CaseIds.Size()>0){
                rtID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[0]);
                lstObjCase = [SELECT Id, ParentId, RecordTypeId ,Status, ContactId, CaseArea__c, Subject, Reason1__c, Parent.RecordTypeId
                              FROM Case WHERE ParentId != null AND Id IN: CaseIds];
//Event type Insert
                if(event == 'Insert'){
                    for(Case ObjCase : lstObjCase){
                        if(!(ObjCase.CaseArea__c == 'Business Delivery' 
                            && objCase.Reason1__c == 'Operational Improvement' 
                            && objCase.Subject.startsWith('Root Cause Analysis')) ){

                            ParentId.add(ObjCase.ParentId);
                        }
                    }

                    if(ParentId.Size()>0){
                        Set<ID> rtSet = new Set<ID>();
                        for(Integer i = 1; i <= Recordtypes.size(); i++){
                            rtSet.add(RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[i]));
                        }
                        for(Case ObjCase : [SELECT Id, RecordTypeId FROM Case WHERE Id IN: ParentId AND RecordTypeId IN :rtSet]){        
                            ObjCase.Status = 'Escalated Internally';
                            lstDMLCases.add(ObjCase);
                        }
                    }
                    FutureProcessorControl.inFutureContext = true;
                    if(lstDMLCases.Size() > 0) {Database.SaveResult[] lsr = Database.update(lstDMLCases);}
                }
//Event type Update
                else if(event == 'Update'){

                    for(Case ObjCase : lstObjCase){
                        if (ObjCase.Parent.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[8])){ 
                            ParentId.add(ObjCase.ParentId);
                        }else {
                            if(ObjCase.ContactId != null)
                                ParentId.add(ObjCase.ParentId);
                        }
                    }
                    System.debug('--------------************ clsInternalCaseDML Parent Size ' + ParentId.Size());
                    if(ParentId.Size()>0){
                        Set<ID> rtSet = new Set<ID>();
                        for(Integer i = 1; i <= Recordtypes.size(); i++)
                            rtSet.add(RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[i]));

                        for(Case ObjCase : [SELECT Id, Status, RecordTypeId, OwnerId, ContactId, CaseNumber FROM Case 
                                            WHERE Status != 'Closed' AND Id IN: ParentId AND RecordTypeId IN :rtSet]){
                            ParentUserIds.add(ObjCase.OwnerId); 
                            ObjCase.Status = 'Action Needed';
                            lstDMLCases.add(ObjCase);
                        }
                    }
                    FutureProcessorControl.inFutureContext = true;
                    if(emails.Size()>0){
                        emails.Clear();
                    }
                    System.debug('--------------************ clsInternalCaseDML lstDMLCases Size ' + lstDMLCases.Size());
                    if(lstDMLCases.Size() > 0) {
                        Database.SaveResult[] lsr = Database.update(lstDMLCases);
                        List<User> lstUser = [Select Id, Name, Email FROM User Where Id IN: ParentUserIds and IsActive = True];
                        EmailTemplate template = [Select Id, Subject from EmailTemplate where DeveloperName = :'Internal_Cases_Notification_on_closure_of_Internal_Case'];
                        for(Database.SaveResult sr:lsr){

                            if(sr.isSuccess()){
                            	
                                System.debug('--------------************ isTriggerAlreadyInvoked ' + isTriggerAlreadyInvoked);
                                for(Integer i=0; i<lstDMLCases.Size();i++){
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    mail.setTargetObjectId(lstUser[i].Id);
                                    mail.setTemplateId(template.Id);
                                    mail.setSaveAsActivity(false);
                                    mail.setBccSender(false);
                                    mail.setUseSignature(false);
                                    mail.setWhatId(lstDMLCases[i].Id);

                                    emails.add(mail);
                                }
                                if(emails.size () > 0){
                                    Messaging.SendEmailResult[] result = Messaging.sendEmail(emails);
                                    if (result[0].isSuccess()) {
                                        System.Debug('The email was sent successfully.');
                                    } else {
                                        System.Debug('The email failed to send: ' + result[0].getErrors());
                                    }
                                }
                                System.debug('--------------************ Setting isTriggerAlreadyInvoked To True');
                            }
                        }
                    }
                }
            }
        }
        catch(System.NullPointerException e){
            System.Debug('Exception : Null Pointer Exception');
        }
        catch(System.Exception e){
            System.Debug('Exception : ---- ' + e.getMessage());
        }
        finally{}
    }
}