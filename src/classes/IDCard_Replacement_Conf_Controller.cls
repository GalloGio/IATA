public with sharing class IDCard_Replacement_Conf_Controller {

    public String Language { get; set; }
    
    
    public Date ExpDate{get;set;}
    public Date expDateReplacement {get;set;}
    public Date expDateRenewal {get;set;}
    public String cardPriceRenewal {get;set;}
    public String cardPriceReplacement {get;set;}
    
    
    private String IATA_Code;
    private String applicationId;
    private String type_Application;
    private String verNumber;
    private Account theAccount;
    

    private static String IDCARD_PORTAL_LANG = 'idcard_portal_lang';

    private String selectedLanguage;
    public String getSelectedLanguage() {
        return selectedLanguage;
    }
    public void setSelectedLanguage(String s) {
        selectedLanguage = s;
    }
    
    private boolean hasError = false;
    public boolean getHasError() {
        return hasError;
    }
    
    private string errMsg = '';
    public string getErrMsg() {
        return errMsg;
    }
    
    private string applicationType = '';
    private string iataCode = '';
    
    private string ver = '';
    
    public List<SelectOption> getLangItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('en_US','English'));
        options.add(new SelectOption('es','Español'));
        options.add(new SelectOption('fr','Français'));
        return options;
    }
    
    /**
     * Constructor
     */
    public IDCard_Replacement_Conf_Controller() {

        
        
        try {
            // check to see if the language was stored in a cookie
            Cookie langCookie = ApexPages.currentPage().getCookies().get(IDCARD_PORTAL_LANG);
            if (langCookie == null) {
                // ?
                Language = 'en_US';
                selectedLanguage = Language;
                //selectedLanguage = null;
            }
            else {
                Language = langCookie.getValue();
                selectedLanguage = Language;
            }    
            
            
            
            applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));
            IATA_Code = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
            type_Application = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPLICATIONTYPE));
            if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_VER))
                verNumber = IDCardUtil.DecodeDecryptParameter(apexpages.currentpage().getparameters().get(IDCardUtil.PARAM_VER));
            else
                verNumber = '';
                 
            verNumber = verNumber.trim();   
            
            
            //set values
            ID_Card__c tempIDCard = GetAssociatedIDCard(verNumber);
            ExpDate = tempIDCard.Valid_To_Date__c;
            expDateReplacement = ExpDate;
           
           // expDateRenewal = Date.Today().addYears(1);//ExpDate.addYears(1);
           // Expiration date should always be shown as last day of the month
            Date firstDayOfMonth = System.today().addYears(1).toStartOfMonth();
            Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
            expDateRenewal = lastDayOfMonth;
            
            theAccount = IDCardUtil.GetAccountObjectFromIATACode(IATA_Code);
            
            // get the Price Table based on the country and on the type of agent
                IATA_ISO_Country__c contactCountry = GetIATAISOCountryOfContact(IATA_Code);
                String accountType = IDCardUtil.GetAgentTypeFromAccountType(theAccount.Type);
                Price_Table__c[] listPriceTables = [Select p.ID_Card_Fee__c, p.CurrencyIsoCode, p.Type_Class_of_Agent__c, p.Expedite__c, p.Name From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
                if (listPriceTables == null || listPriceTables.size() == 0) {
                        throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + theAccount.Type + '</i>'}));
                }    
            
            cardPriceRenewal = String.ValueOf(IDCardUtil.GetApplicableFee(listPriceTables[0], false, false, false, null)) + '   ' + listPriceTables[0].CurrencyIsoCode; 
            cardPriceReplacement = String.ValueOf(IDCardUtil.GetApplicableFee(listPriceTables[0], true, false, false, null)) + '   ' + listPriceTables[0].CurrencyIsoCode;
                      
            
            
        
        }
        catch (Exception ex) {
            cardPriceReplacement = ex.getMessage();
            cardPriceRenewal = verNumber;
        }
    }
    
   
    public Pagereference Renew() {
   
    
            Pagereference prApplicationForm = null;         
            
            
            prApplicationForm = Page.IDCard_Checklist;  //Page.IDCard_ApplicationForm_RR; 
                    
             if (verNumber != '')
                prApplicationForm.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));
                            
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(applicationId));        
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATA_Code));     
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_RENEWAL));                 
            prApplicationForm.getParameters().put(IDCardUtil.PAGE_PART,IDCardUtil.EncryptEncodeParameter('1'));
            
            prApplicationForm.setRedirect(true); 
                    
            return prApplicationForm;

        
   }
   
   
       public Pagereference Replace() {
   
            Pagereference prApplicationForm = null;         
            
            
            prApplicationForm = Page.IDCard_Checklist;  //Page.IDCard_ApplicationForm_RR; 
                    
                    
             if (verNumber != '')
                prApplicationForm.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));
                            
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(applicationId));        
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATA_Code));     
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REISSUE));                 
            prApplicationForm.getParameters().put(IDCardUtil.PAGE_PART,IDCardUtil.EncryptEncodeParameter('1'));
            
            prApplicationForm.setRedirect(true); 
                    
            return prApplicationForm;


        }
        
        
        private ID_Card__c GetAssociatedIDCard(string VER) {
        
        
            ID_Card__c[] card =[ Select i.Valid_To_Date__c, i.Valid_From_Date__c, i.Type_of_ID_Card__c, i.Title__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Sent_to_AIMS_on__c, i.Renewal_From_Replace__c, i.Related_Contact__c, i.Position__c, i.Photo__c, i.Photo_Flag__c, i.Phone__c, i.Payment_Type__c, i.Paid__c, i.OwnerId, i.Nature_of_ID_Card__c, i.Name_on_ID_Card__c, i.Name, i.MustSyncWithAIMS__c,
                    i.Middle_Initial__c, i.LastName__c, i.LastModifiedDate, i.LastModifiedById, i.Is_Active_Card__c, i.IsDeleted, i.Id, i.ID_Card_Application__c, i.Hours_per_week__c, i.Gender__c, i.FirstName__c, i.Fee_Applicable__c, i.Email__c, i.Duties__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Card_Variation__c, i.Card_Variation_Code__c, i.Card_Status__c, i.Card_Code__c,
                     i.Cancellation_Date__c, i.Blacklisted__c, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Agency_Name__c, i.Agency_IATA_Code__c From ID_Card__c i
                     where i.VER_Number__c =: VER and i.Card_Status__c =:IDCardUtil.CARDSTATUS_VALID ORDER BY i.Valid_To_Date__c DESC limit 1];  
          
           
           /*
           // Kofi: 12/09/2013. Card_Status__c is removed from the criteria.
           ID_Card__c[] card =[ Select i.Valid_To_Date__c, i.Valid_From_Date__c, i.Type_of_ID_Card__c, i.Title__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Sent_to_AIMS_on__c, i.Renewal_From_Replace__c, i.Related_Contact__c, i.Position__c, i.Photo__c, i.Photo_Flag__c, i.Phone__c, i.Payment_Type__c, i.Paid__c, i.OwnerId, i.Nature_of_ID_Card__c, i.Name_on_ID_Card__c, i.Name, i.MustSyncWithAIMS__c,
                    i.Middle_Initial__c, i.LastName__c, i.LastModifiedDate, i.LastModifiedById, i.Is_Active_Card__c, i.IsDeleted, i.Id, i.ID_Card_Application__c, i.Hours_per_week__c, i.Gender__c, i.FirstName__c, i.Fee_Applicable__c, i.Email__c, i.Duties__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Card_Variation__c, i.Card_Variation_Code__c, i.Card_Status__c, i.Card_Code__c,
                     i.Cancellation_Date__c, i.Blacklisted__c, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Agency_Name__c, i.Agency_IATA_Code__c From ID_Card__c i
                     where i.VER_Number__c =: VER ORDER BY i.Valid_To_Date__c DESC limit 1];  
           */          
                             
           if (card == null || card.size() == 0) {
                return null;
            }
            
            return card[0];
        }
        private IATA_ISO_Country__c GetIATAISOCountryOfContact(String iataCode) {
           
            IATA_ISO_Country__c[] listCountries = [Select i.Name, i.Id, i.ISO_Code__c, i.IATA_Regional_Office__c,i.AIMS_Area_Name__c From IATA_ISO_Country__c i where i.AIMS_Area_Name__c = :theAccount.BillingCountry];
            if (listCountries == null || listCountries.size() == 0) {
                    throw new IDCardApplicationException(string.format(Label.ID_Card_Invalid_ISO_Country, new string[] { theAccount.BillingCountry }));
            }
            
            return listCountries[0];
        }
        
        
     public Pagereference back() {

            Pagereference confPage = Page.IDCard_Portal;
            confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(applicationId));        
            confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATA_Code));     
            confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(type_Application));
            if (type_Application != IDCardUtil.APPLICATIONTYPE_NEW)
                confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));
            confPage.getParameters().put(IDCardUtil.PAGE_PART,IDCardUtil.EncryptEncodeParameter('1'));
            confPage.getParameters().put(IDCardUtil.PARAM_APPID,IDCardUtil.EncryptEncodeParameter(applicationId));
            confPage.setRedirect(true);
            return confPage;
                       
   }
      
   
   
}