/********************************************************************************
 * @ Last Modified By: Bhargavi Rayavarapu
 * @ Last Modified Date: 2016-04-13
 * @ Description : Use this class to add and  use any Methods that initialize the test data for E-broadcast tests classes.
 * *******************************************************************************/
public class EBC_TestUtility
{
	public static Account createSampleAccount()
	{
		return IECTestUtil.createSampleAccount('');
	}
	public static GDP_Products_Account_View__c createSampleGDPAccount(string sName, string sAgencyCode)
	{
		return IECTestUtil.createSampleGDPAccount(sName, sAgencyCode);
	}
	public static IATA_ISO_Country__c CreateSampleIATAISOCountry()
	{
		return IECTestUtil.CreateSampleIATAISOCountry();
	}
	public static IATA_ISO_State__c CreateSampleIATAISOState(IATA_ISO_Country__c country)
	{
		return IECTestUtil.CreateSampleIATAISOState(country);
	}
	public static GDP_Geo_Detail__c CreateSampleGDPGeoDetail(IATA_ISO_Country__c country)
	{
		return IECTestUtil.CreateSampleGDPGeoDetail(country);
	}
	public static GDP_Address__c CreateSampleGDPAddress(GDP_Products_Account_View__c oAccount, IATA_ISO_Country__c oISOCountry, IATA_ISO_State__c oISOState, GDP_Geo_Detail__c oGEODetail)
	{
		return IECTestUtil.CreateSampleGDPAddress(oAccount,oISOCountry,oISOState,oGEODetail);
	}
	public static Accreditation__c CreateSampleAccreditation(Account oAccount, GDP_Products_Account_View__c oGDPAccount)
	{
		return IECTestUtil.CreateSampleAccreditation(oAccount, oGDPAccount, 'Live');
	}
	public static GDP_Reference_Table__c createSampleGDPReferenceTableEntry(string sCode, string sDescription) {
		return IECTestUtil.createSampleGDPReferenceTableEntry(sCode,sDescription);
	}
}
