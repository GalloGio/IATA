public with sharing class TransferCaseAttachmentsController {
	public Case sourceCase {get; set;}
	public Case targetCase {get; set;}
	public list<CaseWrapper> lstRelatedCases {get; set;}
	public list<AttachmentWrapper> lstAttachments {get; set;}
	public Boolean isTransferDone {get; set;}
	public Boolean SelectAllCheckbox{get;set;}

	public TransferCaseAttachmentsController (ApexPages.StandardController controller) {
		this.SelectAllCheckbox = false;
		if (controller.getRecord().Id != null ) {
			sourceCase = [SELECT Id, Status, AccountId, ParentId, RecordType.DeveloperName FROM Case WHERE Id = :controller.getRecord().Id];
			targetCase = new Case();

			// get the attachments of the source case
			lstAttachments = new list<AttachmentWrapper>();
			for (Attachment att : [SELECT Id, Body, BodyLength, ContentType, Description, Name, ParentId, CreatedDate FROM Attachment WHERE ParentId = :sourceCase.Id]) {
				AttachmentWrapper aw = new AttachmentWrapper();
				aw.AttachmentRecord = att;
				aw.isSelected = false;
				lstAttachments.add(aw);
			}

			// get a list of all the cases related to the source case: parents, children, siblings
			lstRelatedCases = new list<CaseWrapper>();
			list<Case> lstRCases = [SELECT Id, ParentId, CaseNumber, Status, Subject, Account.Name, Owner.Name, RecordType.Name, CreatedDate
									FROM Case
									WHERE Id <> :sourceCase.Id AND (
									Id = :sourceCase.ParentId
									OR (ParentId <> null  AND ParentId = :sourceCase.ParentId)
									OR ParentId = :sourceCase.Id) ];
			for (Case c : lstRCases) {
				CaseWrapper cw = new CaseWrapper();
				cw.CaseRecord = c;
				cw.isSelected = false;
				if ( c.Id == sourceCase.ParentId) {
					cw.strRelationship = 'Parent';
				} else if (c.ParentId == sourceCase.Id) {
					cw.strRelationship = 'Child';
				} else if (c.ParentId == sourceCase.ParentId) {
					cw.strRelationship = 'Sibling';
				}

				lstRelatedCases.add(cw);
			}

			isTransferDone = false;

		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid source Case'));
		}
	}


	public void TransferAttachments () {
		// list of attachments to be created
		list<Attachment> lstNewAttachments = new list<Attachment>();

		// check there's at least 1 selected attachment to be transferred
		Boolean isAttachmentSelected = false;
		for (AttachmentWrapper aw : lstAttachments) {
			if (aw.isSelected) {
				isAttachmentSelected = true;
			}
		}
		// check there's at least 1 selected target case
		Boolean isTargetSelected = false;
		for (CaseWrapper cw : lstRelatedCases) {
			if (cw.isSelected) {
				isTargetSelected = true;
			}
		}


		if (!isAttachmentSelected) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least 1 attachment to transfer.'));

		} else if (targetCase.ParentId == null && !isTargetSelected) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least 1 target Case to receive the attachments.'));

		} else {
			// if the target has been manually selected, add it to the Case Wrapped as selected
			if (targetCase.ParentId != null) {
				Case c = new Case(Id = targetCase.ParentId);
				CaseWrapper cw = new CaseWrapper();
				cw.CaseRecord = c;
				cw.isSelected = true;
				lstRelatedCases.add(cw);
			}

			// go through the list of related cases and create the new attachment(s) for every selected case
			for (CaseWrapper cw : lstRelatedCases) {
				if (cw.isSelected) {

					for (AttachmentWrapper aw : lstAttachments) {
						if (aw.isSelected) {

							Attachment newAtt = new Attachment();
							newAtt.ParentId = cw.CaseRecord.Id;
							newAtt.Body = aw.AttachmentRecord.Body;
							newAtt.ContentType = aw.AttachmentRecord.ContentType;
							newAtt.Description = aw.AttachmentRecord.Description;
							newAtt.Name = aw.AttachmentRecord.Name;

							lstNewAttachments.add(newAtt);
						}
					}

				}
			}

			if (!lstNewAttachments.isEmpty()) {
				Database.SaveResult[] srList = Database.insert(lstNewAttachments, false);

				Integer success = 0;
				Integer errors = 0;
				for (Database.SaveResult sr : srList) {
					if (sr.isSuccess()) {
						success ++;
					} else {
						errors ++;
					}
				}

				isTransferDone = true;
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The attachments transfer operation completed with ' + success + ' success(es) and ' + errors + ' error(s).\n\n<a href="/' + sourceCase.Id + '">Click here</a> to return to the case.'));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The attachments transfer operation completed with ' + success + ' success(es) and ' + errors + ' error(s).\n\n<a href="/' + sourceCase.Id + '" onClick="testCloseTab()">Click here</a> to return to the case.'));
			}
		}
	}

	public PageReference Cancel () {
		PageReference pref = new PageReference('/' + sourceCase.Id);
		return pref;
	}

	/**
		Activate or deactivate all attachments in the list
	**/
	public PageReference SelectAll() {
		for (AttachmentWrapper att: this.lstAttachments ) {
			att.isSelected = this.SelectAllCheckbox;
		}
	  return null;
	}


	public class CaseWrapper {
		public Case CaseRecord {get; set;}
		public Boolean isSelected {get; set;}
		public String strRelationship {get; set;}
	}

	public class AttachmentWrapper {
		public Attachment AttachmentRecord {get; set;}
		public Boolean isSelected {get; set;}
	}
}
