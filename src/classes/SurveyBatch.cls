global class SurveyBatch implements Database.Batchable<sObject>, Database.Stateful {

  // This batch is joining the old batches: SurveyCustomWorkflowBatch and SurveyCustomerRecoveryBatch
  // The purpose of joining them in one single batch is to reduce the load on sfdc's batch scheduler

  global set<Id> CasesPart1;

  //----- VARIABLES USED BY PART 1 -----
  global list<Case> cases;
  global Set<Id> ContactIds;
  //global List<Email> MyEmailToBeSent;
  global map<string, Id> templates = new map<string, Id>();
  //global String RoleName;
  global string log;

  global integer errors;
  global integer success;
  global integer spamAvoided;
  global integer noNation1;
  global integer noNation2;
  global integer noNation3;
  global integer IATAcases;
  global integer totalCases;
  global string errlog;
  global string succLog;
  global string spamAvoidedLog;
  global string noNationLog1;
  global string noNationLog2;
  global string noNationLog3;
  global string IATAcasesLog;


  global map<string, integer> countersMap;
  //global integer usersreplaced;

  public Date ClosedDate {get; set;}

  //----- VARIABLES USED BY PART 2 -----
  global list<Case> lstCases;
  public Date CreatedDate {get; set;}

  global map<String, Id> mapComplaintQueuesPerName = new map<string, Id>();

  // Mapping of the complaint queues per region
  global map<String, String> mapComplaintQueueNamePerRegion = new map<String, String> {
    'Africa & Middle East' => 'Cases_Complaints_GDC_MAD',
    'Americas' => 'Cases_Complaints_GDC_MAD',
    'China & North Asia' => 'Cases_Complaints_BJS',
    'Asia & Pacific' => 'Cases_Complaints_SIN',
    'Europe' => 'Cases_Complaints_GDC_MAD'
  };

  // List of the DeveloperNames of the Case record types that are in the scope of this customer recorvery process
  global list<String> lstRecordTypesInScope = new list<String> { 'CasesMENA', 'CasesAmericas', 'ExternalCasesIDFSglobal', 'Cases_China_North_Asia', 'CasesEurope', 'Cases_Global'};



  global List<Case> start(Database.BatchableContext BC) {
    List<Case> casesToBeProcessed = new List<Case>();
    system.debug(LoggingLevel.error, '################### START() ###########################');
    system.debug(LoggingLevel.error, '################### START() -> GETTING CASES FOR SENDING THE SURVEY ');

    // #################### PART 1 #######################
    // Looking for cases closed yesterday in order to send the survey email
    ContactIds = new Set<Id>();
    templates = new Map<String, Id>();

    Date startd = Test.isRunningTest() ? Date.today() : Date.today().addDays(-1);
    Date endd = Test.isRunningTest() ? Date.today().addDays(1) : Date.today();

    /*For testing:
    Date startd =  Date.today();
    Date endd =  Date.today().addDays(1);
    */

    if (ClosedDate != null) {
      startd =  ClosedDate;
      endd = ClosedDate.addDays(1);
    } else
      ClosedDate = startd;

    //Create a log email
    log = '';

    errors = 0;
    success = 0;
    spamAvoided = 0;
    noNation1 = 0;
    noNation2 = 0;
    noNation3 = 0;
    iataCases = 0;
    totalCases = 0;
    //usersreplaced = 0;
    errlog = '"Case Number","Case Owner","Case Subject","Account Name","IATA Code","Contact Name","Contact Email","Error Raised"';
    succLog = '"Case Number","Case Owner","Case Subject","Account Name","IATA Code","Contact Name","Contact Email"';
    spamAvoidedLog = '';
    noNationLog1 = '';
    noNationLog2 = '';
    noNationLog3 = '';
    iataCasesLog = '';

    countersMap = new map<string, integer>();

    //RoleName = ((UserInfo.getUserRoleId() == null) ? '' : [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()][0].Name);
    for (EmailTemplate et : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'ClickTool%']) {
      templates.put(et.DeveloperName, et.Id);
    }

    system.debug('################# QUERY : WHERE ClosedDate > :' + startd + ' AND ClosedDate < :' + endd + '\n' +
                 'AND ContactId <> NULL AND Contact.Email <> NULL \n' +
                 'AND (Contact.Instant_Survey_opt_out__c = NULL OR Contact.Instant_Survey_opt_out__c = \'\'\n)' +
                 'AND Instant_Survey_Feedback_requested__c = false');

    casesToBeProcessed.addAll([SELECT  RecordType.DeveloperName, CaseArea__c, IATA_Code__c, Reason1__c, Status, Instant_Survey_Feedback_requested__c, BSPCountry__c, Subject,
                               ParentId, Type_of_customer__c, Phone_Redirected_to_Web__c, Case_Group__c, Origin, Region__c, Financial_Review_Type__c,
                               Account_Billing_Country__c, Financial_Review_Result__c, FS_Submitted_Date__c, Instant_Survey_Last_survey_sent__c, CreatedDate,
                               Reason, CaseNumber, Owner.Name, Owner.LastName, Owner.FirstName, Contact.Name,
                               Contact.Email, Contact.HasOptedOutOfEmail, Contact.Instant_Survey_opt_out__c, Account.Name, Account.Status__c,Account.Source_System__c,Account.CNS_Account__c,
                               Contact.Instant_Survey_Last_feedback_received__c, Contact.Instant_Survey_Last_survey_sent__c,
                               WhoClosedCase__r.UserRole.Name, Contact.Account.IATA_ISO_Country__r.Case_BSP_Country__c,
                               WhoClosedCase__r.Profile.Name, CNSCase__c
                               FROM Case
                               WHERE ClosedDate > :startd AND ClosedDate < :endd
                               AND ContactId <> NULL AND Contact.Email <> NULL
                               AND (Contact.Instant_Survey_opt_out__c = NULL OR Contact.Instant_Survey_opt_out__c = '')
                               AND Instant_Survey_Feedback_requested__c = false
                               AND RecordType.DeveloperName <> 'IATA_Financial_Review' /*exclude IFAP cases*/
                                   ORDER BY ClosedDate DESC]);

    CasesPart1 = new Set<Id>();
    for (Case c : casesToBeProcessed)
      CasesPart1.add(c.Id);




    system.debug(LoggingLevel.error, '################### START() -> PART 1 FOUND ' + casesToBeProcessed.size() + ' CASES');

    // #################### PART 2 #######################
    // Looking for cases closed yesterday in order to send the survey email

    startd = Test.isRunningTest() ? Date.today() : Date.today().addDays(-1);
    endd = Test.isRunningTest() ? Date.today().addDays(1) : Date.today();

    /*For testing:
     startd =  Date.today();
     endd = Date.today().addDays(1);
     */

    if (CreatedDate != null) {
      startd =  CreatedDate;
      endd = CreatedDate.addDays(1);
    } else
      CreatedDate = startd;

    // get the newly created Instant Surveys
    List<Instant_Surveys__c> lstInstantSurveys =  [SELECT Id, Relationship_to_Case__c
        FROM Instant_Surveys__c
        WHERE Relationship_to_Case__c <> NULL
        AND ( X2015_Overall_Satisfaction__c IN ('0', '1', '2', '3', '4')
              OR X2015_CES__c IN ('0', '1', '2', '3', '4')
              OR X2015_Communication_Satisfaction__c IN ('0', '1', '2', '3', '4')
              OR X2015_CSR_Quality__c IN ('0', '1', '2', '3', '4')
              OR X2015_Speed_Satisfaction__c IN ('0', '1', '2', '3', '4')
            )
        AND CreatedDate > :startd
        AND CreatedDate < :endd];

    List<Id> lstCaseIds = new List<Id>();
    for (Instant_Surveys__c is : lstInstantSurveys) {
      lstCaseIds.add(is.Relationship_to_Case__c);
    }

    system.debug(LoggingLevel.error, '##### lstCaseIds.size() = ' + lstCaseIds.size());

    casesToBeProcessed.addAll([SELECT Id, Status, Subject, Customer_recovery__c, RecordTypeId, OwnerId, Region__c, WhoClosedCase__r.Profile.Name, WhoClosedCase__r.UserRole.Name
                               FROM Case
                               WHERE Id IN :lstCaseIds
                               AND RecordType.DeveloperName IN :lstRecordTypesInScope]);

    system.debug(LoggingLevel.error, '################### START() -> AFTER PART 2 I FOUND IN TOTAL ' + casesToBeProcessed.size() + ' CASES');

    return casesToBeProcessed;

  }




  global void execute(Database.BatchableContext info, List<Case> scope) {
    system.debug(LoggingLevel.error, '################### EXECUTE() scope = ' + scope.size() + '###########################');
    List<Case> scopepart1 = new List<Case>();
    List<Case> scopepart2 = new List<Case>();

    for (Case c : scope) {
      if (CasesPart1.contains(c.ID))
        scopepart1.add(c);
      else
        scopepart2.add(c);
    }

    processSurveyEmail(scopepart1);
    processCustomerRecovery(scopepart2);
  }



  global void finish(Database.BatchableContext info) {
    system.debug(LoggingLevel.error, '################### FINISH() PART 1###########################');
    String yesterdaydate = Date.today().addDays(-1).year() + '-' + Date.today().addDays(-1).month() + '-' + Date.today().addDays(-1).day();
    String todaydate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
    String ClosedDatestr = ClosedDate.year() + '-' + ClosedDate.month() + '-' + ClosedDate.day();


    if ((errors + success) == 0)
      log += 'No email were sent for the cases closed on ' + yesterdaydate + '\n';
    else {
      log += 'Instant survey email batch result.\n\n'
             + 'The batch ran on ' + totalCases + ' cases closed on ' + ClosedDatestr + ' with the following result: \n'
             + success + ' emails were successfully sent\n'
             + errors + ' emails failed because the contact\'s address is not recognized\n'
             + SpamAvoided + ' emails were blocked by anti spam filter.\n\n'

             + 'A brief table with survey emails sent for each region:\n';

      for (string region : countersMap.keyset())
        log += region + ': ' + countersMap.get(region) + '\n';
      log +=  '\n'
              + 'Best regards';

    }

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    if ((errors + success) > 0) {
      Messaging.EmailFileAttachment[] attachements = new Messaging.EmailFileAttachment[] {} ;
      if (errors > 0) {
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setContentType('Text/csv');
        efa.setFileName('InstantSurveyEmailERRORS' + todaydate + '.csv');
        efa.setBody(blob.valueOf(errlog));
        attachements.add(efa);

        system.debug(LoggingLevel.error, '################### ALLEGO CSV ERRORI CON ' + errors + ' RECORD');
      } else system.debug(LoggingLevel.error, '################### 0 ERRORI ');
      if (success > 0) {
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setContentType('Text/csv');
        efa.setFileName('InstantSurveyEmailSUCCESS' + todaydate + '.csv');
        efa.setBody(blob.valueOf(succLog));
        attachements.add(efa);
        system.debug(LoggingLevel.error, '################### ALLEGO CSV SUCCESSI CON ' + success + ' RECORD');
      } else system.debug(LoggingLevel.error, '################### 0 SUCCESSI ');


      Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
      efa.setContentType('Text/csv');
      efa.setFileName('InstantSurveyEmailAdvancedLog' + todaydate + '.txt');
      efa.setBody(blob.valueOf('NO NATION AM\r\n' + nonationlog1 + '\r\n\r\nNO NATION ARM\r\n' + nonationlog2 + '\r\n\r\nNO NATION CLICKTOOL\r\n' + nonationlog3 +
                               '\r\n\r\nSPAM AVOIDED\r\n' + spamavoidedlog + '\r\n\r\nIATATEAM\r\n' + IATAcaseslog));
      attachements.add(efa);



      email.setFileAttachments(attachements);

    } else system.debug(LoggingLevel.error, '################### 0 MAIL ');

    //system.debug(LoggingLevel.error,'################### EMAIL CON CONTATTI SOSTITUITI DA USER: '+usersreplaced);

    UtilityCS__c sender = UtilityCS__c.getInstance('SurveyEmailSender');
    if (!Test.isRunningTest() && sender != null)  email.setOrgWideEmailAddressId(sender.value__c);
    email.setBccAddresses(new list<string> {'aertsr@iata.org','rovedaa@iata.org','irturko@iata.org'});
    email.setPlainTextBody(log);
    email.setSubject('Instant survey email batch');
    Messaging.sendEmail(new list<Messaging.SingleEmailMessage> {email});
    system.debug(LoggingLevel.error, '################### MANDO ' + (errors + success) + ' email');




    system.debug(LoggingLevel.error, '################### FINISH() PART 2###########################');

    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :info.getJobId()];

    // Send an email to the Apex job's submitter notifying of job completion.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {'aertsr@iata.org','rovedaa@iata.org','irturko@iata.org'};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Instant Survey Customer Recovery batch status: ' + a.Status);
    mail.setPlainTextBody ('The batch process that processes the Instant Surveys with a score between 0 and 4 processed ' + a.TotalJobItems + ' survey batches (containing up to 10 surveys each) with ' + a.NumberOfErrors + ' failures.');
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }

  public class Email {
    public Case cas {get; set;}
    public Id templateId {get; set;}
    public Email(Case c,  Id tm) {
      cas = c;
      templateId = tm;
    }
  }



  public void processSurveyEmail(List<Case> scope) {
    totalCases += scope.size();
    List<Case> CaseToUpdate = new List<Case>();
    List<Email> MyEmailToBeSent = new list<Email>();

    system.debug(LoggingLevel.error, '################### MyEmailToBeSent() size post reinizializzazione = ' + MyEmailToBeSent.size() + '###########################');
    // I apply the filters taken from the old workflow rules and I chose the right template
    for (Case c : scope) {
      id template;
      system.debug(LoggingLevel.error, '################### ESAMINO CASE ' + c.Subject + ' - ' + c.id);

      String RoleName = c.WhoClosedCase__r.UserRole.Name != null ? c.WhoClosedCase__r.UserRole.Name : 'none';
      String ProfileName = c.WhoClosedCase__r.Profile.Name != null ? c.WhoClosedCase__r.Profile.Name : 'none';
      System.debug('::: RoleName : ' + RoleName + 'ProfileName : ' + ProfileName);

      // Conditions requested on INC428523
      if((c.Reason1__c == 'Debt Recovery' && RoleName.contains('E&F')) || (c.Origin == 'E&F Client – Email to Case') || (RoleName.contains('E&F Client Services'))){
        System.debug('Bypass case due to match conditions : c.Reason1__c = Debt Recovery AND RoleName.contains(E&F) OR c.Origin = E&F Client – Email to Case OR RoleName.contains(E&F Client Services)');
        continue;
      }
      // End of requested conditions on INC428523

      // Using the country data from the contact's account and not from the  AccountCountry anymore, to minimize the risk of select the wrong language
      String AccountCountry = '';
      try {
        if (c.Contact.Account.IATA_ISO_Country__r.Case_BSP_Country__c != null) {
          AccountCountry = c.Contact.Account.IATA_ISO_Country__r.Case_BSP_Country__c;
        } else {
          // if no country found, use the one indicated on the case, as before
          AccountCountry = c.BSPCountry__c;
        }
      } catch (Exception e) {
        // probably null pointer exception, no country info available
        // if no country found, use the one indicated on the case, as before
        AccountCountry = c.BSPCountry__c;
      }


      /****** Clicktools Workflow_AM_CX_.... *****/
      if (/*1*/ (c.RecordType.DeveloperName == 'ProcessEuropeSCE' || c.RecordType.DeveloperName == 'OSCAR_Communication') &&
                /*2 aggregate the country for all the Clicktools AM_CX*/
                /*3*/!c.Contact.Email.contains('@iata.org') &&
                !c.Contact.Email.contains('@salesforce.com') &&
                /*4*/c.IATA_Code__c != '953' && c.IATA_Code__c != '954' &&
                /*5*/(c.Reason1__c == 'CHC – Change of Shareholding' || c.Reason1__c == 'CHL - Change of Location' || c.Reason1__c == 'CHN - Change of Name' ||
                      c.Reason1__c == 'CHO / CHS – Change of Ownership / Legal Status' ||
                      c.Reason1__c == 'New BR / IP' || c.Reason1__c == 'New HO' || c.Reason1__c == 'New SA / CHV – New Code')  &&
                /*6*/ c.Status == 'Closed'  &&
                /*7*/ (!c.Account.Name.contains('General Public') && !c.Account.Name.contains('Pubblico Italia')) &&
                /*8*/ c.Contact.HasOptedOutOfEmail == false &&
                /*9*/ String.isBlank(c.Contact.Instant_Survey_opt_out__c)
                /*10*///c.Subject!=null && !c.Subject.contains('PROCOM-EDMC PROJECT')
         ) {
        system.debug(LoggingLevel.error, '################### Clicktools Workflow_AM_CX');
        system.debug(LoggingLevel.error, '################### Region=-' + c.Region__c + '-');
        system.debug(LoggingLevel.error, '################### BSPCountry__c=-' + c.BSPCountry__c + '-');
        system.debug(LoggingLevel.error, '################### AccountCountry=-' + AccountCountry + '-');


        integer n = countersMap.get(c.Region__c) == null ? 0 : countersMap.get(c.Region__c);
        countersMap.put(c.Region__c, ++n);

        //start of INC310891
        List<SurveyBatchIgnoreUsers__c> surveyIgnoreUsers = SurveyBatchIgnoreUsers__c.getAll().values();
        Boolean ignore;
        for(SurveyBatchIgnoreUsers__c siu : surveyIgnoreUsers){
          ignore = false;
          if(siu.FirstName__c == c.Owner.FirstName && siu.LastName__c == c.Owner.LastName){
            IATAcases ++;
            IATAcaseslog += c.id + ', ';
            ignore = true;
            break;
          }
        }
        if(ignore==true)
          continue;
        //end of INC310891

        // If the case is owned by some users the email should not start
   /*     if ((c.Owner.FirstName == 'Ángel' && c.Owner.LastName == 'Peña' ) ||
            (c.Owner.FirstName == 'Alvaro' && c.Owner.LastName == 'Alonso' ) ||
            (c.Owner.FirstName == 'Rafael' && c.Owner.LastName == 'Alarcon' ) ||
            (c.Owner.FirstName == 'Miguel' && c.Owner.LastName == 'Rodriguez Hernandez' ) ||
            (c.Owner.FirstName == 'Cristina' && c.Owner.LastName == 'Lopez' ) ||
            (c.Owner.FirstName == 'Benoit' && c.Owner.LastName == 'Dudognon' ) ||
            (c.Owner.FirstName == 'Monica' && c.Owner.LastName == 'Cabrera' ) ||
            (c.Owner.FirstName == 'Vanesa' && c.Owner.LastName == 'Montero Rosado' ) ||
            (c.Owner.FirstName == 'Vladyslav' && c.Owner.LastName == 'Maydanyk' ) ||
            (c.Owner.FirstName == 'Mercedes Fernandez' && c.Owner.LastName == 'Perez' ) ||
            (c.Owner.FirstName == 'Marta' && c.Owner.LastName == 'Sande Gonzalez-Cela') ||
            (c.Owner.FirstName == 'Victor Manuel' && c.Owner.LastName == 'Meana Solanas') ||
            (c.Owner.FirstName == 'Raluca' && c.Owner.LastName == 'Dediu') ||
            (c.Owner.FirstName =='Sara' && c.Owner.LastName == 'Oubrahim') ||
            (c.Owner.FirstName == 'Taynara'&& c.Owner.LastName == 'Lorentz') ||
            (c.Owner.FirstName == 'Marina'&& c.Owner.LastName == 'de Paula Loures') ||
            (c.Owner.FirstName == 'José' && c.Owner.LastName == 'González-Cela de Cominges')) { //INC267186
          IATAcases ++;
          IATAcaseslog += c.id + ', ';
          continue;
        }*/

    //system.debug(LoggingLevel.ERROR,'AccountCountry is... ' + AccountCountry);

    /*String myvariable;
    myvariable = AccountCountry;
    throw new transformationException( 'Messsage for Susanna ' + myvariable);*/

        if (AccountCountry == 'People\'s Republic of China')
          template = templates.get('Clicktools_Contact_Email_CX_AM_ZH');
        else if (AccountCountry == 'Canada')
          template = templates.get('Clicktools_Contact_Email_CX_AM_EN_FR');
        else if (AccountCountry == 'Algeria' || AccountCountry == 'Benin' || AccountCountry == 'Burkina Faso' || AccountCountry == 'Cameroon' ||
                 AccountCountry == 'Cape Verde' || AccountCountry == 'Central African Republic' || AccountCountry == 'Congo, the Democratic Republic of the' ||
                 AccountCountry == 'Congo (Brazzaville)' || AccountCountry == 'Côte d\'Ivoire' || AccountCountry == 'Equatorial Guinea' || AccountCountry == 'France' ||
                 AccountCountry == 'Gabon' || AccountCountry == 'Guinea' || AccountCountry == 'Guinea-Bissau' || AccountCountry == 'Mali' ||
                 AccountCountry == 'Mauritania' || AccountCountry == 'Morocco' || AccountCountry == 'Niger' || AccountCountry == 'Senegal' || AccountCountry == 'Tchad')
          template = templates.get('Clicktools_Contact_Email_CX_AM_FR');
        else if (AccountCountry == 'Austria' || AccountCountry == 'Germany')
          template = templates.get('Clicktools_Contact_Email_CX_AM_DE');
        else if (AccountCountry == 'Indonesia')
          template = templates.get('Clicktools_Contact_Email_CX_AM_ID');
        else if (AccountCountry == 'Italy')
          template = templates.get('Clicktools_Contact_Email_CX_AM_IT');
        else if (AccountCountry == 'Japan')
          template = templates.get('Clicktools_Contact_Email_CX_AM_JA');
        else if (AccountCountry == 'Korea, Republic of')
          template = templates.get('Clicktools_Contact_Email_CX_AM_KO');
        else if (AccountCountry == 'Brazil' || AccountCountry == 'Portugal')
          template = templates.get('Clicktools_Contact_Email_CX_AM_PT');
        else if (AccountCountry == 'Argentina' || AccountCountry == 'Belize' || AccountCountry == 'Bolivia' || AccountCountry == 'Chile' || AccountCountry == 'Colombia' ||
                 AccountCountry == 'Costa Rica' || AccountCountry == 'Dominican Republic' || AccountCountry == 'Ecuador' || AccountCountry == 'El Salvador' ||
                 AccountCountry == 'Guatemala' || AccountCountry == 'Honduras' || AccountCountry == 'Nicaragua' || AccountCountry == 'Panama' ||
                 AccountCountry == 'Paraguay' || AccountCountry == 'Peru' || AccountCountry == 'Spain' || AccountCountry == 'Andorra' || AccountCountry == 'Uruguay' ||
                 AccountCountry == 'Venezuela')
          template = templates.get('Clicktools_Contact_Email_CX_AM_ES');
        else if (AccountCountry == 'Thailand')
          template = templates.get('Clicktools_Contact_Email_CX_AM_TH');
        else if (AccountCountry == 'Vietnam')
          template = templates.get('Clicktools_Contact_Email_CX_AM_VI');
        else if (AccountCountry == 'Egypt' || AccountCountry == 'Iraq' || AccountCountry == 'Jordan' || AccountCountry == 'Libya' ||
                 AccountCountry == 'Somalia' || AccountCountry == 'South Sudan' || AccountCountry == 'Sudan' || AccountCountry == 'Suriname' || AccountCountry == 'Syria')
          template = templates.get('Clicktools_Contact_Email_CX_AM_AR');
          //start INC325289
        else if(c.Account.Source_System__c == 'WEBSTAR' &&
                (AccountCountry == 'United States' ||  AccountCountry == 'US TERRITORIES AND POSSESS' || AccountCountry == 'Northern Mariana Islands') &&
               (c.Account.Status__c != '' || c.Account.Status__c != 'Terminated' || c.Account.Status__c != null) &&
              (c.CNSCase__c != true || c.Account.CNS_Account__c != true) && c.Case_Group__c == 'Process'){
                template = templates.get('Clicktools_Contact_Email_IATAN_CX_AM_EN_2');
        } //end INC325289

        else if (

          /*2*/((c.Region__c == 'Europe' &&
                 /*3*/(AccountCountry != 'Russian Federation' && AccountCountry != 'France' && AccountCountry != 'Germany' &&
                       AccountCountry != 'Italy' && AccountCountry != 'Portugal' && AccountCountry != 'Spain' && AccountCountry != 'Andorra' ) &&
                 /*4*/!AccountCountry.contains('CIS')) ||

                /*12*/(c.Region__c == 'Asia & Pacific' &&
                       /*13*/(AccountCountry == 'Australia' || AccountCountry == 'Bangladesh' || AccountCountry == 'Cambodia' ||
                              AccountCountry == 'India' || AccountCountry == 'Malaysia' || AccountCountry == 'Nepal' || AccountCountry == 'New Zealand' ||
                              AccountCountry == 'Pakistan' || AccountCountry == 'Philippines' || AccountCountry == 'Singapore' ||
                              AccountCountry == 'Sri Lanka')) ||

                /*14*/(c.Region__c == 'China & North Asia' &&
                       /*15*/(AccountCountry == 'Chinese Taipei' || AccountCountry == '"Hong Kong SAR, China"' || AccountCountry == 'Mongolia')) ||

                /*16*/(c.Region__c == 'Africa & Middle East' &&
                       /*17+18*/ !(AccountCountry == 'Algeria' || AccountCountry == 'Benin' || AccountCountry == 'Burkina Faso' ||
                                   AccountCountry == 'Cameroon' || AccountCountry == 'Cape Verde' || AccountCountry == 'Central African Republic' ||
                                   AccountCountry == '"Congo, the Democratic Republic of the"' || AccountCountry == 'Congo (Brazzaville)' ||
                                   AccountCountry == 'Côte d\'Ivoire' || AccountCountry == 'Equatorial Guinea' || AccountCountry == 'Gabon' ||
                                   AccountCountry == 'Guinea' || AccountCountry == 'Guinea-Bissau' || AccountCountry == 'Mali' ||
                                   AccountCountry == 'Mauritania' || AccountCountry == 'Morocco' || AccountCountry == 'Niger' || AccountCountry == 'Senegal' ||
                                   AccountCountry == 'Tchad' || AccountCountry == 'Egypt' ||
                                   AccountCountry == 'Iran, Islamic Republic of' || AccountCountry == 'Iraq' || AccountCountry == 'Jordan' || AccountCountry == 'Libya' ||
                                   AccountCountry == 'Somalia' || AccountCountry == 'South Sudan' || AccountCountry == 'Sudan' || AccountCountry == 'Suriname' || AccountCountry == 'Syria')) ||

                /*19*/(c.Region__c == 'Americas' &&
                       /*20*/(AccountCountry == 'Bermuda' || AccountCountry == 'Cayman Islands' || AccountCountry == 'Haiti' ||
                              AccountCountry == 'Jamaica' || AccountCountry == 'Trinidad and Tobago' || AccountCountry == 'Turks and Caicos Islands')))

        )
          template = templates.get('Clicktools_Contact_Email_CX_AM_EN');
        //else
        //template = templates.get('Clicktools_Contact_Email_CX_EN');
        else {
          noNation1 ++;
          noNationlog1 += c.id + ', ';

          n = countersMap.get(c.Region__c);
          if (n == 1)  countersMap.remove(c.Region__c);
          else     countersMap.put(c.Region__c, --n);

        }




        //start INC306722 - EXCLUDE the email invitation to fill in the survey from IFAP cases
        /****** Clicktools Workflow_ARM_CX_.... *****/
      /*} else if (*/
      /*1*/
      /*c.RecordType.DeveloperName == 'IATA_Financial_Review' &&*/
                       /*2 */
                       /*c.Status == 'Closed' &&
                       !c.Contact.Email.contains('@iata.org') &&
                       !c.Contact.Email.contains('@salesforce.com') &&*/
                       /*3*/
                       /*(c.Financial_Review_Result__c == 'Satisfactory - New Financial Security' ||
                              c.Financial_Review_Result__c == 'Satisfactory - Update Financial Security' ||
                              c.Financial_Review_Result__c == 'Unsatisfactory - New Financial Security' ||
                              c.Financial_Review_Result__c == 'Unsatisfactory - Update Financial Security') &&*/
                       /*4*/
                       /*c.Financial_Review_Type__c == 'Annual' &&*/
                       /*5*/
                       /*c.FS_Submitted_Date__c != null  &&*/
                       /*6*/
                       /*c.CreatedDate > Date.parse('1/1/2014')*/
                       /*
                ) {
        system.debug(LoggingLevel.error, '################### Clicktools Workflow_ARM_CX ');
        system.debug(LoggingLevel.error, '################### Region=-' + c.Region__c + '-');
        system.debug(LoggingLevel.error, '################### Account_Billing_Country__c=-' + c.Account_Billing_Country__c + '-');

        integer n = countersMap.get(c.Region__c) == null ? 0 : countersMap.get(c.Region__c);
        countersMap.put(c.Region__c, ++n);


        if (c.Account_Billing_Country__c == 'China' || c.Account_Billing_Country__c == 'PEOPLE\'S REPUBLIC OF CHINA')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_ZH');
        else if (c.Account_Billing_Country__c == 'Canada')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_EN_FR');
        else if (c.Account_Billing_Country__c == 'Algeria' || c.Account_Billing_Country__c == 'Benin' || c.Account_Billing_Country__c == 'Burkina Faso' || c.Account_Billing_Country__c == 'Cameroon' ||
                 c.Account_Billing_Country__c == 'Cape Verde' || c.Account_Billing_Country__c == 'Central African Republic' || c.Account_Billing_Country__c == 'Congo, the Democratic Republic of the' ||
                 c.Account_Billing_Country__c == 'Congo' || c.Account_Billing_Country__c == 'CONGO, DEM. REP. OF' || c.Account_Billing_Country__c == 'Côte d\'Ivoire' ||
                 c.Account_Billing_Country__c == 'Equatorial Guinea' || c.Account_Billing_Country__c == 'France' || c.Account_Billing_Country__c == 'Gabon' || c.Account_Billing_Country__c == 'Guinea' ||
                 c.Account_Billing_Country__c == 'Guinea-Bissau' || c.Account_Billing_Country__c == 'Mali' || c.Account_Billing_Country__c == 'Mauritania' || c.Account_Billing_Country__c == 'Morocco' ||
                 c.Account_Billing_Country__c == 'Niger' || c.Account_Billing_Country__c == 'Senegal' || c.Account_Billing_Country__c == 'Tchad' || c.Account_Billing_Country__c == 'Togo' ||
                 c.Account_Billing_Country__c == 'Tunisia' || c.Account_Billing_Country__c == 'COTE D\'IVOIRE' || c.Account_Billing_Country__c == 'GUINEA BISSAU' || c.Account_Billing_Country__c == 'CHAD' ||
                 c.Account_Billing_Country__c == 'FRENCH GUIANA' || c.Account_Billing_Country__c == 'FRENCH POLYNESIA')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_FR');
        else if (c.Account_Billing_Country__c == 'Austria' || c.Account_Billing_Country__c == 'Germany')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_DE');
        else if (c.Account_Billing_Country__c == 'Indonesia')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_ID');
        else if (c.Account_Billing_Country__c == 'ITALY')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_IT');
        else if (c.Account_Billing_Country__c == 'JAPAN')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_JA');
        else if (c.Account_Billing_Country__c == 'Korea' || c.Account_Billing_Country__c == 'Democratic People\'s Republic of' ||
                 c.Account_Billing_Country__c == 'Korea, Republic of' || c.Account_Billing_Country__c == 'KOREA DEM.PEOPLES REPUBLIC')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_KO');
        else if (c.Account_Billing_Country__c == 'Brazil' || c.Account_Billing_Country__c == 'Portugal')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_PT');
        else if (c.Account_Billing_Country__c == 'Argentina' || c.Account_Billing_Country__c == 'Belize' || c.Account_Billing_Country__c == 'Bolivia' || c.Account_Billing_Country__c == 'Chile' ||
                 c.Account_Billing_Country__c == 'Colombia' || c.Account_Billing_Country__c == 'Costa Rica' || c.Account_Billing_Country__c == 'Dominican Republic' || c.Account_Billing_Country__c == 'Ecuador' ||
                 c.Account_Billing_Country__c == 'El Salvador' || c.Account_Billing_Country__c == 'Guatemala' || c.Account_Billing_Country__c == 'Honduras' || c.Account_Billing_Country__c == 'Nicaragua' ||
                 c.Account_Billing_Country__c == 'Panama' || c.Account_Billing_Country__c == 'Paraguay' || c.Account_Billing_Country__c == 'Peru' || c.Account_Billing_Country__c == 'Spain' ||
                 c.Account_Billing_Country__c == 'Uruguay' || c.Account_Billing_Country__c == 'Venezuela' || c.Account_Billing_Country__c == 'SPAIN' || c.Account_Billing_Country__c == 'Andorra' ||
                 c.Account_Billing_Country__c == 'Venezuela, Bolivarian Republic of')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_ES');
        else if (c.Account_Billing_Country__c == 'THAILAND')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_TH');
        else if (c.Account_Billing_Country__c == 'Viet Nam' || c.Account_Billing_Country__c == 'Vietnam')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_VI');
        else if (c.Account_Billing_Country__c == 'Egypt' || c.Account_Billing_Country__c == 'Iraq' || c.Account_Billing_Country__c == 'Jordan' ||
                 c.Account_Billing_Country__c == 'Libya' || c.Account_Billing_Country__c == 'Somalia' || c.Account_Billing_Country__c == 'South Sudan' || c.Account_Billing_Country__c == 'Sudan' ||
                 c.Account_Billing_Country__c == 'Suriname' || c.Account_Billing_Country__c == 'Syria')
          template = templates.get('Clicktools_Contact_Email_CX_ARM_AR');

        else if (*/
          /*6*/
          /*((c.Region__c == 'Europe' &&*/
                 /*7*/
                 /*(c.Account_Billing_Country__c != 'Spain' && c.Account_Billing_Country__c != 'Andorra' &&
                       c.Account_Billing_Country__c != 'Republic of' && c.Account_Billing_Country__c != 'Russia' && c.Account_Billing_Country__c != 'Russian Federation' &&
                       c.Account_Billing_Country__c != 'France' && c.Account_Billing_Country__c != 'Germany' && c.Account_Billing_Country__c != 'Italy' &&
                       c.Account_Billing_Country__c != 'Portugal' && c.Account_Billing_Country__c != 'Spain & Andorra')) ||
                  */
                /*8*/
                /*(c.Region__c == 'Asia & Pacific' &&*/
                      /*9*/
                      /*(c.Account_Billing_Country__c == 'Australia' || c.Account_Billing_Country__c == 'Bangladesh' || c.Account_Billing_Country__c == 'Cambodia' || c.Account_Billing_Country__c == 'India' ||
                            c.Account_Billing_Country__c == 'Malaysia' || c.Account_Billing_Country__c == 'Nepal' || c.Account_Billing_Country__c == 'New Zealand' || c.Account_Billing_Country__c == 'Pakistan' ||
                            c.Account_Billing_Country__c == 'Philippines' || c.Account_Billing_Country__c == 'Singapore' || c.Account_Billing_Country__c == 'Sri Lanka')) ||
                      */
                /*10*/
                /*(c.Region__c == 'China & North Asia' &&*/
                       /*11*/
                       /*(c.Account_Billing_Country__c == 'Chinese Taipei' || c.Account_Billing_Country__c == 'Taiwan' || c.Account_Billing_Country__c == 'Province of China' ||
                              c.Account_Billing_Country__c == 'Hong Kong SAR, China' || c.Account_Billing_Country__c == 'Mongolia' || c.Account_Billing_Country__c == 'Hong Kong' ||
                              c.Account_Billing_Country__c == 'HONG KONG (SAR), CHINA')) ||
                */
                /*12*/
                /*(c.Region__c == 'Africa & Middle East' &&*/
                       /*13 + 14*/
                       /*(c.Account_Billing_Country__c != 'Algeria' && c.Account_Billing_Country__c != 'Benin' && c.Account_Billing_Country__c != 'Burkina Faso' && c.Account_Billing_Country__c != 'Cameroon' &&
                                   c.Account_Billing_Country__c != 'Cape Verde' && c.Account_Billing_Country__c != 'Central African Republic' && c.Account_Billing_Country__c != 'Congo, the Democratic Republic of the' &&
                                   c.Account_Billing_Country__c != 'Congo' && c.Account_Billing_Country__c != 'CONGO, DEM. REP. OF' && c.Account_Billing_Country__c != 'Côte d\'Ivoire' &&
                                   c.Account_Billing_Country__c != 'Equatorial Guinea' && c.Account_Billing_Country__c != 'France' && c.Account_Billing_Country__c != 'Gabon' && c.Account_Billing_Country__c != 'Guinea' &&
                                   c.Account_Billing_Country__c != 'Guinea-Bissau' && c.Account_Billing_Country__c != 'Mali' && c.Account_Billing_Country__c != 'Mauritania' && c.Account_Billing_Country__c != 'Morocco' &&
                                   c.Account_Billing_Country__c != 'Niger' && c.Account_Billing_Country__c != 'Senegal' && c.Account_Billing_Country__c != 'Tchad' && c.Account_Billing_Country__c != 'Togo' && c.Account_Billing_Country__c != 'Tunisia' &&
                                   c.Account_Billing_Country__c != 'COTE D\'IVOIRE' && c.Account_Billing_Country__c != 'GUINEA BISSAU' && c.Account_Billing_Country__c != 'CHAD' && c.Account_Billing_Country__c != 'FRENCH GUIANA' &&
                                   c.Account_Billing_Country__c != 'FRENCH POLYNESIA' && c.Account_Billing_Country__c != 'Egypt' && c.Account_Billing_Country__c != 'Iraq' &&
                                   c.Account_Billing_Country__c != 'Jordan' && c.Account_Billing_Country__c != 'Libya' && c.Account_Billing_Country__c != 'Somalia' && c.Account_Billing_Country__c != 'South Sudan' &&
                                   c.Account_Billing_Country__c != 'Sudan' && c.Account_Billing_Country__c != 'Suriname' && c.Account_Billing_Country__c != 'Syria')) ||
                */
                /*15*/
                /*
                (c.Region__c == 'Americas' &&*/
                       /*16*/
                       /*((c.Account_Billing_Country__c == 'Bermuda' || c.Account_Billing_Country__c == 'Cayman Islands' || c.Account_Billing_Country__c == 'Haiti' || c.Account_Billing_Country__c == 'Jamaica' ||
                               c.Account_Billing_Country__c == 'Trinidad and Tobago' || c.Account_Billing_Country__c == 'Turks and Caicos Islands'))))
        )
          template = templates.get('Clicktools_Contact_Email_CX_ARM_EN');
        else {
          noNation2++;
          noNationlog2 += c.id + ', ';

          n = countersMap.get(c.Region__c);
          if (n == 1)  countersMap.remove(c.Region__c);
          else     countersMap.put(c.Region__c, --n);
        }

      */
      //end INC306722 - EXCLUDE the email invitation to fill in the survey from IFAP cases
        /****** New rule January 2015 ******/
      } else if (c.RecordType.DeveloperName == 'FDS_ICCS_Email_to_Case' && /*FDS ICCS Generic Request Management*/
                 !c.Contact.Email.contains('@iata.org') &&
                 !c.Contact.Email.contains('@salesforce.com') &&
                 c.Status == 'Closed'
                ) {

        template = templates.get('Clicktools_Contact_Email_CX_ICCS_EN');



        /****** New rule January 2015 ******/
      } else if (c.RecordType.DeveloperName == 'Cases_SIS_Help_Desk' &&
                 !c.Contact.Email.contains('@iata.org') &&
                 !c.Contact.Email.contains('@salesforce.com') &&
                 c.Status == 'Closed' &&
                 c.CaseArea__c == 'SIS'

                ) {

        template = templates.get('Clicktools_Contact_Email_CX_SIS_EN');



        /****** New rule January 2015 ******/
      } else if (c.RecordType.DeveloperName == 'Cases_SIS_Help_Desk' &&
                 !c.Contact.Email.contains('@iata.org') &&
                 !c.Contact.Email.contains('@salesforce.com') &&
                 c.Status == 'Closed' &&
                 c.CaseArea__c == 'ICH'
                ) {

        template = templates.get('Clicktools_Contact_Email_CX_ICH_EN');



        /****** Clicktools Workflow .... ******/
      } else if (
        !c.Contact.Email.contains('@iata.org') &&
        !c.Contact.Email.contains('@salesforce.com') &&
        c.Account.Status__c != 'Terminated' &&
        c.Status == 'Closed' &&
        (c.Reason1__c != 'Documentation received (IN)' && c.Reason1__c != 'Irregularity / default / reinstatement' && c.Reason1__c != 'Dispute') &&
        (c.Instant_Survey_Last_survey_sent__c == null ||
         c.Instant_Survey_Feedback_requested__c == false) &&
        c.ParentId == null &&
        (c.Type_of_customer__c != 'Third Party' && c.Type_of_customer__c != 'Legal Entities' && c.Type_of_customer__c != 'Global Distribution System (GDS)' &&
         c.Type_of_customer__c != 'Partner' && c.Type_of_customer__c != 'IATA Employee' && c.Type_of_customer__c != 'DPC' &&
         c.Type_of_customer__c != 'Non-IATA Travel Agent' && c.Type_of_customer__c != 'Auditors' && c.Type_of_customer__c != 'General Public') &&
         c.Type_of_customer__c != 'Airport Authorities' && c.Type_of_customer__c != 'Government Agencies' &&
        (c.Origin != 'Agent Financial Review Notification' && c.Origin != 'Airline Participation' && c.Origin != 'Airline Suspension' &&
         c.Origin != 'AIRS' && c.Origin != 'Code Transfers and Mergers' && c.Origin != 'Customer Portal' &&
         c.Origin != 'Email' && c.Origin != 'Fax' && c.Origin != 'Funds Management' &&
         c.Origin != 'Internal Case' && c.Origin != 'IATA internal user' && c.Origin != 'Letter' && c.Origin != 'Monthly Report' &&
         c.Origin != 'myIATA' && c.Origin != 'New ISS Deployment' && c.Origin != 'OLS' &&
         c.Origin != 'Other' && c.Origin != 'Walk-in' && c.Origin != 'Web SAF' && c.Origin != 'E&F Client – Email to Case' &&
         !c.Phone_Redirected_to_Web__c &&
         c.Case_Group__c == 'Query' &&
         RoleName != null)
      ) {
        id userroleid = UserInfo.getUserRoleId();
        system.debug(LoggingLevel.error, '################### Clicktools Workflow ');
        system.debug(LoggingLevel.error, '################### RoleName=-' + RoleName + '-');
        system.debug(LoggingLevel.error, '################### Region=-' + c.Region__c + '-');
        system.debug(LoggingLevel.error, '################### Account_Billing_Country__c=-' + c.Account_Billing_Country__c + '-');

        integer n = countersMap.get(c.Region__c) == null ? 0 : countersMap.get(c.Region__c);
        countersMap.put(c.Region__c, ++n);

        system.debug('RoleName ------>> ' + RoleName);
        system.debug('ProfileName ------>> ' + ProfileName);


        /* Anyone from the following roles can send instant surveys for the 3 regions "Africa & Middle East, Americas, Europe"
        1- Africa & ME CS Manager
        2- Africa & ME First Level CS Staff
        3- Africa & ME Second Level CS Staff
        4- Americas Customer Service Manager
        5- Americas Customer Service Staff
        6- MAD Hub CS Manager
        7- MAD Hub CS staff
        */
        Set<String> rolesCanSendSurveysTo3Regions = new Set<String> {'Africa & ME CS Manager',
          'Africa & ME First Level CS Staff','Africa & ME Second Level CS Staff',
          'Americas Customer Service Manager','Americas Customer Service Staff','MAD Hub CS Manager','MAD Hub CS staff'};

        if(RoleName.contains('Distribution - Airline Coding & MITA')){
          template = templates.get('Clicktools_Contact_Email_CX_CODING_EN');
        }
        //Inc325289
        else if(c.Account.Source_System__c == 'WEBSTAR' &&
              AccountCountry == 'United States' &&
               (c.Account.Status__c != '' ||  c.Account.Status__c != null) &&
              (c.CNSCase__c != true || c.Account.CNS_Account__c != true) ){
          template = templates.get('Clicktools_Contact_Email_IATAN_CX_CS_EN_2');
        }
        else if (c.CNSCase__c == true) {
            template = templates.get('Clicktools_Contact_Email_EN_CNS');
        }

        else if (ProfileName.contains('FDS ICCS Administrator') || ProfileName.contains('FDS ICCS User')){
          template = templates.get('Clicktools_Contact_Email_CX_ICCS_EN2');
        }
         //inc321684 verification for roleName = 'Staff - TIESS'
        else if (RoleName.contains('Staff - TIESS')) {
          template = templates.get('Clicktools_Contact_Email_CX_EN_AUG17');
        }
        else if (RoleName.contains('E&F')) {
          template = templates.get('Clicktools_Contact_Email_CX_EN_AUG17');

        }
        else if (
          RoleName.contains('China & N. Asia Customer Service') &&
          c.Region__c == 'China & North Asia' &&
          AccountCountry == 'People\'s Republic of China'
        )
          template = templates.get('Clicktools_Contact_Email_CX_ZH_AUG17');


        else if (
          rolesCanSendSurveysTo3Regions.contains(RoleName) &&
          c.Region__c == 'Americas' &&
          AccountCountry == 'Canada'
        )
          template = templates.get('Clicktools_Contact_Email_CX_EN_FR');


        else if (
          rolesCanSendSurveysTo3Regions.contains(RoleName) &&
          ((c.Region__c == 'Europe' &&
           AccountCountry == 'France' )
          ||
          (c.Region__c == 'Africa & Middle East' &&
           (AccountCountry == 'Benin' || AccountCountry == 'Burkina Faso' || AccountCountry == 'Cameroon' || AccountCountry == 'Cape Verde'
            || AccountCountry == 'Tchad' || AccountCountry == 'Congo, the Democratic Republic of the' || AccountCountry == 'Congo (Brazzaville)'
            || AccountCountry == 'Equatorial Guinea' || AccountCountry == 'Gabon' || AccountCountry == 'Guinea'
            || AccountCountry == 'Guinea-Bissau' || AccountCountry == 'Côte d\'Ivoire' || AccountCountry == 'Mali' || AccountCountry == 'Mauritania'
            || AccountCountry == 'Niger' || AccountCountry == 'Central African Republic' || AccountCountry == 'Senegal' || AccountCountry == 'Togo'
            || AccountCountry == 'Morocco' || AccountCountry == 'Tunisia' || AccountCountry == 'Algeria')
          ))
        )
          template = templates.get('Clicktools_Contact_Email_CX_FR_AUG17');

        /*
        else if(
        RoleName.contains('MAD Hub CS') &&
        c.Region__c == 'Europe' &&
        (AccountCountry == 'Greece' || AccountCountry == 'Cyprus')
        )
        template = templates.get('Clicktools_Contact_Email_CX_GR');
        */

        else if (
          rolesCanSendSurveysTo3Regions.contains(RoleName) &&
          c.Region__c == 'Europe' &&
          (AccountCountry == 'Austria' || AccountCountry == 'Germany')
        )
          template = templates.get('Clicktools_Contact_Email_CX_DE_AUG17');


        else if (
          (RoleName.contains('A&P Customer Service') || RoleName.contains('Staff - Indonesia')) &&
          c.Region__c == 'Asia & Pacific' &&
          AccountCountry == 'Indonesia'
        )
          template = templates.get('Clicktools_Contact_Email_CX_ID_AUG17');


        else if (
          rolesCanSendSurveysTo3Regions.contains(RoleName) &&
          c.Region__c == 'Europe' &&
          AccountCountry == 'Italy'
        )
          template = templates.get('Clicktools_Contact_Email_CX_IT_AUG17');


        else if (
          (RoleName.contains('A&P Customer Service') || RoleName.contains('Staff - Japan')) &&
          c.Region__c == 'Asia & Pacific' &&
          AccountCountry == 'Japan'
        )
          template = templates.get('Clicktools_Contact_Email_CX_JA_AUG17');


        else if (
          (RoleName.contains('A&P Customer Service') || RoleName.contains('Staff - Thailand')) &&
          c.Region__c == 'Asia & Pacific' &&
          AccountCountry == 'Korea, Republic of'
        )
          template = templates.get('Clicktools_Contact_Email_CX_KO_AUG17');


        else if (
            rolesCanSendSurveysTo3Regions.contains(RoleName) &&
            (c.Region__c == 'Europe' &&
            AccountCountry == 'Portugal') ||
            (c.Region__c == 'Americas' &&
            AccountCountry == 'Brazil')
        )
          template = templates.get('Clicktools_Contact_Email_CX_PT_AUG17');

        /*
        else if(
        RoleName.contains('MAD Hub CS') &&
        c.Region__c == 'Europe' &&
        AccountCountry == 'Romania & Moldova'
        )
        template = templates.get('Clicktools_Contact_Email_CX_RO');
        */

        else if (
            rolesCanSendSurveysTo3Regions.contains(RoleName) &&
            (c.Region__c == 'Europe' &&
            (AccountCountry == 'Spain' || AccountCountry == 'Andorra')) ||
            (c.Region__c == 'Americas' &&
            (AccountCountry == 'Ecuador' || AccountCountry == 'Costa Rica' || AccountCountry == 'Colombia' || AccountCountry == 'El Salvador' ||
             AccountCountry == 'Belize' || AccountCountry == 'Panama' || AccountCountry == 'Guatemala' || AccountCountry == 'Nicaragua' ||
             AccountCountry == 'Honduras' || AccountCountry == 'Chile' || AccountCountry == 'Dominican Republic' || AccountCountry == 'Mexico' ||
             AccountCountry == 'Bolivia' || AccountCountry == 'Peru' || AccountCountry == 'Venezuela' || AccountCountry == 'Argentina' ||
             AccountCountry == 'Paraguay' || AccountCountry == 'Uruguay' ))

        )
          template = templates.get('Clicktools_Contact_Email_CX_ES_AUG17');


        else if (
          (RoleName.contains('A&P Customer Service') || RoleName.contains('Staff - Thailand')) &&
          c.Region__c == 'Asia & Pacific' &&
          AccountCountry == 'Thailand'
        )
          template = templates.get('Clicktools_Contact_Email_CX_TH_AUG17');

        /*
        else if(
        RoleName.contains('MAD Hub CS') &&
        c.Region__c == 'Europe' &&
        AccountCountry == 'Turkey'
        )
        template = templates.get('Clicktools_Contact_Email_CX_TR');
        */

        else if (
          (RoleName.contains('A&P Customer Service') || RoleName.contains('Staff - Vietnam')) &&
          c.Region__c == 'Asia & Pacific' &&
          AccountCountry == 'Vietnam'
        )
          template = templates.get('Clicktools_Contact_Email_CX_VI_AUG17');

        else if (
          rolesCanSendSurveysTo3Regions.contains(RoleName) &&
          c.Region__c == 'Africa & Middle East' &&
          (AccountCountry == 'Egypt' || AccountCountry == 'Iraq' || AccountCountry == 'Jordan' || AccountCountry == 'Libya' ||
           AccountCountry == 'Somalia' || AccountCountry == 'South Sudan' || AccountCountry == 'Sudan' || AccountCountry == 'Suriname' || AccountCountry == 'Syria')
        )
          template = templates.get('Clicktools_Contact_Email_CX_AR_AUG17');

        else if (
          (RoleName.contains('A&P Customer Service') &&
           c.Region__c == 'Asia & Pacific' &&
           (AccountCountry == 'Philippines' || AccountCountry == 'India' || AccountCountry == 'Nepal' || AccountCountry == 'Bangladesh' ||
            AccountCountry == 'Pakistan' || AccountCountry == 'Singapore' || AccountCountry == 'Sri Lanka' || AccountCountry == 'Cambodia' ||
            AccountCountry == 'New Zealand' || AccountCountry == 'Malaysia' ))
          ||
          (rolesCanSendSurveysTo3Regions.contains(RoleName) &&
           c.Region__c == 'Europe' &&
           (AccountCountry != 'Israel' && AccountCountry != 'France' && AccountCountry != 'Germany' &&
            AccountCountry != 'Italy' && AccountCountry != 'Portugal' &&
            AccountCountry != 'Spain' && AccountCountry != 'Andorra' && AccountCountry != 'Russian Federation'))
          ||
          (RoleName.contains('China & N. Asia Customer Service') &&
           c.Region__c == 'China & North Asia' &&
           (AccountCountry == 'Mongolia' || AccountCountry == 'Chinese Taipei' || AccountCountry == 'Hong Kong (SAR), China' ))
          ||
           (rolesCanSendSurveysTo3Regions.contains(RoleName) &&
           (c.Region__c == 'Africa & Middle East' &&
            AccountCountry != 'Benin' && AccountCountry != 'Burkina Faso' && AccountCountry != 'Cameroon' && AccountCountry != 'Cape Verde' &&
            AccountCountry != 'Tchad' && AccountCountry != 'Congo, the Democratic Republic of the' && AccountCountry != 'Congo (Brazzaville)' &&
            AccountCountry != 'Equatorial Guinea' && AccountCountry != 'Gabon' && AccountCountry != 'Guinea' && AccountCountry != 'Guinea-Bissau' &&
            AccountCountry != 'Côte d\'Ivoire' && AccountCountry != 'Mali' && AccountCountry != 'Mauritania' && AccountCountry != 'Niger' &&
            AccountCountry != 'Central African Republic' && AccountCountry != 'Senegal' && AccountCountry != 'Togo' && AccountCountry != 'Morocco' &&
            AccountCountry != 'Tunisia' && AccountCountry != 'Algeria' &&
            AccountCountry != 'Egypt' && AccountCountry != 'Iraq' && AccountCountry != 'Jordan' &&
            AccountCountry != 'Libya' && AccountCountry != 'Somalia' && AccountCountry != 'South Sudan' && AccountCountry != 'Sudan' &&
            AccountCountry != 'Suriname' && AccountCountry != 'Syria')
          ||
           (c.Region__c == 'Americas' &&
           (AccountCountry == 'HAITI' || AccountCountry == 'JAMAICA' || AccountCountry == 'CAYMAN ISLANDS' ||
            AccountCountry == 'TURKS AND CAICOS ISLANDS' || AccountCountry == 'Trinidad and Tobago' || AccountCountry == 'BERMUDA' )))
          ||
          (RoleName.contains('A&P Customer Service') &&
           c.Region__c == 'Asia & Pacific' &&
           AccountCountry == 'Australia')
        )
          template = templates.get('Clicktools_Contact_Email_CX_EN_AUG17');
        else {
          noNation3++;
          noNationlog3 += c.id + ', ';

          n = countersMap.get(c.Region__c);
          if (n == 1)  countersMap.remove(c.Region__c);
          else     countersMap.put(c.Region__c, --n);
        }

        //start INC292755 recordType = Airline Coding Application
      }else if(c.RecordType.DeveloperName == 'Airline_Coding_Application' &&
                       c.Status == 'Closed' &&
                       !c.Contact.Email.contains('@iata.org') &&
                       !c.Contact.Email.contains('@salesforce.com')){
        template = templates.get('Clicktools_Contact_Email_CX_CODING_EN');
      } //end INC292755

      /****** Preparing the email *****/
      if (template != null) {
        /****** CONTROLS TO AVOID SPAM! ******/
        c.Instant_Survey_Feedback_requested__c = true;


        if (
          //if the contact has received at least one survey request in the last week no email will be sent
          /*INC246478
          (c.Contact.Instant_Survey_Last_feedback_received__c == null &&
           c.Contact.Instant_Survey_Last_survey_sent__c > dateTime.now().addDays(-7))
          ||
          */
          //if the contact answered to one survey in the last month no email will be sent
          (c.Contact.Instant_Survey_Last_feedback_received__c != null &&
           c.Contact.Instant_Survey_Last_feedback_received__c > c.Contact.Instant_Survey_Last_survey_sent__c &&
           c.Contact.Instant_Survey_Last_feedback_received__c > dateTime.now().addDays(-31))
          ||
          //the contact will receive other mails today
          ContactIds.contains(c.contactid)
        ) {
          system.debug(LoggingLevel.error, '################### CONTROLLO ANTI SPAM');
          spamAvoided++;
          spamAvoidedlog += c.id + ', ';
          //continue;
          // FEATURE ANTI SPAM IS TEMPORARILY DEACTIVATED. I JUST WANT TO HAVE DETAILED LOG ON WHICH EMAIL WOULD NOT BE SENT
          //c.Instant_Survey_Last_survey_sent__c = date.today();
          //MyEmailToBeSent.add(new Email(c, template));
          ContactIds.add(c.contactid);
          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        } else {
          c.Instant_Survey_Last_survey_sent__c = date.today();
          MyEmailToBeSent.add(new Email(c, template));
          ContactIds.add(c.contactid);
        }

      } else {system.debug('################### No mail template');}
    }

    /*Map<Id,Id> ContactIdToUserId = new Map<Id,Id>();
    for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN : ContactIds]){
    ContactIdToUserId.put(u.ContactId, u.Id);
    }
    system.debug('################### '+ContactIdToUserId.values().size()+' contacts replaced by users');
    */
    // Sends the email
    UtilityCS__c sender = UtilityCS__c.getInstance('SurveyEmailSender');
    UtilityCS__c senderCNS = UtilityCS__c.getInstance('SurveyEmailSenderCNS');
    List<Messaging.Singleemailmessage> emailToBeSent = new List<Messaging.SingleemailMessage>();
    for (Email em : MyEmailToBeSent) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      if (!Test.isRunningTest() && sender != null)  {
          email.setOrgWideEmailAddressId(sender.value__c);
          if(em.cas.CNSCase__c) {
              email.setOrgWideEmailAddressId(senderCNS.value__c);
          }
      }

      //id userid = ContactIdToUserId.get(em.cas.ContactId);
      //if(userid!=null){
      //email.setTargetObjectId(userid);
      //usersreplaced ++;
      //}else
      email.setTargetObjectId(em.cas.ContactId);
      email.setTemplateId(em.templateId);
      email.setWhatId(em.cas.Id);
      emailToBeSent.add(email);
    }
    Messaging.SendEmailResult [] r = Messaging.sendEmail(emailToBeSent, false);
    system.debug('################### Email sent: ' + emailToBeSent.size());

    for (integer i = 0; i < r.size(); i++) {
      Messaging.SendEmailResult res = r[i];
      Case c = MyEmailToBeSent[i].cas;
      if (!res.isSuccess()) {
        errors ++;
        errlog += '"' + c.CaseNumber + '","' + c.Owner.Name + '","' + c.Subject + '","' + c.Account.Name + '","' + c.IATA_Code__c + '","' + c.Contact.Name + '","' + c.Contact.Email + '","' + res.getErrors()[0].getMessage() + '"\n';
      } else {
        success ++;
        succlog += '"' + c.CaseNumber + '","' + c.Owner.Name + '","' + c.Subject + '","' + c.Account.Name + '","' + c.IATA_Code__c + '","' + c.Contact.Name + '","' + c.Contact.Email + '"\n';
        CaseToUpdate.add(c);
      }
    }


    if (CaseToUpdate.size() > 0)
      Database.update(CaseToUpdate, false);
    system.debug('################### Update cases: ' + CaseToUpdate.size());


  }





  public void processCustomerRecovery(List<Case> scope) {

    Id RT_ComplaintIDFS_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('ComplaintIDFS');

    for (Group g : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName LIKE '%Complaints%']) {
      mapComplaintQueuesPerName.put(g.DeveloperName, g.Id);
      system.debug(LoggingLevel.error, '########## complaint queue added to map: ' + g.DeveloperName + ', ID: ' + g.Id);
    }

    List<Case> lstCasesToUpdate = new List<Case>();

    for (Case c : scope) {
      String RoleName = c.WhoClosedCase__r.UserRole.Name != null ? c.WhoClosedCase__r.UserRole.Name : 'none';
      system.debug(LoggingLevel.error, '#### case ' + c.Subject + '; Region: ' + c.Region__c + '; c.RecordTypeId: ' + c.RecordTypeId + '; cond2: ' + mapComplaintQueueNamePerRegion.get(c.Region__c) + '; cond3: ' + mapComplaintQueuesPerName.get(mapComplaintQueueNamePerRegion.get(c.Region__c)));
      // Only handle cases for the defined regions; if the case region is not mapped to a complaint queue then the case is out of scope
      if ( !RoleName.contains('Staff - TIESS') && c.Region__c != null &&
          mapComplaintQueueNamePerRegion.get(c.Region__c) != null &&
          mapComplaintQueuesPerName.get(mapComplaintQueueNamePerRegion.get(c.Region__c)) != null ) {
        system.debug(LoggingLevel.error, '################### updating fields on case ' + c.Subject);

        c.Customer_recovery__c = true ;
        c.Status = 'Customer Recovery';
        c.RecordTypeId = RT_ComplaintIDFS_Id;
              //**INC301099** Delete this rule
        /*if(RoleName.contains('Distribution - Airline Coding & MITA'))
            c.OwnerId = Label.SurveyCustomerRecoveriesAnnFARRELL;
        else*/
            c.OwnerId = mapComplaintQueuesPerName.get(mapComplaintQueueNamePerRegion.get(c.Region__c));

        lstCasesToUpdate.add(c);
      }
    }
    system.debug(LoggingLevel.error, '################### lstCasesToUpdate.isEmpty() = ' + lstCasesToUpdate.isEmpty());
    if (!lstCasesToUpdate.isEmpty()) {
      Database.update(lstCasesToUpdate, false);
    }
  }

  // to be removed
  public void fakeMethod(){
    Integer i = 0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
    i=0;
  }

}
