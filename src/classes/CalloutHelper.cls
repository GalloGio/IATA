public class CalloutHelper{

    public static Named_Credential_Mapping__mdt getFullConfig(string DeveloperName){
        return [select HTTP_Method__c, Named_Credential_To_Use__c, Resource__c from Named_Credential_Mapping__mdt where DeveloperName=:DeveloperName];
	}
	
	public string getResourceFromConfig(string DeveloperName){
		string sResource = '';
		if(!string.isBlank(DeveloperName)){
			Named_Credential_Mapping__mdt conf = [select Resource__c from Named_Credential_Mapping__mdt where DeveloperName=:DeveloperName];
			if(conf!=null) sResource = conf.Resource__c;
		}
		return sResource;
	}
}