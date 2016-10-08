global class SIDRAliteMassEmailBatch implements Database.Batchable<sObject>{
	private List<Case> caseList = new List<Case>();
	private String emailTemplate;
	private String type;

    public SIDRAliteMassEmailBatch(List<Case> caseList, String emailTemplate, String type) {
        this.caseList = caseList;
        this.emailTemplate = emailTemplate;
        this.type = type;
    }

	global List<Case> start(Database.BatchableContext BC){
		return this.caseList;
	}

	global void execute(Database.BatchableContext BC, List<Case> scope){
        processCases(scope);
	}

	global void finish(Database.BatchableContext BC){

    }

	@TestVisible
    private void processCases(list<Case> listCase) {
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

        try {
			if(!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }
		} catch(Exception e) {
            System.debug('ERROR in SIDRAliteMassEmailBatch ' + e.getMessage());
            TransformationHelper.sendEmailSupport('ERROR: SIDRAliteMassEmailBatch', e.getMessage() + '   ' + e.getStackTraceString());
        }
    }

    private list<Case> casesToUpdateIRR(list<Case> listCase) {
        for(Case cse : listCase){
            cse.NOI_sent__c = DateTime.now();
            cse.Update_AIMS_IRR__c = DateTime.now();
            cse.CS_Rep_Acc_IRR_DEF__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateIRR_Withdrawal(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Update_AIMS_IRRWITH__c = DateTime.now();
            cse.Confirm_IRR_Withdrawal_to_AG__c = DateTime.now();
            cse.CS_Rep_ACC_IRR_Withdrawal__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateDEF(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Inform_Agent_DEF__c = Date.today();
            cse.Update_AIMS_DEF__c = DateTime.now();
            cse.CS_Rep_Acc_DEF__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateDEF_Withdrawal(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Confirm_Reinstatement_to_AG__c = DateTime.now();
            cse.Update_AIMS_REI_DEFWITH__c = DateTime.now();
            cse.CS_Rep_Acc_REI__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateREI(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Confirm_Reinstatement_to_AG__c = DateTime.now();
            cse.Update_AIMS_REI_DEFWITH__c = DateTime.now();
            cse.CS_Rep_Acc_REI__c = UserInfo.getUserId();
        }
        return listCase;
    }

    private list<Case> casesToUpdateTER(list<Case> listCase) {
        for(Case cse : listCase){
            cse.Confirm_Reinstatement_to_AG__c = DateTime.now();
            cse.Update_AIMS_REI_DEFWITH__c = DateTime.now();
            cse.CS_Rep_Acc_REI__c = UserInfo.getUserId();
        }
        return listCase;
    }
}