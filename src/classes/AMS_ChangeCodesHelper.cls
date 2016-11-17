public class AMS_ChangeCodesHelper {

	public static AMS_Utils.Container generateChangeCodes(AMS_OSCAR__c oscar, AMS_Utils.AgChangesConfig config, Map<Id, Account> accounts, Map<Id, Agency_Applied_Change_code__c> accountsPrevChangeCode, String action, Set<Id> allHierarchyAccountsToApplyCC) {

		System.debug('AGENCY CHANGES: Accounts to apply change code: ' + allHierarchyAccountsToApplyCC);

		List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
		List<Account> accts = new List<Account>();
		List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();

		AMS_OSCAR_JSON.ChangeCode changeCode;
		String changeCodeIdentifier;

		if (action == AMS_Utils.SANITYCHECK)
			changeCodeIdentifier = AMS_AgencyChangesConfigHelper.getSanityCheckChangeCode(config.config);
		else if (action == AMS_Utils.APPROVAL)
			changeCodeIdentifier = AMS_AgencyChangesConfigHelper.getManagerApprovalChangeCode(config.config);
		else if (action == AMS_Utils.WITHDRAWAL)
			changeCodeIdentifier = AMS_AgencyChangesConfigHelper.getWithdrawalChangeCode(config.config);

		system.debug('AGENCY CHANGES: Change code to apply: ' + changeCodeIdentifier);
		if (changeCodeIdentifier != null) {

			//in this case apply change code only to the account related to the oscar
			//if (allHierarchyAccountsToApplyCC == null)
			//	allHierarchyAccountsToApplyCC.add(oscar.Account__c);

			for (Id acc : allHierarchyAccountsToApplyCC) {
				Account accToUpdateStatus = accounts.get(acc);
				if (accToUpdateStatus != null) {
					changeCode = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(changeCodeIdentifier, config.typesOfChange, accToUpdateStatus.Status__c, accountsPrevChangeCode.get(accToUpdateStatus.Id), action);
					changeCodes.add(changeCode);

					/*if (changeCode.status != null) {
						system.debug('CHANGE ACCOUNT STATUS: ' + changeCode.status + ' CONVERT: ' + AMS_Utils.getIATAReadableStatus(changeCode.status));
						accToUpdateStatus.Status__c = AMS_Utils.getIATAReadableStatus(changeCode.status);
					}*/

					accts.add(accToUpdateStatus);
					oscars.add(oscar);
				}
			}

		}

		system.debug('AGENCY CHANGES: changeCodes: ' + changeCodes);
		system.debug('AGENCY CHANGES: Accounts: ' + accts);
		system.debug('AGENCY CHANGES: oscars: ' + oscars);

		return new AMS_Utils.Container(changeCodes, accts, oscars);
	}

    public static AMS_Utils.Container generateVRChangeCode(String step, AMS_Oscar__c oscar, Set<Id> accountsInvolved, Map<Id, Account> accounts, Map<Id, Agency_Applied_Change_code__c> accountsChangeCode) {
       
        List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<Account> accountsToReturn = new List<Account>();
        List<AMS_Oscar__c> oscars = new List<AMS_Oscar__c>();

        for(Id accId : accountsInvolved){
            Account acc = accounts.get(accId);
            Agency_Applied_Change_code__c lastChangeCode = accountsChangeCode.get(accId);
            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

            if(step == AMS_Utils.SANITYCHECK){
                changeCode.name = 'VRR';
                changeCode.memoText = 'Advance notification for voluntary relinquishment by Agent by '+oscar.Termination_Date__c;
                changeCode.reasonCode = lastChangeCode.Reason_Code__c;
                changeCode.reasonDesc = lastChangeCode.Reason_Description__c;
                changeCode.status = AMS_Utils.getIATANumericStatus(acc.Status__c);
            }else if(step == AMS_Utils.SUSPENSION){
                String accType = acc.Location_Class__c == 'R' ? 'Cass Associate' : 'Agent';

                changeCode.name = 'NOT';
                changeCode.memoText = accType + ' is served Notice of Termination pursuant to Voluntary Relinquishment';
                changeCode.reasonCode = '62';
                changeCode.reasonDesc = 'RELINQUISHMENT IN PROCESS';
                changeCode.status ='6';
            }else if(step == AMS_Utils.TERMINATION){
                String accType = acc.Location_Class__c == 'R' ? 'Cass Associate' : 'Agent';

                changeCode.name = 'CLO';
                changeCode.memoText = 'Agent Terminated due to Voluntary Relinquishment';
                changeCode.reasonCode = '02';
                changeCode.reasonDesc = 'VOLUNTARY RELINQUISHMENT';
                changeCode.status ='0';
            }else if(step == AMS_Utils.WITHDRAWAL && oscar.Termination_result__c == AMS_Utils.PASSED){

                changeCode.name = 'REI';
                changeCode.memoText = 'Agent is re-entered on Agency List following the Agency Administrator\'s decision';
                changeCode.reasonCode = '91';
                changeCode.reasonDesc = 'ACCREDITED-MEET-STANDARDS';
                changeCode.status ='9';
            }else if(step == AMS_Utils.WITHDRAWAL && oscar.Suspension_result__c == AMS_Utils.PASSED){

                changeCode.name = 'NTW';
                changeCode.memoText = 'Voluntary relinquishment request cancelled by the Agent. Agent is retained back to IATA Agency List';

                if(AMS_Utils.getIATANumericStatus(acc.Status__c) == '8'){
                    changeCode.reasonCode = lastChangeCode.Reason_Code__c;
                    changeCode.reasonDesc = lastChangeCode.Reason_Description__c;
                    changeCode.status ='8';
                }else{

                    changeCode.reasonCode = '91';
                    changeCode.reasonDesc = 'ACCREDITED-MEET-STANDARDS';
                    changeCode.status ='9';
                }

            }else if(step == AMS_Utils.WITHDRAWAL && oscar.Process__c == AMS_UTils.VOLRELINQUISH){

                changeCode.name = 'VRW';
                changeCode.memoText = 'Agent Terminated due to Voluntary Relinquishment';
                changeCode.reasonCode = lastChangeCode.Reason_Code__c;
                changeCode.reasonDesc = lastChangeCode.Reason_Description__c;
                changeCode.status = AMS_Utils.getIATANumericStatus(acc.Status__c);
            }

            changeCodes.add(changeCode);
            accountsToReturn.add(acc);
            oscars.add(oscar);
        }
        

        return new AMS_Utils.Container(changeCodes, accountsToReturn, oscars);
    }

}