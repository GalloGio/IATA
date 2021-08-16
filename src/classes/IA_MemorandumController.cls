public with sharing class IA_MemorandumController {

	public String memorandumNumber {get;set;}
	public Date memorandumDate {get;set;}
	public Date memorandumLastDate {get;set;}
	public String filename {get;set;}

	public String getIATALogoURL() {
		list<Document> listDoc = [
			SELECT Id
			FROM Document
			WHERE DeveloperName = 'new_iata_blue_logo'];
		return listDoc.isEmpty()? null: 
			URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().replace('visualforce','documentforce')+'/servlet/servlet.FileDownload?file='+listDoc[0].id;
	}

	public IA_MemorandumController(){
		initFromParams();
	}

	private void initFromParams() {
		Map<String,String> params = ApexPages.CurrentPage().getParameters();
		DateTime dt = DateTime.now();
		if (params.containsKey('date')) {
			list<String> parseDate = params.get('date').split('/');
			Integer year = Integer.ValueOf(parseDate[2]);
			Integer month = Integer.ValueOf(parseDate[1]);
			Integer day = Integer.ValueOf(parseDate[0]);
			dt = DateTime.newInstance(year,month,day);
			this.memorandumDate = Date.newInstance(dt.year(), dt.month(), 1);
			this.memorandumLastDate = dt.addMonths(1).addDays(-1).date();
		}
		this.memorandumNumber = params.get('number');
		this.filename = 'Interline Agreements Memorandum - ' + this.memorandumNumber + ' - ' + dt.format('MMMM yyyy') + '.pdf';
	}

	public List<String> getListTitles() {
		List<String> listTitles = new List<String>();
		for (String agrType: IA_util.AGREEMENT_TYPES) {
			for (String memoType: IA_util.MEMO_TYPES) {
				listTitles.add(agrType + ' ' + memoType);
			}
		}
		return listTitles;
	}

	public Map<String,List<WrapperAgreement>> getDataAgreements() {
		Map<String,List<WrapperAgreement>> mapAllAgreements = new Map<String,List<WrapperAgreement>>();
		for (String title: getListTitles()) {
			mapAllAgreements.put(title, new List<WrapperAgreement>());
		}
		mapAllAgreements.putAll(getConcurrencesAgreements());
		mapAllAgreements.putAll(getWithdrawalsAgreements());
		return mapAllAgreements;
	}

	public Map<String,List<WrapperAgreement>> getConcurrencesAgreements(){
		List<MITA_Agreement__c> lsitAgreements = [
			SELECT MITAorBIETA__c, Active__c, Airline_1__c, Airline_1__r.Name, Airline_2__c, Airline_2__r.Name, Effective_date__c, Agreement_Processed_Date__c, Agreement_type__c, Created_date__c, Withdrawal_Request_Reception_Date__c, Cancellation_processed_date__c, Cancellation_date__c
			FROM MITA_Agreement__c
			WHERE Effective_Date__c >= :this.memorandumDate
			AND Effective_Date__c <= :this.memorandumLastDate
			ORDER BY Airline_1__r.Name, Effective_Date__c];

		Map<String,List<WrapperAgreement>> mapAllAgreements = new Map<String,List<WrapperAgreement>>();
		for(MITA_Agreement__c agr : lsitAgreements) {
			String key = agr.MITAorBIETA__c + ' ' + IA_util.CONCURRENCES;
			List<WrapperAgreement> listWrapper = mapAllAgreements.get(key);
			if (listWrapper==null) {
				listWrapper = new list<WrapperAgreement>();
				mapAllAgreements.put(key, listWrapper);
			}
			addConcurrenceAgreement(listWrapper, agr);
		}
		return mapAllAgreements;
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

	public Map<String,List<WrapperAgreement>> getWithdrawalsAgreements(){
		List<MITA_Agreement__c> res = [
			SELECT MITAorBIETA__c, Active__c, Airline_1__c, Airline_1__r.Name, Airline_2__c, Airline_2__r.Name, Effective_date__c, Agreement_Processed_Date__c, Agreement_type__c, Created_date__c, Withdrawal_Request_Reception_Date__c, Cancellation_processed_date__c, Cancellation_date__c
			FROM MITA_Agreement__c
			WHERE Cancellation_Date__c >= :this.memorandumDate
			AND Cancellation_Date__c <= :this.memorandumLastDate
			AND Cancellation_Reason__c in (:IA_util.REASON_CANCELLATION_AIRLINE1, :IA_util.REASON_CANCELLATION_AIRLINE2)
			ORDER BY Airline_1__r.Name, Cancellation_Date__c];

		Map<String,List<WrapperAgreement>> mapAllAgreements = new Map<String,List<WrapperAgreement>>();
		for(MITA_Agreement__c agr : res) {
			String key = agr.MITAorBIETA__c + ' ' + IA_util.WITHDRAWALS;
			List<WrapperAgreement> listWrapper = mapAllAgreements.get(key);
			if (listWrapper==null) {
				listWrapper = new list<WrapperAgreement>();
				mapAllAgreements.put(key, listWrapper);
			}
			addWithdrawalAgreement(listWrapper, agr);
		}
		return mapAllAgreements;
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

	public class WrapperAgreement {
		public MITA_Agreement__c agreement {get; set;}
		public MITA_Agreement__c agreementPax {get; set;}
		public MITA_Agreement__c agreementCargo {get; set;}

		public WrapperAgreement(MITA_Agreement__c agreement) {
			this.agreement = agreement;
		}

		public Boolean checkMixConcurrenceAgreement(MITA_Agreement__c newAgreement) {
			return (this.agreement.Agreement_processed_date__c == newAgreement.Agreement_processed_date__c && checkMixAgreement(newAgreement));
		}

		public Boolean checkMixWhitdrawalAgreement(MITA_Agreement__c newAgreement) {
			return (this.agreement.Cancellation_Processed_Date__c == newAgreement.Cancellation_Processed_Date__c && checkMixAgreement(newAgreement));
		}

		private Boolean checkMixAgreement(MITA_Agreement__c newAgreement) {
			if (this.agreement.MITAorBIETA__c == newAgreement.MITAorBIETA__c &&
				(
					(this.agreement.Airline_1__c == newAgreement.Airline_1__c && this.agreement.Airline_2__c == newAgreement.Airline_2__c) ||
					(this.agreement.Airline_1__c == newAgreement.Airline_2__c && this.agreement.Airline_2__c == newAgreement.Airline_1__c)
				) &&
				(
					( this.agreement.Agreement_type__c == IA_util.TYPE_PAX  && newAgreement.Agreement_type__c == IA_util.TYPE_CARGO) ||
					( this.agreement.Agreement_type__c == IA_util.TYPE_CARGO  && newAgreement.Agreement_type__c == IA_util.TYPE_PAX)
				)
			) {
				this.agreement.Agreement_type__c = IA_util.TYPE_PAX_CARGO;
				return true;
			}
			return false;
		}
	}
}