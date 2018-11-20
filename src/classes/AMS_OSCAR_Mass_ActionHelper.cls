public class AMS_OSCAR_Mass_ActionHelper {
	
	public static void process_PCI(AMS_OSCAR__c oscar) {
		oscar.STEP6__c = 'Passed';
		oscar.Is_PCI_compliant__c = 'No';
		oscar.ANG_PCI_compliance_expiry_date__c = null;
		oscar.Status__c = 'Closed';
		update oscar;
	}

	public static void create_VR(Account acc) {
		/*** Create OSCAR ***/
		AMS_OSCAR__c oscar = new AMS_OSCAR__c();
		oscar.Account__c = acc.Id;
		Set<String> vr_ca_classes = new Set<String> {'G', 'M', 'X', 'T'};
		if(vr_ca_classes.contains(oscar.Location_Class__c)) {
			oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
		} else {
			oscar.Process__c = AMS_Utils.VOLRELINQUISH;
		}		
		oscar.RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('VOLUNTARY RELINQUISHMENT').getRecordTypeId();
		oscar.Status__c = 'Open';
		insert oscar;

		/*** Create Case ***/
		Case cse = new Case();
		cse.AccountId = acc.Id;
		cse.Account_Concerned__c = acc.Id;
		cse.BSPCountry__c = acc.BillingCountry;
		cse.CaseArea__c = AMS_UTILS.CASE_AREA_ACCREDITATION_PROCESS;
		cse.Reason1__c = AMS_UTILS.CASE_REASON_VR_CLOSURE;
		cse.Origin = 'Internal';
		cse.OSCAR__c = oscar.Id;
		cse.Region__c = acc.Region_formula__c;
		cse.ContactId = getCaseContact(acc);
		cse.RecordTypeId = schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		insert cse;

		cse = [SELECT Id, CaseNumber, Region__c FROM Case WHERE Id = :cse.Id];

		oscar.STEP6__c = 'Passed';
		oscar.Name = cse.CaseNumber;
		oscar.Change_Effective_as_of__c = Date.today();
		oscar.OwnerId = AMS_Utils.getRegionalQueue(cse);
		update oscar;		
	}

	private static Id getCaseContact(Account acc) {
		Set<Id> accountIds = new Set<Id> {acc.Id};
		if(acc.ParentId != null) {
			accountIds.add(acc.ParentId);
		}
		
		List<Contact> contacts = [SELECT Id, AccountId, User_Portal_Status__c, Financial_Assessment_Contact__c, BSP_CASS_Payment_contact__c
								  FROM Contact
								  WHERE AccountId IN :accountIds AND IsEmailBounced = false AND Status__c = 'Active' AND
								  	(BSP_CASS_Payment_contact__c = true OR Financial_Assessment_Contact__c = true OR User_Portal_Status__c = 'Approved Admin')];

		Map<Id,List<Contact>> mapContacts = new Map<Id,List<Contact>>();
		for(Contact c : contacts) {
			List<Contact> comContacts = mapContacts.get(acc.Id);
			if(comContacts == null) {
				comContacts = new Contact[3];
				mapContacts.put(acc.Id, comContacts);
			}

			if(c.User_Portal_Status__c == 'Approved Admin') {
				comContacts.add(0, c);
			} else if(c.Financial_Assessment_Contact__c) {
				comContacts.add(1, c);
			} else {
				comContacts.add(2, c);
			}
		}

		contacts = mapContacts.get(acc.Id);
		if(contacts == null) {
			contacts = mapContacts.get(acc.ParentId);
		} 

		if(contacts != null) {
			for(Contact c : contacts) {
				if(c != null) {
					return c.Id;
				}
			}
		}

		return null;
	}

}