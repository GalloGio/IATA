global class ANG_AmendFS implements Process.Plugin {
	public class ANG_AmendFSException extends Exception {}

	global Process.PluginResult invoke(Process.PluginRequest request){
		double  NewFSAmount     = (double)  request.inputParameters.get('NewFSAmount');
		string  SelectedCaseId    = (string)  request.inputParameters.get('SelectedCaseId');
		string  SelectedCurrency  = (string)  request.inputParameters.get('SelectedCurrency');
		string  FSToCloneId     = (string)  request.inputParameters.get('FSToCloneId');
		datetime  ExpiryDate      = (Datetime)  request.inputParameters.get('ExpiryDate');
		boolean UnlimitedValidity = (boolean) request.inputParameters.get('UnlimitedValidity');
		string  FSValidationCase  = (string)  request.inputParameters.get('FSValidationCase');
		Date validityStartDate = (Date) request.inputParameters.get('ValidityStartDate');

		string sResult = 'KO';
		string sMessage = '';
		string CreatedFSId = '';
		Savepoint sp = Database.setSavepoint();

		try{
			//Get FS to Clone
			Financial_Security__c fs = [SELECT id, name, Financial_Institution__c, Region__c, Account__c, Reception_Case__c,
											Expiry_Date__c, Security_Type__c
										FROM Financial_Security__c
										WHERE id = :FSToCloneId];

			//Create new FS by cloning the old one.
			//Set the new amount equal to the value provided in input
			Financial_Security__c fsCloned = fs.clone(false, true, false, false);

			fsCloned.Reception_Date__c = system.today();
			fsCloned.Reception_Case__c = SelectedCaseId;
			fsCloned.Reasonforrequest__c = 'Previous Security Update';
			fsCloned.Amount__c = NewFSAmount;
			fsCloned.CurrencyIsoCode = SelectedCurrency;
			fsCloned.Expiry_Date__c = ExpiryDate==null?null:date.newinstance(ExpiryDate.year(), ExpiryDate.month(), ExpiryDate.day());
			fsCloned.Unlimited_Security__c = UnlimitedValidity;
			fsCloned.Remarks__c = fs.name;
			if (fs.Security_Type__c=='Bank Guarantee') {
				list<Case> listCase = [SELECT Id FROM Case WHERE CaseNumber = :FSValidationCase];
				if (listCase.isEmpty()) {
					throw new ANG_AmendFSException('Financial security Validation Case ' + FSValidationCase + ' not found. Go to previous page and select a valid Case Number');
				}
				fsCloned.Financial_Security_Validation_Case__c = listCase[0].Id;
			}

			if(validityStartDate != null){
				fsCloned.Validity_Start_Date__c = validityStartDate;
			}

			insert fsCloned;

			CreatedFSId = fsCloned.Id;

			//Copy attachments from cloned FS to new one created
			list<Attachment> lsAttstoIns = new list<Attachment>();

			for(Attachment a: [select id, name, body from Attachment where ParentId = :fs.Id]){
				lsAttstoIns.add(new Attachment(name = a.name, body = a.body, parentid = fsCloned.Id));
			}

			if(!lsAttstoIns.isEmpty()) insert lsAttstoIns;

			//Inactivate old FS
			fs.Security_Status__c = 'Inactive_Addendum';
			fs.Release_Date__c = system.today();
			fs.Release_Reason__c = 'Security Update';
			update fs;

			sResult = 'OK';
		}catch(Exception e){
			sMessage = e.getMessage();
			Database.rollback(sp);
		}

		Map<String,Object> result = new Map<String,Object>();
		result.put('CreatedFSId', CreatedFSId );
		result.put('Result', sResult);
		result.put('Message', sMessage);

		return new Process.PluginResult(result);
	}


	global Process.PluginDescribeResult describe() {
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();

		result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {
			new Process.PluginDescribeResult.InputParameter('NewFSAmount', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
			new Process.PluginDescribeResult.InputParameter('SelectedCaseId', Process.PluginDescribeResult.ParameterType.STRING, true),
			new Process.PluginDescribeResult.InputParameter('SelectedCurrency', Process.PluginDescribeResult.ParameterType.STRING, true),
			new Process.PluginDescribeResult.InputParameter('ExpiryDate', Process.PluginDescribeResult.ParameterType.DATETIME, true),
			new Process.PluginDescribeResult.InputParameter('UnlimitedValidity', Process.PluginDescribeResult.ParameterType.BOOLEAN, true),
			new Process.PluginDescribeResult.InputParameter('FSToCloneId', Process.PluginDescribeResult.ParameterType.STRING, true),
			new Process.PluginDescribeResult.InputParameter('FSValidationCase', Process.PluginDescribeResult.ParameterType.STRING, true),
			new Process.PluginDescribeResult.InputParameter('ValidityStartDate', Process.PluginDescribeResult.ParameterType.DATE, false)
		};

		result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
			new Process.PluginDescribeResult.OutputParameter('CreatedFSId', Process.PluginDescribeResult.ParameterType.STRING),
			new Process.PluginDescribeResult.OutputParameter('Result', Process.PluginDescribeResult.ParameterType.STRING),
			new Process.PluginDescribeResult.OutputParameter('Message', Process.PluginDescribeResult.ParameterType.STRING)
		};

		return result;
	}
}
