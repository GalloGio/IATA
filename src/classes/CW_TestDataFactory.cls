@isTest
public class CW_TestDataFactory {
	public static IATA_ISO_Country__c newISOCountry() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'Spain', ISO_Code_Numeric__c = 25, ISO_Code__c = '22');
		return country;
	}

	public static Airport_Detail__c newAirport(Id countryId, Id accId) {
		Airport_Detail__c airport = new Airport_Detail__c(Code__c = 'MAD', City__c = 'Madrid', IATA_ISO_Country__c = countryId, Account__c = accId);
		return airport;
	}

	public static ICG_Certification__c newCertification() {
		ICG_Certification__c cert = new ICG_Certification__c();
		cert.Name = 'CEIV Live Animals';
		cert.Certification_Type__c = 'Assessments';
		cert.Image_Filename__c = 'sfoc_stamp.svg';
		cert.Is_Visible__c = true;
		return cert;
	}

	public static User testUser(string fstname, string lstName, String uniqueName, string orgId, string profileId, string contactId) {
		return new User(firstname = fstname, lastName = lstName, email = uniqueName + '@test' + orgId + '.org', Username = uniqueName + '@test' + orgId + '.org', EmailEncodingKey = 'ISO-8859-1', Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = profileId, contactId = contactId);
	}

	public static Account testAccount(String countryId) {
		return new Account(Name = 'Account01', IATA_ISO_Country__c = countryId, Business_City_Name__c = 'Madrid');
	}

	public static Contact testContact(String accountId) {
		return new Contact(FirstName = 'Test', LastName = 'Test', Email = 'Test@Test.com', AccountId = accountId);
	}

	public static Account_Role__c testAccountRole(String accountId, String name) {
		return new Account_Role__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default'), Account__c = accountId, Account_Role_Name__c = name, Functional_Role__c = 'One Source');
	}

	public static ICG_Account_Role_Detail__c testICGAccountRoleDetail(String acctRoleId, Airport_Detail__c airport) {
		return new ICG_Account_Role_Detail__c(Airmail__c = true, Account_Role__c = acctRoleId, IATA_ISO_Country__c = airport.IATA_ISO_Country__c, Nearest_Airport__c = airport.Id, Status__c = 'Approved', Name = 'Test', Available_Languages__c = 'ESP;GER', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Airline'));
	}

	public static Account_Contact_Role__c testAccountContactRole(String acctRolId, String acctId, String contactId) {
		return new Account_Contact_Role__c(Account_Role__c = acctRolId, Account__c = acctId, Contact__c = contactId, Functional_Role__c = 'One Source', Service_Rendered__c = 'TIP');
	}

	public static ICG_Contact_Role_Detail__c testICGContactRoleDetail(String acrId, String ardId) {
		return new ICG_Contact_Role_Detail__c(Account_Contact_Role__c = acrId, ICG_Account_Role_Detail__c = ardId, ICG_Role__c = 'Facility Manager', Status__c = 'Approved');
	}

	public static Account createAirline(String countryId, string recordTypeId, string name, string airlineDesignator, string icaoDesignator) {
		Account target = testAccount(countryId);
		target.RecordTypeId = recordTypeId;
		target.Name = name;
		target.Airline_designator__c = airlineDesignator;
		target.ICAO_designator__c = icaoDesignator;

		return target; //output
	}

	public static Account_Role_Detail_Capability__c createAccountRoleDetailCapability(string equipment, string category, string recordTypeId) {
		Account_Role_Detail_Capability__c ardCap = new Account_Role_Detail_Capability__c();
		ardCap.Equipment__c = equipment != null ? equipment : 'Beneficial_Insects_Bees';
		ardCap.Category__c = category != null ? category : 'Live_Animals_Capacities_1';
		ardCap.RecordTypeId = recordTypeId != null ? recordTypeId : RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role_Detail_Capability__c', 'Live_Animals_Capacities');
		return ardCap;
	}

	public static ICG_Account_Role_Capability_Assignment__c createIcgAccountRoleCapabilityAssignment(string accountroledetailId, string ardCapabilityId) {
		ICG_Account_Role_Capability_Assignment__c assignment = new ICG_Account_Role_Capability_Assignment__c();
		assignment.ICG_Account_Role_Detail__c = accountroledetailId;
		assignment.Account_Role_Detail_Capability__c = ardCapabilityId;
		return assignment;
	}

	public static ICG_Capability_Assignment_Group__c createIcgCapabilityAssignmentGroupCertification(string accountroledetailId, string certifId) {
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		return new ICG_Capability_Assignment_Group__c(RecordTypeId = rtId, ICG_Account_Role_Detail__c = accountroledetailId, ICG_Certification__c = certifId, Expiration_Date__c = Date.today().addMonths(6), Issue_Date__c = Date.today());
	}

	public static List<RecordType> getRecTypes(String obj) {
		return RecordTypeSingleton.getInstance().getRecordTypesBySObject(obj);
	}

	public static RecordType getRecTypesNotStandard() {
		List<RecordType> recTypes = CW_TestDataFactory.getRecTypes('Account');
		RecordType selectedRecordType;

		while (selectedRecordType == null) {
			RecordType selectRecordType = recTypes[Integer.valueof((Math.random() * 1))];
			if (!selectRecordType.DeveloperName.equals('Standard_Account')) {
				selectedRecordType = selectRecordType;
			}
		}
		return selectedRecordType;
	}
}