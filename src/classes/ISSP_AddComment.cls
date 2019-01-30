public class ISSP_AddComment {

  public Boolean showDescription { get; set; }
  public String CaseId ;
  public Case tmpCase {get; set;}
  public Case CaseNumber {get; set;}
  public string inputComment {get; set;}
  private E2CPFieldAccess e2cpFieldaccess;

  //CNS
  public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
  public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}


  public ISSP_AddComment() {
    CaseId  = ApexPages.currentPage().getParameters().get('Caseid');
    List<Case> Case_lst = new List<Case>([select RecordType.Name, Id , description , subject, CaseNumber, New_interaction__c, E2CP__AdditionalCC__c From Case where Id = : CaseId]);
    this.e2cpFieldAccess = new E2CPFieldAccess(caseId);

    if (Case_lst != null && Case_lst.size() > 0) {
      tmpCase = Case_Lst[0];
      tmpCase.New_interaction__c = 'New Comment';
      tmpCase.New_Comment_From_Connection_User__c = true;
      showDescription = true;
      if (tmpCase.RecordType.Name == 'SAAM' || tmpCase.RecordType.Name == 'OSCAR Communication') showDescription = false;
    }
  }


  public CaseComment CaseComment {
    get {
      if (CaseComment == null) {
        CaseComment  = new CaseComment ();
      }
      return CaseComment ;
    }
    set;
  }

  public PageReference upload() {
    CaseComment.ParentId = CaseId; // the record the file is attached to
    CaseComment.commentbody = inputComment ;

    try {
      //insert CaseComment ;
      insert CaseComment;
      update tmpCase;

      //ACAMBAS - WMO-395 - Start
      
      List<User> userList = [SELECT Id, ContactId FROM User WHERE Id = :userInfo.getUserId()];
      List<Contact> contactList = [SELECT Id, Preferred_Language__c, Email FROM Contact WHERE Id = :userList[0].ContactId];

      EmailUtils.sendEmailAlert(contactList, 'Portal_Case_Comment_Autoreply', 'noreply@iata.org', tmpCase.Id);

      //ACAMBAS - WMO-395 - End

    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Adding Comment'));
      return null;
    } finally {
      CaseComment = new CaseComment ();
    }

    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Added Comment successfully'));
    PageReference p = new PageReference('/apex/ISSP_Case?caseId=' + CaseId + commParam);
    p.setRedirect(true);
    return p;
    return null;
  }
  
  public String getAdditionalCC() {
    if (this.e2cpFieldAccess==null) {
      return '';
    }
    return this.e2cpFieldAccess.getAdditionalCC();
  }

}