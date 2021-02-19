public class ContactSelector {
	public static List<Contact> selectByEmails(Set<String> emailList){
		return [SELECT Id, AccountId FROM Contact WHERE Email IN :emailList];
	}

	public static List<Contact> selectByIds(Set<Id> contactIdSet){
		return [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIdSet];
	}

	public static Map<Id,Contact> selectIdMapByContactSet(Set<Contact> contactSet){
		return new Map<Id,Contact>([SELECT Id FROM Contact WHERE Id IN :contactSet]);
	}

	public static List<Contact> selectAccountIdByIds(Set<Id> contactIdSet){
		return [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIdSet];
	}
}