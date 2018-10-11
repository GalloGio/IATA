public with sharing class clsInternalCaseDML {
    public static boolean isTriggerAlreadyInvoked = false;

    @future
    public static void InternalCaseDMLMethod(Set<Id> CaseIds, string event){

        if(CaseIds.isEmpty()) return; 

        else{
            //Declaration
            Id[] recordTypes = new Id[] 
            { 
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesMENA'), //'Cases - Africa & Middle East'
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesAmericas'),
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ExternalCasesIDFSglobal'), //'Cases - Asia & Pacific'
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope'),
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_China_North_Asia'), //Oct-27-2011 AP
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_Ad_hoc_Calendar_Change_R_S_Locked'), // FDS Ad-hoc Calendar Change (R&S) Locked  // Jul-27-2015 SA INC193042
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ComplaintIDFS'), //Complaint (IDFS ISS) 
                RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application') // Jan-25-2016
            };

            Set<Id> parentIds = new Set<Id>();

            List<Case> lstObjCase = new List<Case>();
            Map<Id, Case> cases = new Map<Id, Case>();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Id rt = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE'); //'Internal Cases (IDFS ISS)'

            try{
                
                lstObjCase = [SELECT Id, ParentId, RecordTypeId ,Status, ContactId, CaseArea__c, Subject, Reason1__c, Parent.RecordTypeId
                              FROM Case WHERE ParentId != null AND Id IN: CaseIds];
                //Event type Insert
                if(event == 'Insert'){

                    for(Case objCase : lstObjCase){
                        if( objCase.RecordTypeId == rt && 
                            !(objCase.CaseArea__c == 'Business Delivery' && objCase.Reason1__c == 'Operational Improvement' 
                                && objCase.Subject.startsWith('Root Cause Analysis')) 
                        ){
                            parentIds.add(ObjCase.ParentId);
                        }
                    }

                    if(parentIds.Size()>0){
                        for(Case ObjCase : [SELECT Id, RecordTypeId FROM Case WHERE Id IN: parentIds AND RecordTypeId IN :recordTypes]){        
                            ObjCase.Status = 'Escalated Internally';
                            cases.put(ObjCase.Id, ObjCase);
                        }
                    }
                    FutureProcessorControl.inFutureContext = true;
                    if(cases.Size() > 0) {Database.SaveResult[] lsr = Database.update(cases.values());}
                }

                //Event type Update
                else if(event == 'Update'){
                    List<Id> parentUserIds = new List<Id>();
                    for(Case ObjCase : lstObjCase){
                        if(ObjCase.RecordTypeId == rt && ObjCase.Status == 'Closed'){
                            if (ObjCase.Parent.RecordTypeId == recordTypes[7]){ 
                                parentIds.add(ObjCase.ParentId);
                            }else {
                                if(ObjCase.ContactId != null ){ parentIds.add(ObjCase.ParentId); }
                            }
                        }
                    }

                    System.debug('--------------************ clsInternalCaseDML Parent Size ' + parentIds.Size());
                    if(parentIds.Size()>0){
                        for(Case ObjCase : [SELECT Id, Status, RecordTypeId, OwnerId, ContactId, CaseNumber FROM Case 
                                            WHERE Status != 'Closed' AND Id IN: parentIds AND RecordTypeId IN :recordTypes]){
                            parentUserIds.add(ObjCase.OwnerId); 
                            ObjCase.Status = 'Action Needed';
                            cases.put(ObjCase.Id, ObjCase);
                        }
                    }
                    FutureProcessorControl.inFutureContext = true;
                    if(emails.Size()>0){
                        emails.Clear();
                    }
                    System.debug('--------------************ clsInternalCaseDML cases Size ' + cases.Size());
                    if(cases.Size() > 0) {
                        Database.SaveResult[] lsr = Database.update(cases.values());
                        Map<Id, User> owners = new Map<Id, User>([Select Id, Name, Email FROM User Where Id IN: parentUserIds and IsActive = True]);
                        EmailTemplate template = [Select Id, Subject from EmailTemplate where DeveloperName = :'Internal_Cases_Notification_on_closure_of_Internal_Case'];
                        
                        for(Database.SaveResult sr:lsr){

                            if(sr.isSuccess()){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setTargetObjectId(owners.get(sr.getId()).Id);
                                mail.setTemplateId(template.Id);
                                mail.setSaveAsActivity(false);
                                mail.setBccSender(false);
                                mail.setUseSignature(false);
                                mail.setWhatId(sr.getId());

                                emails.add(mail);
                            }
                        }
                        if(emails.size () > 0){
                            Messaging.SendEmailResult[] result = Messaging.sendEmail(emails);
                            if (result[0].isSuccess()) {
                                System.Debug('The email was sent successfully.');
                            } else {
                                System.Debug('The email failed to send: ' + result[0].getErrors());
                            }
                        }
                    }
                }
            }catch(System.NullPointerException e){
                System.Debug('Exception : Null Pointer Exception');
            }catch(System.Exception e){
                System.Debug('Exception : ---- ' + e.getMessage());
            }
        }
    }
}