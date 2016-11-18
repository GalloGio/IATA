public without sharing class MITA_PortalMyAgreementsCtrl {

	public Account acc {get;set;}
	public Contact c {get;set;}
	public MITA_Agreement__c agr {get;set;}
	public SuggestedAirline sair {get;set;}
	public String accountid {get;set;}
	public String contactid {get;set;}
	public String MITAagreementid {get;set;}
	public String BIETAagreementid {get;set;}
	
	public String MITAairlineID {get;set;}
	public String BIETAairlineID {get;set;}
	
	public List<ContactWrapper> otherContacts {get;set;}
	
	public Map<Id,MITA_Agreement__c> agreements {get;set;}

	//NEW VARIABLES
	
	public boolean MITAwithdrawalMode {get;set;}
	public boolean BIETAwithdrawalMode {get;set;}
	public boolean MITAsubmitMode {get;set;}
	public boolean BIETAsubmitMode {get;set;}


	public Map<Id,SuggestedAirline> suggestedAirlines {get;set;}

	public MITA_PortalMyAgreementsCtrl(){
		
		User u = [SELECT UserName, ContactId, Contact.AccountId, Contact.Account.Name, Profile.Name FROM User WHERE ID = :UserInfo.getUserId()];
		
		List<Account> accs = [SELECT Name, Airline_designator__c, IATAcode__c, MITA_Member__c, Membership_status__c, ICH_Member__c, Due_Diligence_Status__c, BIETA_Member__c, MITA_Currency__c, ACH_Member__c, 
								BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c, 
								MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c, 
								MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c
							  FROM Account 
							  WHERE Id = :u.Contact.AccountId];
							  
		if(accs.size()!=1)	ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'Error in the system: cannot open the selected account'));
		else{
			
			acc = accs[0];
			agreements = new Map<Id,MITA_Agreement__c> ((List<MITA_Agreement__c>)
														[SELECT Airline_1__c, Airline_2__c, Active__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name, Airline_2__r.Name, 
																 Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Comments__c
														  FROM MITA_Agreement__c 
														  WHERE Airline_1__c = :acc.Id OR Airline_2__c = :acc.Id]);
			agr = null;
		}
		
		
		suggestedAirlines = new Map<Id,SuggestedAirline>();
		for(Account a : [SELECT Name, Airline_designator__c, IATAcode__c, MITA_Member__c, ICH_Member__c, BIETA_Member__c,
								BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c, 
								MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c, 
								MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
								(SELECT Agreement_type__c FROM MITA_Agreements_1__r WHERE Airline_2__c = :acc.Id),
								(SELECT Agreement_type__c FROM MITA_Agreements_2__r WHERE Airline_1__c = :acc.Id)
								
						  FROM Account 
						  WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company'
						 	AND (MITA_Member__c = true OR BIETA_Member__c = true)
						 	AND ID <> :acc.Id])
			suggestedAirlines.put(a.id,new SuggestedAirline(a,acc));
		
		MITAwithdrawalMode = false;
		BIETAwithdrawalMode = false;
		MITAsubmitMode = false;
		BIETAsubmitMode = false;		
	}
	

	/////////////////////////////
	///// AGREEMENT METHODS /////

	public String getMITAAgreementTypes(){	return getAgreementTypes(true);	}
	public String getBIETAAgreementTypes(){	return getAgreementTypes(false);}
	public String getAgreementTypes(boolean isMITA){
		String datatype = 'data-type="'+(isMITA ? 'MITA' : 'BIETA')+'"';
		String agreementTypes = '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'agreementtype" class="agreementtypefilter" data-value="" '+datatype+' checked="true"/>Show all the agreements<br/>';
		Set<String> agrtypes= new Set<String>();
		if(agreements!=null)
			for(MITA_Agreement__c mag : agreements.values())
				if((isMITA && mag.MITAorBIETA__c=='MITA') || (!isMITA && mag.MITAorBIETA__c=='BIETA'))
					agrtypes.add(mag.Agreement_type__c);
		for(String s : agrtypes)
			agreementTypes += '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'agreementtype" class="agreementtypefilter" data-value="'+s+'" '+datatype+' />'+s+'<br/>';
		return agreementTypes;
	}


	
	
	
	public String getMITAAgreementTable(){	return getAgreementTable(true);	}
	public String getBIETAAgreementTable(){	return getAgreementTable(false);}
	public String getAgreementTable(boolean isMITA){
		String agTable = '';
		if(agreements != null)
			for(MITA_Agreement__c ag : agreements.values()){
				if((isMITA && ag.MITAorBIETA__c=='MITA') || (!isMITA && ag.MITAorBIETA__c=='BIETA'))
					agTable += '<tr id="'+ag.Id+'">'+
									'<td>'+escape(ag.Airline_1__c==acc.Id ? ag.Airline2_designator_code__c : ag.Airline1_designator_code__c)+'</td>'+
									'<td>'+escape(ag.Airline_1__c==acc.Id ? ag.Airline_2__r.Name : ag.Airline_1__r.Name)+ '</td>'+
									'<td>'+ag.Agreement_type__c+ '</td>'+
									'<td>'+ag.Effective_date__c+ '</td>'+
									'<td>'+ag.Active__c+ '</td>'+
									'<td>'+(ag.Active__c ? '<img class="iconx" onclick="$(\'[id$=agreementid]\').val(\''+ag.Id+'\'); delete'+(isMITA ? 'MITA' : 'BIETA')+'Agremeent();"/>' : '')+ '</td>'+
								'</tr>';
			 
			 
		}
		return agTable ;
	}
	
	public String getMITASuggestionTable(){		return getSuggestionTable(true);}
	public String getBIETASuggestionTable(){	return getSuggestionTable(false);}
	public String getSuggestionTable(boolean isMITA){
		String saTable = '';
		if(suggestedAirlines != null)
			for(SuggestedAirline sa : suggestedAirlines.values()){
				if((isMITA && sa.getMitaTypes()!='') || (!isMITA && sa.getBietaTypes()!=''))
					saTable += '<tr id="'+sa.Id+'">'+
									'<td>'+sa.dcode+ '</td>'+
									'<td>'+sa.ncode+ '</td>'+
									'<td>'+escape(sa.name)+ '</td>'+
									'<td>'+(isMITA ? sa.getMitaTypes() : sa.getBietaTypes())+ '</td>'+
									'<td><img class="iconarrow" onclick="$(\'[id$='+(isMITA ? 'MITA' : 'BIETA')+'airlineid]\').val(\''+sa.Id+'\'); submit'+(isMITA ? 'MITA' : 'BIETA')+'Agremeent();"/></td>'+
								'</tr>';
			
		}
		return saTable ;
	}
	
	public String escape(String s){
		return s == null ? '' : s.escapeHtml4();
	}
	
	
	
	//Methods for edit and save the agreement
	public void selectMITAAgreement(){selectAgreement(true);}
	public void selectBIETAAgreement(){selectAgreement(false);}
	public void selectAgreement(boolean isMITA){
		Id agreementId = (isMITA ? MITAagreementid : BIETAagreementid) ;
		agr = agreements.get(agreementId);
		system.debug('selectAgreement() IS MITA ? '+isMITA+' - id = '+(isMITA ? MITAagreementid : BIETAagreementid)+' - agr = '+agr);
		Id otherAirline = (agreementId == agr.Airline_1__c ? agr.Airline_2__c : agr.Airline_1__c);
		
		otherContacts = new List<ContactWrapper>();
		for( Contact c : [SELECT Name, Email, Title, MITA_Contact_Type__c FROM Contact WHERE AccountId = :otherAirline AND MITA_Contact__c = true])
			otherContacts.add(new ContactWrapper(c,false));
		
	}
	
	
	public void deleteMITAAgreement(){deleteAgreement(true);}
	public void deleteBIETAAgreement(){deleteAgreement(false);}
	public void deleteAgreement(boolean isMITA){
		selectAgreement(isMITA);
		if(isMITA){
			MITAwithdrawalMode = true;
		}else{
			BIETAwithdrawalMode = true;
		}
	}
	
	
	public void createMITAAgreement(){createAgreement(true);}
	public void createBIETAAgreement(){createAgreement(false);}
	public void createAgreement(boolean isMITA){
		agr = new MITA_Agreement__c(Airline_1__c = acc.Id);
		if(isMITA){
			MITAsubmitMode = true;
			sair = suggestedAirlines.get(MITAairlineID);
			agr.Airline_2__c = sair.id;
			agr.MITAorBIETA__c = 'MITA';
		}else{
			BIETAsubmitMode = true;
			sair = suggestedAirlines.get(BIETAairlineID);
			agr.Airline_2__c = sair.id;
			agr.MITAorBIETA__c = 'BIETA';
		}

		otherContacts = new List<ContactWrapper>();
		for( Contact c : [SELECT Name, Email, Title, MITA_Contact_Type__c FROM Contact WHERE AccountId = :agr.Airline_2__c AND MITA_Contact__c = true])
			otherContacts.add(new ContactWrapper(c,false));
	}
	
	
	public void resetMITAWithdrawals(){resetWithdrawals(true);}
	public void resetBIETAWithdrawals(){resetWithdrawals(false);}
	public void resetWithdrawals(boolean isMITA){
		if(isMITA)
			MITAwithdrawalMode = false;
		else
			BIETAwithdrawalMode = false;
	}
	
	public void resetMITAsubmit(){resetSubmit(true);}
	public void resetBIETAsubmit(){resetSubmit(false);}
	public void resetSubmit(boolean isMITA){
		if(isMITA)
			MITAsubmitMode = false;
		else
			BIETAsubmitMode = false;
	}
	
	
	public void completeWithdrawal(){
		try{
			update agr;
			//TODO: understand process! Open case? send email? case team? 
			MITAwithdrawalMode = false;
			BIETAwithdrawalMode = false;
			agr = null;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It was not possible to finalize the withdrawal for the following error: '+e.getMessage()));
			system.debug('It was not possible to finalize the withdrawal for the following error: '+e.getMessage());
		}	
	}
	
	public void completeSubmit(){
		try{
			system.debug('completeSubmit() - sair = '+sair);
			// As first I'll check that the agreement type is available
			if(sair==null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Internal error, please contact the admin: (sair not found).'));
				return;
			}
			if((agr.MITAorBIETA__c == 'MITA' && sair.mitatypesToIsSenior.get(agr.Agreement_type__c) != false) ||
				(agr.MITAorBIETA__c == 'BIETA' && sair.bietatypesToIsSenior.get(agr.Agreement_type__c) != false)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This agreemnt type is not available for this airline: '));
				system.debug('completeSubmit() - this agreemnt type '+agr.Agreement_type__c+'is not available for this airline: '+sair.name);
				return;
								
			}
					
			
			insert agr;
			//TODO: understand process! Open case? send email? case team?
			
			 MITAsubmitMode = false;
			 BIETAsubmitMode = false;
			 agr = null;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It was not possible to submit the agreement for the following error: '+e.getMessage()));
			system.debug('It was not possible to submit the agreement for the following error: '+e.getMessage());
		}
	}
	
	
	
	public class ContactWrapper{
		public Contact c {get;set;}
		public boolean sel {get;set;}
		
		public ContactWrapper(Contact c, boolean sel){
			this.c = c;
			this.sel = sel;
		}
	}
	
	
	public class SuggestedAirline{
		public ID id {get;set;}
		public String name {get;set;}
		public string dcode {get;set;}
		public string ncode {get;set;}
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
				MITAdateToType.put('The Passenger and Cargo Interline Traffic Agreement',MITAdateToType.get('MITA_IATA_Interline_Passenger__c'));
			
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
			'MITA_IATA_Interline_Passenger__c'=>'The Passenger Interline Agreement',
			'MITA_IATA_Interline_Cargo__c'=>'The Cargo Interline Agreement',
			'MITA_One_way_Pass_Issuing_Airline__c'=>'The One Way Issuing Airline',
			'MITA_One_way_Pass_Participating__c'=>'The One Way Participating Airline'
		};
		private Map<String,String> BIETAdateToType = new Map<String,String>{	
			'BIETA_Bilateral_Date__c'=>'Bilateral, both carriers can issue electronic tickets',
			'BIETA_One_way_Electronic_Issuing_Airline__c'=>'One Way Passenger Issuing Airline',
			'BIETA_One_way_Electronic_Participating__c'=>'One Way Passenger Participating',
			'BIETA_One_way_Intermodal_Issuing_Airline__c'=>'One Way Intermodal Issuing Date',
			'BIETA_One_way_Intermodal_Participating__c'=>'One Way Intermodal Participating Date'
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
}