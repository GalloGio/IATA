public with sharing class AMS_Change_Code_Notification_Controller {

	public static final Set<String> VALID_RECORDTYPES = new Set<String>{'SIDRA', 'SIDRA_Lite', 'ProcessEuropeSCE'};

	public String caseId {get; set;}
	public Case currentCase {get; set;}
	public Boolean isVisible {get{
		return currentCase!=null && VALID_RECORDTYPES.contains(currentCase.RecordType.DeveloperName);
	}}

	public AMS_Change_Code_Notification_Controller(ApexPages.StandardController stdController) {
		caseId = stdController.getId();

		list<Case> lstCases = [SELECT Id, RecordType.DeveloperName, Remittance_Period__c, Status, AccountId,
								 Account.Name, Account.IATACode__c, Account.Location_Type__c,
								 Account.Top_Parent__r.Name, Account.Top_Parent__r.IATACode__c,
								 Account.ANG_Accreditation_Model__c, OSCAR__c
								 FROM Case
								 WHERE Id = :caseId];
		if (!lstCases.isEmpty()) {
			currentCase = lstCases[0];
		}


	}

	public void setNotificationMessage() {

		if (currentCase != null) {
			list<Agency_Applied_Change_code__c> lstRecentChangeCodes = new list<Agency_Applied_Change_code__c>();
			Datetime dateRange = Datetime.now().addMinutes(-1);
			Boolean isOscar = false;

			if (currentCase.RecordType.DeveloperName == 'OSCAR_Communication' && currentCase.OSCAR__c != null) {
				// OSCAR Communication Cases - change code linked to the oscar
				lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE OSCAR__c = :currentCase.OSCAR__c AND CreatedDate > :dateRange];
				isOscar = true;

			} else if (VALID_RECORDTYPES.contains(currentCase.RecordType.DeveloperName)) {
				// SIDRA or SAAM Cases - change code linked to the case
				lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE SIDRA_Case__c = :currentCase.Id AND CreatedDate > :dateRange];
			}

			if (!lstRecentChangeCodes.isEmpty()) {
				String codes = '';

				map<String, Integer> mapCountPerChangeCode = new map<String, Integer>();
				for (Agency_Applied_Change_code__c cc : lstRecentChangeCodes)
					if (mapCountPerChangeCode.get(cc.Change_Code__c) != null)
						mapCountPerChangeCode.put(cc.Change_Code__c, mapCountPerChangeCode.get(cc.Change_Code__c) + 1);
					else
						mapCountPerChangeCode.put(cc.Change_Code__c, 1);

				for (Agency_Applied_Change_code__c cc : lstRecentChangeCodes) {
					if (mapCountPerChangeCode.get(cc.Change_Code__c) == 1) {
						// create the link to the newly applied code: std hyper link for normal interface, javascript for console (the oscar is supposed to only be open in console mode)
						codes += (codes == '' ? ' ' : ', ') + '<a href="' + (isOscar ? 'javascript:srcUp(\'' : '') + '/' + cc.Id + (isOscar ? '\');' : '') + '"' + (isOscar ? '' : ' target="_blank" ') + '>' + cc.Change_Code__c + '</a>';
					} else if(mapCountPerChangeCode.get(cc.Change_Code__c) != null){
						codes += (codes == '' ? ' ' : ', ') + mapCountPerChangeCode.get(cc.Change_Code__c) + ' x ' + cc.Change_Code__c;
						// prevent from being displayed again next time the script iterates over the same change code in the list
						mapCountPerChangeCode.put(cc.Change_Code__c, null);
					}
				}



				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AMS_New_Change_Code_Notification + codes));

			} else {
				// check if we need to show any aditional notification
				List<Technical_Logs__c> notifications = [SELECT Id, Record__c, Log__c FROM Technical_Logs__c WHERE Record__c LIKE :caseId+'%' AND CreatedDate > :dateRange ORDER BY CreatedDate DESC];

				if(!notifications.isEmpty()){
					String message = '';
					for(Integer i = 0; i < notifications.size(); i++){

						if(notifications[i].Log__c.contains('NOT')) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This is not the third non-compliance. NOT change code was not generated'));
						else message += (i == 0 ? '' :' and ')+notifications[i].Log__c;
					}

					if(!String.isEmpty(message)) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message+(notifications.size()>1?' were ' : ' was ')+'not generated, please issue Notice of Termination'));

					//clean log records
					delete notifications;
				}
			}

			/*
			 pop up message to customer service team when they land on a SIDRA case with a matching remittance period (case field) to the one in the amazon file record
			 WMO-358
			 */
			if(currentCase.RecordType.DeveloperName == 'SIDRA'){
				if(currentCase.Remittance_Period__c != null){

					List<Account_Statement__c> listStatements = [Select Id, Period__c, Operation__c, Name, Account__c,
																		Amount_to_be_Paid__c, Balance__c, Billing_Amount__c,
																		Paid__c, Remittance_Date__c, Status__c, Billing_Adjustment__c,
																		Account__r.Name, LastModifiedDate
																		From Account_Statement__c
																		Where Account__c =: currentCase.AccountId
																		And Period__c =: currentCase.Remittance_Period__c
																		LIMIT 100];
					if(!listStatements.isEmpty()) {
						list<AmazonFile__c> accountStatementAttPOP = new List<AmazonFile__c>();
						String AmazonFileName = AmazonFile.ICE_proofOfPayment + ' ' + listStatements[0].Period__c + ' ' + listStatements[0].Billing_Amount__c;
						accountStatementAttPOP  = AmazonFile.getAccountRelatedAmazonFiles(currentCase.AccountId, AmazonFileName);

						if(!accountStatementAttPOP.isEmpty()){
							//String msg = 'There are proof of payment add to the account:';
							String msg = Label.ICE_POP_Sidra_Msg;
							Integer secondsValid = 300;

							for (AmazonFile__c af : accountStatementAttPOP){
								String amazonLink = AmazonRest.genPublicExpiringAWSLink( af.Full_Name_Unique__c, WrapperAttach.CREDENTIAL, secondsValid);
								msg = msg + ' '+ '<a href="'+amazonLink+'" target="_blank">'+af.Name+'</a>';

							}
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));

						}
					}
				}
				if(currentCase.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY){
					String geData = Label.SIDRA_GE_Info + ' ';
					if(currentCase.Account.Location_Type__c == AMS_Utils.GE) {
						geData = geData + currentCase.Account.IATACode__c + ' ' + currentCase.Account.Name;
					} else {
						geData = geData + currentCase.Account.Top_Parent__r.IATACode__c + ' ' + currentCase.Account.Top_Parent__r.Name;
					}
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, geData));
				}
			}
		}
	}
}