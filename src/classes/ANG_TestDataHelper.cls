@isTest
public class ANG_TestDataHelper
{
	public static final Map<String, CountryInformation> COUNTRY_INFORMATION = new Map<String, CountryInformation>
	{
		'PT' => new CountryInformation('Portugal', 'PT', 'BSP-PT'),
		'GB' => new CountryInformation('United Kingdom', 'GB', 'BSP-GB'),
		'FR' => new CountryInformation('France', 'FR', 'BSP-FR')
	};

	public static IATA_ISO_Country__c insertBspAndIsoCountry(ANG_TestDataHelper.CountryInformation countryInformation)
	{
		return insertBspAndIsoCountry(countryInformation, true, true);
	}

	public static IATA_ISO_Country__c insertBspAndIsoCountry(
		ANG_TestDataHelper.CountryInformation countryInformation, Boolean newGen, Boolean multicountry)
	{
		AMS_Settlement_System__c bsp = new AMS_Settlement_System__c(
			Name = countryInformation.bspName,
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);
		insert bsp;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = countryInformation.name;
		country.ISO_Code__c = countryInformation.code;
		country.AMS_Settlement_System__c = bsp.Id;
		country.ANG_Enable_NewGen__c = newGen;
		country.Multicountry_Enabled__c = multicountry;
		insert country;

		return country;
	}

	public static Account insertMulticountryAccount(
		String name, Id parent, String locationType, IATA_ISO_Country__c isoCountry, String iataCode)
	{
		Account acct = createBasicAccount(true);
		acct.Name = name;
		acct.ParentId = parent;
		acct.Location_Type__c = locationType;
		acct.IATA_ISO_Country__c = isoCountry.Id;
		acct.IATACode__c = iataCode;
		insert acct;

		return acct;
	}

	public static Account insertStandardAccount(
		String name, Id parent, String locationType, IATA_ISO_Country__c isoCountry, String iataCode)
	{
		Account acct = createBasicAccount(false);
		acct.Name = name;
		acct.ParentId = parent;
		acct.Location_Type__c = locationType;
		acct.IATA_ISO_Country__c = isoCountry.Id;
		acct.IATACode__c = iataCode;
		insert acct;

		return acct;
	}

	private static Account createBasicAccount(boolean isMulticountry)
	{
		Account acct = new Account();
		acct.Location_Class__c = 'P';
		acct.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		acct.Status__c = AMS_Utils.ACC_S9_APPROVED;
		acct.ANG_HE_RiskStatus__c = ANG_Risk_Helper.RISK_STATUS_B;
		acct.Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY;
		acct.ANG_Accreditation_Model__c = isMulticountry ? AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY : AMS_Utils.ACCREDITATIONMODEL_CASH;
		acct.ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED;
		acct.ANG_HE_CashCondition__c = false;
		return acct;
	}

	public static void insertHierarchy(List<Account> accounts) {
		if (accounts.size() <= 1)
			return;
		
		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c();
		h.Hierarchy_Name__c = 'Multicountry Hierarchy';
		h.Main_Account__c = accounts.get(0).Top_Parent__c == null ? accounts.get(0).Id : accounts.get(0).Top_Parent__c;
		insert h;

		List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
		for (Account acct : accounts) {
			if (acct.ParentId == null)
				continue;
			
			AMS_Agencies_relationhip__c ar = new AMS_Agencies_relationhip__c();
			ar.Hierarchy__c = h.Id;
			ar.Parent_Account__c = acct.ParentId;
			ar.Child_Account__c = acct.Id;
			ar.Is_Newgen_Relation__c = true;
			rels.add(ar);
		}
		insert rels;
	}

	public static Contact insertContact(Id accountId) {
		Contact cont = new Contact(
			AccountId = accountId,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'fwuhxeiufxhmrfefdsiyfsimo@test.com',
			Financial_Assessment_Contact__c = false
		);
		insert cont;

		return cont;
	}

	public static AMS_OSCAR__c insertOscarAndRelatedEntities(Account account, Id contactId, String oscarProcessType, Id oscarRecordType, Id paxRecordType) {
		AMS_OSCAR__c oscar = insertOscar(account.Id, oscarProcessType, oscarRecordType);
		Case oscarCase = insertOscarCase(oscar.Id, account.Id, contactId);
		AMS_Pax_Accreditation_Form__c staging = insertPax(paxRecordType, account, oscarCase.Id);

		oscar.AMS_Online_Accreditation__c = staging.Id;
		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		update oscar;

		return oscar;
	}

	private static AMS_OSCAR__c insertOscar(Id accountId, String oscarProcessType, Id oscarRecordType) {
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountId,
			Process__c = oscarProcessType,
			RecordTypeId = oscarRecordType,
			Status__c = 'Open'
		);
		insert oscar;

		return oscar;
	}

	private static Case insertOscarCase(Id oscarId, Id accountId, Id contactId) {
		Case oscarCase = new Case();
		oscarCase.Oscar__c = oscarId;
		oscarCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
		oscarCase.AccountId = accountId;
		oscarCase.ContactId = contactId;
		oscarCase.reason1__c = 'Accreditation Type';
		insert oscarCase;

		return oscarCase;
	}

	private static AMS_Pax_Accreditation_Form__c insertPax(Id paxRecordType, Account acct, Id oscarCaseId) {
		AMS_Pax_Accreditation_Form__c staging = new AMS_Pax_Accreditation_Form__c();
		staging.RecordTypeId = paxRecordType;
		staging.Account_Name__c = acct.Name;
		staging.ISSP_AMS_Legal_Status__c = 'Association';
		staging.Branch_Office_Country__c = acct.IATA_ISO_Country__c;
		staging.Branch_Office_Street_name_number__c = 'sdfsdf';
		staging.Branch_Office_City__c = 'sdfsdfdf';
		staging.IATA_ISO_State__c = acct.Iso_State__c;
		staging.Branch_Office_Email__c = 'sdfsdfgdg@f3434.com';
		staging.Branch_Office_Phone__c = '123123123';
		staging.ISSP_AMS_Premises_located_at_airport__c = 'No';
		staging.Abbreviated_name__c = 'Multicountry ';
		staging.Abbreviated_Address__c = 'sdfsdf';
		staging.Remittance_frequency__c = 'M';
		staging.Solicitation_Flag__c = false;
		staging.Location_Class__c = acct.Location_Class__c;
		staging.Location_Type__c = acct.Location_Type__c;
		staging.SAAM_Case__c = oscarCaseId;
		staging.ANG_Accreditation_type__c = 'Cash';
		staging.ISSP_AMS_GDS_with_signed_contract__c = 'Amadeus';
		insert staging;

		return staging;
	}

	public class CountryInformation
	{
		public String name;
		public String code;
		public String bspName;
		public CountryInformation(String name, String code, String bspName)
		{
			this.name = name;
			this.code = code;
			this.bspName = bspName;
		}
	}
}
