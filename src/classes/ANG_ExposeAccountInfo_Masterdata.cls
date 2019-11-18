/***********************************************************
	2019-07-03. Author: Daniele Tullo
	Class to expose to external source account's data
	
	Interface catalogue [INT_008] Jira issue: https://iatasfdc.atlassian.net/browse/NEWGEN-4597
	confluence specification: https://iatasfdc.atlassian.net/wiki/spaces/MUL/pages/688095239/Accreditation+GO-Global+Requirements

***********************************************************/

public without sharing class ANG_ExposeAccountInfo_Masterdata {
	
	public static final Set<String> dueDiligenceIEPChangeCodes = new Set<String>{'MBDIL','MAPDF','MaddY', AMS_Utils.MBPDD_CHANGE_CODE};
	public static final string CurrencyBSP = 'BspCurrency';
	public static final string CurrencyMulticountry = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

	/***************************************
				Constructor
	***************************************/

	public static void ANG_ExposeAccountInfo_Masterdata(map<id, Account> mapAccnt, string sMode, string sChangeCode) {
		try{
			list<INT008_SuccessPayload> lsToReturn = new list<INT008_SuccessPayload>();
			
			switch on sMode {
				when 'F' {
					map<id, list<AMS_Account_Role__c>> mapOwner = fetchHierarchyOwners(mapAccnt.values());
					for(account accnt:mapAccnt.values()){
						lsToReturn.add(new INT008_SuccessPayload(accnt, sChangeCode, fetchOwners(mapOwner, accnt)));
					}
				}
				when 'S' {
					list<Account> lsAccntToFetchOwner = mapAccnt.values();
					//add fakes account
					for(Account accnt:mapAccnt.values()){ //only 1 acount is coming here
						if(!string.isBlank(accnt.ParentId)) lsAccntToFetchOwner.add(new Account(id=accnt.ParentId));
						if(!string.isBlank(accnt.Top_Parent__c)) lsAccntToFetchOwner.add(new Account(id=accnt.Top_Parent__c));
					}

					map<id, list<AMS_Account_Role__c>> mapOwner = fetchHierarchyOwners(lsAccntToFetchOwner);
					for(account accnt:mapAccnt.values()){
						lsToReturn.add(new INT008_SuccessPayload(accnt, sChangeCode, fetchOwners(mapOwner, accnt)));
					}
				}
				when 'P' {
					//NOT Optimal, but is limited to 2 additional queries.
					for(Account accnt:mapAccnt.values()){ //only 1 account is coming here
						list<Account> lsAccntTmp;
						if(!string.isBlank(accnt.Parent.IATACode__c)){
							for(Account acc: QueryAgencyToProcess('S', accnt.Parent.IATACode__c)){
								mapAccnt.put(acc.Id, acc);
							}
						}

						if(!string.isBlank(accnt.Top_Parent__r.IATACode__c)){
							if(accnt.Top_Parent__c <> accnt.ParentID) //useless to query twice the same record if parent = top parent
								for(Account acc: QueryAgencyToProcess('S', accnt.Top_Parent__r.IATACode__c)){
									mapAccnt.put(acc.Id, acc);
								}
						}
					}

					map<id, list<AMS_Account_Role__c>> mapOwner = fetchHierarchyOwners(mapAccnt.values());
					for(account accnt:mapAccnt.values()){
						lsToReturn.add(new INT008_SuccessPayload(accnt, sChangeCode, fetchOwners(mapOwner, accnt)));
					}

				}
				when else {
					ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('403', 'Wrong mode') ), 403);
				}
			}

			ANG_RestServiceHelper.GenerateResponse(json.serialize(lsToReturn, true), 200);
		}
		catch(exception e){
			ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
		}
	}


	/***************************************
				Helper Methods
	***************************************/
	private static list<AMS_Account_Role__c> fetchOwners(map<id, list<AMS_Account_Role__c>> mapOwners, Account accnt){
		if(mapOwners.containsKey(accnt.id)) return mapOwners.get(accnt.ID);

		if(!string.isBlank(accnt.ParentId)){
			if(mapOwners.containsKey(accnt.ParentId)) return mapOwners.get(accnt.ParentId);
		}

		if(!string.isBlank(accnt.Top_Parent__c)){
			if(mapOwners.containsKey(accnt.Top_Parent__c)) return mapOwners.get(accnt.Top_Parent__c);
		}

		return new List<AMS_Account_Role__c>();
	}

	private static string FormatDateMS(date theDate){
		if(theDate==null) return null;
		else return theDate.Year() + '-' + string.valueOf(theDate.Month()).leftPad(2).replace(' ', '0') + '-' + string.valueOf(theDate.Day()).leftPad(2).replace(' ', '0');
	}

	public static list<Account> QueryAgencyToProcess (string MDMode, string IATACode){
		Set<String> iEPRecordTypes = new Set<String>{AMS_Utils.RECTYPE_BANK_ACCOUNT_SETUP,AMS_Utils.RECTYPE_IEPMODELA,AMS_Utils.RECTYPE_IEPMODELB, AMS_Utils.RECTYPE_IEPMODELBPLUS};
					
		string sQueryMD = 'select Guaranteed_amount__c, CurrencyIsoCode, Due_Diligence_Status__c, ANG_IsNewGenAgency__c, Is_Branch_Abroad__c, Purge_Flag__c, Accreditation_date__c, Date_Organisation_Status_attained__c, Default_date__c, ANG_Accreditation_Model__c, billingCity, billingCountry, billingPostalCode,'
							+' billingState, billingStreet, IATA_ISO_Country__r.BSP_Country_free_text__c, IATA_ISO_Country__r.ISO_Code_Numeric__c, IATA_ISO_Country__r.ISO_Code__c, '
							+' Email__c, fax, IATACode__c, Id, ANG_IEP_Status_FF__c, Location_Class__c, Location_Type__c, Name, Parent.IATACode__c, phone, '
							+' IATA_ISO_Country__r.ANG_Portal_Service__r.Name, IATA_ISO_Country__r.Region__c, Reason__c, Remittance_frequency__c, Status__c, Tax_ID_1__c, TradeName__c, '
							+' VAT_Number__c, ANG_RiskStatus__c, Segmentation__c, Top_Parent__r.IATACode__c,IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, Top_Parent__c, ParentId,'
							+' GDI_Status__c, Location_Type_Ordered__c, Multicountry_Key_Hierarchy__c, Identify_as_Key_Customer__c, Is_PCI_compliant__c  '
							+' , (Select Id, recordtype.developername, Email_Used_for_BSP_Creation__c, ANG_FormOfPayment_ID__c, Status__c From Agency_Authorizations__r where recordtype.developername in (\'BSPLink\',\'FormOfPayment\'))'  //Accelya Email + FOP
							+' , (Select Id, IATACode__c, Status__c, Is_PCI_compliant__c From ChildAccounts where Purge_Flag__c = false and IATACode__c != null and recordtypeId = \'' + AMS_Utils.RECTYPE_IATAAGENCY + '\' )' //List of children
							+' , (Select Id, ANG_RHC_Amount__c, CurrencyIsoCode, ANG_Financial_Security__c From RHC_Informations__r)'  //RHC Information
							+' , (Select Id, STEP17__c, STEP41__c From OSCARs__r where RecordTypeId IN :iEPRecordTypes ORDER BY LastModifiedDate DESC)' //OSCAR
							+' , (select Hierarchy__c, Hierarchy__r.name from AMS_Agencies_relationships__r limit 1)' //hierarchy name
							+' , (select Id, Name, Main_account__c from Main_Accounts__r)'
//                          +' , (Select Id, Percentage__c, Owner_Name__c,Owner_Account__r.Name, Contact__r.Name From AMS_Account_Roles1__r where Active__c = true and RecordType.Name = \'Ownership\') ' // List of Ownwer
							+' from Account';

		if(MDMode=='F'){
			sQueryMD = sQueryMD + ' where recordtypeId = \'' + AMS_Utils.RECTYPE_IATAAGENCY + '\' and (IATACode__c =:IATACode or Top_Parent__r.IATACode__c =:IATACode)';
		}else{
			sQueryMD = sQueryMD + ' where recordtypeId = \'' + AMS_Utils.RECTYPE_IATAAGENCY + '\' and IATACode__c =:IATACode';
		}

		sQueryMD = sQueryMD + ' order by Location_Type_Ordered__c asc';

		return database.query(sQueryMD);
	}

	private static  map<id, list<AMS_Account_Role__c>> fetchHierarchyOwners(list<Account> lsAccnt){
		map<id, list<AMS_Account_Role__c>> mapOwner= new map<id, list<AMS_Account_Role__c>>();
		set<id> setAccntId = new set<id>(); //add all IDS, ParentID, Top_Parent ID
		for(account accnt:lsAccnt){
			setAccntId.add(accnt.Id);
			if(!string.isBlank(accnt.ParentID)) setAccntId.add(accnt.ParentID);
			if(!string.isBlank(accnt.Top_Parent__c)) setAccntId.add(accnt.Top_Parent__c);
		}

		for(Account Accnt: [select id, (Select Id, Percentage__c, Owner_Name__c,Owner_Account__r.Name, Contact__r.Name From AMS_Account_Roles1__r where Active__c = true and RecordType.Name = 'Ownership') from account where id in:setAccntId]){
			if(accnt.AMS_Account_Roles1__r.size()>0)
				mapOwner.put(accnt.id, accnt.AMS_Account_Roles1__r);
		}

		return mapOwner;
	}


	/******************************************
			Classes that define payload
	******************************************/


	/* RHC Information */

	private class RHCInfoClass{
		public string RiskStatus;
		public Decimal RHCAmount; //Number + currency
		public string RHCCurrency;
		public Decimal RHCTotalFSProvided;
		public RHCInfoClass(string RiskStatus, Decimal RHCAmount, string RHCCurrency, Decimal RHCTotalFSProvided){
			this.RiskStatus = RiskStatus==null?'':RiskStatus;
			this.RHCAmount = RHCAmount;
			this.RHCCurrency= RHCCurrency==null?'':RHCCurrency;
			this.RHCTotalFSProvided = RHCTotalFSProvided;
		}
	}

	/* Currency Wrapper */
	private class theCurrency{
		public string currencyCode;
		public string type;
		public theCurrency(string type, string currencyCode){
			this.type = type;
			this.currencyCode = currencyCode;
		}
	}
	
	/* Form Of Payment */
	private class FOP{
		public string Type;     //CA, CE, EP
		public string Status;
		public FOP(string Type, string Status){
			this.Type = Type==null?'':Type;
			this.Status = Status==null?'':Status;
		}
	}

	/* Owners*/
	private class Owner{
		public string name;
		public double percentage;
		public Owner(AMS_Account_Role__c role, double percentage){
			if (role.Owner_Account__c != null) {
				this.name = role.Owner_Account__r.Name;
			} else if (role.Contact__c != null) {
				this.name = role.Contact__r.Name;
			} else {
				this.name = role.Owner_Name__c;
			}

			this.percentage = percentage == null ? 0 : percentage; 
		}
	}

	/* Due Diligence */
	private class DueDiligence{
		public string type;
		public string status;
		
		public DueDiligence(string type, string status){
			this.type = type;
			this.status = status;
		}
	}

	private static Map<String, Boolean> pciCompliantFldMapping = new Map<String, Boolean>{
		'Yes' => TRUE,
		'No' => FALSE,
		'Nil CC' => FALSE,
		'Corporate Card' => TRUE
	};

	/* Succesfull payload when the caller is Mulesoft */
	@TestVisible
	private class INT008_SuccessPayload{
		/* Agency Information */
		public string isBranchAbroad;
		public boolean PurgeCode;
		public string AccreditationDate;
		public string DefaultDate;
		public string LastStatusChangeDate;
		public string AccelyaEmail;     //From Agency Authorization
		public string AccreditationType;
		public string agencyType;
		public string billingCity;
		public string billingCountry;
		public string billingPostalCode;
		public string billingState;
		public string billingStreet;
		public string bspCountry;
		public string countryCodeNumeric;
		public string countryISOCode;
		public string email;
		public string fax;
		public string IATACode;
		//public string id; //Silence for now
		public string IEPStatus;
		public string LocationClass;
		public string locationType;
		public string name;
		public string parentIATACode;
		public string phone;
		public string portalServiceName;
		public string Region;
		public string RelinquishmentCode; //ReasonCode
		public string RemittanceFrequency;
		public string Segmentation; 
		public string status;
		public string TaxID;
		public string TradeName;
		public string vatNumber;        
		public string topParentIATACode;
		public list<FOP> FormOfPayment;
		public RHCInfoClass RHCInfo;    //Risk Information
		//public list<string> lsChildren; //List of Children IATA Code
		public string dueDiligenceStatus;
		public boolean isNewGenAgency;
		public list<Owner> owners;
		public list<DueDiligence> dueDiligence;
		public list<string> externalSystems; //NEWGEN-4276
		public Boolean isPciDss;
		public list<theCurrency> currencies;
		public string hierarchyId;
		public boolean isMultiCountryKeyCustomer;

		/*Constructor*/
		public INT008_SuccessPayload(Account acc, String changeCode, list<AMS_Account_Role__c> lsAccRoleOwners){
			set<string> setIEPStatusToPublish = new set<string>{'Open','In Progress'};
			set<string> setGDIStatusToPublish = new set<string>{'Open','In Progress'};
			try{
				this.hierarchyId = acc.Main_Accounts__r.isEmpty() ? acc.AMS_Agencies_relationships__r.isEmpty() ? null : acc.AMS_Agencies_relationships__r.get(0).hierarchy__r.Name : acc.Main_Accounts__r.get(0).Name;
				this.isBranchAbroad = acc.Is_Branch_Abroad__c;
				this.PurgeCode = acc.Purge_Flag__c;
				this.AccreditationDate = FormatDateMS(acc.Accreditation_date__c);
				this.DefaultDate = FormatDateMS(acc.Default_date__c);
				this.LastStatusChangeDate = String.ValueOf(acc.Date_Organisation_Status_attained__c) ;
				this.dueDiligenceStatus = acc.Due_Diligence_Status__c;
				this.AccreditationType = acc.ANG_Accreditation_Model__c;
				this.agencyType = '';
				this.billingCity = acc.billingCity;
				this.billingCountry = acc.billingCountry;
				this.billingPostalCode = acc.billingPostalCode;
				this.billingState = acc.billingState;
				this.billingStreet = acc.billingStreet;
				this.bspCountry = acc.IATA_ISO_Country__r.BSP_Country_free_text__c;
				this.countryCodeNumeric = string.valueOf(acc.IATA_ISO_Country__r.ISO_Code_Numeric__c);
				this.countryISOCode = acc.IATA_ISO_Country__r.ISO_Code__c;
				this.email = acc.Email__c;
				this.fax = acc.fax;
				this.IATACode = acc.IATACode__c;
				//this.id = acc.Id; // Silence for now
				this.IEPStatus = acc.ANG_IEP_Status_FF__c;
				this.LocationClass = acc.Location_Class__c;
				this.locationType = acc.Location_Type__c;
				this.name = acc.Name;
				this.parentIATACode = acc.Parent.IATACode__c;
				this.phone = acc.phone;
				this.portalServiceName = acc.IATA_ISO_Country__r.ANG_Portal_Service__r.Name;
				this.Region = acc.IATA_ISO_Country__r.Region__c;
				//this.guaranteedAmount = string.valueOf(acc.Guaranteed_amount__c); //Silenced for now
				//this.guaranteedAmountCurrency = acc.CurrencyIsoCode; //Silenced for now
				this.RelinquishmentCode =acc.Reason__c!=null?acc.Reason__c.split('-').get(0).leftPad(2,'0'):acc.Reason__c;
				this.RemittanceFrequency = acc.Remittance_frequency__c;
				this.Segmentation = acc.Segmentation__c;
				this.status = acc.Status__c;
				this.TaxID = acc.Tax_ID_1__c;
				this.TradeName = acc.TradeName__c;
				this.vatNumber = acc.VAT_Number__c;
				this.topParentIATACode = acc.Top_Parent__r.IATACode__c;
				this.dueDiligence = new List<DueDiligence>();
				this.isMulticountryKeyCustomer = acc.Multicountry_Key_Hierarchy__c;

				/* Due Diligence to IEP - NEWGEN-3857 NEWGEN-3841 NEWGEN-4000*/
				if(dueDiligenceIEPChangeCodes.contains(changeCode) && acc.oscars__r != null && acc.oscars__r.size()>0){
					if(changeCode == 'MaddY')
						this.dueDiligence.add(new DueDiligence(changeCode, ((acc.oscars__r[0] != null && acc.oscars__r[0].step41__c == 'Passed' && acc.oscars__r[0].step17__c == 'Passed') ?  'Passed' : 'Failed'  )));
					else
						this.dueDiligence.add(new DueDiligence(changeCode, (acc.oscars__r[0] != null ?  acc.oscars__r[0].step17__c : 'Failed'  )));                    
				}

				list<theCurrency> lsCurrencies = new list<theCurrency>();
				string sBSPCurrency = acc.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode;
				
				lsCurrencies.add(new theCurrency(CurrencyBSP, sBSPCurrency));

				//Risk Info
				for(ANG_RHC_Information__c rhc:acc.RHC_Informations__r){
					this.RHCInfo = new RHCInfoClass(acc.ANG_RiskStatus__c, rhc.ANG_RHC_Amount__c, acc.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, rhc.ANG_Financial_Security__c);
					if(this.AccreditationType == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY) {
						lsCurrencies.add(new theCurrency(CurrencyMulticountry, rhc.CurrencyIsoCode));
					}
				}

				if(this.RHCInfo ==null)
				this.RHCInfo = new RHCInfoClass(null,
					null,
					String.IsBlank(sBSPCurrency)?acc.CurrencyIsoCode:sBSPCurrency,
					String.IsBlank(sBSPCurrency)?acc.Guaranteed_amount__c:ANG_Risk_Helper.currencyConverter(acc.CurrencyIsoCode, acc.Guaranteed_amount__c,acc.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode)
				);
								
				this.currencies = lsCurrencies;

				this.FormOfPayment = new list<FOP>();
				//Form of Payment and AcceleyaEmail
				if(!acc.Agency_Authorizations__r.isEmpty()){
					for(Agency_Authorization__c aa:acc.Agency_Authorizations__r){
						if(aa.RecordType.Developername=='BSPLink'){
							if(aa.Status__c == 'Active')
								this.AccelyaEmail = aa.Email_Used_for_BSP_Creation__c;      //From Agency Authorization
						}
						else
							this.FormOfPayment.add(new FOP(aa.ANG_FormOfPayment_ID__c, aa.Status__c));
					}
				}

				this.isNewGenAgency = acc.ANG_IsNewGenAgency__c;

				//Owners
				this.owners = new List<Owner>();
				for(AMS_Account_Role__c role :lsAccRoleOwners){
					this.owners.add(new Owner(role, (double)role.Percentage__c));
				}

				//externalSystems - NEWGEN-4276
				this.externalSystems = new list<string>();
				//EasyPay
				if(string.isNotBlank(acc.ANG_IEP_Status_FF__c) && setIEPStatusToPublish.contains(acc.ANG_IEP_Status_FF__c))
					this.externalSystems.add(acc.IATA_ISO_Country__r.ANG_Portal_Service__r.Name);

				//GDI - note: we do publish HE/HO only
				if(string.isNotBlank(acc.GDI_Status__c) && setGDIStatusToPublish.contains(acc.GDI_Status__c))
				   this.externalSystems.add(ISSP_Financial_Institutions.GDI_PORTAL_SERVICE); //check if we do have it somewhere in any static variable
				
				//Fill isPciDss attribute for every Account IEP Status except "No IEP Account" or blank 
				if(String.isNotBlank(acc.ANG_IEP_Status_FF__c) && acc.ANG_IEP_Status_FF__c != AMS_Utils.NO_IEP_ACCOUNT){
					this.isPciDss = String.isNotBlank(acc.Is_PCI_compliant__c) ? pciCompliantFldMapping.get(acc.Is_PCI_compliant__c) : FALSE;
				}

			}
			catch(exception e){
				throw e;
			}
		}
	}
}