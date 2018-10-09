public with sharing class IDCard_ApplicationFormNRController  extends IDCardAbstractController  {

  // public Boolean DisplayExpediteFee {get; set;}
  public Boolean DisplayFees {get; set;}
  public Boolean CanRenderPage {get; set;}
  public Boolean HasNotUploadedImage {get; set;}
  public String PhotoFilename {get; set;}
  public String hiddenFilename {get; set;} 
  public Boolean TermsAndConditionChecked { get; set; }
  public String apiSessionId {get; set;}
  public Boolean IsCroppingToolDisplayed { get; set; }
  public Boolean IsViewerDisplayed { get; set; }
  public Boolean DocUploaded {get; set;}
  public decimal expediteFees {get; private set;}

  public Boolean IsExpediteDelivery;
  private String accountType;
  private Boolean newContactRequired;
  private String part;
  private final String sectionOne = '1';
  private final String sectionTwo = '2';
  private final String sectionThree = '3';

  public Boolean isPart1 { get; set; }
  public Boolean isAttachmentsNeeded { get; set; }
  public Boolean isPart2 { get; set; }
  public Boolean isPart3 { get; set; }
  public Boolean lastNameHasChanged {get; set;}
  public Boolean isContractor {get; set;}
  public Boolean isEmployee {get; set;}
  public list<SelectOption> itdiCourses;
  public String[] selectedITDICourses;

  private String IATA_Code;
  private Account theAccount;

  public String geographyinTravelPlanning_Description {get; set;}
  public String destinationGeography_Description {get; set;}
  public String servingtheTravelTourismCustomer_Description {get; set;}
  public String introductiontoBSPLink_Description {get; set;}
  public String leserviceauclientvoyageur_Description {get; set;}
  public String sellingInternationalRailTransportation_Description {get; set;}
  public String introduccionAlBSPlink_Description {get; set;}
  public String introduccionAlSistemaBSPyLenguajeBSP_Description {get; set;}
  public String losInformesyLosProcedimientosDeFacturacionAgenteBSP_Description {get; set;}
  public String socialMediaForTheTravelIndustry_Description {get; set;}
 
  public String fundamentalsJourneyPricing_Description {get; set;}
  public String repricingExchangeReissue_Description {get; set;}
  public String travelAgencyFees_Description {get; set;}

  //RN-INC419676
  public String assisttravelersspecialneeds_Description {get; set;}
  public String notionsessentlentarifetbillet_Description {get; set;}
  public String advskillsjourneypriceticket_Description {get; set;}
  public String servingthetravelcustomer_Description {get; set;}
  public String socialmediafortravelindustry_Description {get; set;}
  public String accfinmgmtforagencies_Description {get; set;}

  private ID_Card__c[] idCardTemp;
  private Contact associatedContact {get; set;}
  private ID_Card__c associatedIDCard {get; set;}
  private Map<String, decimal> detailledFees;

  public ID_Card_Application__c IDCardApplicationNR {get; set;}

  private List<Attachment> docs;

  public String attachmentID {get; set;}


  /** 
   * Constructor
   */
  public IDCard_ApplicationFormNRController() {

 

    DocUploaded = false;
    IsCroppingToolDisplayed = false;
    IsViewerDisplayed = false;
    lastNameHasChanged = false;
    IsExpediteDelivery = false;
    isContractor = false;
    isEmployee = false;
    detailledFees = new Map<String, decimal>();
    selectedITDICourses = new String[] {}; 

    geographyinTravelPlanning_Description = Label.IDCard_GeographyinTravelPlanning_Description;
    destinationGeography_Description = Label.IDCard_DestinationGeography_Description;
    servingtheTravelTourismCustomer_Description = Label.IDCard_ServingtheTravelTourismCustomer_Description;
    introductiontoBSPLink_Description = Label.IDCard_IntroductiontoBSPLink_Description;
    leserviceauclientvoyageur_Description = Label.IDCard_Leserviceauclientvoyageur_Description;
    sellingInternationalRailTransportation_Description = Label.IDCard_SellingInternationalRailTransportation_Description;
    introduccionAlBSPlink_Description = Label.IDCard_IntroduccionAlBSPlink_Description;
    introduccionAlSistemaBSPyLenguajeBSP_Description = Label.IDCard_IntroduccionAlSistemaBSPyLenguajeBSP_Description;
    losInformesyLosProcedimientosDeFacturacionAgenteBSP_Description = Label.IDCard_LosInformesyLosProcedimientosDeFacturacionAgenteBSP_Description;
    socialMediaForTheTravelIndustry_Description = Label.IDCard_SocialMediaForTheTravelIndustry_Description; 

    fundamentalsJourneyPricing_Description = Label.IDCard_FundamentalsJourneyPricing_Description;
    repricingExchangeReissue_Description = Label.IDCard_RepricingExchangeReissue_Description;
    travelAgencyFees_Description = Label.IDCard_Travel_Agency_Fees_Description;

    //RN-INC419676
    assisttravelersspecialneeds_Description = Label.Assist_Travelers_Special_Needs_Description; 
    notionsessentlentarifetbillet_Description = Label.Notions_Essentl_Tarif_Billet_Description;
    advskillsjourneypriceticket_Description = Label.Adv_Skills_Journey_Price_Ticket_Description;
    servingthetravelcustomer_Description = Label.Serving_The_Travel_Customer_Description;
    socialmediafortravelindustry_Description = Label.Social_Media_Travel_Industry_Description;
    accfinmgmtforagencies_Description = Label.Acc_Fin_Mgmt_Agencies_Description;

    initialize();

    //knows what part of page to load
    part = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PAGE_PART));

    try {

      //get application ID from URL parm
      String applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));

      //get application info from DB
      IDCardApplicationNR = [Select i.Payment_Amount__c, i.RecordTypeId, i.VER_Number__c, i.UIR__c, i.Revenue_Confirmation__c, i.Type_of_application__c, i.Title__c, i.Telephone__c, i.SystemModstamp,
                             i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c, i.Promotion_Code__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c,
                             i.Package_of_Travel_Professionals_Course_2__c, i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c, i.Last_Name__c, i.LastModifiedDate,
                             i.LastModifiedById, i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c, i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c,
                             i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c, i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c,
                             i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Email_admin__c, i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c,
                             i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.ConnectionSentId, i.ConnectionReceivedId, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c,
                             i.Applicable_Fee__c, i.Regional_Office__c, i.AgencyShare_Confirmation__c  From ID_Card_Application__c i
                             where i.Id = :applicationId limit 1];
      //Block Page if payment is done and case is created
      Case[] tempCase = [ Select id from Case where Related_ID_Card_Application__c = : IDCardApplicationNR.Id ] ;
      if (tempCase.size() > 0 ) {
        part = '';
        AddError(Label.IDCard_NoModificationAllowed);
      }



      isContractor = (IDCardApplicationNR.Position_in_Current_Agency__c == 'Independent Consultant/Broker');
      isEmployee = !isContractor && IDCardApplicationNR.Position_in_Current_Agency__c != 'Sole Owner' && IDCardApplicationNR.Position_in_Current_Agency__c != 'Shareholder'
                   && IDCardApplicationNR.Position_in_Current_Agency__c != 'Partner';

      if (!IsNewApplication) {
        associatedIDCard = GetAssociatedIDCard(IDCardApplicationNR.VER_Number__c);
        lastNameHasChanged = (associatedIDCard.LastName__c != IDCardApplicationNR.Last_Name__c);
      }

      if (part == sectionOne) {
        isPart1 = true;

        IDCardApplicationNR.IATA_Code__c = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
        IDCardApplicationNR.Type_of_application__c = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPLICATIONTYPE));
        IDCardApplicationNR.Regional_Office__c = (GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c)).IATA_Regional_Office__c;
        if (!IsNewApplication) {
          IDCardApplicationNR.VER_Number__c = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_VER));
          FillContactFieldsForReplacement();

        } else {
          // Validate if Card UI displayed name doesn't match with the business rule displayed name
          if (IDCardApplicationNR.First_Name__c != '' && IDCardApplicationNR.Last_Name__c != '' && IDCardApplicationNR.Displayed_Name__c != '') {
            if (IDCardApplicationNR.Displayed_Name__c != IDCardUtil.calculateDisplayedName(IDCardApplicationNR.First_Name__c, IDCardApplicationNR.Middle_Initial__c, IDCardApplicationNR.Last_Name__c)) {
              //force Displayed name to correct value
              IDCardApplicationNR.Displayed_Name__c = IDCardUtil.calculateDisplayedName(IDCardApplicationNR.First_Name__c, IDCardApplicationNR.Middle_Initial__c, IDCardApplicationNR.Last_Name__c);
            }
          }
        }
      }

      //Not the first page of the form. Other parts get previous data from DB
      else {

        if (part == sectionTwo) { // image upload
          //get image name
          if (!IsNewApplication) {
            associatedContact = GetAssociatedContact(IDCardApplicationNR.VER_Number__c);
            System.debug('** associatedContact' + associatedContact);

            //idCardTemp = [Select i.Photo__c,i.ID_Card_Application__r.Displayed_Name__c From ID_Card__c i where i.Related_Contact__c = :associatedContact.Id AND (Card_Status__c =: IDCardUtil.CARDSTATUS_PRINTED_DELIVERED or Card_Status__c =: IDCardUtil.CARDSTATUS_CANCELED) order by i.CreatedDate desc];

            // Kofi: 12/09/2013. Card_Status__c is removed from the criteria.

            idCardTemp = [Select i.Photo__c, i.ID_Card_Application__r.Displayed_Name__c From ID_Card__c i where i.Related_Contact__c = :associatedContact.Id order by i.Valid_To_Date__c desc];
            //System.debug('** idCardTemp'+idCardTemp);
            if (idCardTemp.size() > 0) {
              //PhotoFilename = idCardTemp[0].Photo__c; 14-12-2016
              PhotoFilename = IDCardUtil.NewGuid();
              hiddenFilename = idCardTemp[0].Photo__c;
              if (!IsCroppingToolDisplayed) { IsViewerDisplayed = true; }
            } else {
              PhotoFilename = IDCardUtil.NewGuid();
              IsCroppingToolDisplayed = true;
              IsViewerDisplayed = false;

            }

          } else {
            if (IDCardApplicationNR.Photo__c != null) {
              //PhotoFilename = IDCardApplicationNR.Photo__c;
              PhotoFilename = IDCardUtil.NewGuid();
              hiddenFilename = IDCardApplicationNR.Photo__c;
              IsCroppingToolDisplayed = false;
              IsViewerDisplayed = true;
            } else {
              PhotoFilename = IDCardUtil.NewGuid();
              IsViewerDisplayed = false;
              IsCroppingToolDisplayed = true;
            }

          }

          isPart2 = true;
        }
        if (part == sectionThree) { // payment and confirmation
          isPart3 = true;

          // if back button is pressed: set UI checkboxes to selected ITDI courses
          if (IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c  != null)
            selectedITDICourses.add(IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c );
          if (IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c  != null)
            selectedITDICourses.add(IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c);


          CalculateApplicationFee();
        }
        if (part == 'attach') { //attachments

          Attachment[] a = [Select a.ParentId, a.Name From Attachment a where a.ParentId = :IDCardApplicationNR.Id];
          if (a.size() > 0) {
            DocUploaded = true;
          }

          isAttachmentsNeeded = true;

        }

      }

      //???
      //DisplayExpediteFee = true;
      DisplayFees = true;
      newContactRequired = false;
      CanRenderPage = true;

    } catch (Exception ex) {
      system.debug('Error : ' + ex.getStackTraceString  ());
      AddError(ex.getMessage());
      CanRenderPage = false;
    }
  }


  public Boolean IsContactFromCanada {
    get {
      if (GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c).ISO_Code__c == 'CA')
        return true;
      return false;

    }
  }

  public Boolean IsExpediteAvailable {
    get {

      IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c);
      Price_Table__c[] listPriceTables = [Select p.ID_Card_Fee__c, p.Expedite__c, p.IATA_Package__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
      if (listPriceTables == null || listPriceTables.size() == 0) {
        throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
      } else
      {
        if (listPriceTables[0].Expedite__c != null )         
          return true;
        return false;
      }
    }
  }
  public Boolean IsExpediteDeliveryAddedtoIDCardPrice {
    get {


      IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c);
      Price_Table__c[] listPriceTables = [Select p.ID_Card_Fee__c, p.Expedite__c, p.IATA_Package__c, p.Expedite_Delivery_added_to_IDCard_Price__c From Price_Table__c p
      where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
      if (listPriceTables == null || listPriceTables.size() == 0) {
        throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
      }else  if(listPriceTables[0].Expedite_Delivery_added_to_IDCard_Price__c == true){
          IsExpediteDelivery = true;
      }
        return listPriceTables[0].Expedite_Delivery_added_to_IDCard_Price__c;
    }
  }


  public Boolean RevenueConfirmationDisabled {
    get {
      if (GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c).ISO_Code__c == 'CA') {
        if (IsNewApplication) {
          return false;
        }
        if (IDCardApplicationNR.Position_in_Current_Agency__c == 'Director' ||
            IDCardApplicationNR.Position_in_Current_Agency__c == 'Employee' ||
            IDCardApplicationNR.Position_in_Current_Agency__c == 'Manager' ) {

          return false;

        }
      }
      return true;
    }
  }

  public String TermsAndConditions {
    get{
      if (GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c).ISO_Code__c == 'CA') {
        return Label.ID_Card_Terms_ConditionCA;
      } else{
        return Label.ID_Card_Terms_Condition;
      }
    }
  }

  public String AttachmentsNeeded {
    get{
      if (isEmployee && LastNameHasChanged)
        return Label.IDCard_LastNameVerification + '<br/>' + Label.IDCard_Employee + '<br/>' + Label.IDCard_UploadDocs + '<br/><br/>';

      if (LastNameHasChanged && isContractor)
        return Label.IDCard_LastNameVerification + '<br/>' + Label.IDCard_ContractorVerification + '<br/>' + Label.IDCard_UploadDocs + '<br/><br/>';

      if (LastNameHasChanged)
        return Label.IDCard_LastNameVerification + '<br/>' + Label.IDCard_UploadDocs + '<br/><br/>';
      if (isContractor)
        return Label.IDCard_ContractorVerification + '<br/>' + Label.IDCard_UploadDocs + '<br/><br/>';

      if (isEmployee )
        return Label.IDCard_Employee + '<br/>' + Label.IDCard_UploadDocs + '<br/><br/>';


      return '';
    }
    set;
  }

  public String PageTitle {
    get{
      //Page Title
      if (IDCardApplicationNR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW)
        return Label.ID_Card_Application_Type_New;
      if (IDCardApplicationNR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
        return Label.ID_Card_Application_Type_Replacement;
      /*
      if(IDCardApplicationNR.Type_of_application__c ==IDCardUtil.APPLICATIONTYPE_RENEWAL)
           return Label.ID_Card_Application_Type_Renewal;
      if(IDCardApplicationNR.Type_of_application__c ==IDCardUtil.APPLICATIONTYPE_REISSUE)
           return Label.ID_Card_Application_Type_Reissue;
      */
      return '';

    }
    set;
  }


  public String[] getSelectedITDICourses() {
    return selectedITDICourses;
  }

  public void setSelectedITDICourses(String[] selectedITDICourses) {
    this.selectedITDICourses = selectedITDICourses;
  }

  public List<SelectOption> getItdiCourses() {
    itdiCourses = new list<SelectOption>();

    Schema.DescribeFieldResult fieldResult = ID_Card_Application__c.Package_of_Travel_Professionals_Course_2__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    String question_image = getResourceURL('question_image');
    for ( Schema.PicklistEntry f : ple) {
      string a_Id = (f.getValue().replace(' ', '')).replace('&', '');
      SelectOption s = new SelectOption(f.getValue(), f.getLabel() + ' <a href="#" id="' + a_Id + '"><img src="' + Label.IDCard_SiteName + question_image + '" width="20" height="20" style="vertical-align: top;"></a>');
      s.setEscapeItem(false);
      itdiCourses.add(s);
    }
    return itdiCourses;
  }




  public Boolean IsNewApplication {
    get{
      return IDCardApplicationNR != null && IDCardApplicationNR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW;
    }
    set;
  }

  private void AddError(string msg) {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
  }

  public void ShowHideIFrames() {
    if (IsViewerDisplayed) {
      IsViewerDisplayed = false;
      IsCroppingToolDisplayed = true;
    }
  }


  private Contact GetAssociatedContact(string VER) {

    // check the VER number (if associated to a contact)
    Contact[] contacts = [Select c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c,
                          c.Solicitation_Flag__c From Contact c where c.VER_Number__c = : Decimal.valueof(VER) limit 1];
    if (contacts == null || contacts.size() == 0) {
      throw new IDCardApplicationException(string.format(Label.ID_Card_Contact_Not_found_for_VER, new string[] { VER }));
    }

    return contacts[0];
  }

  private ID_Card__c GetAssociatedIDCard(string VER) {

    ID_Card__c[] card = [ Select i.Valid_To_Date__c, i.Valid_From_Date__c, i.Type_of_ID_Card__c, i.Title__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c,
                          i.Sent_to_AIMS_on__c, i.Renewal_From_Replace__c, i.Related_Contact__c, i.Position__c, i.Photo__c, i.Photo_Flag__c, i.Phone__c, i.Payment_Type__c, i.Paid__c, i.OwnerId, i.Nature_of_ID_Card__c,
                          i.Name_on_ID_Card__c, i.Name, i.MustSyncWithAIMS__c, i.Middle_Initial__c, i.LastName__c, i.LastModifiedDate, i.LastModifiedById, i.Is_Active_Card__c, i.IsDeleted, i.Id,
                          i.ID_Card_Application__c, i.Hours_per_week__c, i.Gender__c, i.FirstName__c, i.Fee_Applicable__c, i.Email__c, i.Duties__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate,
                          i.CreatedById, i.ConnectionSentId, i.ConnectionReceivedId, i.Card_Variation__c, i.Card_Variation_Code__c, i.Card_Status__c, i.Card_Code__c,
                          i.Cancellation_Date__c, i.Blacklisted__c, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Agency_Name__c, i.Agency_IATA_Code__c From ID_Card__c i
                          where i.VER_Number__c = : VER  ORDER BY i.Valid_To_Date__c DESC limit 1];

    if (card == null || card.size() == 0) {
      return null;
    }

    return card[0];
  }


  /**
   * Calculates and display the Applicable fee
   */
  public void CalculateApplicationFee() {

    try {


      Promotion__c validPromotion = null;
      Account theAccount = [Select a.ID_Card_Key_Account_Discount__c, a.IATACode__c, a.type, a.BillingCountry From Account a where a.RecordType.Name = 'Agency' AND a.IATACode__c = : IDCardApplicationNR.IATA_Code__c limit 1];
      if (theAccount == null)
        throw new IDCardApplicationException(string.format(Label.ID_Card_Account_Not_Found, new String[] {IDCardApplicationNR.IATA_Code__c}));

      // Map the account agent type to the Price Table agent type
      accountType = IDCardUtil.GetAgentTypeFromAccountType(theAccount.type);

      // get the Price Table based on the country and on the type of agent
      IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c);
      Price_Table__c[] listPriceTables = [Select p.ID_Card_Fee__c,  p.IATA_Package__c, p.Type_Class_of_Agent__c, p.Expedite__c, p.CurrencyIsoCode, p.Name From Price_Table__c p
                                          where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
      if (listPriceTables == null || listPriceTables.size() == 0) {
        throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
      }

      validPromotion = validatePromotion();

      ////////////////////////////////
      // calculate the applicable fee

      Boolean isReissue = (IDCardApplicationNR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE);
      Boolean isExpedite = IDCardApplicationNR.IDCard_Expedite_Delivery__c;

      //Get the ITDI Courses Selection
      IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c = null;
      IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c = null;
      if (selectedITDICourses != null) {
        if (selectedITDICourses.size() == 1)
          IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c = selectedITDICourses[0];
        if (selectedITDICourses.size() >= 2) {
          IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c = selectedITDICourses[0];
          IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c = selectedITDICourses[1];
        }

      }


      Boolean isITDIPackage = selectedITDICourses.size() > 0 ; //IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c != null || IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c != null;
      detailledFees = IDCardUtil.GetDetailledFees(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);
      IDCardApplicationNR.ID_Card_Fee__c = detailledFees.get('IDCardFee');
      IDCardApplicationNR.IDCard_Expedite_Delivery_Fee__c = detailledFees.get('ExpediteFee');
      IDCardApplicationNR.ITDI_Courses_Fee__c = detailledFees.get('ITDIFee');
      IDCardApplicationNR.Applicable_Fee__c = IDCardUtil.GetApplicableFee(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);
      IDCardApplicationNR.CurrencyIsoCode = listPriceTables[0].CurrencyIsoCode;

      ///////////////
      IDCardApplicationNR.ID_Card_Fee__c = IDCardApplicationNR.ID_Card_Fee__c * ((100 - (theAccount.ID_Card_Key_Account_Discount__c == null ? 0 : theAccount.ID_Card_Key_Account_Discount__c)) / 100);
      IDCardApplicationNR.Applicable_Fee__c = IDCardApplicationNR.ID_Card_Fee__c + IDCardApplicationNR.IDCard_Expedite_Delivery_Fee__c + IDCardApplicationNR.ITDI_Courses_Fee__c;
      ///////////////
      // Always display the expedite fees
      expediteFees = listPriceTables[0].Expedite__c;
      DisplayFees = true;
      //DisplayExpediteFee = true;


    } catch (Exception ex) {
      AddError(ex.getMessage());
    }
  }

  public void FillContactFieldsForReplacement() {

    //Double dVERNumber;
    String dVERNumber = IDCardApplicationNR.VER_Number__c;

    try {


      //RA: 7/10/2013 USE Last IDCard Values instead of Contact

      associatedIDCard = GetAssociatedIDCard(dVERNumber);

      if (associatedIDCard != null ) {

        // prefill some fields
        IDCardApplicationNR.Gender__c = associatedIDCard.Gender__c;//contactFound.Gender__c;
        IDCardApplicationNR.Last_Name__c = associatedIDCard.LastName__c;//contactFound.LastName;
        IDCardApplicationNR.First_Name__c = associatedIDCard.FirstName__c;//contactFound.FirstName;
        IDCardApplicationNR.Telephone__c = associatedIDCard.Phone__c;//contactFound.Phone;
        IDCardApplicationNR.Start_Date_Industry__c = associatedIDCard.Start_Date_Industry__c;//String.valueOf(contactFound.Start_Date_Industry__c);
        IDCardApplicationNR.Start_Date_Agency_Month__c = associatedIDCard.Start_Date_Agency_Month__c;//contactFound.Start_Date_Agency_Month__c;
        IDCardApplicationNR.Start_Date_Agency_Year__c = associatedIDCard.Start_Date_Agency_Year__c;//String.valueOf(contactFound.Start_Date_Agency_Year__c);
        IDCardApplicationNR.Position_in_Current_Agency__c = associatedIDCard.Position__c;//contactFound.Position__c;
        IDCardApplicationNR.Hours_worked__c = associatedIDCard.Hours_per_week__c;//contactFound.Hours_per_week__c;
        IDCardApplicationNR.Duties_in_Current_Agency__c = associatedIDCard.Duties__c;//contactFound.Duties__c;
        IDCardApplicationNR.Title__c = associatedIDCard.Title__c;//contactFound.Title;
        IDCardApplicationNR.Date_of_Birth__c = associatedIDCard.Date_of_Birth__c;//contactFound.Date_of_Birth__c;
        IDCardApplicationNR.Email_admin__c = associatedIDCard.Email__c;//contactFound.Email;
        IDCardApplicationNR.Displayed_Name__c = IDCardUtil.calculateDisplayedName(IDCardApplicationNR.First_Name__c, IDCardApplicationNR.Middle_Initial__c, IDCardApplicationNR.Last_Name__c);
      }


      if (!IsCroppingToolDisplayed) { IsViewerDisplayed = true; }
      System.debug('*** IsCroppingToolDisplayed ' + IsCroppingToolDisplayed + ' IsViewerDisplayed  ' + IsViewerDisplayed);


    } catch (Exception ex) {

      System.debug('** EXCEPTION' + ex);
      IDCardApplicationNR.Gender__c = '';//contactFound.Gender__c;
      IDCardApplicationNR.Last_Name__c = '';//contactFound.LastName;
      IDCardApplicationNR.First_Name__c = '';//contactFound.FirstName;
      IDCardApplicationNR.Displayed_Name__c = '';//contactFound.Displayed_Name__c;
      IDCardApplicationNR.Telephone__c = '';//contactFound.Phone;
      IDCardApplicationNR.Start_Date_Industry__c = '';//String.valueOf(contactFound.Start_Date_Industry__c);
      IDCardApplicationNR.Start_Date_Agency_Month__c = '';//contactFound.Start_Date_Agency_Month__c;
      IDCardApplicationNR.Start_Date_Agency_Year__c = '';//String.valueOf(contactFound.Start_Date_Agency_Year__c);
      IDCardApplicationNR.Position_in_Current_Agency__c = '';//contactFound.Position__c;
      IDCardApplicationNR.Hours_worked__c = '';//contactFound.Hours_per_week__c;
      IDCardApplicationNR.Duties_in_Current_Agency__c = '';
      PhotoFilename = '';//contactFound.UIR__c;

    }
  }

  /**
   * Create/update the contact, create the ID Card Application object and navigate to the confirmation page
   */
  public Pagereference next() {

    system.debug('Pagereference Next()');

    try {

      if (part == sectionOne) {
        if (IsFormValid()) {
          Savepoint sp = Database.setSavepoint();

          IDCardApplicationNR.IDCard_Prefered_Language__c = Language;
          if (IDCardApplicationNR.Middle_Initial__c != null && IDCardApplicationNR.Middle_Initial__c != '')
            IDCardApplicationNR.Middle_Initial__c = (IDCardApplicationNR.Middle_Initial__c).toUpperCase();
          update IDCardApplicationNR;

          try {

            // reselect the ID Card Application object
            IDCardApplicationNR = [Select i.VER_Number__c, i.RecordTypeId, i.UIR__c, i.Type_of_application__c, i.Title__c, i.Telephone__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c,
                                   i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c, i.Promotion_Code__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c, i.Package_of_Travel_Professionals_Course_2__c,
                                   i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c, i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c,
                                   i.IDCard_Expedite_Delivery__c, i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c, i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c,
                                   i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c, i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Email_admin__c,
                                   i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.ConnectionSentId, i.ConnectionReceivedId,
                                   i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c, i.AgencyShare_Confirmation__c From ID_Card_Application__c i where i.Id = : IDCardApplicationNR.Id limit 1];

            //Go to next part
            Pagereference confPage = Page.IDCard_ApplicationForm_NR;
            System.debug('$$ PARMS ' + IDCardApplicationNR.IATA_Code__c + ' ' + IDCardApplicationNR.Type_of_application__c + ' ' + IDCardApplicationNR.VER_Number__c + ' ' + IDCardApplicationNR.Id);
            confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.IATA_Code__c));
            confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Type_of_application__c));
            confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));

            if (!IsNewApplication)
              confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.VER_Number__c));


            //Do we need to upload any docs?
            if (!IsNewApplication) {
              associatedIDCard = GetAssociatedIDCard(IDCardApplicationNR.VER_Number__c);
              lastNameHasChanged = (associatedIDCard.LastName__c != IDCardApplicationNR.Last_Name__c);
            }
            isContractor = (IDCardApplicationNR.Position_in_Current_Agency__c == 'Independent Consultant/Broker');
            isEmployee = !isContractor && (IDCardApplicationNR.Position_in_Current_Agency__c != 'Sole Owner') && (IDCardApplicationNR.Position_in_Current_Agency__c != 'Shareholder')
                         && (IDCardApplicationNR.Position_in_Current_Agency__c != 'Partner');

            system.debug('----NEXT----');
            system.debug('----lastNameHasChanged----' + lastNameHasChanged);
            system.debug('----isContractor----' + isContractor);
            system.debug('----isKeyAccount(IDCardApplicationNR.IATA_Code__c, vernumParameter)----' + isKeyAccount(IDCardApplicationNR.IATA_Code__c, vernumParameter) );
            system.debug('----vernumParameter----' + vernumParameter);
            system.debug('----IDCardApplicationNR.IATA_Code__c----' + IDCardApplicationNR.IATA_Code__c);

            if ((lastNameHasChanged || isContractor || isEmployee )  && !isKeyAccount(IDCardApplicationNR.IATA_Code__c))
              confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('attach'));
            else
              confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionTwo));


            confPage.setRedirect(true);
            return confPage;

          } catch (Exception ex) {
            AddError(ex.getMessage());
            Database.rollback(sp);
            return null;
          }
        }
        return null;
      }

      //Image Uploading section
      if (part == sectionTwo) {
        //Get ID Card info from controller


        if (hiddenFilename == '') {
          HasNotUploadedImage = true;
          AddError(Label.IDCard_UploadImage);
          return null;
        } else


          IDCardApplicationNR.Photo__c = hiddenFilename;
        // IDCardApplicationNR.Photo__c = idCardTemp.Photo__c;

        //save image name
        IDCardApplicationNR.IDCard_Prefered_Language__c = Language;
        update IDCardApplicationNR;

        //redirect to next part
        Pagereference confPage = Page.IDCard_ApplicationForm_NR;
        confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.IATA_Code__c));
        confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Type_of_application__c));
        if (!IsNewApplication)
          confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.VER_Number__c));

        IATA_Code = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
        theAccount = [Select a.BillingCountry, a.ID_Card_KeyAccount_features__c,  a.type, a.ShippingState, a.Name  , a.IDCard_Key_Account__c From Account a where a.IATACode__c = :IATA_Code limit 1];

        if (theAccount.IDCard_Key_Account__c && theAccount.ID_Card_KeyAccount_features__c != null && !theAccount.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase)) {

          CalculateApplicationFee();
          IDCardApplicationNR.IDCard_Prefered_Language__c = Language;
          update IDCardApplicationNR;

          //upgrade for payment: according to record type will redirect to payment or not.
          String singleRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');

          
          if (IDCardApplicationNR.RecordTypeId != null && IDCardApplicationNR.RecordTypeId.equals(singleRT)) {
            Pagereference checkoutPage = Page.IDCard_CheckoutSingleApplication;
            checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
            checkoutPage.setRedirect(true);
            return checkoutPage;

          }
          
        }

        confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionThree));

        confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
        confPage.setRedirect(true);
        return confPage;
      }

      // Payment Section
      if (part == sectionThree) {
        CalculateApplicationFee();

        //Validation
        boolean isValid = true;

        if (IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c != null || IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c != null) {

          if (IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c == null || IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c == null) {
            AddError(Label.ID_Card_should_Sel_2_Packages);
            isValid = false;
          }
          if (IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c == IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c ) {
            AddError(Label.IDCard_CantSelectSameCourse);
            isValid = false;
          }
        }

        if (selectedITDICourses.size() > 2) {
          AddError(Label.ID_Card_should_Sel_2_Packages);
          isValid = false;
        }

        if (TermsAndConditionChecked == false) {
          AddError(Label.IDCard_Terms_and_Conditions_Err);
          isValid = false;
        }
        // If the user enter a Promo Code and the validatePromotion() is null -> the promo code entered by the user is not valid.
        if (validatePromotion() == null && IDCardApplicationNR.Promotion_Code__c != null && IDCardApplicationNR.Promotion_Code__c != '')
          isValid = false;

        if (isValid) {
          IDCardApplicationNR.IDCard_Prefered_Language__c = Language;
          if(IsExpediteDelivery){
            IDCardApplicationNR.IDCard_Expedite_Delivery__c = true;
          }
          update IDCardApplicationNR;

          //upgrade for payment: according to record type will redirect to payment or not.
          String singleRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
          if (IDCardApplicationNR.RecordTypeId != null && IDCardApplicationNR.RecordTypeId.equals(singleRT)) {
            Pagereference checkoutPage = Page.IDCard_CheckoutSingleApplication;
            checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
            checkoutPage.setRedirect(true);
            return checkoutPage;

          }


          //Pagereference confPage = Page.IDCard_Confirmation_Page;
          Pagereference checkoutPage = Page.IDCard_Checkout;
          checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
          checkoutPage.setRedirect(true);
          return checkoutPage;
        }
        return null;


      }
      //File Upload Section
      if (part == 'attach') {

        //check if  attachemnts were added
        //Attachment[] a = [Select a.ParentId, a.Name From Attachment a where a.ParentId =:IDCardApplicationNR.Id];
        if (!DocUploaded) { //(a.size() == 0)
          AddError(Label.IDCard_UploadFiles);
          return null;
        }


        try {
          System.debug('** IDCardApplicationNR.IATA_Code__c ' + IDCardApplicationNR.IATA_Code__c + ' IDCardApplicationNR.Type_of_application__c ' + IDCardApplicationNR.Type_of_application__c + ' IDCardApplicationNR.VER_Number__c' + IDCardApplicationNR.VER_Number__c + ' IDCardApplicationNR.Id ' + IDCardApplicationNR.Id );
          Pagereference confPage = Page.IDCard_ApplicationForm_NR;

          confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.IATA_Code__c));
          confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Type_of_application__c));
          if (!IsNewApplication)
            confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.VER_Number__c));
          confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionTwo));
          confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
          confPage.setRedirect(true);
          return confPage;
        } catch (Exception ex) {
          System.debug('** error attachments ' + ex);
          return null;
        }
        return null;

      }
      return null;
    } catch (Exception ex) {
      AddError(ex.getMessage());
      return null;
    }
  }

  public Pagereference back() {

    if (part == sectionOne) {
      Pagereference confPage = Page.IDCard_Checklist;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Type_of_application__c));
      if (!IsNewApplication)
        confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.VER_Number__c));
      confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionOne));
      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
      confPage.setRedirect(true);
      return confPage;
    }
    if (part == sectionTwo) {
      Pagereference confPage = Page.IDCard_ApplicationForm_NR;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Type_of_application__c));
      if (!IsNewApplication)
        confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.VER_Number__c));
      system.debug('----BACK----');
      system.debug('----lastNameHasChanged----' + lastNameHasChanged);
      system.debug('----isContractor----' + isContractor);
      system.debug('----isKeyAccount(IDCardApplicationNR.IATA_Code__c, vernumParameter)----' + isKeyAccount(IDCardApplicationNR.IATA_Code__c, vernumParameter) );
      system.debug('----vernumParameter----' + vernumParameter);
      system.debug('----IDCardApplicationNR.IATA_Code__c----' + IDCardApplicationNR.IATA_Code__c);

      if ((lastNameHasChanged || isContractor || isEmployee) && !isKeyAccount(IDCardApplicationNR.IATA_Code__c))
        confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('attach'));
      else
        confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionOne));

      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
      confPage.setRedirect(true);
      return confPage;
    }
    if (part == sectionThree) {
      Pagereference confPage = Page.IDCard_ApplicationForm_NR;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Type_of_application__c));
      if (!IsNewApplication)
        confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.VER_Number__c));
      confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionTwo));
      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
      confPage.setRedirect(true);

      //Hide upload page since picture is supposed to be uploaded already
      IsCroppingToolDisplayed = false;
      IsViewerDisplayed = true;

      return confPage;


    }
    if (part == 'attach') {
      Pagereference confPage = Page.IDCard_ApplicationForm_NR;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Type_of_application__c));
      if (!IsNewApplication)
        confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.VER_Number__c));
      confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionOne));
      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationNR.Id));
      confPage.setRedirect(true);
      return confPage;

    }
    return null;
  }


  private boolean IsFormValid() {
    boolean isValid = true;

    // Approving Manager Name and Email are Required
    if (!keyAccount && (IDCardApplicationNR.Approving_Manager_s_Name__c == null || IDCardApplicationNR.Approving_Manager_s_Name__c == '')) {
      //    schema.Describefieldresult F = ID_Card_Application__c.Approving_Manager_s_Name__c.getDescribe();
      //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    if (!keyAccount && (IDCardApplicationNR.Approving_Manager_s_Email__c == null || IDCardApplicationNR.Approving_Manager_s_Email__c == '')) {
      //   schema.Describefieldresult F = ID_Card_Application__c.Approving_Manager_s_Email__c.getDescribe();
      //  Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    // Title must be selected
    if (IDCardApplicationNR.Title__c == null || IDCardApplicationNR.Title__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Title__c.getDescribe();
      //  Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    } else {
      IDCardApplicationNR.Gender__c = getGenderFromTitle(IDCardApplicationNR.Title__c);
    }



    // A date of birth is required
    if (IDCardApplicationNR.Date_of_Birth__c == null && IsNewApplication) {
      //  schema.Describefieldresult F = ID_Card_Application__c.Date_of_Birth__c.getDescribe();
      //  Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    // Not required since the Gender is autofilled.
    /*
    // A gender must be selected
    if (IDCardApplicationNR.Gender__c == null || IDCardApplicationNR.Gender__c == ''){
        schema.Describefieldresult F = ID_Card_Application__c.Gender__c.getDescribe();
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
        isValid = false;
    }
    */
    // The Last Name cannot be null
    if (IDCardApplicationNR.Last_Name__c == null || IDCardApplicationNR.Last_Name__c == '') {
      //   schema.Describefieldresult F = ID_Card_Application__c.Last_Name__c.getDescribe();
      //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    // The first Name cannot be null
    if (IDCardApplicationNR.First_Name__c == null || IDCardApplicationNR.First_Name__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.First_Name__c.getDescribe();
      //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    //no need to have this since its autopopulated now and readonly
    /*
    // Display name on IDCard cannot be null
    if (IDCardApplicationNR.Displayed_Name__c == null || IDCardApplicationNR.Displayed_Name__c == '') {
        schema.Describefieldresult F = ID_Card_Application__c.Displayed_Name__c.getDescribe();
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
        isValid = false;
    }
     */

    // The name displayed on ID Card must not contain any special characters, only spaces and Hyphen
    if (IDCardApplicationNR.Displayed_Name__c != null && IDCardApplicationNR.Displayed_Name__c != '') {
      //pattern fullNamePattern = pattern.compile('[[\\x30-\\x39][\\x41-\\x5a][\\x61-\\x7a]- ]+');

      //remove accents
      IDCardApplicationNR.Displayed_Name__c = IDCardUtil.deAccent(IDCardApplicationNR.Displayed_Name__c);

      pattern fullNamePattern = pattern.compile('[^a-zA-Z - ,.]');
      Matcher fullNameMatcher = fullNamePattern.matcher(IDCardApplicationNR.Displayed_Name__c);
      if (fullNameMatcher.find()) {
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ID_Card_DisplayName_Business_Rule));
        isValid = false;
      }
    }

    // A admin email is required
    if (IDCardApplicationNR.Email_admin__c == null || IDCardApplicationNR.Email_admin__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Email_admin__c.getDescribe();
      //  Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    if (IDCardApplicationNR.Start_Date_Industry__c == null || IDCardApplicationNR.Start_Date_Industry__c == '') {
      // Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {Label.ID_Card_I_have_been_in_industry_since} )));
      isValid = false;
    }

    if (IDCardApplicationNR.Start_Date_Agency_Month__c == null || IDCardApplicationNR.Start_Date_Agency_Month__c == '') {
      //  Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {Label.ID_Card_Have_Been_Employed_With_Agency})));
      isValid = false;
    }

    // The Start year in industry cannot be null
    if (IDCardApplicationNR.Start_Date_Agency_Year__c == null || IDCardApplicationNR.Start_Date_Agency_Year__c == '') {
      //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {Label.ID_Card_Have_Been_Employed_With_Agency})));
      isValid = false;
    }

    if (IDCardApplicationNR.Position_in_Current_Agency__c == null || IDCardApplicationNR.Position_in_Current_Agency__c == '') {
      //   schema.Describefieldresult F = ID_Card_Application__c.Position_in_Current_Agency__c.getDescribe();
      //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    if (IDCardApplicationNR.Duties_in_Current_Agency__c == null || IDCardApplicationNR.Duties_in_Current_Agency__c == '') {
      //   schema.Describefieldresult F = ID_Card_Application__c.Duties_in_Current_Agency__c.getDescribe();
      //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    // Hours worked Required (if not null need to test for Hours worked > 20 business rule)
    if (IDCardApplicationNR.Hours_worked__c == null || IDCardApplicationNR.Hours_worked__c == '') {
      //   schema.Describefieldresult F = ID_Card_Application__c.Hours_worked__c.getDescribe();
      //    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    } else {
      // Hours Worked > 20
      if (IDCardApplicationNR.Hours_worked__c == 'Less than 20 h') {
        IDCardApplicationNR.Hours_Worked_Validation_Failed__c = true;
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ID_Card_Hours_Worked_business_rule));
        isValid = false;
      }
    }
    // Validate if Card UI displayed name doesn't match with the business rule displayed name
    if (IDCardApplicationNR.First_Name__c != '' && IDCardApplicationNR.Last_Name__c != '' && IDCardApplicationNR.Displayed_Name__c != '') {
      if (IDCardApplicationNR.Displayed_Name__c != IDCardUtil.calculateDisplayedName(IDCardApplicationNR.First_Name__c, IDCardApplicationNR.Middle_Initial__c, IDCardApplicationNR.Last_Name__c)) {
        //force Displayed name to correct value
        IDCardApplicationNR.Displayed_Name__c = IDCardUtil.calculateDisplayedName(IDCardApplicationNR.First_Name__c, IDCardApplicationNR.Middle_Initial__c, IDCardApplicationNR.Last_Name__c);
      }
    }

    if (!isAgeValid(IDCardApplicationNR.IATA_Code__c)) {
      isValid = false;
    }

    // Case Valid Flag
    if (GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c).ISO_Code__c == 'CA') {

      if (IDCardApplicationNR.Position_in_Current_Agency__c == 'Director' ||
          IDCardApplicationNR.Position_in_Current_Agency__c == 'Employee' ||
          IDCardApplicationNR.Position_in_Current_Agency__c == 'Independent Consultant/Broker' ||
          IDCardApplicationNR.Position_in_Current_Agency__c == 'Manager') {

        if (IDCardApplicationNR.Revenue_Confirmation__c == false) {
          IDCardApplicationNR.Revenue_Confirmation_Validation_Failed__c = true;
          Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR , Label.IDCard_ConfirmRev));
          isValid = false;
        }
      }

      if (IDCardApplicationNR.Position_in_Current_Agency__c == 'Sole Owner' ||
          IDCardApplicationNR.Position_in_Current_Agency__c == 'Partner' ||
          IDCardApplicationNR.Position_in_Current_Agency__c == 'Shareholder' ) {

        if (IDCardApplicationNR.AgencyShare_Confirmation__c == false && IDCardApplicationNR.Revenue_Confirmation__c == false) {
          IDCardApplicationNR.Revenue_Confirmation_Validation_Failed__c = true;
          AddError(Label.IDCard_ConfirmShareAgency);
          isValid = false;
        }
      }

    }


    if (!isvalid)
      AddError( Label.IDCard_FillAllFields)   ;
    //Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR , 'IS VALID = '));
    return isvalid;

  }

  private boolean isAgeValid(String iataCode) {

    boolean isValidDate = true;

    if ((IDCardApplicationNR.Date_of_Birth__c != null) && (IDCardApplicationNR.Start_Date_Agency_Year__c != null) && (IDCardApplicationNR.Start_Date_Industry__c != null) ) {
      if (IDCardApplicationNR.Date_of_Birth__c.year() > integer.valueOf(IDCardApplicationNR.Start_Date_Industry__c)) {
        Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.IDCard_IndustryEntrySuperior));
        isValidDate = false;
      }
      if (integer.valueOf(IDCardApplicationNR.Start_Date_Industry__c) > integer.valueOf(IDCardApplicationNR.Start_Date_Agency_Year__c)) {
        Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.IDCard_StartDateSuperior));
        isValidDate = false;
      }
      if ( integer.valueOf(IDCardApplicationNR.Start_Date_Industry__c) > Date.today().year() || integer.valueOf(IDCardApplicationNR.Start_Date_Agency_Year__c) > Date.today().year()) {
        Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.IDCard_EmployementLessThanToday));
        isValidDate = false;
      }


      // if Birth date is superior to entry industry date or entry industry is superior to start agency date
      if (!isValidDate) {
        return false;
      }

      if (GetIATAISOCountryOfContact(iataCode).ISO_Code__c == 'CA') {


        if (IDCardApplicationNR.Date_of_Birth__c.addYears(18) >  Date.today()) {
          Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.Format(Label.IDCard_MinAgeReq1, new String[] {'<i>18</i>'})));
          isValidDate = false;
        }

        if (IDCardApplicationNR.Date_of_Birth__c.addYears(18).year() >  integer.valueOf(IDCardApplicationNR.Start_Date_Agency_Year__c)) {
          Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.Format(Label.IDCard_MinAgeReq2, new String[] {'<i>18</i>'})));
          isValidDate = false;
        }

        if (IDCardApplicationNR.Date_of_Birth__c.addYears(18).year() > integer.valueOf(IDCardApplicationNR.Start_Date_Industry__c)) {
          Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.Format(Label.IDCard_MinAgeReq3, new String[] {'<i>18</i>'})));
          isValidDate = false;
        }
      } else {

        if (IDCardApplicationNR.Date_of_Birth__c.addYears(16) >  Date.today()) {
          Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.Format(Label.IDCard_MinAgeReq1, new String[] {'<i>16</i>'})));
          isValidDate = false;
        }

        if (IDCardApplicationNR.Date_of_Birth__c.addYears(16).year() >  integer.valueOf(IDCardApplicationNR.Start_Date_Agency_Year__c)) {
          Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.Format(Label.IDCard_MinAgeReq2, new String[] {'<i>16</i>'})));
          isValidDate = false;
        }

        if (IDCardApplicationNR.Date_of_Birth__c.addYears(16).year() > integer.valueOf(IDCardApplicationNR.Start_Date_Industry__c)) {
          Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.Format(Label.IDCard_MinAgeReq3, new String[] {'<i>16</i>'})));
          isValidDate = false;
        }
      }
    }
    return isValidDate;
  }


  /**
   * Returns the country ISO code of a contact based on its IATA code
   */
  private IATA_ISO_Country__c GetIATAISOCountryOfContact(String iataCode) {

    Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(iataCode);

    List<IATA_ISO_Country__c> listCountries = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry);
    if (listCountries == null || listCountries.size() == 0) {
      throw new IDCardApplicationException(string.format(Label.ID_Card_Invalid_ISO_Country, new string[] { theAccount.BillingCountry }));
    }

    return listCountries[0];
  }



  ///Upload doc Stuff
  public Attachment document1 {
    get {
      if (document1 == null)
        document1 = new Attachment();
      return document1;
    }
    set;
  }

  public Attachment document2 {
    get {
      if (document2 == null)
        document2 = new Attachment();
      return document2;
    }
    set;
  }

  public Attachment document3 {
    get {
      if (document3 == null)
        document3 = new Attachment();
      return document3;
    }
    set;
  }

  public String docDesc1 {get; set;}
  public String docDesc2 {get; set;}
  public String docDesc3 {get; set;}

  public List<SelectOption> getDocDescription() {
    list<SelectOption> values = new list<SelectOption>();
    values.add(new SelectOption('', '-- None --'));
    if (LastNameHasChanged)
      values.add(new SelectOption('Last Name Change Proof', 'Last Name Change Proof'));
    if (isContractor)
      values.add(new SelectOption('Independent Contractor Proof', 'Independent Contractor Proof'));
    if (isEmployee) {
      values.add(new SelectOption('Employment Proof', 'Employment Proof'));
      values.add(new SelectOption('Proof of IDC Payment (Deposit Slip)', 'Proof of IDC Payment (Deposit Slip)'));
    }
    return values;
  }



  public List<Attachment> getDocs() {
    System.debug('**** Getting New documents');
    docs = [Select Name, Description, Id from Attachment where ParentId = :IDCardApplicationNR.Id];
    return docs;

  }

  public PageReference deleteAttachment() {
    try {
      System.debug('**** Deleteing ATTACHMENT with ID ' + attachmentID);
      delete new List<Attachment>( [Select Name from Attachment where Id = :attachmentID]);

      List<Attachment> tempList = [Select Name, Description, Id from Attachment where ParentId = :IDCardApplicationNR.Id];
      if (tempList.size() == 0)
        DocUploaded = false;
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_ErrorDeleteingFile));
    }
    return null;
  }

  public PageReference upload() {
    System.debug('**** Uploading Docs');
    try {

      if ((document1.Name != null && document1.Name != '' && (docDesc1 == '' || docDesc1 == null))
          || (document2.Name != null && document2.Name != '' && (docDesc2 == '' || docDesc2 == null))
          || (document3.Name != null && document3.Name != '' && (docDesc3 == '' || docDesc3 == null))) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_Select_Description));
        return null;
      }
      //get parent ID
      document1.ParentId = IDCardApplicationNR.Id;
      //document1.Description = 'Last Name Change Proof';
      document1.Description = docDesc1;
      document2.ParentId = IDCardApplicationNR.Id;
      //document2.Description = 'Independent Contractor Proof';
      document2.Description = docDesc2;
      document3.ParentId = IDCardApplicationNR.Id;
      //document3.Description = 'Employment Proof';
      document3.Description = docDesc3;



      //Check if the file upload is a PDF File

      if (document1.Name != null && document1.Name != '') {
        Integer doc1NameLength = document1.Name.length();
        if (!(document1.Name).substring(doc1NameLength - 3, doc1NameLength).equalsIgnoreCase('pdf')) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_OnlyPDFFileAllowed));
          return null;
        }
      }
      if (document2.Name != null && document2.Name != '') {
        Integer doc2NameLength = document2.Name.length();
        if (!(document2.Name).substring(doc2NameLength - 3, doc2NameLength).equalsIgnoreCase('pdf')) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_OnlyPDFFileAllowed));
          return null;
        }
      }
      if (document3.Name != null && document3.Name != '') {
        Integer doc3NameLength = document3.Name.length();
        if (!(document3.Name).substring(doc3NameLength - 3, doc3NameLength).equalsIgnoreCase('pdf')) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_OnlyPDFFileAllowed));
          return null;
        }
      }

      /*if (lastNameHasChanged && document1.Name == null){
          AddError(Label.IDCard_UploadFiles);
          return null;
      }
      if(isContractor && document2.Name == null){
          AddError(Label.IDCard_UploadFiles);
          return null;
      }
      if(isEmployee && document3.Name == null){
          AddError(Label.IDCard_UploadFiles);
          return null;
      }*/
      if (document1.Name == null && document2.Name == null && document3.Name == null) {
        AddError(Label.IDCard_UploadFiles);
        return null;
      }


      /*if (lastNameHasChanged)
         insert document1;
      if(isContractor)
         insert document2;
      if(isEmployee)
         insert document3;*/
      if (document1.Name != null)
        insert document1;
      if (document2.Name != null)
        insert document2;
      if (document3.Name != null)
        insert document3;

    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_ErrorUploadingFile));
      DocUploaded = false;
      return null;
    } finally {
      document1.body = null; // clears the viewstate
      document1 = new Attachment();
      document2.body = null; // clears the viewstate
      document2 = new Attachment();
      document3.body = null; // clears the viewstate
      document3 = new Attachment();

      //get parent ID
      document1.ParentId = IDCardApplicationNR.Id;
      document2.ParentId = IDCardApplicationNR.Id;
      document3.ParentId = IDCardApplicationNR.Id;
      docDesc1 = null;
      docDesc2 = null;
      docDesc3 = null;
    }

    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.IDCard_FileUploadSuccess));
    DocUploaded = true;

    return null;
  }

  private Promotion__c validatePromotion () {
    boolean isError = true;
    //////////////////////////
    // validate the promotion
    // Promotion code must exists, must be associated to the corresponding Price Table and be between the validity period
    if (IDCardApplicationNR.Promotion_Code__c != null && IDCardApplicationNR.Promotion_Code__c != '') {

      Promotion__c[] listPromotion = [Select p.Promotion_Value__c, p.Promotion_Duration_Valid_Up_to__c, p.Promotion_Duration_Valid_From__c, p.Promotion_Code__c, p.Type_of_Application__c From Promotion__c p where p.Promotion_Code__c = :IDCardApplicationNR.Promotion_Code__c];
      if (listPromotion == null || listPromotion.size() == 0) {
        IDCardApplicationNR.Promotion_Code__c.addError(String.Format(Label.ID_Card_Invalid_Promotion_Code, new String[] {IDCardApplicationNR.Promotion_Code__c}));
        return null;
      }
      
       String[] typeOfAppInPromoCode =  listPromotion[0].Type_of_Application__c.split(';');

        for(String typeOfApp : typeOfAppInPromoCode){
          if(typeOfApp == IDCardApplicationNR.Type_of_Application__c) {
            isError = false;
            break;
          }
        }

       
    if (isError) {
       IDCardApplicationNR.Promotion_Code__c.addError(String.Format(Label.ID_Card_Invalid_Promotion_Code_2, new String[] {IDCardApplicationNR.Promotion_Code__c}));
       return null;
    }  
    
      if (listPromotion[0].Promotion_Duration_Valid_Up_to__c < Date.today()) {
        IDCardApplicationNR.Promotion_Code__c.addError(Label.ID_Card_Promotion_Code_No_Longer_Valid);
        return null;
      } else if (listPromotion[0].Promotion_Duration_Valid_From__c > Date.today()) {
        IDCardApplicationNR.Promotion_Code__c.addError(Label.ID_Card_Promotion_Code_Not_Yet_Valid);
        return null;
      }
      return listPromotion[0];
    }
    return null;
  }

  private  String getResourceURL(String resourceName) {
    //Fetching the resource
    list<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

    //Checking if the result is returned or not
    if (resourceList.size() == 1) {
      //Getting namespace
      String namespace = resourceList[0].NamespacePrefix;
      //Resource URL
      return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName;
    } else return '';
  }

  private String getGenderFromTitle(String titleSelected) {
    if (titleSelected.equalsIgnoreCase('Mr'))
      return 'Male';
    if (titleSelected.equalsIgnoreCase('Ms') || titleSelected.equalsIgnoreCase('Mrs'))
      return 'Female';
    return '';
  }


  public void forTestCoverage() {
    this.getGenderFromTitle('Mr');
    this.getGenderFromTitle('Ms');
    this.getResourceURL('Ms');
    this.deleteAttachment();
    this.getDocDescription();
    FillContactFieldsForReplacement();
    docDesc1 = 'desc';
    docDesc2 = 'desc';
    docDesc3 = 'desc';
    this.document1 = new Attachment(Name = 'abc.pdf', Body = Blob.valueOf('abc'));
    this.document2 = new Attachment(Name = 'abc.pdf', Body = Blob.valueOf('abc'));
    this.document3 = new Attachment(Name = 'abc.pdf', Body = Blob.valueOf('abc'));
    this.upload();
    this.back();
    this.GetAssociatedContact('aaa');
    //  this.getIataCodesItems();
    this.CalculateApplicationFee();
    this.GetAssociatedIDCard('aaa');
  }
}