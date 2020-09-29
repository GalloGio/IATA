public without sharing class TIDSReportChanges {
	final static String NUMBER_OFFICES_FIELD_NAME = 'numberOffices';
	final static String TRAVEL_SALES_FIELD_NAME = 'travelSales';
	final static String NUMBER_EMPLOYEES_FIELD_NAME = 'numberEmployees';
	final static String PRINCIPAL_ACTIVITIES_FIELD_NAME = 'principalActivities';
	final static String MARKET_FOCUS_FIELD_NAME = 'marketFocus';
	final static String SALES_MIX_FIELD_NAME = 'salesMix';
	final static String GDS_FIELD_NAME = 'GDS';
	private static Set<String> gdpref1 = new Set<String> {'AIRSYS','APEMP','FOCUSVALUES','APPRAC','APSALE','APDEST','APSPEC','LGLTYP'};
	private static Set<String> gdpref2 = new Set<String> {'AIRSYS'};
	 

	@AuraEnabled(cacheable=false)
	public static Boolean accountHasChangeReportCase(String accountId, String changeReport) {
		Boolean result = false;
		String filter = '%'+changeReport+'%';
		List<Case> cases = new List<Case>();
		cases = [SELECT Id  FROM Case
			WHERE AccountId = :accountId AND Subject LIKE :filter
			AND Status NOT IN ('Draft', 'Closed') ];

		if (cases.size() > 0) {result = true;}
		return result;
	}

	@AuraEnabled(cacheable=false)
	public static TIDSReportChanges.WrapperNameCompany getNameCompanyDetails(String accountId, boolean isLabel){
		TIDSReportChanges.WrapperNameCompany nameCompany = new TIDSReportChanges.WrapperNameCompany();
		Account account = getAccount(accountId);
		Map<String,String> agencyProfile = getMapAgencyProfile(accountId);
		nameCompany.mappingAccount(account, isLabel);
		nameCompany.mappingAgencyProfile(agencyProfile);
		nameCompany.accountRoles = TIDSUtil.tidsShareholders(accountId);
		System.debug(nameCompany.country);
		return nameCompany;
	}

	public static Account getAccount(String accountId) {
		Account tidsAccount = new Account();
		List<Account> accounts = [
				SELECT
					Id,
					Name,
					TradeName__c,
					Company_Type__c,
					VAT_Number__c,
					VAT_Number_2__c,
					License_Number__c,
					BillingAddress,
					BillingStreet,
					BillingCity,
					BillingState,
					BillingPostalCode,
					BillingCountry,
					IATA_ISO_Country__c,
					IATA_ISO_Country__r.Name,
					IATA_ISO_Country__r.ISO_Code__c,
					IATA_ISO_Billing_State__c,
					IATA_ISO_Billing_State__r.Name,
					IATA_ISO_Billing_State__r.ISO_Code__c,
					IATA_ISO_Shipping_Country__c,
					IATA_ISO_Shipping_Country__r.Name,
					IATA_ISO_Shipping_Country__r.ISO_Code__c,
					IATA_ISO_Shipping_State__c,
					IATA_ISO_Shipping_State__r.Name,
					IATA_ISO_Shipping_State__r.ISO_Code__c,
					Iso_State__r.Name,
					Iso_State__r.ISO_Code__c,
					ShippingStreet,
					ShippingCity,
					ShippingState,
					ShippingPostalCode,
					ShippingCountry,
					Preferred_Language__c,
					Phone,
					Fax,
					Email__c,
					Website,
					Manager_First_Name__c,
					Manager_Last_Name__c,
					Geoname_Billing_City__c,
					Geoname_Shipping_City__c,
					GDS__c
				FROM Account
				WHERE Id = :accountId];
			if (accounts.size() > 0) {tidsAccount = accounts.get(0);}
			return tidsAccount;
	}

	public static Map<String,String> getMapAgencyProfile(String accountId) {
		Map<String,String> results = new Map<String,String>();

		List<AMS_Agency_Profile__c> agencyProfileValues = [
			SELECT Id, GR_Code__c, GR_Item__c
			FROM AMS_Agency_Profile__c
			WHERE Account__c = :accountId
		];

		if (agencyProfileValues.size() > 0) {
			for(AMS_Agency_Profile__c agencyProfileValue : agencyProfileValues) {
				results.put(agencyProfileValue.GR_Code__c,agencyProfileValue.GR_Item__c);
			}
		}
		return results;
	}

	
	public class WrapperNameCompany {
		@AuraEnabled public TIDSHelper.IATAISOCountryDTO country;
		@AuraEnabled public String name { get; set; }
		@AuraEnabled public String tradeName { get; set; }
		@AuraEnabled public String companyType { get; set; }
		@AuraEnabled public String vatNumber1 { get; set; }
		@AuraEnabled public String vatNumber2 { get; set; }
		@AuraEnabled public String licenseNumber { get; set; }
		@AuraEnabled public String inOperationsSince { get; set; }
		@AuraEnabled public List<AMS_Account_Role__c> accountRoles {get; set;}

		public void mappingAccount(Account account, boolean isLabel) {
			this.name = account.Name;
			this.tradeName = account.TradeName__c;
			this.companyType = account.Company_Type__c;
			if (isLabel) {this.companyType = getLabelBasedOnCode('LGLTYP', this.companyType);}
	 
			this.vatNumber1 = account.VAT_Number__c;
			this.vatNumber2 = account.VAT_Number_2__c;
			this.licenseNumber = account.License_Number__c;
			this.country = new TIDSHelper.IATAISOCountryDTO(account.IATA_ISO_Country__r.Name,account.IATA_ISO_Country__r.ISO_Code__c,account.IATA_ISO_Country__c);
		}

		public void mappingAgencyProfile(Map<String,String> agencyProfile) {
			this.inOperationsSince = agencyProfile.get('DIBS');
		}

	}

	@AuraEnabled(cacheable=false)
	public static TIDSReportChanges.WrapperAddressContact getAddressContactDetails(String accountId){
		Account account = getAccount(accountId);
		TIDSReportChanges.WrapperAddressContact addressContactDetails = new TIDSReportChanges.WrapperAddressContact();
		addressContactDetails.mappingAddress(account);
		addressContactDetails.mappingMailingAddress(account);
		addressContactDetails.mappingContact(account);
		addressContactDetails.setGeonames();
		System.debug(addressContactDetails);
		return addressContactDetails;
	}
	

	public class WrapperAddressContact {
		@AuraEnabled public String name { get; set; }
		// Address Details
		@AuraEnabled public TIDSHelper.IATAISOCountryDTO country;
		@AuraEnabled public TIDSHelper.IATAISOStateDTO stateProvince;
		@AuraEnabled public String address { get; set; }
		@AuraEnabled public String city { get; set; }
		@AuraEnabled public String postalCode { get; set; }
		@AuraEnabled public String citygeonameId { get; set; }
		//Mailing Details
		@AuraEnabled public TIDSHelper.IATAISOCountryDTO mailingCountry;
		@AuraEnabled public TIDSHelper.IATAISOStateDTO mailingStateProvince;
		@AuraEnabled public String mailingAddress { get; set; }
		@AuraEnabled public String mailingCity { get; set; }
		@AuraEnabled public String mailingPostalCode { get; set; }
		@AuraEnabled public String mailingcitygeonameId { get; set; }
		// Contact
		@AuraEnabled public String phone { get; set; }
		@AuraEnabled public String fax { get; set; }
		@AuraEnabled public String email { get; set; }
		@AuraEnabled public String website { get; set; }
		@AuraEnabled public String managerFirstName { get; set; }
		@AuraEnabled public String managerLastName { get; set; }
		@AuraEnabled public String preferredLanguage { get; set; }
		
		private Map<String, Id> geonameids {get;set;}
		public void setGeonames(){
			geonameids = new Map<String, Id>();
			// Make sure we can update the database before even trying
			if (!String.isEmpty(this.mailingcitygeonameId)){geonameids.put(this.mailingcitygeonameId, null);}
			if (!String.isEmpty(this.citygeonameId)){geonameids.put(this.citygeonameId, null);}
			List<IATA_ISO_City__c> geonames = new List<IATA_ISO_City__c>();
			geonames = [SELECT Id
							,GeonameId__c
					FROM IATA_ISO_City__c
					WHERE GeonameId__c=:geonameids.KeySet() Or Id=:geonameids.KeySet()
					ORDER BY GeonameId__c NULLS LAST
					LIMIT 2];
			for (IATA_ISO_City__c key : geonames){
				geonameids.put(key.GeonameId__c, key.Id);
				geonameids.put(key.Id, key.Id);
			}
			this.mailingcitygeonameId=(String) geonameids.get(this.mailingcitygeonameId);
			this.citygeonameId=(String) geonameids.get(this.citygeonameId);
			System.Debug('geonameids>>>' + geonameids);
		}
		public void mappingAddress(Account account) {
			this.name = account.Name;
			this.address = account.BillingStreet;
			this.city = account.BillingCity;
			this.postalCode = account.BillingPostalCode;
			this.citygeonameId = account.Geoname_Billing_City__c;
			this.country = new TIDSHelper.IATAISOCountryDTO(account.IATA_ISO_Country__r.Name,account.IATA_ISO_Country__r.ISO_Code__c,account.IATA_ISO_Country__c);
			this.stateProvince = new TIDSHelper.IATAISOStateDTO(account.IATA_ISO_Billing_State__r.Name,account.IATA_ISO_Billing_State__r.ISO_Code__c,account.IATA_ISO_Billing_State__c);
		}

		public void mappingMailingAddress(Account account) {
			this.mailingAddress = account.ShippingStreet;
			this.mailingCity = account.ShippingCity;
			this.mailingPostalCode = account.ShippingPostalCode;
			this.mailingcitygeonameId = account.Geoname_Shipping_City__c;
			this.mailingCountry = new TIDSHelper.IATAISOCountryDTO(account.IATA_ISO_Shipping_Country__r.Name,account.IATA_ISO_Shipping_Country__r.ISO_Code__c,account.IATA_ISO_Shipping_Country__c);
			this.mailingStateProvince = new TIDSHelper.IATAISOStateDTO(account.IATA_ISO_Shipping_State__r.Name,account.IATA_ISO_Shipping_State__r.ISO_Code__c,account.IATA_ISO_Shipping_State__c);
		}

		public void mappingContact(Account account) {
			this.phone = account.Phone;
			this.fax = account.Fax;
			this.email = account.Email__c;
			this.website = account.Website;
			this.managerFirstName = account.Manager_First_Name__c;
			this.managerLastName = account.Manager_Last_Name__c;
			this.preferredLanguage = account.Preferred_Language__c;
		}

	}

	@AuraEnabled(cacheable=false)
	public static TIDSReportChanges.WrapperBusinessProfileSpecialization getBusinessProfileSpecialization(String accountId, boolean isLabel){
		TIDSReportChanges.WrapperBusinessProfileSpecialization businessProfileSpecialization = new TIDSReportChanges.WrapperBusinessProfileSpecialization();
		Map<String, List<String>> gdpReferenceValues = loadGdpReferences(gdpref1,true);
		Account account = getAccount(accountId);
		List<AMS_Agency_Profile__c> businessprofilelist = TIDSUtil.tidsBusinessProfile(accountId);
		sBusinessProfile businessProfile = getBusinessProfiles(businessprofilelist,gdpReferenceValues,isLabel);
		businessProfile.values.gds.values = getSpecialties(account.GDS__c,loadGdpReferences(gdpref2,false));
		businessProfileSpecialization.setBusinessProfileDetails(businessProfile);
		sBusinessSpecialization businessSpecialization = getBusinessSpecialization(businessprofilelist,gdpReferenceValues);
		businessProfileSpecialization.setBusinessSpecializationDetails(businessSpecialization);
		return businessProfileSpecialization;
	}
	
	public static Map<String, List<String>> loadGdpReferences(set<String> gdpref, boolean iscode) {
		Map<String, List<String>> gdpMap = new Map<String, List<String>>();
		for(GDP_Reference_Table__c item: [
			SELECT Name, Code__c, Corresponding_AMS_Code__c
			FROM GDP_Reference_Table__c
			WHERE Table__c =:gdpref
			AND Valid_For_TIDS__c = true
		]) {
			String key=item.Code__c;
			if (!iscode) {key=item.Corresponding_AMS_Code__c;}
			List<String> values= new List<String>{item.Name,key};
			System.debug('key>>>'+key+'  item.Name>>>'+item.Name);
			gdpMap.put(key,values);
		}
		return gdpMap;
	}
	
	private static String getLabelBasedOnCode(String criteria, String code){
		if (code==null) {return '';}
		List<GDP_Reference_Table__c> names = new List<GDP_Reference_Table__c>();
		names = [SELECT Name
		FROM GDP_Reference_Table__c
		WHERE Table__c=:criteria AND Valid_For_TIDS__c = true and Code__c=:code Limit 1];
		if (names.size()==0) {return '';}
		return names[0].Name;
	}

	//'PREFLANG, FOCUSVALUES
	public static sBusinessProfile getBusinessProfiles(List<AMS_Agency_Profile__c> businessprofilelist, Map<String, List<String>> gdpReferenceValues, Boolean isLabel) {
		sBusinessProfile businessProfile = new sBusinessProfile();
		businessProfile.sectionName = 'Business Profile';
		businessProfile.cmpName = 'business-profile';
		businessProfile.sectionDecision = 'Not_Started';
		businessProfile.values.numberOffices = new vnfields();
		businessProfile.values.travelSales = new vnfields();
		businessProfile.values.numberEmployees = new vnfields();
		businessProfile.values.principalActivities = new vsfields();
		businessProfile.values.marketFocus = new vsfields();
		businessProfile.values.salesMix = new vsfields();
		businessProfile.values.gds = new vsfields();
		businessProfile.values.gds.fieldName = GDS_FIELD_NAME;

		businessProfile.values.numberOffices.fieldName = NUMBER_OFFICES_FIELD_NAME;
		businessProfile.values.numberOffices.values = '';
		businessProfile.values.travelSales.fieldName = TRAVEL_SALES_FIELD_NAME;
		businessProfile.values.travelSales.values ='';
		businessProfile.values.numberEmployees.fieldName = NUMBER_EMPLOYEES_FIELD_NAME;
		businessProfile.values.numberEmployees.values = '';
		
		businessProfile.values.principalActivities.fieldName = PRINCIPAL_ACTIVITIES_FIELD_NAME;
		
		vslabel item1 =  new vslabel('Corporate','');
		businessProfile.values.marketFocus.fieldName = MARKET_FOCUS_FIELD_NAME;
		vslabel item2 =  new vslabel('Leisure', '');
		businessProfile.values.marketFocus.fieldName = MARKET_FOCUS_FIELD_NAME;
	
		vslabel item3 = new vslabel( 'Online','');
		businessProfile.values.salesMix.fieldName = SALES_MIX_FIELD_NAME;
		vslabel item4 = new vslabel( 'Offline','');
		businessProfile.values.salesMix.fieldName = SALES_MIX_FIELD_NAME;
		
		
		for(AMS_Agency_Profile__c agencyProfile : businessprofilelist){
			/**
			 * NU_OFFI Number of Offices Number of Offices your agency has in Country
			 * SV Sales Volume - What is your agency's annual sales volume?
			 * NU_EMPL Number Employees - Number of Employees at the office applying for TIDS
			 * DS - What are the 3 Destination Specialties of your entity?
			 * MK - What are the 3 Market Specialties of your entity?
			 * AT - What is the principal activity of your agency? (Select 1)
			 * FL (Focus Leisure), FC (Focus Corporate) - Market Focus: Indicate the approximate % of your Leisure and Corporate business.
			 * SMOF (Sales Mix Offline), SMON (Sales Mix Online) - Online / Offline Sales Mix
			*/

			switch on (agencyProfile.GR_Code__c) {
				when 'NU_OFFI' {
					businessProfile.values.numberOffices.values = agencyProfile.GR_Item__c;
				}
				when 'SV' {
					businessProfile.values.travelSales.values = agencyProfile.GR_Item__c;
					if (isLabel){businessProfile.values.travelSales.values = getLabelBasedOnCode('APSALE', agencyProfile.GR_Item__c);}
				}
				when 'NU_EMPL' {
					businessProfile.values.numberEmployees.values = agencyProfile.GR_Item__c;
					if (isLabel){businessProfile.values.numberEmployees.values = getLabelBasedOnCode('APEMP', agencyProfile.GR_Item__c);}
				}
				when 'AT' {
					List<String> answer = (List<String>) gdpReferenceValues.get(agencyProfile.GR_Item__c);
					System.debug('agencyProfile.GR_Item__c>>>'+agencyProfile.GR_Item__c);
					vslabel item = new vslabel(answer[0],String.valueOf(agencyProfile.GR_Item__c));
					businessProfile.values.principalActivities.values.add(item);
				}
				when 'FC' {
					item1 = new vslabel('Corporate',String.valueOf(agencyProfile.GR_Item__c));
				}
				when 'FL' {
					item2 = new vslabel('Leisure', String.valueOf(agencyProfile.GR_Item__c));
				}
				when 'SMOL' {
					item3 = new vslabel( 'Online',String.valueOf(agencyProfile.GR_Item__c));
				}
				when 'SMOF' {
					item4 = new vslabel( 'Offline',String.valueOf(agencyProfile.GR_Item__c));
				}
			}
		}
		businessProfile.values.marketFocus.values.add(item1);
		businessProfile.values.marketFocus.values.add(item2);
		businessProfile.values.salesMix.values.add(item3);
		businessProfile.values.salesMix.values.add(item4);

		return businessProfile;
	}
	
	public static sBusinessSpecialization getBusinessSpecialization(List<AMS_Agency_Profile__c> businessprofilelist, Map<String, List<String>> gdpReferenceValues) {
		sBusinessSpecialization businessSpecialization = new sBusinessSpecialization();
		businessSpecialization.sectionName = 'Business Specialization';
		businessSpecialization.cmpName = 'business-specialization';
		businessSpecialization.sectionDecision = 'Not_Started';
		businessSpecialization.values.percentageBreakdown = new spercentageBreakdown();
		businessSpecialization.values.percentageBreakdown.fieldName = 'percentageBreakdown';

		businessSpecialization.values.marketSpecialties.fieldName = 'marketSpecialties';
		businessSpecialization.values.destinationSpecialties.fieldName = 'destinationSpecialties';

		Map<string, vslabel> plist = new Map<string, vslabel>();
		plist.put('TIDS_SA',new vslabel(getBusinessLabel('TIDS_SA'),''));
		plist.put('TIDS_SS',new vslabel(getBusinessLabel('TIDS_SS'),''));
		plist.put('TIDS_TR',new vslabel(getBusinessLabel('TIDS_TR'),''));
		plist.put('TIDS_ME',new vslabel(getBusinessLabel('TIDS_ME'),''));
		plist.put('TIDS_SH',new vslabel(getBusinessLabel('TIDS_SH'),''));
		plist.put('TIDS_SL',new vslabel(getBusinessLabel('TIDS_SL'),''));
		for(AMS_Agency_Profile__c agencyProfile : businessprofilelist){

			switch on (agencyProfile.GR_Code__c) {
				when 'TIDS_SH','TIDS_SA','TIDS_SS','TIDS_SL','TIDS_ME','TIDS_TR' {
					vslabel item = new vslabel(
						getBusinessLabel(agencyProfile.GR_Code__c),
						String.valueOf(agencyProfile.GR_Item__c)
					);
					plist.put(agencyProfile.GR_Code__c, item);
				}
				when 'MK' {
					businessSpecialization.values.marketSpecialties.values = getSpecialties(agencyProfile.GR_Item__c,gdpReferenceValues);
				}
				when 'DS' {
					businessSpecialization.values.destinationSpecialties.values = getSpecialties(agencyProfile.GR_Item__c,gdpReferenceValues);
				}
			}
		}
		BusinessSpecialization.values.percentageBreakdown.values = plist.values();
		return businessSpecialization;
	}

	public static List<vslabel> getSpecialties(String values,Map<String, List<String>> gdpReferenceValues) {
		List<vslabel> result = new List<vslabel>();
		if (values==null){return result;}
		List<String> parts = values.split(';');
		for(String item : parts) {
			System.debug(item);
			if(item == 'null') {item=null;}
			List<String> gvalues= (List<String>) gdpReferenceValues.get(item);
			if (gvalues==null || gvalues.size()<1){continue;}
			vslabel itm = new vslabel(gvalues[0],gvalues[1]);
			result.add(itm);
		}
		return result;
	}

	public static String getBusinessLabel(String code) {
		String label = null;
		Map<String,String> maplabel = new Map<String,String>();
		maplabel.put('TIDS_SA','Air Travel');
		maplabel.put('TIDS_SS','Cruises');
		maplabel.put('TIDS_TR','Tours & Packages');
		maplabel.put('TIDS_ME','Meetings & Events');
		maplabel.put('TIDS_SH','Accommodation');
		maplabel.put('TIDS_SL','Land Transportation');
		maplabel.put('SMOL','Online');
		maplabel.put('SMOF','Offline');
		maplabel.put('FL','Leisure');
		maplabel.put('FC','Corporate');
		return (String) maplabel.get(code);
	}

	public class WrapperBusinessProfileSpecialization {
		@AuraEnabled public sBusinessProfile businessProfile = new sBusinessProfile();
		@AuraEnabled public sBusinessSpecialization businessSpecialization = new sBusinessSpecialization();

		public void setBusinessProfileDetails(sBusinessProfile values) {
			this.businessProfile = values;
		}
		public void setBusinessSpecializationDetails(sBusinessSpecialization values) {
			this.businessSpecialization = values;
		}
	}


	public class sBusinessProfile {
		@AuraEnabled public String sectionName { get; set; }
		@AuraEnabled public String cmpName { get; set; }
		@AuraEnabled public String sectionDecision { get; set; }
		@AuraEnabled public vBusinessProfile values { get; set; }
		@AuraEnabled public List<verror> errors { get; set; }
		
		public sBusinessProfile() {
			this.values = new vBusinessProfile();
			this.errors = new List<verror>();
		}
	}

	public class vBusinessProfile {
		@AuraEnabled public vsfields principalActivities { get; set; }
		@AuraEnabled public vsfields marketFocus { get; set; }
		@AuraEnabled public vsfields salesMix { get; set; }
		@AuraEnabled public vnfields travelSales { get; set; }
		@AuraEnabled public vsfields gds { get; set; }
		@AuraEnabled public vnfields numberEmployees { get; set; }
		@AuraEnabled public vnfields numberOffices { get; set; }
	}

	public class vnfields {
		@AuraEnabled public String fieldName { get; set; }
		@AuraEnabled public String values { get; set; }
	}

	public class vsfields {
		@AuraEnabled public String fieldName { get; set; }
		@AuraEnabled public List<vslabel> values { get; set; }

		public vsfields() {
			this.values = new List<vslabel>();
		}
	}
	public class vslabel {
		@AuraEnabled public String label { get; set; }
		@AuraEnabled public String value { get; set; }
		public vslabel(String xlabel, String xvalue){
			this.label=xlabel;
			this.value=xvalue;
		}
	}

	public class sBusinessSpecialization {
		@AuraEnabled public String sectionName { get; set; }
		@AuraEnabled public String cmpName { get; set; }
		@AuraEnabled public String sectionDecision { get; set; }
		@AuraEnabled public vBusinessSpecialization values { get; set; }
		@AuraEnabled public List<verror> errors { get; set; }
		public sBusinessSpecialization() {
			this.values = new vBusinessSpecialization();
			this.errors = new List<verror>();
		}
	}
	public class vBusinessSpecialization {
		@AuraEnabled public spercentageBreakdown percentageBreakdown { get; set; }
		@AuraEnabled public smarketSpecialties marketSpecialties { get; set; }
		@AuraEnabled public sdestinationSpecialties destinationSpecialties { get; set; }
		public vBusinessSpecialization() {
			this.percentageBreakdown = new spercentageBreakdown();
			this.marketSpecialties = new smarketSpecialties();
			this.destinationSpecialties = new sdestinationSpecialties();
		}
	}
	public class spercentageBreakdown {
		@AuraEnabled public String fieldName { get; set; }
		@AuraEnabled public List<vslabel> values { get; set; }
		public spercentageBreakdown() {
			this.values = new List<vslabel>();
		}
	}
	public class smarketSpecialties {
		@AuraEnabled public String fieldName { get; set; }
		@AuraEnabled public List<vslabel> values { get; set; }
		public smarketSpecialties() {
			this.values = new List<vslabel>();
		}
	}
	public class sdestinationSpecialties {
		@AuraEnabled public String fieldName { get; set; }
		@AuraEnabled public List<vslabel> values { get; set; }
		public sdestinationSpecialties() {
			this.values = new List<vslabel>();
		}
	}

	public class verror {
		@AuraEnabled public String fieldLabel { get; set; }
		@AuraEnabled public String fieldName { get; set; }
		@AuraEnabled public String description { get; set; }
	}

}