public class RecordTypeSelector {
	public static Id selectIdBySObjectAndName(String sObjectType, String recordTypeName){
		return [SELECT Id FROM RecordType WHERE SobjectType =:sObjectType AND Name =:recordTypeName].get(0).Id;
	}
}