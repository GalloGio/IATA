public without sharing class MITA_PortalMyAgreementsCtrl {

    public static final String APP_NAME = 'MITA Agreements';
    public Account acc {get;set;}
    public user currentUser {get;set;}

    public SuggestedAirline sair {get;set;}
    public String MITAagreementid {get;set;}
    public String BIETAagreementid {get;set;}

    public String MITAairlineID {get;set;}
    public String BIETAairlineID {get;set;}

    public List<ContactWrapper> otherContacts {get;set;}

    public Map<Id,MITA_AgreementsCtrl.WrapperAgreement> wrapperAgreements {get;set;}
    public MITA_AgreementsCtrl.WrapperAgreement wrapper {get;set;}

    //NEW VARIABLES

    public boolean MITAwithdrawalMode {get;set;}
    public boolean BIETAwithdrawalMode {get;set;}
    public boolean MITAsubmitMode {get;set;}
    public boolean BIETAsubmitMode {get;set;}


    public Map<Id,SuggestedAirline> suggestedAirlines {get;set;}

    public MITA_PortalMyAgreementsCtrl(){

        this.currentUser = [SELECT UserName, ContactId, Contact.AccountId, Contact.Account.Name, Profile.Name FROM User WHERE ID = :UserInfo.getUserId()];

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

        MITAwithdrawalMode = false;
        BIETAwithdrawalMode = false;
        MITAsubmitMode = false;
        BIETAsubmitMode = false;
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

    //Methods for edit and save the agreement
    public void selectMITAAgreement(){selectAgreement(true);}
    public void selectBIETAAgreement(){selectAgreement(false);}
    public void selectAgreement(boolean isMITA){
        String agreementId = isMITA ? MITAagreementid : BIETAagreementid;
        try {
            list<MITA_Agreement__c> listAgr = [
                SELECT Airline_1__c, Airline_2__c, Active__c, Status__c, Cancellation_Reason__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c,
                MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Agreement_processed_date__c, Cancellation_processed_date__c,
                Airline_1__r.Name_on_AOC__c , Airline1_designator_code__c, Airline_1__r.Airline_designator__c, Airline_1__r.Airline_Prefix__c, Airline_1__r.IATACode__c,
                Airline_2__r.Name_on_AOC__c , Airline2_designator_code__c, Airline_2__r.Airline_designator__c, Airline_2__r.Airline_Prefix__c, Airline_2__r.IATACode__c
                From MITA_Agreement__c m
                where id in :agreementId.split(',')];

            this.wrapper = new MITA_AgreementsCtrl.WrapperAgreement(listAgr.get(0), this.acc);
            if ( listAgr.size() > 1 ) {
                this.wrapper.checkMixAgreement(listAgr.get(1));
            }

        } catch (Exception e) {
            System.debug('EXCEPTION selectAgreement ' + e.getMessage());
        }

        try {
            MITA_Agreement__c agr = this.wrapper.getAgreement();
            Id otherAirline = (agreementId == agr.Airline_1__c ? agr.Airline_2__c : agr.Airline_1__c);
            otherContacts = new List<ContactWrapper>();
            for( Contact c : [SELECT Name, Email, Title, MITA_Contact_Type__c FROM Contact WHERE AccountId = :otherAirline AND MITA_Contact__c = true])
            otherContacts.add(new ContactWrapper(c,false));
        } catch (Exception e) {
            System.debug('EXCEPTION selectAgreement ' + e.getMessage());
        }
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
        /*
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
        */
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
        /*
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
        */
    }

    public void completeSubmit(){
        /*
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
        */
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

}