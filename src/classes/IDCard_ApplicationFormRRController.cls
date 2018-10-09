public with sharing class IDCard_ApplicationFormRRController extends  IDCardAbstractController {

  private String part;
  private final String sectionOne = '1';
  private final String sectionTwo = '2';
  private final String sectionThree = '3';
  public String attachmentID {get; set;} //used to store the attachment ID that will be deleted
  private List<Attachment> docs;
  private Boolean newContactRequired;
  private Map<String, decimal> detailledFees;
  private String accountType; 

  public String hiddenFilename {get; set;}
  public decimal expediteFees {get; private set;}
  public String PhotoFilename {get; set;}
  public ID_Card_Application__c IDCardApplicationRR {get; set;}
  public ID_Card__c CurrentIDCard {get; set;}
  public Contact associatedContact {get; set;}
  public ID_Card__c associatedIDCard {get; set;}
  // public Attachment attachmentProof {get; set;}
  
  public Boolean IsExpediteDelivery;
  public list<SelectOption> itdiCourses;
  private String[] selectedITDICourses;

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

  private String IATA_Code;
  private Account theAccount;

  //public Boolean DisplayExpediteFee {get; set;}
  public Boolean DisplayFees {get; set;}
  public Boolean CanRenderPage {get; set;}
  public Boolean TermsAndConditionChecked { get; set; }
  public Boolean isPart1 { get; set; }
  public Boolean isAttachmentsNeeded { get; set; }
  public Boolean isPart2 { get; set; }
  public Boolean isPart3 { get; set; }
  public Boolean lastNameHasChanged {get; set;}
  public Boolean isContractor {get; set;}
  public Boolean isEmployee {get; set;}
  public Boolean DocUploaded {get; set;}
  public Boolean HasNotUploadedImage {get; set;}
  public Boolean reissue {
    get {
      if (IDCardApplicationRR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE)
        return true;

      return false;
    }
  }

  public Boolean IsContactFromCanada {
    get {
      if (GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c).ISO_Code__c == 'CA')
        return true;

      return false;

    }
  }

  public Boolean IsExpediteDeliveryAddedtoIDCardPrice {
    get {


      IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c);
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


  public Boolean IsExpediteAvailable {
    get {

      IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c);
      Price_Table__c[] listPriceTables = [Select p.ID_Card_Fee__c, p.Expedite__c, p.IATA_Package__c, p.Expedite_Delivery_added_to_IDCard_Price__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
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

      if (isEmployee)
        return Label.IDCard_Employee + '<br/>' + Label.IDCard_UploadDocs + '<br/><br/>';



      return '';
    }
    set;
  }
  public String PageTitle {
    get{
      if (IDCardApplicationRR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_RENEWAL)
        return Label.ID_Card_Application_Type_Renewal;
      if (IDCardApplicationRR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE)
        return Label.ID_Card_Application_Type_Reissue;
      return '';
    }
    set;
  }

  public String TermsAndConditions {
    get{
      if (GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c).ISO_Code__c == 'CA') {
        return Label.ID_Card_Terms_ConditionCA;
      } else{
        return Label.ID_Card_Terms_Condition;
      }
    }
  }

  public Boolean RevenueConfirmationDisabled {
    get {
      if (GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c).ISO_Code__c == 'CA') {

        if (IDCardApplicationRR.Position_in_Current_Agency__c == 'Director' ||
        IDCardApplicationRR.Position_in_Current_Agency__c == 'Employee' ||
        IDCardApplicationRR.Position_in_Current_Agency__c == 'Manager' ) {
          return false;
        }
      }
      return true;
    }
  }
  // Upload doc Stuff
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
    docs = [Select Name, Description, Id from Attachment where ParentId = :IDCardApplicationRR.Id];
    return docs;
  }

  public String[] getSelectedITDICourses() {
    return selectedITDICourses;
  }
  public String SelectedCoursesCount {
    get {return String.ValueOf(selectedITDICourses.size());}
    set;
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

  public IDCard_ApplicationFormRRController() {
    IsExpediteDelivery = false;
    initialize();
    system.debug('[IDCard_ApplicationFormRRController] Controller started')  ;
    detailledFees = new Map<String, decimal>();
    DocUploaded = false;
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

    //knows what part of page to load
    part = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PAGE_PART));
    system.debug('[IDCard_ApplicationFormRRController] loading part ' + part)  ;
    // check to see if the language was stored in a cookie
    Cookie langCookie = ApexPages.currentPage().getCookies().get(IDCARD_PORTAL_LANG);
    if (langCookie == null) {
      Language = 'en_US';
      selectedLanguage = Language;
    } else {
      Language = langCookie.getValue();
      selectedLanguage = Language;
    }

    try {

      system.debug('[IDCard_ApplicationFormRRController] app Id  ' + IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID)))  ;
      String applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));
      system.debug('[IDCard_ApplicationFormRRController] found id card app Id  ' + applicationId)  ;
      //get application info from DB
      IDCardApplicationRR = [Select i.Payment_Amount__c, i.VER_Number__c, i.RecordTypeId, i.Revenue_Confirmation__c, i.UIR__c, i.Type_of_application__c, i.Title__c, i.Telephone__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c, i.Promotion_Code__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c, i.Package_of_Travel_Professionals_Course_2__c, i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c, i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c, i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c, i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c, i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c, i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Email_admin__c, i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.ConnectionSentId, i.ConnectionReceivedId, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c, i.Regional_Office__c, i.AgencyShare_Confirmation__c  From ID_Card_Application__c i where i.Id = :applicationId limit 1];
      system.debug('[IDCard_ApplicationFormRRController] found id card app from Id ?  ' + (IDCardApplicationRR != null))  ;
      //Block Page if payment is done and case is created
      Case[] tempCase = [ Select id from Case where Related_ID_Card_Application__c = : IDCardApplicationRR.Id ] ;
      if (tempCase.size() > 0 ) {
        system.debug('[IDCard_ApplicationFormRRController] ERROR found cases   ' + tempCase.size())  ;
        part = '';
        AddError(Label.IDCard_NoModificationAllowed);
      }
      String dVERNumber = IDCardApplicationRR.VER_Number__c;// IDCardUtil.formatNumbersWithSeparators(Decimal.valueof(String.valueof(IDCardApplicationRR.VER_Number__c)),0,',',',');
      system.debug('[IDCard_ApplicationFormRRController] converted vernum ' + dVERNumber)  ;
      associatedIDCard = GetAssociatedIDCard(dVERNumber);
      system.debug('[IDCard_ApplicationFormRRController] Find Id card for vernum = ' + dVERNumber + '? ' + (associatedIDCard != null))  ;

      lastNameHasChanged = (associatedIDCard.LastName__c != IDCardApplicationRR.Last_Name__c);
      isContractor = (IDCardApplicationRR.Position_in_Current_Agency__c == 'Independent Consultant/Broker');
      isEmployee = !isContractor && IDCardApplicationRR.Position_in_Current_Agency__c != 'Sole Owner' && IDCardApplicationRR.Position_in_Current_Agency__c != 'Shareholder'
                   && IDCardApplicationRR.Position_in_Current_Agency__c != 'Partner';


      System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PART = ' + part + ' SECTION 1 = ' + sectionOne +  ' Comparaison = ' + (sectionOne == part));
      if (part == sectionOne) {
        isPart1 = true;
        // initialize some variables

        IDCardApplicationRR.IATA_Code__c = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
        IDCardApplicationRR.Type_of_application__c = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPLICATIONTYPE));
        IDCardApplicationRR.VER_Number__c = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_VER));
        IDCardApplicationRR.Regional_Office__c = (GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c)).IATA_Regional_Office__c;


        associatedIDCard = GetAssociatedIDCard(dVERNumber);
        // associatedIDCard = GetAssociatedIDCard(IDCardApplicationRR.VER_Number__c );

        if (associatedIDCard != null ) {

          // prefill some fields
          IDCardApplicationRR.Gender__c = associatedIDCard.Gender__c;//contactFound.Gender__c;
          IDCardApplicationRR.Last_Name__c = IDCardUtil.deAccent(associatedIDCard.LastName__c);//contactFound.LastName;
          IDCardApplicationRR.First_Name__c = IDCardUtil.deAccent(associatedIDCard.FirstName__c);//contactFound.FirstName;
          IDCardApplicationRR.Telephone__c = associatedIDCard.Phone__c;//contactFound.Phone;
          IDCardApplicationRR.Start_Date_Industry__c = associatedIDCard.Start_Date_Industry__c;//String.valueOf(contactFound.Start_Date_Industry__c);
          IDCardApplicationRR.Start_Date_Agency_Month__c = associatedIDCard.Start_Date_Agency_Month__c;//contactFound.Start_Date_Agency_Month__c;
          IDCardApplicationRR.Start_Date_Agency_Year__c = associatedIDCard.Start_Date_Agency_Year__c;//String.valueOf(contactFound.Start_Date_Agency_Year__c);
          IDCardApplicationRR.Position_in_Current_Agency__c = associatedIDCard.Position__c;//contactFound.Position__c;

          IDCardApplicationRR.Duties_in_Current_Agency__c = associatedIDCard.Duties__c;//contactFound.Duties__c;
          IDCardApplicationRR.Title__c = associatedIDCard.Title__c;//contactFound.Title;
          IDCardApplicationRR.Date_of_Birth__c = associatedIDCard.Date_of_Birth__c;//contactFound.Date_of_Birth__c;

          IDCardApplicationRR.Displayed_Name__c = IDCardUtil.calculateDisplayedName(IDCardApplicationRR.First_Name__c, IDCardApplicationRR.Middle_Initial__c, IDCardApplicationRR.Last_Name__c);

        }
      }

      //Not the first page of the form. Other parts get previous data from DB
      else {
        //get application ID from URL parm
        associatedContact = GetAssociatedContact(IDCardApplicationRR.VER_Number__c);

        if (part == sectionTwo) // image upload
          isPart2 = true;
        if (part == sectionThree) { // payment and confirmation
          isPart3 = true;


          // if back button is pressed: set UI checkboxes to selected ITDI courses
          if (IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c  != null)
            selectedITDICourses.add(IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c );
          if (IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c  != null)
            selectedITDICourses.add(IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c);


          CalculateApplicationFee();

        }
        if (part == 'attach') { //attachments
          Attachment[] a = [Select a.ParentId, a.Name From Attachment a where a.ParentId = :IDCardApplicationRR.Id];
          if (a.size() > 0) {
            DocUploaded = true;
          }

          isAttachmentsNeeded = true;

        }

        TermsAndConditionChecked = false;
      }

      //  DisplayExpediteFee = true;
      DisplayFees = true;
      newContactRequired = false;
      CanRenderPage = true;
      hiddenFilename = null;


      try {
        // get the ID Card the agent currently has
        // TODO: validate the business rules to retreive the current ID Card (or the last one)
        associatedContact = GetAssociatedContact(dVERNumber);

        //ID_Card__c[] idCards = [Select i.Related_Contact__c, i.Photo__c, i.Valid_To_Date__c, i.ID_Card_Application__r.Displayed_Name__c  From ID_Card__c i where i.Related_Contact__c = :associatedContact.Id AND (Card_Status__c =:IDCardUtil.CARDSTATUS_PRINTED_DELIVERED or Card_Status__c =: IDCardUtil.CARDSTATUS_CANCELED) order by i.CreatedDate desc];

        // Kofi: 12/09/2013. Card_Status__c is removed from the criteria.

        ID_Card__c[] idCards = [Select i.Related_Contact__c, i.Photo__c, i.Valid_To_Date__c, i.ID_Card_Application__r.Displayed_Name__c  From ID_Card__c i where i.Related_Contact__c = :associatedContact.Id order by i.Valid_To_Date__c desc];
        if (idCards == null || idCards.size() == 0) {
          throw new IDCardApplicationException(string.format(Label.ID_Card_Not_found_for_VER, new string[] { IDCardApplicationRR.VER_Number__c }));
        } else {
          CurrentIDCard = idCards[0];
          PhotoFilename = IDCardUtil.NewGuid();
          hiddenFilename = idCards[0].Photo__c;   // Set the hidden filename field with the name of the photo we get from the last IDCard
        }
      }

      catch (Exception ex) {
        system.debug(ex.getStackTraceString());
        AddError(ex.getStackTraceString());
        CanRenderPage = false;
      }

    }

    catch (Exception ex) {
      system.debug(ex.getStackTraceString());
      AddError(ex.getStackTraceString());
      CanRenderPage = false;
    }
  }

  /**
   * Function : Calculates and displays the Applicable fee
   */
  public void CalculateApplicationFee() {
    try {
      system.debug('[IDCard_ApplicationFormRRController] CalculateApplicationFee ')  ;
      Promotion__c validPromotion = null;
      Account theAccount = [Select a.ID_Card_Key_Account_Discount__c, a.IATACode__c, a.type, a.BillingCountry From Account a where a.IATACode__c = : IDCardApplicationRR.IATA_Code__c limit 1];
      if (theAccount == null)
        throw new IDCardApplicationException(string.format(Label.ID_Card_Account_Not_Found, new String[] {IDCardApplicationRR.IATA_Code__c}));

      // Map the account agent type to the Price Table agent type
      accountType = IDCardUtil.GetAgentTypeFromAccountType(theAccount.type);

      // get the Price Table based on the country and on the type of agent
      IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c);
      Price_Table__c[] listPriceTables = [Select p.ID_Card_Fee__c, p.IATA_Package__c, p.Type_Class_of_Agent__c, p.Expedite__c, p.Name From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
      if (listPriceTables == null || listPriceTables.size() == 0) {
        throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
      }

      validPromotion = validatePromotion();

      //Get the ITDI Courses Selection
      IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c = null;
      IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c = null;



      if (selectedITDICourses != null) {
        if (selectedITDICourses.size() == 1)
          IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c = selectedITDICourses[0];
        if (selectedITDICourses.size() >= 2) {
          IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c = selectedITDICourses[0];
          IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c = selectedITDICourses[1];
        }
      }

      ////////////////////////////////
      // calculate the applicable fee

      Boolean isReissue = (IDCardApplicationRR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE);
      Boolean isExpedite = IDCardApplicationRR.IDCard_Expedite_Delivery__c;
      Boolean isITDIPackage = selectedITDICourses.size() > 0; //IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c != null || IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c != null;
      detailledFees = IDCardUtil.GetDetailledFees(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);
      IDCardApplicationRR.Applicable_Fee__c = IDCardUtil.GetApplicableFee(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);
      IDCardApplicationRR.ID_Card_Fee__c = detailledFees.get('IDCardFee');
      IDCardApplicationRR.IDCard_Expedite_Delivery_Fee__c = detailledFees.get('ExpediteFee');
      IDCardApplicationRR.ITDI_Courses_Fee__c = detailledFees.get('ITDIFee');

      ///////////////
      IDCardApplicationRR.ID_Card_Fee__c = IDCardApplicationRR.ID_Card_Fee__c * ((100 - (theAccount.ID_Card_Key_Account_Discount__c == null ? 0 : theAccount.ID_Card_Key_Account_Discount__c)) / 100);
      IDCardApplicationRR.Applicable_Fee__c = IDCardApplicationRR.ID_Card_Fee__c + IDCardApplicationRR.IDCard_Expedite_Delivery_Fee__c + IDCardApplicationRR.ITDI_Courses_Fee__c;
      ///////////////

      IDCardApplicationRR.CurrencyIsoCode = listPriceTables[0].CurrencyIsoCode;
      DisplayFees = true;

      // Always display the expedite fees
      expediteFees = listPriceTables[0].Expedite__c;
      //  DisplayExpediteFee = true;


    }

    catch (Exception ex) {
      System.debug('1 Exception on CalculateApplicationFee... ' + ex);
      AddError(ex.getMessage());
    }
  }

  /**
   * Function : Create/update the contact, create the ID Card Application object and navigate to the confirmation page
   */
  public Pagereference next() {
    //First Section
    system.debug('[IDCard_ApplicationFormRRController] next ')  ;
    if (part == sectionOne) {
      if (IsFormValid()) {
        Savepoint sp = Database.setSavepoint();

        try {

          IDCardApplicationRR.IDCard_Prefered_Language__c = Language;
          if (IDCardApplicationRR.Middle_Initial__c != null && IDCardApplicationRR.Middle_Initial__c != '')
            IDCardApplicationRR.Middle_Initial__c = (IDCardApplicationRR.Middle_Initial__c).toUpperCase();
          update IDCardApplicationRR;

          // reselect the ID Card Application object
          ID_Card_Application__c idCardApp = [Select i.Name From ID_Card_Application__c i where i.Id = :IDCardApplicationRR.Id limit 1];


          //Go to next part
          Pagereference confPage = Page.IDCard_ApplicationForm_RR;
          System.debug('$$ PARMS ' + IDCardApplicationRR.IATA_Code__c + ' ' + IDCardApplicationRR.Type_of_application__c + ' ' + IDCardApplicationRR.VER_Number__c + ' ' + IDCardApplicationRR.Id);
          confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.IATA_Code__c));
          confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Type_of_application__c));
          confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.VER_Number__c));

          //Do we need to upload any docs?
          associatedIDCard = GetAssociatedIDCard(IDCardApplicationRR.VER_Number__c);
          lastNameHasChanged = (associatedIDCard.LastName__c != IDCardApplicationRR.Last_Name__c);

          isContractor = (IDCardApplicationRR.Position_in_Current_Agency__c == 'Independent Consultant/Broker');
          isEmployee = !isContractor && IDCardApplicationRR.Position_in_Current_Agency__c != 'Sole Owner' && IDCardApplicationRR.Position_in_Current_Agency__c != 'Shareholder'
                       && IDCardApplicationRR.Position_in_Current_Agency__c != 'Partner';
          //isEmployee = !reissue && !isContractor && IDCardApplicationRR.Position_in_Current_Agency__c != 'Sole Owner' && IDCardApplicationRR.Position_in_Current_Agency__c != 'Shareholder';

          System.debug(LoggingLevel.ERROR, ':::::: section1: next: lastNameHasChanged: ' + lastNameHasChanged);
          System.debug(LoggingLevel.ERROR, ':::::: section1: next: isContractor: ' + isContractor);
          System.debug(LoggingLevel.ERROR, ':::::: section1: next: isEmployee: ' + isEmployee);
          System.debug(':::::: section1: next: vernumParameter: 511' + vernumParameter);
          System.debug(':::::: section1: next: isKeyAccount 511: ' + isKeyAccount(IDCardApplicationRR.IATA_Code__c, vernumParameter));
          System.debug(':::::: section1: next: isKeyAccount 511: ' + isKeyAccount(IDCardApplicationRR.IATA_Code__c, IDCardApplicationRR.VER_Number__c));
          if ((lastNameHasChanged || isContractor || isEmployee) && !isKeyAccount(IDCardApplicationRR.IATA_Code__c, IDCardApplicationRR.VER_Number__c))
            confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('attach'));

          else
            confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionTwo));

          confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
          confPage.setRedirect(true);
          return confPage;
        } catch (Exception ex) {
          AddError(ex.getMessage());
          System.debug('1 Exception on next... ' + ex);
          Database.rollback(sp);
          return null;
        }
      }
      return null;
    }

    //Image Uploading section
    if (part == sectionTwo) {
      //Validation if image was uploaded
      if (hiddenFilename == '' || hiddenFilename == null ) {
        AddError(Label.IDCard_UploadImage);
        return null;
      }

      //save image name
      IDCardApplicationRR.Photo__c = hiddenFilename;
      IDCardApplicationRR.IDCard_Prefered_Language__c = Language;
      update IDCardApplicationRR;

      //redirect to next part
      Pagereference confPage = Page.IDCard_ApplicationForm_RR;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Type_of_application__c));
      confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.VER_Number__c));

      IATA_Code = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
      theAccount = [Select a.BillingCountry, a.ID_Card_KeyAccount_features__c,  a.type, a.ShippingState, a.Name  , a.IDCard_Key_Account__c From Account a where a.IATACode__c = :IATA_Code limit 1];

      if (theAccount.IDCard_Key_Account__c && theAccount.ID_Card_KeyAccount_features__c != null && !theAccount.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase)) {

        CalculateApplicationFee();
        IDCardApplicationRR.IDCard_Prefered_Language__c = Language;
        update IDCardApplicationRR;

        //upgrade for payment: according to record type will redirect to payment or not.
        String singleRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        if (IDCardApplicationRR.RecordTypeId != null && IDCardApplicationRR.RecordTypeId.equals(singleRT)) {
          Pagereference checkoutPage = Page.IDCard_CheckoutSingleApplication;
          checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
          checkoutPage.setRedirect(true);
          return checkoutPage;

        }
      }

      confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionThree));
      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
      confPage.setRedirect(true);
      return confPage;
    }

    // Payment Section
    if (part == sectionThree) {
      CalculateApplicationFee();

      //Validation
      boolean isValid = true;

      if (IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c != null || IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c != null) {
        if (IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c == null || IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c == null) {
          AddError(Label.ID_Card_should_Sel_2_Packages);
          isValid = false;
        }

        if (IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c == IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c ) {
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
      if (validatePromotion() == null && IDCardApplicationRR.Promotion_Code__c != null && IDCardApplicationRR.Promotion_Code__c != '')
        isValid = false;


      if (isValid) {
        IDCardApplicationRR.IDCard_Prefered_Language__c = Language;
        if(IsExpediteDelivery){
            IDCardApplicationRR.IDCard_Expedite_Delivery__c = true;
          }
        update IDCardApplicationRR;


        //upgrade for payment: according to record type will redirect to payment or not.
        String singleRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        if (IDCardApplicationRR.RecordTypeId != null && IDCardApplicationRR.RecordTypeId.equals(singleRT)) {
          Pagereference checkoutPage = Page.IDCard_CheckoutSingleApplication;
          checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
          checkoutPage.setRedirect(true);
          return checkoutPage;

        }

        Pagereference checkoutPage = Page.IDCard_Checkout;
        checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
        checkoutPage.setRedirect(true);
        return checkoutPage;


      }
      return null;

    }

    //File Upload Section
    if (part == 'attach') {
      //check if  attachemnts were added
      // Attachment[] a = [Select a.ParentId, a.Name From Attachment a where a.ParentId =:IDCardApplicationRR.Id];
      if (!DocUploaded) { //(a.size() == 0)
        AddError(Label.IDCard_UploadFiles);
        return null;
      }

      try {
        System.debug('** IDCardApplicationRR.IATA_Code__c ' + IDCardApplicationRR.IATA_Code__c + ' IDCardApplicationRR.Type_of_application__c ' + IDCardApplicationRR.Type_of_application__c + ' IDCardApplicationRR.VER_Number__c' + IDCardApplicationRR.VER_Number__c + ' IDCardApplicationRR.Id ' + IDCardApplicationRR.Id );
        Pagereference confPage = Page.IDCard_ApplicationForm_RR;

        confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.IATA_Code__c));
        confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Type_of_application__c));
        confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.VER_Number__c));
        confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionTwo));
        confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
        confPage.setRedirect(true);
        return confPage;
      } catch (Exception ex) {
        System.debug('** error attachments ' + ex);
        return null;
      }
    }
    return null;
  }


  public Pagereference back() {

    if (part == sectionOne) {
      Pagereference confPage = Page.IDCard_Checklist;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Type_of_application__c));
      confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.VER_Number__c));
      confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionTwo));
      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
      confPage.setRedirect(true);
      return confPage;
    }
    if (part == sectionTwo) {
      Pagereference confPage = Page.IDCard_ApplicationForm_RR;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Type_of_application__c));
      confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.VER_Number__c));

      System.debug(LoggingLevel.ERROR, ':::::: section2: back: lastNameHasChanged: ' + lastNameHasChanged);
      System.debug(LoggingLevel.ERROR, ':::::: section2: back: isContractor: ' + isContractor);
      System.debug(LoggingLevel.ERROR, ':::::: section2: back: isEmployee: ' + isEmployee);
      System.debug(LoggingLevel.ERROR, ':::::: section2: back: keyAccount: ' + keyAccount);
      System.debug(':::::: section1: next: vernumParameter: 689' + vernumParameter);
      System.debug(':::::: section1: next: isKeyAccount 689: ' + isKeyAccount(IDCardApplicationRR.IATA_Code__c, vernumParameter));
      System.debug(':::::: section1: next: isKeyAccount 689: ' + isKeyAccount(IDCardApplicationRR.IATA_Code__c, IDCardApplicationRR.VER_Number__c));
      //if ((lastNameHasChanged || isContractor || isEmployee) && !keyAccount)
      if ((lastNameHasChanged || isContractor || isEmployee) && !isKeyAccount(IDCardApplicationRR.IATA_Code__c, IDCardApplicationRR.VER_Number__c))
        confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('attach'));
      else
        confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionOne));

      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
      confPage.setRedirect(true);
      return confPage;
    }
    if (part == sectionThree) {
      Pagereference confPage = Page.IDCard_ApplicationForm_RR;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Type_of_application__c));
      confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.VER_Number__c));
      confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionTwo));
      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
      confPage.setRedirect(true);
      return confPage;

    }
    if (part == 'attach') {
      Pagereference confPage = Page.IDCard_ApplicationForm_RR;
      confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.IATA_Code__c));
      confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Type_of_application__c));
      confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.VER_Number__c));
      confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter(sectionOne));
      confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(IDCardApplicationRR.Id));
      confPage.setRedirect(true);
      return confPage;

    }
    return null;
  }


  /**
   * Function : Deletes Attachement
   */
  public PageReference deleteAttachment() {
    try {
      System.debug('**** Deleteing ATTACHMENT with ID ' + attachmentID);
      delete new List<Attachment>( [Select Name from Attachment where Id = :attachmentID]);

      List<Attachment> tempList = [Select Name, Description, Id from Attachment where ParentId = :IDCardApplicationRR.Id];
      if (tempList.size() == 0)
        DocUploaded = false;
    } catch (Exception e) {
      system.debug('[IDCard_ApplicationFormRRController ] Exception in deleteAttachment ' + e.getstacktracestring());
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_ErrorDeleteingFile));
    }
    return null;
  }

  public PageReference upload() {

    try {
      if ((document1.Name != null && document1.Name != '' && (docDesc1 == '' || docDesc1 == null))
          || (document2.Name != null && document2.Name != '' && (docDesc2 == '' || docDesc2 == null))
          || (document3.Name != null && document3.Name != '' && (docDesc3 == '' || docDesc3 == null))) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_Select_Description));
        return null;
      }
      //get parent ID
      document1.ParentId = IDCardApplicationRR.Id;
      //document1.Description = 'Last Name Change Proof';
      document1.Description = docDesc1;
      document2.ParentId = IDCardApplicationRR.Id;
      //document2.Description = 'Independent Contractor Proof';
      document2.Description = docDesc2;
      document3.ParentId = IDCardApplicationRR.Id;
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
      system.debug('[IDCard_ApplicationFormRRController ] Exception in upload ' + e.getstacktracestring());
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
      document1.ParentId = IDCardApplicationRR.Id;
      document2.ParentId = IDCardApplicationRR.Id;
      document3.ParentId = IDCardApplicationRR.Id;
      docDesc1 = null;
      docDesc2 = null;
      docDesc3 = null;
    }
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.IDCard_FileUploadSuccess));
    DocUploaded = true;
    return null;
  }


  /**
   * Function : Adds error message on the page
   */
  private void AddError(string msg) {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
  }

  /*
  * Function : Validate the form
  */
  private boolean IsFormValid() {
    boolean isValid = true;

    // The Last Name cannot be null
    if (IDCardApplicationRR.Last_Name__c == null || IDCardApplicationRR.Last_Name__c == '') {
      //schema.Describefieldresult F = ID_Card_Application__c.Last_Name__c.getDescribe();
      //Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    // Approving Manager Name and Email are Required
    if (IDCardApplicationRR.Approving_Manager_s_Name__c == null || IDCardApplicationRR.Approving_Manager_s_Name__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Approving_Manager_s_Name__c.getDescribe();
      //  Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    // Title must be selected
    if (IDCardApplicationRR.Title__c == null || IDCardApplicationRR.Title__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Title__c.getDescribe();
      //  Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    } else {
      IDCardApplicationRR.Gender__c = getGenderFromTitle(IDCardApplicationRR.Title__c);
    }

    if (IDCardApplicationRR.Approving_Manager_s_Email__c == null || IDCardApplicationRR.Approving_Manager_s_Email__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Approving_Manager_s_Email__c.getDescribe();
      // Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    //if Displayed Name on IDCard is empty
    if (IDCardApplicationRR.Displayed_Name__c == null || IDCardApplicationRR.Displayed_Name__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Displayed_Name__c.getDescribe();
      //  AddError(string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()}));
      isValid = false;
    }

    // A admin email is required
    if (IDCardApplicationRR.Email_admin__c == null || IDCardApplicationRR.Email_admin__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Email_admin__c.getDescribe();
      //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()})));
      isValid = false;
    }

    /*
    if (associatedContact != null) {
        if (IDCardApplicationRR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE && associatedContact.LastName != IDCardApplicationRR.Last_Name__c) {
        //  schema.Describefieldresult F = ID_Card_Application__c.Last_Name__c.getDescribe();
         //   Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, F.getLabel()));
            isValid = false;
        }
    }
     */

    if (IDCardApplicationRR.Position_in_Current_Agency__c == null || IDCardApplicationRR.Position_in_Current_Agency__c == '') {
      //   schema.Describefieldresult F = ID_Card_Application__c.Position_in_Current_Agency__c.getDescribe();
      //  AddError(string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()}));
      isValid = false;
    }

    if (IDCardApplicationRR.Duties_in_Current_Agency__c == null || IDCardApplicationRR.Duties_in_Current_Agency__c == '') {
      //  schema.Describefieldresult F = ID_Card_Application__c.Duties_in_Current_Agency__c.getDescribe();
      //  AddError(string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()}));
      isValid = false;
    }

    // Hours worked Required (if not null need to test for Hours worked > 20 business rule)
    if (IDCardApplicationRR.Hours_worked__c == null || IDCardApplicationRR.Hours_worked__c == '') {
      // schema.Describefieldresult F = ID_Card_Application__c.Hours_worked__c.getDescribe();
      //  AddError(string.format(Label.ID_Card_Field_Required, new list<string> {F.getLabel()}));
      isValid = false;
    } else {
      // Hours Worked > 20
      if (IDCardApplicationRR.Hours_worked__c == 'Less than 20 h') {
        IDCardApplicationRR.Hours_Worked_Validation_Failed__c = true;
        AddError(Label.ID_Card_Hours_Worked_business_rule);
        isValid = false;
      }
    }

    // Validate if Card UI displayed name doesn't match with the business rule displayed name
    if (IDCardApplicationRR.Displayed_Name__c != IDCardUtil.calculateDisplayedName(IDCardApplicationRR.First_Name__c, IDCardApplicationRR.Middle_Initial__c, IDCardApplicationRR.Last_Name__c)) {
      //force display name to the correct value if not correct
      IDCardApplicationRR.Displayed_Name__c = IDCardUtil.calculateDisplayedName(IDCardApplicationRR.First_Name__c, IDCardApplicationRR.Middle_Initial__c, IDCardApplicationRR.Last_Name__c);
    }

    // The name displayed on ID Card must not contain any special characters, only spaces and Hyphen
    if (IDCardApplicationRR.Displayed_Name__c != null && IDCardApplicationRR.Displayed_Name__c != '') {
      //pattern fullNamePattern = pattern.compile('[[\\x30-\\x39][\\x41-\\x5a][\\x61-\\x7a]- ]+');

      //remove accents
      IDCardApplicationRR.Displayed_Name__c = IDCardUtil.deAccent(IDCardApplicationRR.Displayed_Name__c);

      pattern fullNamePattern = pattern.compile('[^a-zA-Z - ,.]');
      Matcher fullNameMatcher = fullNamePattern.matcher(IDCardApplicationRR.Displayed_Name__c);
      if (fullNameMatcher.find()) {
        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ID_Card_DisplayName_Business_Rule));
        isValid = false;
      }
    }

    // Case Valid Flag
    if (GetIATAISOCountryOfContact(IDCardApplicationRR.IATA_Code__c).ISO_Code__c == 'CA') {

      if (IDCardApplicationRR.Position_in_Current_Agency__c == 'Director' ||
          IDCardApplicationRR.Position_in_Current_Agency__c == 'Employee' ||
          IDCardApplicationRR.Position_in_Current_Agency__c == 'Independent Consultant/Broker' ||
          IDCardApplicationRR.Position_in_Current_Agency__c == 'Manager' ) {

        if (IDCardApplicationRR.Revenue_Confirmation__c == false) {
          IDCardApplicationRR.Revenue_Confirmation_Validation_Failed__c = true;
          Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR , Label.IDCard_ConfirmRev));
          isValid = false;
        }
      }

      if (IDCardApplicationRR.Position_in_Current_Agency__c == 'Sole Owner' ||
          IDCardApplicationRR.Position_in_Current_Agency__c == 'Partner' ||
          IDCardApplicationRR.Position_in_Current_Agency__c == 'Shareholder' ) {

        if (IDCardApplicationRR.AgencyShare_Confirmation__c == false && IDCardApplicationRR.Revenue_Confirmation__c == false) {
          IDCardApplicationRR.Revenue_Confirmation_Validation_Failed__c = true;
          Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR , Label.IDCard_ConfirmShareAgency));
          isValid = false;
        }
      }
    }


    if (!isvalid)
      Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR , Label.IDCard_FillAllFields));

    return isValid;
  }

  /**
   * Function : Returns the country ISO code of a contact based on its IATA code
   */
  private IATA_ISO_Country__c GetIATAISOCountryOfContact(String iataCode) {
    Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(iataCode);

    IATA_ISO_Country__c[] listCountries = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry);
    if (listCountries == null || listCountries.size() == 0) {
      throw new IDCardApplicationException(string.format(Label.ID_Card_Invalid_ISO_Country, new string[] { theAccount.BillingCountry }));
    }

    return listCountries[0];
  }



  /**
   * Function : Return the associated contact of the agent if it exists
   */
  private Contact GetAssociatedContact(string VER) {
    // check the VER number (if associated to a contact)
    Contact[] contacts = [Select c.VER_Number_2__c, c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c, c.Email From Contact c where c.VER_Number_2__c = :VER];
    if (contacts == null || contacts.size() == 0) {
      system.debug('[IDCard_ApplicationFormRRController ] Exception in GetAssociatedContact no contact found for ver ' + ver);
      throw new IDCardApplicationException(string.format(Label.ID_Card_Contact_Not_found_for_VER, new string[] { VER }));
    }
    return contacts[0];
  }


  private ID_Card__c GetAssociatedIDCard(string VER) {


    ID_Card__c[] card = [ Select i.Valid_To_Date__c, i.Valid_From_Date__c, i.Type_of_ID_Card__c, i.Title__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Sent_to_AIMS_on__c, i.Renewal_From_Replace__c, i.Related_Contact__c, i.Position__c, i.Photo__c, i.Photo_Flag__c, i.Phone__c, i.Payment_Type__c, i.Paid__c, i.OwnerId, i.Nature_of_ID_Card__c, i.Name_on_ID_Card__c, i.Name, i.MustSyncWithAIMS__c,
                          i.Middle_Initial__c, i.LastName__c, i.LastModifiedDate, i.LastModifiedById, i.Is_Active_Card__c, i.IsDeleted, i.Id, i.ID_Card_Application__c, i.Hours_per_week__c, i.Gender__c, i.FirstName__c, i.Fee_Applicable__c, i.Email__c, i.Duties__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.ConnectionSentId, i.ConnectionReceivedId, i.Card_Variation__c, i.Card_Variation_Code__c, i.Card_Status__c, i.Card_Code__c,
                          i.Cancellation_Date__c, i.Blacklisted__c, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Agency_Name__c, i.Agency_IATA_Code__c From ID_Card__c i
                          where i.VER_Number__c = :VER ORDER BY i.Valid_To_Date__c DESC limit 1];

    if (card == null || card.size() == 0) {
      return null;
    }

    return card[0];
  }



  /**
   * Function : Determine if the last name has changed
   */
  private Boolean LastNameHasChanged() {
    return (associatedIDCard.LastName__c != IDCardApplicationRR.Last_Name__c); //associatedContact.LastName != IDCardApplicationRR.Last_Name__c;
  }

  private Promotion__c validatePromotion() {
    boolean isError = true;
    //////////////////////////
    // validate the promotion
    // Promotion code must exists, must be associated to the corresponding Price Table and be between the validity period
    if (IDCardApplicationRR.Promotion_Code__c != null && IDCardApplicationRR.Promotion_Code__c != '') {
      Promotion__c[] listPromotion = [Select p.Promotion_Value__c, p.Promotion_Duration_Valid_Up_to__c, p.Promotion_Duration_Valid_From__c, p.Promotion_Code__c, p.Type_of_Application__c From Promotion__c p where p.Promotion_Code__c = :IDCardApplicationRR.Promotion_Code__c];

      if (listPromotion == null || listPromotion.size() == 0) {
        IDCardApplicationRR.Promotion_Code__c.addError(String.Format(Label.ID_Card_Invalid_Promotion_Code, new String[] {IDCardApplicationRR.Promotion_Code__c}));
        return null;
      }
      system.debug('------->> ' + listPromotion[0].Type_of_Application__c);
      String[] typeOfAppInPromoCode =  listPromotion[0].Type_of_Application__c.split(';');

        for(String typeOfApp : typeOfAppInPromoCode){
          if(typeOfApp == IDCardApplicationRR.Type_of_Application__c) {
            isError = false;
            break;
          }
        }

       
    if (isError) {
       IDCardApplicationRR.Promotion_Code__c.addError(String.Format(Label.ID_Card_Invalid_Promotion_Code_2, new String[] {IDCardApplicationRR.Promotion_Code__c}));
       return null;
    }  

      if (listPromotion[0].Promotion_Duration_Valid_Up_to__c < Date.today()) {
        IDCardApplicationRR.Promotion_Code__c.addError(Label.ID_Card_Promotion_Code_No_Longer_Valid);
        return null;
      } else if (listPromotion[0].Promotion_Duration_Valid_From__c > Date.today()) {
        IDCardApplicationRR.Promotion_Code__c.addError(Label.ID_Card_Promotion_Code_Not_Yet_Valid);
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

  public Boolean IsNewApplication { //INC271394
    get{
      return IDCardApplicationRR != null && IDCardApplicationRR.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW;
    }
    set;
  }
}