public with sharing class MITA_AgreementsCtrl {

	private static final String TYPE_ISSUING_AIRLINE = 'The One Way Issuing Airline';
	private static final String TYPE_PARTICIPATING_AIRLINE = 'The One Way Participating Airline';

	private static final String TYPE_PAX_ISSUING_AIRLINE = 'One Way Passenger Issuing Airline';
	private static final String TYPE_PAX_PARTICIPATING_AIRLINE = 'One Way Passenger Participating';

	private static final String TYPE_IMOD_ISSUING_AIRLINE = 'One Way Intermodal Issuing Date';
	private static final String TYPE_IMOD_PARTICIPATING_AIRLINE = 'One Way Intermodal Participating Date';

	private static final map<String, String> MAP_ONE_WAY_TYPES = new map<String,String>{
		TYPE_ISSUING_AIRLINE => TYPE_PARTICIPATING_AIRLINE,
		TYPE_PARTICIPATING_AIRLINE => TYPE_ISSUING_AIRLINE,
		TYPE_PAX_ISSUING_AIRLINE => TYPE_PAX_PARTICIPATING_AIRLINE,
		TYPE_PAX_PARTICIPATING_AIRLINE => TYPE_PAX_ISSUING_AIRLINE,
		TYPE_IMOD_ISSUING_AIRLINE => TYPE_IMOD_PARTICIPATING_AIRLINE,
		TYPE_IMOD_PARTICIPATING_AIRLINE => TYPE_IMOD_ISSUING_AIRLINE
	};

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
    public boolean editAccountMode {get;set;}
    public boolean editContactMode {get;set;}
    public boolean editMITAAgreementMode {get;set;}
    public boolean editBIETAAgreementMode {get;set;}
    
    public boolean searchContactMode {get;set;}
    public boolean duplicateContactMode {get;set;}
    public boolean confirmMoveContactMode {get;set;}
    public string contactEmail {get;set;}
    public Contact foundContact {get;set;}
    public Map<Id,Contact> duplicateContacts {get;set;}
    
    public List<Contact> contacts {get;set;}
    public Map<Id,MITA_Agreement__c> agreements {get;set;}

    public MITA_AgreementsCtrl(){
        chosenAccount=false;
        chosenMITAAgreement=false;
        chosenBIETAAgreement=false;
        searchContactMode=false;
        confirmMoveContactMode=false;
    }
    
    public Integer getIsThereAnError(){
        return ApexPages.getMessages().size();
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
        if(accs.size()!=1)  ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'Error in the system: cannot open the selected account'));
        else{
        	
            chosenAccount = true;
            chosenContact = false;
            chosenMITAAgreement=false;
            chosenBIETAAgreement=false;
            acc = accs[0];
            
            editAccountMode = false;
            editContactMode = false;
            editMITAAgreementMode = false;
            editBIETAAgreementMode = false;
            
            // fill the agreements map
            agreements = new map<Id,MITA_Agreement__c>();
            for ( MITA_Agreement__c agreement: [
                SELECT Airline_1__c, Airline_2__c, Active__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name, Airline_2__r.Name, 
                    Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Agreement_processed_date__c
                FROM MITA_Agreement__c 
                WHERE Airline_1__c = :acc.Id OR Airline_2__c = :acc.Id
            ]) {
            	// change agreement type for all one way agreements (each side of the agreement has a different name, defined in MAP_ONE_WAY_TYPES)
                if (agreement.Airline_2__c == acc.Id) {
                	String newAgreementType = MAP_ONE_WAY_TYPES.get(agreement.Agreement_type__c);
                	if (newAgreementType!= null) {
                		agreement.Agreement_type__c = newAgreementType;
                	}
                }
                agreements.put(agreement.Id, agreement);
            }
            
            if (agr != null ) {
            	selectAgreement(agr.MITAorBIETA__c=='MITA');
            }

            contacts = [SELECT Name, Title, Email, MITA_Contact_Type__c, MITA_Teletype__c FROM Contact WHERE MITA_Contact__c = true AND (AccountId = :acc.Id OR Account.Top_Parent__c = :acc.Id)];
        }
        
    }
    
    public void editAccount(){
        editAccountMode = true;
    }
    public void resetAccount(){
        editAccountMode = false;
    }
    public void saveAccount(){
        try{
            update acc;
            editAccountMode = false;
        }catch(Exception e){
            String cleanmessage = e.getMessage();
            if(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')!=-1)   cleanmessage = cleanmessage.substring(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35);
            ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'It was not possible to save the airline because of the following error: '+cleanmessage));
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

    public String getMITAAgreementTypes(){  return getAgreementTypes(true); }
    public String getBIETAAgreementTypes(){ return getAgreementTypes(false);}
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


    
    
    
    public String getMITAAgreementTable(){  return getAgreementTable(true); }
    public String getBIETAAgreementTable(){ return getAgreementTable(false);}
    public String getAgreementTable(boolean isMITA){
        String agTable = '';
        system.debug('getAgreementTable() --> agreements size = '+agreements.size());
        for(MITA_Agreement__c ag : agreements.values()){
            if((isMITA && ag.MITAorBIETA__c=='MITA') || (!isMITA && ag.MITAorBIETA__c=='BIETA')) {
                String effectiveDate = ag.Effective_date__c==null?'':ag.Effective_date__c.format();
                
                agTable += '<tr id="'+ag.Id+'">'+
                                '<td>'+escape(ag.Airline_1__c==acc.Id ? ag.Airline2_designator_code__c : ag.Airline1_designator_code__c)+'</td>'+
                                '<td>'+escape(ag.Airline_1__c==acc.Id ? ag.Airline_2__r.Name : ag.Airline_1__r.Name)+ '</td>'+
                                '<td>'+ag.Agreement_type__c+ '</td>'+
                                '<td>'+ effectiveDate + '</td>'+
                                '<td>'+ag.Active__c+ '</td>'+
                            '</tr>';
            }
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
    	Id agreementId = isMITA ? MITAagreementid : BIETAagreementid;
        agr = [
        	SELECT Airline_1__c, Airline_2__c, Active__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name, Airline_2__r.Name, Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Agreement_processed_date__c, Cancellation_processed_date__c 
        	From MITA_Agreement__c m
			where id = :agreementId];
        
        system.debug('selectAgreement() IS MITA ? '+isMITA+' - id = '+agreementId+' - agr = '+agr);
        if(isMITA){
            chosenMITAAgreement = true;
            editMITAAgreementMode = false;
        }else{
            chosenBIETAAgreement = true;
            editBIETAAgreementMode = false;
        }
    }
    
    
    public void newMITAAgreement(){newAgreement(true);}
    public void newBIETAAgreement(){newAgreement(false);}
    public void newAgreement(boolean isMITA){
        agr = new MITA_Agreement__c(Airline_1__c = acc.Id, MITAorBIETA__c = isMITA ? 'MITA' : 'BIETA');
        //editAgreementMode = true;
        if(isMITA){
            if(editBIETAAgreementMode){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It\'s not possible to create or edit an agreement in MITA and BIETA section at the same time. Please save the open one and try again.'));
                return;
            }
            
            editMITAAgreementMode  = true;
            chosenMITAAgreement = true;
        }else{
            if(editMITAAgreementMode){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It\'s not possible to create or edit an agreement in MITA and BIETA section at the same time. Please save the open one and try again.'));
                return;
            }
            editBIETAAgreementMode  = true;
            chosenBIETAAgreement = true;
        }
    }
    public void editMITAAgreement(){editAgreement(true);}
    public void editBIETAAgreement(){editAgreement(false);}
    public void editAgreement(boolean isMITA){
        if(isMITA){
            if(editBIETAAgreementMode){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It\'s not possible to create or edit an agreement in MITA and BIETA section at the same time. Please save the open one and try again.'));
                return;
            }
            editMITAAgreementMode = true;
        }else{
            if(editMITAAgreementMode){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It\'s not possible to create or edit an agreement in MITA and BIETA section at the same time. Please save the open one and try again.'));
                return;
            }
            editBIETAAgreementMode = true;
        }
    }
    
    public void resetMITAAgreement(){resetAgreement(true);}
    public void resetBIETAAgreement(){resetAgreement(false);}
    public void resetAgreement(boolean isMITA){
        if(isMITA){
            editMITAAgreementMode = false;
            if(agr.Id == null){
                agr = null;
                chosenMITAAgreement = false;
            }
        }else{
            editBIETAAgreementMode = false;
            if(agr.Id == null){
                agr = null;
                chosenBIETAAgreement = false;
            }
        }
        
    }
    
    
    public void saveAgreement(){
        system.savepoint sp = Database.setSavePoint();
        try{
        	// set some fileds before upserting to the database
            if ( agr.Cancellation_date__c != null && agr.Cancellation_processed_date__c == null ) {
            	agr.Cancellation_processed_date__c = Date.today();
            }
            if ( agr.Effective_date__c != null && agr.Agreement_processed_date__c == null ) {
            	agr.Agreement_processed_date__c = Date.today();
            }
            // As first I save so that I can catch the errors raised by the validation rules
            upsert agr;
            system.debug(LoggingLevel.ERROR, 'upserted the agreement: '+agr.Airline_1__r.Name+' ---> '+agr.Airline_2__r.Name+' with id = '+agr.id);
            List<MITA_Agreement__c> duplicates = [SELECT Id, Airline_1__c, Airline_1__r.Name, Airline_2__c, Airline_2__r.Name, Agreement_processed_date__c
                                                    FROM MITA_Agreement__c 
                                                    WHERE ((Airline_1__c = :agr.Airline_1__c AND Airline_2__c = :agr.Airline_2__c))
                                                        //OR (Airline_1__c = :agr.Airline_2__c AND Airline_2__c = :agr.Airline_1__c))
                                                        AND Agreement_type__c = :agr.Agreement_type__c
                                                        AND ID <> :agr.ID];
            // If it's a duplicate I remove it! 
            if(duplicates.size()>0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, acc.Name +' has already an agreement of type '+agr.Agreement_Type__c +
                                                                                    ' with the airline '+(duplicates[0].Airline_1__c==agr.Airline_1__c ? duplicates[0].Airline_2__r.Name : duplicates[0].Airline_1__r.Name)));
                                                                                    
                Database.rollback(sp);
                return;
            }           
            
            
            MITA_Agreement__c thenewone = [SELECT Airline_1__c, Airline_2__c, Active__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name, Airline_2__r.Name, 
                                                                 Airline1_designator_code__c , Airline2_designator_code__c, Agreement_processed_date__c 
                                                          FROM MITA_Agreement__c 
                                                          WHERE ID = :agr.ID];
            
            agreements.put(thenewone.Id,thenewone);
        }catch(Exception e){
            String cleanmessage = e.getMessage();
            if(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')!=-1)   cleanmessage = cleanmessage.substring(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35);
            ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'It was not possible to save the agreement because of the following error: '+cleanmessage));
            system.debug(LoggingLevel.ERROR, 'It was not possible to save the agreement because of the following error: '+e.getMessage());
            Database.rollback(sp);
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
    public void editContact(){
        editContactMode = true;
    }
    public void saveContact(){
        try{
            upsert c;
            chosenContact = true;
            editContactMode = false;
        }catch(Exception e){
            String cleanmessage = e.getMessage();
            if(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')!=-1)   cleanmessage = cleanmessage.substring(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35);
            ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'Error saving the contact: '+cleanmessage));
        }
    }
    public void newContact(){
        resetContact();
        ID rt = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        c = new Contact(AccountId = accountid, MITA_Contact__c=true, RecordTypeId = rt, Status__c='Active');
        chosenContact = true;
        editContactMode = true;
    }
    public void resetContact(){
        c = null;
        chosenContact = false;
        editContactMode = false;
        searchContactMode = false;
        duplicateContactMode = false;
        confirmMoveContactMode = false;
    }
    
    public void searchContact(){
        searchContactMode = true;
    }
    
    public void removeContactFromMITA(){
        if(c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No contact has been selected. '));
            return;
        }
        c.MITA_Contact__c = false;
        try{
            upsert c;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error while saving the contact '+c.Name+': '+e.getMessage()));
        }
    }
    
    public void moveContact(){
        duplicateContactMode = false;
        if(String.isEmpty(contactEmail)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please insert a valid email'));
            return;
        }
        duplicateContacts = new Map<Id, Contact>((List<Contact>) [SELECT Name, Salutation, FirstName, LastName, Title, Email, MITA_Contact_Type__c, MITA_Teletype__c, Phone, Fax, OtherStreet, OtherCity, OtherPostalCode, 
                                                                        OtherState, OtherCountry, Status__c, AccountId, Account.RecordTypeId, Account.Name, Account.IATA_ISO_Country__r.Name, Account.Top_Parent__c, Account.ParentId  
                                                                  FROM Contact 
                                                                  WHERE Email = :contactEmail]);
                                                                  
        //NO CONTACT
        if(duplicateContacts.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No contact with the email '+contactemail+' was found in the system. Please check the email is correct or create a new contact.'));
            system.debug(LoggingLevel.ERROR,'####### no contact'); 
            return;
            
        //ONE CONTACT
        }else if(duplicateContacts.size()==1){         
            foundContact = duplicateContacts.values()[0];
            confirmMoveContactMode=true;
            duplicateContacts = null;
        //MANY CONTACTS
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Several contacts were found with the email '+contactemail+'. Please select the one you want to use.'));
            system.debug(LoggingLevel.ERROR,'####### tanti contatti, bisogna scegliere da tabella'); 
            duplicateContactMode = true;
        }
    }
    
    public void confirmMoveContact(){
        foundContact.AccountId = accountid;
        foundContact.MITA_Contact__c = true;
        
        Database.SaveResult sr = database.update(foundContact,false);
        if(!sr.isSuccess()){
            String cleanmessage = sr.getErrors()[0].getMessage();
            if(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')!=-1)   cleanmessage = cleanmessage.substring(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+foundContact.Id+'" target="_blank">'+foundContact.Name+'</a> raised the following error: '+cleanmessage));
            system.debug(LoggingLevel.ERROR,'####### errore sul salvataggio del contatto: '+sr.getErrors()[0].getMessage()); 
            return;
        }
        
        searchContactMode = false;
        confirmMoveContactMode = false;
        duplicateContactMode = false;
        contactEmail = '';
        foundContact = new Contact();
    }
    
    public void chooseContact(){
        contactId = System.currentPageReference().getParameters().get('contactId');
        foundContact = duplicateContacts.get(contactid);
        
        if(foundContact==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'System error: the chosen contact has not been recognized. Please contact the administrator'));
            system.debug(LoggingLevel.ERROR,'####### contact was not find in the map!');
            return; 
        }
        
        confirmMoveContactMode = true;
    }
    
    public void deactivateMitaMember() {
    	deactivateMember('MITA');
    }
    
    public void deactivateBietaMember() {
    	deactivateMember('BIETA');
    }
    	
    public void deactivateMember(String agreementType) {
        Date cancellationDate = Date.today();
        list<MITA_Agreement__c> listUpdates = new list<MITA_Agreement__c>(); 
        for ( MITA_Agreement__c agreement: agreements.values() ) {
            if (agreement.MITAorBIETA__c.equals(agreementType) && agreement.Active__c ) {
                agreement.Cancellation_date__c = cancellationDate;
                listUpdates.add(agreement);
            }
        }
        if (!listUpdates.isEmpty()) {
            update listUpdates;
        }
    }
    
}