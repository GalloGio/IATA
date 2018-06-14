global class SIDRAliteMassEmailBatch implements Database.Batchable<Case>, Database.AllowsCallouts {

	private String sessionId;
	private String apiServerUrl;
	private List<Case> caseList = new List<Case>();
	//private String emailTemplate;
	private String type;
	private Boolean sendToParentCase;
	private list<Database.SaveResult> listErrors = new list<Database.SaveResult>();

    public SIDRAliteMassEmailBatch(List<Case> caseList, String type, Boolean sendToParentCase, String sessionId, String apiServerUrl) {
		this.sessionId = sessionId;
		this.apiServerUrl = apiServerUrl;
        this.caseList = caseList;
		this.sendToParentCase = sendToParentCase;
        //this.emailTemplate = emailTemplate;
        this.type = type;
    }

	global List<Case> start(Database.BatchableContext BC){
		return this.caseList;
	}

	global void execute(Database.BatchableContext BC, List<Case> scope){
        processCases(scope);
	}

	global void finish(Database.BatchableContext BC){
		processErrors();
    }

	@TestVisible
	private void processErrors() {
		if (this.listErrors.isEmpty()) return;

		String errorDescription = '';
		for (Database.SaveResult result : this.listErrors) {
			for(Database.Error err : result.getErrors()) {
				errorDescription += 'Case error ' + result.getId() + '\n';
				errorDescription += err.getStatusCode() + ': ' + err.getMessage() + '\n';
				errorDescription +='Case fields that affected this error: ' + err.getFields() + '\n';
				errorDescription += '\n\n';
			}
		}
		System.debug('ERROR in SIDRAliteMassEmailBatch ' + errorDescription );
		TransformationHelper.sendEmailSupport('ERROR: SIDRAliteMassEmailBatch', errorDescription);
	}

    public void processCases(list<Case> listCase) {
        list<Case> casesToUpdate = new list<Case>();

        if (this.type == 'IRR') {
            casesToUpdate = casesToUpdateIRR(listCase);
        }
        else if (this.type == 'IRR Withdrawal') {
            casesToUpdate = casesToUpdateIRR_Withdrawal(listCase);
        }
        else if (this.type == 'DEF') {
            casesToUpdate = casesToUpdateDEF(listCase);
        }
        else if (this.type == 'DEF Withdrawal') {
            casesToUpdate = casesToUpdateDEF_Withdrawal(listCase);
        }
        else if (this.type == 'REI') {
            casesToUpdate = casesToUpdateREI(listCase);
        }
        else if (this.type == 'TER') {
            casesToUpdate = casesToUpdateTER(listCase);
        }

		Database.SaveResult[] listResults = Database.update(casesToUpdate, false);
		map<Id,Case> mapCases = new map<Id,Case>(casesToUpdate);
		for (Database.SaveResult result : listResults) {
			Case cse = mapCases.get(result.getId());
		    if (result.isSuccess()) {
				sendCongaMail(cse, this.type);
		    } else {
				this.listErrors.add(result);
			}
		}
    }

    private list<Case> casesToUpdateIRR(list<Case> listCase) {
        for(Case cse : listCase){
            cse.NOI_sent__c = DateTime.now();
            cse.Update_AIMS_IRR__c = DateTime.now();
            //cse.CS_Rep_Acc_IRR_DEF__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateIRR_Withdrawal(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Update_AIMS_IRRWITH__c = DateTime.now();
            cse.Confirm_IRR_Withdrawal_to_AG__c = DateTime.now();
            //cse.CS_Rep_ACC_IRR_Withdrawal__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateDEF(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Inform_Agent_DEF__c = Date.today();
            cse.Update_AIMS_DEF__c = DateTime.now();
            //cse.CS_Rep_Acc_DEF__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateDEF_Withdrawal(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Confirm_Reinstatement_to_AG__c = DateTime.now();
            cse.Update_AIMS_REI_DEFWITH__c = DateTime.now();
            //cse.CS_Rep_Acc_REI__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateREI(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Confirm_Reinstatement_to_AG__c = DateTime.now();
            cse.Update_AIMS_REI_DEFWITH__c = DateTime.now();
            //cse.CS_Rep_Acc_REI__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateTER(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Update_AIMS_TER__c = DateTime.now();
            cse.Notify_TER_to_AG__c = DateTime.now();
            //cse.CS_Rep_Acc_REI__c = UserInfo.getUserId();
        }
        return listCase;
    }

	public EmailTemplate getTemplate(Case cse) {
		try {
			SidraLiteEmailTemplates__c selectedTemplate = SidraLiteEmailTemplates__c.getInstance(this.type);

			EmailTemplate emailTemplate = [SELECT id, Name
				FROM EmailTemplate
				WHERE Name = :selectedTemplate.EmailTemplate__c
				limit 1];
			return emailTemplate;

		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Template not found, please check templates for case ' + cse.CaseNumber + ' and type ' + this.type));
			return null;
		}
	}

	/**
		Send an email using conga services, mail merge template and email template are selected based on case and action type
	**/
	@TestVisible
	private void sendCongaMail(Case cse, String actiontype) {
		Id contactId;
		if (this.sendToParentCase && cse.parent.contactId != null) {
			contactId = cse.parent.contactId;
		} else {
			contactId = cse.ContactId;
		}

		try {
			String mergeTemplateId = SidraLiteUtil.getMergeTemplate(cse,actiontype);
			String emailTemplateId = SidraLiteUtil.getEmailTemplate(cse,actiontype);
			CongaManager.sendMail(this.sessionId, this.apiServerUrl, cse.Id, contactId, mergeTemplateId, emailTemplateId);

		} catch (Exception e) {
			System.debug('**sendCongaMail ' + e.getMessage());
		}
	}
}