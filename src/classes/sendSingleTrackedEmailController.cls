public with sharing class sendSingleTrackedEmailController {

  public static final map<String,Sender_Tracked_Emails__c> SENDER_TRACKED_EMAILS = Sender_Tracked_Emails__c.getAll();

  public Tracked_Email__c email {get; set;}
  public Case cse {get;set;}
  public Boolean isNew {
    get {return this.email.Id==null;}
  }
  public sendSingleTrackedEmailController thisController {
    get{ return this; }
  }

  public sendSingleTrackedEmailController(ApexPages.StandardController stdController) {
    list<String> listFields = new list<String>{'ToContact__c', 'TextBody__c', 'Html_Body__c', 'Subject__c', 'Signaturit_Id__c', 'FromAddress__c', 'FromName__c', 'CcAddress__c', 'Case__c', 'BccAddress__c'};
    if (!Test.IsRunningtest()) stdController.addFields(listFields);
    this.email = (Tracked_Email__c)stdController.getRecord();

    if (this.email.Id == null ) {
      try {
        Id caseId = ApexPages.currentPage().getParameters().get('case');
        this.cse = [Select Id, Contact.email, contact.name from Case where Id = :caseId ];
        this.email = createNewEmail();
      } catch (Exception e) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A valid case is required' ));
      }
    }
  }

  private Tracked_Email__c createNewEmail() {
    Id toContactId;
    if (ApexPages.currentPage().getParameters().get('toContact') != null) {
      toContactId = ApexPages.currentPage().getParameters().get('toContact');
    } else {
      toContactId = this.cse.ContactId;
    }

    Tracked_Email__c te =  new Tracked_Email__c(
      Case__c = cse.Id,
      ToContact__c = toContactId,
      Subject__c = '',
      TextBody__c = '',
      Html_Body__c = '',
      Status__c = 'Sent'
    );
    return te;
  }

  private Boolean checkFields() {
    Boolean result = true;
    if (email.ToContact__c == null ) {
      email.ToContact__c.addError('Field is mandatory');
      result = false;
    }
    if (email.Subject__c == null ) {
      email.Subject__c.addError('Field is mandatory');
      result = false;
    }
    if (email.Html_Body__c == null ) {
      email.Html_Body__c.addError('Field is mandatory');
      result = false;
    }
    return result;
  }

  /**
    Save current emailmessage plus the Tracked Email object
  **/
  public PageReference sendTrackedEmail() {
    if (!checkFields()) return null;
    SignaturitRest.MailResponse response = SignaturitRest.sendMail(email);
    if (response == null ) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sending failure'));
      return null;
    }
    Savepoint sp = Database.setSavepoint();
    try {
      this.email.Signaturit_Id__c = response.id;
      this.email.Signaturit_Certificate_Ids__c = String.join(response.getCertificateIds(),';');
      insert this.email;

      Pagereference pageref = new PageReference('/' + this.email.Id);
      pageref.setRedirect(true);
      return pageref;
      //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Email sent'));

    } catch ( Exception e) {
      Database.rollback(sp);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error sending email'));
      return null;
    }
  }

  /**
    Redirect to retURL or home without doing changes
  **/
  public PageReference cancel() {
    String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
    String url = retUrl==null? '/' + cse.Id : retURL;
    PageReference pageref = new PageReference(url);
    pageref.setRedirect(true);
    return pageref;
  }

  /**
    Workaround to get the body and subject using a template
  **/
  public void applyTemplate() {
    try {
      String templateId = ApexPages.currentPage().getParameters().get('template');
      //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,templateId));
      EmailTemplate emailTemplate = [
        select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId, TemplateType
        from EmailTemplate
        where Id = :templateId];

      Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
      dummyEmailMsg.setTemplateId(emailTemplate.Id);
      dummyEmailMsg.setSaveAsActivity(false);
      String[] toAddresses = new String[]{'dummy@maildummy.org'};
      dummyEmailMsg.setToAddresses(toAddresses);
      dummyEmailMsg.setReplyTo('dummy@maildummy.org');

      Savepoint sp = Database.setSavepoint();
      Account dummyAcct = new Account(Name='dummy account');
      insert dummyAcct;

      dummyEmailMsg.setTargetObjectId(this.cse.ContactId);
      dummyEmailMsg.setWhatId(cse.Id);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {dummyEmailMsg});
      Database.rollback(sp);

      this.email.Subject__c = dummyEmailMsg.getSubject();
      if (emailTemplate.TemplateType == 'Text') {
        this.email.Html_Body__c = dummyEmailMsg.getPlainTextBody();
      } else {
        this.email.Html_Body__c = dummyEmailMsg.getHtmlBody();
      }
      //this.email.TextBody__c = dummyEmailMsg.getPlainTextBody();
    } catch (Exception e) {
      System.debug('Error. Template not applied. ' + e.getMessage());
      //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
    }
  }

  public String selectedFrom {
    get;
    set {
      this.email.FromName__c = value;
      this.email.FromAddress__c = SENDER_TRACKED_EMAILS.get(value).email__c;
    }
  }

  public list<SelectOption> getFromAddresses() {
    list<SelectOption> listOption = new list<SelectOption>();
    for ( Sender_Tracked_Emails__c ste: SENDER_TRACKED_EMAILS.values() ) {
      String value = '"' + ste.name + '" <' + ste.email__c + '>';
      listOption.add(new SelectOption(ste.Name, value));
    }
    return listOption;
  }

}