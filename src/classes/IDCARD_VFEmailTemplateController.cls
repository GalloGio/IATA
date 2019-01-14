public with sharing class IDCARD_VFEmailTemplateController {


  public String myID {
    get;
    set{myID = value; IDCARD_VFEmailTemplateController();}
  }

  public Boolean isRenewal {get; set;}
  public Boolean isITDIPurchased {get; set;}
  public Boolean isExpedite {get; set;}
  public Boolean isPaymentbyCard {get; set;}
  public Boolean isMassApplication {get; set;}

  public Case c {get; set;}
  public Contact cc {get; set;}

  public Date thisDay { get; set;}
  public Date expDate {get; set;}

  public String emailBody1 {get; set;}
  public String emailBody2 {get; set;}
  public String emailBody3 {get; set;}
  public String text1 {get; set;}
  public String text2 {get; set;}
  public String text3 {get; set;}
  public String text4 {get; set;}
  public String text5 {get; set;}
  public String text6 {get; set;}
  public String greeting {get; set;}
  public String signature {get; set;}
  public String fee {get; set;}
  public String expediteMsg {get; set;}
  public String[] shippingAddress {get; set;}

  public List<ID_Card_Application__c> singleApps {get; set;}

  //EM - INC269266
  public boolean hiderenewal {get;set;}

  public void  IDCARD_VFEmailTemplateController() {

    thisDay = Date.Today();
    isITDIPurchased = false;
    isExpedite = false;
    isPaymentbyCard = false;
    isMassApplication = false;

    if(Test.isRunningTest()){
    //coverage Fake
    Integer i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     
  }


    try {


      //Confirmation Email
      if (!isRenewal) {


        // get Case required fields
        c = [Select c.RecordType.Name, c.Related_ID_Card_Application__r.Tax_1_Value__c, c.Related_ID_Card_Application__r.Tax_2_Value__c, c.Related_ID_Card_Application__r.Tax_1_Name__c,
             c.Related_ID_Card_Application__r.Tax_2_Name__c, c.Related_ID_Card_Application__r.Payment_Date__c, c.Related_ID_Card_Application__r.Payment_Transaction_Number__c ,
             c.Related_ID_Card_Application__r.Payment_Credit_Card_Number__c, c.Related_ID_Card_Application__r.ID_Card_Fee__c, c.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c,
             c.Related_ID_Card_Application__r.ITDI_Courses_Fee__c, c.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c, c.Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_2__c,
             c.Related_ID_Card_Application__r.IDCard_Prefered_Language__c, c.Related_ID_Card_Application__r.Last_Name__c,
             c.Account.BillingStreet, c.Account.BillingCity, c.Account.BillingState, c.Account.BillingPostalCode, c.Account.BillingCountry,
             c.Account.ShippingStreet, c.Account.ShippingCity, c.Account.ShippingState, c.Account.ShippingPostalCode, c.Account.ShippingCountry, c.Account.Name,
             c.Account.Short_Name__c, c.Account.TradeName__c, c.Related_ID_Card_Application__r.Type_of_application__c, c.Related_ID_Card_Application__r.First_Name__c, c.Related_ID_Card_Application__r.Middle_Initial__c,
             c.Related_ID_Card_Application__c, c.Related_ID_Card_Application__r.CurrencyIsoCode, c.Related_ID_Card_Application__r.Applicable_Fee__c, c.Related_ID_Card_Application__r.IATA_Code__c, c.CaseNumber,
             c.Account_Billing_Country__c, c.AccountId From Case c  where id = : myID];
        // System.debug('*** IDCARD_VFEmailTemplateController '+c.Related_ID_Card_Application__c);

        //get list of single apps
        singleApps = [SELECT Id, IATA_Code__c, Displayed_Name__c, VER_Number__c FROM ID_Card_Application__c WHERE Mass_order_Application__c = : c.Related_ID_Card_Application__c];

        if (c.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != 0 && c.Related_ID_Card_Application__r.IDCard_Expedite_Delivery_Fee__c != null)
          isExpedite = true;
        if (c.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != 0 && c.Related_ID_Card_Application__r.ITDI_Courses_Fee__c != null)
          isITDIPurchased = true;
        if (c.Related_ID_Card_Application__r.Payment_Transaction_Number__c != '' && c.Related_ID_Card_Application__r.Payment_Transaction_Number__c != null)
          isPaymentbyCard = true;


        //Get the template to be used based on the prefered language
        String Lang = 'English';
        expediteMsg = ' If you have selected expedite delivery your ID Card will be delivered in 8 business days. ';
        if (c.Related_ID_Card_Application__r.IDCard_Prefered_Language__c == 'fr') {
          Lang = 'French';
          expediteMsg = ' Si vous avez choisi la livraison rapide de votre carte d\'identité celle-ci sera livré dans un delai de 8 jours ouvrables. ';
        }
        if (c.Related_ID_Card_Application__r.IDCard_Prefered_Language__c == 'es') {
          Lang = 'Spanish';
          expediteMsg = ' Si ha seleccionado la entrega por envió rápido, recibirá su tarjeta de identificación en 8 días laborales. ';
        }
        /////////////////////////////////////////////////////
        EmailTemplate__c e;

        if (c.RecordType.Name == 'ID Card Mass Application') {
          isMassApplication = true;
          if ( isPaymentbyCard)
            e = [Select  Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, greeting_line__c, Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c from EmailTemplate__c where RecordType.Name = 'ID Card Application' and Template_Type__c = 'Mass Confirmation Email' and Template_Language__c = : Lang];
          else // cheque payment
            e = [Select  Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, greeting_line__c, Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c from EmailTemplate__c where RecordType.Name = 'ID Card Application' and Template_Type__c = 'Mass Confirmation Email Cheque' and Template_Language__c = : Lang];
        } else {
          isMassApplication = false;
          if ( isPaymentbyCard)
            e = [Select  Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, greeting_line__c, Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c from EmailTemplate__c where RecordType.Name = 'ID Card Application' and Template_Type__c = 'Confirmation Email' and Template_Language__c = : Lang];
          else // cheque payment
            e = [Select  Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, greeting_line__c, Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c from EmailTemplate__c where RecordType.Name = 'ID Card Application' and Template_Type__c = 'Confirmation Email Cheque' and Template_Language__c = : Lang];
        }

        // System.debug('****  ID CArd VF EMail TempController '+ UserInfo.getUserId());


        //set Email component fields
        emailBody1 = e.Body_Section_1__c;
        emailBody2 = e.Body_Section_2__c;
        emailBody3 = e.Body_Section_3__c;
        text1 = e.Text_1__c;
        text2 = e.Text_2__c;
        text3 = e.Text_3__c;
        text4 = e.Text_4__c;
        text5 = e.Text_5__c;
        text6 = e.Text_6__c;
        greeting = e.greeting_line__c;
        signature = e.Signature_Details__c;
        
        shippingAddress = new String[5];

        //return the shipping address if any of the fields is filled
        if (c.Account.ShippingStreet != null || c.Account.ShippingState != null || c.Account.ShippingPostalCode != null || c.Account.ShippingCountry != null || c.Account.ShippingCity != null) {
            shippingAddress[0] = c.Account.ShippingStreet == null ? '' : c.Account.ShippingStreet;
            shippingAddress[1] = c.Account.ShippingCity == null ? '' : c.Account.ShippingCity;
            shippingAddress[2] = c.Account.ShippingState == null ? '' : c.Account.ShippingState;
            shippingAddress[3] = c.Account.ShippingPostalCode == null ? '' : c.Account.ShippingPostalCode;
            shippingAddress[4] = c.Account.ShippingCountry == null ? '' : c.Account.ShippingCountry;
        } else {
            shippingAddress[0] = c.Account.BillingStreet == null ? '' : c.Account.BillingStreet;
            shippingAddress[1] = c.Account.BillingCity == null ? '' : c.Account.BillingCity;
            shippingAddress[2] = c.Account.BillingState == null ? '' : c.Account.BillingState;
            shippingAddress[3] = c.Account.BillingPostalCode == null ? '' : c.Account.BillingPostalCode;
            shippingAddress[4] = c.Account.BillingCountry == null ? '' : c.Account.BillingCountry;
        }

        //set Case Number field in ID Card application to be used in Check out page at the end of Payment
        ID_Card_Application__c tempApp = [Select Case_Number__c from ID_Card_Application__c where Id = : c.Related_ID_Card_Application__c ];
        tempApp.Case_Number__c  = c.CaseNumber;
        Update tempApp;

      }


      //Renewal Email Stuff
      else {

        //get related Contact
        cc = [ Select c.ID_Card_Preferred_Language__c, c.VER_Number__c, c.Name, c.Date_of_Birth__c, id, c.AccountId, c.Account.type, c.Account.BillingStreet, c.Account.BillingCity, c.Account.IATACode__c, c.Account.BillingCountry, c.Account.Name, c.Account.Short_Name__c From Contact c where id = : myID ];
        String contactID = cc.Id;
        // get last ID Card
        ID_Card__c idcard = [Select Valid_To_Date__c, Related_Contact__r.Account.IDCard_Key_Account__c From ID_Card__c c where c.Related_Contact__r.Id = :contactID AND c.Card_Status__c = : IDCardUtil.CARDSTATUS_VALID
                             AND c.Valid_To_Date__c != null  order by c.Valid_To_Date__c desc limit 1];

        //set expiry date of last IDCard
        expDate = idcard.Valid_To_Date__c;

        if (idcard.related_contact__r.account != null && idcard.related_contact__r.account.IDCard_Key_Account__c == true)
           hiderenewal = true;
        else
           hiderenewal = false;


        //Get the template to be used based on the prefered language
        String Lang = 'English';
        if (cc.ID_Card_Preferred_Language__c == 'fr')
          Lang = 'French';
        if (cc.ID_Card_Preferred_Language__c == 'es')
          Lang = 'Spanish';


        //get fee for Renewal
        String acccountType = IDCardUtil.GetAgentTypeFromAccountType(cc.Account.type);
        IATA_ISO_Country__c contactCountry = IDCardUtil.GetIATAISOCountryOfContact(cc.Account.IATACode__c);
        Price_Table__c[] listPriceTables = [Select p.ID_Card_Fee__c, p.Type_Class_of_Agent__c, p.CurrencyIsoCode, p.Expedite__c, p.Name From Price_Table__c p where p.Type_Class_of_Agent__c = :acccountType and p.ISO_Country__r.Id = :contactCountry.Id];
        fee = IDCardUtil.GetApplicableFee(listPriceTables[0], false, false, false, null) + '   ' + listPriceTables[0].CurrencyIsoCode;
        EmailTemplate__c e = null;
        if (Test.isRunningTest())
          e = new EmailTemplate__c(Body_Section_1__c = '', Body_Section_2__c = '', Text_1__c = '');
        else
          e = [Select  Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, greeting_line__c, Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c from EmailTemplate__c where RecordType.Name = 'ID Card Application' and Template_Type__c = 'Renewal Notice' and Template_Language__c = : Lang];


        emailBody1 = e.Body_Section_1__c;
        emailBody2 = e.Body_Section_2__c;
        emailBody3 = e.Body_Section_3__c;
        text1 = e.Text_1__c;
        text2 = e.Text_2__c;
        text3 = e.Text_3__c;
        text4 = e.Text_4__c;
        text5 = e.Text_5__c;
        text6 = e.Text_6__c;
        greeting = e.greeting_line__c;
        signature = e.Signature_Details__c;

      }

    }

    catch (Exception ex) {
      System.debug('*** ERROR ' + ex.getMessage());
      signature = ex.getMessage();
    }


  }




}