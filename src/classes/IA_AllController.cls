public without sharing class IA_AllController {

	@testVisible
	private static Blob EncDecKey = Blob.valueOf('I@T@M!tAS3rvIc3!');

	public Account account {get;set;}
	public Boolean hasWithdrawPermission {get;set;}
	private Set<String> setFilterNames;
	private Set<String> setFilterTypes;
	private Set<String> setFilterStatus;

	// list of select option to be used in the filter popup
	public List<SelectOption> getOptionNames() {
		return IA_util.setToOptions(this.setFilterNames,null);
	}
	public List<SelectOption> getOptionTypes() {
		return IA_util.setToOptions(this.setFilterTypes,IA_util.MAP_AGREEMENT_LABELS);
	}
	public List<SelectOption> getOptionStatus() {
		return IA_util.setToOptions(this.setFilterStatus,null);
	}

	/**
	 * initialize agreement variables to retrive them again
	 **/
	public void refreshPage() {
		this.mapAllAgreements = null;
		this.AllAgreementsRows= null;
	}

	private static List<String> VALID_STATUS = new List<String>{
		IA_Util.STATUS_ACTIVE,
		IA_Util.STATUS_NOT_ACTIVE_YET,
		IA_Util.STATUS_PENDING_WITHDRAWAL,
		IA_Util.STATUS_WITHDRAWN
	};

	/**
	 * Get the query result with all related agreements related to the input account
	 */
	private map<Id,MITA_Agreement__c> mapAllAgreements {
		get{
			if (mapAllAgreements==null) {
				mapAllAgreements = new Map<Id,MITA_Agreement__c>([
					SELECT Airline_1__c, Airline_2__c, Active__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Agreement_processed_date__c,
						Status__c, MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Comments__c, Cancellation_processed_date__c, Cancellation_Reason__c,
						Airline_1__r.Name , Airline1_designator_code__c, Airline_1__r.Airline_designator__c, Airline_1__r.Airline_Prefix__c, Airline_1__r.IATACode__c, Airline_1__r.Company_Logo__c,
						Airline_2__r.Name , Airline2_designator_code__c, Airline_2__r.Airline_designator__c, Airline_2__r.Airline_Prefix__c, Airline_2__r.IATACode__c, Airline_2__r.Company_Logo__c
					FROM MITA_Agreement__c
					WHERE (Airline_1__c = :account.Id OR Airline_2__c = :account.Id)
					AND Status__c IN :VALID_STATUS
					AND Airline_1__c != null
					AND Airline_2__c != null
					LIMIT 1000
				]);
			}
			return mapAllAgreements;
		}
		private set;
	}

	/**
	 * get a list of all agreements using a wrapper class
	 */
	public list<AllAgreementsRow> AllAgreementsRows {
		get{
			if (AllAgreementsRows==null) {
				AllAgreementsRows = new list<AllAgreementsRow>();
				//initialize filters
				this.setFilterNames = new Set<String>();
				this.setFilterTypes = new Set<String>();
				this.setFilterStatus = new Set<String>();
	
				for(MITA_Agreement__c agreement : this.mapAllAgreements.values()){
					Account otherAirline;
					String agreementType = agreement.Agreement_type__c;
					if ( agreement.Airline_1__c == this.account.Id ) {
						otherAirline = agreement.Airline_2__r;
					} else {
						otherAirline = agreement.Airline_1__r;
						// if it's a one way agreement and our airline is in second place find the oposite agreement name
						if (IA_util.MAP_ONE_WAY_TYPES.containsKey(agreement.Agreement_type__c)) {
							agreementType = IA_util.MAP_ONE_WAY_TYPES.get(agreement.Agreement_type__c);
						}
					}

					AllAgreementsRow row = new AllAgreementsRow();
					row.agreementId = IA_util.encrypt(EncDecKey,agreement.Id);
					row.otherAirlineName = otherAirline.Name;
					row.otherAirlineDesignator = otherAirline.Airline_designator__c;
					row.otherAirlineIataCode = otherAirline.IATACode__c;
					row.otherAirlinePrefix = otherAirline.Airline_Prefix__c;
					row.agreementType = IA_util.MAP_AGREEMENT_LABELS.get(agreementType);
					row.agreementName = agreement.MITAorBIETA__c;
					row.agreementStatus = agreement.Status__c;
					AllAgreementsRows.add(row);
	
					//store filters
					this.setFilterNames.add(row.agreementName);
					this.setFilterTypes.add(row.agreementType);
					this.setFilterStatus.add(row.agreementStatusLabel);
				}
				AllAgreementsRows.sort();
			}
			return AllAgreementsRows;
		}
		private set;
	}

	/**
	 * Wrapper class with the minimal agreement info to be used in the page table
	 */
	private class AllAgreementsRow implements Comparable {
		public String agreementId {get;set;}
		public String otherAirlineName {get;set;}
		public String otherAirlineDesignator {get;set;}
		public String otherAirlineIataCode {get;set;}
		public String otherAirlinePrefix {get;set;}
		public String otherAirlineLogo {get;set;}
		public String agreementType {get;set;}
		public String agreementName {get;set;}
		public String agreementStatus {get;set;}
		public String agreementStatusLabel {
			get{ 
				return IA_util.MAP_STATUS_LABELS.get(agreementStatus);
			}
		}
		public Integer compareTo(Object compareTo) {
			if (this.agreementStatus==((AllAgreementsRow)compareTo).agreementStatus) {
				return (this.otherAirlineDesignator > ((AllAgreementsRow)compareTo).otherAirlineDesignator)? 1:-1;
			}
			return (agreementStatus > ((AllAgreementsRow)compareTo).agreementStatus)? 1:-1;
		}
	}

	/***
	 * MODAL NEW AGREEMENT
	 */
	public String selectedAgreementId {get;set;}
	public MITA_Agreement__c selectedAgreement {get;set;}
	public Account selectedAgreementOtherAirline {get;set;}
	public Boolean showModalAgreementDetail {get;set;}

	/**
	 * Opens the modal to show a detail view of a single agreement
	 */
	public void openModalAgreementDetail() {
		if (String.IsEmpty(this.selectedAgreementId)) return ;
		this.selectedAgreement = this.mapAllAgreements.get(IA_util.decrypt(EncDecKey,this.selectedAgreementId));
		if (this.selectedAgreement == null) return;

		this.showModalAgreementDetail = true;
		this.selectedAgreementOtherAirline = this.selectedAgreement.Airline_1__c==this.account.Id?
			this.selectedAgreement.Airline_2__r:
			this.selectedAgreement.Airline_1__r;
	}

	/**
	 * Closes the modal to show a detail view of a single agreement
	 */
	public void closeModalAgreementDetail() {
		this.showModalAgreementDetail = false;
		this.selectedAgreementId = null;
		this.selectedAgreement = null;
		this.selectedAgreementOtherAirline = null;
		refreshPage();
	}
}
