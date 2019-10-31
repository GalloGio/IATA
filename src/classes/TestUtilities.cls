public class TestUtilities {
	
	private static User[] getUsers(Id profileId, Integer uCount) {
        User[] res = new User[] {};
        for (Integer i = 0; i < uCount; i++) {
            res.add(new User(
				FirstName = 'test',
				LastName = 'test' + Math.abs(Crypto.getRandomInteger()),
				Username = 'test-' + Math.abs(Crypto.getRandomInteger()) + '@weitclick.de.test',
				Email = 'test@weitclick.de.test',
				ProfileId = profileId,
				Alias = (Math.abs(Crypto.getRandomInteger()) + 'testtest').substring(0, 8),
				TimeZoneSidKey = 'Europe/Berlin',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				LanguageLocaleKey = 'en_US',
				License_Cost_Center__c = 'XSMW01JO01'
			));
        }
        return res;
    }

	public static User createAdminUser() {
        Profile[] ps = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User resUser = TestUtilities.getUsers(ps[0].Id, 1)[0];
        insert resUser;
        return resUser;
    }

	public static Accreditation__c[] createAccreditations(integer accreditationsCount, List<Account> accountsList) {
        Accreditation__c[] accreditationsArray = new Accreditation__c[] {};
        for (Integer i = 0; i < accreditationsCount; i++) {
            accreditationsArray.add(new Accreditation__c(
				Related_Account__c = accountsList[i].Id,
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert accreditationsArray;
        return accreditationsArray;
    }

	public static AMS_Inspection__c[] createAMSInspections(integer accreditationsCount, List<AMS_Agency__c> agenciesList, List<Account> accountsList) {
        AMS_Inspection__c[] record = new AMS_Inspection__c[] {};
        for (Integer i = 0; i < accreditationsCount; i++) {
            record.add(new AMS_Inspection__c(
				Agency__c = agenciesList[i].Id,
				Accreditation_Endorsement_Status_code__c = '0',
				Account__c = accountsList[i].Id
			));
        }
        insert record;
        return record;
    }

    public static IATA_ISO_Country__c createCountry() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country = new IATA_ISO_Country__c(Name='United States', ISO_Code__c='US');
        upsert country;
        return country;
    }

	public static AMS_Accreditation_Organization__c[] createAMSAccreditationOrganizations(integer accreditationsCount, List<AMS_Agency__c> agenciesList, List<Account> accountsList) {
        AMS_Accreditation_Organization__c[] record = new AMS_Accreditation_Organization__c[] {};
        for (Integer i = 0; i < accreditationsCount; i++) {
            record.add(new AMS_Accreditation_Organization__c(
				Air_Code__c = 'IATA'
				// Name = 'test' + String.valueOf(i),
				// Agency__c = agenciesList[i].Id,
				// Accreditation_Endorsement_Status_code__c = '0',
				// Account__c = accountsList[i].Id
			));
        }
        insert record;
        return record;
    }

	 public static Account[] createAccounts(integer acCount) {
        Account[] res = new Account[] {};
        for (Integer i = 0; i < acCount; i++) {
            res.add(new Account(
				Name = 'test' + Math.abs(Crypto.getRandomInteger()),
				IATACode__c = 'test123',
				AIMS_ID__c = 'test' + String.valueOf(i),
				Location_Class__c = 'D'
			));
        }
        insert res;
        return res;
    }

	public static Account_Category__c[] createAccountCategoriess(integer acCountCategories) {
        Account_Category__c[] res = new Account_Category__c[] {};
        for (Integer i = 0; i < acCountCategories; i++) {
            res.add(new Account_Category__c(
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert res;
        return res;
    }

	public static GDP_Address__c[] createAddresses(integer addresses) {
        GDP_Address__c[] res = new GDP_Address__c[] {};
        for (Integer i = 0; i < addresses; i++) {
            res.add(new GDP_Address__c(
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert res;
        return res;
    }

	public static Assoc_Affiliation_Membership__c[] createAffiliationMemberships(integer count) {
        Assoc_Affiliation_Membership__c[] res = new Assoc_Affiliation_Membership__c[] {};
        for (Integer i = 0; i < count; i++) {
            res.add(new Assoc_Affiliation_Membership__c(
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert res;
        return res;
    }

	public static Adjacent_Airport__c[] createAdjacentAirports(integer count) {
        Adjacent_Airport__c[] res = new Adjacent_Airport__c[] {};
        for (Integer i = 0; i < count; i++) {
            res.add(new Adjacent_Airport__c(
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert res;
        return res;
    }

	public static Agency_Owner__c[] createAgencyOwners(integer count) {
        Agency_Owner__c[] res = new Agency_Owner__c[] {};
        for (Integer i = 0; i < count; i++) {
            res.add(new Agency_Owner__c(
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert res;
        return res;
    }

	public static GDP_Phone__c[] createGDPPhones(integer count) {
        GDP_Phone__c[] res = new GDP_Phone__c[] {};
        for (Integer i = 0; i < count; i++) {
            res.add(new GDP_Phone__c(
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert res;
        return res;
    }

	public static GDP_Agency_Profile_Specialization__c[] createGDPAgencyProfileSpecializations(integer count) {
        GDP_Agency_Profile_Specialization__c[] res = new GDP_Agency_Profile_Specialization__c[] {};
        for (Integer i = 0; i < count; i++) {
            res.add(new GDP_Agency_Profile_Specialization__c(
				AIMS_ID__c = 'test' + String.valueOf(i)
			));
        }
        insert res;
        return res;
    }
    
	public static AMS_Agency__c[] createAMSAgencies(integer count, IATA_ISO_Country__c country) {
        AMS_Agency__c[] res = new AMS_Agency__c[] {};
        for (Integer i = 0; i < count; i++) {
            res.add(new AMS_Agency__c(
				Agency_Status__c = 'Terminated',
				Legacy_system__c = '\'AIMS%\'',
                Country__c = country.Id
			));
        }
        insert res;
        return res;
    }
}