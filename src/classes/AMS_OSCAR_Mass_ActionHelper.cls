public class AMS_OSCAR_Mass_ActionHelper {
	
	public static void process_PCI(AMS_OSCAR__c oscar) {
		Savepoint sp = Database.setSavepoint();
		try {
		oscar.STEP6__c = 'Passed';
		oscar.Is_PCI_compliant__c = 'No';
		oscar.ANG_PCI_compliance_expiry_date__c = null;
		oscar.Status__c = 'Closed';
		update oscar;

			Account acc = new Account();
			acc.Id = oscar.Account__c;
			acc.ANG_PCI_compliance_expiry_date__c = null;
			acc.Is_PCI_compliant__c = 'No';
			acc.PCI_DSS_Compliant__c= null;
			update acc;
		} catch(Exception e) {
			Database.rollback(sp);
			throw e;
		}		
	}

	public static void create_VR(Account acc, Map<String,Object> params) {
		Savepoint sp = Database.setSavepoint();
		try {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;  
        List<IATA_ISO_Country__c> countries = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<Id> {acc.IATA_ISO_Country__c});

        /*** Create Case ***/
		Case cse = new Case();
		cse.AccountId = acc.Id;
		cse.Account_Concerned__c = acc.Id;
        if(!countries.isEmpty()) {
            IATA_ISO_Country__c country = countries[0];
            cse.BSPCountry__c = country.Case_BSP_Country__c;
            cse.Region__c = country.Region__c;
        }
		cse.CaseArea__c = AMS_UTILS.CASE_AREA_ACCREDITATION_PROCESS;
		cse.Reason1__c = AMS_UTILS.CASE_REASON_VR_CLOSURE;
		cse.Origin ='IATA Internal User';		
		cse.ContactId = getCaseContact(acc);
		cse.RecordTypeId = schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
        cse.Status = 'Open';
		cse.setOptions(dmo);
        insert cse;

        cse = [SELECT Id, CaseNumber, OwnerId FROM Case WHERE Id = :cse.Id];

		/*** Create OSCAR ***/
		AMS_OSCAR__c oscar = new AMS_OSCAR__c();
        oscar.Name = cse.CaseNumber;
        oscar.OwnerId = cse.OwnerId;
		oscar.Account__c = acc.Id;
		Set<String> vr_ca_classes = new Set<String> {'G', 'M', 'X', 'T'};
		if(vr_ca_classes.contains(oscar.Location_Class__c)) {
			oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
		} else {
			oscar.Process__c = AMS_Utils.VOLRELINQUISH;
		}		
		oscar.RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('VOLUNTARY RELINQUISHMENT').getRecordTypeId();
		oscar.Status__c = 'Open';
        oscar.Change_Effective_as_of__c = Date.today();
        oscar.Form_Effective_Date__c = Date.valueOf(((String) params.get('Form_Effective_Date__c')));
		oscar.Financial_Security_expiry_date__c = Date.valueOf(((String) params.get('Financial_Security_expiry_date__c')));
		insert oscar;

		cse.OSCAR__c = oscar.Id;
        update cse;
		} catch(Exception e) {
			Database.rollback(sp);
			throw e;
		}
	}

    public static void create_Certificate(Account acc) {
		Savepoint sp = Database.setSavepoint();
		try {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;  
        List<IATA_ISO_Country__c> countries = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<Id> {acc.IATA_ISO_Country__c});
        /** Create Case **/
		Case cse = new Case();
        cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        cse.Origin = 'IATA Internal User';
        cse.CaseArea__c = 'Accreditation Products';
        cse.Reason1__c = 'PAX/CARGO Certificate';
		cse.AccountId = acc.Id;
		cse.Account_Concerned__c = acc.Id;
		cse.ContactId = getCaseContact(acc);
        cse.Status = 'Open';
        if(!countries.isEmpty()) {
            IATA_ISO_Country__c country = countries[0];
            cse.BSPCountry__c = country.Case_BSP_Country__c;
            cse.Region__c = country.Region__c;
        }
        cse.setOptions(dmo);
		insert cse;

        cse = [SELECT Id, CaseNumber, OwnerId FROM Case WHERE Id = :cse.Id];

        /** Create OSCAR **/
        AMS_OSCAR__c oscar = new AMS_OSCAR__c();
        oscar.Process__c = 'CER.1.0';
		oscar.Account__c = acc.Id;
		oscar.Name = cse.CaseNumber;
        oscar.OwnerId = cse.OwnerId;
        oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATE');
        oscar.Status__c = 'Open';
        insert oscar;

        cse.OSCAR__c = oscar.Id;
        update cse;
		} catch(Exception e) {
			Database.rollback(sp);
			throw e;
		}
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