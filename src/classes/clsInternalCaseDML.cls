public with sharing class clsInternalCaseDML {
    public static boolean isTriggerAlreadyInvoked = false;

    @future
    public static void InternalCaseDMLMethod(Set<Id> CaseIds, string event){

        //Declaration
        Id RecordTypeId;
        
        String[] Recordtypes = new String[]
        {
        	'InternalCasesEuropeSCE', //'Internal Cases (IDFS ISS)'
        	'CasesMENA', //'Cases - Africa & Middle East'
        	'CasesAmericas',
        	'ExternalCasesIDFSglobal', //'Cases - Asia & Pacific'
        	'CasesEurope',
        	'Cases_China_North_Asia', //Oct-27-2011 AP
        	'FDS_Ad_hoc_Calendar_Change_R_S_Locked', // FDS Ad-hoc Calendar Change (R&S) Locked	 // Jul-27-2015 SA INC193042
        	'ComplaintIDFS', //Complaint (IDFS ISS)	
        	'ID_Card_Application' // Jan-25-2016
        };


        Set<Id> ParentId = new Set<Id>();
        List<Id> ParentUserIds = new List<Id>();
        List<String> toAddress = new List<string>();
        Map<String,Id> mapRecordType = new Map<String,Id>();

        List<Case> lstObjCase = new List<Case>();
        List<Case> lstDMLCases = new List<Case>();
        List<User> userIds = new List<User>();
        List<Contact> lstObjCon = new List<Contact>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        try{
            if(CaseIds.Size()>0){

                lstObjCase = [SELECT Id, ParentId, RecordTypeId ,Status, ContactId, CaseArea__c, Subject, Reason1__c, Parent.RecordTypeId FROM Case Where ParentId != null And Id IN: CaseIds];

                if(event == 'Insert'){
                    RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[0]);
                    for(Case ObjCase : lstObjCase){
                        if( ObjCase.RecordTypeId == RecordTypeId &&
                            ObjCase.ParentId != null &&
                            ! (ObjCase.CaseArea__c == 'Business Delivery' && objCase.Reason1__c == 'Operational Improvement' && objCase.Subject.startsWith('Root Cause Analysis'))
                        ){
                            ParentId.add(ObjCase.ParentId);
                        }
                    }

                    if(ParentId.Size()>0){
                        for(List<Case> lstCases : [SELECT Id, RecordTypeId FROM Case Where Id IN: ParentId]){
                            for(Case ObjCase : lstCases){
                                if((ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[1])) ||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[2])) ||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[3]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[4]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[5]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[6]))|| // Jul-27-2015 SA INC193042
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[7]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[8]))){ // Jan-25-2016
                                    //ObjCase.Status = 'Escalated';
                                    ObjCase.Status = 'Escalated Internally'; //Oct-27-2011 AP

                                }
                              
                                lstDMLCases.add(ObjCase);
                            }
                        }
                    }
                    FutureProcessorControl.inFutureContext = true;
                    if(lstDMLCases.Size() > 0) {Database.SaveResult[] lsr = Database.update(lstDMLCases);}
                }
                else if(event == 'Update'){

                    RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[0]);
                    System.debug('--------------************ clsInternalCaseDML Recordtypes[0] - RecordTypeId ' + Recordtypes[0] + ' - ' + RecordTypeId);
                    for(Case ObjCase : lstObjCase){
                        System.debug('--------------************ RecordTypeId - Status - ParentI - ContactId ' + ObjCase.RecordTypeId + ' - ' + ObjCase.Status + ' - ' + ObjCase.ParentId + ' - ' + ObjCase.ContactId);
                        if (ObjCase.Parent.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[8])) {
                            if(ObjCase.RecordTypeId == RecordTypeId && ObjCase.Status == 'Closed' && ObjCase.ParentId != null ){
                                ParentId.add(ObjCase.ParentId);
                            }
                        } else {
                            if(ObjCase.RecordTypeId == RecordTypeId && ObjCase.Status == 'Closed' && ObjCase.ParentId != null && ObjCase.ContactId != null ){
                                ParentId.add(ObjCase.ParentId);
                            }
                        }
                    }
                    System.debug('--------------************ clsInternalCaseDML Parent Size ' + ParentId.Size());
                    if(ParentId.Size()>0){
                        for(List<Case> lstCases : [SELECT Id, Status, RecordTypeId, OwnerId, ContactId, CaseNumber FROM Case Where Status != 'Closed' And Id IN: ParentId]){
                            for(Case ObjCase : lstCases){
                                System.Debug('Parent Cse : ------ ' + ObjCase);
                                ParentUserIds.add(ObjCase.OwnerId);  //(ObjCase.Status != 'Closed') &&
                                if((ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[1])) ||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[2])) ||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[3]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[4]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[5]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[6]))|| // Jul-27-2015 SA INC193042
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[7]))||
                                (ObjCase.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Case', Recordtypes[8]))){

                                    ObjCase.Status = 'Action Needed'; //Oct-27-2011 AP
                                    //ObjCase.Status = 'In progress';
                                } //(ObjCase.Status != 'Closed') &&

                                lstDMLCases.add(ObjCase);
                            }
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
                      for(Database.SaveResult sr:lsr){

                            if(sr.isSuccess()){
                            	
                                Database.SaveResult[] lsr1 = Database.insert(lstObjCon);
                                System.debug('--------------************ isTriggerAlreadyInvoked ' + isTriggerAlreadyInvoked);

                                EmailTemplate template = [Select Id, Subject from EmailTemplate where DeveloperName = :'Internal_Cases_Notification_on_closure_of_Internal_Case']; //Oct-27-2011 AP
                                System.debug('--------------************ toAddress ' + toAddress);
                                for(Integer i=0; i<lstDMLCases.Size();i++){
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                  //  mail.setTargetObjectId(lstObjCon[i].Id);
                                    mail.setTargetObjectId(lstUser[i].Id);
                                   // mail.setToAddresses(toAddress); //Oct-27-2011 AP
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