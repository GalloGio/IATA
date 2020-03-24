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

	public static Account insertStandardAccount(
		String name, Id parent, String locationType, IATA_ISO_Country__c isoCountry, String iataCode)
	{
		Account acct = createBasicAccount();
		acct.Name = name;
		acct.ParentId = parent;
		acct.Location_Type__c = locationType;
		acct.IATA_ISO_Country__c = isoCountry.Id;
		acct.IATACode__c = iataCode;
		insert acct;

		return acct;
	}

	private static Account createBasicAccount()
	{
		Account acct = new Account();
		acct.Location_Class__c = 'P';
		acct.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		acct.Status__c = AMS_Utils.ACC_S9_APPROVED;
		acct.ANG_HE_RiskStatus__c = ANG_Risk_Helper.RISK_STATUS_B;
		acct.Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY;
		acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
		acct.ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED;
		acct.ANG_HE_CashCondition__c = false;
		return acct;
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
