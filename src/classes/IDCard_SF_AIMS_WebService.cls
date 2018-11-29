global with sharing class IDCard_SF_AIMS_WebService {

    //not used anymore... formula field instead
    private static final string HOURSWORKED35MORE = '35 H OR MORE';
    private static final string HOURSWORKED2534 = '25-34 H';
    private static final string HOURSWORKED2024 = '20-24 H';
    private static final string HOURSWORKEDLESSTHAN20 = 'LESS THAN 20 H';

    private static final string JANUARY = 'January';
    private static final string FEBRUARY = 'February';
    private static final string MARCH = 'March';
    private static final string APRIL = 'April';
    private static final string MAY = 'May';
    private static final string JUNE = 'June';
    private static final string JULY = 'July';
    private static final string AUGUST = 'August';
    private static final string SEPTEMBER = 'September';
    private static final string OCTOBER = 'October';
    private static final string NOVEMBER = 'November';
    private static final string DECEMBER = 'December';

    private static final string CSPRINTEDDELIVERED = 'Printed/Delivered';
    private static final string CSVALID = 'Valid ID Card';
    private static final String CSCANCELED = 'Cancelled ID Card';

    private static final string SFUPDATEFAILED = 'FAILED';
    private static final string SFUPDATEOK = 'OK';

    private static final string CONTACTCHANGE = 'CONTACT_CHANGE';

    private static final string STATUSNOPHOTO = 'ERROR Picture Missing';
    private static final string STATUSREJECTED = 'ERROR Rejected by G&D';
    private static final string STATUSMISSINGINFO = 'ERROR Missing Information';

    private static final string ERRORSOURCEJAVATOOL = 'ID Card Printing Java Tool';

    private static final Integer ADDRESSLINEMAXLENGTH = 32;
    private static final Integer AGENCYNAMEMAXLENGTH = 25;
    private static final Integer COUNTRYMAXLENGTH = 26;
    private static final Integer CITYMAXLENGTH = 22;

    private static map<String, String> ISOCountry_AIMSArea;

    WebService static string ExtractIdCardInfo() {

        // This is the old web service for AIMS
        // disabled on 01.Dec.2016 in order to not interfere with the new web service that is bypassing AIMS
        if (!Test.isRunningTest()) return null;


        List<AIMSFileInfo> infos = new List<AIMSFileInfo>();

        ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

        // Get the list of cards that must be synchronized with AIMS
        List<ID_Card__c> cardsToSync = new List<ID_Card__c>();
        cardsToSync = [Select Valid_From_Date__c, Valid_To_Date__c, Photo__c, ID, HourWorkedCode__c , Is_Expedite__c, Related_Contact__c, VER_Number__c, FirstName__c, Middle_Initial__c, LastName__c, Date_of_Birth__c, Gender__c, Title__c, Position_Code__c, Duty_Code__c, Duties__c, Hours_per_week__c, Email__c, Start_Date_Industry__c, Start_Date_Agency_Year__c, Photo_Flag__c, Nature_of_ID_Card__c, Name_on_ID_Card__c, Card_Variation_Code__c, Card_Code__c, Agency_IATA_Code__c, Position__c, Start_Date_Agency_Month__c, Card_Status__c From ID_Card__c Where MustSyncWithAIMS__c = true  and RecordTypeId = : rectypeid ORDER BY Card_Status__c desc];

        if (!cardsToSync.isEmpty()) {
            set<ID> RelatedContactIDs = new set<ID>();
            for (ID_Card__c card : cardsToSync) {
                RelatedContactIDs.add(card.Related_Contact__c);
            }

            map<ID, Contact> RelatedContacts = new map<ID, Contact>();
            Set<ID> RelatedAccountIDs = new set<ID>();
            for (Contact aContact : [Select VER_Number__c, UIR__c, Title, Start_Date_Industry__c, Start_Date_Agency_Year__c, Start_Date_Agency_Month__c, AIMS_Qualification_Code__c, Position__c, Position_Code__c, LastName, Gender__c, FirstName, Duty_Code__c, Duties__c, Date_of_Birth__c, Email, Hours_per_week__c, AccountId, Id, Solicitation_Flag__c, Middle_Initial__c From Contact Where Id in : RelatedContactIDs]) {
                RelatedContacts.put(aContact.Id, aContact);

                RelatedAccountIDs.add(aContact.AccountId);
            }

            ISOCountry_AIMSArea = new map<String, String>();
            for (IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountries()) {
                ISOCountry_AIMSArea.put(country.AIMS_Area_Name__c, country.AIMS_Area_ID__c);
            }

            map<ID, Account> RelatedAccounts = new map<ID, Account>();
            for (Account aAcount : [Select Id, AIMS_ID__c, IATA_Area__c, BillingCountry From Account Where id in : RelatedAccountIDs]) {
                RelatedAccounts.put(aAcount.id, aAcount);
            }

            for (ID_Card__c aCard : cardsToSync) {
                AIMSFileInfo info = GetFileInfoFromIDCard(aCard, RelatedContacts, RelatedAccounts);

                //if (info.IsValid) infos.add(info);
                //pass all IDcards to .Net even the ones with errors;
                infos.add(info);

            }
        }
        System.debug('*** SFAIMS ' + infos);
        String retVal = WriteXml(infos);
        return retVal;
    }

    WebService static string SetMustSynchWithAIMSFlagToFalse(List<string> idCards) {
        try {
            List<ID_Card__c> cards = [SELECT Id, Valid_To_Date__c, Valid_From_Date__c, Photo__c, HourWorkedCode__c , MustSyncWithAIMS__c, VER_Number__c,
                                      Is_Expedite__c, FirstName__c, Middle_Initial__c, LastName__c, Date_of_Birth__c, Gender__c, Title__c,
                                      Position_Code__c, Duty_Code__c, Duties__c, Hours_per_week__c, Email__c, Start_Date_Industry__c, Start_Date_Agency_Year__c,
                                      Position__c, Start_Date_Agency_Month__c
                                      FROM ID_Card__c
                                      WHERE Id IN : idCards  ]; //and MustSyncWithAIMS__c = true

            if (cards != null && !cards.isEmpty()) {
                for (ID_Card__c aCard : cards) {
                    aCard.Sent_to_AIMS_on__c = Datetime.now();
                    aCard.MustSyncWithAIMS__c = false;
                }

                update cards;
            }
        } catch (Exception e) {}

        return '';
    }

    Webservice static string UpdateSFIdCards(string pUIR, string pCardHolderName, string pIATACode, string pValidFromDate, string pValidToDate, string pSFIdCardRecordId, String pAIMSComment) {

        List<ID_Card__c> relCards = [Select Received_From_AIMS__c, Photo__c, HourWorkedCode__c , Valid_To_Date__c, VER_Number__c, ID_Card_Application__c, Is_Expedite__c, Valid_From_Date__c, FirstName__c, Middle_Initial__c, LastName__c, Date_of_Birth__c, Gender__c, Title__c, Position_Code__c, Duty_Code__c, Duties__c, Hours_per_week__c, Email__c, Start_Date_Industry__c, Start_Date_Agency_Year__c, Related_Contact__c, Name_on_ID_Card__c, Id, Card_Status__c, Position__c, Start_Date_Agency_Month__c From ID_Card__c WHERE Id = : pSFIdCardRecordId limit 1];

        if (relCards != null && !relCards.IsEmpty()) {
            try {
                for (ID_Card__c aCard : relCards) {

                    // INC184819
                    //aCard.Valid_From_Date__c = date.valueOf(pValidFromDate);
                    //Date firstDayOfMonth = date.valueOf(pValidToDate).toStartOfMonth();
                    //Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                    //aCard.Valid_To_Date__c = lastDayOfMonth;
                    aCard.Card_Status__c = CSVALID;
                    aCard.Received_From_AIMS__c = Datetime.now();

                    List<Case> c = [Select Id, Status from Case c where c.Related_ID_Card_Application__c = : aCard.ID_Card_Application__c and c.RecordType.Name = 'ID Card Application'];
                    if (c != null && !c.IsEmpty()) {
                        c[0].Status = 'Closed';
                        update c[0];
                    }
                }
                update relCards;

            } catch (Exception e) {
                return GetXmlResponse(SFUPDATEFAILED, pSFIdCardRecordId, e.getMessage());
            }
        } else {
            return GetXmlResponse(SFUPDATEFAILED, pSFIdCardRecordId, 'No ID card');
        }
        return GetXmlResponse(SFUPDATEOK, pSFIdCardRecordId, '');
    }

    //Not used anymore .. formula field instead
    private static string GetHoursWorkedCode(string HoursWorked) {
        if (HoursWorked != null) {
            if (HoursWorked.toUpperCase() == HOURSWORKED35MORE) {
                return '1';
            } else if (HoursWorked.toUpperCase() == HOURSWORKED2534) {
                return '2';
            } else if (HoursWorked.toUpperCase() == HOURSWORKED2024) {
                return '3';
            } else return '4';
        }
        return '';
    }

    private static string GetMonthNumericValue(string aMonth) {
        if (aMonth.toUpperCase() == JANUARY || aMonth == '1')    return '01';
        else if (aMonth.toUpperCase() == FEBRUARY || aMonth == '2') return '02';
        else if (aMonth.toUpperCase() == MARCH || aMonth == '3') return '03';
        else if (aMonth.toUpperCase() == APRIL || aMonth == '4') return '04';
        else if (aMonth.toUpperCase() == MAY || aMonth == '5') return '05';
        else if (aMonth.toUpperCase() == JUNE || aMonth == '6') return '06';
        else if (aMonth.toUpperCase() == JULY || aMonth == '7') return '07';
        else if (aMonth.toUpperCase() == AUGUST || aMonth == '8') return '08';
        else if (aMonth.toUpperCase() == SEPTEMBER || aMonth == '9') return '09';
        else if (aMonth.toUpperCase() == OCTOBER || aMonth == '10') return '10';
        else if (aMonth.toUpperCase() == NOVEMBER || aMonth == '11') return '11';
        else if (aMonth.toUpperCase() == DECEMBER || aMonth == '12') return '12';
        else return 'ERROR';
    }

    private static AIMSFileInfo GetFileInfoFromIDCard(ID_Card__c aCard, map<ID, Contact> RelatedContacts, map<ID, Account> RelatedAccounts) {
        AIMSFileInfo aLineInfo = new AIMSFileInfo();
        alineinfo.IsValid = true;
        aLineInfo.ErrorMsg = '';


        // IdCard info
        aLineInfo.CardId = aCard.Id;

        aLineInfo.CardType = (aCard.Nature_of_ID_Card__c == null ? '' : aCard.Nature_of_ID_Card__c.toUpperCase());
        //set nature of card to canceled when the status of the IDCard is canceled
        if (aCard.Card_Status__c == 'Cancelled ID Card')
            aLineInfo.CardType = 'CANCELLATION';

        aLineInfo.IATACode = (aCard.Agency_IATA_Code__c == null ? '' : aCard.Agency_IATA_Code__c);
        if (aLineInfo.IATACode == null || aLineInfo.IATACode == '') {
            aLineInfo.ErrorMsg = 'IATA Code missing';
            aLineInfo.IsValid = false;
        }

        aLineInfo.NameOnIDCard = (aCard.Name_on_ID_Card__c == null ? '' : aCard.Name_on_ID_Card__c);
        if (aLineInfo.NameOnIDCard == null || aLineInfo.NameOnIDCard == '') {
            aLineInfo.ErrorMsg = 'NameOnIDCard is missing';
            aLineInfo.IsValid = false;
        }

        aLineInfo.CardCode = (aCard.Card_Code__c == null ? '' : aCard.Card_Code__c);
        aLineInfo.CardVariationCode = (aCard.Card_Variation_Code__c == null ? '' : aCard.Card_Variation_Code__c);
        aLineInfo.PhotoFlag = (aCard.Photo_Flag__c == null ? '' : aCard.Photo_Flag__c);

        // Previously fetched from the contact object now we get the info from the IDCard Object itself
        aLineInfo.VERNumber = (aCard.VER_Number__c == null ? '' : aCard.VER_Number__c);
        if (aLineInfo.VERNumber == null || aLineInfo.VERNumber == '') {
            aLineInfo.ErrorMsg = 'VERNumber is missing';
            aLineInfo.IsValid = false;
        }
        aLineInfo.FirstName = (aCard.FirstName__c == null ? '' : aCard.FirstName__c.toUpperCase().trim());
        aLineInfo.Initials = (aCard.Middle_Initial__c == null ? '' : aCard.Middle_Initial__c.toUpperCase().trim());
        aLineInfo.LastName = (aCard.LastName__c == null ? '' : aCard.LastName__c.toUpperCase().trim());
        aLineInfo.BirthDate = getDateOfBirthAsString(acard.Date_of_Birth__c);

        aLineInfo.Gender = (aCard.Gender__c == null ? '' : aCard.Gender__c.substring(0, 1).toUpperCase().trim());
        aLineInfo.Title = (aCard.Title__c == null ? '' : aCard.Title__c.toUpperCase().trim());
        aLineInfo.PositionCode = (aCard.Position_Code__c == null ? '' : aCard.Position_Code__c);
        aLineInfo.PositionDescription = (aCard.Position__c == null ? '' : aCard.Position__c.toUpperCase());
        aLineInfo.DutiesCode = (aCard.Duty_Code__c == null ? '' : aCard.Duty_Code__c);
        aLineInfo.DutiesDescription = (aCard.Duties__c == null ? '' : aCard.Duties__c.toUpperCase());
        aLineInfo.HoursWorkedDescription = (aCard.Hours_per_week__c == null ? '' : aCard.Hours_per_week__c.toUpperCase().trim());
        aLineInfo.HoursWorkedCode = (aCard.HourWorkedCode__c == null ? '1' : aCard.HourWorkedCode__c);
        aLineInfo.Email = (aCard.Email__c == null ? '' : aCard.Email__c.toUpperCase().trim());
        aLineInfo.YearEnteredIndustry = (aCard.Start_Date_Industry__c == null ? '' : string.valueOf(aCard.Start_Date_Industry__c));

        aLineInfo.Expedite = (aCard.Is_Expedite__c == true ? 'Y' : 'N');


        //@@@
        aLineInfo.ValidFrom = getDateOfBirthAsString(acard.Valid_From_Date__c);
        aLineInfo.ValidTo = getDateOfBirthAsString(acard.Valid_To_Date__c);
        //@@@


        // "mm/yyyy" format
        aLineInfo.DateStartInCompany = getStartDateInAgencyToAIMSFormat(aCard.Start_Date_Agency_Month__c, aCard.Start_Date_Agency_Year__c);
        if (aLineInfo.DateStartInCompany.contains('ERROR')) {
            aLineInfo.ErrorMsg = 'Error in Month Converstion';
            aLineInfo.IsValid = false;
        }


        // Related Contact Info
        Contact aContact = RelatedContacts.get(aCard.Related_Contact__c);
        if (aContact != null) {
            aLineInfo.Solicitation = (aContact.Solicitation_Flag__c == true ? 'Y' : 'N');

            aLineInfo.UIRCode = (aContact.UIR__c == null ? '' : aContact.UIR__c);

            //check if picture has good name
            string goodPicNameJPG = aLineInfo.UIRCode + '.jpg';
            string goodPicNameJPEG = aLineInfo.UIRCode + '.jpeg';
            if (aCard.Photo__c != null && aCard.Photo__c.toUpperCase() != goodPicNameJPG.toUpperCase()  && aCard.Photo__c.toUpperCase() != goodPicNameJPEG.toUpperCase() ) {
                aLineInfo.IsValid = false;
                aLineInfo.ErrorMsg = 'Photo Name not correct for card: ' + aLineInfo.UIRCode;
            }

            aLineInfo.QualificationCode = (aContact.AIMS_Qualification_Code__c == null ? '' : aContact.AIMS_Qualification_Code__c.toUpperCase());

            // Related Account Info
            Account aAccount = RelatedAccounts.get(aContact.AccountId);
            if (aAccount != null) {
                aLineInfo.AIMSId = (aAccount.AIMS_ID__c == null ? '' : aAccount.AIMS_ID__c);

                //Area Code
                if ( ISOCountry_AIMSArea.get(aAccount.BillingCountry.toUpperCase()) == null) {
                    aLineInfo.IsValid = false;
                    aLineInfo.ErrorMsg = 'Cannot find ISO Country / AIMS ID entry for country ' + aAccount.BillingCountry;
                    aLineInfo.AreaCode = 'Not Found';
                } else
                    aLineInfo.AreaCode = ISOCountry_AIMSArea.get(aAccount.BillingCountry.toUpperCase());

            }
        } else {
            aLineInfo.IsValid = false;
            aLineInfo.ErrorMsg = 'XML error';
        }

        System.debug('*** SFAIMS aLineInfo ' + aLineInfo);
        return aLineInfo;
    }

    private static string getDateOfBirthAsString(date dateOfBirth) {
        if (dateOfBirth != null) {
            datetime aDt = date.newInstance(dateOfBirth.year(), dateOfBirth.month(), dateOfBirth.day());
            return aDt.format('MM/dd/yyyy', 'GMT');
        } else return '';
    }

    private static string getStartDateInAgencyToAIMSFormat(string startDateMonth, string startDateYear) {
        // "mm/yyyy" format
        if (startDateMonth != null && startDateYear != null) {
            return GetMonthNumericValue(startDateMonth) + '/' + startDateYear;
        } else return '';
    }

    private static String GetXmlResponse(string Status, string sfCardID, string ErrorMsg) {
        Xmlstreamwriter writer = new Xmlstreamwriter();

        writer.writeStartDocument('utf-8', '1.0');
        writer.writeStartElement('', 'IDCardSfAims', 'http://www.w3.org/2001/XMLSchema-instance');
        writer.writeStartElement(NULL, 'Status', null);
        writer.writeCharacters(Status);
        writer.writeEndElement();
        writer.writeStartElement(null, 'SFIDCard', null);
        writer.writeCharacters(sfCardID);
        writer.writeEndElement();
        writer.writeStartElement(null, 'ErrorMsg', null);
        writer.writeCharacters(ErrorMsg);
        writer.writeEndElement();
        writer.writeEndElement();
        writer.writeEndDocument();

        return writer.getXmlString();
    }

    // generate XML response
    private static String WriteXml(List<AIMSFileInfo> infos) {
        Xmlstreamwriter writer = new Xmlstreamwriter();

        writer.writeStartDocument(null, '1.0');
        writer.writeStartElement('', 'IDCards', 'http://www.w3.org/2001/XMLSchema-instance');

        for (AIMSFileInfo info : infos) {
            writer.writeStartElement(null, 'Card', null);

            writer.writeStartElement(null, 'Type', null);
            writer.writeCharacters(info.CardType);
            writer.writeEndElement();

            writer.writeStartElement(null, 'AIMSID', null);
            writer.writeCharacters((info.AIMSId == null ? '' : info.AIMSId)  );
            writer.writeEndElement();

            writer.writeStartElement(null, 'IATACode', null);
            writer.writeCharacters((info.IATACode == null ? '' : info.IATACode)  );
            writer.writeEndElement();

            writer.writeStartElement(null, 'UIRCode', null);
            writer.writeCharacters((info.UIRCode == null ? '' : info.UIRCode)  );
            writer.writeEndElement();

            writer.writeStartElement(null, 'VERNumber', null);
            writer.writeCharacters((info.VERNumber == null ? '' : info.VERNumber)  );
            writer.writeEndElement();

            writer.writeStartElement(null, 'FirstName', null);
            writer.writeCharacters(info.FirstName);
            writer.writeEndElement();

            writer.writeStartElement(null, 'Initials', null);
            writer.writeCharacters(info.Initials);
            writer.writeEndElement();

            writer.writeStartElement(null, 'Surname', null);
            writer.writeCharacters(info.LastName);
            writer.writeEndElement();

            writer.writeStartElement(null, 'NameOnIdCard', null);
            writer.writeCharacters((info.NameOnIDCard == null ? '' : info.NameOnIDCard)  );
            writer.writeEndElement();

            writer.writeStartElement(null, 'BirthDate', null);
            writer.writeCharacters(info.BirthDate);
            writer.writeEndElement();

            writer.writeStartElement(null, 'Sex', null);
            writer.writeCharacters(info.Gender);
            writer.writeEndElement();

            writer.writeStartElement(null, 'Title', null);
            writer.writeCharacters(info.Title);
            writer.writeEndElement();

            writer.writeStartElement(null, 'QualificationCode', null);
            writer.writeCharacters((info.QualificationCode == null ? '' : info.QualificationCode)  );
            writer.writeEndElement();

            writer.writeStartElement(null, 'PositionCode', null);
            writer.writeCharacters(info.PositionCode);
            writer.writeEndElement();

            writer.writeStartElement(null, 'PositionDescr', null);
            writer.writeCharacters(info.PositionDescription);
            writer.writeEndElement();

            writer.writeStartElement(null, 'DutiesCode', null);
            writer.writeCharacters(info.DutiesCode);
            writer.writeEndElement();

            writer.writeStartElement(null, 'DutiesDescr', null);
            writer.writeCharacters(info.DutiesDescription);
            writer.writeEndElement();

            writer.writeStartElement(null, 'HoursWorkedCode', null);
            writer.writeCharacters(info.HoursWorkedCode);
            writer.writeEndElement();

            writer.writeStartElement(null, 'HrsWorkedDescr', null);
            writer.writeCharacters(info.HoursWorkedDescription);
            writer.writeEndElement();

            writer.writeStartElement(null, 'Email', null);
            writer.writeCharacters(info.Email);
            writer.writeEndElement();

            writer.writeStartElement(null, 'YearEnterIndustry', null);
            writer.writeCharacters(info.YearEnteredIndustry);
            writer.writeEndElement();

            writer.writeStartElement(null, 'DtStartCompany', null);
            writer.writeCharacters(info.DateStartInCompany);
            writer.writeEndElement();

            writer.writeStartElement(null, 'CardCode', null);
            writer.writeCharacters((info.CardCode == null ? '' : info.CardCode));
            writer.writeEndElement();

            writer.writeStartElement(null, 'VariationCode', null);
            writer.writeCharacters((info.CardVariationCode == null ? '' : info.CardVariationCode));
            writer.writeEndElement();

            writer.writeStartElement(null, 'PhotoFlag', null);
            writer.writeCharacters((info.PhotoFlag == null ? '' : info.PhotoFlag));
            writer.writeEndElement();

            writer.writeStartElement(null, 'Solicitation', null);
            writer.writeCharacters((info.Solicitation == null ? '' : info.Solicitation));
            writer.writeEndElement();

            writer.writeStartElement(null, 'Duration', null);
            writer.writeCharacters(info.CardDuration);
            writer.writeEndElement();

            writer.writeStartElement(null, 'AreaCode', null);
            writer.writeCharacters((info.AreaCode == null ? '' : info.AreaCode));
            writer.writeEndElement();

            writer.writeStartElement(null, 'ErrorMsg', null);
            writer.writeCharacters(info.ErrorMsg);
            writer.writeEndElement();

            writer.writeStartElement(null, 'IsValid', null);
            writer.writeCharacters(String.ValueOf(info.IsValid));
            writer.writeEndElement();

            writer.writeStartElement(null, 'Expedite', null);
            writer.writeCharacters(info.Expedite);
            writer.writeEndElement();


            writer.writeStartElement(null, 'SFIDCardID', null);
            writer.writeCharacters((info.CardId == null ? '' : info.CardId));
            writer.writeEndElement();


            //@@@@
            writer.writeStartElement(null, 'ValidFrom', null);
            writer.writeCharacters((info.ValidFrom == null ? '' : info.ValidFrom));
            writer.writeEndElement();

            writer.writeStartElement(null, 'ValidTo', null);
            writer.writeCharacters((info.ValidTo == null ? '' : info.ValidTo));
            writer.writeEndElement();
            //@@@@




            writer.writeEndElement();
        }
        writer.writeEndElement();
        writer.writeEndDocument();

        return writer.getXmlString();
    }

    private with sharing class AIMSFileInfo {
        public string CardId { get; set; }
        public string CardType { get; set; }
        public string AIMSId { get; set; }
        public string IATACode { get; set; }
        public string UIRCode { get; set; }
        public string VERNumber { get; set; }
        public string FirstName { get; set; }
        public string Initials { get; set; }
        public string LastName { get; set; }
        public string NameOnIDCard { get; set; }
        public string BirthDate { get; set; }
        public string Gender { get; set; }
        public string Title { get; set; }
        public string QualificationCode { get; set; }
        public string PositionCode { get; set; }
        public string PositionDescription { get; set; }
        public string DutiesCode { get; set; }
        public string DutiesDescription { get; set; }
        public string HoursWorkedCode { get; set; }
        public string HoursWorkedDescription { get; set; }
        public string Email { get; set; }
        public string YearEnteredIndustry { get; set; }
        public string DateStartInCompany { get; set; }
        public string CardCode { get; set; }
        public string CardVariationCode { get; set; }
        public string PhotoFlag { get; set; }
        public string Expedite { get; set; }
        public string Solicitation { get; set; }
        public string CardDuration { get { return Label.IDCard_CardDuration; } set; }    // For now, hard coded to 12...
        public string AreaCode {get; set;}
        public string ErrorMsg {get; set;}

        public string ValidFrom {get; set;}
        public string ValidTo {get; set;}

        public boolean IsValid { get; set; }
    }





    global class IDCardLine {
        webservice String Tdcod;
        webservice String AgencyName;
        webservice String AgencyAddress1;
        webservice String AgencyAddress2;
        webservice String AgencyAddress3;
        webservice String City;
        webservice String Zip;
        webservice String EmployeeName;
        webservice String ServiceDate;
        webservice String OriginalServiceDate;
        webservice String ExpiryDate;
        webservice String Tcin;
        webservice String Simplex;
        webservice String EmployeeKey;
        webservice String AffiliationCode1;
        webservice String AffiliationCode2;
        webservice String AffiliationCode3;
        webservice String Country;
        webservice String CountryISO;
        webservice String RequestNumber;
        webservice String Track1;
        webservice String Track2;
        webservice String CardId;
        webservice String PhotoName;
        webservice String AgencyName3;
        webservice String State;
        webservice String Expedite;

        WebService Boolean isValid;
        WebService String strErrors;
        WebService Id idCardId; 

        public IDCardLine (ID_Card__c idCard, Account agency, String regionCode) {
            
            CheckDataValidity(idCard, agency);

            this.idCardId = IdCard.Id;

            if (this.isValid) {
                this.Tdcod = GetTdcod(idCard).toUpperCase();
                this.AgencyName = agency.Short_Name__c != null ? agency.Short_Name__c : (agency.TradeName__c != null ? agency.TradeName__c : ( agency.Legal_name__c != null ? agency.Legal_name__c : agency.Name));
                this.AgencyName = this.AgencyName.left(AGENCYNAMEMAXLENGTH).toUpperCase();
                /*
                this.AgencyAddress1 = GetNonNull( GetAgencyAddress1(agency.ShippingStreet != null ? agency.ShippingStreet : agency.BillingStreet) ).toUpperCase();
                this.AgencyAddress2 = GetNonNull( GetAgencyAddress2(agency.ShippingStreet != null ? agency.ShippingStreet : agency.BillingStreet) ).toUpperCase();
                this.AgencyAddress3 = GetNonNull( GetAgencyAddress3(agency.ShippingStreet != null ? agency.ShippingStreet : agency.BillingStreet) ).toUpperCase();
                */
                SetAgencyAddressLines( agency.ShippingStreet != null ? agency.ShippingStreet : agency.BillingStreet );

                String tmpCity = GetNonNull(agency.ShippingCity != null ? agency.ShippingCity : agency.BillingCity);
                this.City = (tmpCity.left(CITYMAXLENGTH) + ' ' + agency.IATA_ISO_Country__r.ISO_Code__c).toUpperCase();
                this.Zip = GetNonNull(agency.ShippingPostalCode != null ? agency.ShippingPostalCode : agency.BillingPostalCode).toUpperCase();
                this.EmployeeName = GetNonNull(idCard.Name_on_ID_Card__c).toUpperCase();
                this.ServiceDate = GetServiceDate(idCard);
                this.OriginalServiceDate = GetServiceDate(idCard);
                this.ExpiryDate = DateTime.newInstanceGmt(idCard.Valid_To_Date__c.year(), idCard.Valid_To_Date__c.month(), idCard.Valid_To_Date__c.day()).format('MM/yy', 'GMT');
                this.Tcin = idCard.CIN__c;//.rightPad(18);
                this.Simplex = idCard.VER_Number__c;
                this.EmployeeKey = idCard.Related_Contact__r.UIR__c;
                this.AffiliationCode1 = '';
                this.AffiliationCode2 = '';
                this.AffiliationCode3 = '';
                //this.Country = agency.IATA_ISO_Country__r.Name.toUpperCase().left(COUNTRYMAXLENGTH).rightPad(COUNTRYMAXLENGTH);
                String tmpCountry = agency.ShippingCountry != null ? agency.ShippingCountry : (agency.BillingCountry != null ? agency.BillingCountry : agency.IATA_ISO_Country__r.Name); 
                this.Country = tmpCountry.toUpperCase().left(COUNTRYMAXLENGTH).rightPad(COUNTRYMAXLENGTH);
                this.CountryISO = agency.IATA_ISO_Country__r.ISO_Code__c.toUpperCase();//idcard.Related_Contact__r.UIR__c.mid(0,2).toUpperCase();
                this.RequestNumber = GetRequestNumber(regionCode).toUpperCase();
                this.Track1 = GetTrack1(idCard).toUpperCase();
                this.Track2 = GetTrack2(idCard).toUpperCase();
                this.CardId = GetNonNull(idCard.Card_Code__c).toUpperCase();
                this.PhotoName = idCard.Photo__c;
                this.AgencyName3 = tmpCity.toUpperCase();
                this.State = GetNonNull(agency.ShippingState != null ? agency.ShippingState : agency.BillingState).toUpperCase();
                this.Expedite = idCard.Is_Expedite__c ? 'XPRS' : '';
            }
        }

        private String GetTdcod (ID_Card__c idCard) {
            return idCard.Agency_IATA_Code__c.mid(0,2) + '-' + idCard.Agency_IATA_Code__c.mid(2,1) + ' ' + idCard.Agency_IATA_Code__c.mid(3,4) + ' ' + idCard.Agency_IATA_Code__c.mid(7,1);
        }

        private String GetServiceDate(ID_Card__c idCard) {
            return GetMonthNumericValue(idCard.Start_Date_Agency_Month__c) + idCard.Start_Date_Agency_Year__c.trim().right(2) + '/' + idCard.Start_Date_Industry__c.trim().right(2);
        }

        private void SetAgencyAddressLines (String StreetAddress) {
            this.AgencyAddress1 = StreetAddress;
            this.AgencyAddress2 = '';
            this.AgencyAddress3 = '';

            if (StreetAddress.length() > ADDRESSLINEMAXLENGTH) {
                // Break the address line at space or \n characters in order to not break words

                String substring = StreetAddress.mid(0, ADDRESSLINEMAXLENGTH);
                Integer lastSpacePosition = substring.lastIndexOf('\n') > -1 ? substring.lastIndexOf('\n') : substring.lastIndexOf(' ');

                if (lastSpacePosition == -1) { // no space or new line -> get first 32 chars
                    this.AgencyAddress1 = substring.replace('\n','');
                    lastSpacePosition = substring.length();
                } else {
                    this.AgencyAddress1 = substring.substring(0, lastSpacePosition + 1).replace('\n','');
                    lastSpacePosition += 1;
                }

                if (StreetAddress.length() > lastSpacePosition) {

                    substring = StreetAddress.mid(lastSpacePosition, ADDRESSLINEMAXLENGTH);
                    lastSpacePosition = substring.lastIndexOf('\n') > 0 ? substring.lastIndexOf('\n') : substring.lastIndexOf(' ');

                    if (lastSpacePosition == -1 || substring.length() < ADDRESSLINEMAXLENGTH || StreetAddress.length() == lastSpacePosition + ADDRESSLINEMAXLENGTH) { // no space or new line -> get first 32 chars
                        this.AgencyAddress2 = substring.replace('\n','');
                        lastSpacePosition = this.AgencyAddress1.length() + substring.length();
                    } else {
                        this.AgencyAddress2 = substring.substring(0, lastSpacePosition + 1).replace('\n','');
                        lastSpacePosition = this.AgencyAddress1.length() + lastSpacePosition + 1;
                    }
                }


                if (StreetAddress.length() > lastSpacePosition) {

                    substring = StreetAddress.mid(lastSpacePosition, ADDRESSLINEMAXLENGTH);
                    lastSpacePosition = substring.lastIndexOf('\n') > 0 ? substring.lastIndexOf('\n') : substring.lastIndexOf(' ');

                    if (lastSpacePosition == -1 || substring.length() < ADDRESSLINEMAXLENGTH || StreetAddress.length() == lastSpacePosition + ADDRESSLINEMAXLENGTH) { // no space or new line -> get first 32 chars
                        this.AgencyAddress3 = substring.replace('\n','');
                    } else {
                        this.AgencyAddress3 = substring.substring(0, lastSpacePosition + 1).replace('\n','');
                    }

                }
            }

        }
        /*
        private String GetAgencyAddress1 (String StreetAddress) {
            return StreetAddress.left(32);
        }

        private String GetAgencyAddress2 (String StreetAddress) {
            if (StreetAddress.length() > 32) {
                return StreetAddress.substring(32).left(32);
            } else {
                return null;
            }
        }

        private String GetAgencyAddress3 (String StreetAddress) {
            if (StreetAddress.length() > 64) {
                return StreetAddress.substring(64).left(32);
            } else {
                return null;
            }
        }
        */
        private String GetRequestNumber(String regionCode) {
            // XXmmdd1N 
            return regionCode + Datetime.now().format('MMdd', 'GMT') + '1N';
        }

        private String GetTrack1(ID_Card__c idCard) {
            // 1 to 25: Agency Name
            // 27 to 51: Cardholder Name
            // 53 to 56: MonthYear of start of current employment
            // 57 to 74: TCIN

            //String retStr = idCard.Agency_Name__c.length() > 25 ? idCard.Agency_Name__c.left(25) : idCard.Agency_Name__c.rightPad(25);
            String retStr = this.AgencyName.length() > 25 ? this.AgencyName.left(25) : this.AgencyName.rightPad(25);
            retStr += '^';
            retStr += idCard.Name_on_ID_Card__c.length() > 25 ? idCard.Name_on_ID_Card__c.left(25) : idCard.Name_on_ID_Card__c.rightPad(25);
            retStr += '^';
            retStr += GetMonthNumericValue(idCard.Start_Date_Agency_Month__c) + idCard.Start_Date_Agency_Year__c.trim().right(2);
            retStr += idCard.CIN__c;

            return retStr;
        }

        private String GetTrack2(ID_Card__c idCard) {
            // 1 to 14: IATA Code
            // 16 to 19: Expiry Date in mmyy
            // 20 to 29: 10-digit VER#

            String retStr = idCard.Agency_IATA_Code__c.leftPad(14).replace(' ','0');
            retStr += '=';
            retStr += DateTime.newInstanceGmt(idCard.Valid_To_Date__c.year(), idCard.Valid_To_Date__c.month(), idCard.Valid_To_Date__c.day()).format('MMyy', 'GMT');
            retStr += idCard.VER_Number__c;

            return retStr;
        }

        private void CheckDataValidity(ID_Card__c idCard, Account agency) {
            String errStr = '';
            Boolean isComplete = true;

            if (idCard.Agency_IATA_Code__c == null || idCard.Agency_IATA_Code__c.length() < 8) {
                errStr += 'Agency IATA Code is null or less than 8 characters. ';
                isComplete = false;
            }

            if (idCard.Start_Date_Agency_Month__c == null) {
                errStr += 'Start Date Agency Month is null. ';
                isComplete = false;
            }

            if (idCard.Start_Date_Agency_Year__c == null) {
                errStr += 'Start Date Agency Year is null. ';
                isComplete = false;
            }

            if (idCard.Start_Date_Industry__c == null) {
                errStr += 'Start Date Industry Year is null. ';
                isComplete = false;
            }

            if (idCard.Agency_Name__c == null) {
                errStr += 'Agency Name is null. ';
                isComplete = false;
            }

            if (idCard.Name_on_ID_Card__c == null) {
                errStr += 'Name on ID Card is null. ';
                isComplete = false;
            }

            if (idCard.CIN__c == null) {
                errStr += 'CIN is null. ';
                isComplete = false;
            }

            if (idCard.Valid_To_Date__c == null) {
                errStr += 'Valid To Date is null. ';
                isComplete = false;
            }

            if (idCard.VER_Number__c == null) {
                errStr += 'VER Number is null. ';
                isComplete = false;
            }

            if (agency == null) {
                errStr += 'No related account on the related Contact. ';
                isComplete = false;
            }

            if (agency.IATA_ISO_Country__c == null) {
                errStr += 'ISO Country on the related account is null. ';
                isComplete = false;
            }

            if (agency.IATA_ISO_Country__c != null && agency.IATA_ISO_Country__r.Name == null) {
                errStr += 'ISO Country Name on the related account is null. ';
                isComplete = false;
            }

            if (agency.ShippingStreet == null && agency.BillingStreet == null) {
                errStr += 'The Shipping and Billing Street on the related account are null. ';
                isComplete = false;
            }

            if (idCard.Related_Contact__c == null) {
                errStr += 'Related Contact is null. ';
                isComplete = false;
            }

            if (idCard.Related_Contact__c != null && idCard.Related_Contact__r.UIR__c == null) {
                errStr += 'The UIR on the Related Contact is null. ';
                isComplete = false;
            }


            if (idCard.Related_Contact__c != null && idCard.Related_Contact__r.UIR__c != null && !idCard.Photo__c.startsWith(idCard.Related_Contact__r.UIR__c)) {
                errStr += 'The Photo file name format is invalid. ';
                isComplete = false;
            }
            
            this.strErrors = errStr;
            this.isValid = isComplete;
        }
    }

    private static String GetNonNull(String inputStr) {
        return inputStr == null ? '' : inputStr;
    }

    private static void LogMissingDataErrors (list<IDCardLine> idCardLines) {
        list<ID_Card__c> lstIdCardsToUpdate = new list<ID_Card__c>();

        for (IDCardLine idCLine : idCardLines) {
            ID_Card__c idCard = new ID_Card__c(Id = idCLine.idCardId, Missing_Information__c = idCLine.strErrors, Card_Status__c = STATUSMISSINGINFO);
            lstIdCardsToUpdate.add(idCard);
        }
        system.debug('lstIdCardsToUpdate: ' + lstIdCardsToUpdate);
        update(lstIdCardsToUpdate);
    }

    WebService static list<IDCardLine> GetIdCardPrintInfo(String regionCode) {
        List<IDCardLine> IdCards = new List<IDCardLine>();
        List<IDCardLine> IncompleteIdCards = new List<IDCardLine>();

        ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

        // Get the list of cards that must be sent for printing
        // Non 'US' only - requested by Inigo on Nov 4th, 2016 as extra precaution
        List<ID_Card__c> cardsToPrint = [SELECT Valid_To_Date__c, Photo__c, ID, Is_Expedite__c, Related_Contact__c, VER_Number__c, Start_Date_Industry__c, Start_Date_Agency_Year__c, Name_on_ID_Card__c, Card_Code__c, Agency_IATA_Code__c, Start_Date_Agency_Month__c, Agency_Name__c, Related_Contact__r.UIR__c, CIN__c, Related_Contact__r.AccountId FROM ID_Card__c WHERE  Sent_to_AIMS_on__c = null AND MustSyncWithAIMS__c = true AND RecordTypeId = : rectypeid AND Related_Contact__r.Account.IATA_ISO_Country__r.ISO_Code__c <> 'US' AND Card_Status__c <> :CSCANCELED ORDER BY Card_Status__c DESC];

        if (!cardsToPrint.isEmpty()) {

            set<Id> setRelatedAccountIds = new set<Id>();
            for (ID_Card__c idCard : cardsToPrint) {
                setRelatedAccountIds.add(idCard.Related_Contact__r.AccountId);
            }

            map<Id, Account> mapRelatedAccountsPerId = new map<Id, Account>([SELECT Id, Name, Short_Name__c, TradeName__c, Legal_name__c, IATACode__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, BillingStreet, BillingPostalCode, BillingState, BillingCity, BillingCountry, ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, ShippingCountry FROM Account WHERE Id IN :setRelatedAccountIds]);
            

            for (ID_Card__c idCard : cardsToPrint) {
                IDCardLine idCardLn = new IDCardLine(idCard, mapRelatedAccountsPerId.get(idCard.Related_Contact__r.AccountId), regionCode);
                    
                if (idCardLn.isValid) {
                    IdCards.add(idCardLn);
                } else {
                    IncompleteIdCards.add(idCardLn);
                }                
            }
        }

        if (!IncompleteIdCards.isEmpty()) {
            LogMissingDataErrors(IncompleteIdCards);
        }
        
        return IdCards;
    }

    WebService static WSResponse LogMissingPhotoErrors(List<string> idCards) {
        WSResponse resp = new WSResponse();
        
        try {
            List<ID_Card__c> cards = [SELECT Id, Card_Status__c FROM ID_Card__c WHERE Id IN : idCards  ]; //and MustSyncWithAIMS__c = true

            if (cards != null && !cards.isEmpty()) {
                for (ID_Card__c aCard : cards) {
                    aCard.Card_Status__c = STATUSNOPHOTO;
                }

                update cards;

                resp.Status = SFUPDATEOK;
            }
        } catch (Exception e) {
            resp.Status = SFUPDATEFAILED;
            resp.Message = e.getMessage();
        }
        
        return resp;
    }

    Webservice static WSResponse UpdatePrintedIdCard(string pUIR) {
        // Expected input example: '02-3 3362 3FLIGHT CENTRE TRAVEL                                            BRISBA                          LEVEL 3, 545 QUEEN STREET                                                                       BRISBANE                      4000      GRAHAM TURNER       0381/730381/7311/17  TUR49G062651MI1AU 5036000661     AU000661            AUSTRALIA                 AUWW11281N                                                                                                   '

        // extract the UIR from the input line
        String strUIR = pUIR.mid(317,8);

        List<ID_Card__c> relCards = [SELECT Received_From_AIMS__c, Id, Card_Status__c, ID_Card_Application__c FROM ID_Card__c WHERE Related_Contact__r.UIR__c = :strUIR AND Received_From_AIMS__c = null AND Sent_to_AIMS_on__c <> null ORDER BY Sent_to_AIMS_on__c DESC LIMIT 1];

        if (relCards != null && !relCards.IsEmpty()) {
            try {
                for (ID_Card__c aCard : relCards) {

                    // INC184819
                    //aCard.Valid_From_Date__c = date.valueOf(pValidFromDate);
                    //Date firstDayOfMonth = date.valueOf(pValidToDate).toStartOfMonth();
                    //Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                    //aCard.Valid_To_Date__c = lastDayOfMonth;
                    aCard.Card_Status__c = CSVALID;
                    aCard.Received_From_AIMS__c = Datetime.now();

                    List<Case> c = [SELECT Id, Status FROM Case c WHERE c.Related_ID_Card_Application__c = : aCard.ID_Card_Application__c AND c.RecordType.Name = 'ID Card Application'];
                    if (c != null && !c.IsEmpty()) {
                        c[0].Status = 'Closed';
                        update c[0];
                    }
                }
                update relCards;

            } catch (Exception e) {
                WSResponse resp = new WSResponse();
                resp.Status = SFUPDATEFAILED;
                resp.Message = e.getMessage();
                resp.RecordId = relCards[0] != null ? relCards[0].Id : strUIR;

                return resp;
            }
        } else {
            WSResponse resp = new WSResponse();
            resp.Status = SFUPDATEFAILED;
            resp.Message = 'No ID card';
            resp.RecordId = strUIR;

            return resp;
        }
        
        WSResponse resp = new WSResponse();
        resp.Status = SFUPDATEOK;
        resp.Message = '';
        resp.RecordId = relCards[0].Id;

        return resp;
    }


    Webservice static WSResponse UpdateRejectedIdCards(list<string> pUIR) {
        // Expected input example: ZW067439201611210118 (UIR + Date + Error code)

        // extract UIR from received messages
        map<string,string> mapErrorMsgsPerUIR = new map<string, string>();
        for (string sUIR : pUIR) {
            mapErrorMsgsPerUIR.put(sUIR.left(8), sUIR);
        }

        List<ID_Card__c> relCards = [SELECT Received_From_AIMS__c, Id, Card_Status__c, Missing_Information__c, ID_Card_Application__c, Related_Contact__r.UIR__c FROM ID_Card__c WHERE Related_Contact__r.UIR__c IN :mapErrorMsgsPerUIR.keyset() AND Received_From_AIMS__c = null AND Sent_to_AIMS_on__c <> null ORDER BY Sent_to_AIMS_on__c DESC];

        if (relCards != null && !relCards.IsEmpty()) {
            try {
                for (ID_Card__c aCard : relCards) {
                    aCard.Card_Status__c = STATUSREJECTED;
                    aCard.Received_From_AIMS__c = Datetime.now();
                    aCard.Missing_Information__c = 'G&D error message: ' + mapErrorMsgsPerUIR.get(aCard.Related_Contact__r.UIR__c);
                }
                update relCards;

            } catch (Exception e) {
                WSResponse resp = new WSResponse();
                resp.Status = SFUPDATEFAILED;
                resp.Message = e.getMessage();

                return resp;
            }
        } else {
            WSResponse resp = new WSResponse();
            resp.Status = SFUPDATEFAILED;
            resp.Message = 'No ID cards found';

            return resp;
        }
        
        WSResponse resp = new WSResponse();
        resp.Status = SFUPDATEOK;
        resp.Message = '';

        return resp;
    }


    Webservice static WSResponse LogSystemError(string message, string targetSystem, string inputData, string extraInfo) {
        WSResponse resp = new WSResponse();

        try {
            IEC_Error_Log__c errLog = new IEC_Error_Log__c();
            errLog.Source__c = ERRORSOURCEJAVATOOL;
            errLog.Displayed_Message__c = message;
            errLog.Errror_Message__c = targetSystem;
            errLog.Extra_Information__c = extraInfo;
            errLog.Data__c = inputData;
            errLog.Type__c = 'Error';

            insert errLog;

            resp.Status = SFUPDATEOK;
            resp.Message = '';
            resp.RecordId = '';
        } catch (Exception e) {
            resp.Status = SFUPDATEFAILED;
            resp.Message = e.getMessage();
            resp.RecordId = '';
        }

        return resp;
    }


    global class WSResponse {
        Webservice String Status; 
        Webservice String Message;
        Webservice String RecordId;
    }

}