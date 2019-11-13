global class ISSP_2FA_Reset implements Process.Plugin {

	global Process.PluginResult invoke(Process.PluginRequest request) {

		String userId = (String) request.inputParameters.get('userId');

		List <TwoFactorInfo> tfList = [SELECT Id FROM TwoFactorInfo WHERE UserId = :userId];
		delete tfList;

		List <User> myUserList = [SELECT Id, Email, ContactId FROM User WHERE Id = :userId];
		if (!myUserList.isEmpty()){
			User myUser = myUserList[0];
			String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ISSP_Reset_2FA_Device'].Id;
			List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] bccAddresses = new String[] {};
			if (ISSP_CS__c.getValues('TwoFA_Emails').value__c != null){
				bccAddresses = ISSP_CS__c.getValues('TwoFA_Emails').value__c.split(';');
				//bccAddresses.add('khattabil@iata.org');
				system.debug('bccAddresses: ' + bccAddresses);
				mail.setBccAddresses(bccAddresses);
			}
			mail.setTargetObjectId(myUser.ContactId);
			mail.setTemplateId(templateId);
			mail.setWhatId(myUser.ContactId);
			mail.saveAsActivity = false;
			mailsToSend.add(mail);
			Messaging.sendEmailResult[] sendEmailResults = new List<Messaging.Sendemailresult>();
			if (mailsToSend.size() > 0){
				system.debug('sending mail');
				sendEmailResults = Messaging.sendEmail(mailstoSend, false);
			}
		}

		// return to Flow
		Map<String,Object> result = new Map<String,Object>();
		return new Process.PluginResult(result);
	}


	// Returns the describe information for the interface
	global Process.PluginDescribeResult describe() {
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = '2FA_Reset';
		result.Tag = 'APEX';
		result.inputParameters = new
		   List<Process.PluginDescribeResult.InputParameter>{
			   new Process.PluginDescribeResult.InputParameter('userId',
			   Process.PluginDescribeResult.ParameterType.STRING, true)
			};
		result.outputParameters = new
		   List<Process.PluginDescribeResult.OutputParameter>{ };
		return result;
	}

}
