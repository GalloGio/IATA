public class CalloutHelper{

	public Named_Credential_Mapping__mdt getFullConfig(string DeveloperName){
		list<Named_Credential_Mapping__mdt> ls = [select HTTP_Method__c, Named_Credential_To_Use__c, Resource__c from Named_Credential_Mapping__mdt where DeveloperName=:DeveloperName];
		if(ls.isEmpty())
			return null;
		else return ls[0];
	}
	
	public string getResourceFromConfig(string DeveloperName){
		string sResource = '';
		if(!string.isBlank(DeveloperName)){
			Named_Credential_Mapping__mdt conf = this.getFullConfig(DeveloperName);
			if(conf!=null)
				sResource = conf.Resource__c;
		}
		return sResource;
	}
}