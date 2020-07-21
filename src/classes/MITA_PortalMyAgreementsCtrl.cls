public without sharing class MITA_PortalMyAgreementsCtrl {

	public static final String APP_NAME = 'Interline agreements';
	public Account acc {get;set;}
	public user currentUser {get;set;}

	public SuggestedAirline sair {get;set;}
	public String MITAagreementid {get;set;}
	public String BIETAagreementid {get;set;}

	public String MITAairlineID {get;set;}
	public String BIETAairlineID {get;set;}

	public Map<Id,MITA_AgreementsCtrl.WrapperAgreement> wrapperAgreements {get;set;}
	public MITA_AgreementsCtrl.WrapperAgreement wrapper {get;set;}

	public Map<Id,SuggestedAirline> suggestedAirlines {get;set;}
	
	public MITA_PortalMyAgreementsCtrl(){
		selectedAirlineId = '';
		selectedContactToEdit = '';
		ContactBeingEdited = new contact();
		selectedContactToRemove = '';
		ContactBeingRemoved = new contact();

		SaveError='';
		hasSearched = false;

		this.currentUser = [SELECT UserName, ContactId, Contact.AccountId, Contact.Account.Name, Profile.Name, Contact.Account.ParentId, Contact.Account.Parent.ParentId FROM User WHERE ID = :UserInfo.getUserId()];

		if(this.currentUser.Contact.Account.Parent.ParentId <> null)	currUserTopAccntId = this.currentUser.Contact.Account.Parent.ParentId;
		else if(this.currentUser.Contact.Account.ParentId <> null)		currUserTopAccntId = this.currentUser.Contact.Account.ParentId;
		else currUserTopAccntId = this.currentUser.Contact.AccountId;
		
		RetrieveMyContacts();
		
		List<Account> accs = [SELECT Name, Airline_designator__c, IATAcode__c, MITA_Member__c, Membership_status__c, ICH_Member__c, Due_Diligence_Status__c, BIETA_Member__c, MITA_Currency__c, ACH_Member__c,
								BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c,
								MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c,
								MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
								Name_on_AOC__c, Airline_Prefix__c
							  FROM Account
							  WHERE Id = :this.currentUser.Contact.AccountId];
		
		if(accs.size()!=1)    ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, Label.ISSP_cannot_open_the_selected_account));
		else{

			acc = accs[0];
			list<MITA_Agreement__c> listAgreements =[
				SELECT Airline_1__c, Airline_2__c, Active__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c,
				Status__c, MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Comments__c, Cancellation_processed_date__c, Agreement_processed_date__c,
				Airline_1__r.Name_on_AOC__c , Airline1_designator_code__c, Airline_1__r.Airline_designator__c, Airline_1__r.Airline_Prefix__c, Airline_1__r.IATACode__c,
				Airline_2__r.Name_on_AOC__c , Airline2_designator_code__c, Airline_2__r.Airline_designator__c, Airline_2__r.Airline_Prefix__c, Airline_2__r.IATACode__c
				FROM MITA_Agreement__c
				WHERE (Airline_1__c = :acc.Id OR Airline_2__c = :acc.Id)
				AND Active__c = true];

			this.wrapper = null;
			this.wrapperAgreements = new map<Id,MITA_AgreementsCtrl.WrapperAgreement>();
			for (MITA_Agreement__c agreement: listAgreements) {
				addToAgreementsMap( agreement, this.wrapperAgreements, acc);
			}
		}


		suggestedAirlines = new Map<Id,SuggestedAirline>();
		for(Account a : [SELECT Name, Airline_designator__c, IATAcode__c, MITA_Member__c, ICH_Member__c, BIETA_Member__c,
								BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c,
								MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c,
								MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
								Name_on_AOC__c, Airline_Prefix__c,
								(SELECT Agreement_type__c FROM MITA_Agreements_1__r WHERE Airline_2__c = :acc.Id),
								(SELECT Agreement_type__c FROM MITA_Agreements_2__r WHERE Airline_1__c = :acc.Id)

						  FROM Account
						  WHERE RecordType.Name = 'Airline Headquarters'
							 AND ACLI_Status__c = 'Active Company'
							 AND (MITA_Member__c = true OR BIETA_Member__c = true)
							 AND ID <> :acc.Id])
			suggestedAirlines.put(a.id,new SuggestedAirline(a,acc));
	}

	private void addToAgreementsMap( MITA_Agreement__c newAgreement, map<Id,MITA_AgreementsCtrl.WrapperAgreement> mapAgreements, Account account) {
		for ( MITA_AgreementsCtrl.WrapperAgreement wrapper: mapAgreements.values()) {
			if (wrapper.checkMixAgreement(newAgreement)) {
				return;
			}
		}
		mapAgreements.put(newAgreement.Id, new MITA_AgreementsCtrl.WrapperAgreement(newAgreement, account));
	}

	/**
		Start actions: check rights
	**/
	public PageReference initActions() {
		try {
			String strId = this.currentUser.ContactId;
			Portal_Application_Right__c appRight = [
				Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c, Right__c
				From Portal_Application_Right__c
				Where ContactId__c = :strId.left(15)
				And Portal_Application__r.Name = :APP_NAME
			];
			// If user has no rights to access to Account statements app then is redirected to Home
			if (appRight.Right__c=='Access Granted') {
				return null;
			}

		} catch(Exception e) {
			//if error happens return to home page
		}
		// default action, return to home page (if no Access granted was found)
		Pagereference pageref = new PageReference('/ISSP_Homepage');
		pageref.setRedirect(true);
		return pageref;
	}

	/////////////////////////////
	///// AGREEMENT METHODS /////

	public String getMITAAgreementTypes(){    return getAgreementTypes(true);    }
	public String getBIETAAgreementTypes(){    return getAgreementTypes(false);}
	public String getAgreementTypes(boolean isMITA){
		String datatype = 'data-type="'+(isMITA ? 'MITA' : 'BIETA')+'"';
		String agreementTypes = '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'agreementtype" class="agreementtypefilter" data-value="" '+datatype+' checked="true"/>Show all the agreements<br/>';
		Set<String> agrtypes= new Set<String>();
		for(MITA_AgreementsCtrl.WrapperAgreement wrapper : this.wrapperAgreements.values()) {
			MITA_Agreement__c mag = wrapper.getAgreement();
			if((isMITA && mag.MITAorBIETA__c=='MITA') || (!isMITA && mag.MITAorBIETA__c=='BIETA')) {
				agrtypes.add(mag.Agreement_type__c);
			}
		}
		for(String s : agrtypes) {
			agreementTypes += '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'agreementtype" class="agreementtypefilter" data-value="'+s+'" '+datatype+' />'+s+'<br/>';
		}
		return agreementTypes;
	}

	public String getMITAAgreementTable(){    return getAgreementTable(true);    }
	public String getBIETAAgreementTable(){    return getAgreementTable(false);}
	public String getAgreementTable(boolean isMITA){
		String agTable = '';
		for(MITA_AgreementsCtrl.WrapperAgreement wrapper : this.wrapperAgreements.values()){
			MITA_Agreement__c ag = wrapper.getAgreement();
			if((isMITA && ag.MITAorBIETA__c=='MITA') || (!isMITA && ag.MITAorBIETA__c=='BIETA')) {
				Account otherAccount = wrapper.getOther();
				agTable += '<tr id="'+wrapper.getId()+'">'+
								'<td>'+escape(otherAccount.Airline_designator__c)+'</td>'+
								'<td>'+escape(otherAccount.IATACode__c)+'</td>'+
								'<td>'+escape(otherAccount.Airline_Prefix__c)+'</td>'+
								'<td>'+escape(otherAccount.Name_on_AOC__c)+ '</td>'+
								'<td>'+wrapper.getAgreementType()+ '</td>'+
								'<td>'+wrapper.getStatus()+ '</td>'+
								'<td align="center"><a class="glyphicon glyphicon-eye-open" href="#!" onClick="startLoading();RetrieveOtherAirlineContacts(\'' + escape(otherAccount.Id) + '\');"></a></td>'+
							'</tr>';
			}
		}
		return agTable ;
	}

	public String getMITASuggestionTypes(){    return getSuggestionTypes(true);    }
	public String getBIETASuggestionTypes(){    return getSuggestionTypes(false);}
	public String getSuggestionTypes(boolean isMITA){
		String datatype = 'data-type="'+(isMITA ? 'MITA' : 'BIETA')+'"';
		String agreementTypes = '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'suggestiontype" class="suggestiontypefilter" data-value="" '+datatype+' checked="true"/>Show all the agreements<br/>';
		Set<String> agrtypes= new Set<String>();
		for(SuggestedAirline sa : suggestedAirlines.values()){
			agrtypes.addAll((isMITA ? sa.mitatypesToIsSenior : sa.bietatypesToIsSenior).keyset());
		}
		for(String s : agrtypes) {
			agreementTypes += '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'suggestiontype" class="suggestiontypefilter" data-value="'+s+'" '+datatype+' />'+s+'<br/>';
		}
		return agreementTypes;
	}

	public String getMITASuggestionTable(){        return getSuggestionTable(true);}
	public String getBIETASuggestionTable(){    return getSuggestionTable(false);}
	public String getSuggestionTable(boolean isMITA){
		String saTable = '';
		for(SuggestedAirline sa : suggestedAirlines.values()){
			if((isMITA && sa.mita) || (!isMITA && sa.bieta)) {
				saTable += '<tr id="'+sa.Id+'">'+
								'<td>'+escape(sa.dcode)+ '</td>'+
								'<td>'+escape(sa.ncode)+ '</td>'+
								'<td>'+escape(sa.prefix)+ '</td>'+
								'<td>'+escape(sa.name)+ '</td>'+
								'<td>'+sa.getTypes(isMITA)+ '</td>'+
							'</tr>';
			}
		}
		return saTable ;
	}

	public String escape(String s){
		return s == null ? '' : s.escapeHtml4();
	}

	public class SuggestedAirline{
		public ID id {get;set;}
		public String name {get;set;}
		public string dcode {get;set;}
		public string ncode {get;set;}
		public string prefix {get;set;}
		public boolean mita {get;set;}
		public boolean bieta {get;set;}
		public map<string,boolean> mitatypesToIsSenior{get;set;}
		public map<string,boolean> bietatypesToIsSenior{get;set;}
		public set<String> alreadyExisting{get;set;}

		public SuggestedAirline(Account a, Account myacc){
			this.id = a.id;
			this.name = a.Name;
			this.dcode = a.Airline_Designator__c;
			this.ncode = a.IATAcode__c;
			this.prefix = a.Airline_Prefix__c;
			this.mita = a.MITA_Member__c;
			this.bieta = a.BIETA_Member__c;
			mitatypesToIsSenior=new Map<string,boolean>();
			bietatypesToIsSenior=new Map<string,boolean>();
			for(String d : MITAdateToType.keyset()){
				String t = MITAdateToType.get(d);
				if(a.get(d)!=null && myacc.get(d)!=null)
					mitatypesToIsSenior.put(t,((Date)a.get(d)) < ((Date)myacc.get(d)));
			}
			if(MITAdateToType.get('MITA_IATA_Interline_Passenger__c')!=null && MITAdateToType.get('MITA_IATA_Interline_Cargo__c')!=null)
				MITAdateToType.put(Label.ISSP_The_Passenger_and_Cargo_Interline_Traffic_Agreement,MITAdateToType.get('MITA_IATA_Interline_Passenger__c'));

			for(String d : BIETAdateToType.keyset()){
				String t = BIETAdateToType.get(d);
				if(a.get(d)!=null && myacc.get(d)!=null)
					bietatypesToIsSenior.put(t,((Date)a.get(d)) < ((Date)myacc.get(d)));
			}
			alreadyExisting = new set<String>();
			for(MITA_Agreement__c ma : a.MITA_Agreements_1__r)
				alreadyExisting.add(ma.Agreement_type__c);
			for(MITA_Agreement__c ma : a.MITA_Agreements_2__r)
				alreadyExisting.add(ma.Agreement_type__c);

		}

		private Map<String,String> MITAdateToType = new Map<String,String>{
			'MITA_IATA_Interline_Passenger__c'=>Label.ISSP_The_Passenger_Interline_Agreement,
			'MITA_IATA_Interline_Cargo__c'=>Label.ISSP_The_Cargo_Interline_Agreement,
			'MITA_One_way_Pass_Issuing_Airline__c'=>Label.ISSP_The_One_Way_Issuing_Airline,
			'MITA_One_way_Pass_Participating__c'=>Label.ISSP_The_One_Way_Participating_Airline
		};
		private Map<String,String> BIETAdateToType = new Map<String,String>{
			'BIETA_Bilateral_Date__c'=>Label.ISSP_Bilateral_both_carriers_can_issue_electronic_tickets,
			'BIETA_One_way_Electronic_Issuing_Airline__c'=>Label.ISSP_One_Way_Passenger_Issuing_Airline,
			'BIETA_One_way_Electronic_Participating__c'=>Label.ISSP_One_Way_Passenger_Participating,
			'BIETA_One_way_Intermodal_Issuing_Airline__c'=>Label.ISSP_One_Way_Intermodal_Issuing_Date,
			'BIETA_One_way_Intermodal_Participating__c'=>Label.ISSP_One_Way_Intermodal_Participating_Date
		};


		public List<SelectOption> getMITAAvailableTypes(){return getAvailableTypes(true);}
		public List<SelectOption> getBIETAAvailableTypes(){return getAvailableTypes(false);}
		public List<SelectOption> getAvailableTypes(boolean isMITA){
			List<SelectOption> opts = new List<SelectOption>();
			for(String s : (isMITA ? mitatypesToIsSenior : bietatypesToIsSenior).keyset()){
				if(!alreadyExisting.contains(s) && (isMITA ? mitatypesToIsSenior : bietatypesToIsSenior).get(s)==false)
					opts.add(new SelectOption(s,s));
			}
			return opts;
		}

		public String getMITATypes(){return getTypes(true);}
		public String getBIETATypes(){return getTypes(false);}
		public String getTypes(boolean isMITA){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'isMITA ? '+isMITA+' - BIETA = '+bieta));
			String types = '';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'mitatypesToIsSenior = '+mitatypesToIsSenior));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'alreadyExisting = '+alreadyExisting));
			if((isMITA ? mita : bieta))
				for(String t : (isMITA ? mitatypesToIsSenior : bietatypesToIsSenior).keyset())
					if(!alreadyExisting.contains(t))
						types += (types=='' ? '' : ', ') + t + ((isMITA ? mitatypesToIsSenior : bietatypesToIsSenior).get(t) ? '(Senior)' : '(Junior)');
			return types;
		}
	}

	/**********************************
	 *   CONTACTS METHODS AND VARIABLES 
	 **********************************/
	public string selectedAirlineId				{get; set;}
	public string selectedAirlineName			{get; set;}

	public string selectedContactToEdit			{get; set;}
	public contact ContactBeingEdited			{get; set;}
	public string SaveError						{get; set;}

	public contact ContactBeingRemoved			{get; set;}
	public string selectedContactToRemove		{get; set;}
	public string RemoveError					{get; set;}

	public string SearchCriteria				{get; set;}

	public boolean hasSearched					{get; set;}
	private string currUserTopAccntId;
	
	private static final string MandatoryMITAType = 'Interline Airline Generic Contact';

	//Variables storing the HTML text to be rerenderd in dataTable
	public string OtherAirlineContactTable		{get; set;}
	public string myActiveContactsTable			{get; set;}
	public string myAllContactsTable			{get; set;}

	public string RetrieveOtherAirlineContacts(){
		OtherAirlineContactTable = '';
		selectedAirlineName='';
		if(string.isEmpty(selectedAirlineId))
			return null;
		else{
			for(Contact c:retrieveContacts(selectedAirlineId, false, 'MITA', false)){
				selectedAirlineName = c.Account.Name_on_AOC__c;
				OtherAirlineContactTable += '<tr id="'+c.Id+'">'+
							'<td>'+escape(c.salutation)+ ' ' +escape(c.name)+ '</td>'+
							'<td>'+escape(c.email)+ '</td>'+
							'<td>'+escape(c.phone)+ '</td>'+
							'<td>'+escape(c.MITA_Contact_Type__c)+ '</td>'+
							'<td>'+escape(c.MITA_Teletype__c)+ '</td>'+
						'</tr>';
			}
		}
		return null;
	}

	public string getContactTypes(){
		string ctype = '<input type="radio" name="ContactType" class="contactTypefilter" data-value="" data-type="Contact" checked="true"/>Show all the contacts<br/>';
		List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Contact.MITA_Contact_Type__c.getDescribe();
		for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
			ctype += '<input type="radio" name="ContactType" class="contactTypefilter" data-value="'+pickListVal.getLabel()+'" data-type="Contact" />Show '+pickListVal.getLabel()+'<br/>';
		}
		return ctype;
	}

	public void RetrieveMyContacts(){
		MyActiveContactsTable = '';
		for(Contact c:retrieveContacts(currUserTopAccntId, true, null, false)){
			if(string.isNotBlank(c.MITA_Contact_Type__c))
			MyActiveContactsTable += '<tr id="'+c.Id+'">'+
				'<td>'+escape(c.salutation)+ ' ' +escape(c.name)+ '</td>'+
				'<td>'+escape(c.email)+ '</td>'+
				'<td>'+escape(c.phone)+ '</td>'+
				'<td>'+escape(c.MITA_Contact_Type__c)+ '</td>'+
				'<td>'+escape(c.MITA_Teletype__c)+ '</td>'+
				'<td align="center"><a class="glyphicon glyphicon-pencil" href="#!" onClick="ActiveCon_EditContactSuccess(\'\');startLoading();editContact(\'' + escape(c.Id) + '\');"></a> <a class="glyphicon glyphicon-remove" href="#!" onClick="ActiveCon_EditContactSuccess(\'\');startLoading();removeContact(\'' + escape(c.Id) + '\');"></a></td>'+
			'</tr>';
		}
	}
	
	public void SearchContact(){
		myAllContactsTable = '';
		hasSearched = true;
		if(string.isNotBlank(SearchCriteria)){
			for(Contact c:retrieveContacts(currUserTopAccntId , true, null, true)){
				myAllContactsTable += '<tr id="'+c.Id+'">'+
					'<td>'+escape(c.salutation)+ ' ' +escape(c.name)+ '</td>'+
					'<td>'+escape(c.email)+ '</td>'+
					'<td>'+escape(c.phone)+ '</td>'+
					'<td>'+escape(c.MITA_Teletype__c)+ '</td>'+
					'<td align="center"><a class="glyphicon glyphicon-pencil" href="#!" onClick="AllCon_EditContactSuccess(\'\');startLoading();editContact(\'' + escape(c.Id) + '\');"></a></td>'+
				'</tr>';
			}
		}
	}

	private list<Contact> retrieveContacts(id AirlineId, boolean bAllHierarchy, string searchType, boolean filterSearch){
		system.debug('DTULLO retrieveContacts AirlineId --> ' + string.valueOf(AirlineId));
		string sQuery = 'select id, Account.Name_on_AOC__c, name, email, phone, salutation, MITA_Contact_Type__c, MITA_Teletype__c from contact where recordtype.developername=\'Standard_Contact\' AND Status__c=\'Active\'';
		if(searchType=='MITA')
			sQuery += ' AND MITA_Contact_Type__c<>\'\'';

		if(bAllHierarchy){
			sQuery += ' AND (AccountId = \'' + AirlineId + '\' OR Account.ParentId = \'' + AirlineId + '\' or Account.parent.ParentId = \'' + AirlineId + '\')';
		}else{
			sQuery += ' AND AccountId =\'' + AirlineId + '\'';
		}

		if(filterSearch){
			sQuery += ' AND MITA_Contact_Type__c =\'\' AND (name like \'%' + SearchCriteria + '%\' OR email like \'%' + SearchCriteria + '%\')';
		}

		sQuery += ' ORDER BY Name ASC';
		return database.query(sQuery);
	}

	public void retrieveContactToEdit(){
		if(!string.isBlank(selectedContactToEdit))
			ContactBeingEdited = [select id, name, AccountId, email,  phone, salutation, MITA_Contact_Type__c, MITA_Teletype__c from contact where id=:selectedContactToEdit];
	}

	public void retrieveContactToRemove(){
		if(!string.isBlank(selectedContactToRemove))
			ContactBeingRemoved = [select id, name, AccountId, email,  phone, salutation, MITA_Contact_Type__c, MITA_Teletype__c from contact where id=:selectedContactToRemove];
	}


	public pageReference ValidateContact(){
		SaveError='';
		try{
			if(!(string.isBlank(ContactBeingEdited.MITA_Contact_Type__c)) && ContactBeingEdited.MITA_Contact_Type__c.contains(MandatoryMITAType)) SaveError='';
			else {
				if(ValidateMandatoryType(ContactBeingEdited.Id))
					SaveError='At least one contact must be ' + MandatoryMITAType;
			}
		}
		catch(exception e){
			SaveError='An unexpected error occured ' +  e.getMessage();
		}
		return null;
	}

	private boolean ValidateMandatoryType(id ContactId){
		list<contact> lsOtherAccnContact = [SELECT id, MITA_Contact_Type__c 
											FROM contact 
											WHERE (AccountId = :this.currentUser.Contact.AccountId OR Account.ParentId = :this.currentUser.Contact.AccountId OR Account.parent.ParentId = :this.currentUser.Contact.AccountId)
											AND RecordType.DeveloperName = 'Standard_Contact'
											AND id <> :ContactId
											AND MITA_Contact_Type__c INCLUDES (:MandatoryMITAType) limit 1];
		
		return lsOtherAccnContact.isEmpty();
	}

	public void SaveTheContact(){
		SaveError='';
		try{
			update ContactBeingEdited;
			RetrieveMyContacts();
			SearchContact();
			ContactBeingEdited = null;
		}catch(Exception e){
			SaveError = 'An exception occured: ' + e.getMessage();
		}
	}

	public void removeTheContact(){
		SaveError='';
		try{
			ContactBeingRemoved.MITA_Contact_Type__c = null;
			update ContactBeingRemoved;
			RetrieveMyContacts();
			SearchContact();
			ContactBeingRemoved = null;
		}catch(Exception e){
			SaveError = 'An exception occured: ' + e.getMessage();
		}
	}


	public pageReference ValidateContactRemoval(){
		SaveError='';
		try{
			if(ValidateMandatoryType(ContactBeingRemoved.Id))
				SaveError='At least one contact must be ' + MandatoryMITAType;
		}
		catch(exception e){
			SaveError='An unexpected error occured ' +  e.getMessage();
		}
		return null;
	}
}
