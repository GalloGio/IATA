public  class IDCard_CheckoutController extends IDCardAbstractController {

    public String Language {get; set;}
    
    public String Tax1 {get;set;}
    public String Tax1Value {get;set;}
    public String Tax2 {get;set;}
    public String Tax2Value {get;set;}

    public String amount {get;set;}
    public String curr {get;set;}
    public String orderNumber {get;set;}
    public String billToFirstName {get;set;}
    public String billToLastName {get;set;}
    
    public Map<String,String> cyberSrcData {get; set;}
    
    public String accountName {get;set;}
    public String accountIATACode {get;set;}
    public String accountState {get;set;}
    public String description {get;set;}
    public String orderPage_transactionType {get; set;}
    public String merchantID {get; set;}
    public String orderPage_timestamp {get; set;}
    public String orderPage_version {get; set;}
    public String orderPage_serialNumber {get; set;}
    public string idCardFee {get; set;}
    public string itdiCourseFee {get; set;}
    public string expediteDeliveryFee {get; set;}
    public string itdiSelCourseNames {get; set;}
    public string agencyCountryCode {get; set;}
    public String profitCenter{get; set;}
    public Boolean CanPayByCheque {get;set;}
     
    public ID_Card_Application__c idCardApplication {get; private set;} 
    
    private String accountType;
    
    private Account theAccount;
    
    private String sharedSecret;
    private String profile_id;
    private String access_key;
    
    public String calculatedSignature {
        get{
            return machash(buildDataToSign(), sharedSecret);
        } set;}
  
    
    public String confirmationString {
        get {
            if (idCardApplication != null) {
                if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW)
                    return Label.IDCard_CheckoutPage_Message_NewApplication;
                else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE)
                    return Label.IDCard_CheckoutPage_Message_ReplaceApplication;
                else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_RENEWAL)
                    return Label.IDCard_CheckoutPage_Message_RenewApplication;
                else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
                    return Label.IDCard_CheckoutPage_Message_ChangeApplication;
                else
                    return '';
            }
            else
                return '';
        }
    }
    
    public Boolean IsExpediteDeliveryAddedtoIDCardPrice {
        get {
            
                IATA_ISO_Country__c contactCountry =  [Select i.Name, i.Id, i.ISO_Code__c, i.IATA_Regional_Office__c,i.AIMS_Area_Name__c From IATA_ISO_Country__c i where i.AIMS_Area_Name__c = :theAccount.BillingCountry];
                Price_Table__c[] listPriceTables = [Select p.Expedite_Delivery_added_to_IDCard_Price__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
                if (listPriceTables == null || listPriceTables.size() == 0) {
                    throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
                }
                else
                    return listPriceTables[0].Expedite_Delivery_added_to_IDCard_Price__c;                           
        
        }
    }
    
      public boolean displayPopup {get; set;} 

    /**
     * Constructor
     */ 
    public IDCard_CheckoutController() {
        initialize();
        CanPayByCheque= false;
             
        try {
            // retreive ID Card Application from URL param
            if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID) == null)
                throw new IDCardApplicationException('Missing parameter ' + IDCardUtil.PARAM_APPID);
            String applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));                                  
            
            // retreive error msg if any (coming from CheckoutConfirmation)
            if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG) != null) {
                String errMsg = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
            }
            
            try {
                // get ID Card Application
                idCardApplication = [Select i.RecordtypeId, i.VER_Number__c, i.UIR__c,i.Revenue_Confirmation__c, i.Type_of_application__c, i.Title__c, i.Telephone__c, i.SystemModstamp, 
                                     i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c, 
                                     i.Promotion_Code__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c, 
                                     i.Package_of_Travel_Professionals_Course_2__c, i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c, 
                                     i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c, 
                                     i.IDCard_Expedite_Delivery_Fee__c, i.ID_Card_Fee__c, i.ITDI_Courses_Fee__c, i.IATA_numeric_code_previous_employer_4__c, i.IATA_numeric_code_previous_employer_3__c, 
                                     i.IATA_numeric_code_previous_employer_2__c, i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c, i.IATA_Code__c, 
                                     i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Email_admin__c, 
                                     i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, 
                                     i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c,
                                     i.Tax_2_Name__c,  i.Tax_1_Name__c,  i.Tax_1_Value__c,  i.Tax_2_Value__c    
                                     From ID_Card_Application__c i 
                                     where i.Id = :applicationId 
                                     limit 1];
               System.debug('****************************************************** IDCard Fees ' + idCardApplication.ITDI_Courses_Fee__c);
               
               Account a = [ Select BillingState, BillingCountry from Account where IATACode__c =: idCardApplication.IATA_Code__c limit 1];
                
               Map<String,String> taxes =  IDCardTaxUtil.GetTaxes(a.BillingState,a.BillingCountry);
               if(taxes.keySet().Size()==1){   
                     List<String> taxPercentage =  taxes.values();
                     List<String> taxName = new List<String>();
                     taxName.addAll(taxes.keySet());
                     idCardApplication.Tax_1_Name__c = String.ValueOf(taxName[0]) + '(' + String.ValueOf(taxPercentage[0]) + '%)' ;
                     idCardApplication.Tax_1_Value__c = IDCardTaxUtil.CalculateTaxes(String.ValueOf(taxPercentage[0]), String.ValueOf(idCardApplication.Applicable_Fee__c)) + ' '+ idCardApplication.CurrencyIsoCode;
                  
               }else if(taxes.keySet().Size()==2){
                     List<String> taxPercentage =  taxes.values();
                     List<String> taxName = new List<String>();
                     taxName.addAll(taxes.keySet());
                     idCardApplication.Tax_1_Name__c = String.ValueOf(taxName[0]) + '(' + String.ValueOf(taxPercentage[0]) + '%)' ;
                     idCardApplication.Tax_2_Name__c = taxName[1] + '(' + String.ValueOf(taxPercentage[1]) + '%)' ;
                     
                     // If I have 2 taxes, I must consider both in the calculation
                     // As first I retrieve the total amount of the taxes
                     decimal totaltaxpercentage = decimal.valueOf(taxPercentage[0])+decimal.valueOf(taxPercentage[1]);
                     decimal totaltaxamount = decimal.valueOf(IDCardTaxUtil.CalculateTaxes(String.valueOf(totaltaxpercentage), String.ValueOf(idCardApplication.Applicable_Fee__c)));

                     // Now I split the total tax amount in the two separate ones
                     decimal taxamount1 = totaltaxamount / totaltaxpercentage * decimal.valueOf(taxPercentage[0]);
                     decimal taxamount2 = totaltaxamount / totaltaxpercentage * decimal.valueOf(taxPercentage[1]);            
                     idCardApplication.Tax_1_Value__c = taxamount1.setScale(2) + ' '+ idCardApplication.CurrencyIsoCode;
                     idCardApplication.Tax_2_Value__c = taxamount2.setScale(2)+ ' '+ idCardApplication.CurrencyIsoCode;
                 }
            }
            catch (Exception ex) {
                throw new IDCardApplicationException(Label.IDCard_IDCardAppNotFound);
            }
            // get related Account
            theAccount = [Select a.BillingCountry,a.type, a.ShippingState, a.Name From Account a where a.IATACode__c = :idCardApplication.IATA_Code__c limit 1];
            
            
            
             ////Checks if User can pay by Cheque
             // Map the account agent type to the Price Table agent type
             accountType = IDCardUtil.GetAgentTypeFromAccountType(theAccount.type);
             IATA_ISO_Country__c contactCountry =  [Select i.Name, i.Id, i.ISO_Code__c, i.IATA_Regional_Office__c,i.AIMS_Area_Name__c From IATA_ISO_Country__c i where i.AIMS_Area_Name__c = :theAccount.BillingCountry];
             Price_Table__c[] listPriceTables = [Select p.Can_Pay_by_Cheque__c, p.CurrencyIsoCode, p.Profit_Center__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
             CanPayByCheque = listPriceTables[0].Can_Pay_by_Cheque__c;
             if (listPriceTables[0].Profit_Center__c != null && listPriceTables[0].Profit_Center__c != '')
                profitCenter = listPriceTables[0].Profit_Center__c;
             else
                profitCenter = '';               
                 
            
            
            // set application and account values
            Double d = idCardApplication.Applicable_Fee__c;
            if(d == null || d < 0 || d == 0)
                amount =  '0.00';
            else amount = String.valueOf(idCardApplication.Applicable_Fee__c);
            
          
            //####set ISO Country name as part of order name:
            //this is a workaround for SAP since their logic was built on wrong assumption
            // order number must have ID+ISOCode as a prefix
            //remove IDCA- from the idCardApplication.Name
            orderNumber = 'ID'+contactCountry.ISO_Code__c + '-'+ idCardApplication.Name.substring(5, idCardApplication.Name.length()); 
                        

            
            
            billToFirstName = idCardApplication.First_Name__c;
            billToLastName = idCardApplication.Last_Name__c;
            accountName = theAccount.Name;
            accountIATACode = idCardApplication.IATA_Code__c;
            accountState = theAccount.ShippingState;
            curr = idCardApplication.CurrencyIsoCode;
            idCardFee = String.valueOf(idCardApplication.ID_Card_Fee__c);
            itdiCourseFee = String.valueOf(idCardApplication.ITDI_Courses_Fee__c);
            expediteDeliveryFee = String.valueOf(idCardApplication.IDCard_Expedite_Delivery_Fee__c);
            itdiSelCourseNames = '#1: ' + idCardApplication.Package_of_Travel_Professionals_Course_1__c + ' - #2: ' + idCardApplication.Package_of_Travel_Professionals_Course_2__c; 
            agencyCountryCode = contactCountry.ISO_Code__c;
            
            // set description
            if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW)
                description = 'ID Card - New application';
            else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE)
                description = 'ID Card - Reissue';
            else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_RENEWAL)
                description = 'ID Card - Renewal';
            else if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
                description = 'ID Card - Replacement';
            
            if(listPriceTables[0].CurrencyIsoCode == 'CAD')
            {
                //CAD
                profile_id = label.Cybersource_ProfileId;
                access_key = label.Cybersource_AccessKey;                
                sharedSecret = label.Cybersource_SecurityKey;
            }
            else
            { 
                // USD
                profile_id = label.Cybersource_ProfileId_USD;
                access_key = label.Cybersource_AccessKey_USD;
                sharedSecret = label.Cybersource_SecurityKey_USD;
            }
            
            // set Cybersource fields
            fillCyberSrcData();
            
            orderPage_version = '7';
            
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
        

      
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    
    private String machash(String value, String key) {
        //return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA1', Blob.valueOf(value), Blob.valueOf(key)));
        return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA256', Blob.valueOf(value), Blob.valueOf(key)));
    }
    
    private String buildDataToSign() { 
        String dataToSign = '';
        
        List<String> signedFieldNames = String.valueOf(cyberSrcData.get('signed_field_names')).split(',');
        
        for (String signedFieldName : signedFieldNames) {
            dataToSign += (dataToSign == '' ? '' : ',') + signedFieldName + '=' + String.valueOf(cyberSrcData.get(signedFieldName));
        }
        
        return dataToSign;
    }
    
    public Pagereference buyNow() {
        try {
            showPopup();
            orderPage_timestamp = String.valueOf(System.currentTimeMillis());
            //String theData = merchantID + amount + curr + orderPage_timestamp + orderPage_transactionType;
            calculatedSignature = machash(buildDataToSign(), sharedSecret);
            // Update idCardApplication__c with the profit center information
            idCardApplication.Profit_Center__c = profitCenter;
            update idCardApplication;
            return null;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    private void fillCyberSrcData() {
        cyberSrcData = new Map<String,String>();
        
        cyberSrcData.put('profile_id', profile_id);
        cyberSrcData.put('access_key', access_key);
        cyberSrcData.put('signed_date_time', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        cyberSrcData.put('transaction_uuid', String.ValueOf(idCardApplication.Id) + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        cyberSrcData.put('currency', curr);
        cyberSrcData.put('amount', amount);
        cyberSrcData.put('reference_number', orderNumber);
            
        // hardcoded values
        cyberSrcData.put('transaction_type', 'sale');
        cyberSrcData.put('locale', 'en');
        cyberSrcData.put('signed_field_names', 'access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency');
        cyberSrcData.put('unsigned_field_names', 'bill_to_forename,bill_to_surname,merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,merchant_defined_data4,merchant_defined_data5,merchant_defined_data6,merchant_defined_data8,merchant_defined_data9,merchant_defined_data11,merchant_defined_data12,merchant_defined_data13,merchant_defined_data14');
        //,merchant_defined_data7,merchant_defined_data10
        
        // merchant defined fields
        cyberSrcData.put('bill_to_forename', billToFirstName != null ? billToFirstName : '');
        cyberSrcData.put('bill_to_surname', billToLastName != null ? billToLastName : '');
        cyberSrcData.put('merchant_defined_data1', accountName != null ? accountName : '');
        cyberSrcData.put('merchant_defined_data2', accountIATACode != null ? accountIATACode : '');
        cyberSrcData.put('merchant_defined_data3', accountState != null ? accountState : '');
        cyberSrcData.put('merchant_defined_data4', description != null ? description : '');
        cyberSrcData.put('merchant_defined_data5', idCardFee != null ? idCardFee : '');
        cyberSrcData.put('merchant_defined_data6', itdiCourseFee != null ? itdiCourseFee : '');
        //cyberSrcData.put('merchant_defined_data7', expediteDeliveryFee != null ? expediteDeliveryFee : '');
        cyberSrcData.put('merchant_defined_data8', itdiSelCourseNames != null ? itdiSelCourseNames : '');
        cyberSrcData.put('merchant_defined_data9', agencyCountryCode != null ? agencyCountryCode : '');
        //cyberSrcData.put('merchant_defined_data10', profitCenter != null ? profitCenter : '');
        cyberSrcData.put('merchant_defined_data11', Tax1 != null ? Tax1 : '');
        cyberSrcData.put('merchant_defined_data12', Tax1Value != null ? Tax1Value : '');
        cyberSrcData.put('merchant_defined_data13', Tax2 != null ? Tax2 : '');
        cyberSrcData.put('merchant_defined_data14', Tax2Value != null ? Tax2Value : '');
            
    }
    
    public Pagereference payByCheque(){
     
      Pagereference confPage = Page.IDCard_CheckoutConfirmation;
     
     //set param to show that its a payment by cheque 
     String temp = CanPayByCheque+'';
     confPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE,IDCardUtil.EncryptEncodeParameter(temp));
     confPage.getParameters().put('req_reference_number',idCardApplication.Name);
     //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, idCardApplication.Name));
     
     // Update idCardApplication__c with the profit center information
     idCardApplication.Profit_Center__c = profitCenter;
     update idCardApplication;   
     return confPage;
     
     
    }
    
     
    public Pagereference freeOrder(){
     
      Pagereference confPage = Page.IDCard_CheckoutConfirmation;
     
     //set param to show that its a payment by cheque 
     String temp = amount;
     confPage.getParameters().put(IDCardUtil.ISFOC,IDCardUtil.EncryptEncodeParameter(temp));
     confPage.getParameters().put('req_reference_number',idCardApplication.Name);
     //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, idCardApplication.Name));
     
     // Update idCardApplication__c with the profit center information
     idCardApplication.Profit_Center__c = profitCenter;
     update idCardApplication;   
     return confPage;
     
     
    }
     
    public Pagereference back() {

            Pagereference confPage;
            if (idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE|| idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_RENEWAL)
            {   
                confPage = Page.IDCard_ApplicationForm_RR;
                confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(idCardApplication.VER_Number__c));
            }
            else 
            {
                confPage = Page.IDCard_ApplicationForm_NR;
                if(idCardApplication.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
                    confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(idCardApplication.VER_Number__c));
            }   
            confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(idCardApplication.IATA_Code__c));  
            confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(idCardApplication.Type_of_application__c));

            confPage.getParameters().put(IDCardUtil.PAGE_PART,IDCardUtil.EncryptEncodeParameter('3'));
            confPage.getParameters().put(IDCardUtil.PARAM_APPID,IDCardUtil.EncryptEncodeParameter(idCardApplication.Id));
            confPage.setRedirect(true);
            return confPage;
                       
   }
   
  /* 
   public String getAmount(){
        Double d = Double.valueOf(amount);
        if(d<0 || d==0)
            return '0.0';
        return amount;
   }
    */
}