public class ams2gdp_BusinessLogic
{
	/**
	 * This function format a List of Account records into a list of GDP_Products_Account_View__c records
	 * There is a 1:1 relation between Account and GDP Product Account View. The mapping key is then the Account Id
	 * @param  List<Account> accounts
	 * @return List<GDP_Products_Account_View__c>
	 * @author: David Daboué<david.daboue@cgi.com>
	 */
	public static List<GDP_Products_Account_View__c> formatAccount2ProductAccountView(List<Account> accounts)
	{
		List<GDP_Products_Account_View__c> result = new List<GDP_Products_Account_View__c>();

		Set<String> location_types = new Set<String>();
		Set<String> company_types = new Set<String>();
		Set<String> parentIds = new Set<String>();
		Set<String> accountIds = new Set<String>();

		Set<String> accreditation_models = new Set<String>();
		Set<String> risk_status = new Set<String>();
		Set<String> remittance_frequencies = new Set<String>();
		Set<String> easy_pay_statuses = new Set<String>();

		for(Account account : accounts)
		{
			accountIds.add(account.Id);
			if(String.isNotBlank(account.Location_Type__c)) location_types.add(account.Location_Type__c);
			if(String.isNotBlank(account.Company_Type__c)) company_types.add(account.Company_Type__c);
			if(account.ParentId != null) parentIds.add(account.ParentId);

			accreditation_models.add(account.ANG_Accreditation_Model__c);
			// risk_status.add(account.ANG_RiskStatus__c);
			// split the multi select to two target fields
			if(account.Remittance_frequency__c != null) {
				remittance_frequencies.add(account.Remittance_frequency__c.split(';')[0]);
				if(account.Remittance_frequency__c.indexOf(';') != -1) remittance_frequencies.add(account.Remittance_frequency__c.split(';')[1]);
			}
			easy_pay_statuses.add(account.ANG_IEP_Status_FF__c);
		}

		Map<String, GDP_Reference_Table__c> tbl_location_types 	= ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(location_types, 'LOCTYP');
		Map<String, GDP_Reference_Table__c> tbl_company_types 	= ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(company_types, 'LGLTYP');

		Map<String, String> parentMap  = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(parentIds);
		Map<String, String> addressMap = ams2gdp_Selector.getGDP_AddressByAccount(accountIds);
		Map<String, String> phoneMap   = ams2gdp_Selector.getGDP_PhoneByAccount(accountIds);
		Map<String, String> accredMap  = ams2gdp_Selector.getAccreditationByAccount(accountIds);
		Map<String, String> appointmentMap  = ams2gdp_Selector.getAppointmentByAccount(accountIds);


	// NewGen
		Map<String, GDP_Reference_Table__c> accreditation_model_references 	= ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(accreditation_models, 'ACCTYP');
		// Map<String, GDP_Reference_Table__c> risk_status_references 		= ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(risk_status, 'RISKSTAT');
		Map<String, GDP_Reference_Table__c> remittance_frequency_references = ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(remittance_frequencies, 'REMITFREQ');
		Map<String, GDP_Reference_Table__c> easy_pay_status_references 		= ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(easy_pay_statuses, 'EPSTAT');

		for(Account account : accounts)
		{
			//-- Mapping Key
			String mapping_key = account.Id;

			// Wrap the Legal Name & Trade Name
			List<String> legalNameParts = ams2gdp_Utils.WrapText(account.Name, 32);
			List<String> tradeNameParts = ams2gdp_Utils.WrapText(account.TradeName__c, 32);

			String airlineCode = account.Airline_Code__c;
			if(account.Location_Class__c == 'M' && appointmentMap.containsKey(account.Id)) airlineCode = appointmentMap.get(account.Id);



			// split the multi select to two target fields
			String remittance1 = '';
			String remittance2 = '';
			if(account.Remittance_frequency__c != null) {
				remittance1 = account.Remittance_frequency__c.split(';')[0];
				if(account.Remittance_frequency__c.indexOf(';') != -1) remittance2 = account.Remittance_frequency__c.split(';')[1];
			}
			// code PCI Complicance to single char - or empty
			String PCICompliance = '';
			if(account.Is_PCI_compliant__c == 'Yes') {PCICompliance = 'Y';}
			else if(account.Is_PCI_compliant__c == 'No') {PCICompliance = 'N';}
			else if(account.Is_PCI_compliant__c == 'Nil CC') {PCICompliance = 'X';}
			else if(account.Is_PCI_compliant__c == 'Corporate Card') {PCICompliance = 'C';}

			result.add(new GDP_Products_Account_View__c(AMS_GDP_Key__c  = mapping_key
				, Parent_GDP_Account_View__c = (account.ParentId !=null)? parentMap.get(account.ParentId): null
				, Related_GDP_Address__c = addressMap.get(account.Id)
				, Related_Accreditation_Class__c = accredMap.get(account.Id)
				, Related_Main_Phone__c = phoneMap.get(account.Id)
				, Name = account.Name.left(80)
				, Airline_Code__c =  airlineCode
				, BSP_CASS_Code__c =  account.BSP_CASS_Code__c
				, CASS_Number__c =  account.CASS_Number__c
				, Check_Digit__c =   account.Check_Digit__c
				, Email_Address__c =  account.Email__c
				, GDP_Opt_In__c =  account.GDP_Opt_In__c
				, IATA_Code__c =  (String.isNotBlank(account.IATACode__c)) ? (account.IATACode__c.left(1).equalsIgnoreCase('x') ? account.IATACode__c.left(8) : account.IATACode__c.left(7)) : null
				, Incorporation_Type__c =  (tbl_company_types.containsKey(account.Company_Type__c)) ? tbl_company_types.get(account.Company_Type__c).Id : account.Incorporation_Type__c
				, Agency_Short_Name__c  = account.Short_Name__c
 				, Legal_Name_1__c =   (legalNameParts.size() > 0) ? legalNameParts.get(0) : null
				, Legal_Name_2__c =   (legalNameParts.size() > 1) ? legalNameParts.get(1) : null
				, Legal_Name_3__c =   (legalNameParts.size() > 2) ? legalNameParts.get(2) : null
				, License_Number__c =   account.License_Number__c
				, Location_Type__c =  (tbl_location_types.containsKey(account.Location_Type__c)) ? tbl_location_types.get(account.Location_Type__c).Id : account.GDP_Location_Type__c
				, Manager_First_Name__c =   account.Manager_First_Name__c
				, Manager_Last_Name__c =   account.Manager_Last_Name__c
				, Passenger_And_Cargo__c =   account.PAX_Cargo__c
				, Preferred_Language__c =   account.Preferred_Language__c
				, Tax_ID_1__c =  (String.isNotBlank(account.VAT_Number__c))? account.VAT_Number__c.left(20):null
				, Tax_ID_2__c =  (String.isNotBlank(account.VAT_Number_2__c))? account.VAT_Number_2__c.left(20):null
				, Ticketing_Agent_First_Name__c =   account.Ticketing_Agent_First_Name__c
				, Ticketing_Agent_Last_Name__c =   account.Ticketing_Agent_Last_Name__c
				, Trading_Name_1__c =   (tradeNameParts.size() > 0) ? tradeNameParts.get(0) : null
				, Trading_Name_2__c =   (tradeNameParts.size() > 1) ? tradeNameParts.get(1) : null
				, TTY__c =  account.TTY__c
				, Website__c =  account.Website
				, WebStar_ID__c = (String.isNotBlank(account.WebStar_ID__c))? account.WebStar_ID__c+'GDP':null
				, AIMS_ID__c = (String.isNotBlank(account.AIMS_ID__c))? account.AIMS_ID__c+'GDP':null
				, Parent_Account_WebStar_ID__c = (account.ParentId != null && String.isNotBlank(account.Parent.WebStar_ID__c)) ? account.Parent.WebStar_ID__c : null
				, Parent_Account_AIMS_ID__c = (account.ParentId != null && String.isNotBlank(account.Parent.AIMS_ID__c)) ? account.Parent.AIMS_ID__c : null
				// , account.ANG_IsNewGenAgency__c
				, Due_Diligence_Status__c = account.Due_Diligence_Status__c
				, PCI_Compliance__c = PCICompliance
				, PCI_compliance_expiry_date__c = account.ANG_PCI_compliance_expiry_date__c

				, Remittance_Frequency_1__c =  (remittance_frequency_references.containsKey(remittance1)) ? remittance_frequency_references.get(remittance1).Id : null
				, Remittance_Frequency_2__c =  (remittance_frequency_references.containsKey(remittance2)) ? remittance_frequency_references.get(remittance2).Id : null
				, EasyPay_Account_Status__c =  (easy_pay_status_references.containsKey(account.ANG_IEP_Status_FF__c)) ? easy_pay_status_references.get(account.ANG_IEP_Status_FF__c).Id : null
			));
		}

		return result;
	}

	public static List<Account_Category__c> formatAccount2AccountCategory(List<Account> accounts)
	{
		List<Account_Category__c> result = new List<Account_Category__c>();

		Set<String> category_codes = new Set<String>();
		Set<String> accountIds = new Set<String>();

		for(Account account : accounts)
		{
			if(String.isNotBlank(account.Location_Category__c))
				category_codes.addAll(account.Location_Category__c.split(';'));

			accountIds.add(account.Id);
		}

		Map<String, GDP_Reference_Table__c> tbl_category_codes 	= ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(category_codes, 'LOCCAT');
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account_Category__c');
		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

		for(Account account : accounts)
		{
			if(String.isBlank(account.Location_Category__c)) continue;

			String gdp_product = (gdpProductIdByAccountId.containsKey(account.Id))? gdpProductIdByAccountId.get(account.Id):null;

			Integer rank =1;
			for(String code : account.Location_Category__c.split(';'))
			{
				if(tbl_category_codes.containsKey(code))
				{
					//-- Mapping Key
					String mapping_key = account.Id +'-'+ code;

					/*result.add(new Account_Category__c(AMS_GDP_Key__c = mapping_key
						, Category_ID__c = rank
						, Related_Account__c = account.Id
						, Category_Code__c = tbl_category_codes.get(code).Id
						, RecordTypeId = recordTypes.get('Live')
					));*/
					result.add(new Account_Category__c(AMS_GDP_Key__c = mapping_key+'GDP'
						, Category_ID__c = rank
						, Related_Account__c = account.Id
						, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(account.Id)
						, Category_Code__c = tbl_category_codes.get(code).Id
						, RecordTypeId = recordTypes.get('GDP')
					));

					rank++;
				}
			}
		}

		return result;
	}

	/**
	 * This function format a List of Account records into a list of GDS records
	 * Account can have multiple GDS records (Multipicklist in Account)
	 * Each value of GDS Fields should map GDS.REfTable
	 * 		ABAC-ABACUS
	 * 	 	AGTD-Amadeus
	 * 	  	AXSS-AXESS
	 * 	   	CMAS-Kiu System
	 * 	    DERD-DEUTSCHE REISEBURO
	 * 	    FLGX-Farelogix
	 * 		GDSL-Galileo
	 * 	 	INFI-INFINI
	 * 	  	KOTI-KOTIS TRAVEL INFO
	 * 	   	MINS-Travelsky
	 * 	    RESI-Resiber
	 * 	    SABR-Sabre
	 * 	    SITA-SITA
	 * 	    STRA-SIRENA
	 * 	    TOPAS-Topas
	 * 	    UALA-Apollo
	 * 	    WSPN-Worldspan
	 *
	 * @param  List<Account> accounts
	 * @return List<GDS__c>
	 */
	public static List<GDS__c> formatAccount2GDS(List<Account> accounts)
	{
		List<GDS__c> result = new List<GDS__c>();

		Set<String> gds_codes = new Set<String>();
		Set<String> gds_definitions = new Set<String>();
		Set<String> accountIds = new Set<String>();

		for(Account acc : accounts)
		{
			accountIds.add(acc.Id);
			if(String.isNotBlank(acc.GDS__c))
			{
				gds_codes.addAll(acc.GDS__c.split(';'));
			}
		}

		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

		Map<String, String> definitionByCode = new Map<String, String>{
			'ABAC' =>  'Abacus',
			'AGTD' =>  'Amadeus',
			'UALA' =>  'Apollo',
			'AXSS' =>  'Axess',
			'DERD' =>  'DEUTSCHE REISEBURO',
			'FLGX' =>  'Farelogix',
			'GDSL' =>  'Galileo',
			'INFI' =>  'Infini',
			'CMAS' =>  'Kiu System',
			'KOTI' =>  'KOTIS TRAVEL INFO',
			'RESI' =>  'Resiber',
			'SABR' =>  'Sabre',
			'STRA' =>  'SIRENA',
			'SITA' =>  'SITA',
			'TOPAS' =>  'Topas',
			'MINS' =>  'Travelsky',
			'WSPN' =>  'Worldspan'
		};


		for(String c : gds_codes)
		{
			if(definitionByCode.containsKey(c)) gds_definitions.add(definitionByCode.get(c));
		}

		Map<String, GDP_Reference_Table__c> tbl_gds_codes 	= ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(gds_definitions, 'AIRSYS');
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDS__c');

		for(Account account : accounts)
		{
			if(String.isBlank(account.GDS__c)) continue;

			Map<String, Integer> rankByAccount = new Map<String, Integer>();

			for(String code : account.GDS__c.split(';'))
			{
				if(!definitionByCode.containsKey(code))
					continue;

				String definition = definitionByCode.get(code);
				if(tbl_gds_codes.containsKey(definition))
				{
					//-- Mapping Key
					String mapping_key = account.Id +'-'+ code;

					Integer rank = (rankByAccount.containsKey(account.Id)) ? rankByAccount.get(account.Id)+1 : 1;
 					rankByAccount.put(account.Id, rank);

					/*result.add(new GDS__c(AMS_GDP_Key__c = mapping_key
						, Related_Account__c = account.Id
						, Computer_Reservation_System__c = tbl_gds_codes.get(definition).Id
						//, Related_GDP_Products_Account_View__c = gdp_product
						, GDS_ID__c = rank
						, RecordTypeId = recordTypes.get('Live')
					));*/
					result.add(new GDS__c(AMS_GDP_Key__c = mapping_key+'GDP'
						, Computer_Reservation_System__c = tbl_gds_codes.get(definition).Id
						, Related_Account__c = account.Id
						, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(account.Id)
						, GDS_ID__c = rank
						, RecordTypeId = recordTypes.get('GDP')
					));
				}
			}
		}

		return result;
	}

	/**
	 * This function format a list of Account records into GDP Address (GDP_Address__c) records
	 * @param  List<Account>
	 * @return List<GDP_Address__c>
	 * @author David Daboué <david.daboue@cgi.com>
	 */
	public static List<GDP_Address__c> formatAccount2Address(List<Account> accounts)
	{
		List<GDP_Address__c> result = new List<GDP_Address__c>();

		Set<String> accountIds = new Set<String>();
 		Set<String> countryIds = new Set<String>();

 		Set<String> countryNames = new Set<String>();
 		Set<String> stateNames = new Set<String>();


		for(Account acc : accounts)
		{
			accountIds.add(acc.Id);

			if(acc.IATA_ISO_Country__c != null) countryIds.add(acc.IATA_ISO_Country__c);
			if(acc.IATA_ISO_Shipping_Country__c != null) countryIds.add(acc.IATA_ISO_Shipping_Country__c);

			if(String.isNotBlank(acc.BillingCountry)) countryNames.add(acc.BillingCountry);
			if(String.isNotBlank(acc.ShippingCountry)) countryNames.add(acc.ShippingCountry);

			if(String.isNotBlank(acc.BillingState)) stateNames.add(acc.BillingState);
			if(String.isNotBlank(acc.ShippingState)) stateNames.add(acc.ShippingState);
		}

		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Address__c');
		Map<String, String> geoDetailByCountry = ams2gdp_Selector.getGeoDetailsByCountry(countryIds);
		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

		Map<String, String> countryIdByName = ams2gdp_Selector.getCountryIdByName(countryNames);
		Map<String, String> stateIdByName = ams2gdp_Selector.getStateIdByName(stateNames);

		for(Account acc: accounts)
		{



			/*if(!(String.isBlank(acc.BillingStreet) && String.isBlank(acc.BillingCity) && String.isBlank(acc.BillingCountry))) ----> RN-INC350124 -> remove the blank validation to update the addres when blank
			{

				if(String.isBlank(acc.BillingStreet))  acc.BillingStreet = '-';
				if(String.isBlank(acc.BillingCity))  acc.BillingCity = '-';
				if(String.isBlank(acc.BillingCountry))  acc.BillingCountry = '-';*/
				//Generate Location Address
				List<String> streetPartsBS = ams2gdp_Utils.WrapText(acc.BillingStreet, 32);
				String countryIdBS = (acc.IATA_ISO_Country__c !=null)? acc.IATA_ISO_Country__c : countryIdByName.get(acc.BillingCountry);
				result.add(new GDP_Address__c(AMS_GDP_Key__c = acc.Id+'LOCGDP'
					, Address_Type__c = 'Location'
					, Address_Line_1__c = (streetPartsBS.size() > 0) ? streetPartsBS.get(0) : ''
					, Address_Line_2__c = (streetPartsBS.size() > 1) ? streetPartsBS.get(1) : ''
					, Address_Line_3__c = (streetPartsBS.size() > 2) ? streetPartsBS.get(2) : ''
					, Address_City__c = String.isBlank(acc.BillingCity) ? '' : acc.BillingCity.left(30)
					, IATA_ISO_State__c = (acc.IATA_ISO_Billing_State__c !=null)? acc.IATA_ISO_Billing_State__c : stateIdByName.get(acc.BillingState)
					, GDP_Geo_Detail__c = geoDetailByCountry.get(countryIdBS)
					, IATA_ISO_Country__c = countryIdBS
					, Address_Postal_Code__c = String.isNotBlank(acc.BillingPostalCode) ? acc.BillingPostalCode.left(10) : ''
					, Related_Account__c = acc.Id
					, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(acc.Id)
					, RecordTypeId = recordTypes.get('GDP')
				));
			//}

			/*if(!(String.isBlank(acc.ShippingStreet) && String.isBlank(acc.ShippingCity) && String.isBlank(acc.ShippingCountry))) ----> RN-INC350124 -> remove the blank validation to update the addres when blank
			{

				if(String.isBlank(acc.ShippingStreet))  acc.ShippingStreet = '-';
				if(String.isBlank(acc.ShippingCity))  acc.ShippingCity = '-';
				if(String.isBlank(acc.ShippingCountry))  acc.ShippingCountry = '-';*/
				//Generate Mailing Address
				List<String> streetPartsSH = ams2gdp_Utils.WrapText(acc.ShippingStreet, 32);
				String countryIdSH = (acc.IATA_ISO_Shipping_Country__c !=null)? acc.IATA_ISO_Shipping_Country__c : countryIdByName.get(acc.ShippingCountry);
				result.add(new GDP_Address__c(AMS_GDP_Key__c = acc.Id+'MAIGDP'
					, Address_Type__c = 'Mailing'
					, Address_Line_1__c = (streetPartsSH.size() > 0) ? streetPartsSH.get(0) : ''
					, Address_Line_2__c = (streetPartsSH.size() > 1) ? streetPartsSH.get(1) : ''
					, Address_Line_3__c = (streetPartsSH.size() > 2) ? streetPartsSH.get(2) : ''
					, Address_City__c = String.isBlank(acc.ShippingCity) ? '' : acc.ShippingCity.left(30)
					, IATA_ISO_State__c = (acc.IATA_ISO_Shipping_State__c !=null)? acc.IATA_ISO_Shipping_State__c : stateIdByName.get(acc.ShippingState)
					, GDP_Geo_Detail__c = geoDetailByCountry.get(countryIdSH)
					, IATA_ISO_Country__c = countryIdSH
					, Address_Postal_Code__c = String.isNotBlank(acc.ShippingPostalCode) ? acc.ShippingPostalCode.left(10) : ''
					, Related_Account__c = acc.Id
					, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(acc.Id)
					, RecordTypeId = recordTypes.get('GDP')
				));
			//}

		}
		return result;
	}


 	/**
	 * This function format a list of AMS Address(AMS_Address__c) records into GDP Address (GDP_Address__c) records
	 * @param  List<AMS_Address__c
	 * @return List<GDP_Address__c>
	 * @author David Daboué <david.daboue@cgi.com>
	 */
	/*public static List<GDP_Address__c> formatAddress2Address(List<AMS_Address__c> addresses)
 	{
 		List<GDP_Address__c> result = new List<GDP_Address__c>();

 		Set<String> accountIds = new Set<String>();
 		Set<String> countryIds = new Set<String>();
		for(AMS_Address__c adr : addresses)
		{
			if(adr.Account__c != null){accountIds.add(adr.Account__c);}
			countryIds.add(adr.Country__c);
		}

		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);
		Map<String, String> gdpAddressTypeByAMS = new Map<String, String>{'Primary' => 'Location'
			, 'Mailing' => 'Mailing'
			, 'Registered' => 'Registered'
		};

		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Address__c');
		Map<String, String> geoDetailByCountry = ams2gdp_Selector.getGeoDetailsByCountry(countryIds);

 		for(AMS_Address__c adr : addresses)
		{
			//-- GDP External Key = {AMS_ADR_ID}  1 AMS_Address__c generate 1 GDP_Address__c record
			String key = adr.Id;

			if(adr.Address_Type__c == null) continue;
			for(String adrType : adr.Address_Type__c.split(';'))
			{
				if(!gdpAddressTypeByAMS.containsKey(adrType)) continue;

				result.add(new GDP_Address__c(AMS_GDP_Key__c = key+'GDP'
					, Address_Type__c = gdpAddressTypeByAMS.get(adrType)
					, Address_Line_1__c = String.isNotBlank(adr.Address_1__c) ? adr.Address_1__c.left(32) : ''
					, Address_Line_2__c = String.isNotBlank(adr.Address_2__c) ? adr.Address_2__c.left(32) : ''
					, Address_Line_3__c = String.isNotBlank(adr.Address_3__c) ? adr.Address_3__c.left(32) : ''
					, Address_City__c = String.isNotBlank(adr.City__c) ? adr.City__c.left(30) : ''
					, IATA_ISO_State__c = adr.State__c
					, GDP_Geo_Detail__c = geoDetailByCountry.get(adr.Country__c)
					, IATA_ISO_Country__c = adr.Country__c
					, Address_Postal_Code__c = String.isNotBlank(adr.AMS_ZipCode__c) ? adr.AMS_ZipCode__c.left(10) : ''
					, Related_Account__c = adr.Account__c
					, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(adr.Account__c)
					, RecordTypeId = recordTypes.get('GDP')
				));
			}
		}

 		return result;
 	}*/


 	public static List<GDP_Phone__c> formatAccount2Phone(List<Account> accounts)
	{
		List<GDP_Phone__c> result = new List<GDP_Phone__c>();

	   Set<String> accountIds = new Set<String>();
		for(Account acc : accounts)
		{
			accountIds.add(acc.Id);
		}

		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);
		Map<String, String> phoneCodesByCountry = ams2gdp_Selector.getPhoneCodesByCountry();
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Phone__c');

		for(Account acc : accounts)
		{
			String gdp_product = (gdpProductIdByAccountId.containsKey(acc.Id))? gdpProductIdByAccountId.get(acc.Id):null;
			//if(String.isNotBlank(acc.Phone)) -RN-INC350124
			//{
				Map<String, String> phoneParts = ams2gdp_Utils.getPhoneNumberParts(acc.Phone, acc.IATA_ISO_Country__r.ISO_Code__c, phoneCodesByCountry);
				result.add(new GDP_Phone__c(AMS_GDP_Key__c = acc.Id+'-P1GDP'
					, Number__c = phoneParts.get('phone')
					, ISD_Code__c 	= phoneParts.get('isd')
					, STD_Code__c 	= phoneParts.get('std')
					, Name = acc.Phone
					, Phone_Type__c = 'Phone 1'
					, Related_GDP_Products_Account_View__c = gdp_product
					, Related_Account__c = acc.Id
					, RecordTypeId = recordTypes.get('GDP')
				));
			//}

			//if(String.isNotBlank(acc.Fax)) RN-INC350124
			//{
				Map<String, String> faxParts = ams2gdp_Utils.getPhoneNumberParts(acc.Fax, acc.IATA_ISO_Country__r.ISO_Code__c, phoneCodesByCountry);
				result.add(new GDP_Phone__c(AMS_GDP_Key__c = acc.Id+'-FXGDP'
					, Number__c = faxParts.get('phone')
					, ISD_Code__c 	= faxParts.get('isd')
					, STD_Code__c 	= faxParts.get('std')
					, Name = acc.Fax
					, Phone_Type__c = 'Fax'
					, Related_GDP_Products_Account_View__c = gdp_product
					, Related_Account__c = acc.Id
					, RecordTypeId = recordTypes.get('GDP')
				));
			//}
		}

		return result;
	}

 	/*public static List<GDP_Phone__c> formatAddress2Phone(List<AMS_Address__c> addresses)
 	{
		List<GDP_Phone__c> result = new List<GDP_Phone__c>();

		Set<String> accountIds = new Set<String>();
		for(AMS_Address__c adr : addresses)
		{
			if(adr.Account__c != null){accountIds.add(adr.Account__c);}
		}

		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);
		Map<String, String> phoneCodesByCountry = ams2gdp_Selector.getPhoneCodesByCountry();
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Phone__c');

		for(AMS_Address__c adr : addresses)
		{
			//-- GDP External Key = {ADR_ID}-{PHONE_TYPE}  is used as Key 1 AMS_Address__c generate multiple GDP_Phone__c record
			String key = adr.Id;
			String gdp_product = (gdpProductIdByAccountId.containsKey(adr.Account__c))? gdpProductIdByAccountId.get(adr.Account__c):null;
			String ful_phone_number = ''+adr.Telephone_Int__c+adr.Telephone_STD__c+ adr.Telephone__c;

			//Because addre type is multi-picklist, split it into multi records
			if(adr.Address_Type__c == null) continue;
			for(String adrType : adr.Address_Type__c.split(';'))
			{
				//Primary address contains Phone 1 & Fax info
				if(adrType == 'Primary' && String.isNotBlank(ful_phone_number))
				{
					//If phone already splitted just take it has is
					if(String.isNotBlank(adr.Telephone_Int__c) && String.isNotBlank(adr.Telephone_STD__c))
					{
						result.add(new GDP_Phone__c(AMS_GDP_Key__c = key+'-P1'+'GDP'
							, Number__c = adr.Telephone__c
							, ISD_Code__c 	= adr.Telephone_Int__c
							, STD_Code__c 	= adr.Telephone_STD__c
							, Name = adr.Telephone_Int__c+' '+adr.Telephone_STD__c+ ' '+adr.Telephone__c
							, Phone_Type__c = 'Phone 1'
							, Related_GDP_Products_Account_View__c = gdp_product
							, Related_Account__c = adr.Account__c
							, RecordTypeId = recordTypes.get('GDP')
						));
					}
					else if(String.isNotBlank(adr.Account__r.Phone_Number__c) || String.isNotBlank(adr.Account__r.Phone))
					{
						//Split Custom field Phone Number
						String p = (String.isNotBlank(adr.Account__r.Phone_Number__c))?adr.Account__r.Phone_Number__c:adr.Account__r.Phone;

						Map<String, String> phone_parts = ams2gdp_Utils.getPhoneNumberParts(p, adr.Country__r.ISO_Code__c, phoneCodesByCountry);
						String isd1  = phone_parts.get('isd');
						String std1  = (phone_parts.containsKey('std')) ? phone_parts.get('std') : '';
						String num1  = phone_parts.get('phone');

						if(std1 == 'null') std1 = '';
						result.add(new GDP_Phone__c(AMS_GDP_Key__c = key+'-P1'+'GDP'
							, Number__c = num1
							, ISD_Code__c = isd1
							, STD_Code__c = std1
							, Name = isd1 + ' '+std1 + ' '+ num1
							, Phone_Type__c = 'Phone 1'
							, Related_GDP_Products_Account_View__c = gdp_product
							, Related_Account__c = adr.Account__c
							, RecordTypeId = recordTypes.get('GDP')
						));
					}

					//If Fax already splited take it has is
					if(String.isNotBlank(adr.Fax_Int__c) && String.isNotBlank(adr.Fax_STD__c))
					{
						result.add(new GDP_Phone__c(AMS_GDP_Key__c = key+'-FX'+'GDP'
							, Number__c = adr.Fax__c
							, ISD_Code__c 	= adr.Fax_Int__c
							, STD_Code__c 	= adr.Fax_STD__c
							, Name = adr.Fax_Int__c+' '+adr.Fax_STD__c+ ' '+adr.Fax__c
							, Phone_Type__c = 'Fax'
							, Related_GDP_Products_Account_View__c = gdp_product
							, Related_Account__c = adr.Account__c
							, RecordTypeId = recordTypes.get('GDP')
						));
					}
					else if(String.isNotBlank(adr.Account__r.Fax))
					{
						Map<String, String> fax_parts = ams2gdp_Utils.getPhoneNumberParts(adr.Account__r.Fax, adr.Country__r.ISO_Code__c, phoneCodesByCountry);
						String isd2  = fax_parts.get('isd');
						String std2  = (fax_parts.containsKey('std')) ? fax_parts.get('std') : '';
						String num2  = fax_parts.get('phone');
						if(std2 == 'null') std2 = '';

						result.add(new GDP_Phone__c(AMS_GDP_Key__c = key+'-FX'+'GDP'
							, Number__c = num2
							, ISD_Code__c 	= isd2
							, STD_Code__c 	= std2
							, Name = isd2+' '+std2+ ' '+num2
							, Phone_Type__c = 'Fax'
							, Related_GDP_Products_Account_View__c = gdp_product
							, Related_Account__c = adr.Account__c
							, RecordTypeId = recordTypes.get('GDP')
						));
					}
				}
				else if(adrType == 'Mailing' && String.isNotBlank(ful_phone_number))
				{
					result.add(new GDP_Phone__c(AMS_GDP_Key__c = key+'-P2'+'GDP'
						, Number__c = adr.Telephone__c
						, ISD_Code__c 	= adr.Telephone_Int__c
						, STD_Code__c 	= adr.Telephone_STD__c
						, Name = adr.Telephone_Int__c+' '+adr.Telephone_STD__c+ ' '+adr.Telephone__c
						, Phone_Type__c = 'Phone 2'
						, Related_GDP_Products_Account_View__c = gdp_product
						, Related_Account__c = adr.Account__c
						, RecordTypeId = recordTypes.get('GDP')
					));
				}
				else if(adrType == 'Registered' && String.isNotBlank(ful_phone_number))
				{
					result.add(new GDP_Phone__c(AMS_GDP_Key__c = key+'-P3'+'GDP'
						, Number__c = adr.Telephone__c
						, ISD_Code__c 	= adr.Telephone_Int__c
						, STD_Code__c 	= adr.Telephone_STD__c
						, Name = adr.Telephone_Int__c+' '+adr.Telephone_STD__c+ ' '+adr.Telephone__c
						, Phone_Type__c = 'Phone 3'
						, Related_GDP_Products_Account_View__c = gdp_product
						, Related_Account__c = adr.Account__c
						, RecordTypeId = recordTypes.get('GDP')
					));
				}
			}
		}

		return result;
 	} */

 	/**
 	 * This function format a list of AMS Agency Affiliation  (AMS_Agency_Affiliation__c) records into Assoc Affiliation Membership (Assoc_Affiliation_Membership__c) records
 	 * @param  List<AMS_Agency_Affiliation__c>
 	 * @return List<Assoc_Affiliation_Membership__c>
 	 * @author David Daboué <david.daboue@cgi.com>
 	 */
	public static List<Assoc_Affiliation_Membership__c> formatAgency2Membership(List<AMS_Agency_Affiliation__c> agencies)
	{
		List<Assoc_Affiliation_Membership__c> result = new List<Assoc_Affiliation_Membership__c>();
		Set<String> accountIds= new Set<String>();
		//-- Affiliation Code Picklist => Lookup
		Set<String> affiliation_codes = new Set<String>();

		for(AMS_Agency_Affiliation__c agency : agencies){
			affiliation_codes.add(agency.Affiliation__r.Affiliation_Code__c);

			if(agency.Account__c != null)
				accountIds.add(agency.Account__c);
		}

		//Reference Table By Code
		Map<String, GDP_Reference_Table__c> ref_table = ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(affiliation_codes, 'ASSC');
		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);
		//-- Ranking calculation
		Map<String, Integer> rankByAccount = new Map<String, Integer>();
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Assoc_Affiliation_Membership__c');

		for(AMS_Agency_Affiliation__c agency : agencies)
		{
			//-- GDP External Key = {AGENCY_ID} 1 AMS_Agency_Affiliation__c generate 1 Assoc_Affiliation_Membership__c record
			String key = agency.Id;

			Integer rank = (rankByAccount.containsKey(agency.Account__c)) ? rankByAccount.get(agency.Account__c)+1 : 1;
			rankByAccount.put(agency.Account__c, rank);

			/*result.add(new Assoc_Affiliation_Membership__c(AMS_GDP_Key__c = key
				, Related_Account__c = agency.Account__c
				, Assoc_Affiliation_ID__c = rank
				, Assoc_Affiliation_Code__c = (ref_table.containsKey(agency.Affiliation__r.Affiliation_Code__c))? ref_table.get(agency.Affiliation__r.Affiliation_Code__c).Id : null
				, RecordTypeId = recordTypes.get('Live')
			));*/
			result.add(new Assoc_Affiliation_Membership__c(AMS_GDP_Key__c = key+'GDP'
				, Assoc_Affiliation_ID__c = rank
				, Assoc_Affiliation_Code__c = (ref_table.containsKey(agency.Affiliation__r.Affiliation_Code__c))? ref_table.get(agency.Affiliation__r.Affiliation_Code__c).Id : null
				, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(agency.Account__c)
				, Related_Account__c = agency.Account__c
				, RecordTypeId = recordTypes.get('GDP')
			));
		}

		return result;
	}

	/**
 	 * This function format a List of Account Role (AMS) records to Agency Owner (GDP) records
 	 * Query to retrieve oAccount Role should be ordered by Account and Percentage
 	 * The Owner Id is based on thepercentage
 	 * Biggest percentage => Rank 1 ...
 	 * @param  List<AMS_Account_Role__c>
 	 * @return List<Agency_Owner__c>
 	 * @author Bhanu Chandra Bulusu <bhanuchandra.bulusu@cgi.com>
 	 */
 	public static List<Agency_Owner__c>  formatAccountRole2AgencyOwner(List<AMS_Account_Role__c> roles)
 	{

 		List<Agency_Owner__c> result= new List<Agency_Owner__c>();
 		//List<String> userNameList=new List<String>();
 		Set<String> accountIds = new Set<String>();

 		for(AMS_Account_Role__c arole: roles)
 		{
 			if(arole.Account__c != null){accountIds.add(arole.Account__c);}
			//userNameList.add(arole.Owner_Name__c);
 		}


 		//Map<String,Id> userIds=ams2gdp_Selector.getUserIdfromName(userNameList);

 		Map<String, Integer> rankByAccount = new Map<String, Integer>();
 		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Agency_Owner__c');
 		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

 		for(AMS_Account_Role__c arole: roles)
 		{

 			Integer rank = (rankByAccount.containsKey(arole.Account__c)) ? rankByAccount.get(arole.Account__c)+1 : 1;
 			rankByAccount.put(arole.Account__c, rank);

 			//-- Mapping Key
 			String key = arole.Id;

 			/*result.add(new Agency_Owner__c(AMS_GDP_Key__c=key
 				, Name = arole.Owner_Name__c
 				, Percent__c=arole.Percentage__c
 				, Related_Account__c=arole.Account__c
				, Owner_ID__c = rank
				, RecordTypeId = recordTypes.get('Live')
			));*/
			String name = arole.Unified_Owner_Name__c;
			//if(arole.Contact__r.name != null) name = arole.Contact__r.name;
			result.add(new Agency_Owner__c(AMS_GDP_Key__c=key+'GDP'
 				, Name =  name
 				, Percent__c=arole.Percentage__c
 				, Related_GDP_Products_Account_View__c=gdpProductIdByAccountId.get(arole.Account__c)
 				, Related_Account__c=arole.Account__c
				, Owner_ID__c = rank
				, RecordTypeId = recordTypes.get('GDP')
			));
 		}

 		return result;
 	}

 	/**
 	 * This function format a List of Account Role (AMS) records to Agency Owner (GDP) records
 	 * to delete
 	 * Biggest percentage => Rank 1 ...
 	 * @param  List<AMS_Account_Role__c>
 	 * @return List<Agency_Owner__c>
 	 * @author Aku Luukka <luukkaa@iata.org>
 	 */
 	public static List<Agency_Owner__c>  getAgencyOwnersToDelete(List<AMS_Account_Role__c> roles)
 	{
 		Set<String> accountIds = new Set<String>();

 		for(AMS_Account_Role__c arole: roles)
 		{
 			if(arole.Account__c != null){accountIds.add(arole.Account__c);}
			//userNameList.add(arole.Owner_Name__c);
 		}

		List<Agency_Owner__c> result= [SELECT Id FROM Agency_Owner__c WHERE Related_Account__c IN :accountIds];

 		return result;
 	}

 	/**
 	 * This function format a List of Agency Airport (AMS) records to Adjacent Airport (GDP) records
 	 * @param  List<AMS_Agency_Airport__c>
 	 * @return List<Adjacent_Airport__c>
 	 * @author Bhanu Chandra Bulusu <bhanuchandra.bulusu@cgi.com>
 	 */
 	public static List<Adjacent_Airport__c>  formatAgencyAirport2AdjacentAirport(List<AMS_Agency_Airport__c> airport)
 	{
 		List<Adjacent_Airport__c> result= new List<Adjacent_Airport__c>();

 		Set<String> airport_codes= new Set<String>();
 		Set<String> accountIds = new Set<String>();

 		for(AMS_Agency_Airport__c aport:airport)
 		{
 			if(aport.Account__c!= null) accountIds.add(aport.Account__c);
 			if(aport.Airport__c != null) airport_codes.add(aport.Airport__r.Code__c);
 		}

 		//-- Reference Table for Airport Codes
 		Map<String, GDP_Reference_Table__c> ref_table 	= ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(airport_codes, 'AIRPORT');
 		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Adjacent_Airport__c');
 		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

 		//--Ranking calculation
 		Map<String, Integer> rankByAccount = new Map<String, Integer>();

		for(AMS_Agency_Airport__c agency: airport)
		{
			String gdp_product = (gdpProductIdByAccountId.containsKey(agency.Account__c))? gdpProductIdByAccountId.get(agency.Account__c):null;

			//-- Mapping Key
			String key=agency.Id;

			//-- Airport ID calculation
			Integer rank = (rankByAccount.containsKey(agency.Account__c)) ? rankByAccount.get(agency.Account__c)+1 : 1;
 			rankByAccount.put(agency.Account__c, rank);

			/*result.add(new Adjacent_Airport__c(AMS_GDP_Key__c = key
				, Airport_ID__c = rank
				, Related_Account__c = agency.Account__c
				, AirportCode__c = (ref_table.containsKey(agency.Airport__r.Code__c)) ? ref_table.get(agency.Airport__r.Code__c).Id : null
				, RecordTypeId = recordTypes.get('Live')
			));	*/
			result.add(new Adjacent_Airport__c(AMS_GDP_Key__c = key+'GDP'
				, Airport_ID__c = rank
				, Related_GDP_Products_Account_View__c=gdp_product
				, Related_Account__c = agency.Account__c
				, AirportCode__c = (ref_table.containsKey(agency.Airport__r.Code__c)) ? ref_table.get(agency.Airport__r.Code__c).Id : null
				, RecordTypeId = recordTypes.get('GDP')
			));
		}

 		return result;
 	}

	/**
 	 * This function format a List of Appointment (AMS)  (AMS_Territory__c) records to GSA Territory (GSA_Territory__c) records
 	 * @param  List<AMS_Territory__c>
 	 * @return List<GSA_Territory__c>
 	 * @author David Daboué <david.daboue@cgi.com>
 	 */
 	public static List<GSA_Territory__c> formatInspection2Territory(List<AMS_Territory__c> territories)
 	{
 		//-- What the function would return
 		List<GSA_Territory__c> result = new List<GSA_Territory__c>();

 		//-- Find GDP Product By Account
 		Set<String> accountIds = new Set<String>();
 		for(AMS_Territory__c territory: territories)
 			if(territory.Appointment__r.Account__c != null){accountIds.add(territory.Appointment__r.Account__c);}

 		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);
 		Map<String, String> accreditationIdByAccountId = ams2gdp_Selector.getAccreditationByAccount(accountIds);
 		Map<String, Integer> rankByAccount = new Map<String, Integer>();

 		//-- Build GSA Territory (GSA_Territory__c) records for each AMS Territory(AMS_Territory__c) records
 		for(AMS_Territory__c territory : territories)
 		{
 			//-- GDP External Key = {INSPECTION_ID}   1 Inspection generate 1 gsa_territory record
 			String key = territory.Id;

 			Integer rank = (rankByAccount.containsKey(territory.Appointment__r.Account__c)) ? rankByAccount.get(territory.Appointment__r.Account__c)+1 : 1;
			rankByAccount.put(territory.Appointment__r.Account__c, rank);

 			/*result.add(new GSA_Territory__c(AMS_GDP_Key__c = key
 				, Accreditation_ID__c = rank
 				, Related_Account__c = territory.Appointment__r.Account__c
 				, AIMS_Area_ID__c = territory.Appointment__r.Account__r.IATA_ISO_Country__r.AIMS_Area_ID__c
				, IATA_Code__c = (territory.Appointment__r.Account__r.IATACode__c != null)? territory.Appointment__r.Account__r.IATACode__c.left(7) : null
				, Check_Digit__c = territory.Appointment__r.Account__r.Check_Digit__c
				, IATA_ISO_Country__c = territory.Appointment__r.Account__r.IATA_ISO_Country__r.ISO_Code__c
				, Location_Country_Name__c = territory.Appointment__r.Account__r.IATA_ISO_Country__r.Name
				, Airline_Code__c = territory.Appointment__r.Account__r.Main_Accreditation_Organization__c
				, Airline_Name__c = territory.Appointment__r.Accreditation_Endorsement_organisation__r.Name
				, Appointment_Date__c = territory.Appointment__r.Date_Organisation_Status_attained__c
				, Appointment_Type__c = territory.Appointment__r.AMS_Appointment_Type__c
				, Territory_ISO_Country__c = territory.ISO_Country__r.ISO_Code__c
				, Territory_IATA_Numeric_Country_Code__c = ''+territory.ISO_Country__r.ISO_Code_Numeric__c
				, Territory_Country_Name__c = territory.ISO_Country__r.Name
				, Territory_State_Abbreviation__c = territory.ISO_State__r.ISO_Code__c
				, Territory_Description__c = territory.Comments__c
			));*/

			String code = '';
			String name = '';
			if(territory.Appointment__r.Accreditation_Endorsement_organisation__c != null ) {
				if(territory.Appointment__r.Accreditation_Endorsement_organisation__r.Air_Code__c != null) {
					if(territory.Appointment__r.Accreditation_Endorsement_organisation__r.Air_Code__c.length()>3) {
						code = territory.Appointment__r.Accreditation_Endorsement_organisation__r.Air_Code__c.left(3);
					} else { code = territory.Appointment__r.Accreditation_Endorsement_organisation__r.Air_Code__c;}
				}
				name = territory.Appointment__r.Accreditation_Endorsement_organisation__r.Name;
			}
			else if(territory.Appointment__r.Airline__c != null ) {
				code = territory.Appointment__r.Airline__r.IATACode__c != null ? territory.Appointment__r.Airline__r.IATACode__c.left(3) : '';
				name = territory.Appointment__r.Airline__r.Name;
			}

			result.add(new GSA_Territory__c(AMS_GDP_Key__c = key+'GDP'
 				, Accreditation_ID__c = rank
 				, Related_Accreditation__c = accreditationIdByAccountId.get(territory.Appointment__r.Account__c)
 				, Related_Account__c = territory.Appointment__r.Account__c
 				, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(territory.Appointment__r.Account__c)
 				, AIMS_Area_ID__c = territory.Appointment__r.Account__r.IATA_ISO_Country__r.AIMS_Area_ID__c
				, IATA_Code__c = (territory.Appointment__r.Account__r.IATACode__c != null)? territory.Appointment__r.Account__r.IATACode__c.left(7) : null
				, Check_Digit__c = territory.Appointment__r.Account__r.Check_Digit__c
				, IATA_ISO_Country__c = territory.Appointment__r.Account__r.IATA_ISO_Country__r.ISO_Code__c
				, Location_Country_Name__c = (territory.Appointment__r.Account__r.IATA_ISO_Country__r.ISO_Country_Short_Name__c.left(30) == null ? '' : territory.Appointment__r.Account__r.IATA_ISO_Country__r.ISO_Country_Short_Name__c.left(30))
				, Airline_Code__c = code
				, Airline_Name__c = name
				, Appointment_Date__c = territory.Appointment__r.Date_Organisation_Status_attained__c
				, Appointment_Type__c = territory.Appointment__r.AMS_Appointment_Type__c
				, Territory_ISO_Country__c = territory.ISO_Country__r.ISO_Code__c
				, Territory_IATA_Numeric_Country_Code__c = territory.Appointment__r.Account__r.state_numeric_code__c
				, Territory_Country_Name__c = (territory.ISO_Country__r.ISO_Country_Short_Name__c.left(30) == null ? '' : territory.ISO_Country__r.ISO_Country_Short_Name__c.left(30))
				, Territory_State_Abbreviation__c = territory.ISO_State__r.ISO_Code__c
				, Territory_Description__c = (String.isNotBlank(territory.Comments__c))? territory.Comments__c.left(40):null
			));

 		}
 		return result;
 	}

 	/**
 	 * This function format a list of Appointment (AMS)  (AMS_Inspection__c) records into Accreditation (Accreditation__c) records
 	 * @param  List<AMS_Inspection__c>
 	 * @return List<Accreditation__c>
 	 * @author David Daboué <david.daboue@cgi.com>
 	 */
 	public static List<Accreditation__c> formatInspection2Accreditation(List<Account> accounts)
 	{
 		//-- What the function would return
 		List<Accreditation__c> result = new List<Accreditation__c>();

 		//-- Fetch Corresponding GDP References Tables
 		Set<String> location_class_codes = new Set<String>();
 		Set<String> air_codes = new Set<String>();
 		Set<String> status_codes = new Set<String>();

 		Set<String> iatan_status = new Set<String>();//Code 0-7
 		Set<String> iata_status = new Set<String>();//Code 0-9

 		Set<String> accreditation_models = new Set<String>();
 		Set<String> risk_status = new Set<String>();
 		Set<String> remittance_frequencies = new Set<String>();
 		Set<String> easy_pay_statuses = new Set<String>();



 		Set<String> accountIds = new Set<String>();

		for(Account acc : accounts)
		{
			String air_code = acc.Main_Accreditation_Organization__c;

			location_class_codes.add(acc.Location_Class__c);
			air_codes.add(air_code);

			if(air_code.equalsIgnoreCase('IATAN'))
			iatan_status.add(acc.Status__c);
			else if(air_code.equalsIgnoreCase('IATA') || air_code.equalsIgnoreCase('DOM')) iata_status.add(acc.Status__c);
			//status_codes.add(inspection.Accreditation_Endorsement_Status_code__c);

			accreditation_models.add(acc.ANG_Accreditation_Model__c);
			risk_status.add(acc.ANG_RiskStatus__c);

			if(acc.Id != null)
				accountIds.add(acc.Id);
		}

		Map<String, GDP_Reference_Table__c> location_class_references 	= ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(location_class_codes, 'ORGCLASS');
		Map<String, GDP_Reference_Table__c> air_code_references 		= ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(air_codes, 'ORGABB');
		//Map<String, GDP_Reference_Table__c> status_references 			= ams2gdp_Selector.getGDPReferenceTableByCodeAndTable(status_codes, 'STATUS');
		Map<String, GDP_Reference_Table__c> iatan_status_references 	= ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(iatan_status, 'STATUS','Webstar');
		Map<String, GDP_Reference_Table__c> iata_status_references 		= ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(iata_status, 'STATUS','AIMS');

		// NewGen
		Map<String, GDP_Reference_Table__c> accreditation_model_references 		= ams2gdp_Selector.getGDPReferenceTablebyDescriptionAndTable(accreditation_models, 'ACCTYP');

		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);
		Map<String, Integer> rankByAccount = new Map<String, Integer>();
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Accreditation__c');

		//-- Build Accredition records for each AMS_Inspection record
		for(Account acc : accounts)
		{
			//-- GDP External Key = {INSPECTION_ID} 1 Inspection generate 1 accreditation record
			String key = acc.Id;
			String air_code = acc.Main_Accreditation_Organization__c;

			Integer rank = (rankByAccount.containsKey(acc.Id)) ? rankByAccount.get(acc.Id)+1 : 1;
			rankByAccount.put(acc.Id, rank);

			Accreditation__c accreditation = new Accreditation__c(AMS_GDP_Key__c = key
				, Accreditation_ID__c = rank
				, Last_change_date__c = acc.Organization_Last_Change_Date__c
				, Last_re_inspection_date__c = acc.Verification_Date__c
				, Original_approval_date__c = acc.Accreditation_date__c
				, Related_Account__c = acc.Id
				, Date__c = acc.Date_Organisation_Status_attained__c
			);



			//Class field is a Lookup & Location Class on Account is a Picklist
			if(location_class_references.containsKey(acc.Location_Class__c)) accreditation.Class__c = location_class_references.get(acc.Location_Class__c).Id;

			//if(status_references.containsKey(inspection.Accreditation_Endorsement_Status_code__c)) accreditation.Status__c = status_references.get(inspection.Accreditation_Endorsement_Status_code__c).Id;

			if((air_code.equalsIgnoreCase('IATA') || air_code.equalsIgnoreCase('DOM')) && iata_status_references.containsKey(acc.Status__c))
			{

				accreditation.Status__c = iata_status_references.get(acc.Status__c).Id;

			}
			else if(air_code.equalsIgnoreCase('IATAN') && iatan_status_references.containsKey(acc.Status__c))

			{

				accreditation.Status__c = iatan_status_references.get(acc.Status__c).Id;
			}

			//-- Set default record Type
			if(recordTypes.containsKey('Live'))
				accreditation.RecordTypeId = recordTypes.get('Live');

			//result.add(accreditation);

			//Adding Accreditation with GDP Record Type
			Accreditation__c gdpAccreditation= accreditation.clone(false,false,false,false);
			gdpAccreditation.AMS_GDP_Key__c+='GDP';
			gdpAccreditation.RecordTypeId= recordTypes.get('GDP');
			//gdpAccreditation.Related_Account__c=null;
			gdpAccreditation.Related_GDP_Products_Account_View__c=gdpProductIdByAccountId.get(acc.Id);

			//newgen
			if(acc.ANG_IsNewGenAgency__c) {
			}
				gdpAccreditation.Is_NewGen_Agency__c = acc.ANG_IsNewGenAgency__c;
				gdpAccreditation.Accreditation_Model__c = accreditation_model_references.containsKey(acc.ANG_Accreditation_Model__c) ? accreditation_model_references.get(acc.ANG_Accreditation_Model__c).Id : null;
				gdpAccreditation.Cash_Conditions_Override__c = acc.ANG_CashCondition__c;
				gdpAccreditation.Risk_Status__c = acc.ANG_RiskStatus__c;

			result.add(gdpAccreditation);
		}

		return result;
 	}








	/**
 	 * This function format a List of Agency Profile (AMS) records to Agency Profile & Specialization (GDP) records
 	 * @param  List<AMS_Agency_Profile__c>
 	 * @return List<GDP_Agency_Profile_Specialization__c>
 	 * @author Bhanu Chandra Bulusu <bhanuchandra.bulusu@cgi.com>
 	 */
 	public static List<GDP_Agency_Profile_Specialization__c> formatAgencyProfile2GDPAgencyProfile(List<AMS_Agency_Profile__c> profiles){
		List<GDP_Agency_Profile_Specialization__c> result= new List<GDP_Agency_Profile_Specialization__c>();

		Set<String> grItems= new Set<String>();
		Set<Id> accountsAMS=new Set<Id>();
		Set<String> accountIds=new Set<String>();

		for(AMS_Agency_Profile__c ag:profiles)
		{
			grItems.addAll(ag.GR_Item__c.split(';'));
			accountsAMS.add(ag.Account__c);
			if(ag.Account__c != null) accountIds.add(ag.Account__c);
		}

		Map<String,GDP_Reference_Table__c> descriptionsMapwithTable1= ams2gdp_Selector.getGDPReferenceTableByCodeandTable1(grItems);
		Map<String, GDP_Reference_Table__c> descriptionsMap= ams2gdp_Selector.getGDPReferenceTableByCode(grItems);

		Map<String,Set<String>> listOfCodes= new Map<String,Set<String>>();

		Map<String, GDP_Agency_Profile_Specialization__c> gdpRecordByAccount = ams2gdp_Selector.getGDPbyAccount(accountsAMS);
		Map<String, GDP_Agency_Profile_Specialization__c> gdpRecordByProductsView = new Map<String,GDP_Agency_Profile_Specialization__c>();
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('GDP_Agency_Profile_Specialization__c');
		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

		for(AMS_Agency_Profile__c agencies: profiles)
		{
			GDP_Agency_Profile_Specialization__c gdpAgencies = (gdpRecordByAccount.containsKey(agencies.Account__c)) ? 	gdpRecordByAccount.get(agencies.Account__c) : 	new GDP_Agency_Profile_Specialization__c();

			//@quick fix to solve issue: INVALID_FIELD_FOR_INSERT_UPDATE
			if(gdpAgencies.Id != null) gdpAgencies.Id = null;

			// Split GRItem
			List<String> grItemSplit= new List<String>();
			grItemSplit.addAll(agencies.GR_Item__c.split(';'));

			//--Mapping Key
			gdpAgencies.AMS_GDP_Key__c=agencies.Account__c;
			gdpAgencies.Related_Account__c=agencies.Account__c;
			gdpAgencies.RecordTypeId = recordTypes.get('Live');

			//for those GR items that dont have a duplicate in GDP ref table,
			GDP_Reference_Table__c ref1 =descriptionsMap.get(grItemSplit[0]);

			//-- Market Focus
			if(agencies.GR_Code__c=='FL')
			{
				//Map<String,GDP_Reference_Table__c> codeValues=descriptionsMapwithTable.get('APENL2');
				GDP_Reference_Table__c tempRef1 = descriptionsMapwithTable1.get('APENL2'+grItemSplit[0]);
				gdpAgencies.Market_Focus_Leisure__c= tempRef1.Id;
			}

			//-- Sales Land
			else if(agencies.GR_Code__c=='SL')
			{
				//Map<String,GDP_Reference_Table__c> codeValues=descriptionsMapwithTable.get('APEN4L');
				GDP_Reference_Table__c tempRef1 = descriptionsMapwithTable1.get('APEN4L'+grItemSplit[0]);
				gdpAgencies.Sales_Land__c= tempRef1.Id;
			}

			//-- Sales Air
			else if(agencies.GR_Code__c=='SA')
			{
				//Map<String,GDP_Reference_Table__c> codeValues=descriptionsMapwithTable.get('APEN4A');
				GDP_Reference_Table__c tempRef1 = descriptionsMapwithTable1.get('APEN4A'+grItemSplit[0]);
				gdpAgencies.Sales_Air__c= tempRef1.Id;
			}

			//-- Sales Volume
			else if(agencies.GR_Code__c=='SV')
			{
				//Map<String,GDP_Reference_Table__c> codeValues=descriptionsMapwithTable.get('APEN4A');
				GDP_Reference_Table__c tempRef1 = descriptionsMapwithTable1.get('APSALE'+grItemSplit[0]);
				gdpAgencies.Sales_Volume__c= tempRef1.Id;

			}

			//-- Market Specialization
			else if(agencies.GR_Code__c=='MK')
			{

				Iterator<String> iter = grItemSplit.iterator();
				//GR item needs to be split into 3, one each for main market, secondary market and tertiary market
				GDP_Reference_Table__c tempRef = descriptionsMapwithTable1.get('APSPEC' + iter.next());
				gdpAgencies.Main_Market_Specialization__c=tempRef.Id;
				if(iter.hasNext()){
					GDP_Reference_Table__c tempRef1 = descriptionsMapwithTable1.get('APSPEC' + iter.next());
					gdpAgencies.Secondary_Market_Specialization__c=tempRef1.Id;
					if(iter.hasNext()){
						GDP_Reference_Table__c tempRef2 = descriptionsMapwithTable1.get('APSPEC' + iter.next());
						gdpAgencies.Tertiary_Market_Specialization__c=tempRef2.Id;
					}
				}
			}

			//-- Destination Specialization
			else if(agencies.GR_Code__c=='DS')
			{
				Iterator<String> iter = grItemSplit.iterator();
				//GR item needs to be split into 3, one each for main market, secondary market and tertiary market
				GDP_Reference_Table__c tempRef = descriptionsMapwithTable1.get('APDEST' + iter.next());
				gdpAgencies.Main_Destination_Specialization__c=tempRef.Id;
				if(iter.hasNext()){
					GDP_Reference_Table__c tempRef1 = descriptionsMapwithTable1.get('APDEST' + iter.next());
					gdpAgencies.Secondary_Destination_Specialization__c=tempRef1.Id;
					if(iter.hasNext()){
						GDP_Reference_Table__c tempRef2 = descriptionsMapwithTable1.get('APDEST' + iter.next());
						gdpAgencies.Tertiary_Destination_Specialization__c=tempRef2.Id;
					}
				}
			}

			else if(agencies.GR_Code__c=='FC') gdpAgencies.Market_Focus_Corporate__c=ref1.Id;
			else if(agencies.GR_Code__c=='SS') gdpAgencies.Sales_Sea__c=ref1.Id;
			else if(agencies.GR_Code__c=='AT') gdpAgencies.Main_Activity__c=ref1.Id;
			else if(agencies.GR_Code__c=='SH') gdpAgencies.Sales_Accomodation__c=ref1.Id;
			else if(agencies.GR_Code__c=='TR') gdpAgencies.Sales_Tour__c=ref1.Id;

			gdpRecordByAccount.put(agencies.Account__c, gdpAgencies);

		}


		List<GDP_Agency_Profile_Specialization__c> liveRecords =  gdpRecordByAccount.values();
		List<GDP_Agency_Profile_Specialization__c> gdpRecords =new List<GDP_Agency_Profile_Specialization__c>();

			//result.addAll(liveRecords);

		//Replicting to GDP record type
		for(GDP_Agency_Profile_Specialization__c liveRecord: gdpRecordByAccount.values())
		{
			GDP_Agency_Profile_Specialization__c gdpRecord = liveRecord.clone(false, false, false, false);
				gdpRecord.Related_GDP_Products_Account_View__c= (gdpProductIdByAccountId.containsKey(gdpRecord.Related_Account__c))? gdpProductIdByAccountId.get(gdpRecord.Related_Account__c):null;
				//gdpRecord.Related_Account__c=null;
				gdpRecord.RecordTypeId=recordTypes.get('GDP');
				gdpRecord.AMS_GDP_Key__c+='GDP';

			gdpRecords.add(gdpRecord);
		}

		result.addAll(gdpRecords);

		return result;
 	}

	/**
 	 * This function format a List of Agency Authorization (AMS) records to Agency Profile & Specialization (GDP) records
 	 * @param  List<AMS_Agency_Authorization__c>
 	 * @return List<Remittance__c>
 	 * @author Aku Luukka <luukkaa@iata.org>
 	 */
 	public static List<Authorized_Forms_Of_Payment__c> formatAgencyAuthorization2AuthorizedFormOfPayment(List<Agency_Authorization__c> authorizations){

		// List<Id> productIds = new List<Id>();
		Set<String> accountIds = new Set<String>();
		for(Agency_Authorization__c aa : authorizations) {
			accountIds.add(aa.Account__c);
		}
		Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

		// because the AMS_GDP_Key__c == accountId we can query based on them
		List<Authorized_Forms_Of_Payment__c> result = new List<Authorized_Forms_Of_Payment__c>();
		for(Agency_Authorization__c aa : authorizations) {
			result.add(new Authorized_Forms_Of_Payment__c(AMS_GDP_Key__c = aa.Account__c+aa.ANG_FormOfPayment_ID__c
				, Form_of_Payment_Code__c = aa.ANG_FormOfPayment_ID__c
				, Status__c = aa.Status__c
				, Related_GDP_Products_Account_View__c = gdpProductIdByAccountId.get(aa.Account__c)
			));
		}

		return result;
 	}

}
