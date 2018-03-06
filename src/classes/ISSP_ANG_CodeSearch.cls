public with sharing class ISSP_ANG_CodeSearch {
	public Long iataCode {get; set;}
	public Boolean activeSearch {get; set;}
	public Boolean activeError {get; set;}
	public Account agency {get; set;}
	public String errorMessage {get; set;}
	public String heMessage {get; set;}
	public Boolean financialSecurityExists {get; set;}
	public String iataCodeStr {get; set;}
	public Boolean showParent {get; set;}
	public List<RiskEvent> riskEventsList {get; set;}
	public String riskStatus {get; set;}

	public ISSP_ANG_CodeSearch() {
		this.activeSearch = false;
		this.activeError = false;
		this.showParent = false;
	}

	public PageReference doSearch() {
		this.activeSearch = false;
		this.activeError = false;
		this.showParent = false;
		this.agency = null;
		this.riskStatus = '';
		this.financialSecurityExists = false;

		try{
			this.iataCodeStr = String.valueOf(iataCode);	
		} catch(Exception e) {
			this.iataCodeStr = '';
		}		

		Integer len = iataCodeStr.length();

		//
		// IATA CODE 7-8 DIGITS => Travel Agency
		//
		// IATA CODE 10-11 DIGITS => Cargo Agency
		//
		if(len < 7 || len > 11 || len == 9) {
			this.activeError = true;
			this.errorMessage = Label.ISSP_ANG_IATA_CODE_SEARCH_INVALID;
		} else {

			String sector;
			String auxReplacement;

			if(len >= 7 && len <= 8) {
				sector = Ams_Utils.SECTOR_PASSENGER;
				auxReplacement = Label.ISSP_Travel;
			} else {
				sector = Ams_Utils.SECTOR_CARGO;
				auxReplacement = Label.ISSP_Cargo;
			}

			Set<String> statusSet = new Set<String>();
			statusSet.add(Ams_Utils.ACC_S9_APPROVED);
			statusSet.add(Ams_Utils.ACC_S8_CHANGESPROCESSED);
			statusSet.add(Ams_Utils.ACC_S0_TERMINATED);
			statusSet.add(Ams_Utils.ACC_S5_CASHNOCOMMISSION);
			statusSet.add(Ams_Utils.ACC_S6_CASHWITHCOMMISSION);

			List<Account> auxList = [Select id,
											IATACode__c,
											Legal_name__c,
											TradeName__c,
											IATA_ISO_Country__r.Name,
											ANG_Accreditation_Model__c,
											ANG_HE_RiskStatus__c,
											Active_Guarantees__c,
											Accumulated_Irregularities__c,
											Location_Type__c,
											ParentId,
											IATA_ISO_Country__r.ANG_Enable_NewGen__c
									   From Account 
									  Where Sector__c =: sector
									    And Status__c in: statusSet
									    And RecordTypeId =: AMS_Utils.RECTYPE_IATAAGENCY
									    And IATACode__c =: iataCodeStr];									    

			if(auxList.size() != 0) {
				Account auxAgency = auxList[0];
				
				if(auxAgency.Location_Type__c == Ams_Utils.AE || auxAgency.Location_Type__c == Ams_Utils.BR) {

					if(auxAgency.Location_Type__c == Ams_Utils.AE) {
						auxReplacement = Label.ISSP_ANG_ASSOCIATE_ENTITY;
					} else {
						auxReplacement = Label.ISSP_ANG_BRANCH_OFFICE;
					}

					this.showParent = true;

					String aux = Label.ISSP_ANG_IATA_CODE_SEARCH_HE;
					String aux2 = aux.replace('%IATA_CODE%', iataCodeStr);
					String aux3 = aux2.replace('%CHILD_LOCATION%', auxReplacement);

					Account parentAgency = [Select id,
												   IATACode__c,
												   Legal_name__c,
												   TradeName__c,
												   IATA_ISO_Country__r.Name,
												   ANG_Accreditation_Model__c,
												   ANG_HE_RiskStatus__c,
												   Active_Guarantees__c,
												   Accumulated_Irregularities__c,
												   Location_Type__c,
												   IATA_ISO_Country__r.ANG_Enable_NewGen__c
											  From Account
											 Where id =: auxAgency.parentId];					

					if(parentAgency.Location_Type__c == Ams_Utils.HE) {
						auxReplacement = Label.ISSP_AMS_NoC_Head_Entity;
					} else {
						auxReplacement = Label.ISSP_AMS_NoC_Head_Office;
					}

					heMessage = aux3.replace('%PARENT_LOCATION%', auxReplacement);		 

					this.agency = parentAgency;

				} else {
					this.agency = auxAgency;
				}
				
				if(this.agency.Active_Guarantees__c != 0) {
					this.financialSecurityExists = true;
				}

				riskStatus = this.agency.ANG_HE_RiskStatus__c;

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


				List<ANG_Agency_Risk_Event__c> events = Database.query(soqlStr);

				for(ANG_Agency_Risk_Event__c event : events) {
					if(event.ANG_CaseId__c == null || (event.ANG_CaseId__c != null && event.ANG_CaseId__r.Visible_on_ISS_Portal__c))
						riskEventsList.add(new RiskEvent(event));
				}

				this.activeSearch = true;
			} else {
				this.activeError = true;
				String aux = Label.ISSP_ANG_IATA_CODE_SEARCH_NOTHING_FOUND;

				this.errorMessage = aux.replace('%TYPE%', auxReplacement);
			}									    		
		}
		return null;
    }	

	public class RiskEvent {
		public String description {get; set;}
		public Date dateAssigned {get; set;}
		public Date dateExpired {get; set;}
		public String iataCode {get; set;}
		public String caseNumber {get; set;}
		public String caseId  {get; set;}
		public String caseNumberLink {get; set;}
		public String status {get; set;}

		public RiskEvent(ANG_Agency_Risk_Event__c event) {
			this.description = event.ANG_Risk_Type__r.ANG_Description__c;
			this.dateAssigned = event.ANG_Issued_Date__c;
			this.dateExpired = event.ANG_expiration_date_ff__c;
			this.iataCode = event.ANG_AccountId__r.IATACode__c;

			if(event.ANG_CaseId__c != null && event.ANG_CaseId__r.CaseNumber != null && event.ANG_CaseId__r.Visible_on_ISS_Portal__c) {
				this.caseId = event.ANG_CaseId__c;
				this.caseNumber = event.ANG_CaseId__r.CaseNumber;
				this.caseNumberlink = '<a href="/ISSP_Case?caseId=' + this.caseId + '&mid=M1S2">' + this.caseNumber + '</a>';
			}
		
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
}