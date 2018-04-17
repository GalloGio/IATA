global without sharing class LVA_CallGeneratePDFAttach {
    
	@Future(callout=true)
    public static void addPDFAttach(List<Id> liveChatIds, Set<Id> caseIds){
        List<Attachment> attachments = new List<Attachment>();
        try{
            for(LiveChatTranscript lct : [select Id, body, CaseId, Case.Subject, Case.OwnerId from LiveChatTranscript where Id in :liveChatIds and caseId != null]){
                System.debug('addPDFAttach lct ' + lct);
                PageReference transcriptPage = Page.LVA_TranscriptPdfPage;
                transcriptPage.getParameters().put('id', lct.id);
                
                Blob reportPdf;
                try {
                    reportPdf = transcriptPage.getContentAsPDF();
                }catch (Exception e) {
                    reportPdf = Blob.valueOf(e.getMessage());
                    System.debug('call');
                }
                
                //attachments.add(attachPDF(lct.Id, Blob.toPDF(lct.body), lct.caseId, lct.Case.Subject));
                attachments.add(attachPDF(reportPdf, lct.caseId, lct.Case.Subject));
                
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
        if(attachments.size()>0){
            insert attachments;
            makeAllPublic(caseIds);
        }
    }
    
    public static Attachment attachPDF(Blob reportPdf, Id caseId, String Subject){
        Attachment attachmentPdf = new Attachment();
        try{
            
            System.debug('Generating pdf');
            
            attachmentPdf.name = Subject + ' - transcript.pdf';
            attachmentPdf.body = reportPdf;
            attachmentPdf.contentType = 'application/pdf';
            attachmentPDF.parentId = caseId;
            attachmentPDF.IsPrivate = false;
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return attachmentPdf;
    }
    
    public static void makeAllPublic (Set<Id> caseIds){
        
        List <Attachment> attachList = [SELECT Id FROM Attachment WHERE ParentId in :caseIds];
        if (!attachList.isEmpty()){
            Set <Id> attachIds = new Set <Id>();
            Map <Id, Id> attachIdMap = new Map <Id, Id>();
            for (Attachment thisAttach : attachList){
                attachIds.add(thisAttach.Id);
                attachIdMap.put(thisAttach.Id, thisAttach.Id);
            }
            if (!attachIds.isEmpty()){
                List <ISSPAttachmentPermission__c> listPerm = [SELECT Id, ShowToPortalUsers__c,
                                                               AttachmentId__c
                                                               FROM ISSPAttachmentPermission__c
                                                               WHERE AttachmentId__c IN :attachIds];
                if (!listPerm.isEmpty()){
                    for (ISSPAttachmentPermission__c thisPerm : listPerm){
                        attachIdMap.remove(thisPerm.AttachmentId__c);
                        if (!thisPerm.ShowToPortalUsers__c){
                            thisPerm.ShowToPortalUsers__c = true;
                        }
                    }
                    system.debug('update: ' + listPerm.size());
                    update listPerm;
                }
                List <Id> attachIdsToCreate = attachIdMap.values();
                List <ISSPAttachmentPermission__c> newPermList = new List <ISSPAttachmentPermission__c>();
                for (Id thisId : attachIdsToCreate){
                    ISSPAttachmentPermission__c newPerm = new ISSPAttachmentPermission__c();
                    newPerm.AttachmentId__c = thisId;
                    newPerm.ShowToPortalUsers__c = true;
                    newPermList.add(newPerm);
                }
                
                if (!newPermList.isEmpty()){
                    system.debug('insert: ' + newPermList.size());
                    insert newPermList;
                }
            }
        }
    }
}