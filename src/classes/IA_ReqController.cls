public without sharing class IA_ReqController {

	@testVisible
	private static Blob EncDecKey = Blob.valueOf('I@T@M!tAS3rvIc3!');

	public static final String ALERT_SUCCESS = 'success';
	public static final String ALERT_REJECTED = 'rejected';
	public static final String ALERT_UNDO = 'undo';
	public static final String ALERT_FAIL = 'fail';

	public Account account {get;set;}
	public Boolean hasApprovePermission {get;set;}
	public String selectedAgreement {get;set;}
	public IA_util.AlertModal toast {get;set;}
	private Set<String> setFilterNames;
	private Set<String> setFilterTypes;
	private Set<String> setFilterStatus;

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
		this.mapAgreements = null;
		this.RequesterAgreementsRows= null;
	}

	private Map<Id,MITA_Agreement__c> mapAgreements {
		get{
			if (mapAgreements==null) {
				mapAgreements = new Map<Id,MITA_Agreement__c>([
					SELECT Id, MITAorBIETA__c, Agreement_type__c, Active__c, Status__c, Created_date__c, Effective_date__c, Agreement_processed_date__c, Cancellation_date__c, Cancellation_Reason__c, Cancellation_processed_date__c,
						Airline_1__c, Airline_1__r.Name , Airline1_designator_code__c, Airline_1__r.Airline_designator__c, Airline_1__r.Airline_Prefix__c, Airline_1__r.IATACode__c,Airline_1__r.Logo_File_ID__c,Airline_1__r.Company_Logo__c,
						Airline_2__c, Airline_2__r.Name , Airline2_designator_code__c, Airline_2__r.Airline_designator__c, Airline_2__r.Airline_Prefix__c, Airline_2__r.IATACode__c,Airline_2__r.Logo_File_ID__c,Airline_2__r.Company_Logo__c
					FROM MITA_Agreement__c
					WHERE (Airline_1__c = :account.Id OR Airline_2__c = :account.Id)
					AND Status__c IN (:IA_Util.STATUS_PENDING_APPROVAL, :IA_Util.STATUS_REJECTED)
					AND Airline_1__c != null
					AND Airline_2__c != null
					ORDER BY Airline_1__r.Name ASC
					LIMIT 1000
				]);
			}
			return mapAgreements;
		}
		private set;
	}

	public list<RequestAgreementsRow> RequesterAgreementsRows {
		get {
			if (RequesterAgreementsRows==null) {
				//initialize filters
				this.setFilterNames = new Set<String>();
				this.setFilterTypes = new Set<String>();
				this.setFilterStatus = new Set<String>();

				RequesterAgreementsRows = new list<RequestAgreementsRow>();
				for(MITA_Agreement__c agreement : this.mapAgreements.values()){
					// if it's a one way agreement and our airline is in second place find the oposite agreement name
					String agreementType = agreement.Agreement_type__c;
					if (this.account.Id == agreement.Airline_2__c && IA_util.MAP_ONE_WAY_TYPES.containsKey(agreementType)) {
						agreementType = IA_util.MAP_ONE_WAY_TYPES.get(agreementType);
					}

					RequestAgreementsRow row = new RequestAgreementsRow();
					row.agreementId = IA_util.encrypt(EncDecKey,agreement.Id);
					row.agreementName = agreement.MITAorBIETA__c;
					row.agreementType = IA_util.MAP_AGREEMENT_LABELS.get(agreementType);
					row.requesterName = agreement.Airline_1__r.Name;
					row.requesterDesignator = agreement.Airline1_designator_code__c;
					row.approverName = agreement.Airline_2__r.Name;
					row.approverDesignator = agreement.Airline2_designator_code__c;
					row.effectiveDate = IA_util.dateformat(agreement.Effective_date__c);
					row.agreementStatus = agreement.Status__c;
					row.showAproveRejectButtons = (agreement.Status__c == IA_Util.STATUS_PENDING_APPROVAL && this.hasApprovePermission && this.account.Id == agreement.Airline_2__c);
					RequesterAgreementsRows.add(row);
					//store filters
					this.setFilterNames.add(row.agreementName);
					this.setFilterTypes.add(row.agreementType);
					this.setFilterStatus.add(row.agreementStatus);
				}
				// show lines in specific order
				list<RequestAgreementsRow> listApprove = new list<RequestAgreementsRow>();
				list<RequestAgreementsRow> listRequest = new list<RequestAgreementsRow>();
				list<RequestAgreementsRow> listRejected = new list<RequestAgreementsRow>();
				for(RequestAgreementsRow row : RequesterAgreementsRows){
					if (row.showAproveRejectButtons) {
						listApprove.add(row);
					} else if (row.agreementStatus==IA_Util.STATUS_PENDING_APPROVAL) {
						listRequest.add(row);
					} else if(row.agreementStatus==IA_Util.STATUS_REJECTED) {
						listRejected.add(row);
					}
				}
				RequesterAgreementsRows = new list<RequestAgreementsRow>();
				RequesterAgreementsRows.AddAll(listApprove);
				RequesterAgreementsRows.addAll(listRequest);
				RequesterAgreementsRows.addAll(listRejected);
			}
			return RequesterAgreementsRows;
		}
		private set;
	}

	public class RequestAgreementsRow {
		public String agreementId {get;set;}
		public String agreementName {get;set;}
		public String agreementType {get;set;}
		public String requesterName {get;set;}
		public String requesterDesignator {get;set;}
		public String approverName {get;set;}
		public String approverDesignator {get;set;}
		public String effectiveDate {get;set;}
		public String agreementStatus {get;set;}
		public Boolean showAproveRejectButtons {get;set;}
		public String agreementStatusLabel {
			get{ 
				return IA_util.MAP_STATUS_LABELS.get(agreementStatus);
			}
		}
	}

	/**
	 * save selected agreement for approval
	 **/
	public void approveAgreement() {
		if (!this.hasApprovePermission && this.selectedAgreement!=null) return;

		MITA_Agreement__c agreement = this.mapAgreements.get(IA_util.decrypt(EncDecKey,this.selectedAgreement));

		MITA_Agreement__c undoAgreement = new MITA_Agreement__c(
			Id = agreement.Id,
			Agreement_processed_date__c = agreement.Agreement_processed_date__c,
			Effective_date__c = agreement.Effective_date__c
		);
		
		agreement.Agreement_processed_date__c = Date.today();
		if (agreement.Effective_date__c < Date.today()) {
			agreement.Effective_date__c = Date.today();
		}
		Database.SaveResult result = Database.update(agreement,false);
		if (result.isSuccess()) {
			refreshPage();
			String undoActionId = createUndoAction(undoAgreement);
			this.toast = new IA_util.AlertModal(ALERT_SUCCESS,Label.IA_Request_Approved, undoActionId);

		} else {
			this.toast = new IA_util.AlertModal(ALERT_FAIL,Label.IA_Approving_Problem,null);
		}
	}

	public void rejectAgreement() {
		if (!this.hasApprovePermission && this.selectedAgreement!=null) return;

		MITA_Agreement__c agreement = this.mapAgreements.get(IA_util.decrypt(EncDecKey,this.selectedAgreement));

		MITA_Agreement__c undoAgreement = new MITA_Agreement__c(
			Id = agreement.Id,
			Cancellation_date__c = agreement.Cancellation_date__c,
			Cancellation_processed_date__c = agreement.Cancellation_processed_date__c,
			Cancellation_Reason__c = agreement.Cancellation_Reason__c
		);

		agreement.Cancellation_date__c = Date.today();
		agreement.Cancellation_processed_date__c = Date.today();
		agreement.Cancellation_Reason__c = IA_Util.REASON_REJECTION;

		Database.SaveResult result = Database.update(agreement,false);
		if (result.isSuccess()) {
			//force recalculation of requested agreements
			this.mapAgreements = null;
			this.RequesterAgreementsRows = null;

			String undoActionId = createUndoAction(undoAgreement);
			this.toast = new IA_util.AlertModal(ALERT_REJECTED,Label.IA_Request_Rejected, undoActionId);

		} else {
			this.toast = new IA_util.AlertModal(ALERT_FAIL,Label.IA_Rejecting_Problem,null);
		}
	}

	private map<String,MITA_Agreement__c> mapUndoActions = new map<String,MITA_Agreement__c>();
	private String createUndoAction(MITA_Agreement__c agreement) {
		String newId = IA_util.randomString(8);
		this.mapUndoActions.put(newId,agreement);
		return newId;
	}

	public String undoId {get;set;}
	public void undoAction() {
		MITA_Agreement__c agreement = this.mapUndoActions.get(this.undoId);
		if (agreement==null) return;

		Database.SaveResult result = Database.update(agreement,false);
		if (result.isSuccess()) {
			//force recalculation of requested agreements
			this.mapAgreements = null;
			this.RequesterAgreementsRows = null;

			this.toast = new IA_util.AlertModal(ALERT_UNDO,Label.IA_Action_Reverted,null);

		} else {
			this.toast = new IA_util.AlertModal(ALERT_FAIL,Label.IA_Undoing_Problem,null);
		}
	}

	public void resetToast() {
		this.toast = null;
	}

	/***
	 * MODAL AGREEMENT DETAILS
	 */
	public String selectedAgreementId {get;set;}
	public MITA_Agreement__c selectedAgreementDetail {get;set;}
	public Account selectedAgreementOtherAirline {get;set;}
	public Boolean showModalAgreementDetail {get;set;}

	/**
	 * Opens the modal to show a detail view of a single agreement
	 */
	public void openModalAgreementDetail() {
		if (String.IsEmpty(this.selectedAgreementId)) return ;
		this.selectedAgreementDetail = this.mapAgreements.get(IA_util.decrypt(EncDecKey,this.selectedAgreementId));
		if (this.selectedAgreementDetail == null) return;

		this.showModalAgreementDetail = true;
		if (this.account.Id == this.selectedAgreementDetail.Airline_1__c) {
			this.selectedAgreementOtherAirline = this.selectedAgreementDetail.Airline_2__r;
		} else {
			this.selectedAgreementOtherAirline = this.selectedAgreementDetail.Airline_1__r;
		}
	}

	/**
	 * Closes the modal to show a detail view of a single agreement
	 */
	public void closeModalAgreementDetail() {
		this.showModalAgreementDetail = false;
		this.selectedAgreementId = null;
		this.selectedAgreementDetail = null;
		this.selectedAgreementOtherAirline = null;
	}
}
