public class ISSP_ANG_CodeSearch {
	public Long iataCode {get; set;}
	public Boolean activeSearch {get; set;}
	public Boolean activeError {get; set;}
	public Account agency {get; set;}
	public String errorMessage {get; set;}
	public String heMessage {get; set;}
	public Boolean financialSecurityExists {get; set;}
	public String iataCodeStr {get; set;}
	public Boolean showParent {get; set;}
	public List<RiskEvent> riskEventsList;
	public String riskStatus {get; set;}
	public Boolean isAll {get; set;}
	public Boolean isTravel {get; set;}
	public String riskStatusFilter {get; set;}
	public String accreditationModel {get; set;}
	public String ho_he {get; set;}
	public Boolean showIrregularities {get; set;}
	public String status {get; set;}
	public Contact contact {get; set;}
	public ANG_ISSP_AfpWrapper afpWrapper {get; set;}
	public String airlineId {get; set;}
	public ANG_RHC_Information__c rhcAgencyInfo {get; set;}

	public static Set<String> statusSet = new Set<String> {
		Ams_Utils.ACC_S9_APPROVED,
		Ams_Utils.ACC_S8_CHANGESPROCESSED,
		Ams_Utils.ACC_S0_TERMINATED,
		Ams_Utils.ACC_S5_CASHNOCOMMISSION,
		Ams_Utils.ACC_S6_CASHWITHCOMMISSION
    };

	public ISSP_ANG_CodeSearch() {
		this.riskStatusFilter = 'Active';
		this.activeSearch = false;
		this.activeError = false;
		this.showParent = false;

		this.airlineId = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Contact.AccountId;
	}

	public PageReference doSearch() {
		this.activeSearch = false;
		this.activeError = false;
		this.showParent = false;
		this.agency = null;
		this.isTravel = false;
		this.riskStatus = '';
		this.showIrregularities = false;
		this.financialSecurityExists = false;
		this.ho_he = '';

		try{
			//
			// First check is the iata code is a valid integer
			//
			this.iataCodeStr = String.valueOf(iataCode);

			//
			// Get the seach string because it can have zeros on the left.
			//
			this.iataCodeStr = Apexpages.currentPage().getParameters().get('searchString');

            if(this.iataCodeStr == null) {
               this.iataCodeStr = '';
            }
		} catch(Exception e) {
			this.iataCodeStr = '';
		}

		Integer len = iataCodeStr.length();

		//
		// IATA CODE 7-8 DIGITS => Travel Agency (Last digit is a checkcode)
		//
		// IATA CODE 10-11 DIGITS => Cargo Agency (Last digit is a checkcode)
		//
		if(len < 7 || len > 11 || len == 9) {
			this.activeError = true;
			this.errorMessage = Label.ISSP_ANG_IATA_CODE_SEARCH_INVALID;
		} else {

			if(len == 7 || len == 10) {
				iataCodeStr += '_';
			}

			String sector;
			String auxReplacement;

			if(len >= 7 && len <= 8) {
				sector = Ams_Utils.SECTOR_PASSENGER;
				auxReplacement = Label.ISSP_Travel;
				this.isTravel = true;
			} else {
				sector = Ams_Utils.SECTOR_CARGO;
				auxReplacement = Label.ISSP_Cargo;
			}

			List<Account> agencies = [SELECT Id, IATACode__c, Name, TradeName__c, Status__c, IATA_ISO_Country__r.Name, ANG_Accreditation_Model__c,
											ANG_HE_RiskStatus__c, Active_Guarantees__c, Accumulated_Irregularities__c, Location_Type__c,
											Top_Parent__c, IATA_ISO_Country__r.ANG_Enable_NewGen__c, ANG_IsNewGenAgency__c, 
											Account.ANG_IEP_Status_FF__c, Top_Parent__r.Location_Type__c 
									   	  FROM Account
									  	  WHERE Sector__c = :sector AND Status__c IN :statusSet
									    	AND RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY
									    	AND IATACode__c LIKE :iataCodeStr];

			Account airline = [SELECT Id, IATACode__c, Name, TradeName__c, Status__c, IATA_ISO_Country__r.Name, ANG_Accreditation_Model__c,
										ANG_HE_RiskStatus__c, Active_Guarantees__c, Accumulated_Irregularities__c, Location_Type__c,
										Top_Parent__c, IATA_ISO_Country__r.ANG_Enable_NewGen__c, ANG_IsNewGenAgency__c, 
										Account.ANG_IEP_Status_FF__c, Field_Head_Office__c, Top_Parent__r.Location_Type__c
								FROM Account
								WHERE Id = :this.airlineId];

			if(agencies.size() > 0) { 
				Account reqAgency = agencies[0];

				List<ANG_RHC_Information__c> rhcInfos = [SELECT Id, ANG_CashCondition__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :reqAgency.Id];

				if (rhcInfos.size() > 0) {
					rhcAgencyInfo = rhcInfos[0];
				}

				if(reqAgency.Location_Type__c == Ams_Utils.AE || reqAgency.Location_Type__c == Ams_Utils.BR || reqAgency.Location_Type__c == Ams_Utils.SA) {

					if(reqAgency.Location_Type__c == Ams_Utils.AE) {
						auxReplacement = 'an ' + Label.ISSP_ANG_ASSOCIATE_ENTITY;
					} else {
						if(reqAgency.Location_Type__c == Ams_Utils.BR) {
							auxReplacement = 'a ' + Label.ISSP_ANG_BRANCH_OFFICE;
						} else {
							auxReplacement = 'a ' + Label.ISSP_ANG_CODE_SEARCH_SA;
						}
					}

					this.showParent = true;

					String aux = Label.ISSP_ANG_IATA_CODE_SEARCH_HE.replace('%IATA_CODE%', reqAgency.IATACode__c).replace('%CHILD_LOCATION%', auxReplacement);

					Account parentAgency = [SELECT Id, IATACode__c, Name, TradeName__c, Status__c, IATA_ISO_Country__r.Name,
												   ANG_Accreditation_Model__c, ANG_HE_RiskStatus__c, Active_Guarantees__c,
												   Accumulated_Irregularities__c, Location_Type__c, IATA_ISO_Country__r.ANG_Enable_NewGen__c, 
												   ANG_IsNewGenAgency__c, Account.ANG_IEP_Status_FF__c, Top_Parent__r.Location_Type__c 
											FROM Account
											WHERE Id = :reqAgency.Top_Parent__c]; 


					String auxHoHe = Label.ISSP_ANG_IATA_CODE_SEARCH_IATA_CODE_HO_HE;
					if(parentAgency.Location_Type__c == Ams_Utils.HE) {
						auxReplacement = Label.ISSP_AMS_NoC_Head_Entity;
						this.ho_he = auxHoHe.replace('HO / HE', Label.ISSP_AMS_NoC_Head_Entity);
					} else {
						auxReplacement = Label.ISSP_AMS_NoC_Head_Office;
						this.ho_he = auxHoHe.replace('HO / HE', Label.ISSP_AMS_NoC_Head_Office);
					}

					heMessage = aux.replace('%PARENT_LOCATION%', auxReplacement);

					this.agency = parentAgency;

				} else {
					this.agency = reqAgency;
				}

				if (airline.Field_Head_Office__c == 'Branch') {
					Account parentAirline = [SELECT Id, IATACode__c, Name, TradeName__c, Status__c, IATA_ISO_Country__r.Name,
												   ANG_Accreditation_Model__c, ANG_HE_RiskStatus__c, Active_Guarantees__c,
												   Accumulated_Irregularities__c, Location_Type__c, IATA_ISO_Country__r.ANG_Enable_NewGen__c, 
												   ANG_IsNewGenAgency__c, Account.ANG_IEP_Status_FF__c, Top_Parent__r.Location_Type__c 
											FROM Account
											WHERE Id = :airline.Top_Parent__c];

					airline = parentAirline;
				}

				String serviceRenderendType;

				if (sector == Ams_Utils.SECTOR_CARGO) 
					serviceRenderendType = 'CASS Participation';
				else if (sector == Ams_Utils.SECTOR_PASSENGER) 
					serviceRenderendType = 'BSP Participation';

				Boolean countryFound = false;

				for (Services_Rendered__c service :[SELECT Id, ISO_Country_formula__c
													   FROM Services_Rendered__c
													   WHERE Services_Rendered_Type__c = :serviceRenderendType
														AND Services_Rendered_Status__c = 'Active'
													 	AND Services_Rendered_By__c = :airline.Id]) {
					if (service.ISO_Country_formula__c == this.agency.IATA_ISO_Country__r.Name) {
						countryFound = true;
						break;
					}
				}

				if (countryFound) {

					if (this.agency.IATA_ISO_Country__r.ANG_Enable_NewGen__c) afpWrapper = AMS_Utils.getANG_ISSP_AfpWrapper(null, this.agency, true);

					if (this.agency.Active_Guarantees__c != 0) this.financialSecurityExists = true;
						
					riskStatus = this.agency.ANG_HE_RiskStatus__c;

					this.accreditationModel = AMS_Utils.officialAccreditationTypeMap.get(this.agency.ANG_Accreditation_Model__c);

					this.showIrregularities = (!agency.ANG_IsNewGenAgency__c || !isTravel);

					this.status = translateAgencyStatus(agency);

					this.activeSearch = true;
				} else {
					this.activeError = true;

					if (sector == Ams_Utils.SECTOR_CARGO) 
						this.errorMessage = 'Information not available: Your Airline has no CASS Participation in the country of this IATA Code ' + this.agency.IATA_ISO_Country__r.Name;
					else if (sector == Ams_Utils.SECTOR_PASSENGER) 
						this.errorMessage = 'Information not available: Your Airline has no BSP Participation in the country of this IATA Code ' + this.agency.IATA_ISO_Country__r.Name;
				}
				
			} else {
				this.activeError = true;
				String aux = Label.ISSP_ANG_IATA_CODE_SEARCH_NOTHING_FOUND;

				this.errorMessage = aux.replace('%TYPE%', auxReplacement);
			}
		}
		return null;
    }

    public PageReference refreshRiskEventsTable() {

        riskEventsList = null;

        return null;
    }

    public List<RiskEvent> getRiskEventsList() {

		riskEventsList = new List<RiskEvent>();

		String soqlStr = 'Select ANG_Risk_Type__r.ANG_Description__c,' +
								'ANG_Issued_Date__c,' +
								'ANG_Event_Status__c,' +
								'ANG_expiration_date_ff__c,' +
								'ANG_AccountId__r.IATACode__c,' +
								'ANG_CaseId__c,' +
								'ANG_CaseId__r.CaseNumber,' +
								'ANG_Expired__c,' +
								'ANG_CaseId__r.Visible_on_ISS_Portal__c' +
						  ' From ANG_Agency_Risk_Event__c' +
						 ' Where ANG_HE_AccountId__c = \'' + this.agency.id + '\'';

		this.isAll = false;
		String filter = ' And ';
		if(this.riskStatusFilter == 'Active') {
			filter += 'ANG_Event_Status__c = \'Active\' AND ANG_Expired__c = false';
		} else if(this.riskStatusFilter == 'Expired') {
			filter += 'ANG_Expired__c = true';
		} else if(this.riskStatusFilter == 'Inactive') {
			filter += 'ANG_Event_Status__c in(\'Inactive_Withdrawn\', \'Inactive_Revoked\') AND ANG_Expired__c = false';
		} else if(this.riskStatusFilter == 'All') {
			this.isAll = true;
			filter += 'ANG_Event_Status__c  not in(\'Inactive_CHO\', \'Inactive_TER\',\'Inactive_Migrated\')';
		}

		soqlStr += filter;

		List<ANG_Agency_Risk_Event__c> events = Database.query(soqlStr);

		for(ANG_Agency_Risk_Event__c event : events) {
			riskEventsList.add(new RiskEvent(event));
		}
		return riskEventsList;
    }

	public class RiskEvent {
		public String description {get; set;}
		public Date dateAssigned {get; set;}
		public Date dateExpired {get; set;}
		public String iataCode {get; set;}
		public String caseNumber {get; set;}
		public String status {get; set;}

		public RiskEvent(ANG_Agency_Risk_Event__c event) {
			this.description = event.ANG_Risk_Type__r.ANG_Description__c;
			this.dateAssigned = event.ANG_Issued_Date__c;
			this.dateExpired = event.ANG_expiration_date_ff__c;
			this.iataCode = event.ANG_AccountId__r.IATACode__c;
			this.status = translateStatus(event.ANG_Event_Status__c, event.ANG_Expired__c);
		}

		private String translateStatus(String status, Boolean expired) {
			String retStatus = status;
			if(expired) {
				retStatus = 'Expired';
			} else if(status == 'Inactive_Withdrawn' || status == 'Inactive_Revoked') {
				retStatus = 'Inactive';
			}
			return retStatus;
		}
	}

	private String translateAgencyStatus(Account agency) {
		if(agency.Status__c == Ams_Utils.ACC_S0_TERMINATED) {
			return Label.ISSP_ANG_STATUS_TERMINATED;
		} else {
			return Label.ISSP_ANG_STATUS_APPROVED;
		}
	}
}