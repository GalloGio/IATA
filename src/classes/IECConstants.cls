/**  
  * Description: This class contains all constants used all around the IEC project 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
global class IECConstants {

  //Order Status : add by CGI - David D 2015-10-16
  public static final String ORDER_STATUS_NEW       =  'New';
  public static final String ORDER_STATUS_CANCELLED       =  'Cancelled';
  public static final String ORDER_STATUS_PAID       =  'Paid';//Used for credit card only
  public static final String ORDER_STATUS_READY_FOR_SAP   =   'Ready for SAP';
  public static final String ORDER_STATUS_CREDIT_CARD_DEFERRED = 'Credit Card Deferred';
  public static final String ORDER_STATUS_CHECK = 'Check';
  public static final String ORDER_STATUS_PENDING_PAYMENT = 'Pending Payment';
  public static final String ORDER_STATUS_PAYMENT_FAILURE = 'Payment Failure';
  public static final String ORDER_STATUS_INVOICED = 'Invoiced';
  //Orders Types
  public static final String ORDER_TYPE_QUOTE = 'Quote';
  public static final String ORDER_TYPE_RENEWAL_NOTIFICATION = 'Renewal Notification';
  public static final String ORDER_TYPE_AUTORENEWAL = 'Subscription'; //Event Auto-Renew
  public static final String ORDER_TYPE_HISTORY = 'History';
  public static final String ORDER_TYPE_CART = 'Cart';
  //Used to fetch orders that are not expired
  public static final List<String> expiredStatus = new List<String>{ORDER_STATUS_CANCELLED};
  public static final List<String> expiredStatusForOrderHistory = new List<String>{ORDER_STATUS_CANCELLED, ORDER_STATUS_NEW, ORDER_STATUS_PENDING_PAYMENT,ORDER_STATUS_PAYMENT_FAILURE,ORDER_STATUS_READY_FOR_SAP};
  public static final List<String> expiredTypes = new List<String>{ORDER_TYPE_RENEWAL_NOTIFICATION, ORDER_TYPE_QUOTE, ORDER_TYPE_CART, ORDER_TYPE_HISTORY};


  public static final String ORDER_PAYMENT_CONFIRMED = 'Payment Confirmed';//Used for bank transfer

  // Zuora Payment Method
  public static final String ZUORA_PAYMENT_METHOD_PREFIX_CREDIT_CARD = 'Credit Card';

  // GET parameters constants
  public static final string PARAM_PRODUCT_CODE =     'ProductCode';
  public static final string PARAM_RATEPLAN_ID =       'rpid';
  public static final string PARAM_RATEPLANINFO_ID =    'rpiid';
  public static final string PARAM_PRODINFO_ID =      'piid';
  public static final string PARAM_RETURN_URL =       'returl';
  public static final string PARAM_WARNING_MSG =       'warnmsg';
  public static final string PARAM_SHOW_REGISTER_LINK  =  'registerLink';
  public static final string PARAM_SUBSCRIPTION_ID =    'subid';
  public static final string PARAM_SUBSCRIPTION_NAME =  'subname';
  public static final string PARAM_INVOICE_ID =       'invid';
  public static final string PARAM_PAYMENT_ID =       'payid';
  public static final string PARAM_RESETPASSWORD =    'respw';
  public static final string PARAM_APPFILTER_ID =      'appfid';
  public static final string PARAM_LIMITTOIDS =      'limittoids'; // Added by Mathieu Beausoleil
  public static final string PARAM_UTM =              'utm_';
  
  //Get customer types constants
  public static final string PARAM_CUSTOMERTYPE_AIRLINE =     'Airline';
  public static final string PARAM_CUSTOMERTYPE_NONAIRLINE =    'Non Airline Supplier';
  public static final string PARAM_CUSTOMERTYPE_AGENCY =       'IATA Agency';
  public static final string PARAM_CUSTOMERTYPE_NONIATAAGENCY =   'Non IATA Agency';
  public static final string PARAM_CUSTOMERTYPE_GAS =       'GAS';
  public static final string PARAM_CUSTOMERTYPE_PARTNER =     'Partner';
  public static final string PARAM_CUSTOMERTYPE_OTHER =       'Other';
  public static final string PARAM_CUSTOMERTYPE_DEFAULT = 'Non-member';  //*** (Thai 2016-09-01) added

    //Params to defin elements to be shown on Maps
    public static final string PARAM_SHOWMAPSAGENCIES =             'sa';
    public static final string PARAM_SHOWMAPSEMAILS =               'se';
    public static final string PARAM_SHOWMAPSFLAGS =                'sf';

  //Locations constants
  public static final string SHIPTO = 'Ship To';
  public static final string BILLTO = 'Bill To';
  public static final string SOLDTO = 'Sold To';
  
  // Custom Labels: Error
  public static string Error_InvalidProductCode = Label.IEC_Error_InvalidProductCode;
  public static string Error_InvalidRatePlanId = Label.IEC_Error_InvalidRatePlanId;
  public static string Error_InvalidClientType = Label.IEC_Error_InvalidClientType;
  public static string Error_InvalidPageParameter = Label.IEC_Error_InvalidPageParameter;
  public static string Error_AcceptTermAndCondition = Label.IEC_Error_AcceptTermAndCondition;
  public static string Error_TrialConsumed = Label.IEC_Error_TrialConsumed;
  public static string Error_MustLogin = Label.IEC_Error_MustLogin;
  public static string Error_ICHCodeNotAvailable = Label.IEC_Error_ICHCodeNotAvailable;
  
    //New Self Register Contact Status
    public final static string NEW_CONTACT_STATUS =     'Privilege - Pending Approval';
    public final static string PENDING_APPROVAL_STATUS =  'Privilege - Pending Approval';
    public final static string PENDING_LOGIN_STATUS =     'Privilege - Pending Login';
    public final static string APPROVED_CONTACT_STATUS =   'Privilege - Approved';  
    public final static string NO_PRIVILEGE_STATUS =     'No Privilege';  
  
  // Account - Record types
  public final static string Account_RecordType_Standard = 'Standard_Account';
  public final static string Account_RecordType_Airline = 'IATA_Airline'; // (headquarter)
  public final static string Account_RecordType_BranchAirline = 'IATA_Airline_BR';
  public final static string Account_RecordType_Agency = 'IATA_Agency';
  public final static string Account_RecordType_GSA = 'IATA_GSA';
  public final static string Account_RecordType_Others = 'Others';
  
  // Account - Industry
  public final static string Account_Industry_Airline = 'Airline';
  
  // Opportunity - StageName
  public final static string Opportunity_StageName_NeedsAssessment = '3. Needs Assessment';
  
  // Opportunity - Type
  public final static string Opportunity_Type_NewCustomerSale = 'New Customer Sale';
  
  // Quote - Subscription Type
  public final static string Quote_SubscriptionType_NewSubscription = 'New Subscription';
  
  // Account - Membership status
  public final static string Account_MembershipStatus_IATAMember = 'IATA member';
  
  // Custom Labels: Trial Request
  public static string Trial_RequestSucceed = Label.IEC_Trial_RequestSucceed;
  public static string Trial_RequestFail = Label.IEC_Trial_RequestFail;
  
  // Quote.Quote_Validation_Status__c picklist values
  public static final string Quote_ValidationStatus_Confirmed = 'Confirmed';
  public static final string Quote_ValidationStatus_ValidationRequired = 'Validation Required';
  
  // Account.Client_Type__c picklist values
  public static final string Account_ClientType_MemberAirline = 'Member Airline';
  public static final string Account_ClientType_ThirdParty = 'Third Party';
  
  // Product_Category__c.Button_Type__c picklist values
  public static final string ProductCategory_ButtonType_GetAQuote = 'Get a Quote';
  public static final string ProductCategory_ButtonType_BuyNow = 'Buy Now';
  public static final string ProductCategory_ButtonType_BuyQuote = 'Buy/Quote';

  // Product Audience in Zuora (equivalent to ClientType in SalesForce)
  public static final string ProductAudience_Zuora_ALL = 'All';
  public static final string ProductAudience_Zuora_MEMBERAIRLINE = 'Member Airline';
  public static final string ProductAudience_Zuora_NONMEMBERSINGLE = 'Non-Member Single';
  public static final string ProductAudience_Zuora_NONMEMBERGDS = 'Non-Member GDS';
  public static final string ProductAudience_Zuora_NONMEMBERPROCESSOR = 'Non-Member Processor';
  public static final string ProductAudience_Zuora_NONMEMBERFRANCHISE = 'Non-Member Franchise';
  
  // Product Information Audience in SalesForce
  public static final string ProductInformationAudience_DEFAULT = 'Default';
  public static final string ProductInformationAudience_MEMBERAIRLINE = 'Member Airline';
  public static final string ProductInformationAudience_IATAEMPLOYEE = 'IATA Employee';
  public static final string ProductInformationAudience_STRATEGICMEMBER = 'Strategic Member';
  public static final string ProductInformationAudience_NonMember = 'Non Member';

  // Product Category SF codes
  public static final string ProductCategory_SF_CACFREE = 'CACFREE';
  public static final string ProductCategory_SF_CACPRO = 'CACPRO';
  public static final string ProductCategory_SF_CACWEB = 'CACWEB';
  public static final string ProductCategory_SF_PAL = 'PAL';
  public static final string ProductCategory_SF_CAL = 'CAL';
  public static final string ProductCategory_SF_ASL = 'ASL';
  public static final string ProductCategory_SF_GSS = 'GSS';
  public static final string ProductCategory_SF_MDP = 'MDP';
  public static final string ProductCategory_SF_GAD = 'GAD';
  public static final string ProductCategory_SF_EBROADCAST = 'EBC';
  public static final string ProductCategory_SF_TEST = 'PCTST';
  
  
  // Product Category Feature
  public static final string ProductCategoryFeature_DATA = 'Data';
  public static final string ProductCategoryFeature_LOOKUP = 'Lookup';
  public static final string ProductCategoryFeature_MARKETING = 'Marketing';
  
  // Product Category in Zuora
  public static final string ProductCategory_Zuora_CAC = 'CheckACode Professional';
  public static final string ProductCategory_Zuora_CACWEB = 'CheckACode Web Service';    
  public static final string ProductCategory_Zuora_GSS = 'Global System Solutions';
  public static final string ProductCategory_Zuora_MDP = 'Marketing Data Package';
  public static final string ProductCategory_Zuora_GAD = 'Global Agency Directory';
  public static final string ProductCategory_Zuora_DONOTDISPLAY = 'DO NOT DISPLAY';
  
  // Product Rate Plan IsTriable__c picklist values
  public static final string ProductRatePlanIsTriable_YES = 'Yes';
  public static final string ProductRatePlanIsTriable_NO = 'No';
  
  // Charge Models in Zuora
  public static final string ChargeModel_Zuora_FlatFeePricing = 'Flat Fee Pricing';
  public static final string ChargeModel_Zuora_PerUnitPricing = 'Per Unit Pricing';
  public static final string ChargeModel_Zuora_VolumePricing = 'Volume Pricing';
  public static final string ChargeModel_Zuora_TieredPricing = 'Tiered Pricing';
  public static final string ChargeModel_Zuora_DiscountFixedAmount = 'Discount-Fixed Amount';
  public static final string ChargeModel_Zuora_DiscountPercentage = 'Discount-Percentage';
  
  // Payment types (matches IEC_Payment_Threshold__c.Payment_Type__c)
  public static final string PaymentThresholdType_CreditCard = 'Credit Card';
  public static final string PaymentThresholdType_BankTransfer = 'Bank Transfer';
  public static final string PaymentThresholdType_ICH = 'ICH';
  public static final string PaymentThresholdType_BillMeLater = 'Bill me later';
  
  // Swap types (swap, upgrade, suggestions)
  public static final string SwappingType_Swap = 'Swap';
  public static final string SwappingType_Upgrade = 'Upgrade';
  public static final string SwappingType_Suggestion = 'Suggestion';
  
  // Email templates used for the email notification object
  public static final string Email_Template_Order = 'IEC_Order_Confirmation';
  public static final string Email_Template_GDPError = 'IEC_GDP_Replicate_Error';
  
  // Refers to the IECAddress.Address_Type__c picklist values
  public static final String IECAddress_AddressType_Billing = 'Bill To';    //*** changed by Thai (2016-02-26) from "Billing"
  public static final String IECAddress_AddressType_Shipping = 'Ship To';   //*** changed by Thai (2016-02-26) from "Shipping"
  
  // IEC_SAP_Invoice__c.Status__c picklist values
  public static final String IECSAPInvoice_Status_New = 'New';
  //public static final String IECSAPInvoice_Status_SAPReady = 'SAP Ready'; // no longer valid
  public static final String IECSAPInvoice_Status_SentToSAP = 'Sent to SAP';
  public static final String IECSAPInvoice_Status_SAPPaymentConfirmationReceived = 'SAP Payment Confirmation Received';
  public static final String IECSAPInvoice_Status_ZuoraReady = 'Zuora Ready';
  public static final String IECSAPInvoice_Status_SentToZuora = 'Sent to Zuora';
  public static final String IECSAPInvoice_Status_ValidationError = 'Validation Error';
  public static final String IECSAPInvoice_Status_SAPError = 'SAP Error';
  public static final String IECSAPInvoice_Status_ZuoraError = 'Zuora Error';
  
  // IEC_SAP_Invoice_Items__c.Status__c picklist values
  public static final String IECSAPInvoiceItem_Status_New = 'New';
  //public static final String IECSAPInvoiceItem_Status_SAPReady = 'SAP Ready'; // no longer valid
  public static final String IECSAPInvoiceItem_Status_SentToSAP = 'Sent to SAP';
  public static final String IECSAPInvoiceItem_Status_ValidationError = 'Validation Error';
  public static final String IECSAPInvoiceItem_Status_SAPError = 'SAP Error';
  
  // SAP Account Bill-To Invoice Type
  public static final String SAPAccount_InvoiceType_Invoices = 'e-Commerce';
  
  // IEC Usage Tracker Search Target
  public static final String IECUsageTrackerSearchTarget_Agent = 'Agent';
  public static final String IECUsageTrackerSearchTarget_Agency = 'Agency';
  
  // IEC Usage Tracker Search Status
  //public static final String IECUsageTrackerSearchStatus_Success = 'Success';
  //public static final String IECUsageTrackerSearchStatus_Fail = 'Fail';
  public static final String IECUsageTrackerSearchStatus_Success = 'Valid';
  public static final String IECUsageTrackerSearchStatus_Fail = 'Invalid';
  
  // ID Card status
  public static final String ID_Card_Status_Preapproved = 'Preapproved';
  public static final String ID_Card_Status_Approved = 'Approved';
  public static final String ID_Card_Status_PrintedDelivered = 'Printed/Delivered';
  public static final String ID_Card_Status_Cancelled = 'Cancelled';
  public static final String ID_Card_Status_Valid_ID_Card = 'Valid ID Card';
  public static final String ID_Card_Status_Sent_ID_Card = 'Sent ID Card';
  
  public enum PaymentType {BANK_TRANSFER, ICH, CREDIT_CARD, CHECK, OTHER}
  
  public enum GADAgencyNameSearchBy {TradingName, LegalName, Both}
  public enum GADSearchType {ExactMatch, StartsWith, Contains}
  
  public static String ENCRYPTION_ALGORYTHM {
    get {
      return Test.isRunningTest() ? 'AES128' : IEC_Settings__c.getOrgDefaults().Encryption_Algorythm__c;
    }
  }
  
  public static String ENCRYPTION_KEY {
    get {
      return Test.isRunningTest() ? 'Kg0m2vAj4VmBBviGAUehrw==' : IEC_Settings__c.getOrgDefaults().Encryption_Key__c;
    }
  }
  
  public static String PaymentMethod_ICH_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().PaymentMethod_ICH_Zuora_ID__c;
    }
  }
  
  public static String PaymentMethod_BankTransfer_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().PaymentMethod_Bank_Transfer_Zuora_ID__c;
    }
  }
  
  public static String PaymentMethod_Other_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().PaymentMethod_Other_Zuora_ID__c;
    }
  }
  
  public static String InvoiceTemplate_Bank_Transfer_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().InvoiceTemplate_Bank_Transfer_Zuora_ID__c;
    }
  }

  public static String PaymentMethod_Check_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().PaymentMethod_Check_Zuora_ID__c;
    }
  }
  
  public static String InvoiceTemplate_Check_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().InvoiceTemplate_Check_Zuora_ID__c;
    }
  }
  
  public static String InvoiceTemplate_Credit_Card_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().InvoiceTemplate_Credit_Card_Zuora_ID__c;
    }
  }
  
  public static String InvoiceTemplate_Other_ZuoraID {
    get {
      return IEC_Settings__c.getOrgDefaults().InvoiceTemplate_Other_Zuora_ID__c;
    }
  }
  
  /**
   * Maps the Product Category code configured in SalesForce to the one configured in Zuora (up to today, they don't match)
   * @param sSFProductCategoryCode The SalesForce Product Category code
   * @return The corresponding Zuora Production Category 
   */
  public static string mapSFProductCategoryToZuora(string sSFProductCategoryCode) {
    if (sSFProductCategoryCode == null || sSFProductCategoryCode == '')
      return null;
    else if (sSFProductCategoryCode == ProductCategory_SF_CACPRO || sSFProductCategoryCode == 'CAC')
      return ProductCategory_Zuora_CAC;  // TODO: MAYBE UPDATE TO NEW CATEGORY (CAC WEB DOES NOT EXIST YET IN ZUORA)
    else if (sSFProductCategoryCode == ProductCategory_SF_CACWEB)
      return ProductCategory_Zuora_CAC;
    else if (sSFProductCategoryCode == ProductCategory_SF_GSS)
      return ProductCategory_Zuora_GSS;
    else if (sSFProductCategoryCode == ProductCategory_SF_MDP)
      return ProductCategory_Zuora_MDP;
    else if (sSFProductCategoryCode == ProductCategory_SF_GAD)
      return ProductCategory_Zuora_GAD;
    else
      return null;
  }
  
  /**
   * Returns true if the string corresponds to a Zuora ProductCategory
   */
  public static boolean isZuoraProductCategory(string sProductCategory) {
    return (sProductCategory == ProductCategory_Zuora_CAC
        || sProductCategory == ProductCategory_Zuora_GSS
        || sProductCategory == ProductCategory_Zuora_MDP
        || sProductCategory == ProductCategory_Zuora_GAD
        || sProductCategory == ProductCategory_Zuora_DONOTDISPLAY);
  }
  
  /**
   * Returns true if the string corresponds to a SF Product Category Code
   */
  public static boolean isProductCategoryCode(string sProductCategoryCode) {
    return (sProductCategoryCode == ProductCategory_SF_CACPRO
        || sProductCategoryCode == ProductCategory_SF_CACWEB
        || sProductCategoryCode == ProductCategory_SF_GSS
        || sProductCategoryCode == ProductCategory_SF_MDP
        || sProductCategoryCode == ProductCategory_SF_GAD
        || sProductCategoryCode == ProductCategory_SF_EBROADCAST
        || sProductCategoryCode == ProductCategory_SF_TEST);
  }
  
  /**
   * Returns true if the string corresponds to a SF Client type
   */
  public static boolean isClientType(string sClientType) {
    return (sClientType == Account_ClientType_MemberAirline
        || sClientType == Account_ClientType_ThirdParty);
  }
  
  /**
   * Returns a list of the non-member client
   */
  public static List<String> getZuoraNonMembersClientTypes() {
    return new List<String> {ProductAudience_Zuora_NONMEMBERSINGLE,
                ProductAudience_Zuora_NONMEMBERGDS,
                ProductAudience_Zuora_NONMEMBERPROCESSOR,
                ProductAudience_Zuora_NONMEMBERFRANCHISE};
  }
  
  /**
   * Converts a Payment Type String into a Payment Type Enum
   * @param sPmType: Payment Method String value
   * @return The corresponding Payment Type Enum
   */
  public static PaymentType parsePaymentMethodToEnum(String sPmType) {
    if (sPmType == 'CREDIT_CARD') return PaymentType.CREDIT_CARD;
    else if (sPmType == 'BANK_TRANSFER') return PaymentType.BANK_TRANSFER;
    else if (sPmType == 'ICH') return PaymentType.ICH;
    else return null;
  }
  
  /**
   * Converts a Payment Type enum into a string (used for picklist)
   * @param ePmType Payment Method enum value
   * @return The corresponding Payment Type string
   */
  public static String parsePaymentMethodEnumToPicklistValue(PaymentType ePmType) {
    if (ePmType == PaymentType.CREDIT_CARD) return PaymentThresholdType_CreditCard;
    else if (ePmType == PaymentType.BANK_TRANSFER) return PaymentThresholdType_BankTransfer;
    else if (ePmType == PaymentType.ICH) return PaymentThresholdType_ICH;
    else return null;
  }
  
  /**
   * Converts a Payment Method Type (picklist values) into a string
   * @param sPaymentType Payment Method Type
   * @return The corresponding Payment Type string with spaces
   */
  public static String parsePaymentMethodTypeToTypeWithSpaces(String sPaymentType) {
    if (sPaymentType == 'CreditCard') return PaymentThresholdType_CreditCard;
    else if (sPaymentType == 'BankTransfer') return PaymentThresholdType_BankTransfer;
    else if (sPaymentType == 'ACH' || sPaymentType == 'Other') return PaymentThresholdType_ICH;
    else return null;
  }
  
  /**
   * Converts a string to the GAD search type enum
   * @param sSearchType
   * @return A GADSearchType enum
   */
  public static GADSearchType parseGADSearchTypeToEnum(String sSearchType) {
    if (String.isBlank(sSearchType)) return null;
    if (sSearchType.toLowerCase() == 'exact match' || sSearchType.toLowerCase() == 'exactmatch') return GADSearchType.ExactMatch;
    else if (sSearchType.toLowerCase() == 'starts with' || sSearchType.toLowerCase() == 'startswith') return GADSearchType.StartsWith;
    else if (sSearchType.toLowerCase() == 'contains') return GADSearchType.Contains;
    else return null;
  }
  
  /**
   * Converts a string to the GAD Agency Name Search By enum
   * @param sSearchType
   * @return A GADSearchType enum
   */
  public static GADAgencyNameSearchBy parseGADAgencyNameSearchByToEnum(String sSearchBy) {
    if (String.isBlank(sSearchBy)) return null;
    if (sSearchBy.toLowerCase() == 'trading name'||  sSearchBy.toLowerCase() == 'tradingname') return GADAgencyNameSearchBy.TradingName;
    else if (sSearchBy.toLowerCase() == 'legal name'|| sSearchBy.toLowerCase() == 'legalname') return GADAgencyNameSearchBy.LegalName;
    else if (sSearchBy.toLowerCase() == 'both') return GADAgencyNameSearchBy.Both;
    else return null;
  }

    /**
     * Returns the list of provinces of Canada
     */
    public static List<SelectOption> getCanadaProvinces() {
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','-Select a Province-'));
        /* NOTE: decided to keep the province names as the values
        options.add(new SelectOption('AB','Alberta'));
        options.add(new SelectOption('BC','British Columbia'));
        options.add(new SelectOption('MB','Manitoba'));
        options.add(new SelectOption('NB','New Brunswick'));
        options.add(new SelectOption('NL','Newfoundland and Labrador'));
        options.add(new SelectOption('NS','Nova Scotia'));
        options.add(new SelectOption('NT','Northwest Territories'));
        options.add(new SelectOption('NU','Nunavut'));
        options.add(new SelectOption('ON','Ontario'));
        options.add(new SelectOption('PE','Prince Edward Island'));
        options.add(new SelectOption('QC','Quebec'));
        options.add(new SelectOption('SK','Saskatchewan'));
        options.add(new SelectOption('YT','Yukon'));
        */
        options.add(new SelectOption('Alberta','Alberta'));
        options.add(new SelectOption('British Columbia','British Columbia'));
        options.add(new SelectOption('Manitoba','Manitoba'));
        options.add(new SelectOption('New Brunswick','New Brunswick'));
        options.add(new SelectOption('Newfoundland and Labrador','Newfoundland and Labrador'));
        options.add(new SelectOption('Nova Scotia','Nova Scotia'));
        options.add(new SelectOption('Northwest Territories','Northwest Territories'));
        options.add(new SelectOption('Nunavut','Nunavut'));
        options.add(new SelectOption('Ontario','Ontario'));
        options.add(new SelectOption('Prince Edward Island','Prince Edward Island'));
        options.add(new SelectOption('Quebec','Quebec'));
        options.add(new SelectOption('Saskatchewan','Saskatchewan'));
        options.add(new SelectOption('Yukon','Yukon'));

        return options;
    }
    
    
    /**
     * Returns the list of States of USA 
     */
    public static List<SelectOption> getUSAStates() {
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','-Select a State-'));
        /* NOTE: decided to keep the state names as the values
        options.add(new SelectOption('AL','Alabama'));
        options.add(new SelectOption('AK','Alaska'));
        options.add(new SelectOption('AZ','Arizona'));
        options.add(new SelectOption('AR','Arkansas'));
        options.add(new SelectOption('CA','California'));
        options.add(new SelectOption('CO','Colorado'));
        options.add(new SelectOption('CT','Connecticut'));
        options.add(new SelectOption('DE','Delaware'));
        options.add(new SelectOption('FL','Florida'));
        options.add(new SelectOption('GA','Georgia'));
        options.add(new SelectOption('HI','Hawaii'));
        options.add(new SelectOption('ID','Idaho'));
        options.add(new SelectOption('IL','Illinois'));
        options.add(new SelectOption('IN','Indiana'));
        options.add(new SelectOption('IA','Iowa'));
        options.add(new SelectOption('KA','Kansas'));
        options.add(new SelectOption('KY','Kentucky'));
        options.add(new SelectOption('LA','Louisiana'));
        options.add(new SelectOption('ME','Maine'));
        options.add(new SelectOption('MD','Maryland'));
        options.add(new SelectOption('MA','Massachusetts'));
        options.add(new SelectOption('MI','Michigan'));
        options.add(new SelectOption('MN','Minnesota'));
        options.add(new SelectOption('MS','Mississippi'));
        options.add(new SelectOption('MO','Missouri'));
        options.add(new SelectOption('MT','Montana'));
        options.add(new SelectOption('NE','Nebraska'));
        options.add(new SelectOption('NV','Nevada'));
        options.add(new SelectOption('NH','New Hampshire'));
        options.add(new SelectOption('NJ','New Jersey'));
        options.add(new SelectOption('NM','New Mexico'));
        options.add(new SelectOption('NY','New York'));
        options.add(new SelectOption('NC','North Carolina'));
        options.add(new SelectOption('ND','North Dakota'));
        options.add(new SelectOption('OH','Ohio'));
        options.add(new SelectOption('OK','Oklahoma'));
        options.add(new SelectOption('OR','Oregon'));
        options.add(new SelectOption('PA','Pennsylvania['));
        options.add(new SelectOption('RI','Rhode Island'));
        options.add(new SelectOption('SC','South Carolina'));
        options.add(new SelectOption('SD','South Dakota'));
        options.add(new SelectOption('TN','Tennessee'));
        options.add(new SelectOption('TX','Texas'));
        options.add(new SelectOption('UT','Utah'));
        options.add(new SelectOption('VT','Vermont'));
        options.add(new SelectOption('VA','Virginia'));
        options.add(new SelectOption('WA','Washington'));
        options.add(new SelectOption('WV','West Virginia'));
        options.add(new SelectOption('WI','Wisconsin'));
        options.add(new SelectOption('WY','Wyoming'));
        */
        options.add(new SelectOption('Alabama','Alabama'));
        options.add(new SelectOption('Alaska','Alaska'));
        options.add(new SelectOption('Arizona','Arizona'));
        options.add(new SelectOption('Arkansas','Arkansas'));
        options.add(new SelectOption('California','California'));
        options.add(new SelectOption('Colorado','Colorado'));
        options.add(new SelectOption('Connecticut','Connecticut'));
        options.add(new SelectOption('Delaware','Delaware'));
        options.add(new SelectOption('Florida','Florida'));
        options.add(new SelectOption('Georgia','Georgia'));
        options.add(new SelectOption('Hawaii','Hawaii'));
        options.add(new SelectOption('Idaho','Idaho'));
        options.add(new SelectOption('Illinois','Illinois'));
        options.add(new SelectOption('Indiana','Indiana'));
        options.add(new SelectOption('Iowa','Iowa'));
        options.add(new SelectOption('Kansas','Kansas'));
        options.add(new SelectOption('Kentucky','Kentucky'));
        options.add(new SelectOption('Louisiana','Louisiana'));
        options.add(new SelectOption('Maine','Maine'));
        options.add(new SelectOption('Maryland','Maryland'));
        options.add(new SelectOption('Massachusetts','Massachusetts'));
        options.add(new SelectOption('Michigan','Michigan'));
        options.add(new SelectOption('Minnesota','Minnesota'));
        options.add(new SelectOption('Mississippi','Mississippi'));
        options.add(new SelectOption('Missouri','Missouri'));
        options.add(new SelectOption('Montana','Montana'));
        options.add(new SelectOption('Nebraska','Nebraska'));
        options.add(new SelectOption('Nevada','Nevada'));
        options.add(new SelectOption('New Hampshire','New Hampshire'));
        options.add(new SelectOption('New Jersey','New Jersey'));
        options.add(new SelectOption('New Mexico','New Mexico'));
        options.add(new SelectOption('New York','New York'));
        options.add(new SelectOption('North Carolina','North Carolina'));
        options.add(new SelectOption('North Dakota','North Dakota'));
        options.add(new SelectOption('Ohio','Ohio'));
        options.add(new SelectOption('Oklahoma','Oklahoma'));
        options.add(new SelectOption('Oregon','Oregon'));
        options.add(new SelectOption('Pennsylvania','Pennsylvania'));
        options.add(new SelectOption('Rhode Island','Rhode Island'));
        options.add(new SelectOption('South Carolina','South Carolina'));
        options.add(new SelectOption('South Dakota','South Dakota'));
        options.add(new SelectOption('Tennessee','Tennessee'));
        options.add(new SelectOption('Texas','Texas'));
        options.add(new SelectOption('Utah','Utah'));
        options.add(new SelectOption('Vermont','Vermont'));
        options.add(new SelectOption('Virginia','Virginia'));
        options.add(new SelectOption('Washington','Washington'));
        options.add(new SelectOption('West Virginia','West Virginia'));
        options.add(new SelectOption('Wisconsin','Wisconsin'));
        options.add(new SelectOption('Wyoming','Wyoming'));

        return options;
    }
    
    public static Integer SAPSettings_SchedulePeriod {
        get {
            return integer.valueOf(IEC_SAP_Settings__c.getOrgDefaults().Schedule_Period__c);
        }
    }
    
    public static Boolean SAPSettings_ZuoraInterfaceActive {
        get {
            return IEC_SAP_Settings__c.getOrgDefaults().Activate_Zuora_Payment_Interface__c;
        }
    }
    
    public static Boolean SAPSettings_SAPInterfaceActive {
        get {
            return IEC_SAP_Settings__c.getOrgDefaults().Activate_SAP_Invoice_Interface__c;
        }
    }
    
    public static Integer GDPReplication_SchedulePeriod {
        get {
            return integer.valueOf(IEC_GDP_Replication__c.getOrgDefaults().Schedule_Period__c);
        }
    }
    
    public static Boolean GDPReplication_ScheduleActive {
        get {
            return IEC_GDP_Replication__c.getOrgDefaults().Schedule_Active__c;
        }
    }
    
    public static String GDPReplication_SystemAdminEmail {
        get {
            return IEC_GDP_Replication__c.getOrgDefaults().System_Admin_Email__c;
        }
    }
    
    public static String GDPReplication_ProfileIDswithAccess {
        get {
            return Test.isRunningTest() ? '00ew0000001R6uT,00e20000000kvcd,00e20000001QMpc,00e20000000h0gF,00520000002P7Kb,00ew0000001QUyp,00e20000000kvcdAAA,00e20000000h0gC,00ew0000001QoD2' : IEC_GDP_Replication__c.getOrgDefaults().Profile_IDs_with_Access__c;
        }
    }
}