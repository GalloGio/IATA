public with sharing class MITA_AgreementsCtrl {

    public class MITAException extends Exception {}

    private static final String TYPE_PAX_CARGO = 'The Passenger and Cargo Interline Traffic Agreement';
    private static final String TYPE_PAX = 'The Passenger Interline Agreement';
    private static final String TYPE_CARGO = 'The Cargo Interline Agreement';

    private static final String TYPE_ISSUING_AIRLINE = 'The One Way Issuing Airline';
    private static final String TYPE_PARTICIPATING_AIRLINE = 'The One Way Participating Airline';

    private static final String TYPE_BILATERAL = 'Bilateral, both carriers can issue electronic tickets';
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
    public WrapperAgreement wrapper {get; set;}
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
    public Map<Id,WrapperAgreement> agreements {get;set;}

    public MITA_AgreementsCtrl(){
        chosenAccount=false;
        chosenMITAAgreement=false;
        chosenBIETAAgreement=false;
        searchContactMode=false;
        confirmMoveContactMode=false;

        this.showDeactivateAgreementsPanel = false;
        this.dummyAgreement = new MITA_Agreement__c();
    }

    public Integer getIsThereAnError(){
        return ApexPages.getMessages().size();
    }

    ///////////////////////////
    ///// AIRLINE METHODS /////

    public void selectAccount(){
        acc = getAccount();
        if (acc == null) return;

        chosenAccount = true;
        chosenContact = false;
        chosenMITAAgreement=false;
        chosenBIETAAgreement=false;

        editAccountMode = false;
        editContactMode = false;
        editMITAAgreementMode = false;
        editBIETAAgreementMode = false;

        this.MITAagreementid = null;
        this.BIETAagreementid = null;
        this.wrapper = null;

        // fill the agreements map
        refreshAgreementList();

        contacts = [
            SELECT Id, Name, Title, Email, MITA_Contact_Type__c, MITA_Teletype__c
            FROM Contact
            WHERE id IN (
                Select Contact__c
                from Related_Contact__c
                where Account__c = :acc.Id
                and Contact__r.MITA_Contact__c = true)
        ];
    }

    private void refreshAgreementList() {
        agreements = new map<Id,WrapperAgreement>();
        for ( MITA_Agreement__c agreement: [
            SELECT Airline_1__c, Airline_2__c, Active__c, Status__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name_on_AOC__c , Airline_2__r.Name_on_AOC__c ,
                Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Agreement_processed_date__c, Cancellation_processed_date__c
            FROM MITA_Agreement__c
            WHERE Airline_1__c = :acc.Id OR Airline_2__c = :acc.Id
        ]) {
            addToAgreementsMap( agreement, agreements);
        }
    }

    private void addToAgreementsMap( MITA_Agreement__c newAgreement, map<Id,WrapperAgreement> mapAgreements) {
        for ( WrapperAgreement wrapper: mapAgreements.values()) {
            if (wrapper.checkMixAgreement(newAgreement)) {
                return;
            }
        }
        mapAgreements.put(newAgreement.Id, new WrapperAgreement(newAgreement, this.acc));
    }

    private Account getAccount() {
        try {
            Account account = [
                SELECT Name, Name_on_AOC__c, Airline_designator__c, IATAcode__c, MITA_Member__c, Membership_status__c, ICH_Member__c, Due_Diligence_Status__c, BIETA_Member__c, MITA_Currency__c, ACH_Member__c,
                BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c,
                MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c,
                MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c, Airline_Prefix__c
                FROM Account
                WHERE Id = :this.accountid
            ];
            return account;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in the system: cannot open the selected account'));
            return null;
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
            acc = getAccount();
        }

    }

    public void viewGroupedAgreement(){
        this.wrapper.viewSeparated = false;
    }

    public void viewSeparatedAgreements(){
        this.wrapper.viewSeparated = true;
    }

    public String getAccountTable(){
        String accTable = '';
        for(Account a : [SELECT Name, Name_on_AOC__c , Airline_designator__c, MITA_Member__c, IATACode__c
                         FROM Account
                         WHERE RecordType.Name = 'Airline Headquarters'
                            AND ACLI_Status__c = 'Active Company' ])
            accTable += '<tr id="'+a.ID+'">'+
                            '<td>' + escape(a.Airline_designator__c)+ '</td>'+
                            '<td>' + escape(a.IATACode__c)+ '</td>'+
                            '<td>' + escape(a.Name_on_AOC__c ) + '</td>'+
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
        for(WrapperAgreement wrapper : agreements.values()) {
            MITA_Agreement__c mag = wrapper.getAgreement();
            if((isMITA && mag.MITAorBIETA__c=='MITA') || (!isMITA && mag.MITAorBIETA__c=='BIETA')) {
                agrtypes.add(mag.Agreement_type__c);
            }
        }
        for(String s : agrtypes)
            agreementTypes += '<input type="radio" name="'+(isMITA ? 'MITA' : 'BIETA')+'agreementtype" class="agreementtypefilter" data-value="'+s+'" '+datatype+' />'+s+'<br/>';
        return agreementTypes;
    }


    public String getMITAAgreementTable(){  return getAgreementTable(true); }
    public String getBIETAAgreementTable(){ return getAgreementTable(false);}
    public String getAgreementTable(boolean isMITA){
        String agTable = '';
        system.debug('getAgreementTable() --> agreements size = '+agreements.size());
        for(WrapperAgreement wrapper : agreements.values()){
            MITA_Agreement__c ag = wrapper.getAgreement();
            if((isMITA && ag.MITAorBIETA__c=='MITA') || (!isMITA && ag.MITAorBIETA__c=='BIETA')) {
                agTable += '<tr id="'+wrapper.getId()+'">'+
                                '<td>'+escape(wrapper.getOtherDesignatorCode())+'</td>'+
                                '<td>'+escape(wrapper.getOtherAirlineName())+ '</td>'+
                                '<td>'+wrapper.getAgreementType()+ '</td>'+
                                '<td>'+ wrapper.getEffectiveDate() + '</td>'+
                                '<td class="hide" >'+wrapper.getActive()+ '</td>'+
                                '<td>'+wrapper.getStatus()+ '</td>'+
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
        try {
            String agreementId = isMITA ? MITAagreementid : BIETAagreementid;
            list<MITA_Agreement__c> listAgr = [
                SELECT Airline_1__c, Airline_2__c, Active__c, Status__c, Cancellation_Reason__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name_on_AOC__c , Airline_2__r.Name_on_AOC__c , Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Agreement_processed_date__c, Cancellation_processed_date__c
                From MITA_Agreement__c m
                where id in :agreementId.split(',')];

            this.wrapper = new WrapperAgreement(listAgr.get(0), this.acc);
            if ( listAgr.size() > 1 ) {
                this.wrapper.checkMixAgreement(listAgr.get(1));
            }

        } catch (Exception e) {
            System.debug('EXCEPTION selectAgreement ' + e.getMessage());
        }

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
        MITA_Agreement__c agr = new MITA_Agreement__c(Airline_1__c = this.acc.Id, MITAorBIETA__c = isMITA ? 'MITA' : 'BIETA');
        this.wrapper = new WrapperAgreement(agr, this.acc);
        //editAgreementMode = true;
        if(isMITA){
            if(editBIETAAgreementMode){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It\'s not possible to create or edit an agreement in MITA and BIETA section at the same time. Please save the open one and try again.'));
                return;
            }
            this.editMITAAgreementMode  = true;
            this.chosenMITAAgreement = true;
        }else{
            if(editMITAAgreementMode){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'It\'s not possible to create or edit an agreement in MITA and BIETA section at the same time. Please save the open one and try again.'));
                return;
            }
            this.editBIETAAgreementMode  = true;
            this.chosenBIETAAgreement = true;
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
            if(this.wrapper.getId() == null){
                this.wrapper = null;
                chosenMITAAgreement = false;
            }
        }else{
            editBIETAAgreementMode = false;
            if(this.wrapper.getId() == null){
                this.wrapper = null;
                chosenBIETAAgreement = false;
            }
        }

    }

    public void saveMITAAgreement(){saveAgreement(true);}
    public void saveBIETAAgreement(){saveAgreement(false);}
    public void saveAgreement(boolean isMITA){
        this.wrapper.save(isMITA);
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
        system.savepoint sp = Database.setSavePoint();
        try{
            upsert c;

            Related_Contact__c relatedContact = new Related_Contact__c(
                Account__c = this.accountid,
                Contact__c = c.Id
            );
            insert relatedContact;
            chosenContact = true;
            editContactMode = false;

        }catch(Exception e){
            Database.rollback(sp);
            String cleanmessage = e.getMessage();
            if(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')!=-1)   cleanmessage = cleanmessage.substring(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35);
            ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'Error saving the contact: '+cleanmessage));
        }
    }
    public void newContact(){
        resetContact();
        ID rt = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        this.c = new Contact(MITA_Contact__c=true, RecordTypeId = rt, Status__c='Active');
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
        system.savepoint sp = Database.setSavePoint();
        try{
            c.MITA_Contact__c = false;
            upsert c;

            list<Related_Contact__c> listRelatedContact = [
                Select Id from Related_Contact__c where Contact__c = :c.Id and Account__c = :this.acc.Id];
            delete listRelatedContact;

        }catch(Exception e){
            Database.rollback(sp);
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
                                                                        OtherState, OtherCountry, Status__c, AccountId, Account.RecordTypeId, Account.Name_on_AOC__c , Account.IATA_ISO_Country__r.Name, Account.Top_Parent__c, Account.ParentId
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
        system.savepoint sp = Database.setSavePoint();

        try {
            foundContact.AccountId = accountid;
            foundContact.MITA_Contact__c = true;
            update foundContact;

            Related_Contact__c relatedContact = new Related_Contact__c(
                Account__c = this.accountid,
                Contact__c = foundContact.Id
            );
            insert relatedContact;

            searchContactMode = false;
            confirmMoveContactMode = false;
            duplicateContactMode = false;
            contactEmail = '';
            foundContact = new Contact();

        } catch (Exception e) {
            Database.rollback(sp);
            String cleanmessage = e.getMessage();
            if(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')!=-1)   cleanmessage = cleanmessage.substring(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+foundContact.Id+'" target="_blank">'+foundContact.Name+'</a> raised the following error: '+cleanmessage));
            system.debug(LoggingLevel.ERROR,'####### ERROR saving a contact: '+cleanmessage);
            return;
        }
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

    public class WrapperAgreement {
        public MITA_Agreement__c agreement {get; set;}
        public Boolean isMixed {get; set;}
        public Boolean isMITA {get; set;}
        public Boolean isNew {get; set;}
        public Boolean viewSeparated {get; set;}
        public MITA_Agreement__c agreementPax {get; set;}
        public MITA_Agreement__c agreementCargo {get; set;}
        private Account sourceAccount;

        public WrapperAgreement(MITA_Agreement__c agreement) {
            this(agreement,null);
        }
        public WrapperAgreement(MITA_Agreement__c agreement, Account sourceAccount) {
            this.agreement = agreement;
            this.sourceAccount = sourceAccount;
            this.isMixed = false;
            this.isNew = agreement.Id == null;
            this.isMITA = agreement.MITAorBIETA__c=='MITA';
            this.viewSeparated = true;
            if ( agreement.Agreement_type__c == TYPE_PAX ) {
                this.agreementPax = agreement;
            }
            if ( agreement.Agreement_type__c == TYPE_CARGO ) {
                this.agreementCargo = agreement;
            }
        }

        public Boolean checkMixAgreement(MITA_Agreement__c newAgreement) {
            if (this.agreement.Active__c && newAgreement.Active__c &&
                this.agreement.MITAorBIETA__c == newAgreement.MITAorBIETA__c &&
                (
                    (this.agreement.Airline_1__c == newAgreement.Airline_1__c && this.agreement.Airline_2__c == newAgreement.Airline_2__c) ||
                    (this.agreement.Airline_1__c == newAgreement.Airline_2__c && this.agreement.Airline_2__c == newAgreement.Airline_1__c)
                )
            ) {
                if ( this.agreement.Agreement_type__c == TYPE_PAX  && newAgreement.Agreement_type__c == TYPE_CARGO) {
                    this.agreementPax = this.agreement;
                    this.agreementCargo = newAgreement;
                    mixAgreement();
                    return true;
                }
                if ( this.agreement.Agreement_type__c == TYPE_CARGO  && newAgreement.Agreement_type__c == TYPE_PAX) {
                    this.agreementPax = newAgreement;
                    this.agreementCargo = this.agreement;
                    mixAgreement();
                    return true;
                }
            }
            return false;
        }
        public void mixAgreement() {
            this.agreement = new MITA_Agreement__c();
            this.agreement.MITAorBIETA__c = this.agreementPax.MITAorBIETA__c;
            this.agreement.Airline_1__c = this.agreementPax.Airline_1__c;
            this.agreement.Airline_2__c = this.agreementPax.Airline_2__c;
            this.agreement.Agreement_type__c = TYPE_PAX_CARGO;
            this.agreement.Created_date__c = maxDate(this.agreementPax.Created_date__c, this.agreementCargo.Created_date__c);
            this.agreement.Effective_date__c = maxDate(this.agreementPax.Effective_date__c, this.agreementCargo.Effective_date__c);
            this.agreement.Withdrawal_Request_Reception_Date__c = maxDate(this.agreementPax.Withdrawal_Request_Reception_Date__c, this.agreementCargo.Withdrawal_Request_Reception_Date__c);
            this.agreement.Cancellation_processed_date__c = maxDate(this.agreementPax.Cancellation_processed_date__c, this.agreementCargo.Cancellation_processed_date__c);
            this.agreement.Cancellation_date__c = maxDate(this.agreementPax.Cancellation_date__c, this.agreementCargo.Cancellation_date__c);
            //this.agreement.Cancellation_Reason__c = //not required
            this.agreement.Agreement_processed_date__c = maxDate(this.agreementPax.Agreement_processed_date__c, this.agreementCargo.Agreement_processed_date__c);
            this.isMixed = true;
        }

        private Date maxDate(Date date1, Date date2) {
            return date1 > date2? date1: date2;
        }

        public MITA_Agreement__c getAgreement() {
            return this.agreement;
        }

        public String getId() {
            if (this.agreementPax!=null && this.agreementCargo!=null) {
                return this.agreementPax.Id + ',' + this.agreementCargo.Id;
            }
            return this.agreement.Id;
        }
        public String getOtherDesignatorCode() {
            if (this.agreement.Id == null) {
                return this.agreementPax.Airline_1__c==this.sourceAccount.Id ? this.agreementPax.Airline2_designator_code__c : this.agreementPax.Airline1_designator_code__c;
            } else {
                return this.agreement.Airline_1__c==this.sourceAccount.Id ? this.agreement.Airline2_designator_code__c : this.agreement.Airline1_designator_code__c;
            }
        }
        public String getOtherAirlineName() {
            if (this.agreement.Id == null) {
                return this.agreementPax.Airline_1__c==this.sourceAccount.Id ? this.agreementPax.Airline_2__r.Name_on_AOC__c : this.agreementPax.Airline_1__r.Name_on_AOC__c;
            } else {
                return this.agreement.Airline_1__c==this.sourceAccount.Id ? this.agreement.Airline_2__r.Name_on_AOC__c : this.agreement.Airline_1__r.Name_on_AOC__c;
            }
        }
        public Account getOther() {
            if (this.agreement.Id == null) {
                return this.agreementPax.Airline_1__c==this.sourceAccount.Id ? this.agreementPax.Airline_2__r : this.agreementPax.Airline_1__r;
            } else {
                return this.agreement.Airline_1__c==this.sourceAccount.Id ? this.agreement.Airline_2__r : this.agreement.Airline_1__r;
            }
        }
        public String getAgreementType() {
            // change agreement type for all one way agreements (each side of the agreement has a different name, defined in MAP_ONE_WAY_TYPES)
            if (this.agreement.Airline_2__c == this.sourceAccount.Id) {
                String newAgreementType = MAP_ONE_WAY_TYPES.get(this.agreement.Agreement_type__c);
                if (newAgreementType!= null) {
                    return newAgreementType;
                }
            }
            return this.agreement.Agreement_type__c;
        }
        public String getEffectiveDate() {
            return this.agreement.Effective_date__c==null?'':this.agreement.Effective_date__c.format();
        }
        public String getStatus() {
            return this.agreement.Id == null? this.agreementPax.Status__c:this.agreement.Status__c;
        }
        public Boolean getActive() {
            return this.agreement.Id == null? this.agreementPax.Active__c:this.agreement.Active__c;
        }

        public void save(boolean isMITA) {
            this.agreement.MITAorBIETA__c = isMITA? 'MITA': 'BIETA';

            system.savepoint sp = Database.setSavePoint();
            try {
                // if a new agreemnt of type Pax and cargo is saved,
                // it must be separated in two different agreements
                if (this.isNew && this.agreement.Agreement_type__c == TYPE_PAX_CARGO) {
                    this.agreementPax = this.agreement.clone();
                    this.agreementPax.Agreement_type__c = TYPE_PAX;
                    this.agreementCargo = this.agreement.clone();
                    this.agreementCargo.Agreement_type__c = TYPE_CARGO;
                    saveSingleAgreement(this.agreementPax);
                    saveSingleAgreement(this.agreementCargo);

                } else if (this.isMixed) {
                    if (!this.viewSeparated) {
                        // copy agreement dates to Pax agreement
                        this.agreementPax.Created_date__c = this.agreement.Created_date__c;
                        this.agreementPax.Effective_date__c = this.agreement.Effective_date__c;
                        this.agreementPax.Withdrawal_Request_Reception_Date__c = this.agreement.Withdrawal_Request_Reception_Date__c;
                        this.agreementPax.Cancellation_processed_date__c = this.agreement.Cancellation_processed_date__c;
                        this.agreementPax.Cancellation_date__c = this.agreement.Cancellation_date__c;
                        this.agreementPax.Agreement_processed_date__c = this.agreement.Agreement_processed_date__c;
                        // copy agreement dates to Cargo agreement
                        this.agreementCargo.Created_date__c = this.agreement.Created_date__c;
                        this.agreementCargo.Effective_date__c = this.agreement.Effective_date__c;
                        this.agreementCargo.Withdrawal_Request_Reception_Date__c = this.agreement.Withdrawal_Request_Reception_Date__c;
                        this.agreementCargo.Cancellation_processed_date__c = this.agreement.Cancellation_processed_date__c;
                        this.agreementCargo.Cancellation_date__c = this.agreement.Cancellation_date__c;
                        this.agreementCargo.Agreement_processed_date__c = this.agreement.Agreement_processed_date__c;
                    }
                    saveSingleAgreement(this.agreementPax);
                    saveSingleAgreement(this.agreementCargo);
                } else {
                    saveSingleAgreement(this.agreement);
                }
            } catch (Exception e) {
                Database.rollback(sp);
                String cleanmessage = e.getMessage();
                if(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')!=-1)   cleanmessage = cleanmessage.substring(cleanmessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+35);
                ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'It was not possible to save the agreement because of the following error: '+cleanmessage));
                system.debug(LoggingLevel.ERROR, 'It was not possible to save the agreement because of the following error: '+e.getMessage());
            }
        }

        private void saveSingleAgreement(MITA_Agreement__c agreement) {
            if ( agreement.Cancellation_date__c != null && agreement.Cancellation_processed_date__c == null ) {
                agreement.Cancellation_processed_date__c = Date.today();
            }
            if ( agreement.Effective_date__c != null && agreement.Agreement_processed_date__c == null ) {
                agreement.Agreement_processed_date__c = Date.today();
            }
            // As first I save so that I can catch the errors raised by the validation rules
            upsert agreement;

            system.debug(LoggingLevel.ERROR, 'upserted the agreement: '+agreement.Airline_1__r.Name_on_AOC__c +' ---> '+agreement.Airline_2__r.Name_on_AOC__c +' with id = '+agreement.id);
            List<MITA_Agreement__c> listAllActiveAgreements = [
                SELECT Id, Airline_1__c, Airline_1__r.Name_on_AOC__c , Airline_2__c, Airline_2__r.Name_on_AOC__c , Agreement_type__c, Agreement_processed_date__c, Status__c, MITAorBIETA__c
                FROM MITA_Agreement__c
                WHERE ((Airline_1__c = :agreement.Airline_1__c AND Airline_2__c = :agreement.Airline_2__c)
                    OR (Airline_1__c = :agreement.Airline_2__c AND Airline_2__c = :agreement.Airline_1__c))
                AND MITAorBIETA__c = :agreement.MITAorBIETA__c
                AND Active__c = true
                AND ID <> :agreement.Id ];

            for ( MITA_Agreement__c otherAgr: listAllActiveAgreements ) {
                String firstAirlineName = otherAgr.Airline_1__r.Name_on_AOC__c;
                String secondAirlineName = otherAgr.Airline_2__r.Name_on_AOC__c;
                //String secondAirlineName = otherAgr.Airline_1__c==agreement.Airline_1__c ? otherAgr.Airline_2__r.Name_on_AOC__c  : otherAgr.Airline_1__r.Name_on_AOC__c;
                if (agreement.Agreement_Type__c == otherAgr.Agreement_Type__c ) {
                    throw new MITAException( firstAirlineName  +' has already an active agreement of type '+agreement.Agreement_Type__c +' with the airline ' + secondAirlineName);
                }
                if (agreement.Agreement_Type__c == TYPE_ISSUING_AIRLINE && otherAgr.Agreement_Type__c == TYPE_PARTICIPATING_AIRLINE ) {
                    throw new MITAException( firstAirlineName  +' has already an active One Way agreement of type '+agreement.Agreement_Type__c +' with the airline ' + secondAirlineName);
                }
            }
        }
    }

    /**
        DEACTIVATE AGREEMENTS SECTION
    **/
    public Boolean showDeactivateAgreementsPanel {get;set;}
    public MITA_Agreement__c dummyAgreement {get;set;}
    public String deactivateType {get;set;}

    public void showDeactivateMITAPanel(){
        this.deactivateType = 'MITA';
        showDeactivatePanel();
    }
    public void showDeactivateBIETAPanel(){
        this.deactivateType = 'BIETA';
        showDeactivatePanel();
    }
    private void showDeactivatePanel() {
        this.dummyAgreement = new MITA_Agreement__c(
            Cancellation_date__c = Date.today()
        );
        this.showDeactivateAgreementsPanel = true;
    }

    public void deactivateAgreements() {
        Date cancellationDate = this.dummyAgreement.Cancellation_date__c;
        list<MITA_Agreement__c> listUpdates = new list<MITA_Agreement__c>();

        list<MITA_Agreement__c> listAgreements = new list<MITA_Agreement__c>();
        for ( WrapperAgreement wrapper: agreements.values() ) {
            if (wrapper.isMixed) {
                listAgreements.add(wrapper.agreementPax);
                listAgreements.add(wrapper.agreementCargo);
            } else{
                listAgreements.add(wrapper.getAgreement());
            }
        }
        System.debug('*** listAgreements ' + listAgreements);
        for ( MITA_Agreement__c agreement: listAgreements ) {
            if (agreement.MITAorBIETA__c.equals(this.deactivateType) && agreement.Active__c ) {
                System.debug('*** agreement ' + agreement);
                agreement.Cancellation_date__c = cancellationDate;
                agreement.Cancellation_processed_date__c = Date.today();
                if (this.acc.Id == agreement.Airline_1__c) {
                    agreement.Cancellation_Reason__c = 'Airline 1 leaves agreement';
                } else {
                    agreement.Cancellation_Reason__c = 'Airline 2 leaves agreement';
                }
                listUpdates.add(agreement);
            }
        }
        if (!listUpdates.isEmpty()) {
            update listUpdates;
            refreshAgreementList();
        }
        this.showDeactivateAgreementsPanel = false;
    }

    public void cancelDeactivation() {
        this.showDeactivateAgreementsPanel = false;
    }

}
