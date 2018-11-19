public with sharing class IDCard_AdmUserExportCSVController extends IDCardAbstractController {

  private final string BLACKLISTED = 'Cancelled';
  public static Integer STATUS_UNDEFINED = -1;
  public static Integer STATUS_PENDING_APP = 0;
  public static Integer STATUS_PENDING_PAYMENT_APP = 1;
  public static Integer STATUS_EXISTING_VALID_CARD = 2;
  public static Integer STATUS_EXISTING_UNVALID_CARD = 3;
  public static Integer STATUS_BLACKLISTED_CARD = 4;
  public static Integer STATUS_CANCELLED_APP = 5;

  public transient Map<String, ContactViewProxy2> listedContact {get; set;}
  public transient Map<String, ContactViewProxy2> blacklistedContact {get; set;}
  private List<ContactViewProxy2> cancelledContacts {get; set;}

  public IDCard_AdmUserExportCSVController() {
    initialize(true);

    loadContacts2();


  }



  public void loadContacts2() {
    //0 init maps
    listedContact = new Map<String, ContactViewProxy2>();

    blacklistedContact = new Map<String, ContactViewProxy2>();

    cancelledContacts = new List<ContactViewProxy2>();
    ContactViewProxy2 cpcc;
    
    String previousIATACode = '';
    String previousVER = '';

    //1 select ID card existing in system
    for (ID_Card__c idc : [ Select i.VER_Number__c, i.Is_Active_Card__c, i.Valid_To_Date__c, i.Photo__c, i.Id, i.ID_Card_Application__c, i.Card_Status__c, i.Cancellation_Date__c, i.Blacklisted__c,
                            Title__c, FirstName__c, LastName__c, Date_of_Birth__c, Agency_IATA_Code__c, Phone__c, Email__c, Position__c, Duties__c,
                            Start_Date_Agency_Month__c, Start_Date_Agency_Year__c, Start_Date_Industry__c
                            From ID_Card__c i
                            where Agency_IATA_Code__c in:keyContactAndDelegateForAccountList.keySet()
                            order by Agency_IATA_Code__c , VER_Number__c, Valid_To_Date__c DESC]) {

      if (idc.Cancellation_Date__c != null) {
        cpcc = new ContactViewProxy2();
        cpcc.VER = idc.VER_Number__c;
        cpcc.validityDate = idc.Valid_To_Date__c;
        cancelledContacts.add(cpcc);
      }

      if (blacklistedContact.get(idc.VER_Number__c) == null) {
        ContactViewProxy2 cp = listedContact.get(idc.VER_Number__c);
        if (cp == null)
          cp = new ContactViewProxy2();
        cp.ver = idc.VER_Number__c;
        //cancelledContacts.add(cp);

        //if blacklisted: no need to go ahead.
        if (idc.Blacklisted__c) {
          blacklistedContact.put(idc.VER_Number__c, cp);
          listedContact.remove(idc.VER_Number__c);
          cp.status = STATUS_BLACKLISTED_CARD;
        } else {

          cp.salutation = idc.Title__c;
          cp.firstName = idc.FirstName__c;
          cp.lastName = idc.LastName__c;
          cp.birthDate = idc.Date_of_Birth__c == null ? '' : idc.Date_of_Birth__c.month() + '/' + idc.Date_of_Birth__c.day() + '/' + idc.Date_of_Birth__c.year();
          cp.phone = idc.Phone__c;
          
          // keep the ID Card Email of the lastest ID Card record
          if(previousIATACode != idc.Agency_IATA_Code__c && previousVER != idc.VER_Number__c ||
             previousIATACode == idc.Agency_IATA_Code__c && previousVER != idc.VER_Number__c)
             {
                 cp.email = idc.Email__c;
                 previousIATACode = idc.Agency_IATA_Code__c;
                 previousVER = idc.VER_Number__c;
             }
             
          cp.position = idc.Position__c;
          cp.duties = idc.Duties__c;
          cp.startdateagencymonth = idc.Start_Date_Agency_Month__c;
          cp.startdateagencyyear = idc.Start_Date_Agency_Year__c;
          cp.startdateindustry = idc.Start_Date_Industry__c;


          //if status !0 valid : set as cancel if needed
          if (idc.Cancellation_Date__c != null && cp.status != STATUS_EXISTING_VALID_CARD  && (cp.status == STATUS_UNDEFINED || cp.validityDate < idc.Valid_To_Date__c)) {
            cp.status = STATUS_CANCELLED_APP;
            cp.IATAcode = idc.Agency_IATA_Code__c;
            cp.hasPhoto = true;

            cp.validityDate = null;
            cp.printableValidityDate = '';
          }
          // if idc is  valid
          else if (idc.Cancellation_Date__c == null) {
            if (cp.validityDate == null || (cp.validityDate <  idc.Valid_To_Date__c && idc.Is_Active_Card__c)) {
              cp.validityDate = idc.Valid_To_Date__c;
              cp.PrintableValidityDate = idc.Valid_To_Date__c == null ? '' : idc.Valid_To_Date__c.month() + '/' + idc.Valid_To_Date__c.day() + '/' + idc.Valid_To_Date__c.year();

              cp.IATAcode = idc.Agency_IATA_Code__c;

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

      }
    }
    //process according to ID Card App pendign as a single application
    String singeAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
    String standardAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Standard');

    for (ID_Card_Application__c  idca : [Select i.VER_Number__c, i.Photo__c, i.Type_of_application__c, i.Single_Application_Processing_Step__c, i.RecordTypeId, i.Mass_order_Application__c, i.Id, i.IATA_Code__c, i.Displayed_Name__c, i.Application_Status__c,
                                         Title__c, First_Name__c, Last_Name__c, Date_of_Birth__c, Position_in_Current_Agency__c, Duties_in_Current_Agency__c,
                                         Start_Date_Agency_Month__c, Start_Date_Agency_Year__c, Start_Date_Industry__c,
                                         Package_of_Travel_Professionals_Course_1__c,  Package_of_Travel_Professionals_Course_2__c


                                         From ID_Card_Application__c i
                                         where IATA_Code__c in:keyContactAndDelegateForAccountList.keySet()
                                         and (Application_Status__c = 'Pending' or Application_Status__c = 'Unpaid'  )
                                         and (RecordTypeId = :singeAppRT or RecordTypeId = :standardAppRT)]) {

      if (blacklistedContact.get(idca.VER_Number__c) == null) {
        ContactViewProxy2 cp = listedContact.get(idca.VER_Number__c);
        if (cp == null)
          cp = new ContactViewProxy2();
        cp.ver = idca.VER_Number__c;
        cp.salutation = idca.Title__c;
        cp.firstName = idca.First_Name__c;
        cp.lastName = idca.Last_Name__c;
        cp.birthDate = idca.Date_of_Birth__c == null ? '' : idca.Date_of_Birth__c.month() + '/' + idca.Date_of_Birth__c.day() + '/' + idca.Date_of_Birth__c.year();
        if (!String.isBlank(cp.IATAcode) && cp.IATAcode != idca.IATA_Code__c)
          cp.previousIATAcode = idca.IATA_Code__c;
        else
          cp.IATAcode = idca.IATA_Code__c;
        cp.position = idca.Position_in_Current_Agency__c;
        cp.duties = idca.Duties_in_Current_Agency__c;
        cp.startdateagencymonth = idca.Start_Date_Agency_Month__c;
        cp.startdateagencyyear = idca.Start_Date_Agency_Year__c;
        cp.startdateindustry = idca.Start_Date_Industry__c;
        cp.apptype = idca.Type_of_application__c;
        string pack1 = idca.Package_of_Travel_Professionals_Course_1__c;
        string pack2 = idca.Package_of_Travel_Professionals_Course_2__c;
        if (pack1 == 'Geography in Travel Planning' || pack2 == 'Geography in Travel Planning') cp.packages = '"true",';  else  cp.packages = '"",';
        if (pack1 == 'Destination Geography' || pack2 == 'Destination Geography') cp.packages += '"true",';  else  cp.packages += '"",';
        if (pack1 == 'Serving the Travel & Tourism Customer' || pack2 == 'Serving the Travel & Tourism Customer') cp.packages += '"true",';  else  cp.packages += '"",';
        if (pack1 == 'Introduction to BSPLink' || pack2 == 'Introduction to BSPLink') cp.packages += '"true",';  else  cp.packages += '"",';
        if (pack1 == 'Le service au client voyageur' || pack2 == 'Le service au client voyageur') cp.packages += '"true",';  else  cp.packages += '"",';
        if (pack1 == 'Selling International Rail Transportation' || pack2 == 'Selling International Rail Transportation') cp.packages += '"true",';  else  cp.packages += '"",';

        if (cp.status == STATUS_UNDEFINED) {
          cp.hasPhoto = (idca.Photo__c != null && idca.Photo__c != '');


          if (idca.Application_Status__c == 'Pending' || idca.Application_Status__c == 'Unpaid')
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

      }


    }
    // forexsiting proxy contact get he name of contact.
    listedContact.remove(null);
    Map<String, ContactViewProxy2> tmp2delete = new Map<String, ContactViewProxy2>();
    for (Contact c : [select Name, Date_of_Birth__c, VER_Number_2__c, Iata_code__c ,
                      FirstName, LastName, Phone, Email, Position__c, Duties__c, IDCard_Email__c,  Function__c,
                      Salutation, Start_Date_Agency_Month__c,  Start_Date_Agency_year__c, Start_Date_Industry__c
                      from Contact
                      where VER_Number_2__c in :listedContact.keySet()]) {



      ContactViewProxy2 cp = listedContact.get(c.VER_Number_2__c);

      cp.birthDate = c.Date_of_Birth__c == null ? '' : c.Date_of_Birth__c.month() + '/' + c.Date_of_Birth__c.day() + '/' + c.Date_of_Birth__c.year();
      //excude those who had changed since last card
      if (cp.status == STATUS_CANCELLED_APP && keyContactAndDelegateForAccountList.get( c.Iata_code__c) == null) {
        listedContact.remove(c.VER_Number_2__c);

        //exclude those who have a cancelled id card
      } else if (cp.status == STATUS_CANCELLED_APP || cp.status == STATUS_BLACKLISTED_CARD) {
        listedContact.remove(c.VER_Number_2__c);

      } else {
        if (string.isBlank(cp.salutation)) cp.salutation = c.Salutation;
        if (string.isBlank(cp.firstName)) cp.firstName = c.FirstName;
        if (string.isBlank(cp.lastName)) cp.lastName = c.LastName;
        if (string.isBlank(cp.birthDate)) cp.birthDate = c.Date_of_Birth__c == null ? '' : c.Date_of_Birth__c.month() + '/' + c.Date_of_Birth__c.day() + '/' + c.Date_of_Birth__c.year();
        if (string.isBlank(cp.iatacode)) cp.iatacode = c.Iata_code__c;
        if (string.isBlank(cp.function)) cp.function = c.Function__c;
        if (string.isBlank(cp.phone)) cp.phone = c.Phone;
        //if (string.isBlank(cp.email)) cp.email = c.Email;
        if (string.isBlank(cp.email)) cp.email = c.IDCard_Email__c;
        if (string.isBlank(cp.position)) cp.position = c.Position__c;
        if (string.isBlank(cp.duties)) cp.duties = c.Duties__c;
        if (string.isBlank(cp.startdateagencymonth)) cp.startdateagencymonth = c.Start_Date_Agency_Month__c;
        if (string.isBlank(cp.startdateagencyyear)) cp.startdateagencyyear = string.valueOf(c.Start_Date_Agency_year__c);
        if (string.isBlank(cp.startdateindustry)) cp.startdateindustry = string.valueOf(c.Start_Date_Industry__c);

      }
    }


    for (ContactViewProxy2 cc : cancelledContacts) {
      if (listedContact.containsKey(cc.VER) && cc.validityDate > listedContact.get(cc.VER).validityDate) {
        listedContact.remove(cc.VER);
      }
    }

  }

  public class ContactViewProxy2 {
    public string salutation {get; set;}
    public string firstName {get; set;}
    public string lastName {get; set;}
    public String birthDate {get; set;}
    public string IATAcode {get; set;}
    public string VER {get; set;}
    public string function {get; set;}
    public string phone {get; set;}
    public string email {get; set;}
    public string position {get; set;}
    public string duties {get; set;}
    public string startdateagencymonth {get; set;}
    public string startdateagencyyear {get; set;}
    public string startdateindustry {get; set;}
    public string packages {get; set;}
    public string apptype {get; set;}
    public string previousiatacode {get; set;}
    public string printableValidityDate {get; set;}
    public Date ValidityDate {get; set;}

    public boolean hasPhoto {get; set;}
    public integer status {get; set;}

    public ContactViewProxy2() {
      this.status = STATUS_UNDEFINED;
      packages = '"","","","","","",';
    }

  }
}