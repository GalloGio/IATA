public class Enquiry_NewContact_Controller {



  public integer Page {get; private set;}

  public string Airline {get{return'Airline';} private set;}
  public string Agency {get{return'Agency';} private set;}
  public string GSA {get{return'General Sales Agent';} private  set;}
  public string TIESS {get{return'TIESS';} private  set;}
  public string NonIATA {get{return'Non IATA Agency';} private  set;}
  public string Partner {get{return'Partner';} private set;}
  public string GenPublic {get{return 'General Public';} private set;}

  public List<SelectOption> FilteredType { get; set;}
  public List<SelectOption> FilteredIndustry { get; set;}
  public List<SelectOption> ISOCountry {get; set;}
  // public List<SelectOption> ISOCountryName{get;set;}
  public List<SelectOption> TypeOfCustomer {get; set;}

  public String lang {get; set;}
  public String Language {get; set;}

  public string CustomerType {get; set;}

  //flags for page.
  public boolean searchMade {get; set;}
  public boolean sameAsBilling {get; set;}
  public boolean searchresultsFound {get; set;}
  public boolean HqsFound { get { return AccListHQ.size() > 0 ? false : true;} set;}
  public boolean BranchesFound { get { return AccListBranches.size() > 0 ? false : true;} set;}
  public boolean validationError {get; set;}
  public boolean showNext {get; set;}

  public Contact con { get; set; }
  public Account acc {get; set; }
  public List<Account> AccListHQ { get; set;}
  public List<Account> AccListBranches { get; set;}
  public string selectedAccountID {get; set;}

  public list<String> errorMessage { get; set; }


  private string LogAnEnquiryForm {
    get{ return LogAnEnquiryUtil__c.getValues('customer-portal').Content__c  + lang + LogAnEnquiryUtil__c.getValues('LogAnEnquiry').Content__c; }
    set;
  }

  private String caseID;
  private final map<string, string> LANGUAGEMAP = new map<string, string> {'sp' => 'es', 'kr' => 'ko', 'jp' => 'ja'};
  //helper class for the whole an enquiry
  private string theLanguage(String lParam) {
    return LANGUAGEMAP.get(lParam.toLowerCase()) <> null ?  LANGUAGEMAP.get(lParam) : lParam.toLowerCase();
  }

  private  final set<String> ACCMANDATORYFIELS = new set<String> {'Name', 'Industry', 'Type', 'BillingStreet', 'BillingCity', 'BillingCountry', 'Phone'};
  private  final set<String> CONTACTMANDATORYFIELS = new set<String> {'Email', 'Salutation', 'LastName', 'Title', 'FirstName', 'Membership_Function__c', 'Phone'};
  private final string DEVELOPEREMAIL =  LogAnEnquiryUtil__c.getValues('EmailDeveloper').Content__c ;

  private Id rtHQ;
  private Id rtBranch;
  private Id rtAgency;
  private Id rtGsa ;
  private ID rtOthers;
  private ID rtStandard;
  private ID rtContactStandar;

  private FINAL  map<string, string> ISOFIELDPERLANGUAGE = new map<string, string> {
    'en' => 'IATA_COUNTRY_EN__c',
    'ko' => 'IATA_Contry_KR__c',
    'fr' => 'IATA_Country_FR__c',
    'it' => 'IATA_Country_IT__c',
    'ja' => 'IATA_Country_JP__c',
    'pt' => 'IATA_Country_PT__c',
    'es' => 'IATA_Country_SP__c',
    'zh' => 'IATA_Country_ZH__c'
  };

  private FINAL  map<string, string> industryPerType = new map<string, string> {

    'Airline_ Airline' => 'Airline',
    'Agency_ Travel Agent' => 'Travel Agent',
    'Agency_ Cargo Agent' => 'Cargo Agent',
    'General Sales Agent_ General Sales Agent' => 'General Sales Agent'

  };





  private final set<string> NOTFOUNDMSGPERCUSTOMERTYPE = new set<string> {TIESS , Partner, GSA , Agency};


  private FINAL  map<string, string> TYPEPerType = new map<string, string> {

    'Airline_ Cargo Only' => 'Cargo Only',
    'Airline_ Passenger and cargo' => 'Passenger and cargo',
    'Airline_ Passenger Only' => 'Passenger Only',
    'Agency_ Airline Point of Sale' => 'Airline Point of Sale',
    'Agency_ Associations' => 'Associations',
    'Agency_ Airline Point of Sale' => 'Airline Point of Sale',
    'Agency_ CASS Associates' => 'CASS Associates',
    'Agency_ Couriers' => 'Couriers',
    'Agency_ Domestic Agent' => 'Domestic Agent',
    'Agency_ ERSP Agent' => 'ERSP Agent',
    'Agency_ GSA General Sales Agent' => 'GSA General Sales Agent',
    'Agency_ Handling Agent' => 'Handling Agent',
    'Agency_ IATA Cargo Agent' => 'IATA Cargo Agent',
    'Agency_ IATA Passenger Sales Agent' => 'IATA Passenger Sales Agent',
    'Agency_ Import Agent' => 'Import Agent',
    'Agency_ MSO Member Sales Office' => 'MSO Member Sales Office',
    'Agency_ NISI' => 'NISI',
    'Agency_ SSI' => 'SSI',
    'Agency_ TIDS Agent' => 'TIDS Agent',
    'General Sales Agent_ GSSA Cargo' => 'GSSA Cargo',
    'General Sales Agent_ IBCS consolidator' => 'IBCS consolidator'
  };



  private final string EMAILPATTERN = '[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+(\\.[a-zA-Z]{2,4})+';
  private final string PHONEPATTERN = '[+]{0,1}[0-9_ ]+';

  public Enquiry_NewContact_Controller() {

    try {



      con = new Contact();
      acc = new Account();

      AccListHQ = new List<Account>();
      AccListBranches = new List<Account>();
      errorMessage = new list<string>();


      page = 0;
      searchMade = false;
      sameAsBilling = false;
      searchresultsFound = false;
      showNext = false;

      rtHQ = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
      rtBranch = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
      rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
      rtGsa = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_GSA');
      rtOthers   = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others');
      rtStandard = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
      rtContactStandar = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

      ISOCountry = new List<SelectOption>();

      //Language: used for SF
      //lang: is used to pass back to sharepoint page.

      Language =  'en'; // default SF is en_US but its fine to use en it will get set to english by default
      lang = '';
      //get Language

      if (System.currentPageReference().getParameters().containsKey('l')) {
        string outerLanguage =  EncodingUtil.urlDecode(System.currentPageReference().getParameters().get('l'), 'UTF-8');
        lang = outerLanguage != null && outerLanguage<> 'en' ? outerLanguage + '/' : '';
        Language =  this.theLanguage(outerLanguage) ;

      }

      Language =  Language <> null ?  Language.left(2) : 'en';
      string isoField =  ISOFIELDPERLANGUAGE.get(Language.toLowerCase());

      for (IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')) {

        if (String.isNotBlank(string.valueOf(iso.get(isoField)))) {
          ISOCountry.add(new SelectOption(iso.Id, string.valueOf(iso.get(isoField))));
        }
      }

      TypeOfCustomer = new List<SelectOption> {
        new SelectOption('', '-None-'),
        new SelectOption(Airline, Airline),
        new SelectOption(Agency, Agency),
        new SelectOption(GSA, GSA),
        new SelectOption(TIESS, TIESS),
        new SelectOption(NonIATA, NonIATA),
        new SelectOption(Partner, Partner),
        new SelectOption(GenPublic, GenPublic)
      };

      //get email value from parameter
      if (System.currentPageReference().getParameters().containsKey('e')) {
        con.Email =  EncodingUtil.urlDecode(System.currentPageReference().getParameters().get('e'), 'UTF-8');
        if (!Pattern.matches(EMAILPATTERN, con.Email))
          throw new transformationException('No Email found. There seems to be an issue in your url. ');
        if (this.searchContact(con.Email ) <> null)this.RedirectToForm();
      }


      //Check if theres a case passed instead of email
      if (System.currentPageReference().getParameters().containsKey('c')) {

        caseID = EncodingUtil.urlDecode(System.currentPageReference().getParameters().get('c') , 'UTF-8');
        list<Case> myCases = [Select SuppliedEmail from Case where Id = : caseID];
        if (myCases.size() == 0)
          throw new transformationException('URL ISSUE Case ' + caseID + ' not found');

        con.Email = myCases[0].SuppliedEmail;
      }

      //check if a contact is passed.
      if (System.currentPageReference().getParameters().containsKey('cid')) {
        String conID = EncodingUtil.urlDecode( System.currentPageReference().getParameters().get('cid'), 'UTF-8');

        list<Contact> cons =
          Database.Query('SELECT' +
                         TransformationHelper.getAllFields(Schema.SObjectType.Contact.fields.getMap()) +
                         ' FROM Contact WHERE id =\'' + conID + '\'');

        if (cons.size() == 0)
          throw new transformationException('URL ISSUE Contact ' + conID + ' not found');

      }

      if (String.isBlank(con.Email))
        throw new transformationException('No Email found. There seems to be an issue in your url.');


    } catch (StringException e) {
      Page = -1;
      errorMessage.add('An Error occured. URL ISSUE ');

    } catch (transformationException e) {

      Page = -1;
      errorMessage.add('An Error occured.'
                       + e.getMessage()
                      );

    } catch (Exception e) {

      Page = -1;
      errorMessage.add('An Error occured.'
                       + e.getMessage()
                      );
      TransformationHelper.sendSFDevsAlertMessage('  Enquiry new contact '
          , ' ERROR :  ' + e.getmessage() +  '   Line  ' + e.getLineNumber() +   '   Sttrstr '  + e.getStackTraceString()
          , DEVELOPEREMAIL);
    }

  }

  private Contact searchContact(string emailLocal) {

    list<Contact> cont  =  [    Select Contact_Profile_Complete__c,
                                FirstName, LastName, Email, Agent_Type__c,
                                ISO_Country__r.Name, Account.IATACode__c,
                                Account.Name, Name, Phone
                                From Contact
                                where Email = : emailLocal
                                    AND recordtype.developername = 'Standard_Contact'
                           ];

    return !cont.IsEmpty() ?  cont[0] : null;
  }
  //takes user to account search page in case its not general public
  //IF General public the contact is saved and the confirmation page is shown
  public void  goToAccountSearch() {

    try {
      errorMessage.clear();
      validateContact();
      if (!Pattern.matches(PHONEPATTERN, con.Phone))
        errorMessage.add(Label.Laq_PhoneValidation);

      if (errorMessage.size() > 0)
        throw new transformationException('' + errorMessage[0]);

      if (CustomerType <> null && CustomerType <> GenPublic) {

        page = 1;

      } else if (CustomerType == GenPublic) {

        list<Account> GeneralAccounts = [ select id from Account where type = 'General Public' and IATA_ISO_Country__c = :con.ISO_Country__c];

        if (GeneralAccounts.isEmpty()) throw new transformationException('NO GENERAL PUBLIC ACCOUNT FOUND');
        account  GeneralAccount =  GeneralAccounts[0];
        con.AccountId = GeneralAccount.Id;
        con.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Insert con;
        //show msg and redirect to the log an enquiry page
        RedirectToForm();

      } else {

        throw new transformationException(' Customer Type not supported ');

      }

    } catch (transformationException e) {
      if (errorMessage.isEmpty())
        errorMessage.add(' Error. Please reload the page ');
    } catch (Exception e) {
      if (errorMessage.isEmpty())
        errorMessage.add(' Error. Please reload the page ');
      TransformationHelper.sendSFDevsAlertMessage('  LOG AN ENQUIRY CLASS   next'
          , ' ERROR :  ' + e.getmessage() +  '   Line  ' + e.getLineNumber() +   '   Sttrstr '  + e.getStackTraceString()
          , DEVELOPEREMAIL);
    }
  }

  //show msg that everything ok then redirect to Log an enquiry form
  private pagereference RedirectToForm() {

    //In  the first case was passed as a param send it to the form so it doesnt create a new case
    // in the second one we pass the email
    page = -1;
    string url = !String.isBlank(caseID) ? LogAnEnquiryForm + 'c=' + caseID : LogAnEnquiryForm + 'e=' + con.Email;
    errorMessage.add(String.format(Label.LAQ_RegistrationSuccess, new String[] {'<a href=' + url + '>', '</a>'}));

    return null;
  }


  private boolean codeValidation(string customerType) {



    map<string, string> patternPerCustomerType = new map<string, string> {     Airline => '[0-9]{3}',
        Agency => '[0-9]{8}||[0-9]{11}',
        GSA => '[a-zA-Z]{3}',
        TIESS => 'TIESS_[0-9]{7}',
        NonIATA => '.{2,}',
        Partner => '.{2,}'
                                                                         };

    map<string, string> fieldPerCustomerType = new map<string, string> {       Airline => 'IATACode__c',
        Agency => 'IATACode__c',
        GSA => 'IATACode__c',
        TIESS => 'TIESS_Code__c',
        NonIATA => 'Name',
        Partner => 'Name'
                                                                       };


    return Pattern.matches(patternPerCustomerType.get(customerType), String.valueOF(acc.get(fieldPerCustomerType.get(customerType))));
  }
  // method to find account being searched.
  public pagereference searchForAccount() {
    validationError = false;
    try {
      searchMade  = true;
      errorMessage.clear();
      AccListHQ = new List<Account>();
      AccListBranches = new List<Account>();
      boolean validRegex = codeValidation(customerType);
      searchresultsFound = false;

      if (con.ISO_Country__c == null  && customerType <> Agency && customerType <> GSA && customerType <> TIESS  )
        throw new  transformationException('Please choose a country');

      if (!validRegex && CustomerType  == Airline) {
        validationError = true;
        throw new transformationException(System.Label.LAQ_IATACodeLimitation1);
      } else if (!validRegex && CustomerType  == Agency) {
        validationError = true;
        throw new transformationException(Label.LAQ_IATACodeLimitation2);
      } else if (!validRegex && CustomerType  == GSA) {
        validationError = true;
        throw new transformationException(Label.LAQ_IATACodeLimitation4);
      } else if (!validRegex && CustomerType  == TIESS ) {
        validationError = true;
        throw new transformationException(Label.LAQ_IATACodeLimitation3);
      } else if (!validRegex && ( CustomerType  == NonIATA || CustomerType  == Partner))  {
        validationError = true;
        throw new transformationException(Label.LAQ_IATACodeLimitation5);
      }

      string query = 'SELECT Id,IATACode__c,Field_Head_Office__c,Name,  BillingStreet,BillingCity,BillingCountry'
                     + '  FROM Account WHERE ';
      // gsa NO COUNTRY -- for partner change the error msg to make a general public

      if (CustomerType == Airline)
        query += '  (RecordTypeId=:rtHQ OR RecordTypeId=:rtBranch) ';

      if (CustomerType == Agency)
        query += '  RecordTypeId=:rtAgency  ';

      if (CustomerType == GSA)
        query += '  RecordTypeId=:rtGsa  ';


      if (CustomerType == Airline || CustomerType == GSA || CustomerType == Agency )
        query +=   ' AND IATACode__c=\'' + acc.IATACode__c + '\' ';

      if ( CustomerType == TIESS)
        query += '  RecordTypeId=:rtOthers  '
                 +  ' AND TIESS_Code__c =\'' + acc.TIESS_Code__c + '\' ';


      if (CustomerType == NonIATA || CustomerType == Partner)
        query += '  RecordTypeId=:rtOthers  '
                 + ' and Name like \'%' + acc.name + '%\' ' ;


      if (CustomerType <> Agency && CustomerType <> GSA && CustomerType <> TIESS)
        query += ' AND IATA_ISO_Country__c=\'' + con.ISO_Country__c + '\'';

      AccListHQ = dataBase.Query(query);

      if (AccListHQ.isEmpty() && NOTFOUNDMSGPERCUSTOMERTYPE.contains(CustomerType) ) {
        searchresultsFound = false;

        if (customerType == TIESS)
          throw new TransformationException( Label.LAQ_NoTiess);
        if (customerType == Partner)
          throw new TransformationException(  Label.LAQ_noPartenr);
        if (customerType == GSA)
          throw new TransformationException( Label.LAQ_noGSA);
        if (Agency == TIESS)
          throw new TransformationException(Label.LAQ_noAgenciesFound);

      }
      if (AccListHQ.isEmpty()) {
        throw new TransformationException( Label.LAQ_NoRecordsFound);
        searchresultsFound = false;
      }

      searchresultsFound = true;
      showNext = true;
      list <Account> tList = new list <Account>();
      accListBranches.clear();
      for (Account tacc : AccListHQ) {
        if (tacc.Field_Head_Office__c == 'Branch')
          accListBranches.add(tacc);
        else
          tList.add(tacc);
      }
      AccListHQ = tList;

      return null;
    } catch (transformationException e) {

      showNext = true;

      if (validationError) {
        showNext = false;
        searchresultsFound = false;
      }

      if ((customertype == Agency || customertype ==  Partner || customertype == TIESS || customertype ==  GSA)
          && (!searchresultsFound ||  validationError)
         )
        showNext = false;

      AccListHQ.clear();
      AccListBranches.clear();
      errorMessage.add('An error occured. ' + e.getMessage()  );
      return null;



    } catch (Exception e) {
      showNext = false;
      searchresultsFound = false;
      TransformationHelper.sendSFDevsAlertMessage('  LOG AN ENQUIRY CLASS   next'
          , ' ERROR :  ' + e.getmessage() +  '   Line  ' + e.getLineNumber() +   '   Sttrstr '  + e.getStackTraceString()
          , DEVELOPEREMAIL);
      AccListHQ.clear();
      AccListBranches.clear();
      errorMessage.add('An error occured. ' + e.getMessage()  );
      return null;

    }

  }


  //saves contact to goes to Account creation page
  // this method is on Account search page... it saves the contact and links to account in case Account is found
  //other wise it redirects to account creation page and it will save contact and account in that page.
  public PageReference  saveContact() {

    try {

      this.searchForAccount();

      errorMessage.clear();

      filterAccountIndustryAndType();
      //IF account not found
      if (selectedAccountID == 'null' || selectedAccountID == '') {
        //redirect to Account creation page

        page = 2;

        IATA_ISO_Country__c iso = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<ID> {con.ISO_Country__c})[0];
        acc.BillingCountry = iso.Name;

      } else {


        validateContact();
        if (errorMessage.size() > 0) {
          return null;
        } else if (con.ISO_Country__c == null) {
          errorMessage.add(Label.LAQ_MandatoryFields);
        } else {
          con.AccountId = selectedAccountID;
          con.RecordTypeId = rtContactStandar ;
          Insert con;
          //IF all good take them to log an enquiry page
          RedirectToForm();
        }

      }
      return null;

    } catch (DMLException e) {
      //   throw new transformationException('      v '+   errorMessage +' Error. ' + e.getMessage() + e.getLineNumber() );

      errorMessage.add('Error. Please reload the page (DML)');
      return null;

    } catch (Exception e) {
      page = -1;
      errorMessage.add('Error: ' + e.getMessage() );
      TransformationHelper.sendSFDevsAlertMessage('  LOG AN ENQUIRY CLASS   next'
          , ' ERROR :  ' + e.getmessage() +  '   Line  ' + e.getLineNumber() +   '   Sttrstr '  + e.getStackTraceString()
          , DEVELOPEREMAIL);
      // errorMessage.add('An Error occured. Please contact support');
      return null;

    }


  }


  // this method is on account creation page.
  //it will save the account and the contact after creation.
  public PageReference saveAccountAndContact() {

    errorMessage.clear();

    try {
      //Validation missing fields
      validateContact();
      validateAccount();

      if (!Pattern.matches(PHONEPATTERN, acc.Phone))
        errorMessage.add(Label.Laq_PhoneValidation);
      if ( String.isNotBlank(acc.Fax) && !Pattern.matches(PHONEPATTERN, acc.Fax))
        errorMessage.add(Label.Laq_Fax_Validation);
      if (String.isNotBlank(acc.Email__c) && !Pattern.matches(EMAILPATTERN, acc.Email__c))
        errorMessage.add(Label.LAQ_EmailValidation);

      if (errorMessage.size() > 0) {
        return null;

      } else {

        IATA_ISO_Country__c iso = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String> {acc.BillingCountry})[0];
        acc.IATA_ISO_Country__c =  iso.Id; // ISOCountry.getValue();//

        acc.RecordTypeId = rtStandard ;
        acc.Reason_for_creation__c = 'Created by customer';
        Insert acc;

        con.AccountId = acc.Id;
        con.RecordTypeId = rtContactStandar ;
        Insert con;

        //If all good take them to log an enquiry page
        RedirectToForm();
      }
    } catch (DMLException e) {

      //   throw new transformationException('      v '+   errorMessage +' Error. ' + e.getMessage() + e.getLineNumber() );

      errorMessage.add('Error. Please reload the page (DML)');
    } catch (Exception e) {
      //throw new transformationException('  e.get ' + e.getMessage() + '    ' + e.getLineNumber());
      page = -1;
      errorMessage.add('An Error occurred. Please contact support.' + e.getMessage()   );
      TransformationHelper.sendSFDevsAlertMessage('  LOG AN ENQUIRY CLASS   next'
          , ' ERROR :  ' + e.getmessage() +  '   Line  ' + e.getLineNumber() +   '   Sttrstr '  + e.getStackTraceString()
          , DEVELOPEREMAIL);
    }

    return null;

  }


  //goes back to first section
  public PageReference backToContact() {

    AccListHQ.clear();
    AccListBranches.clear();
    acc.IATACode__c = null;
    acc.Name = null;
    acc.TIESS_Code__c = null;
    searchmade = false;
    shownext = false;
    errorMessage.clear();
    page = 0;
    return null;
  }


  //filter based on business requirements
  public void filterAccountIndustryAndType() {
    try {
      List<SelectOption> IndustryOptions = Customertype == Airline ? new List<SelectOption>() : new List<SelectOption> {new SelectOption('', '-None-')};
      List<SelectOption> TypeOptions = new List<SelectOption> {  new SelectOption('', '-None-')};

      for (string key : industryPerType.keyset()) {
        if (key.contains(CustomerType + '_')) {
          IndustryOptions.add(new SelectOption(industryPerType.get(key), industryPerType.get(key)));
        }
      }

      for (string key : TYPEPerType.keyset()) {
        if (key.contains(CustomerType + '_'))
          TypeOptions.add(new SelectOption(TYPEPerType.get(key), TYPEPerType.get(key)));
      }

      if (CustomerType == TIESS || CustomerType == NonIATA || CustomerType == Partner ) {

        Schema.DescribeFieldResult fieldResult1 =  Account.Industry.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for ( Schema.PicklistEntry f1 : ple1) {
          IndustryOptions.add(new SelectOption(f1.getLabel(), f1.getValue()));
        }




        Schema.DescribeFieldResult fieldResult2 =  Account.Type.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        for ( Schema.PicklistEntry f2 : ple2) {
          TypeOptions.add(new SelectOption(f2.getLabel(), f2.getValue()));
        }



      }
      FilteredType = TypeOptions;
      FilteredIndustry = IndustryOptions;

    } catch (Exception e) {
      errorMessage.add('An Error occurred. Please contact support.' + e.getMessage() );
      TransformationHelper.sendSFDevsAlertMessage('  LOG AN ENQUIRY CLASS   next'
          , ' ERROR :  ' + e.getmessage() +  '   Line  ' + e.getLineNumber() +   '   Sttrstr '  + e.getStackTraceString()
          , DEVELOPEREMAIL);
    }


  }

  public void validateContact() {
    for (String field : CONTACTMANDATORYFIELS) {
      if (con.get(field) == null ||  con.get(field) == '') {
        errorMessage.add(Label.LAQ_MandatoryFields);
        break;
      }
    }

  }

  public void validateAccount() {
    for (String field : ACCMANDATORYFIELS) {
      if (acc.get(field) == null ||  acc.get(field) == '') {
        errorMessage.add(Label.LAQ_MandatoryFields);
        break;
      }
    }
  }


}
