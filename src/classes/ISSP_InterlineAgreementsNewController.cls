public without sharing class ISSP_InterlineAgreementsNewController {

	@testVisible
	private static Blob EncDecKey = Blob.valueOf('I@T@M!tAS3rvIc3!');

	private static List<String> ACTIVE_STATUS = new List<String>{'Not Active Yet','Active','Pending Approval','Pending Withdrawal'};

	public Account account {get;set;}
	public Boolean hasRequestPermission {get;set;}
	public MITAutil.AlertModal alertModal{get;set;}
	private Set<String> setMyAccountAllowed;
	private Set<String> setFilterNames;
	private Set<String> setFilterTypes;

	public List<SelectOption> getOptionNames() {
		return MITAutil.setToOptions(this.setFilterNames,null);
	}
	public List<SelectOption> getOptionTypes() {
		return MITAutil.setToOptions(this.setFilterTypes,MITAutil.MAP_AGREEMENT_LABELS);
	}

	/**
	 * initialize agreement variables to retrieve them again
	 **/
	public void refreshPage() {
		this.suggestedAirlines = null;
		this.availableAgreementsRows = null;
	}

	private Map<Id,SuggestedAirline> suggestedAirlines {
		get{
			if (suggestedAirlines==null) {
				this.setMyAccountAllowed = new Set<String>(getAllowedAgreementTypes(this.account));

				suggestedAirlines = new Map<Id,SuggestedAirline>();
				for(Account otherAccount : [
						SELECT Name, Airline_designator__c, IATAcode__c, MITA_Member__c, ICH_Member__c, BIETA_Member__c,
							BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c,
							MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c,
							MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c, Airline_Prefix__c,
							(SELECT Agreement_type__c FROM MITA_Agreements_1__r WHERE Airline_2__c = :account.Id AND Status__c IN :ACTIVE_STATUS),
							(SELECT Agreement_type__c FROM MITA_Agreements_2__r WHERE Airline_1__c = :account.Id AND Status__c IN :ACTIVE_STATUS)
						FROM Account
						WHERE RecordType.DeveloperName = 'IATA_Airline'
						AND ACLI_Status__c = 'Active Company'
						AND (MITA_Member__c = true OR BIETA_Member__c = true)
						AND ID <> :account.Id
						ORDER BY Name]) {

					suggestedAirlines.put(otherAccount.id,new SuggestedAirline(this.account,otherAccount,this.setMyAccountAllowed));
				}
			}
			return suggestedAirlines;
		}
		private set;
	}

	/**
	 * Help class to calculate all possible agreements between two airlines
	 * First check is if each agreement is allowed according to airline configrations:
	 *   - for MITA agreements both airlines must have the checkbox MITA_Member__c and each type must have the corresponding date populated (defined in MAP_AGREEMENT_FIELDS)
	 *   - for BIETA agreements both airlines must have the checkbox BIETA_Member__c and each type must have the corresponding date populated (defined in MAP_AGREEMENT_FIELDS)
	 *   - for EMD agreements there is no limit, are always available
	 * Second check is if the agreement is already active o pending request, so it can't be available
	 */
	public class SuggestedAirline{
		public Account myAccount;
		public Account otherAccount;
		private Set<String> setMyAccountAllowed;
		public map<String,List<String>> mapActiveAgreements {get;set;}

		public SuggestedAirline(Account myAccount, Account otherAccount, Set<String> setMyAccountAllowed){
			this.myAccount = myAccount;
			this.otherAccount = otherAccount;
			this.setMyAccountAllowed = setMyAccountAllowed;

			Set<String> alreadyExisting = getExistingAgreements();
			this.mapActiveAgreements = new map<String,List<String>>();
			for (String agreementType : getAllowedAgreementTypes(this.otherAccount)) {
				if (this.setMyAccountAllowed.contains(agreementType) && !alreadyExisting.contains(agreementType)) {
					// this agreementType is available, so it is added to the mapActiveAgreements
					String agreementName = MITAutil.MAP_AGREEMENTS_BY_NAME.get(agreementType);
					list<String> listAgreementTypes = this.mapActiveAgreements.get(agreementName);
					if (listAgreementTypes == null) listAgreementTypes = new list<String>();
					listAgreementTypes.add(agreementType);
					this.mapActiveAgreements.put(agreementName,listAgreementTypes);
				}
			}
		}

		/**
		 * Find the agreements already active or pending request for the two airlines in this class
		 */
		private Set<String> getExistingAgreements() {
			set<String> alreadyExisting = new set<String>();
			//agreements where myAccount is in Airline2 and required one way agreements conversion
			for(MITA_Agreement__c ma : otherAccount.MITA_Agreements_1__r) {
				if (MITAutil.MAP_ONE_WAY_TYPES.containsKey(ma.Agreement_type__c)) {
					alreadyExisting.add(MITAutil.MAP_ONE_WAY_TYPES.get(ma.Agreement_type__c));
				} else {
					alreadyExisting.add(ma.Agreement_type__c);
				}
			}
			//agreements where myAccount is in Airline1 and no one way conversion is needed
			for(MITA_Agreement__c ma : otherAccount.MITA_Agreements_2__r) {
				alreadyExisting.add(ma.Agreement_type__c);
			}
			return alreadyExisting;
		}
	}

	/**
	 * For the given account it returns all allowed agreements based on its configuration
	 */
	private static list<String> getAllowedAgreementTypes(Account account) {
		//get the field list that controlls the permission for each agreement
		list<String> listFieldNames = new list<String>();
		if (account.MITA_Member__c) listFieldNames.addAll(MITAutil.LIST_MITA_FIELDS);
		if (account.BIETA_Member__c) listFieldNames.addAll(MITAutil.LIST_BIETA_FIELDS);
		// EMD is granted for everyone so far

		list<String> listAgreementTypes = new list<String>();
		for (String fieldName: listFieldNames) {
			Date datefield = (Date)account.get(fieldName);
			if(datefield !=null && datefield <= Date.today()) {
				listAgreementTypes.add(MITAutil.MAP_AGREEMENT_FIELDS.get(fieldName));
			}
		}
		// EMD has no permissions, it is always able to be requested
		listAgreementTypes.add(MITAutil.TYPE_EMD);
		return listAgreementTypes;
	}

	/**
	 * Prepared version for the available agreements to be displayed in a table
	 */
	public list<AvailableAgreementsRow> availableAgreementsRows {
		get{
			if (availableAgreementsRows==null) {
				//initialize filters
				this.setFilterNames = new Set<String>();
				this.setFilterTypes = new Set<String>();

				availableAgreementsRows = new list<AvailableAgreementsRow>();
				for(SuggestedAirline sa : this.suggestedAirlines.values()){
					for(String agreementName : sa.mapActiveAgreements.keyset()) {
						List<String> listActiveAgreements = sa.mapActiveAgreements.get(agreementName);
						if (!listActiveAgreements.isEmpty()) {
							AvailableAgreementsRow row = new AvailableAgreementsRow();
							row.designator = sa.otherAccount.Airline_Designator__c;
							row.iatacode = sa.otherAccount.IATAcode__c;
							row.Prefix = sa.otherAccount.Airline_Prefix__c;
							row.airlinename = sa.otherAccount.Name;
							row.agreementname = agreementName;
							row.agreements = new list<String>();
							for (String agr: listActiveAgreements) {
								String agrType = MITAutil.MAP_AGREEMENT_LABELS.get(agr);
								row.agreements.add(agrType);
								this.setFilterTypes.add(agrType);
							}
							row.otherAccount = MITAutil.Encrypt(EncDecKey,sa.otherAccount.Id);
							availableAgreementsRows.add(row);

							this.setFilterNames.add(agreementName);
						}
					}
				}
			}
			return availableAgreementsRows;
		}
		private set;
	}

	/**
	 * wrapper class to store a table row
	 */
	public class AvailableAgreementsRow {
		public String designator {get;set;}
		public String iatacode {get;set;}
		public String Prefix {get;set;}
		public String airlinename {get;set;}
		public String agreementname {get;set;}
		public list<String> agreements {get;set;}
		public String otherAccount {get;set;}
	}

	/***
	 * MODAL NEW AGREEMENT
	 **/
	public String selectedAccount {get;set;}
	public String selectedAgreementName {get;set;}
	public Boolean showModalNewAgreement {get;set;}
	public String newAgreementAirlineName {get;set;}
	public list<SelectOption> listOptionAgreementTypes {get; set;}
	public MITA_Agreement__c newAgreement {get;set;}

	/**
	 * Opens the modal to create a new agreement
	 **/
	public void openModalNewAgreement() {
		this.showModalNewAgreement = true;
		this.alertModal = null;

		//create the new agreement record ready to be saved
		SuggestedAirline suggestedAirline = this.suggestedAirlines.get(MITAutil.Decrypt(EncDecKey,this.selectedAccount));
		if (suggestedAirline==null) closeModalNewAgreement();

		this.newAgreementAirlineName = suggestedAirline.otherAccount.Name;
		this.newAgreement = new MITA_Agreement__c(
			Airline_1__c = suggestedAirline.myAccount.Id,
			Airline_2__c = suggestedAirline.otherAccount.Id,
			MITAorBIETA__c = this.selectedAgreementName,
			Agreement_type__c = '',
			Agreement_processed_date__c = null,
			Effective_date__c = null,
			Created_date__c = Date.today()
		);

		// get the agreement types available for the selected agreement
		list<String> listActiveAgreements = suggestedAirline.mapActiveAgreements.get(this.selectedAgreementName);
		this.listOptionAgreementTypes = new list<SelectOption>();
		if (listActiveAgreements.size()!=1) {
			this.listOptionAgreementTypes.add(new SelectOption('','Choose agreement type',true));
		}
		for (String agreementName: listActiveAgreements) {
			this.listOptionAgreementTypes.add(new SelectOption(agreementName,MITAutil.MAP_AGREEMENT_LABELS.get(agreementName)));
		}
	}

	/**
	 * Closes the modal to create a new agreement
	 **/
	public void closeModalNewAgreement() {
		this.showModalNewAgreement = false;
		this.newAgreement = null;
		this.alertModal = null;
	}

	/**
	 * Insert the new agreement record created in openNewAgreementModal()
	 **/
	public void saveNewAgreement() {
		if (!this.hasRequestPermission) return;
		if (this.newAgreement.Effective_date__c == null) {
			this.alertModal = new MITAutil.AlertModal('errorMsg','Warning','Select an effective date','');
			return;
		}

		Database.SaveResult result = Database.insert(this.newAgreement);
		if (result.isSuccess()) {
			closeModalNewAgreement();
			refreshPage();
			this.alertModal = new MITAutil.AlertModal('successMsgNew','Your request has been submitted.','Once the counterpart accepts the request, the agreement will be activated on the effective date.','');
		} else {
			this.alertModal = new MITAutil.AlertModal('errorMsg','','There was a problem saving the agreement','');
		}
	}

	/**
	 * formatted date for the min parameter in the <input type="date">
	 */
	public String getMinEffectiveAge() {
		return DateTime.now().format('yyyy-MM-dd');
	}

	/**
	 * Clean the alert modal
	 */
	public void resetAlertModal() {
		this.alertModal = null;
	}
}