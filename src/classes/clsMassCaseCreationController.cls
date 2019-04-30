public with sharing class clsMassCaseCreationController {

  public boolean IFAP_CanCreateWhileClosedCase {get; set;}
  public Date sixMonthsAgo = date.today().addMonths(-6);

  //RA: Dynamic build Get ISO Country  directly from Object
  public List<SelectOption> getISOCountryName() {
    List<SelectOption> options = new List<SelectOption>();
    //Fill based on regions
    //Americas       where Region__c=:'Americas'
    for (IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'AIMS_Area_Name__c')) {
      options.add(new SelectOption(iso.AIMS_Area_Name__c, iso.AIMS_Area_Name__c));
    }

    return options;
  }

  public String FinancialReviewType { get; set; }
  public string casesQuery {get; private set;}

  private String CASEOPENFORFILTEREDAGENT = 'Cases already exist for one or more than one agent of that list.';
  private Case caseParam = new Case();
  private EmailTemplate__c emailParam = new EmailTemplate__c();
  // the soql without the order and limit
  private String soql {get; set;}
  private string outputMsg { get; set; }
  private string warnMsg { get; set; }
  private Boolean IsSelectedCountryIsSpain = false;
  private string subject { get; set; }
  private String selectedCountry;

  public Boolean isCreateCasesIsDisabled { get; set; }
  public Boolean isSendEmailIsDisabled { get; set; }
  public string XlsUrl {get; set;}

  private Map<ID, Boolean> ContactCheckedList = new Map<ID, Boolean>();
  private List<ID> ALLContacts;
  private List<cContact> displayList = new List<cContact>() ;

  public Boolean SelAllIsChecked { get; set; }
  private Integer inPageSize { get; set; }
  private Integer totalNoOfRecs = 0;
  public Integer pageNumber {get; set;}
  public Integer noOfPages {get; set;}

  public Account aISOCountry {get; set;}//INC212899

  // a property for the lookuptype
  public String GetEmailTemplateKeyPrefix {get; private set;}

  public String openCasesReportURL { get; private set; }
  public Boolean showOpenCasesReportURL { get; private set; }

  public String emailTemplatePreviewURL { get; set; }

  private Set<Id> listAgentIdWithClosedCase;

  public List<cContact> Contacts {
    get {
      if (ContactCheckedList != null) {
        for (cContact aContact : displayList) {

          if (ContactCheckedList.containsKey(aContact.con.ID))
            aContact.selected = true;

        }
      }
      return displayList;
    }

    set {Contacts = value;}
  }



  public Case CaseParameter {
    get { return caseParam; }
    set;
  }

  public EmailTemplate__c EmailParameter {
    get { return emailParam; }
    set ;
  }

  // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }

  // the current field to sort by. defaults to account Name
  public String sortField {
    get  { if (sortField == null) {sortField = 'account.Name'; } return sortField;  }
    set;
  }

  // format the soql for display on the visualforce page
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir; }
    set;
  }

  public string ProcessOutput {
    get { return outputMsg; }
  }

  public string Warning {
    get { return warnMsg; }
  }

  /*
  public EmailTemplate__c getInitialEmailTemplate {

      get {
          return [Select e.Id, e.Name, e.IATA_ISO_Country__r.Name From EmailTemplate__c e where e.IATA_ISO_Country__r.Name =: selectedCountry];
      }
  }*/

  //builds a picklist of Financial review type
  public List<selectOption> lstFinReviewType {
    get{
      Schema.DescribeFieldResult F = Case.Financial_Review_Type__c.getDescribe();
      List<Schema.PicklistEntry> P = F.getPicklistValues();

      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      options.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
      for (Schema.PicklistEntry val :  P) {
        options.add(new selectOption(val.getValue(), val.getLabel())); //for all records found - add them to the picklist options
        if (val.defaultValue) {
          CaseParameter.Financial_Review_Type__c = val.getValue();
        }
      }
      return options; //return the picklist options
    }
  }


  //builds a picklist of Template Languages
  public List<selectOption> lstLanguage {
    get{
      Schema.DescribeFieldResult F = EmailTemplate__c.Template_Language__c.getDescribe();
      List<Schema.PicklistEntry> P = F.getPicklistValues();
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      options.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
      for (Schema.PicklistEntry val :  P) {

        options.add(new selectOption(val.getValue(), val.getLabel())); //for all records found - add them to the picklist options

        if (val.defaultValue) {
          emailParam.Template_Language__c = val.getValue();
        }
      }
      return options; //return the picklist options
    }
  }

  public List<selectOption> lstFinancialMonth {
    get{
      Schema.DescribeFieldResult F = Case.IFAP_Financial_Month__c.getDescribe();
      List<Schema.PicklistEntry> P = F.getPicklistValues();
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      options.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
      for (Schema.PicklistEntry val :  P) {

        options.add(new selectOption(val.getValue(), val.getLabel())); //for all records found - add them to the picklist options

        if (val.defaultValue) {
          CaseParameter.IFAP_Financial_Month__c = val.getValue();
        }
      }
      return options; //return the picklist options
    }
  }
  // init the controller and display some sample data when the page loads
  public clsMassCaseCreationController () {
    isSendEmailIsDisabled = true;
    isCreateCasesIsDisabled = true;
    inPageSize = 10;
    aISOCountry = new account();

    GetEmailTemplateKeyPrefix = EmailTemplate__c.SObjectType.getDescribe().getKeyPrefix();
  }

  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // simply toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';

    // run the query again
    runQuery();
  }


  // runs the actual query
  public void runQuery() {

    pageNumber = 0;
    isNbrRecordsDisplayed = true;
    AllContacts = new List<Id>();
    ContactCheckedList = new Map<ID, Boolean>();
    displayList = new List<cContact>();
    SelAllIsChecked = false;

    try {
        
      String yearend = Apexpages.currentPage().getParameters().get('yearend');
      //String openCasesFlag = Apexpages.currentPage().getParameters().get('opencasesflag');  // phase 4
      String targetFinancialYear = Apexpages.currentPage().getParameters().get('targetFinancialYear');  // phase 4
      String exclClosedCases = Apexpages.currentPage().getParameters().get('exclClosedCases');  // phase 4

      // test
      searchAgentsWithClosedCase();

      system.debug('Query to be executed: ' + soql + ' order by ' + sortField + ' ' + sortDir);

      //get all contacts and store them in AllContacts list
      for (Contact cont : Database.query(soql + ' order by ' + sortField + ' ' + sortDir )) {
        if (exclClosedCases.equals('false') || (exclClosedCases.equals('true') && !agentHasClosedCases(cont.Account.Id)))
          ALLContacts.add(cont.Id);
      }

      system.debug('ALL contacts Size = ' + AllContacts.size());


      //initial display list first 10 items
      String extraQuery = '';
      Integer num = inPageSize ;
      if (num > AllContacts.size())
        num = AllContacts.size();

      if (AllContacts.size() > 0) {
        extraQuery = ' and (';
        for (Integer i = 0 ; i < num ; i++) {
          if (i == 0)
            extraQuery += ' Contact.ID = \'' + AllContacts[i] + '\'';

          extraQuery += ' or Contact.ID = \'' + AllContacts[i] + '\'';
        }
        extraQuery +=  ' )';
      }

      String q = soql + extraQuery + ' order by ' + sortField + ' ' + sortDir;

      string agentType = Apexpages.currentPage().getParameters().get('agenttype');
      string agentStatus = Apexpages.currentPage().getParameters().get('agentstatus');
      string country = aISOCountry.IATA_ISO_Country__c;
      string email = Apexpages.currentPage().getParameters().get('email');
      yearend = Apexpages.currentPage().getParameters().get('yearend');  //phase 1 release 2
      targetFinancialYear = Apexpages.currentPage().getParameters().get('targetFinancialYear');  // phase 4
      string exclOpenCases = Apexpages.currentPage().getParameters().get('exclOpenCases');  // phase 4
      exclClosedCases = Apexpages.currentPage().getParameters().get('exclClosedCases');  // phase 4

      system.debug('Query to be executed::: ' + q );
      PageReference secondPage = Page.DownloadAgents;
      secondPage.getParameters().put('agentType', agentType);
      secondPage.getParameters().put('agentStatus', agentStatus);
      secondPage.getParameters().put('ISOCountry', country);     
      secondPage.getParameters().put('email', email);
      secondPage.getParameters().put('yearend', yearend);
      secondPage.getParameters().put('targetFinancialYear', targetFinancialYear);
      secondPage.getParameters().put('exclOpenCases', exclOpenCases);
      secondPage.getParameters().put('exclClosedCases', exclClosedCases);

      XlsUrl = secondPage.getUrl();
      for (Contact cont : Database.query(q)) {

        Boolean hasClosedCases = agentHasClosedCases(cont.AccountId);
        if (exclClosedCases.equals('false') || (exclClosedCases.equals('true') && !hasClosedCases))
          displayList.add(new cContact(cont, hasClosedCases));
      }

      //totalNoOfRecs  = displayList.size();
      totalNoOfRecs = AllContacts.size();

      if (totalNoOfRecs == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No agent Found, please change your search criterias'));
      }


    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unhandled error' + e));
    }
  }


  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
    String agentType = Apexpages.currentPage().getParameters().get('agenttype');
    String agentStatus = Apexpages.currentPage().getParameters().get('agentstatus');

    String country = aISOCountry.IATA_ISO_Country__c;
    system.debug('country on class : ' + country);
    system.debug('country page new : ' + Apexpages.currentPage().getParameters().get('ISOcountry'));
    selectedCountry = country;
    String email = Apexpages.currentPage().getParameters().get('email');
    String yearend = Apexpages.currentPage().getParameters().get('yearend');  //phase 1 release 2
    String targetFinancialYear = Apexpages.currentPage().getParameters().get('targetFinancialYear');  // phase 4
    String exclOpenCases = Apexpages.currentPage().getParameters().get('exclOpenCases');  // phase 4
    String exclClosedCases = Apexpages.currentPage().getParameters().get('exclClosedCases');  // phase 4

    isCreateCasesIsDisabled = true;
    isSendEmailIsDisabled = true;

    // validate target financial year
    if (targetFinancialYear == null || targetFinancialYear == '') {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The target financial year is mandatory.'));
      return null;
    } else if (targetFinancialYear.isNumeric() == false) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The target financial year is not valid.'));
      return null;
    }
    
    CaseParameter.IFAP_Financial_Year__c = targetFinancialYear;

    if (String.valueOf(aISOCountry.IATA_ISO_Country__c) == null || String.valueOf(aISOCountry.IATA_ISO_Country__c) == '') {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a country'));
      IsSelectedCountryIsSpain = false;
    } else {
      soql = 'select Account.name, Account.IATACode__c, Account.Status__c, Account.Type, Account.BillingCountry, Account.Location_Type__c, account.CCG_Participant__c , account.CCG_IRR_Distribution_list__c, Account.Number_of_open_Financial_Review_Cases__c, FirstName, LastName, Email, Account.Region__c, ID, Financial_Assessment_Contact__c, Name from contact where account.name != null and Account.IATACode__c != null and Financial_Assessment_Contact__c = true';
      //if (!country.equals('')) {
        //soql += ' and Account.BillingCountry LIKE \''+String.escapeSingleQuotes(country)+'%\'';

        system.debug('aISOCountry.IATA_ISO_Country__c  '+aISOCountry.IATA_ISO_Country__c); // country id
        soql += ' and Account.IATA_ISO_Country__c = \'' + aISOCountry.IATA_ISO_Country__c + '\'';
        system.debug('soql  '+soql);

        if (country.toUpperCase().equals('SPAIN')) IsSelectedCountryIsSpain = true;
        else IsSelectedCountryIsSpain = false;
      //}
      if (!agentType.equals('') ) {

        string[] aType = String.escapeSingleQuotes(agentType).split('-', 12);
        String b = '';

        if (aType.size() > 1)
          b = '(';

        soql += ' and' + b + ' Account.Type LIKE \'' + aType[0] + '%\'';

        for (integer i = 1 ; i < aType.size(); i++) {
          if (!aType[i].equals(''))
            soql += ' or Account.Type LIKE \'' + aType[i] + '%\'';

          if (i == aType.size() - 1)
            soql += ')';
        }

      }
      if (!agentStatus.equals('')) {
        string[] words = String.escapeSingleQuotes(agentStatus).split('-', 12);
        String b = '';

        if (words.size() > 1)
          b = '(';

        soql += ' and' + b + ' Account.Status__c LIKE \'' + words[0] + '%\'';

        for (integer i = 1 ; i < words.size(); i++) {
          if (!words[i].equals(''))
            soql += ' or Account.Status__c LIKE \'' + words[i] + '%\'';

          if (i == words.size() - 1)
            soql += ')';
        }
      }
      if (email.equals('1')) {
        soql += ' and Email != null';
        //isSendEmailIsDisabled = false;
      } else if (email.equals('2')) {
        soql += ' and Email = null';
        //isSendEmailIsDisabled = true;
      }//else isSendEmailIsDisabled = true;

      //if (!yearend.equals('') && !yearend.equals('--All--'))   //phase 1 release 2
      //    soql += ' and Account.Financial_Year_End__c LIKE \''+String.escapeSingleQuotes(yearend)+'%\'';
      if (yearend != '' && yearend.equals('--All--'))
        soql += ' and Account.Fin_statements_submission_deadline__c != \'\'';
      else if (yearend != '')
        soql += ' and Account.Fin_statements_submission_deadline__c LIKE \'' + String.escapeSingleQuotes(yearend) + '%\'';

      // Location Type AO/HO/BR filter
      soql += ' and (Account.Location_Type__c LIKE \'AO%\' OR Account.Location_Type__c LIKE \'HO%\' OR Account.Location_Type__c LIKE \'BR%\' OR Account.Location_Type__c LIKE \'HE%\' OR Account.Location_Type__c LIKE \'AE%\')';

      // exclude opened cases
      if (exclOpenCases.equals('true'))
        soql += ' and Account.Has_Financial_Review_Open_Cases__c = false';
      else if (exclOpenCases.equals('false'))
        soql += ' and (Account.Has_Financial_Review_Open_Cases__c = true or Account.Has_Financial_Review_Open_Cases__c = false)';
      // else we ignore the flag

      // construct link to report (no need to pass the hardcoded parameter, only the dynamic ones)
      //openCasesReportURL = '/00OR0000000k0QE?';   //'/00OR0000000k06s?';  // ID of the report

      soql += ' and (((Account.Reinstated_Date__c = null or Account.Reinstated_Date__c < :sixMonthsAgo) and Account.Category__c = \'IATA Passenger Sales Agent\') or Account.Category__c != \'IATA Passenger Sales Agent\') ';
      soql += ' and Account.ANG_Accreditation_Model__c <> \'Cashless\''; // NEWGEN-1079';

      system.debug(LoggingLevel.ERROR, 'QUERY: ' + soql);

      List<Report> r = [SELECT Id FROM Report where DeveloperName = 'IFAP_Agents_with_Open_Closed_cases' limit 1];

      if (r.size() > 0) {
        openCasesReportURL =  '/' + r[0].Id + '?';
      }
      Else   {
        system.debug('ERROR:(clsMassCaseCreationController.runSearch) The report IFAP_Agents_with_Open_Closed_cases does not exist');
      }




      if (email.equals('1'))
        openCasesReportURL += 'pn5=ne'; // not equals
      else if (email.equals('2'))
        openCasesReportURL += 'pn5=e';  // equals
      //openCasesReportURL += 'pv6=';     // Email equals/not equals null
      List<IATA_ISO_Country__c> couutryName = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<String>{country});
      
      //openCasesReportURL += '&pv6=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(country).trim(), 'UTF-8'); // provide the country
      openCasesReportURL += '&pv6=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(couutryName[0].Name).trim(), 'UTF-8'); // provide the country
      string[] agentTypes = String.escapeSingleQuotes(agentType).trim().split('-', 4);
      string joinedAgentTypes = String.join(agentTypes, '%2C');
      // remove the trailing dash (-), maybe a bug
      joinedAgentTypes = joinedAgentTypes.substring(0, joinedAgentTypes.length());

      if (joinedAgentTypes.endsWithIgnoreCase('%2C'))
        joinedAgentTypes = joinedAgentTypes.substringBeforeLast('%2C');
      openCasesReportURL += '&pv7=' + joinedAgentTypes; // agent type

      if (yearend != null && yearend.equals('--All--')) {
        // list all yead end
        List<Schema.PicklistEntry> ple = Account.Fin_statements_submission_deadline__c.getDescribe().getPicklistValues();
        String allYearEnd = '';
        for (Schema.PicklistEntry entry : ple) {
          allYearEnd += entry.getValue() + '%2C';
        }
        if (allYearEnd.endsWithIgnoreCase('%2C'))
          allYearEnd = allYearEnd.substringBeforeLast('%2C');
        openCasesReportURL += '&pv3=' + String.escapeSingleQuotes(allYearEnd); // Financial statements submission deadline
      } else {
        openCasesReportURL += '&pv3=' + String.escapeSingleQuotes(yearend); // Financial statements submission deadline
      }
      openCasesReportURL += '&pv10=' + CaseParameter.IFAP_Financial_Year__c;

      // run the query again
      runQuery();
      // show the report link every time we search
      showOpenCasesReportURL = true;

      if (nbrFoundRecords > 0) {
        isCreateCasesIsDisabled = false;

        if (email.equals('1'))
          isSendEmailIsDisabled = false;
      }
    }
    return null;
  }

  private void searchAgentsWithClosedCase() {

    listAgentIdWithClosedCase = new Set<Id>();
    String agentType = Apexpages.currentPage().getParameters().get('agenttype');
    String agentStatus = Apexpages.currentPage().getParameters().get('agentstatus');
    //String country = Apexpages.currentPage().getParameters().get('country');
    //String country = Apexpages.currentPage().getParameters().get('ISOcountry');
    String country = aISOCountry.IATA_ISO_Country__c;
    selectedCountry = country;
    String email = Apexpages.currentPage().getParameters().get('email');
    String yearend = Apexpages.currentPage().getParameters().get('yearend');  //phase 1 release 2
    String targetFinancialYear = Apexpages.currentPage().getParameters().get('targetFinancialYear');  // phase 4

    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

    // search for agents that have closed cases for the same financial year
    String soql = 'select c.Contact.Account.Id, c.Contact.Account.Name from Case c where c.RecordTypeId=\'' + IFAPcaseRecordTypeID + '\' and c.Status = \'Closed\' and c.IFAP_Financial_Year__c = \'' + targetFinancialYear + '\' and c.Contact.Account.name != null and c.Contact.Account.IATACode__c != null and c.Contact.Financial_Assessment_Contact__c = true';

    if (!country.equals('')) {
      soql += ' and c.Contact.Account.IATA_ISO_Country__c = \'' + aISOCountry.IATA_ISO_Country__c + '\'';

      if (country.toUpperCase().equals('SPAIN'))
        IsSelectedCountryIsSpain = true;
      else
        IsSelectedCountryIsSpain = false;
    }

    if (!(String.valueOf(aISOCountry.IATA_ISO_Country__c) == null || String.valueOf(aISOCountry.IATA_ISO_Country__c) == '')) {

      string[] aType = String.escapeSingleQuotes(agentType).split('-', 12);
      String b = '';

      if (aType.size() > 1)
        b = '(';

      soql += ' and' + b + ' c.Contact.Account.Type LIKE \'' + aType[0] + '%\'';

      for (integer i = 1 ; i < aType.size(); i++) {
        if (!aType[i].equals(''))
          soql += ' or c.Contact.Account.Type LIKE \'' + aType[i] + '%\'';

        if (i == aType.size() - 1)
          soql += ')';
      }
    }

    if (!agentStatus.equals('')) {
      string[] words = String.escapeSingleQuotes(agentStatus).split('-', 12);
      String b = '';

      if (words.size() > 1)
        b = '(';

      soql += ' and' + b + ' c.Contact.Account.Status__c LIKE \'' + words[0] + '%\'';

      for (integer i = 1 ; i < words.size(); i++) {
        if (!words[i].equals(''))
          soql += ' or c.Contact.Account.Status__c LIKE \'' + words[i] + '%\'';

        if (i == words.size() - 1)
          soql += ')';
      }
    }
    if (email.equals('1'))
      soql += ' and c.Contact.Email != null';
    else if (email.equals('2'))
      soql += ' and c.Contact.Email = null';

    if (yearend != '' && yearend.equals('--All--'))
      soql += ' and c.Contact.Account.Fin_statements_submission_deadline__c != \'\'';
    else if (yearend != '')
      soql += ' and c.Contact.Account.Fin_statements_submission_deadline__c LIKE \'' + String.escapeSingleQuotes(yearend) + '%\'';

    // Location Type HO/ AO filter
    soql += ' and (c.Contact.Account.Location_Type__c LIKE \'AO%\' OR c.Contact.Account.Location_Type__c LIKE \'HO%\' OR c.Contact.Account.Location_Type__c LIKE \'BR%\' OR c.Contact.Account.Location_Type__c LIKE \'HE%\' OR c.Contact.Account.Location_Type__c LIKE \'AE%\' )';

    soql += 'and c.Contact.Account.ANG_Accreditation_Model__c <> \'Cashless\''; // NEWGEN-1079

    casesQuery = soql;

    for (Case c : Database.query(soql)) {
      listAgentIdWithClosedCase.add(c.Contact.Account.Id);
    }
  }

  public Boolean agentHasClosedCases(Id agentId) {
    return listAgentIdWithClosedCase != null && listAgentIdWithClosedCase.contains(agentId);
  }

  // Create case without sending Emails
  public PageReference MassCaseCreate() {
    MassCaseCreation('no email');
    System.debug('**** MassCaseCreate');

    return null;
  }

  // Create cases (The case created by this function will be flagged as "Agent to be notified (Email)")
  public PageReference MassCaseCreateSendEmail() {
    MassCaseCreation('email');
    System.debug('**** MassCaseCreateSendEmail');

    return null;
  }
  
  // Create cases (The case created by this function will be flagged as "Agent to be notified (Tracked Email)")
  public PageReference MassCaseCreateSendTrackedEmail() {
    MassCaseCreation('tracked email');
        System.debug('**** MassCaseCreateSendTrackedEmail');
    return null;
  }

  //openCase is used as a flag if theres any contact in lstContact has an open case this will be used in js function


  public Boolean openCase {
    get{

      Set <ID> selectedID = new Set<ID>();
      selectedID = ContactCheckedList.KeySet();

      //Assessment Perform is considered as Closed Status
      for (Case aCase : [Select C.ID, c.ContactId,
      c.contact.accountID
      , c.accountID
      From Case c
      Where c.RecordTypeId = '01220000000Q4Yd'
      and (c.Status <> 'Closed'
      AND c.Status <> 'Assessment Cancelled')
      AND c.ContactId IN :selectedID]) {
        // Find the contact of the case
        if (ContactCheckedList.containsKey(aCase.ContactId)
        && (aCase.accountId == aCase.contact.accountID))
          return true;

        break;
      }

      return false;
    }
    set{}

  }

  /**
   * Returns True if one of the selected Account has one or more closed case for the same financial year
   */
  public Boolean agentWithClosedCaseSelected {
    get{

      Set<ID> selectedIDs = ContactCheckedList.KeySet();

      List<Contact> contacts = [Select c.Account.Id From Contact c Where c.Id IN :selectedIDs];

      // Loop through cases
      for (Contact cont : contacts) {
        if (agentHasClosedCases(cont.Account.Id))
          return true;
      }
      return false;
    }
    set{}
  }

  private void MassCaseCreation(String sendEmail) {

    System.debug('**** Sendemail ' + sendEmail);
    refreshCheckMap();
    List<String> lstContactId = new List<String>();
    List<String> lstContactName = new List<String>();

    if (ValidateRequiredFields()) {
      if (Contacts.size() > 0) {
        for (ID Id : ContactCheckedList.keyset()) {
          if (ContactCheckedList.get(Id)) {
            lstContactId.add(Id);
          }
        }

        // We create a new batch and call the creation of the cases only if the user have selected at least one contact
        if (lstContactId.size() > 0) {
          BatchNumber__c batch = new BatchNumber__c();
          batch.Subject__c = caseParam.Subject;
          batch.Country__c = selectedCountry;
          batch.Deadline_date__c = caseParam.Deadline_Date__c;
          insert batch;
          System.debug('Call of the Assynchronous case creation Method');

          String templateName = '';
          EmailTemplate__c[] templates = [SELECT name, Id, IATA_ISO_Country__r.Id FROM EmailTemplate__c WHERE id = : caseParam.EmailTemplate__c and recordType.Name = 'IFAP' limit 1];
          if (templates.size() > 0 ) templateName = templates[0].name;

          if(sendEmail == 'email'){
            IFAP_BusinessRules.massCreateCase(lstContactId, batch.Id, 'Agent Notified (Email)', CaseParameter.Subject, CaseParameter.Description,
                                              CaseParameter.Financial_Review_Type__c, CaseParameter.Deadline_Date__c, CaseParameter.EmailTemplate__c, CaseParameter.IFAP_Financial_Year__c,
                                              CaseParameter.IFAP_Financial_Month__c, templateName, openCasesReportURL, IFAP_CanCreateWhileClosedCase);
          }
          else if(sendEmail == 'tracked email'){
            IFAP_BusinessRules.massCreateCase(lstContactId, batch.Id, 'Agent Notified (Tracked Email)', CaseParameter.Subject, CaseParameter.Description,
                                              CaseParameter.Financial_Review_Type__c, CaseParameter.Deadline_Date__c, CaseParameter.EmailTemplate__c, CaseParameter.IFAP_Financial_Year__c,
                                              CaseParameter.IFAP_Financial_Month__c, templateName, openCasesReportURL, IFAP_CanCreateWhileClosedCase);
          }
          else {
            IFAP_BusinessRules.massCreateCase(lstContactId, batch.Id, 'Agent to be Notified', CaseParameter.Subject,
                                              CaseParameter.Description, CaseParameter.Financial_Review_Type__c,
                                              CaseParameter.Deadline_Date__c, CaseParameter.EmailTemplate__c,
                                              CaseParameter.IFAP_Financial_Year__c, CaseParameter.IFAP_Financial_Month__c,
                                              templateName, openCasesReportURL, IFAP_CanCreateWhileClosedCase);
          }

          batch = [Select Name From BatchNumber__c Where id = : batch.Id limit 1];
          isCreateCasesIsDisabled = true;
          isSendEmailIsDisabled = true;
          String msg = '';
          if (lstContactId.size() == 1)
            msg = ' case was created. The batch number is ';
          else
            msg = ' cases were created. The batch number is ';

          String extramsg = '. Please note that it may take some time for all the cases to be created for this batch.' ;
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, lstContactId.size() + msg + batch.Name + extramsg));
        }
      }
    }
  }

  public PageReference SelectAll() {
    try {
      //select displayed contacts
      for (cContact aContact : displayList) {
        aContact.selected = SelAllIsChecked;
      }

      //select all contacts and add them to list
      for (Id id : AllContacts) {
        if (SelAllIsChecked)
          ContactCheckedList.put(id, true);
        else {
          if (ContactCheckedList.containsKey(id))
            ContactCheckedList.remove(id);
        }
      }

      refreshCheckMap();
    } catch (Exception e) {}
    return null;
  }



  private Boolean ValidateRequiredFields() {
    Boolean isRequiredFieldsAreOK = true;

    if (CaseParameter.Subject == '') {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Case subject is required'));
      isRequiredFieldsAreOK = false;
    }
    if (CaseParameter.Financial_Review_Type__c == null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Financial Review type is required'));
      isRequiredFieldsAreOK = false;
    }

    if (CaseParameter.EmailTemplate__c == null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Email Template is required'));
      isRequiredFieldsAreOK = false;
    }
    if (CaseParameter.IFAP_Financial_Year__c == '') {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Financial year is required'));
      isRequiredFieldsAreOK = false;
    }
    if (CaseParameter.Financial_Review_Type__c == 'Annual' && IsSelectedCountryIsSpain && CaseParameter.IFAP_Financial_Month__c == null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Financial month is required for Spain'));
      isRequiredFieldsAreOK = false;
    }
    if (CaseParameter.Deadline_Date__c == null) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Deadline date is required'));
      isRequiredFieldsAreOK = false;
    }

    // Deadline date for Annual review must be greater or equal than today + 30 days
    if (CaseParameter.Financial_Review_Type__c == 'Annual' && CaseParameter.Deadline_Date__c < (Date.today().addDays(30))) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Deadline date for Annual review cannot be less than 30 days from today\'s date'));
      isRequiredFieldsAreOK = false;
    }

    // Validate if the financial year is written correctly (only digits)
    try {
      Integer inFinancialYear = Integer.valueOf(CaseParameter.IFAP_Financial_Year__c);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Financial year. Only numeric caracters are allowed.'));
      isRequiredFieldsAreOK = false;
    }

    return isRequiredFieldsAreOK;
  }


  //refereshes the Map that contains checked Contacts
  public void refreshCheckMap() {
    for (cContact aContact : displayList) {
      if (aContact.selected) {
        ContactCheckedList.put(aContact.con.Id, true);
      } else {
        if (ContactCheckedList.containsKey(aContact.con.Id))
          ContactCheckedList.remove(aContact.con.Id);
      }
    }

  }



  // returns true if the "First" link must be displayed
  public Boolean hasFirst {
    get {
      return (pageNumber != 0);
    }
  }

  // returns true if the "Last" link must be displayed
  public Boolean hasLast {
    get {
      if (totalPage == 1)
        return false;
      return (pageNumber + 1 != totalPage);
    }
  }

  // indicates whether there are more records after the current page set.
  public Boolean hasNext {
    get {
      return (pageNumber + 1 < totalPage);
    }
  }

  // indicates whether there are more records before the current page set.
  public Boolean hasPrevious {
    get {
      return (pageNumber > 0);
    }
  }


  public PageReference first() {
    pageNumber = 0;
    queryContacts();
    return null;
  }

  public PageReference last() {
    pageNumber = totalPage - 1;
    queryContacts();
    return null;
  }

  public PageReference next() {
    pageNumber++;
    queryContacts();
    return null;
  }

  public PageReference previous() {
    pageNumber--;
    if (pageNumber < 0) {
      pageNumber = 0;
    }
    queryContacts();
    return null;
  }


//triggered on next,prev, last and first actions
  private void queryContacts() {

    refreshCheckMap();
    System.debug('query accounts');
    displayList = new List<cContact>();
    SelAllIsChecked = false;
    Integer offset = pageNumber * inPageSize ;
    System.debug('offset ' + offset );


    String extraQuery = '';
    if (AllContacts.size() > 0) {
      extraQuery = ' and (';
      Integer k = offset + inPageSize;
      if (k > AllContacts.size())
        k = AllContacts.size();

      for (Integer i = offset ; i < k ; i++) {
        if (i == offset)
          extraQuery += ' Contact.ID = \'' + AllContacts[i] + '\'';

        extraQuery += ' or Contact.ID = \'' + AllContacts[i] + '\'';
      }
      extraQuery +=  ' )';
    }

    System.debug('Query is ' + soql + extraQuery + ' order by ' + sortField + ' ' + sortDir);

    for (Contact cont : Database.query(soql + extraQuery + ' order by ' + sortField + ' ' + sortDir )) {
      if (listAgentIdWithClosedCase != null)
        displayList.add(new cContact(cont, agentHasClosedCases(cont.Account.Id)));
      else
        displayList.add(new cContact(cont));
    }
  }


  // returns true if the number of selected/found records must be displayed
  public Boolean isNbrRecordsDisplayed {
    get {
      return isNbrRecordsDisplayed;
    }
    set{isNbrRecordsDisplayed = value;}
  }

  // returns the number of selected records
  public Integer nbrSelectedRecords {
    get {
      return ContactCheckedList.size();
    }
  }

  public void updateNbrSelectedRecords() {

    refreshCheckMap();
    // trigger the count of selected records
    Integer i = nbrSelectedRecords;
  }

  // returns the number of records found
  public Integer nbrFoundRecords {
    get {
      return totalNoOfRecs;
    }
    set{
      nbrFoundRecords = value;
    }
  }

  // returns the current page
  public Integer currentPage {
    get {
      return  (pageNumber + 1);
    }
    set{
      currentPage = value;
    }
  }

  // returns the total number of pages
  public Integer totalPage {
    get {

      Decimal d = totalNoOfRecs;
      Decimal dd = d.divide(inPageSize, 2, System.RoundingMode.CEILING);


      Long i = dd.round(roundingMode.UP);
      System.debug('****** totalNoofRec ' + totalNoOfRecs);
      System.debug('******* dd ' + dd + ' d ' + d + ' i ' + i);

      if (i == 0)
        i++;

      return  (Integer)i;
    }
  }

  public PageReference openEmailTemplatePreview() {

    if (CaseParameter == null)
      return null;
    if (CaseParameter.Subject == null || CaseParameter.Subject == '')
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter a Subject in order to preview the email template'));
    if (CaseParameter.Financial_Review_Type__c == null || CaseParameter.Financial_Review_Type__c == '')
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a Financial Review Type in order to preview the email template'));
    if (CaseParameter.EmailTemplate__c == null)
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select the Initial Request Email Template in order to preview the email template'));
    if (CaseParameter.Deadline_Date__c == null)
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select the Deadline Date in order to preview the email template'));
    if (CaseParameter.IFAP_Financial_Year__c == null || CaseParameter.IFAP_Financial_Year__c == '')
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter the Financial year in order to preview the email template'));

    if (nbrFoundRecords == 0) {
      emailTemplatePreviewURL = '';
      return null;
    }
    if (AllContacts == null || AllContacts.size() == 0) {
      emailTemplatePreviewURL = '';
      return null;
    }

    if (ApexPages.hasMessages(ApexPages.severity.ERROR)) {
      emailTemplatePreviewURL = '';
      return null;
    } else {
      PageReference previewPage = Page.IFAP_EmailTemplatePreview;
      previewPage.getParameters().put('contactId', AllContacts[0]);
      previewPage.getParameters().put('emailTemplateId', CaseParameter.EmailTemplate__c);
      previewPage.getParameters().put('subject', CaseParameter.Subject);
      previewPage.getParameters().put('financialReviewType', CaseParameter.Financial_Review_Type__c);
      previewPage.getParameters().put('deadlineDate', CaseParameter.Deadline_Date__c.format());
      previewPage.getParameters().put('financialYear', CaseParameter.IFAP_Financial_Year__c);
      emailTemplatePreviewURL = previewPage.getUrl();
      return null/*previewPage*/;
    }
  }


  // This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Contact and a Boolean value
  public class cContact {
    public Contact con {get; set;}
    public boolean selected {get; set;}
    public boolean OpenCases { get; set; }
    public Integer totalCases {get; set;}
    public Integer nbrClosedCases {get; set;}
    public String hasClosedCases {get; private set;}

    //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
    public cContact(Contact c) {
      con = c;
      selected = false;
      OpenCases = false;
    }

    public cContact(Contact c, Boolean pHasClosedCases) {
      con = c;
      selected = false;
      OpenCases = false;

      hasClosedCases = (pHasClosedCases ? 'Yes' : 'No');
    }
  }
}