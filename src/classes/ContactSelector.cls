public class ContactSelector {
	public static List<Contact> selectByEmails(Set<String> emailList){
		return [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :emailList];
	}

	public static Map<Id,Contact> selectByIds(Set<Id> contactIdSet){
		return new Map<Id, Contact>([SELECT Id, Email, AccountId FROM Contact WHERE Id IN :contactIdSet]);
	}

	public static Map<Id,Contact> selectIdMapByContactSet(Set<Contact> contactSet){
		return new Map<Id,Contact>([SELECT Id FROM Contact WHERE Id IN :contactSet]);
	}

	public static List<Contact> selectAccountIdByIds(Set<Id> contactIdSet){
		return [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIdSet];
	}

	public static Map<String,Contact> selectEmailContactMapByEmails(Set<String> emailSet){
		List<Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email IN :emailSet];
		Map<String,Contact> emailContactMap = new Map<String,Contact>();
		for(Contact contact : contactList){
			emailContactMap.put(contact.Email, contact);
		}
		return emailContactMap;
	}
}