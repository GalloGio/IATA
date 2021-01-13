/****************************************************************************************************
    Created by CGI, Thai 2015-10-22
        Cover code of class "ISO_Country_State_Helper"
****************************************************************************************************/
@isTest(seeAllData=false)
private class ISO_Country_State_Helper_Test {

	static testMethod void test_AllMethod() {
	    TestDataGenerator.generateISOCountryState();
	
	    List<ISO_Country_State_DTO> listCountry = ISO_Country_State_Helper.getCountry_State();
	    System.debug('listCountry::'+listCountry);

	    system.assert(listCountry.size() == 4, 'Size of listCountry: ' + listCountry.size());
	    system.assert(listCountry[0].StateCode.size() == 4, 'Size of listState for Canada: ' + listCountry[0].CountryName + ' - ' + listCountry[0].StateCode.size());
	    system.assert(listCountry[1].StateCode.size() == 0, 'Size of listState for Chile: ' + listCountry[1].CountryName + ' - ' + listCountry[1].StateCode.size());
	    system.assert(listCountry[2].StateCode.size() == 0, 'Size of listState for Mexico: ' + listCountry[2].CountryName + ' - ' + listCountry[2].StateCode.size());
	    system.assert(listCountry[3].StateCode.size() == 6, 'Size of listState for United States: ' + listCountry[3].CountryName + ' - ' + listCountry[3].StateCode.size());
	
	    Map<String, String> mapName_Code = ISO_Country_State_Helper.getCountryCodeFromName(new List<String>{'Canada', 'Not Found'});
	    system.assert(mapName_Code.get('Canada') == 'CA', 'Wrong code for Canada: ' + mapName_Code.get('Canada'));
	    system.assert(mapName_Code.get('Not Found') == null, 'Wrong code for Not Found: ' + mapName_Code.get('Not Found'));
	
	    mapName_Code = ISO_Country_State_Helper.getStateCodeFromName(new Map<String, String>{'Ontario' => 'CA', 'Alaska' => 'CA', 'Not Found' => 'CA'});
	    system.assert(mapName_Code.get('Ontario') == 'CA-ON', 'Wrong code for Ontario: ' + mapName_Code.get('Ontario'));
	    system.assert(mapName_Code.get('Alaska') == null, 'Wrong code for Alaska: ' + mapName_Code.get('Alaska'));
	    system.assert(mapName_Code.get('Not Found') == null, 'Wrong code for Not Found: ' + mapName_Code.get('Not Found'));
	    
	    List<SelectOption> lstCountryOption = ISO_Country_State_Helper.getPicklistISOCountry(listCountry);
	    system.assert(lstCountryOption.size() == 5, 'Size of lstCountryOption: ' + lstCountryOption.size());
	    
	    List<SelectOption> lstStateOption = ISO_Country_State_Helper.getPicklistISOState(listCountry, listCountry[0].CountryId);
	    system.assert(lstStateOption.size() == 5, 'Size of lstStateOption: ' + lstStateOption.size());

	    List<IATA_ISO_Country__c> listISOCountry = ISO_Country_State_Helper.getIsoCountryByIsoCode('CA');
	    system.assert(listISOCountry.size() == 1, 'Size of listISOCountry: ' + listISOCountry.size());
	    listISOCountry = ISO_Country_State_Helper.getIsoCountryById(listISOCountry[0].Id);
	    system.assert(listISOCountry.size() == 1, 'Size of listISOCountry: ' + listISOCountry.size());

	    update new IATA_ISO_Country__c(Id=listISOCountry[0].Id, IEC_Zip_Postal_Code_required__c=true, VAT_Validation_Required__c=true);
	    IATAIsoCountryDAO.resetMapIataIsoCountry();
	    Map<Id, IATA_ISO_Country__c> mapId_Country = ISO_Country_State_Helper.requiredCountriesZipCode();
	    system.assert(mapId_Country.size() == 1, 'Size of mapId_Country: ' + mapId_Country.size());
	    system.assert(ISO_Country_State_Helper.requiredZipCode('CA') == true, 'Postal Code should be required for CA');
	    mapId_Country = ISO_Country_State_Helper.requiredCountriesVAT();
	    system.assert(mapId_Country.size() == 1, 'Size of mapId_Country: ' + mapId_Country.size());
	    system.assert(ISO_Country_State_Helper.requiredVATNumber('CA') == true, 'VAT Number should be required for CA');

	    List<IATA_ISO_State__c> listISOState = ISO_Country_State_Helper.getIsoStateByIsoCode('CA-QC');
	    system.assert(listISOState.size() == 1, 'Size of listISOState: ' + listISOState.size());
	    listISOState = ISO_Country_State_Helper.getIsoStateByIsoCode('CA', 'QC');
	    system.assert(listISOState.size() == 1, 'Size of listISOState: ' + listISOState.size());
	    listISOState = ISO_Country_State_Helper.getIsoStateById(listISOState[0].Id);
	    system.assert(listISOState.size() == 1, 'Size of listISOState: ' + listISOState.size());

	    List<SelectOption> listOption = ISO_Country_State_Helper.getCountriesSelectOption();
	    system.assert(listOption.size() == 5, 'Size of listOption: ' + listOption.size());
	    listOption = ISO_Country_State_Helper.getStatesSelectOption('CA');
	    system.assert(listOption.size() == 5, 'Size of listOption: ' + listOption.size());
	}

} //*** end of class