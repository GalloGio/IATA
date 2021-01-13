public with sharing class MITA_MemorandumsCtrl {

	private static final String TYPE_PAX_CARGO = 'The Passenger and Cargo Interline Traffic Agreement';
	private static final String TYPE_PAX = 'The Passenger Interline Agreement';
	private static final String TYPE_CARGO = 'The Cargo Interline Agreement';

	private static final Map<String,String> MAP_TYPES = new Map<String,String>{
		TYPE_PAX_CARGO => 'P&C',
		TYPE_PAX => 'P',
		TYPE_CARGO => 'C',
		'The One Way Issuing Airline' => 'O',
		'The One Way Participating Airline' => 'O',
		'Bilateral, both carriers can issue electronic tickets' => 'BIET',
		'One Way Passenger Issuing Airline' => 'OWI',
		'One Way Passenger Participating' => 'OWP',
		'One Way Intermodal Issuing Date' => 'O',
		'One Way Intermodal Participating Date' => 'O'
	};

	public String memorandumType {get;set;}
	public Map<Integer,String> memorandumTypes = new Map<Integer,String>{0=>'--- None ---',1=>'Concurrences',2=>'Withdrawals'};
	public list<SelectOption> agreementTypes {get; set;}
	public Integer sectionActive {get;set;}
	public String selectedAgreement {get;set;}
	public String memorandumNumber {get;set;}
	private boolean printErrors = true;
	public boolean showMemorandum {get;set;}

	public PageReference getMEMOConcurrences(){
		if ( !checkMemorandumNumber() ) {
			return null;
		}
		return new PageReference('/apex/MITA_MemoConcurrences');
	}
	public PageReference getMEMOWithdrawals(){
		if ( !checkMemorandumNumber() ) {
			return null;
		}
		return new PageReference('/apex/MITA_MemoWithdrawals');
	}

	private Boolean checkMemorandumNumber() {
		if ( this.memorandumNumber.trim() == '') {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Set a valid Memorandum Number');
			ApexPages.addMessage(myMsg);
			return false;
		}
		return true;
	}

	public MITA_MemorandumsCtrl(){
		sectionActive = 0;
		fromDate = new MITA_Agreement__c();
		toDate = new MITA_Agreement__c();
		showMemorandum = false;

		list<Schema.PicklistEntry> listTypes = MITA_Agreement__c.MITAorBIETA__c.getDescribe().getPicklistValues();
		this.agreementTypes = new list<SelectOption>();
		for ( Schema.PicklistEntry entry: MITA_Agreement__c.MITAorBIETA__c.getDescribe().getPicklistValues() ) {
			this.agreementTypes.add(new SelectOption(entry.getValue(), entry.getLabel(), !entry.isActive()));
		}
	}


	public Map<Integer,String> monthsNtoName = new Map<Integer,String>{
			01=>'January',
			02=>'February',
			03=>'March',
			04=>'April',
			05=>'May',
			06=>'June',
			07=>'July',
			08=>'August',
			09=>'September',
			10=>'October',
			11=>'November',
			12=>'December'
	};

	public void showMemorandum(){
		showMemorandum = true;
	}
	public void hideMemorandum(){
		showMemorandum = false;
	}


	// Memorandum header
	public MITA_Agreement__c fromdate {get;set;} //I need only a date but there is no standard way to have a date picker if the date is not belonging to a sobject. I'll use Agreement_Processed_Date__c
	public MITA_Agreement__c todate {get;set;}	 //I need only a date but there is no standard way to have a date picker if the date is not belonging to a sobject. I'll use Cancellation_Processed_Date__c


	// Memorandum 1: CONCURRENCES
	public list<WrapperAgreement> getConcurrencesAgreements(){
		List<MITA_Agreement__c> res = [SELECT MITAorBIETA__c , Active__c , Airline_1__c, Airline_1__r.Name_on_AOC__c, Airline_2__r.Name_on_AOC__c, Effective_date__c, Agreement_Processed_Date__c, Agreement_type__c, Created_date__c, Withdrawal_Request_Reception_Date__c, Cancellation_processed_date__c, Cancellation_date__c
										FROM MITA_Agreement__c
										WHERE Agreement_Processed_Date__c >= :fromDate.Agreement_Processed_Date__c
										AND Agreement_Processed_Date__c <= :toDate.Agreement_Processed_Date__c
										AND MITAorBIETA__c = :selectedAgreement
										ORDER BY Airline_1__r.Name_on_AOC__c, Effective_Date__c];
		list<WrapperAgreement> listWrapper = new list<WrapperAgreement>();
		for(MITA_Agreement__c agr : res) {
			addConcurrenceAgreement(listWrapper, agr);
		}
		return listWrapper;
	}

	/**
		Check if input agreement has an agreement to join in listWrapper
	**/
	public void addConcurrenceAgreement(list<WrapperAgreement> listWrapper, MITA_Agreement__c agr) {
		for(WrapperAgreement wrapper : listWrapper) {
			if(wrapper.checkMixConcurrenceAgreement(agr)) {
				return;
			}
		}
		listWrapper.add(new WrapperAgreement(agr));
	}

	// Memorandum 2: WITHDRAWALS
	public list<WrapperAgreement> getWithdrawalsAgreements(){
		List<MITA_Agreement__c> res = [SELECT MITAorBIETA__c, Active__c, Airline_1__c, Airline_1__r.Name_on_AOC__c, Airline_2__r.Name_on_AOC__c, Cancellation_Date__c, Cancellation_Processed_Date__c, Agreement_type__c, Created_date__c, Withdrawal_Request_Reception_Date__c
										FROM MITA_Agreement__c
										WHERE Cancellation_Processed_Date__c >= :fromDate.Cancellation_Processed_Date__c
										AND Cancellation_Processed_Date__c <= :toDate.Cancellation_Processed_Date__c
										AND MITAorBIETA__c = :selectedAgreement
										AND Cancellation_Reason__c in ('Requested by Airline 1','Requested by Airline 2')
										ORDER BY Airline_1__r.Name_on_AOC__c, Cancellation_Date__c];
		list<WrapperAgreement> listWrapper = new list<WrapperAgreement>();
		for(MITA_Agreement__c agr : res) {
			addWithdrawalAgreement(listWrapper, agr);
		}
		return listWrapper;
	}

	/**
		Check if input agreement has an agreement to join in listWrapper
	**/
	public void addWithdrawalAgreement(list<WrapperAgreement> listWrapper, MITA_Agreement__c agr) {
		for(WrapperAgreement wrapper : listWrapper) {
			if(wrapper.checkMixWhitdrawalAgreement(agr)) {
				return;
			}
		}
		listWrapper.add(new WrapperAgreement(agr));
	}


	///// METHODS FOR PRINTING PDFS /////
	public List<SelectOption> getMemorandumTypes(){
		List<SelectOption> sos = new List<SelectOption>();
		for(Integer i : memorandumTypes.keyset())
			sos.add(new SelectOption(''+i, memorandumTypes.get(i)));
		return sos;
	}

	public class WrapperAgreement {
		public MITA_Agreement__c agreement {get; set;}
		public MITA_Agreement__c agreementPax {get; set;}
		public MITA_Agreement__c agreementCargo {get; set;}

		public WrapperAgreement(MITA_Agreement__c agreement) {
			this.agreement = agreement;
		}

		public Boolean checkMixConcurrenceAgreement(MITA_Agreement__c newAgreement) {
			if (this.agreement.Agreement_processed_date__c == newAgreement.Agreement_processed_date__c &&
				checkMixAgreement(newAgreement)
			) {
				return true;
			}
			return false;
		}

		public Boolean checkMixWhitdrawalAgreement(MITA_Agreement__c newAgreement) {
			if (this.agreement.Cancellation_Processed_Date__c == newAgreement.Cancellation_Processed_Date__c &&
				checkMixAgreement(newAgreement)
			) {
				return true;
			}
			return false;
		}

		private Boolean checkMixAgreement(MITA_Agreement__c newAgreement) {
			if (this.agreement.MITAorBIETA__c == newAgreement.MITAorBIETA__c &&
				(
					(this.agreement.Airline_1__c == newAgreement.Airline_1__c && this.agreement.Airline_2__c == newAgreement.Airline_2__c) ||
					(this.agreement.Airline_1__c == newAgreement.Airline_2__c && this.agreement.Airline_2__c == newAgreement.Airline_1__c)
				) &&
				(
					( this.agreement.Agreement_type__c == TYPE_PAX  && newAgreement.Agreement_type__c == TYPE_CARGO) ||
					( this.agreement.Agreement_type__c == TYPE_CARGO  && newAgreement.Agreement_type__c == TYPE_PAX)
				)
			) {
				this.agreement.Agreement_type__c = TYPE_PAX_CARGO;
				return true;
			}
			return false;
		}


		public String getTypeCode() {
			return MAP_TYPES.get(this.agreement.Agreement_type__c);
		}

	}
}
