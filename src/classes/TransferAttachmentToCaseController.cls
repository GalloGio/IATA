public with sharing class TransferAttachmentToCaseController {
    public Case sourceCase {get; set;}
    public Case targetCase {get; set;}
    public list<CaseWrapper> lstRelatedCases {get; set;}
    public list<WrapperAttach> lstAttachments {get; set;}
    public Boolean isTransferDone {get; set;}
    public Boolean SelectAllCheckbox{get;set;}
    public Double offset{ get{
        TimeZone tz = UserInfo.getTimeZone();
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }}

    public TransferAttachmentToCaseController (ApexPages.StandardController controller) {
        this.SelectAllCheckbox = false;
        Id caseId = controller.getRecord().Id;
        if (caseId == null ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Invalid_Source_Case));
            return;
        }

        sourceCase = [SELECT Id, Status, AccountId, ParentId, RecordType.DeveloperName FROM Case WHERE Id = :caseId];
        targetCase = new Case();

        // get the attachments of the source case with body field
        lstAttachments = WrapperAttach.getListAttachments(caseId, true);

        // get a list of all the cases related to the source case: parents, children, siblings
        lstRelatedCases = new list<CaseWrapper>();
        list<Case> lstRCases = [SELECT Id, ParentId, CaseNumber, Status, Subject, Account.Name, Owner.Name, RecordType.Name, CreatedDate
                                FROM Case
                                WHERE Id <> :sourceCase.Id AND (
                                Id = :sourceCase.ParentId
                                OR (ParentId <> null    AND ParentId = :sourceCase.ParentId)
                                OR ParentId = :sourceCase.Id) ];
        for (Case c : lstRCases) {
            CaseWrapper cw = new CaseWrapper();
            cw.CaseRecord = c;
            cw.isSelected = false;

            if ( c.Id == sourceCase.ParentId)           cw.strRelationship = 'Parent';
            else if (c.ParentId == sourceCase.Id)       cw.strRelationship = 'Child';
            else if (c.ParentId == sourceCase.ParentId) cw.strRelationship = 'Sibling';

            lstRelatedCases.add(cw);
        }

        isTransferDone = false;
    }

    private list<WrapperAttach> getAttachmentSelected() {
        list<WrapperAttach> listAttachments = new list<WrapperAttach>();
        //throw new transformationException('lstAttachments ' + lstAttachments);

        for (WrapperAttach attach : lstAttachments) {
            if (attach.isSelected) {
                listAttachments.add(attach);
            }
        }
        return listAttachments;
    }

    private list<CaseWrapper> getTargetCaseSelected() {
        list<CaseWrapper> listTargetCaseSelected = new list<CaseWrapper>();
        for (CaseWrapper cw : lstRelatedCases) {
            if (cw.isSelected) {
                listTargetCaseSelected.add(cw);
            }
        }
        // if the target has been manually selected, add it to the Case Wrapped as selected
        if (targetCase.ParentId != null) {
            Case c = new Case(Id = targetCase.ParentId);
            CaseWrapper cw = new CaseWrapper();
            cw.CaseRecord = c;
            cw.isSelected = true;
            listTargetCaseSelected.add(cw);
        }
        return listTargetCaseSelected;
    }

    /**
        Activate or deactivate all attachments in the list
    **/
    public PageReference SelectAll() {
        for (WrapperAttach att: this.lstAttachments ) {
            att.isSelected = this.SelectAllCheckbox;
        }
      return null;
    }

    public void TransferAttachments () {
        // Save new attachments
        Integer success = 0;
        Integer errors = 0;

        // check if there is any attachment selected
        list<WrapperAttach> listAttachmentSelected = getAttachmentSelected();
        if ( listAttachmentSelected.isEmpty() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Select_one_Attachment));
            return;
        }

        // check if there is any target case selected
        list<CaseWrapper> listTargetCaseSelected = getTargetCaseSelected();
        if (listTargetCaseSelected.isEmpty() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Select_one_Case));
            return;
        }

        for(CaseWrapper cw : listTargetCaseSelected  ){
            if(sourceCase.id == cw.caserecord.id ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You selected the same source case as destination, please reselect a proper case'));
                return;
            }
        }



        // list of attachments to be created
        list<Attachment> lstNewAttachments = new list<Attachment>();
        //list<Archived_Attachment__c> lstNewArchived = new list<Archived_Attachment__c>();
        list<AmazonFile__c> lstNewAmazon = new list<AmazonFile__c>();

        // go through the list of related cases and create the new attachment(s) for every selected case
        for (CaseWrapper cw : listTargetCaseSelected) {
            for (WrapperAttach attach : listAttachmentSelected) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,cw + '<br/>'+ attach));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'is SF ' + attach.getIsSalesforce() ));

                // if is a regular attachment, clone it
                if (attach.getIsSalesforce() ) {
                    Attachment newAtt = attach.fileAttachment.clone();
                    newAtt.Body = attach.fileAttachment.Body;
                    newAtt.ParentId = cw.CaseRecord.Id;
                    newAtt.OwnerId = UserInfo.getUserId();//added by MGO INC254433
                    lstNewAttachments.add(newAtt);
                }
                /*
                // if is an archived file, clone it
                if (attach.getIsArchived() ) {
                    Archived_Attachment__c newAtt = attach.fileArchived.clone();
                    newAtt.Case__c = cw.CaseRecord.Id;
                    lstNewArchived.add(newAtt);
                }
                */
                // if it is an amazon file, clone it and do the copy to amazon
                if (attach.getIsAmazon() ) {
                    AmazonFile newAtt = attach.transfer(cw.CaseRecord.Id);

                    if ( newAtt == null ) errors++;
                    else lstNewAmazon.add(newAtt.amazonFile);
                }
            }
        }

        if (!lstNewAttachments.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(lstNewAttachments, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    success ++;
                } else {
                    errors ++;
                    System.debug('ERROR inserting attachment ' + String.ValueOf(sr.getErrors()));
                }
            }
        }
        if (!lstNewAmazon.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(lstNewAmazon, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    success ++;
                } else {
                    errors ++;
                    System.debug('ERROR inserting attachment ' + String.ValueOf(sr.getErrors()));
                }
            }
        }
        isTransferDone = true;
        String message = Label.Response_message;
        message = message.replace('{0}', String.ValueOf(success));
        message = message.replace('{1}', String.ValueOf(errors));
        message = message.replace('{2}', String.ValueOf(sourceCase.Id));

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));
    }

    public PageReference Cancel () {
        PageReference pref = new PageReference('/' + sourceCase.Id);
        return pref;
    }


    public class CaseWrapper {
        public Case CaseRecord {get; set;}
        public Boolean isSelected {get; set;}
        public String strRelationship {get; set;}
    }

}