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

    private static final string SFUPDATEFAILED = 'FAILED';
    private static final string SFUPDATEOK = 'OK';

    private static final string CONTACTCHANGE = 'CONTACT_CHANGE';

    private static map<String, String> ISOCountry_AIMSArea;

    WebService static string ExtractIdCardInfo() {
        List<AIMSFileInfo> infos = new List<AIMSFileInfo>();

        ID rectypeid = Schema.SObjectType.ID_Card__c.getRecordTypeInfosByName().get('AIMS').getRecordTypeId();

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
            for (IATA_ISO_Country__c country : [Select i.AIMS_Area_Name__c, i.AIMS_Area_ID__c From IATA_ISO_Country__c i ]) {
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
                    aCard.Card_Status__c = CSPRINTEDDELIVERED;
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
        if (aCard.Card_Status__c == 'Cancelled')
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
}