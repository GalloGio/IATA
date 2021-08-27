public class RecordTypeSelector {
	public static Id selectIdBySObjectAndDeveloperName(String sObjectType, String recordTypeName){
		return [SELECT Id FROM RecordType WHERE SobjectType =:sObjectType AND DeveloperName =:recordTypeName].get(0).Id;
	}
}