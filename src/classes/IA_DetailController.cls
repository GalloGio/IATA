public without sharing class IA_DetailController {

	public static final String HISTORY_CREATED = 'created';
	public static final String HISTORY_AGREEMENT_FIELDNAME = 'Agreement_processed_date__c';
	public static final String HISTORY_CANCELLATION_FIELDNAME = 'Cancellation_date__c';
	public static final String INTERNAL_USERNAME = 'IATA';

	public MITA_Agreement__c selectedAgreement {
		get;
		set {
			if ( selectedAgreement != value ) {
				selectedAgreement = value;
				this.agreementDetail = null;
				this.showSuccessWithdrawn = false;
			}
		}
	}
	public Account otherAirline {get;set;}
	public Boolean hasWithdrawPermission {get;set;}

	// dummy object used only to use date field Cancellation_date__c in <apex:inputField> tag
	public MITA_Agreement__c agreementCancellation {get;set;}
	public Boolean showSuccessWithdrawn {get;set;}

	public IA_DetailController(){
		this.agreementCancellation = new MITA_Agreement__c();
	}

	/**
	 * Getting the number of days to wait from today to be able to withdraw an agreement
	 */
	public Integer getDaysForWithdrawal() {
		return IA_util.DAYS_TO_WAIT_FOR_WITHDRAWAL;
	}

	/**
	 * String formatted version for the withdrawal date
	 */
	public String getWithdrawnDateFormatted() {
		return IA_util.dateformat(agreementCancellation.Cancellation_date__c);
	}

	/**
	 * Withdraw an agreement updating the three cancellation fields in a MITA_Agreement__c record
	 * only available if the user has permission to do so
	 */
	public void withdrawAgreement() {
		if(!this.hasWithdrawPermission &&
			(this.agreementCancellation.Cancellation_date__c ==null
			|| this.agreementCancellation.Cancellation_date__c < Date.today().addDays(getDaysForWithdrawal()))
		) {
			return;
		}

		this.selectedAgreement.Cancellation_processed_date__c = Date.today();
		this.selectedAgreement.Withdrawal_Request_Reception_Date__c = Date.today();
		this.selectedAgreement.Cancellation_Reason__c = this.selectedAgreement.Airline_1__c == this.otherAirline.Id? IA_util.REASON_CANCELLATION_AIRLINE1: IA_util.REASON_CANCELLATION_AIRLINE2;
		this.selectedAgreement.Cancellation_date__c = this.agreementCancellation.Cancellation_date__c;

		Database.SaveResult result = Database.update(this.selectedAgreement,false);
		this.showSuccessWithdrawn = result.isSuccess();
		if (this.showSuccessWithdrawn) {
			this.agreementDetail.agreementStatus = IA_util.STATUS_PENDING_WITHDRAWAL;
			this.agreementDetail.agreementCancellationDate = IA_util.dateformat(this.selectedAgreement.Cancellation_date__c);
		}
	}

	/**
	 * Get the selected agreement object containing more detailed information
	 */
	public AgreementDetail agreementDetail{
		get{
			if (agreementDetail==null) {
				String agreementType = this.selectedAgreement.Agreement_type__c;
				// if it's a one way agreement and the other airline is in first place find the oposite agreement name
				if (this.selectedAgreement.Airline_1__c == this.otherAirline.Id && IA_util.MAP_ONE_WAY_TYPES.containsKey(agreementType)) {
					agreementType = IA_util.MAP_ONE_WAY_TYPES.get(agreementType);
				}
				agreementDetail = new AgreementDetail();
				agreementDetail.agreementId = this.selectedAgreement.id;
				agreementDetail.otherAirlineDesignator = this.otherAirline.Airline_designator__c;
				agreementDetail.otherAirlineIataCode = this.otherAirline.IATACode__c;
				agreementDetail.otherAirlinePrefix = this.otherAirline.Airline_Prefix__c;
				agreementDetail.otherAirlineName = this.otherAirline.Name;
				agreementDetail.otherAirlineLogo = this.otherAirline.Company_Logo__c;
				agreementDetail.agreementType = IA_util.MAP_AGREEMENT_LABELS.get(agreementType);
				agreementDetail.agreementName = this.selectedAgreement.MITAorBIETA__c;
				agreementDetail.agreementStatus = this.selectedAgreement.Status__c;
				agreementDetail.agreementEffectiveDate = IA_util.dateformat(this.selectedAgreement.Effective_date__c);
				agreementDetail.agreementCancellationDate = IA_util.dateformat(this.selectedAgreement.Cancellation_date__c);
				agreementDetail.minWithdrawDate = DateTime.now().addDays(getDaysForWithdrawal()).format('yyyy-MM-dd');
			}
			return agreementDetail;
		}
		private set;
	}

	/**
	 * Class used as a wrapper to whoe agreement details
	 */
	public class AgreementDetail {
		public String agreementId {get;set;}
		public String otherAirlineDesignator {get;set;}
		public String otherAirlineIataCode {get;set;}
		public String otherAirlinePrefix {get;set;}
		public String otherAirlineName {get;set;}
		public String otherAirlineLogo {get;set;}
		public String agreementType {get;set;}
		public String agreementName {get;set;}
		public String agreementStatus {get;set;}
		public String agreementEffectiveDate {get;set;}
		public String agreementCancellationDate {get;set;}
		public String minWithdrawDate {get;set;}
		public String agreementStatusLabel {
			get{ 
				return IA_util.MAP_STATUS_LABELS.get(agreementStatus);
			}
		}
	}

	/**
	 * Get the list of changes for the current agreement
	 */
	public list<HistoryRow> AgreementHistory {
		get{
			// get history records and its related users in a separate query (not allowed directly)
			list<MITA_Agreement__history> listHistory = [SELECT Id, ParentId, CreatedById, CreatedDate, Field, OldValue, NewValue
				FROM MITA_Agreement__history
				WHERE ParentId = :this.selectedAgreement.Id
				ORDER BY CreatedDate DESC
				LIMIT 1000];
			
			set<Id> setUserId = new set<Id>();
			for (MITA_Agreement__history history: listHistory) {
				setUserId.add(history.CreatedById);
			}
			map<Id,User> mapUsers = new map<Id,User>([
				SELECT Id, Name, ContactId, Contact.AccountId, Contact.Account.Name
				FROM User 
				WHERE Id IN :setUserId
				LIMIT 1000
			]);

			// create history rows to be displayed in the page
			list<HistoryRow> listHistoryRow = new list<HistoryRow>();
			for (MITA_Agreement__history history: listHistory) {
				String details = getDetails(history);
				if (details!=null) {
					User user = mapUsers.get(history.CreatedById);
					HistoryRow row = new HistoryRow();
					row.datechange = history.CreatedDate.format();
					row.company = user.ContactId == null? INTERNAL_USERNAME: user.Contact.Account.Name;
					row.username = user.ContactId == null? INTERNAL_USERNAME: user.Name;
					row.details = details;
					listHistoryRow.add(row);
				}
			}
			return listHistoryRow;
		}
		private set;
	}

	/**
	 * Returns the history description, if applicable, to be shown to the user based on the input history record
	 */
	@TestVisible
	private String getDetails(MITA_Agreement__history history) {
		if (history.field == HISTORY_CREATED) {
			return Label.IA_Agreement_Accepted;
		}
		if (history.field == HISTORY_AGREEMENT_FIELDNAME && history.OldValue == null && history.newValue != null) {
			return Label.IA_Agreement_Rejected;
		}
		if (history.field == HISTORY_AGREEMENT_FIELDNAME && history.OldValue != null && history.newValue == null) {
			return Label.IA_Agreement_Requested;
		}
		if (history.field == HISTORY_CANCELLATION_FIELDNAME && history.OldValue == null && history.newValue != null) {
			if (this.selectedAgreement.Cancellation_Reason__c ==null || this.selectedAgreement.Cancellation_Reason__c == IA_util.REASON_REJECTION) {
				return Label.IA_Agreement_Withdrawn;
			}
			return Label.IA_Undo_Agreement_Accepted;
		}
		if (history.field == HISTORY_CANCELLATION_FIELDNAME && history.OldValue != null && history.newValue == null) {
			return Label.IA_Undo_Agreement_Rejected;
		}
		return null;
	}

	/**
	 * Wrapper class to store agreement history info
	 */
	public class HistoryRow {
		public String datechange {get;set;}
		public String company {get;set;}
		public String username {get;set;}
		public String details {get;set;}
	}

	/**
	 * Get the contacts that belongs to the selected airline to show them in a modal
	 */
	public List<AccountContactRow> getAccountContactRows(){
		List<AccountContactRow> listRows = new List<AccountContactRow>();

		for(Contact contact: [
			SELECT id, name, email, phone, salutation, MITA_Contact_Type__c
			FROM Contact
			WHERE Recordtype.DeveloperName = 'Standard_Contact'
			AND Status__c = 'Active'
			AND (AccountId = :this.otherAirline.Id OR Account.Top_Parent__c = :this.otherAirline.Id)
			AND MITA_Contact_Type__c != null
			ORDER BY Name ASC
			LIMIT 1000])
		{
			AccountContactRow row = new AccountContactRow();
			String salutation = (String.isBlank(contact.salutation)? '': contact.salutation + ' ');
			row.fullName = salutation + contact.name;
			row.email = contact.email;
			row.phone = String.isBlank(contact.phone)? '-': contact.phone;
			row.mitaTypes = new list<IA_util.MitaType>();
			for (String name: contact.MITA_Contact_Type__c.split(';')) {
				row.mitaTypes.add(new IA_util.MitaType(name));
			}
			listRows.add(row);
		}
		return listRows;
	}

	/**
	 * Wrapper class to show agreement contact table
	 */
	public class AccountContactRow {
		public String fullName {get;set;}
		public String email {get;set;}
		public String phone {get;set;}
		public list<IA_util.MitaType> mitaTypes {get;set;}
	}

}
