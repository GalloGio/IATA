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


}