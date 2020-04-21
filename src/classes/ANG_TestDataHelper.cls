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
		return insertBspAndIsoCountry(countryInformation, true, true, false);
	}

	public static IATA_ISO_Country__c insertBspAndIsoCountry(
		ANG_TestDataHelper.CountryInformation countryInformation, Boolean newGen, Boolean multicountry)
	{
		return insertBspAndIsoCountry(countryInformation, newGen, multicountry, false);
	}

	public static IATA_ISO_Country__c insertBspAndIsoCountry(
		ANG_TestDataHelper.CountryInformation countryInformation, Boolean newGen, Boolean multicountry, Boolean forRisk)
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
		if (forRisk) {
			country.AIMS_Area_ID__c = '1';
			country.Enable_Risk_Change_Codes__c = true;
		}
		insert country;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - insertBspAndIsoCountry] Created country: ' + country);

		return country;
	}

	public static Account insertMulticountryAccount(String name, Id parent, Id topParent, String locationType, IATA_ISO_Country__c isoCountry,
		String iataCode)
	{
		Account acct = createMulticountryAccount(name, parent, topParent, locationType, isoCountry, iataCode);
		insert acct;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - insertMulticountryAccount] Inserted account: ' + acct);
		return acct;
	}

	public static Account createMulticountryAccount(String name, Id parent, Id topParent, String locationType, IATA_ISO_Country__c isoCountry,
		String iataCode)
	{
		Account acct = createBasicAccount(true);
		acct.Name = name;
		acct.ParentId = parent;
		acct.Top_Parent__c = topParent;
		acct.Location_Type__c = locationType;
		acct.IATA_ISO_Country__c = isoCountry.Id;
		acct.IATACode__c = iataCode;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - createMulticountryAccount] Created account: ' + acct);
		return acct;
	}

	public static Account insertStandardAccount(String name, Id parent, String locationType, IATA_ISO_Country__c isoCountry,
		String iataCode)
	{
		Account acct = createStandardAccount(name, parent, locationType, isoCountry, iataCode);
		insert acct;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - insertStandardAccount] Inserted account: ' + acct);
		return acct;
	}

	public static Account createStandardAccount(String name, Id parent, String locationType, IATA_ISO_Country__c isoCountry,
		String iataCode)
	{
		Account acct = createBasicAccount(false);
		acct.Name = name;
		acct.ParentId = parent;
		acct.Top_Parent__c = parent;
		acct.Location_Type__c = locationType;
		acct.IATA_ISO_Country__c = isoCountry.Id;
		acct.IATACode__c = iataCode;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - createStandardAccount] Created account: ' + acct);
		return acct;
	}

	public static Account insertAccreditedMulticountryAccount(String name, Id parent, Id topParent, String locationType, IATA_ISO_Country__c isoCountry,
		String iataCode)
	{
		Account acct = createBasicAccount(true);
		acct.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		acct.Name = name;
		acct.ParentId = parent;
		acct.Top_Parent__c = topParent;
		acct.Location_Type__c = locationType;
		acct.IATA_ISO_Country__c = isoCountry.Id;
		acct.IATACode__c = iataCode;
		acct.Location_Class__c = 'P';
		acct.Remittance_frequency__c = 'M';
		acct.BillingCountry = isoCountry.Name;
		insert acct;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - insertAccreditedMulticountryAccount] Created account: ' + acct);

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
		acct.Type = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
		return acct;
	}

	public static void setAccountGenericAddress(Account acct) {
		acct.BillingStreet = 'some street';
		acct.BillingCity = 'some city';
	}

	public static void insertHierarchy(List<Account> accounts) {
		if (accounts.size() <= 1)
			return;
		
		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c();
		h.Hierarchy_Name__c = 'Multicountry Hierarchy';
		h.Main_Account__c = accounts.get(0).Top_Parent__c == null ? accounts.get(0).Id : accounts.get(0).Top_Parent__c;
		insert h;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - insertHierarchy] Created hierarchy: ' + h);

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

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - insertHierarchy] Created relations: ' + rels);
	}

	public static Contact insertContact(Id accountId) {
		return insertContact(accountId, false);
	}
	
	public static Contact insertContact(Id accountId, Boolean financialContact) {
		return insertContact(accountId, financialContact, null);
	}

	public static Contact insertContact(Id accountId, Boolean financialContact, String contactType) {
		
		Contact cont = new Contact(
			AccountId = accountId,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'contact_for_' + accountId + Math.random() + '@test.com',
			Financial_Assessment_Contact__c = financialContact,
			User_Portal_Status__c = contactType
		);
		insert cont;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_TestDataHelper - insertContact] Created contact: ' + cont);

		return cont;
	}

	public static AMS_Account_Role__c insertAccountOwner(Id accountId) {
		AMS_Account_Role__c owner = new AMS_Account_Role__c();
		owner.RecordTypeId = AMS_Utils.AccountRoleOwnershipRT;
		owner.Account__c = accountId;
		owner.Duty__c = 'number 2';
		owner.Employee_Name__c = 'name for ' + accountId;
		owner.Hours__c = '6';
		owner.IsManager__c = true;
		owner.Percentage__c = 100;
		owner.Position__c = 'G';
		owner.Owner_Name__c = 'name for ' + accountId;
		owner.Legacy_External_Id__c = 'some ext-id';
		owner.Owner_Account__c = null;
		owner.Contact__c = null;

		insert owner;
		return owner;
	}

	public static ResultObjects insertOscarAndRelatedEntities(Account account, Id contactId, String oscarProcessType, Id oscarRecordType) {
		return insertOscarAndRelatedEntities(account, contactId, oscarProcessType, oscarRecordType, null, null);
	}

	public static ResultObjects insertOscarAndRelatedEntities(Account account, Id contactId, String oscarProcessType, Id oscarRecordType, Id paxRecordType, String accreditationType) {
		AMS_OSCAR__c oscar = insertOscar(account.Id, oscarProcessType, oscarRecordType);
		Case oscarCase = insertOscarCase(oscar.Id, account.Id, contactId);
		AMS_Pax_Accreditation_Form__c staging = null;
		if (paxRecordType != null)
			staging = insertPax(paxRecordType, account, oscarCase.Id, accreditationType);

		oscar.AMS_Online_Accreditation__c = staging == null ? null : staging.Id;
		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		update oscar;

		ResultObjects objs = new ResultObjects();
		objs.oscar = oscar;
		objs.oscarCase = oscarCase;
		objs.oscarStagingArea = staging;
		return objs;
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

	private static AMS_Pax_Accreditation_Form__c insertPax(Id paxRecordType, Account acct, Id oscarCaseId, String accreditationType) {
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
		staging.ANG_Accreditation_type__c = accreditationType;
		staging.ISSP_AMS_GDS_with_signed_contract__c = 'Amadeus';
		insert staging;

		return staging;
	}

	public static void insertProcessDetails(Id oscarId, Id accountId, String processType) {
		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', processType);
		insert new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscarId, Account__c = accountId);
	}

	public static void insertGenericAttachmentToOscar(Id oscarCaseId) {
		Attachment att = new Attachment();
		att.Name = 'Certificates '+oscarCaseId+'.pdf';
		att.Body = Blob.valueOf('Test content');
		att.ParentId = oscarCaseId;
		insert att;
	}

	public static void insertGenericOscarContact(Id paxId, Id accountId) {
		Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
		insert new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100, AMS_Pax_Accreditation_Form__c = paxId,
			Company__c = accountId, First_name__c = 'NameToUse1', Last_name__c = 'Last1', Job_title__c = 'ABC1', Mobile__c = '+4112345671',
			Phone__c = '3424322341', Email__c = 'oscar_contact_for_' + paxId + '@email1.com', RecordTypeId = personAccreditationRT);
	}

	public static void setOscarMainAccount(AMS_OSCAR__c oscar, Id mainAccount) {
		oscar.New_parent__c = mainAccount;
	}

	public static void setOscarTypeOfChange(AMS_OSCAR__c oscar, String typeOfChange) {
		oscar.ANG_Type_Of_Change__c = typeOfChange;
	}

	public static void setOscarStepPassed(AMS_OSCAR__c oscar, String step) {
		switch on step.toUpperCase() {
			when 'STEP6' {
				setOscarSanityCheckPassed_Step6(oscar);
			}
			when 'STEP30' {
				setOscarProcessSuspensionPassed_Step30(oscar);
			}
			when 'STEP31' {
				setOscarProcessTerminationPassed_Step31(oscar);
			}
			when else {
				System.assert(false, 'Invalid step');
			}
		}
	}

	public static void setOscarSanityCheckPassed_Step6(AMS_OSCAR__c oscar) {
		oscar.STEP6__c = AMS_Utils.PASSED;
		
		if (isOscarVoluntaryRelinquishment(oscar)) {
			oscar.Form_Effective_Date__c = Date.today();
			oscar.Financial_Security_expiry_date__c = Date.today();
		} else {
			oscar.Change_effective_as_of__c = System.today();
			oscar.Is_PCI_compliant__c = 'Yes';
			oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		}
	}

	public static void setOscarProcessSuspensionPassed_Step30(AMS_OSCAR__c oscar) {
		oscar.STEP30__c = AMS_Utils.PASSED;
		oscar.Suspend_in_BSPLink_CASSLink__c = true;
	}

	public static void setOscarProcessTerminationPassed_Step31(AMS_OSCAR__c oscar) {
		oscar.STEP31__c = AMS_Utils.PASSED;
		//oscar.Release_FS_if_applicable__c = true;
	}

	public static void appendOscarHierarchyScenario(AMS_OSCAR__c oscar, String scenario) {
		oscar.Change_of_Hierarchy_Scenario__c = (String.isNotBlank(oscar.Change_of_Hierarchy_Scenario__c) ? ';' : '') + scenario;
	}

	private static Boolean isOscarVoluntaryRelinquishment(AMS_OSCAR__c oscar) {
		return oscar.RecordTypeId == AMS_Utils.RECTYPE_VOLUNTARYRELINQUISHMENT;
	}

	public static Case insertIfapCase(Id contactId, Id accountId, String year, Date deadline, String finReviewType) {
		Case c = new Case(
			ContactId = contactId,
			AccountId = accountId,
			Subject = 'Financial Review',
			Description = 'Financial Review - ' + year,
			Status = 'Agent Notified',
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = year,
			Deadline_Date__c = deadline,
			Financial_Review_Type__c = finReviewType
		);
		insert c;
		return c;
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

	public class ResultObjects {
		public AMS_OSCAR__c oscar;
		public Case oscarCase;
		public AMS_Pax_Accreditation_Form__c oscarStagingArea;
	}
}