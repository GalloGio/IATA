public class TransformationHelper {

  public static boolean NoStatusValidation = false;

  public static boolean trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;

  public static  boolean trgAccountISSP_AfterBeforInsertDeleteUpdateUndeleteGet() {

    return  trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete;
  }

  public static void trgAccountISSP_AfterBeforInsertDeleteUpdateUndeleteSet() {
    trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;

  }

  public static boolean CalculateBusinessHoursAges = false;

  public static  boolean CalculateBusinessHoursAgesGet() {

    return  trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete;
  }
  public static void CalculateBusinessHoursAgesSet() {
    trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;

  }

  public static string buildSiteForAcli(String AccountingCode, string TwoCaracterCode, string IsoCOde, string AirlinePrefix) {
    AccountingCode = AccountingCode <>  null ? AccountingCode.trim() : null;
    TwoCaracterCode = TwoCaracterCode<>  null ? TwoCaracterCode.trim() : null;
    IsoCOde = IsoCOde<>  null ? IsoCOde.trim() : null;
    AirlinePrefix = AirlinePrefix<>  null ? AirlinePrefix.trim() : null;
    String trellettere = !String.isblank(AccountingCode) ? AccountingCode.trim() :
                         ! String.isblank(   AirlinePrefix ) ? AirlinePrefix.trim()
                         : '' ;

    string twoLetters = TwoCaracterCode == null || String.isblank(TwoCaracterCode)  ? '' : TwoCaracterCode.trim();
    string isoC = IsoCOde == null || String.isblank(IsoCOde) ? '' : IsoCOde.trim();

    string site = '';

    if (twoLetters <> null && twoLetters <> '')
      site =  twoLetters.trim();

    if (trellettere <> null && trellettere <> '') {
      if (twoLetters <> null && twoLetters <> '')
        site += ' ' + trellettere.trim();
      else
        site += trellettere.trim();
    }


    if (isoC <> null && isoC <> '') {
      if (
        (twoLetters <> null && twoLetters <> '')
        ||
        (trellettere <> null && trellettere <> '')
      )
        site += ' ' + isoC.trim();
      else
        site += isoC.trim();
    }
    site = site.ToUpperCase();

    return site;


  }

  public static Set<String> getPicklistValues(String ObjectApi_name, String Field_name) {

    Set<String> lstPickvals = new Set<String>();
    Map<String, Schema.SObjectField> field_map = Schema.getGlobalDescribe().get(ObjectApi_name).newSObject().getSObjectType().getDescribe().fields.getMap();

    for (Schema.PicklistEntry a : field_map.get(Field_name).getDescribe().getPickListValues()) {
      lstPickvals.add(a.getValue());
    }

    return lstPickvals;
  }

  public static String getAllFields(Map<String, Schema.SObjectField> fieldMap) {
    String result = '*';
    for (String key : fieldMap.keyset())
      result += ', ' + key;
    result = result.replace('*,', '');
    return result;
  }

  public static map<String, list<String>> getAllFieldsPerDisplayType( string sObjectName) {

    map<String, list<String>> returnListPerType = new  map<String, list<String>>();


    Map<String, Schema.SObjectField>  fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();

    for (String f : fieldMap.keySet()) {
      string fieldType = '';
      if (fieldMap.get(f).getDescribe().getType() == Schema.DisplayType.Reference) fieldType = 'Reference'; // Only reference for now...if you need other fields type help yourself            else continue;
      if (returnListPerType.get(fieldType) == null)
        returnListPerType.put(fieldType, new list<String>());
      returnListPerType.get(fieldType).add(fieldMap.get(f).getDescribe().getName());
    }

    return returnListPerType;
  }

  public static String selectAllFields(String SObjectName) {
    String result = '';
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(SObjectName).getDescribe().fields.getMap();
    for (String f : fieldMap.keySet()) {
      Schema.DescribeFieldResult field = fieldMap.get(f).getDescribe();
      if (field.isAccessible())
        result += (result == '' ? '' : ', ') + field.getName();
    }

    return result;
  }

  public  static boolean triggerOnCaseNSerRen = false;

  public static void setComingFromCase() {
    triggerOnCaseNSerRen = true;
  }

  public static void sendSFDevsAlertMessage(String title, String message, String receiver) {
    sendSFDevsAlertMessage(title, message, new List<String> {receiver});
  }

  public static void sendSFDevsAlertMessage(String title, String message, List<String> receivers) {
    try {
      system.debug('Try to send message . ' + title + ' ******  ' + message);
      List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setSubject(title);
      mail.setToAddresses(receivers) ;
      mail.setPlainTextBody(message);
      emails.add(mail);
      Messaging.sendEmail(emails);
    } catch (Exception  e) {
      system.debug('Failed to send email to webdev');
    }
  }


  public static void sendEmailSupport( string subject, string message ) {
    if (Test.isRunningTest()) {
      System.debug('SendEmailSupport skipped because this is a Test. Subject: ' + subject + ', message: ' + message);
      return;
    }

    List<ID> userIDs = getUserIds(getSupportEmails());
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

    try {
      system.debug('Try to send message . ' + subject + ' ******  ' + message);


      for (ID userId : userIDs) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(userId);
        mail.setSubject(subject);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(message);
        emailsToSend.add(mail);
      }

      Messaging.sendEmail(emailsToSend);

    } catch (Exception  e) {
      system.debug('Failed to send email to users');
    }

  }

  private static List<String> getSupportEmails() {
    List<String> emails = new List<String>();

    String supportEmails = UtilityCS__c.getInstance('Emails').value__c;
    System.debug('SupportEmails: ' + supportEmails );

    if (supportEmails != null)
      for (String email : supportEmails.split(',', 0)) {
        if (validateEmail(email))
          emails.add(email);
      }

    return emails;
  }

  public static Boolean validateEmail(String email) {

    Boolean res = true;

    String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    // source: <a href="http://www.regular-expressions.info/email.html" target="_blank">http://www.regular-expressions.info/email.html</a>
    Pattern MyPattern = Pattern.compile(emailRegex);

    Matcher MyMatcher = MyPattern.matcher(email);

    if (!MyMatcher.matches())
      res = false;
    return res;
  }

  //Get the internal user IDs
  private static List<ID> getUserIds(List<String> users) {
    List<ID> userIDs = new List<ID>();

    if (users != null && users.size() > 0) {
      User[] userList = [select ID from User where Email in : users];
      for (User user : userList)
        userIDs.add(user.Id);
    }

    return userIDs;
  }

  /**
   * Used to asynchronously delete SObject
   */
  @future
  public static void deleteSObjects(Set<Id> idSet, String objType) {
    List<SObject> objectList = new List<SObject>();
    for (Id sid : idSet) {
      sObject obj = Schema.getGlobalDescribe().get(objType).newSObject(sid);
      objectList.add(obj);
    }
    delete objectList;
  }

}