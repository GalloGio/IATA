public with sharing class IDCard_AdmUserManagmentPictureCtrl extends IDCardAbstractController{

   // public Boolean DisplayExpediteFee {get; set;}
    public Boolean DisplayFees {get; set;}
    public Boolean CanRenderPage {get; set;}
    public Boolean HasNotUploadedImage {get; set;}
    public String PhotoFilename {get; set;}
    public String hiddenFilename {get; set;}
    public Boolean TermsAndConditionChecked { get; set; }     
    public String apiSessionId {get;set;}
    public Boolean IsCroppingToolDisplayed { get; set; }
    public Boolean IsViewerDisplayed { get; set; }
    public Boolean DocUploaded {get;set;}
    public decimal expediteFees{get; private set;}
    
    private String accountType; 
    private Boolean newContactRequired;
    //private String part;
    private final String sectionOne = '1';
    private final String sectionTwo = '2';
    private final String sectionThree = '3';

    public boolean operationCompleted {get;set;}

    public Boolean isPart1 { get; set; }
    public Boolean isAttachmentsNeeded { get; set; }
    public Boolean isPart2 { get; set; }
    public Boolean isPart3{ get; set; }
    public Boolean lastNameHasChanged {get;set;}
    public Boolean isContractor {get;set;}
    public Boolean isEmployee {get;set;}
    public list<SelectOption> itdiCourses;
    public String[] selectedITDICourses;
    
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
    //private Contact associatedContact {get; set;}
    private ID_Card__c associatedIDCard {get;set;}
    private Map<String, decimal> detailledFees;
    private final Blob SECURITYKEY = Blob.valueOf('IDCard_AdmUserManagmentPictureCtrl');  
    
    private boolean fromAgencyChange;
    
    public ID_Card_Application__c IDCardApplicationNR {get; set;}   
    
    private List<Attachment> docs;
    
    public String attachmentID{get;set;}  
    public boolean isLoggedUser{get;set;}
    
    /**
     * Constructor
     */
    public IDCard_AdmUserManagmentPictureCtrl() {      
        OperationCompleted = false;
       DocUploaded = false;
       IsCroppingToolDisplayed = false;
       IsViewerDisplayed = false;
       lastNameHasChanged= false;
       isContractor = false;
       isEmployee = false;
       detailledFees = new Map<String, decimal>();
       selectedITDICourses = new String[]{}; 
       
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
       
       // Check the login and get Vernumber of the keycontact
       initialize();         
       //printerr('################## vernumber = '+vernumParameter);
       //printerr('################## iatacode = '+iatacodeParameter);
       isLoggedUser = (vernumParameter!=null && vernumParameter!='');

       // I get the info about the contact for whom I'll insert the picture
       String ver = ApexPages.currentPage().getParameters().get('VER');
       try{
            ver = IDCardUtil.DecodeDecryptParameter(ver);
       }catch(Exception e){
            printerr('Invalid link '+e);
            return;
       }
       
       //knows what part of page to load
       //part = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PAGE_PART));

        try {
            List<ID_Card_Application__c> idcapps = database.query(
                        'SELECT '+TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap())+
                        ' FROM ID_Card_Application__c '+
                        ' WHERE VER_Number__c = :ver'+
                        ' AND Application_Status__c = \'Pending\' '+
                        ' LIMIT 1'
            ); 
            
            if(idcapps.size()>0){
                IDCardApplicationNR = idcapps[0];
            }else{
                Contact c = database.query(
                                  'SELECT '+TransformationHelper.getAllFields(Schema.SObjectType.Contact.fields.getMap())+
                                          ',Account.Id, Account.Type, Account.BillingCountry, Account.BillingState'+
                                  ' FROM Contact '+
                                  ' WHERE VER_Number_2__c = :ver'+
                                  ' LIMIT 1');
                
                IDCardApplicationNR = IDCardApplicationFactory.createIDCardApplication(c,'New');
                IDCardApplicationFactory.applyContactInformations(IDCardApplicationNR,c);
                
            }
               
              
            //printerr('IDCardApplicationNR.id = '+IDCardApplicationNR.id+ ' IDCardApplicationNR.Photo__c :'+IDCardApplicationNR.Photo__c);
            
            // If there's not the photo on the application I'll look for it on the id card as well
            if(IDCardApplicationNR.id == null || IDCardApplicationNR.Photo__c == null){
                idCardTemp = [Select i.Photo__c, i.ID_Card_Application__r.Displayed_Name__c From ID_Card__c i where i.Related_Contact__r.VER_Number_2__c = :ver order by i.Valid_To_Date__c desc];
                //printerr('idCardTemp.size() = '+idCardTemp.size());
                // I take the photo from Id Card
                if(idCardTemp.size() > 0 && idCardTemp[0].Photo__c!=null){
                    //PhotoFilename = idCardTemp[0].Photo__c; 14-12-2016
                    PhotoFilename = IDCardUtil.NewGuid();
                    hiddenFilename = idCardTemp[0].Photo__c;
                    IsCroppingToolDisplayed = false;
                    IsViewerDisplayed = true;
                    //printerr('idCardTemp.size() = '+idCardTemp.size());
                // I need to create a new photo
                }else{
                    PhotoFilename = IDCardUtil.NewGuid();
                    IsCroppingToolDisplayed = true;
                    IsViewerDisplayed = false;
                }
            
            }else{
                //PhotoFilename = IDCardApplicationNR.Photo__c; 14-12-2016
                PhotoFilename = IDCardUtil.NewGuid();
                hiddenFilename = IDCardApplicationNR.Photo__c;
                IsCroppingToolDisplayed = false;
                IsViewerDisplayed = true;

            }
            //printerr('IsCroppingToolDisplayed = '+IsCroppingToolDisplayed + ' IsViewerDisplayed:'+IsViewerDisplayed);
            //printerr('PhotoFilename = '+PhotoFilename + ' hiddenFilename:'+hiddenFilename);
 
            DisplayFees = true;
            newContactRequired = false;
            CanRenderPage = true;        
        }
        catch (Exception ex) {
            system.debug('########### Error : '+ex.getStackTraceString  ());
            //AddError(ex.getMessage());
            printerr(ex.getMessage() + ' - '+ex.getStackTraceString());
            CanRenderPage = false;
        }
        
        fromAgencyChange = ApexPages.currentPage().getParameters().get('fromAgencyChange')=='true';
        
    }
    
    
    public Boolean IsContactFromCanada {
         get {
            if (IDCardApplicationNR!=null &&  
                IDCardApplicationNR.IATA_Code__c != null && 
                GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c).ISO_Code__c == 'CA') 
                return true;
             return false;
                      
         }                   
    }
     
    public Boolean IsExpediteAvailable {
        get {
            
                IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c);
                Price_Table__c[] listPriceTables = [Select p.Expedite__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
                if (listPriceTables == null || listPriceTables.size() == 0) {
                    throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
                }
                else
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
                Price_Table__c[] listPriceTables = [Select p.Expedite_Delivery_added_to_IDCard_Price__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
                if (listPriceTables == null || listPriceTables.size() == 0) {
                    throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
                }
                else
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
        
    public String TermsAndConditions{
        get{
            if (GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c).ISO_Code__c == 'CA'){
                return Label.ID_Card_Terms_ConditionCA;
            }
            else{
                return Label.ID_Card_Terms_Condition;
            }
        }   
    }
    
     public String AttachmentsNeeded 
     { 
        get{
 
             if(LastNameHasChanged)
               return Label.IDCard_LastNameVerification + '<br/>'+ Label.IDCard_UploadDocs + '<br/><br/>';
            if(isContractor)   
                return Label.IDCard_ContractorVerification + '<br/>'+ Label.IDCard_UploadDocs + '<br/><br/>';
            
            if(isEmployee )   
                return Label.IDCard_Employee + '<br/>'+ Label.IDCard_UploadDocs + '<br/><br/>';
                
            if(isEmployee && LastNameHasChanged)
                return Label.IDCard_LastNameVerification + '<br/>'+ Label.IDCard_Employee + '<br/>'+ Label.IDCard_UploadDocs + '<br/><br/>';
                 
            if(LastNameHasChanged&&isContractor)
                return Label.IDCard_LastNameVerification + '<br/>'+ Label.IDCard_ContractorVerification + '<br/>'+ Label.IDCard_UploadDocs + '<br/><br/>';
            return '';
         }
        set;
    }
    
    public String PageTitle 
    {
        get{
                //Page Title
            if(IDCardApplicationNR == null || IDCardApplicationNR.Type_of_application__c == null)
                return 'NULL';
            if(IDCardApplicationNR.Type_of_application__c ==IDCardUtil.APPLICATIONTYPE_NEW)
                 return Label.ID_Card_Application_Type_New;
            if(IDCardApplicationNR.Type_of_application__c ==IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
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
       for( Schema.PicklistEntry f : ple)
       {  
          string a_Id = (f.getValue().replace(' ', '')).replace('&','');          
          SelectOption s = new SelectOption(f.getValue(), f.getLabel() + ' <a href="#" id="' + a_Id + '"><img src="/'+Label.IDCard_SiteName + question_image + '" width="20" height="20" style="vertical-align: top;"></a>');
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
    
    public void ShowHideIFrames(){
        if (IsViewerDisplayed){
            IsViewerDisplayed = false;
            IsCroppingToolDisplayed = true;
        }
    }
   
    
     private Contact GetAssociatedContact(string VER) {
        
        // check the VER number (if associated to a contact)
        Contact[] contacts = [Select c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c From Contact c where c.VER_Number__c =: Decimal.valueof(VER) limit 1];
        if (contacts == null || contacts.size() == 0) {
            throw new IDCardApplicationException(string.format(Label.ID_Card_Contact_Not_found_for_VER, new string[] { VER }));
        }
        
        return contacts[0];
    }
    
     private ID_Card__c GetAssociatedIDCard(string VER) {
        
      
        /*
        ID_Card__c[] card =[ Select i.Valid_To_Date__c, i.Valid_From_Date__c, i.Type_of_ID_Card__c, i.Title__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Sent_to_AIMS_on__c, i.Renewal_From_Replace__c, i.Related_Contact__c, i.Position__c, i.Photo__c, i.Photo_Flag__c, i.Phone__c, i.Payment_Type__c, i.Paid__c, i.OwnerId, i.Nature_of_ID_Card__c, i.Name_on_ID_Card__c, i.Name, i.MustSyncWithAIMS__c,
                i.Middle_Initial__c, i.LastName__c, i.LastModifiedDate, i.LastModifiedById, i.Is_Active_Card__c, i.IsDeleted, i.Id, i.ID_Card_Application__c, i.Hours_per_week__c, i.Gender__c, i.FirstName__c, i.Fee_Applicable__c, i.Email__c, i.Duties__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Card_Variation__c, i.Card_Variation_Code__c, i.Card_Status__c, i.Card_Code__c,
                 i.Cancellation_Date__c, i.Blacklisted__c, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Agency_Name__c, i.Agency_IATA_Code__c From ID_Card__c i
                 where i.VER_Number__c =: VER and (i.Card_Status__c =: IDCardUtil.CARDSTATUS_PRINTED_DELIVERED or i.Card_Status__c =:IDCardUtil.CARDSTATUS_APPROVED or i.Card_Status__c =: IDCardUtil.CARDSTATUS_CANCELED ) ORDER BY i.Valid_To_Date__c DESC limit 1];  
        */
        
        // Kofi: 12/09/2013. Card_Status__c is removed from the criteria.
        
        ID_Card__c[] card =[ Select i.Valid_To_Date__c, i.Valid_From_Date__c, i.Type_of_ID_Card__c, i.Title__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Sent_to_AIMS_on__c, i.Renewal_From_Replace__c, i.Related_Contact__c, i.Position__c, i.Photo__c, i.Photo_Flag__c, i.Phone__c, i.Payment_Type__c, i.Paid__c, i.OwnerId, i.Nature_of_ID_Card__c, i.Name_on_ID_Card__c, i.Name, i.MustSyncWithAIMS__c,
                i.Middle_Initial__c, i.LastName__c, i.LastModifiedDate, i.LastModifiedById, i.Is_Active_Card__c, i.IsDeleted, i.Id, i.ID_Card_Application__c, i.Hours_per_week__c, i.Gender__c, i.FirstName__c, i.Fee_Applicable__c, i.Email__c, i.Duties__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Card_Variation__c, i.Card_Variation_Code__c, i.Card_Status__c, i.Card_Code__c,
                 i.Cancellation_Date__c, i.Blacklisted__c, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Agency_Name__c, i.Agency_IATA_Code__c From ID_Card__c i
                 where i.VER_Number__c =: VER  ORDER BY i.Valid_To_Date__c DESC limit 1];  
                 
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
                Account theAccount = [Select a.IATACode__c, a.type, a.BillingCountry From Account a where a.RecordType.Name = 'Agency' AND a.IATACode__c =: IDCardApplicationNR.IATA_Code__c limit 1];
                if (theAccount == null)
                        throw new IDCardApplicationException(string.format(Label.ID_Card_Account_Not_Found,new String[]{IDCardApplicationNR.IATA_Code__c}));

                // Map the account agent type to the Price Table agent type
                accountType = IDCardUtil.GetAgentTypeFromAccountType(theAccount.type);
                
                // get the Price Table based on the country and on the type of agent
                IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IDCardApplicationNR.IATA_Code__c);
                Price_Table__c[] listPriceTables = [Select p.Type_Class_of_Agent__c, p.Expedite__c, p.CurrencyIsoCode, p.Name From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
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
                if(selectedITDICourses != null) {
                    if (selectedITDICourses.size() == 1)
                        IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c = selectedITDICourses[0];
                    if (selectedITDICourses.size() >= 2) {                    
                        IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c = selectedITDICourses[0];
                        IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c = selectedITDICourses[1];
                    }
                                   
                }
                
                              
                Boolean isITDIPackage = selectedITDICourses.size()>0 ;//IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c != null || IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c != null;                
                detailledFees = IDCardUtil.GetDetailledFees(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);
                IDCardApplicationNR.ID_Card_Fee__c = detailledFees.get('IDCardFee');
                IDCardApplicationNR.IDCard_Expedite_Delivery_Fee__c = detailledFees.get('ExpediteFee');         
                IDCardApplicationNR.ITDI_Courses_Fee__c = detailledFees.get('ITDIFee');                
                IDCardApplicationNR.Applicable_Fee__c = IDCardUtil.GetApplicableFee(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);                               
                IDCardApplicationNR.CurrencyIsoCode = listPriceTables[0].CurrencyIsoCode;
                // Always display the expedite fees
                expediteFees = listPriceTables[0].Expedite__c;
                DisplayFees = true;                
                //DisplayExpediteFee = true;
                
                
        }
        catch (Exception ex) {
                AddError(ex.getMessage());
        }
    }
    
    public void FillContactFieldsForReplacement() {
        
        //Double dVERNumber;
        String dVERNumber = IDCardApplicationNR.VER_Number__c;
        
        try {
                
            
               //RA: 7/10/2013 USE Last IDCard Values instead of Contact
               
                associatedIDCard = GetAssociatedIDCard(dVERNumber);
               
                if(associatedIDCard !=null )
                {
                             
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
                System.debug('*** IsCroppingToolDisplayed '+IsCroppingToolDisplayed + ' IsViewerDisplayed  '+IsViewerDisplayed);
                
                                
        }
        catch (Exception ex) {              
                          
                System.debug('** EXCEPTION'+ ex);
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
        try {
                if(hiddenFilename == '')
                {
                    HasNotUploadedImage = true;
                    AddError(Label.IDCard_UploadImage);
                    return null;
                }    
                else
                    IDCardApplicationNR.Photo__c = hiddenFilename; 
                           
                //save image name
                IDCardApplicationNR.IDCard_Prefered_Language__c = Language;
                upsert IDCardApplicationNR;
        system.debug('---------------------------- TEST IDCardApplicationNR-> Id = '+IDCardApplicationNR.id+' -  photo = '+IDCardApplicationNR.photo__c);

        // Constantin - 12.12.2016 - removed, no longer needed; the new cropping tool keeps the existing filename (UIR.jpg)
        //IDCardUtil.renameIDCardPhotoOfContact(IDCardApplicationNR.ID, IDCardApplicationNR.UIR__c,Userinfo.getSessionId());   // rename photo to its old name

                if(isLoggedUser!=true){
                    operationCompleted = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your picture was successfully update.'));
                    return null;
                }
                if(fromAgencyChange)
                  return new PageReference(pagesurl.get('prefix')+'/IDCard_AdmUserManagmentAgencyChange?ImagedSaved='+IDCardApplicationNR.id);
                return new PageReference(pagesurl.get('prefix')+'/IDCard_AdmUserForm?ver='+IDCardApplicationNR.VER_Number__c);
            
        }
        catch (Exception ex) {
            AddError(ex.getMessage());

        }
        return null;
    }
    
   public Pagereference back() {     
           return new PageReference(pagesurl.get('prefix')+'/IDCard_AdmUserForm?ver='+IDCardApplicationNR.VER_Number__c);
   }
   
    

    /**
     * Returns the country ISO code of a contact based on its IATA code
     */
    private IATA_ISO_Country__c GetIATAISOCountryOfContact(String iataCode) {
        
        Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(iataCode);
        
        IATA_ISO_Country__c[] listCountries = [Select i.Name, i.AIMS_Area_Name__c, i.Id, i.ISO_Code__c, IATA_Regional_Office__c From IATA_ISO_Country__c i where i.AIMS_Area_Name__c = :theAccount.BillingCountry];
        if (listCountries == null || listCountries.size() == 0) {
                throw new IDCardApplicationException(string.format(Label.ID_Card_Invalid_ISO_Country, new string[] { theAccount.BillingCountry }));
        }
        
        return listCountries[0];
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
  
   private  String getResourceURL(String resourceName)  
    {  
        //Fetching the resource  
        list<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];  
                              
        //Checking if the result is returned or not  
        if(resourceList.size() == 1)  
        {  
           //Getting namespace  
           String namespace = resourceList[0].NamespacePrefix;  
           //Resource URL  
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName;   
        }  
        else return '';  
    }
    
    private String getGenderFromTitle(String titleSelected) {        
        if (titleSelected.equalsIgnoreCase('Mr'))
            return 'Male';
        if (titleSelected.equalsIgnoreCase('Ms') || titleSelected.equalsIgnoreCase('Mrs'))
            return 'Female';            
        return '';
    }
    public void printErr(String message){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));
    }    
}