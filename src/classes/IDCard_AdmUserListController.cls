global with sharing class IDCard_AdmUserListController extends IDCardAbstractController {
  public Contact loggedContact {get; set;}
  public List<Contact> conts {get; set;}
  public Account mainAccount {get; set;}
  public ContactProxy nc {get; set;}

  public boolean showRenewReissue {get; set;}
  public boolean NewContactQuestionResult {get; set;}
  public boolean enableMassImport {get; set;}
  public boolean selectall {get; set;}
  public boolean importBatchStarted {get; set;}
  public integer importBatchTot {get; set;}
  public integer importBatchSucc {get; set;}
  public integer importBatchErr {get; set;}
  public string importAppType {get; set;}

  public string RenewReissueMode {get; set;}
  public List<SelectOption> packages {get; set;}
  public List<SelectOption> accountCodes {get; set;}
  public List<SelectOption> appTypes {get; set;}

  public id ContactToEditId {get; set;}
  public Map<string, ContactViewProxy> contMap {get; set;}
  //public Map<string,ContactViewProxy> contMap{get;set;}

  private final string CANCELLED = 'Cancelled ID Card';

  public boolean createNewIDCardApp {get; set;}
  public Blob file {get; set;}
  public string verParameter {get; set;}

  private string adminName;
  private string adminEmail;

  public boolean FASTVERSION {get; set;}

  public static Integer STATUS_UNDEFINED = -1;
  public static Integer STATUS_PENDING_APP = 0;
  public static Integer STATUS_PENDING_PAYMENT_APP = 1;
  public static Integer STATUS_EXISTING_VALID_CARD = 2;
  public static Integer STATUS_EXISTING_UNVALID_CARD = 3;
  public static Integer STATUS_BLACKLISTED_CARD = 4;
  public static Integer STATUS_CANCELLED_APP = 5;

  public transient Map<String, ContactViewProxy2> listedContact {get; set;}
  public transient Map<String, ContactViewProxy2> blacklistedContact {get; set;}
  public Map<String, Boolean> selectedContact {get; set;}
  private List<ContactViewProxy2> cancelledContacts {get; set;}

  public IDCard_AdmUserListController () {
    initialize(true);
    // Get the key contact
    try {
      //printErr('iataCodeParameter='+iataCodeParameter+' - vernumParameter='+vernumParameter);
      loggedContact = [SELECT Name, Email, IDCard_Email__c, IATA_code__c, IDCard_Batch_Status__c, VER_Number_2__c
                       FROM Contact
                       //WHERE Id in (SELECT contact__c from Managed_agency__c where Account__r.IATACode__c = :iataCodeParameter)
                       //AND VER_Number_2__c = :vernumParameter
                       WHERE VER_Number_2__c = :vernumParameter
                           AND IATA_Code__c = :iataCodeParameter
                                              LIMIT 1];

      for (Managed_agency__c ma : keyContactAndDelegateForAccountList.values()) {
        if (ma.Account__r.IATAcode__c == iataCodeParameter) {
          mainAccount = ma.Account__r;
          adminName = ma.Contact__r.Name;
          adminEmail = ma.Contact__r.Email;
        }
      }
    } catch (Exception e) {
      printErr('Login has expired. Please go back and login again.' + e.getMessage());
      return;
    }
    selectall = false;
    enableMassImport = (mainAccount != null && mainAccount.ID_Card_KeyAccount_features__c != null && mainAccount.ID_Card_KeyAccount_features__c.contains(IDCArdUtil.Key_Account_Feature_File));

    // Get all the contacts for this account and keep counters up to date

    loadContacts2();
    FASTVERSION = listedContact.keyset().size() <= 2500;


    packages = new List<SelectOption>();
    packages.add(new SelectOption('', '--None--'));
    for (Schema.PicklistEntry ple : ID_Card_Application__c.Package_of_Travel_Professionals_Course_1__c.getDescribe().getPicklistValues())
      packages.add(new SelectOption(ple.getValue(), ple.getLabel()));



    appTypes = new List<SelectOption>();
    appTypes.add(new SelectOption('', '--None--'));
    for (Schema.PicklistEntry ple : ID_Card_Application__c.Type_of_application__c.getDescribe().getPicklistValues())
      appTypes.add(new SelectOption(ple.getValue(), ple.getLabel()));


  }

  public void loadContacts2() {
    //0 init maps
    listedContact = new Map<String, ContactViewProxy2>();
    selectedContact = new Map<String, boolean>();
    blacklistedContact = new Map<String, ContactViewProxy2>();
    cancelledContacts = new List<ContactViewProxy2>();
    ContactViewProxy2 cpcc;

    //1 select ID card existing in system
    for (ID_Card__c idc : [ Select i.VER_Number__c, i.Is_Active_Card__c, i.Date_Of_Birth__c,     i.Valid_To_Date__c, i.Photo__c, i.Name_on_ID_Card__c, i.Id, i.ID_Card_Application__c, i.Card_Status__c, i.Cancellation_Date__c, i.Blacklisted__c, i.Agency_IATA_Code__c
                            From ID_Card__c i
                            where Agency_IATA_Code__c in:keyContactAndDelegateForAccountList.keySet()
                            order by Valid_To_Date__c DESC]) {

      if (idc.Cancellation_Date__c != null) {
        cpcc = new ContactViewProxy2();
        cpcc.VER = idc.VER_Number__c;
        //cpcc.VER = '6124041851';
        cpcc.validityDate = idc.Valid_To_Date__c;
        cancelledContacts.add(cpcc);
      }

      if (blacklistedContact.get(idc.VER_Number__c) == null) {
        ContactViewProxy2 cp = listedContact.get(idc.VER_Number__c);
        if (cp == null)
          cp = new ContactViewProxy2();
        cp.ver = idc.VER_Number__c;


        //if blacklisted: no need to go ahead.
        if (idc.Blacklisted__c) {
          blacklistedContact.put(idc.VER_Number__c, cp);
          listedContact.remove(idc.VER_Number__c);
          cp.status = STATUS_BLACKLISTED_CARD;
        } else {
          //if status !0 valid : set as cancel if needed

          if (idc.Cancellation_Date__c != null && cp.status != STATUS_EXISTING_VALID_CARD && (cp.status == STATUS_UNDEFINED || cp.validityDate < idc.Valid_To_Date__c)) {
            cp.status = STATUS_CANCELLED_APP;
            cp.appIATAcode = idc.Agency_IATA_Code__c;
            cp.displayName = idc.Name_on_ID_Card__c;
            cp.hasPhoto = true;
            cp.validityDate = null;
            cp.PrintableValidityDate = idc.Cancellation_Date__c == null ? '' : idc.Cancellation_Date__c.month() + '/' + idc.Cancellation_Date__c.day() + '/' + idc.Cancellation_Date__c.year();
            system.debug('--------------------------------------------------------------------------');
            system.debug('VER_Number_2__c: ' + idc.VER_Number__c + '; Cancellation_Date__c: ' + idc.Cancellation_Date__c + '; Valid_To_Date__c: ' + idc.Valid_To_Date__c + '; Agency_IATA_Code__c: ' + idc.Agency_IATA_Code__c);
            system.debug('--------------------------------------------------------------------------');
          }
          // if idc is  valid
          else if (idc.Cancellation_Date__c == null) {
            if (cp.validityDate == null || (cp.validityDate <  idc.Valid_To_Date__c && idc.Is_Active_Card__c)) {
              cp.validityDate = idc.Valid_To_Date__c;
              cp.PrintableValidityDate = idc.Valid_To_Date__c == null ? '' : idc.Valid_To_Date__c.month() + '/' + idc.Valid_To_Date__c.day() + '/' + idc.Valid_To_Date__c.year();
              cp.displayName = idc.Name_on_ID_Card__c;
              cp.appIATAcode = idc.Agency_IATA_Code__c;
              cp.birthdate = idc.Date_Of_Birth__c == null ? '' : idc.Date_Of_Birth__c.month() + '/' + idc.Date_Of_Birth__c.day() + '/' + idc.Date_Of_Birth__c.year();

              //if we have an id crd then we have a picture. to validate
              //@TODO
              cp.hasPhoto = true;
              if (cp.validityDate >= Date.today())
                cp.status = STATUS_EXISTING_VALID_CARD;
              else
                cp.status = STATUS_EXISTING_UNVALID_CARD;
            }
          }
        }
        listedContact.put(idc.VER_Number__c, cp);
        selectedContact.put(idc.VER_Number__c , false);
      }

    }
    //process according to ID Card App pendign as a single application
    String singeAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
    String standardAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Standard');

    for (ID_Card_Application__c  idca : [Select i.VER_Number__c, i.Photo__c,  i.Type_of_application__c, i.Single_Application_Processing_Step__c, i.RecordTypeId,
                                         i.Mass_order_Application__c,  i.IATA_Code__c, i.Displayed_Name__c, i.Application_Status__c, i.Date_of_birth__c
                                         From ID_Card_Application__c i
                                         where IATA_Code__c in:keyContactAndDelegateForAccountList.keySet()
                                         and (Application_Status__c = 'Pending' or Application_Status__c = 'Unpaid'  )
                                         and (RecordTypeId = :singeAppRT or RecordTypeId = :standardAppRT)]) {
      if (blacklistedContact.get(idca.VER_Number__c) == null) {
        ContactViewProxy2 cp = listedContact.get(idca.VER_Number__c);
        if (cp == null)
          cp = new ContactViewProxy2();
        cp.ver = idca.VER_Number__c;
        cp.birthDate = idca.Date_of_Birth__c == null ? '' : idca.Date_of_Birth__c.month() + '/' + idca.Date_of_Birth__c.day() + '/' + idca.Date_of_Birth__c.year();
        if (cp.status == STATUS_UNDEFINED) {
          cp.displayName = idca.Displayed_Name__c;
          cp.hasPhoto = (idca.Photo__c != null && idca.Photo__c != '');
          cp.appIATAcode = idca.IATA_Code__c;
          if (idca.Application_Status__c == 'Pending'  || idca.Application_Status__c == 'Unpaid')
            cp.status = STATUS_PENDING_APP;
          else
            cp.status = STATUS_EXISTING_UNVALID_CARD;
        } else {
          //Application_Status__c = 'Pending' or Application_Status__c = 'Unpaid'
          if (idca.Application_Status__c == 'Pending' || idca.Application_Status__c == 'Unpaid')
            cp.status = STATUS_PENDING_APP;
          else
            cp.status = STATUS_EXISTING_UNVALID_CARD;
        }

        listedContact.put(idca.VER_Number__c, cp);
        selectedContact.put(idca.VER_Number__c, false);
      }
    }
    // forexsiting proxy contact get he name of contact.
    listedContact.remove(null);
    Map<String, ContactViewProxy2> tmp2delete = new Map<String, ContactViewProxy2>();

    for (Contact c : [select Name, Date_of_Birth__c, VER_Number_2__c, Iata_code__c from Contact where VER_Number_2__c in :listedContact.keySet() ]) {
      // if(c.VER_Number_2__c == '5990055584'){ printerr('Ho cercato il contatto '+c.id+' perchè listed contact contiene '+listedContact.get(c.VER_Number_2__c));}
      ContactViewProxy2 cp = listedContact.get(c.VER_Number_2__c);
      cp.contactName = c.Name;
      cp.birthDate = c.Date_of_Birth__c == null ? '' : c.Date_of_Birth__c.month() + '/' + c.Date_of_Birth__c.day() + '/' + c.Date_of_Birth__c.year();
      //excude those who had changed since last card
      if (cp.status == STATUS_CANCELLED_APP && keyContactAndDelegateForAccountList.get( c.Iata_code__c) == null) {
        listedContact.remove(c.VER_Number_2__c);
      }
      //exclude those who have a cancelled or blacklisted id card
      if (cp.status == STATUS_CANCELLED_APP || cp.status == STATUS_BLACKLISTED_CARD)
        listedContact.remove(c.VER_Number_2__c);

    }
    /*
    if (listedContact.size()>0) {
        system.debug('######size: ' + listedContact.size());
        for (ContactViewProxy2 i: listedContact.values()) {
        String previousName = i.contactName;

        //system.debug('displayName - '  + i.displayName + '; contactName - ' + i.contactName +'; validityDate - ' + i.validityDate +'; validFromDate - ' + i.validFromDate);
        system.debug('--------------------------------------------------------------------------');

      }
    }
    */
    for (ContactViewProxy2 cc : cancelledContacts) {
      if (listedContact.containsKey(cc.VER) && cc.validityDate > listedContact.get(cc.VER).validityDate) {
        listedContact.remove(cc.VER);
      }
    }

  }


  public string getHTMLtable() {
    string res = '';
    if (listedContact == null) loadContacts2();

    blacklistedContact.clear();
    selectedContact.clear();
    res += '<table id="pendingApplicationTable" class="display" >'
           + '   <thead>'
           + '        <tr>'
           + '             <th style="width:2em;text-align:center"> <input type="checkbox" class="selectAll" onchange="selectAll()" style="width:1em;"> </th>'
           + '             <th>' + Label.IDCard_ka_applicant + ' [ID Card Name	]</th>'
           + '     		<th>' + Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('Date_of_Birth__c').getDescribe().getLabel().toUpperCase() + '</th>'
           + '             <th>' + Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('IATA_code__c').getDescribe().getLabel().toUpperCase() + '</th>'
           + '             <th>' + Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('VER_Number_2__c').getDescribe().getLabel().toUpperCase() + '</th>'
           + '             <th>' + Label.IDCard_Validity_Date.toUpperCase() + '</th>'
           + '             <th>' + Label.IDCard_hasPhoto.toUpperCase() + '</th>'
           + '             <th style="text-align:center">' + Label.IDCard_ka_actions.toUpperCase() + '</th>'
           + '         </tr>'
           + '   </thead> '
           + '   <tbody>';

    for (string ver : listedContact.keyset()) {
      ContactViewProxy2 cvp = listedContact.get(ver);
      res += '           <tr id="row' + ver + '">'
             + '               <td  class="dttd" style="text-align:center"><input type="checkbox" class="selectCheckBox" onclick="enablebutton()" style="width:1em;" id="' + cvp.VER + '" ' + (cvp.selected ? 'checked' : '') + '>' +
             +'                 <td class="dttd" >' + cvp.contactName + ' [' + cvp.displayName + ']</td>'
             + '                  <td class="dttd" >' + cvp.birthdate + '</td>'
             + '                 <td class="dttd" >' + cvp.appIATAcode + '</td>'
             + '                 <td class="dttd" >' + ver + '</td>'
             + '                 <td class="dttd" >' + cvp.PrintableValidityDate + ' </td>'
             + '                 <td class="dttd">' + (cvp.hasPhoto ? 'OK' : Label.IDCard_MissingPhoto) + '</td>'

             + '<td  class="dttd" >'
             + (cvp.status == 0 ?
                //'<a  class="myLink" href="IDCard_AdmUserForm?ver='+cvp.ver+'"> ' +Label.IDCard_Action_Edit+'</a>':
                Label.IDCard_PortalPage_MenuPendingOps + '...' :
                '')

             + (cvp.status == 1 ?
                Label.IDCard_PortalPage_MenuPendingOps + '...' :
                '')

             + (cvp.status >= 2 ?
                '<a href="#" class="myLink"  onclick="callRenewContact(\'' + cvp.VER + '\')">' + Label.IDCard_Action_Renew + '</a> | '

                + '<a href="#" class="myLink"  onclick="callReissueContact(\'' + cvp.VER + '\')">' + Label.IDCard_Action_Reissue + '</a> | '

                + '<a  href="#" class="myLink" 	onclick="confirmDelete(\'' + cvp.VER + '\')"> ' + Label.IDCard_Delete + '</a>' :
                '')
             + '</td>'
             + '</tr>';

    }
    res += '    </tbody>'
           + '</table> ';
    return res;

  }





  public PageReference goToNewPage() {
    return Page.IDCard_AdmUserForm;
    return new PageReference(pagesurl.get('prefix') + '/IDCard_AdmUserForm');
  }

  public PageReference goToEditPage() {
    return new PageReference('/IDCard_AdmUserForm?ver=' + verParameter);
  }


  public PageReference RenewContact() {
    try {
      //string ver = Apexpages.currentPage().getParameters().get('vernum');
      string ver = verParameter;
      ContactProxy cp = getContact(ver);

      if (cp.idc == null  || cp.idc.Valid_To_Date__c == null) {
        printerr('This employee has not a valid ID card.');
        return null;
      } if (cp.idc.Valid_To_Date__c > date.today().addMonths(3)) {
        printerr('The ID card for ' + cp.c.Name + ' will expire on ' + cp.idc.Valid_To_Date__c.format() + ' and ' +
                 'it \'s not possible to renew an ID card more than 3 months before its expiration.');
        return null;
      }
      List<ID_Card_Application__c> pendingapps = [SELECT Id FROM ID_Card_Application__c
          WHERE VER_Number__c = :ver
                                AND (Application_Status__c = 'Pending' OR
                                     Application_Status__c = 'Unpaid'  OR
                                         (Mass_order_Application__c <> NULL AND Application_Status__c = :IDCardUtil.single_application_status_waiting) )];
      if (pendingapps.size() > 0) {
        printerr('There is already an operation in pending status for this employee.');
        return null;
      }
      RenewReissueMode = 'Renewal';
      nc = cp;
      showRenewReissue = true;
      //return goToEditPage();
    } catch (Exception e) {
      printErr('An error has raised and it is not possible to renew the id card for this applicant. Please contact your key contact for more details (' + adminName + ': ' + adminEmail + '). ' + e.getMessage());
    }
    return null;
  }


  public PageReference ReissueContact() {
    try {
      //string ver = Apexpages.currentPage().getParameters().get('vernum');
      string ver = verParameter;
      ContactProxy cp = getContact(ver);
      if (cp.idc == null) {
        printerr('This employee has not a valid ID card.');
        return null;
      } if (cp.idc.Valid_To_Date__c < date.today()) {
        printerr('The ID card for ' + cp.c.Name + ' has expired on ' + cp.idc.Valid_To_Date__c.format() + ' and ' +
                 'it \'s not possible to reissue an expired ID card.');
        return null;
      } else if (cp.idc.Valid_To_Date__c <= date.today().addMonths(3)) {
        printerr('The ID card for ' + cp.c.Name + ' will expire on ' + cp.idc.Valid_To_Date__c.format() + ' and ' +
                 'it \'s not possible to reissue an ID card which will expire during next 3 months.');
        return null;
      }
      List<ID_Card_Application__c> pendingapps = [SELECT Id FROM ID_Card_Application__c
          WHERE VER_Number__c = :ver
                                AND (Application_Status__c = 'Pending' OR
                                     Application_Status__c = 'Unpaid'  OR
                                         (Mass_order_Application__c <> NULL AND Application_Status__c = :IDCardUtil.single_application_status_waiting)) ];
      if (pendingapps.size() > 0) {
        printerr('There is already an operation in pending status for this employee.');
        return null;
      }
      RenewReissueMode = 'Reissue';
      nc = cp;
      showRenewReissue = true;


      //update: we redirect to form once new Applciation had been created
      //CompleteRenewReissue();



    } catch (Exception e) {
      printErr('An error has raised and it is not possible to reissue the id card for this applicant. Please contact your key contact for more details (' + adminName + ': ' + adminEmail + '). ' + e.getMessage());
    }

    return null;
  }

  public PageReference CompleteRenewReissue() {
    try {
      if ((String.isEmpty(nc.pack1) && !String.isEmpty(nc.pack2)) ||
          (String.isEmpty(nc.pack2) && !String.isEmpty(nc.pack1))) {

        printerr('It is not possible to select only one package.');
        showRenewReissue = false;
        return null;
      }
      Account myAcc = keyContactAndDelegateForAccountList.get(nc.IATAcode).Account__r;
      ID_Card_Application__c idcapp = createApplication(nc.c, myAcc, RenewReissueMode, nc.pack1, nc.pack2);
      idcapp.Photo__c = nc.Photo;
      idcapp.Application_status__c = 'Pending';
      insert idcapp;
      //contMap.get(nc.c.VER_Number_2__c).pending = true;
      //showRenewReissue = false;
      return goToEditPage();
    } catch (Exception e) {
      printErr('An error has raised and it is not possible to renew the id card for this applicant. Please contact your key contact for more details (' + adminName + ': ' + adminEmail + '). ' + e.getStackTraceString());
      showRenewReissue = false;
      return null;
    }
  }




  public string getImageLink() {
    string ver = nc.c.VER_Number_2__c;
    return IDCardUtil.EncryptEncodeParameter(ver).replaceAll('%', '%25');
  }

  /*

  updated:
  blacklist exisitng cards and return tuô same page
  */
  public Pagereference DeleteContact() {
    try {

      //string ver = Apexpages.currentPage().getParameters().get('vernum');
      string ver = verParameter;
      // Completing informations adding the most recent idcard (if exists)
      List<ID_Card__c> idcs = [SELECT Related_Contact__c, Valid_To_Date__c, Blacklisted__c,  VER_Number__c,  Card_status__c, MustSyncWithAIMS__c
                               FROM ID_Card__c
                               WHERE VER_Number__c = :ver
                                   AND Card_Status__c <> :CANCELLED
                                   ORDER BY Valid_To_Date__c DESC
                                   LIMIT 1];
      for (ID_Card__c idc : idcs) {
        //idc.MustSyncWithAIMS__c = true;
        idc.Card_status__c = CANCELLED;
        idc.Cancellation_date__c = date.today();
      }
      update idcs;
      /*Pagereference formPage = Page.IDCard_AdmUserList;
      return formPage;*/
    } catch (Exception e) {
      printErr('An error has raised and it is not possible to edit this contact. Please contact your key contact for more details (' + adminName + ': ' + adminEmail + '). ' + e);
    }
    return null;
  }



  public PageReference newImport() {
    return new PageReference(pagesurl.get('prefix') + '/IDCard_AdmImportCSV');
  }


  public Pagereference Cancel() {
    //file = null;

    showRenewReissue = false;
    RenewReissueMode = null;

    //return null;
    return Page.IDCard_AdmUserList;
    return new PageReference('/IDCard_AdmUserList');
  }




  public void printErr(String message) {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
  }

  public ID_Card_Application__c createApplication(Contact c, Account a, string appType, string packageTravel1, string packageTravel2) {
    ID_Card_Application__c idcapp = IDCardApplicationFactory.createIDCardApplication(c, appType);
    idcapp.Package_of_Travel_Professionals_Course_1__c = packageTravel1;
    idcapp.Package_of_Travel_Professionals_Course_2__c = packageTravel2;
    idcapp = IDCardApplicationFactory.applyApplicationFees(idcapp, a, null);
    return idcapp;
  }


  public void sendEmailForPictureLoading() {
    //map<string,string> emailToLink = new map<string,string>();
    set<string> VERnumbers = new set<string>();
    list<Messaging.Singleemailmessage> emails = new list<Messaging.Singleemailmessage>();
    list<String> selectedVerNums = new List<String>();
    for (String s : selectedContact.keyset())
      if (selectedContact.get(s))
        selectedVerNums.add(s);
    for (Contact c : [SELECT VER_Number_2__c, Email, IDCard_Email__c, FirstName, LastName FROM Contact WHERE VER_Number_2__c IN :selectedVerNums]) {

      if (c.Email == null && c.IDCard_Email__c == null) {
        printerr('It\'s not possible to send an email to ' + c.FirstName + ' ' + c.LastName + ' because he has not a valid email address.');
        continue;
      }
      list<string> toAddresses = new list<string>();
      if (c.Email != null)
        toAddresses.add(c.Email);
      if (c.IDCard_Email__c != null && (toAddresses.size() == 0 || toAddresses[0] != c.IDCard_Email__c))
        toAddresses.add(c.IDCard_Email__c);

      string ver = IDCardUtil.EncryptEncodeParameter(c.VER_Number_2__c).replaceAll('%', '%25');
      string link = URL.getSalesforceBaseUrl().toExternalForm() + pagesurl.get('prefix') + '/IDCard_AdmUserManagmentPicture?VER=' + ver;
      Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
      //email.setTargetObjectId(cp.c.Id);
      email.setToAddresses(toAddresses);
      email.setSubject('IATA ID Card - Please upload your picture');
      email.setPlainTextBody('Dear applicant,\nPlease update the picture of your ID card by following the instructions on this page: \n' + link + '\n\nBest regards'

                            );

      emails.add(email);

    }
    Messaging.SendEmailResult [] r = Messaging.sendEmail(emails, false);
    for (integer i = 0; i < r.size(); i++) {
      Messaging.SendEmailResult res = r[i];
      ContactViewProxy cp = contmap.values()[i];
      if (!res.isSuccess()) {
        printerr('Email to the applicant ' + cp.c.FirstName + ' ' + cp.c.LastName + ' was not sent dued to the following error: ' + res.getErrors()[0].getMessage());
      }
    }
    ApexPages.addMessage(new ApexPages.Message(ApexPAges.severity.CONFIRM, 'The emails were sent successfully to ' + emails.size() + ' applicants.'));

  }


  public string getBatchInfo() {
    loggedContact = [SELECT Name, Email, IATA_code__c, IDCard_Batch_Status__c
                     FROM Contact
                     WHERE Id in (select contact__c from Managed_agency__c where Account__r.IATACode__c = :iataCodeParameter)
                     AND VER_Number_2__c = :vernumParameter
                                           LIMIT 1];
    if (String.isBlank(loggedContact.IDCard_Batch_Status__c)) {
      importBatchStarted = false;
      return '';
    } else {
      importBatchStarted = true;
      importBatchTot = integer.valueOf(loggedContact.IDCard_Batch_Status__c.split('-')[0]);
      importBatchSucc = integer.valueOf(loggedContact.IDCard_Batch_Status__c.split('-')[1]);
      importBatchErr = integer.valueOf(loggedContact.IDCard_Batch_Status__c.split('-')[2]);

      if (importBatchTot > (importBatchSucc + importBatchErr))
        return 'A batch to import ' + importBatchTot + ' applicants from the CSV file is in progress: ' + (importBatchSucc + importBatchErr) + ' of them were processed with ' + importBatchErr + ' errors';
      else
        return 'Import process for ' + importBatchTot + ' applicants has been completed with ' + importBatchErr + ' errors. <p style="display:inline-block;text-decoration:underline;cursor:pointer;"onclick="callRemoveBatchInfo()">OK</p>';

    }

  }

  public void removeBatchInfo() {
    importBatchStarted = false;
    loggedContact.IDcard_Batch_Status__c = null;
    update loggedContact;
  }



  /*
       public string displayName {get;set;}
          public string contactName {get;set;}
          public string appIATAcode {get;set;}
          public Date validityDate {get;set;}
          public string printableValidityDate {get;set;}
          public String birthDate {get;set;}
          public integer status {get;set;}
          public string VER {get;set;}
          public boolean hasPhoto {get;set;}
          public boolean selected {get;set;}



      public ContactProxy getContact2(string VER){
          Contact c = [SELECT Name, FirstName, LastName, Phone, Email, Date_of_Birth__c, IATA_Code__c, Middle_Initial__c, Position__c, Duties__c, IDCard_Email__c,  UIR__c,
                                      VER_Number_2__c, Function__c, AccountId, Title, Start_Date_Agency_Month__c,  Start_Date_Agency_year__c, Start_Date_Industry__c,
                                      Gender__c, Salutation, Revenue_Confirmation__c, Hours_per_week__c, AgencyShare_Confirmation__c, Account.IATACode__c,
                                      Account.BillingCountry, Account.Short_Name__c
                               FROM Contact
                               WHERE VER_Number_2__c = :VER
          ];
          ContactViewProxy2 cp = new ContactViewProxy2();

          // Completing informations adding the most recent idcard (if exists)
          for(ID_Card__c idc : [SELECT Related_Contact__c, Valid_To_Date__c, Blacklisted__c,  VER_Number__c,
                                       Photo__c, Card_status__c, MustSyncWithAIMS__c,
                                       Start_Date_Agency_Month__c,  Start_Date_Agency_year__c,
                                       Title__c, Gender__c, Position__c, Hours_per_week__c, Duties__c, Start_Date_Industry__c
                                FROM ID_Card__c
                                WHERE Related_Contact__r.Account.IATAcode__c IN :keyContactAndDelegateForAccountList.keySet()
                                AND Related_Contact__r.VER_Number_2__c = : cp.c.VER_Number_2__c
                                AND Card_Status__c <> :BLACKLISTED

          ]){

              cp.addIDcard(idc);

          }

          // I look for every ID card application related to the contacts
          for(ID_Card_Application__c idca : [SELECT VER_Number__c, Photo__c, Package_of_Travel_Professionals_Course_1__c, Application_Status__c,
                                                    Package_of_Travel_Professionals_Course_2__c, Mass_order_Application__r.Application_Status__c,
                                                    Title__c, Gender__c, Position_in_Current_Agency__c, Hours_worked__c, Duties_in_Current_Agency__c,
                                                    Start_Date_Agency_Month__c, Start_Date_Agency_Year__c, Start_Date_Industry__c
                                             FROM ID_Card_Application__c
                                             WHERE VER_Number__c = : cp.c.VER_Number_2__c
                                             AND  (Application_Status__c = 'Pending' OR
                                                   Application_Status__c = 'Unpaid'  OR
                                                   Mass_order_Application__r.Application_Status__c = 'Pending')
          ]){

              cp.addApplication(idca);

          }
          return cp;
      }
       */

  public ContactProxy getContact(string VER) {
    Contact c = [SELECT Name, FirstName, LastName, Phone, Email, Date_of_Birth__c, IATA_Code__c, Middle_Initial__c, Position__c, Duties__c, IDCard_Email__c,  UIR__c,
                 VER_Number_2__c, Function__c, AccountId, Title, Start_Date_Agency_Month__c,  Start_Date_Agency_year__c, Start_Date_Industry__c,
                 Gender__c, Salutation, Revenue_Confirmation__c, Hours_per_week__c, AgencyShare_Confirmation__c, Account.IATACode__c,
                 Account.BillingCountry, Account.Short_Name__c


                 FROM Contact
                 WHERE VER_Number_2__c = :VER
                ];
    ContactProxy cp = new ContactProxy(c);
    cp.IATAcode = c.Account.IATACode__c;
    cp.country = c.Account.BillingCountry;

    // Completing informations adding the most recent idcard (if exists)
    for (ID_Card__c idc : [SELECT Related_Contact__c, Valid_To_Date__c, Blacklisted__c,  VER_Number__c,
                           Photo__c, Card_status__c, MustSyncWithAIMS__c,
                           Start_Date_Agency_Month__c,  Start_Date_Agency_year__c,
                           Title__c, Gender__c, Position__c, Hours_per_week__c, Duties__c, Start_Date_Industry__c
                           FROM ID_Card__c
                           WHERE Related_Contact__r.Account.IATAcode__c IN :keyContactAndDelegateForAccountList.keySet()
                           AND Related_Contact__r.VER_Number_2__c = : cp.c.VER_Number_2__c
                               AND Card_Status__c <> :CANCELLED
                               //ORDER BY Valid_To_Date__c DESC LIMIT 1
                          ]) {
      /*cp.idc = idc;
      if(idc.Photo__c != null){
          cp.Photo = idc.Photo__c;
      }*/
      cp.addIDcard(idc);

    }

    // I look for every ID card application related to the contacts
    for (ID_Card_Application__c idca : [SELECT VER_Number__c, Photo__c, Package_of_Travel_Professionals_Course_1__c, Application_Status__c,
                                        Package_of_Travel_Professionals_Course_2__c, Mass_order_Application__r.Application_Status__c,
                                        Title__c, Gender__c, Position_in_Current_Agency__c, Hours_worked__c, Duties_in_Current_Agency__c,
                                        Start_Date_Agency_Month__c, Start_Date_Agency_Year__c, Start_Date_Industry__c
                                        FROM ID_Card_Application__c
                                        WHERE VER_Number__c = : cp.c.VER_Number_2__c
                                            AND  (Application_Status__c = 'Pending' OR
                                                Application_Status__c = 'Unpaid'  OR
                                                    Mass_order_Application__r.Application_Status__c = 'Pending')
                                       ]) {

      cp.addApplication(idca);

    }
    return cp;
  }


  public class ContactViewProxy2 {

    public string displayName {get; set;}
    public string contactName {get; set;}
    public string appIATAcode {get; set;}
    public Date validityDate {get; set;}
    public Date validFromDate {get; set;}
    public string printableValidityDate {get; set;}
    public String birthDate {get; set;}
    public integer status {get; set;}
    public string VER {get; set;}
    public boolean hasPhoto {get; set;}
    public boolean selected {get; set;}

    public ContactViewProxy2() {
      this.status = STATUS_UNDEFINED;
      this.hasPhoto = false;
      this.selected = false;
      this.printableValidityDate = '';
      this.contactName = '';
    }

  }



  public class ContactViewProxy implements Comparable {
    public Contact c {get; set;}
    public string appname {get; set;}
    public string appIATAcode {get; set;}
    public Date appBirthday {get; set;}
    public string photo {get; set;}
    public boolean pending {get; set;}
    public boolean pendingOpIsLocked {get; set;}
    //public Date validityDate {get;set;}
    public boolean selected {get; set;}
    public string VER {get; set;}

    public string printableValidityDate {get; set;}
    public boolean hasPhoto {get; set;}

    public string salutation, firstname, lastname, gender, function, position, duties;

    public ContactViewProxy() {
      this.pending = false;
      this.pendingOpIsLocked = false;
      this.selected = false;
      this.hasPhoto = false;
    }

    public string getUniqueId() {
      return c.FirstName + '-' + c.LastName + '-' + c.Date_of_Birth__c + '-' + c.IATA_Code__c;
    }
    public Integer compareTo(Object compareTo) {
      //if(ContactViewProxy.orderfield == 'Name'){
      string thisname = this.appname != null ? this.appname : this.c.Name;
      thisname = thisname == null ? '' : thisname.toLowerCase();

      string thatname = this.appname != null ? ((ContactViewProxy)compareTo).appname : ((ContactViewProxy)compareTo).c.Name;
      thatname = thatname == null ? '' : thatname.toLowerCase();

      return thisname.compareTo(thatname);
      //}
    }

    public string getName() { return appname != null ? appname : c.Name;}
    public string getIATAcode() { return appIATAcode != null ? appIATAcode : c.IATA_code__c;}
    public string getBirthday() {
      Date d = appBirthday != null ? appBirthday : c.Date_of_Birth__c;
      return d.month() + '/' + d.day() + '/' + d.year();
    }

    //public String getPrintableValidityDate(){return validityDate==null ? '' : validityDate.month()+'/'+validityDate.day()+'/'+validityDate.year();}
    //public boolean getHasPhoto(){return photo!=null;}
  }


}