public with sharing class IDCardLoginController extends IdCardAbstractController {


    public String IATACodeLocation {get; set;}
    public String IATACodeLocation2 {get; set;}
    public String VERNumber {get; set;}
    public String TempVERNumber {get; set;}
    public String verNum {get; set;}
    public String idCardQuery {get;set;}
    public String idCardAppQuery {get;set;}
    public ID_Card_Application__c [] pendingIdCardsAppV2 {get;set;}
 
    public String DOB {get; set;}

    public Boolean isNew {get; set;} 

    private String applicationType = null;

    public String pageTitle {get; set;}

    public String FNAME {
        get;
        set { FNAME = String.escapeSingleQuotes(value);  } 
    }
    public String LNAME {
        get;
        set{ LNAME = String.escapeSingleQuotes(value);}
    }

    private String agencyStatus {get; set;}
    private Boolean statusCancelled {
        get;
        set {statusCancelled = false; }
    }
    //RN-INC356501
    public String whichcountry {get;set;}

    public IDCardLoginController() {
        System.debug('**** Enter in IDCARD LOGIN PAGE');

        Cookie iataCodeCookie = new Cookie('iatacode', '', null, -1, true);
        ApexPages.currentPage().setCookies(new Cookie[] {iataCodeCookie});

        Cookie verNumberCookie = new Cookie('ver', '', null, -1, true);
        ApexPages.currentPage().setCookies(new Cookie[] {verNumberCookie});

        isNew = false;
        this.verified = false;
        initialize();
        PageTitle = '';
    }

    //Login with Codes
    public PageReference verify() {
        if (!Test.isRunningTest())  findLocation();
        Boolean validCaptcha;

        //@@ Disables captcha
        //validCaptcha = true;

        //exception for China //RN-INC356501
        if (whichcountry == 'CN'){
            validCaptcha = true;
        }else{
            validCaptcha =validCaptcha();
        }

        //for test method to pass captcha validation
        if (Test.isRunningTest() )
            validCaptcha = true;

        if (!validCaptcha) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_CaptchaError ));
            return null;
        }

        if (IATACodeLocation == null || IATACodeLocation == '') {
            AddError(Label.IDCard_IATACodeRequired);
            return null;
        }


        if (IATACodeLocation.length() != 8) {
            AddError(Label.IDCard_IATACodeNot8Digits);
            return null;
        }


        if (VERNumber == null || VERNumber == '') {
            AddError(Label.IDCard_VERrequired);
            return null;
        }



        Pagereference prAgencyDetails = Page.IDCard_MultipleAgency_Details;//Page.IDCard_Portal;

        Contact[] contacts;

        if (VERNumber.trim().isNumeric() && IATACodeLocation.trim().isNumeric()) {
            //jfo test first if key contact
            system.debug('[Controller] TEST KEY CONTACVT WITH PARAM  ' + IATACodeLocation.trim() + ' VERNUM ' + VERNumber );
            system.debug('[Controller] select m.Id, m.Account__c, m.Account__r.IATACode__c , m.delegate__c from Managed_agency__c m where m.contact__r.Ver_Number_2__c =:VERNumber and m.Account__r.IATACode__c =: IATACodeLocation.trim() '  );
            List<Managed_agency__c> managedAccountList = [select m.Id, m.Account__c, m.Account__r.IATACode__c , m.delegate__c
                    from Managed_agency__c m
                    where m.contact__r.Ver_Number_2__c = :VERNumber
                            and m.Account__r.IATACode__c = : IATACodeLocation.trim()
                                    and m.Account__r.IDCard_Key_Account__c = true
                                            and m.Account__r.Status__c = : IDcardutil.ALLOWED_ACCOUNT_STATUS];
            if (managedAccountList.size() > 0) {
                Cookie iataCodeCookie = new Cookie(IDCardUtil.PARAM_IATACODE, IATACodeLocation.trim(), null, 7200, true);
                Cookie verNumCookie = new Cookie(IDCardUtil.PARAM_VER, VERNumber.trim(), null, 7200, true);
                ApexPages.currentPage().setCookies(new Cookie[] {iataCodeCookie, verNumCookie});
                system.debug('[Controller] key contact  from  key Account selected ');
                Pagereference prApplicationForm = Page.IDCard_PortalKeyContact;
                prApplicationForm.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation.trim()));
                prApplicationForm.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(VERNumber.trim()));
                return prApplicationForm;
            }

            ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

            // Kofi: 12/09/2013. Card_Status__c is removed from the criteria.
            // INC183592
            
            contacts = [Select   c.VER_Number_2__c, c.FirstName, c.LastName, c.Date_of_Birth__c,
                        c.Account.IDCard_Key_Account__c, c.Account.type, c.Account.Short_Name__c, c.Account.Is_AIMS_Account__c , c.Id,
                        c.Account.Status__c, c.Account.IATACode__c, c.Account.ID_Card_KeyAccount_features__c
                        From Contact c
                        where
                        c.Id IN (Select i.Related_Contact__c From ID_Card__c i where i.RecordTypeId = : rectypeid)
                        and c.RecordType.Name = 'Standard'
                                                AND c.Account.RecordType.Name = 'Agency'
                                                        AND (c.Account.Status__c in :IDCardUtil.ALLOWED_ACCOUNT_STATUS OR Account.Status__c = 'Terminated')
                                                        AND c.Account.IATACode__c = : IATACodeLocation.trim()
                                                                AND c.Account.type  in :IDCardUtil.ALLOWED_ACCOUNT_TYPES
                                                                and c.VER_Number_2__c = : VERNumber];

            if (contacts == null || contacts.size() == 0) {
                AddError(Label.IDCard_NoContactsFound);
                return null;
            }


            /*List<Contact> keyContactcontactList = [Select c.IDCardContactType__c,  c.VER_Number_2__c,c.FirstName,c.LastName,c.Date_of_Birth__c,
            c.Account.IDCard_Key_Account__c, c.Account.type, c.Account.Short_Name__c, c.Account.Is_AIMS_Account__c , c.Id
            From Contact c
            where
            c.IDCardContactType__c like '%key contact%'
            And c.Account.IDCard_Key_Account__c = true
            AND c.Account.Status__c in :IDCardUtil.ALLOWED_ACCOUNT_STATUS
            AND c.Account.IATACode__c =: IATACodeLocation.trim()
            AND c.Account.type  in :IDCardUtil.ALLOWED_ACCOUNT_TYPES
            and c.VER_Number_2__c =: VERNumber limit 1];
            Contact keyContactcontact = null;
            if(keyContactcontactList.size()>0)
            keyContactcontact = keyContactcontactList[0];
            //(c.IDCardContactType__c like '%key contact%' and c.Account.IDCard_Key_Account__c = true)  or
            if(keyContactcontact !=null ){*/


            String acccountType = IDCardUtil.GetAgentTypeFromAccountType(contacts[0].Account.type);

            IATA_ISO_Country__c contactCountry;
            try {
                contactCountry = IDCardUtil.GetIATAISOCountryOfContact(IATACodeLocation);
            } catch (Exception e) {
                AddError('Please Contact IDCard Support with the following message: ISO Country not found for the following Account:' + IATACodeLocation );
                return null;
            }


            boolean blackListedCard = false;
            String IDCardQuery = 'Select Id, Blacklisted__c, Card_Status__c From ID_Card__c where Related_Contact__c  = \'' + contacts[0].Id + '\' order by createddate desc';
            ID_Card__c[] cards = Database.query(IDCardQuery);

            for (ID_Card__c aCard : cards) {
                if (aCard.Blacklisted__c == true) {
                    mailAlertOnBlackListedConnection(aCard, VERNumber, IATACodeLocation);
                    AddError('Your IATA/IATAN ID Card has been blacklisted. For more information, please kindly contact IATA Customer Service on www.iata.org/cs');
                    return null;
                }
            }

            Price_Table__c[] listPriceTables = [Select p.Type_Class_of_Agent__c, p.Expedite__c, p.Name
                                                From Price_Table__c p
                                                where p.Type_Class_of_Agent__c = :acccountType
                                                        and p.ISO_Country__r.Id = :contactCountry.Id];
            if (listPriceTables == null || listPriceTables.size() == 0) {
                AddError('Please Contact IDCard Support with the following message: Price Table not found for the following Country:' + contactCountry.Name );
                return null;
            }

            if (contacts[0].VER_Number_2__c != null) {


                //check if theres any pending cases
                Case[] pendingCase =  [Select Id from Case where RecordType.Name = 'ID Card Application' AND Contact.Id = : contacts[0].Id AND status <> 'Closed' limit 1];
                //INC239933
                TempVERNumber = 'Z'+VERNumber;
                ID_Card_Application__c [] pendingIdCardsApp = [Select id from ID_Card_Application__c where RecordType.Name = 'Single ID Card Operation' 
                                                                                                        AND (((VER_Number__c = :VERNumber OR VER_Number__c = :TempVERNumber) AND IATA_Code__c =:IATACodeLocation.trim())
                                                                                                        OR (VER_Number__c = :VERNumber OR VER_Number__c = :TempVERNumber )) 
                                                                                                        AND (Application_Status__c = 'Pending' OR Application_Status__c = 'Unpaid')  limit 1];
                                                          
                
                if (pendingCase != null && pendingCase.size() > 0){
                    prAgencyDetails = Page.IDCard_PendingCase_Details;
                    prAgencyDetails.getParameters().put('cid', IDCardUtil.EncryptEncodeParameter(pendingCase[0].Id));
                    return prAgencyDetails;
                    //redirect to new pending case information

                } else if (pendingIdCardsApp != null && pendingIdCardsApp.size() > 0) { //INC239933
                    prAgencyDetails = Page.IDCard_PendingIdCardApp_Details;
                    prAgencyDetails.getParameters().put('apId', IDCardUtil.EncryptEncodeParameter(pendingIdCardsApp[0].Id));
                    return prAgencyDetails;
                }

                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation));
                prAgencyDetails.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(contacts[0].VER_Number_2__c));

                if ( contacts[0].LastName != '') prAgencyDetails.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(contacts[0].LastName.trim()));
                if ( contacts[0].FirstName != '')  prAgencyDetails.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(contacts[0].FirstName.trim()));

                if ( contacts[0].Date_of_Birth__c != null) {

                    // String[] dob_DateTime = String.ValueOf(contacts[0].Date_of_Birth__c).split('/');
                    // DateTime parsedDtDOB = DateTime.newInstance(Integer.valueOf(dob_DateTime[2]), Integer.valueOf(dob_DateTime[0]), Integer.valueOf(dob_DateTime[1]));

                    prAgencyDetails.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(String.ValueOf(contacts[0].Date_of_Birth__c)));//parsedDtDOB.format('yyyy-MM-dd')));
                }

                // INC183592 & INC243166
                if (contacts[0].Account.Status__c == 'Terminated' || cards[0].Card_Status__c == IDCardUtil.CARDSTATUS_CANCELED){
                        /*(cards[0].Card_Status__c == IDCardUtil.CARDSTATUS_CANCELED &&
                         contacts[0].Account.IDCard_Key_Account__c == TRUE &&
                         contacts[0].Account.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Only_KC_Purchase))) {*/

                    Pagereference prSkipDetails = Page.IDCard_Portal;
                    prSkipDetails.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(contacts[0].VER_Number_2__c));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(String.ValueOf(contacts[0].Date_of_Birth__c)));//parsedDtDOB.format('yyyy-MM-dd')));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(contacts[0].Account.IATACode__c));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter('New'));
                    prSkipDetails.getParameters().put(IDCardUtil.ACCOUNT_STATUS_TERMINATED, IDCardUtil.EncryptEncodeParameter(contacts[0].Account.Status__c));
                    prSkipDetails.setRedirect(true);
                    return prSkipDetails;
                }


            } else {
                AddError(Label.IDCard_NoContactsFound);
                return null;
            }

            prAgencyDetails.setRedirect(true);
        } else {
            AddError(Label.IDCard_NumericFieldError);
            return null;
        }

        return prAgencyDetails;

    }


    /*
    *
    *
    *
    Login with personal info
    *
    *
    */
    public PageReference verifyAlternative() {
        Boolean validCaptcha;
         if (!Test.isRunningTest())  findLocation();

        //@@ Disables captcha
        //validCaptcha = true;

        //exception for China //RN-INC356501
        if (whichcountry == 'CN'){
            validCaptcha = true;
        }else{
            validCaptcha =validCaptcha();
        }

        //for test method to pass captcha validation
        if (Test.isRunningTest())
            validCaptcha = true;

        if (!validCaptcha) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_CaptchaError));
            return null;
        }

        if (IATACodeLocation2.length() != 8) {
            AddError(Label.IDCard_IATACodeNot8Digits);
            return null;
        }


        Integer counter = 0;

        if ( IATACodeLocation2 != '') counter++;
        if ( FNAME != '') counter++;
        if ( LNAME != '') counter++;
        if (  DOB != null && DOB != '') counter++;

        //All four fields are manadatory hence <4
        if (counter < 4) {
            AddError(Label.IDCard_FillAllFields);
        } else {
            DOB = DOB.trim();
            Pattern myPattern =
                Language == 'en_US' ?
                pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)') :
                pattern.compile('(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[012])/((19|20)\\d\\d)') ;


            Matcher myMatcher = myPattern.matcher(DOB);

            if (!myMatcher.matches()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_InvalidDateFormat));
                return null;
            }

            String[] dob_DateTime = DOB.split('/');
            DateTime parsedDtDOB = null;
            if (Language == 'en_US')
                parsedDtDOB = DateTime.newInstance(Integer.valueOf(dob_DateTime[2]), Integer.valueOf(dob_DateTime[0]), Integer.valueOf(dob_DateTime[1]));
            else
                parsedDtDOB = DateTime.newInstance(Integer.valueOf(dob_DateTime[2]), Integer.valueOf(dob_DateTime[1]), Integer.valueOf(dob_DateTime[0]));

            if (IATACodeLocation2 != '') {
                IATACodeLocation2 = IATACodeLocation2.trim();
                // check the account if valid
                System.debug('IATACodeLocation2.trim() ' + IATACodeLocation2.trim()
                             + '  IDCardUtil.ACCOUNT_STATUS_LISTED' + IDCardUtil.ACCOUNT_STATUS_LISTED
                             +  '  IDCardUtil.ACCOUNT_STATUS_APPROVED ' + IDCardUtil.ACCOUNT_STATUS_APPROVED
                             + '  IDCardUtil.ACCOUNT_STATUS_CHANGES_PROCESSED' + IDCardUtil.ACCOUNT_STATUS_CHANGES_PROCESSED
                             + ' IDCardUtil.ACCOUNT_STATUS_UNDER_REVIEW' + IDCardUtil.ACCOUNT_STATUS_UNDER_REVIEW
                             + '  IDCardUtil.ACCOUNT_TYPE_PASSENGER' + IDCardUtil.ACCOUNT_TYPE_PASSENGER
                             + ' IDCardUtil.ACCOUNT_TYPE_TIDS ' + IDCardUtil.ACCOUNT_TYPE_TIDS);
                // INC183592
                Account[] accounts = [Select a.Id, a.type, a.Short_Name__c, a.Is_AIMS_Account__c,
                                      a.Status__c, a.IATACode__c, a.Location_Class__c
                                      From Account a
                                      where a.IATACode__c = : IATACodeLocation2.trim()
                                              and a.RecordType.Name = 'Agency'
                                                      and (a.Status__c in :IDCardUtil.ALLOWED_ACCOUNT_STATUS OR Account.Status__c = 'Terminated') // INC183592
                                                            and WebStar_ID__c = null
                                                              and (a.Location_Class__c in :IDCardUtil.ALLOWED_ACCOUNT_LOCATION_CLASS)];  
                                                              

                if (accounts == null || accounts.size() == 0) {
                    AddError(String.Format(Label.ID_Card_Account_Not_Found, new String[] {'<i>' + IATACodeLocation2.trim() + '</i>'})); 
                    System.debug('*** ' + accounts);
                    return null;
                }

                String acccountType = IDCardUtil.GetAgentTypeFromAccountType(accounts[0].type);

                //IATA_ISO_Country__c contactCountry = IDCardUtil.GetIATAISOCountryOfContact(IATACodeLocation2);
                IATA_ISO_Country__c contactCountry;
                try {
                    contactCountry = IDCardUtil.GetIATAISOCountryOfContact(IATACodeLocation2);
                } catch (Exception e) {
                    system.debug('[IDCardLoginController] error ISO Country not found for the following Account:' + IATACodeLocation);
                    AddError('Please Contact IDCard Support with the following message: ISO Country not found for the following Account:' + IATACodeLocation2);
                }

                Price_Table__c[] listPriceTables = [Select p.Type_Class_of_Agent__c, p.Expedite__c, p.Name
                                                    From Price_Table__c p
                                                    where p.Type_Class_of_Agent__c = :acccountType
                                                            and p.ISO_Country__c = :contactCountry.Id];

                if (listPriceTables == null || listPriceTables.size() == 0) {
                    AddError('Please Contact IDCard Support with the following message: Price Table not found for the following Country:' + contactCountry.Name + ' ISO search from ' + contactCountry.Id );
                    return null;
                }

                //INC183592
                agencyStatus = accounts[0].Status__c;

            }

            /*
            //The query checks for agent that already has an Active ID Card
            String query = 'Select c.Id,c.LastName, c.FirstName,c.Date_of_Birth__c,c.Account.IATACode__c, c.VER_Number_2__c From Contact c where  c.RecordType.Name = \'Standard\' and'
            +' c.Id IN (Select i.Related_Contact__c From ID_Card__c i where i.Card_Status__c = \''+IDCardUtil.CARDSTATUS_PRINTED_DELIVERED+'\'  or i.Card_Status__c = \''+IDCardUtil.CARDSTATUS_CANCELED+'\') and ';
            */

            //The query checks for agent that already has an Active ID Card
            String ContactQuery = 'Select c.Id,c.LastName, c.FirstName,c.Date_of_Birth__c,c.Account.IATACode__c, c.VER_Number_2__c'
                                  + ' From Contact c'
                                  + ' where  c.RecordType.Name = \'Standard\' and '
                                  + ' c.FirstName = \'' + FNAME.trim() + '\''
                                  + ' and c.LastName = \'' + LNAME.trim() + '\''
                                  + ' and c.Date_of_Birth__c = ' + parsedDtDOB.format('yyyy-MM-dd')
                                  + ' and  c.account.IATACode__c =\'' + IATACodeLocation2.trim() + '\' ' ;
            //  +' c.Id IN (Select i.Related_Contact__c From ID_Card__c i) and ';

            system.debug('[IDCardLoginController] Existing contact search query ' + ContactQuery);
            Contact[] contacts = Database.query(ContactQuery);


            //RA: 7/9/2013 Check IDCard entries
            /*
            String IDCardQuery = 'Select i.Related_Contact__c From ID_Card__c i where (i.Card_Status__c = \''+IDCardUtil.CARDSTATUS_PRINTED_DELIVERED+'\'  or i.Card_Status__c = \''+IDCardUtil.CARDSTATUS_CANCELED+'\') '
            +' and i.FirstName__c = \'' +FNAME.trim() + '\' and i.LastName__c = \'' + LNAME.trim() +'\' and i.Date_of_Birth__c = '+ parsedDtDOB.format('yyyy-MM-dd');
            */

            ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

            String IDCardQuery = 'Select i.Related_Contact__c, i.Blacklisted__c, Card_Status__c '
                                 + ' From ID_Card__c i '
                                 + 'where '
                                 + '  i.RecordTypeId = \'' + rectypeid
                                 + '\' and i.FirstName__c = \'' + FNAME.trim() + '\' '
                                 + ' and i.LastName__c = \'' + LNAME.trim() + '\' '
                                 + ' and i.Date_of_Birth__c = ' + parsedDtDOB.format('yyyy-MM-dd') 
                                 + ' order by i.Valid_To_Date__c desc LIMIT 1';

            system.debug('[IDCardLoginController] Existing card search query ' + IDCardQuery);
            ID_Card__c[] cards = Database.query(IDCardQuery);

            boolean blackListedCard = false;
            for (ID_Card__c aCard : cards) {
                if (aCard.Blacklisted__c == true) {
                    mailAlertOnBlackListedConnection(aCard, ' ######  LastName :' + LNAME + '  FirstName ' + FNAME , IATACodeLocation);
                    AddError('Your IATA/IATAN ID Card has been blacklisted. For more information, please kindly contact IATA Customer Service on www.iata.org/cs');
                    return null;
                }
            }
            system.debug('[IDCardLoginController]FOUND ' + contacts.size() + ' CONTACTS AND  ' + cards.size() + ' CARDS');

            //INC239933
            Date birthDate = Date.newInstance(parsedDtDOB.year(), parsedDtDOB.month(), parsedDtDOB.day());
            
            idCardQuery = 'Select id,FirstName__c,LastName__c,Date_of_Birth__c,Card_Status__c, VER_Number__c'
                                      + ' from ID_Card__c '
                                      + ' where Agency_IATA_Code__c=\'' + IATACodeLocation2.trim() + '\' '                                      
                                      + ' and LastName__c =  \'' + LNAME.trim() + '\''
                                      + ' and FirstName__c = \'' + FNAME.trim() +'\''
                                      + ' and Date_of_Birth__c =  ' + parsedDtDOB.format('yyyy-MM-dd')
                                      + ' AND Card_Status__c != \'Cancelled ID Card\' limit 1';

            idCardAppQuery = 'Select id,Last_Name__c,First_Name__c,Date_of_Birth__c'
                                + ' from ID_Card_Application__c '
                                + ' where RecordType.Name=\'Single ID Card Operation\''
                                + ' and Date_of_Birth__c=  ' + parsedDtDOB.format('yyyy-MM-dd')
                                + ' and First_Name__c=\''+FNAME.trim()+'\''
                                + ' AND ( Application_Status__c=\'Pending\''
                                    + ' OR Application_Status__c=\'Unpaid\')'; 


            ID_Card__c[] checkIdCard = Database.query(idCardQuery);

            if(checkIdCard != null && checkIdCard.size() > 0){
                verNum = checkIdCard[0].VER_Number__c;
                pendingIdCardsAppV2 = Database.query(idCardAppQuery + ' AND VER_Number__c=\''+ verNum +'\'' + 'limit 1');
            }
            else{
                pendingIdCardsAppV2 = Database.query(idCardAppQuery + 'AND IATA_Code__c=\'' +IATACodeLocation2.trim() +'\'' + 'limit 1');
            }

            system.debug('pendingIdCardsAppV2 ' + pendingIdCardsAppV2 + ' iata code ' + IATACodeLocation2.trim() + ' birthDate ' + birthDate + ' FNAME.trim() ' + FNAME.trim() + ' verNum ' + verNum);
            if (pendingIdCardsAppV2 != null && pendingIdCardsAppV2.size() > 0) {
                    Pagereference pendingIdCardApp = Page.IDCard_PendingIdCardApp_Details;
                    pendingIdCardApp.getParameters().put('apId', IDCardUtil.EncryptEncodeParameter(pendingIdCardsAppV2[0].Id));
                    return pendingIdCardApp;
            }

            //check if theres any pending cases for that contact
            //if (contacts.size() > 0 || cards.size() > 0) {
            if (cards.size() > 0 && pendingIdCardsAppV2 == null) {

                //ID contID = contacts.size() > 0 ? contacts[0].Id : cards[0].Related_Contact__c;

                ID contID = cards[0].Related_Contact__c;
                Case[] pendingCase =  [Select Id
                                       from Case
                                       where RecordType.Name = 'ID Card Application'
                                               AND Contact.Id = : contID
                                                       AND status <> 'Closed' limit 1];
                                
                if (pendingCase != null && pendingCase.size() > 0){
                    //redirect to new pending case information
                    Pagereference  pendingCasePage = Page.IDCard_PendingCase_Details;
                    pendingCasePage.getParameters().put('cid', IDCardUtil.EncryptEncodeParameter(pendingCase[0].Id));
                    return pendingCasePage;
                } 
            }


            //check if the application is still pending for new Agent
            //if (contacts.size() + cards.size() == 0) {
            if (cards.size() == 0) {

                //Case[] pendingCase =  [Select Id from Case where Related_ID_Card_Application__r.Last_Name__c=:LNAME.trim() and Related_ID_Card_Application__r.First_Name__c=:FNAME.trim()
                // and Related_ID_Card_Application__r.Date_of_Birth__c=:parsedDtDOB.format('yyyy-MM-dd') and RecordType.Name = 'ID Card Application' AND status <> 'Closed' limit 1];
                String pendingquery = 'Select Id'
                                      + ' from Case '
                                      + ' where Related_ID_Card_Application__r.Last_Name__c=\'' + LNAME.trim() + '\' '
                                      + ' and Related_ID_Card_Application__r.First_Name__c = \'' + FNAME.trim() + '\' '
                                      + ' and Related_ID_Card_Application__r.Date_of_Birth__c=  ' + parsedDtDOB.format('yyyy-MM-dd')
                                      + ' and RecordType.Name = \'ID Card Application\' '
                                      + ' AND status <> \'Closed\' limit 1';

                Case[] pendingCase = Database.query(pendingquery);

                if (pendingCase != null && pendingCase.size() > 0) {
                    //redirect to new pending case information
                    Pagereference  pendingCasePage = Page.IDCard_PendingCase_Details;
                    pendingCasePage.getParameters().put('cid', IDCardUtil.EncryptEncodeParameter(pendingCase[0].Id));
                    return pendingCasePage;
                }
            }

            ///if one or more record is found redirect to multi record page
            //if (contacts.size() + cards.size() >= 1) {
            if (cards.size() >= 1) {

                // INC183592 & INC243166
                if (agencyStatus == 'Terminated' || cards[0].Card_Status__c == IDCardUtil.CARDSTATUS_CANCELED) {
                    Pagereference prSkipDetails = Page.IDCard_Portal;
                    prSkipDetails.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(contacts[0].VER_Number_2__c));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(parsedDtDOB.format('yyyy-MM-dd')));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation2.trim()));
                    prSkipDetails.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter('New'));
                    prSkipDetails.getParameters().put(IDCardUtil.ACCOUNT_STATUS_TERMINATED, IDCardUtil.EncryptEncodeParameter('Terminated'));
                    prSkipDetails.setRedirect(true);
                    return prSkipDetails;
                }

                Pagereference prAgencyDetails = Page.IDCard_MultipleAgency_Details;

                if ( IATACodeLocation2 != '') prAgencyDetails.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation2.trim()));
                if ( FNAME != '') prAgencyDetails.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(FNAME.trim()));
                if ( LNAME != '')  prAgencyDetails.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(LNAME.trim()));
                if (  DOB != null && DOB != '' ) {
                    prAgencyDetails.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(parsedDtDOB.format('yyyy-MM-dd')));
                }

                prAgencyDetails.setRedirect(true);
                return prAgencyDetails;


            }

            //New Application
            else {

                // INC183592
                if (agencyStatus == 'Terminated') {
                    AddError(String.Format(Label.ID_Card_Account_Not_Found, new String[] {'<i>' + IATACodeLocation2.trim() + '</i>'}));
            		return null; 
                }

                Pagereference prAgencyDetails = Page.IDCard_Agency_Details;

                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter('New'));
                if ( IATACodeLocation2 != '') prAgencyDetails.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation2.trim()));
                if ( FNAME != '') prAgencyDetails.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(FNAME.trim()));
                if ( LNAME != '')  prAgencyDetails.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(LNAME.trim()));
                if ( DOB != '' && DOB != null) {
                    prAgencyDetails.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(parsedDtDOB.format('yyyy-MM-dd')));
                }

                prAgencyDetails.setRedirect(true);
                system.debug('New applicant. Redirect to cjheck agency page');
                return prAgencyDetails;
            }

        }

        return null;

    }



    //Error method: prints errors on page
    private void AddError(string msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }

    private void mailAlertOnBlackListedConnection(ID_Card__c card, String vernum, String iataCode) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();


        mail.setToAddresses(new String[] {'jfonteray@gmail.com'});
        mail.setSubject('A blacklisted agent has tried to sign in on ID Card Online Platform. VER: ' + vernum + ' IATA Code: ' + iataCode);
        mail.setPlainTextBody('A blacklisted agent has tried to sign in on ID Card Online Platform. VER: ' + vernum + ' IATA Code: ' + iataCode);
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        lstMsgs.add(mail);
        try {
            Messaging.sendEmail(lstMsgs);

        } catch (Exception  e) {
            system.debug('Failed to send email ' + e.getMessage());
        }

    }

    ////////////////////////////////////////////////////////////////////////
    //  Captcha stuff
    //   To setup follow the information in the following link
    //     http://wiki.developerforce.com/page/Adding_CAPTCHA_to_Force.com_Sites
    ///////////////////////////////////////////////////////////////////////



    /* Configuration */

    // The API endpoint for the reCAPTCHA service
    //private static String baseUrl = 'https://www.google.com/recaptcha/api/verify';
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = Label.ID_Card_PivateKEY;
    public String publicKey {
        get { return Label.ID_Card_PublicKEY;}
    }

    /* Implementation */

    // Create properties for the non-VF component input fields generated
    // by the reCAPTCHA JavaScript.
    public String challenge {
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  {
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }

    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }


    public Boolean validCaptcha() {
        String recaptcha = ApexPages.currentPage().getParameters().get('g-recaptcha-response');

        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        if ( recaptcha == null) {
            System.debug('reCAPTCHA verification attempt with empty form');
            return false;
        }


        HttpResponse r = makeRequest(baseUrl,
                                     //'secret=' + privateKey +
                                     'secret=6LeFvAYTAAAAAI7zjOUVELbcH6msdHgI2LZ5GdF0' +
                                     '&response='  + recaptcha +
                                     '&remoteip='  + remoteHost
                                    );
        if ( r != null ) {
            this.verified = (r.getBody().indexOf('"success": true') != -1);
        }

        return this.verified;



        /* System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        if ( challenge == null || response == null ) {
        System.debug('reCAPTCHA verification attempt with empty form');
        return false;
        }
        return true;
        if (response.equals('1304'))return true;
        HttpResponse r = makeRequest(baseUrl,
        'privatekey=' + privateKey +
        '&remoteip='  + remoteHost +
        '&challenge=' + challenge +
        '&response='  + response
        );

        if ( r != null ) {
        this.verified = (r.getBody().startsWithIgnoreCase('true'));
        }

        return this.verified;*/
    }

    public PageReference reset() {
        return null;
    }

    /* Private helper methods */

    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }

    private String remoteHost {
        get {
            String ret = '127.0.0.1';
            // also could use x-original-remote-host
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr') != null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP') != null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }

    //RN-INC356501
    public void findLocation(){

        ISSP_CS__c cs = ISSP_CS__c.getInstance('ipinfo_token');
        String ipinfo_token = cs.value__c;
        String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');

        String IP_LOOKUP_URL = 'https://ipinfo.io/' + ipAddress + '/json?token=' + ipinfo_token;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(IP_LOOKUP_URL);
        req.setMethod('GET');
        req.setTimeout(2000);
        HttpResponse res;
        try{
            res = h.send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            system.debug('message:' + String.valueOf(parser));
            while (parser.nextToken() != null) {
                system.debug('field name:' + JSONToken.FIELD_NAME);
                system.debug('value:' + parser.getText());
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'country')) {
                    parser.nextToken();
                    system.debug('COUNTRY:' + parser.getText());
                    whichcountry = parser.getText();
                }
            }


        }catch(Exception e){

        }


    }

}