public class AWSKeys {

	public class AWSKeysException extends Exception {}

	AWSKey__c keyObj = null;
	public string key { get { return keyObj.key__c; } private set; }
	public string secret { get { return keyObj.secret__c; } private set; }
	public string sNamedCredential { get { return keyObj.Named_Credential__c; } private set; }
	// constructor
	public AWSKeys(string name) {
		try {
			string sErrField = '';
			keyObj = [select key__c, secret__c, id, Named_Credential__c from AWSKey__c where name = :name limit 1];

			//Check that key__c is not null
			if (string.isBlank(keyObj.key__c)) { sErrField = 'Key';}

			//Check that secret__c is not null
			if (string.isBlank(keyObj.secret__c)) { sErrField = 'Secret';}

			if (string.isBlank(keyObj.Named_Credential__c)) { sErrField = 'Named Credential';}

			if(sErrField!=''){
				string sErrMsg = 'Error: No ' + sErrField + ' is specified for the AWSKey__c record with name of [' + name + ']. Pleaes enter the ' + sErrField + 'value and retry.';
				ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, sErrMsg);
				ApexPages.addMessage(errorMsg);
				throw new AWSKeysException(sErrMsg);
			}

		} catch (QueryException queryEx) {
			throw new AWSKeysException('Error when querying the AWSKey__c custom object. Did not find any record with name of [' + name + ']. Please make sure the name is correct or create a record with the proper AWS credentials and retry.');
		}
		//don't catch other exceptions, let them fall through to the calling class....
	}
  }
