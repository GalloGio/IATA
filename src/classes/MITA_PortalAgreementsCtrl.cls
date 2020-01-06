public class MITA_PortalAgreementsCtrl {

	public Account acc {get;set;}
	public Contact c {get;set;}
	public MITA_Agreement__c agr {get;set;}
	public String accountid {get;set;}
	public String contactid {get;set;}
	public String MITAagreementid {get;set;}
	public String BIETAagreementid {get;set;}
	public boolean chosenAccount {get;set;}
	public boolean chosenContact {get;set;}
	public boolean chosenMITAAgreement {get;set;}
	public boolean chosenBIETAAgreement {get;set;}

	public List<Contact> contacts {get;set;}
	public Map<Id,MITA_Agreement__c> agreements {get;set;}

	public MITA_PortalAgreementsCtrl(){
		chosenAccount=false;
		chosenMITAAgreement=false;
		chosenBIETAAgreement=false;
	}

	///////////////////////////
	///// AIRLINE METHODS /////

	public void selectAccount(){

		List<Account> accs = [SELECT Name, Airline_designator__c, IATAcode__c, MITA_Member__c, Membership_status__c, ICH_Member__c, Due_Diligence_Status__c, BIETA_Member__c, MITA_Currency__c, ACH_Member__c,
								BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c,
								MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c,
								MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c
								FROM Account
								WHERE Id = :accountid];
		if(accs.size()!=1)	ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'Error in the system: cannot open the selected account'));
		else{
			chosenAccount = true;
			chosenContact = false;
			chosenMITAAgreement=false;
			chosenBIETAAgreement=false;
			acc = accs[0];

			agreements = new Map<Id,MITA_Agreement__c> ((List<MITA_Agreement__c>)
														[SELECT Airline_1__c, Airline_2__c, Active__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name, Airline_2__r.Name,
																 Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c
															FROM MITA_Agreement__c
															WHERE Airline_1__c = :acc.Id OR Airline_2__c = :acc.Id]);
			agr = null;
			contacts = [SELECT Name, Title, Email, MITA_Contact_Type__c, MITA_Teletype__c FROM Contact WHERE MITA_Contact__c = true AND (AccountId = :acc.Id OR Account.Top_Parent__c = :acc.Id)];
		}

	}

	public String getAccountTable(){
		String accTable = '';
		for(Account a : [SELECT Name, Airline_designator__c, MITA_Member__c, IATACode__c
						 FROM Account
						 WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company' ])
			accTable += '<tr id="'+a.ID+'">'+
							'<td>' + escape(a.Airline_designator__c)+ '</td>'+
							'<td>' + escape(a.IATACode__c)+ '</td>'+
							'<td>' + escape(a.Name) + '</td>'+
							'<td>' + a.MITA_Member__c +'</td>'+
						'</tr>';

		return accTable ;
	}

	/////////////////////////////
	///// AGREEMENT METHODS /////

	public String getMITAAgreementTypes(){	return getAgreementTypes(true);	}
	public String getBIETAAgreementTypes(){	return getAgreementTypes(false);}
	public String getAgreementTypes(boolean isMITA){
		String datatype = 'data-type="'+(isMITA ? 'MITA' : 'BIETA')+'"';
		String agreementTypes = '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'agreementtype" class="agreementtypefilter" data-value="" '+datatype+' checked="true"/>Show all the agreements<br/>';
		Set<String> agrtypes= new Set<String>();
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
		system.debug('getAgreementTable() --> agreements size = '+agreements.size());
		for(MITA_Agreement__c ag : agreements.values()){
			if((isMITA && ag.MITAorBIETA__c=='MITA') || (!isMITA && ag.MITAorBIETA__c=='BIETA'))
				agTable += '<tr id="'+ag.Id+'">'+
								'<td>'+escape(ag.Airline_1__c==acc.Id ? ag.Airline2_designator_code__c : ag.Airline1_designator_code__c)+'</td>'+
								'<td>'+escape(ag.Airline_1__c==acc.Id ? ag.Airline_2__r.Name : ag.Airline_1__r.Name)+ '</td>'+
								'<td>'+ag.Agreement_type__c+ '</td>'+
								'<td>'+ag.Effective_date__c+ '</td>'+
								'<td>'+ag.Active__c+ '</td>'+
							'</tr>';

		}
		return agTable ;
	}

	public String escape(String s){
		return s == null ? '' : s.escapeHtml4();
	}


	//Methods for edit and save the agreement
	public void selectMITAAgreement(){selectAgreement(true);}
	public void selectBIETAAgreement(){selectAgreement(false);}
	public void selectAgreement(boolean isMITA){
		agr = agreements.get(isMITA ? MITAagreementid : BIETAagreementid);
		system.debug('selectAgreement() IS MITA ? '+isMITA+' - id = '+(isMITA ? MITAagreementid : BIETAagreementid)+' - agr = '+agr);
		if(isMITA){
			chosenMITAAgreement = true;
		}else{
			chosenBIETAAgreement = true;
		}
	}


	////////////////////////////////
	///// METHODS FOR CONTACTS /////

	public void selectContact(){
		try{
			c = [SELECT Name, Salutation, FirstName, LastName, Title, Email, MITA_Contact_Type__c, MITA_Teletype__c, Phone, Fax, OtherStreet, OtherCity, OtherPostalCode, OtherState, OtherCountry, Status__c FROM Contact WHERE Id = :contactid];
			chosenContact = true;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'Error in the system: cannot open the selected contact: '+e.getMessage()));

		}
	}

}
