public class ISSP_AddAttachment {

  public String CaseId;
  public Case tmpCase {get; set;}
  public String claimId;
  //public Baggage_Claim__c tmpClaim {get;set;}
  public Boolean isCase {get; set;}
  public Boolean isClaim {get; set;}
  public boolean isOSCARCase {get; set;} //AS - ISSP AMS SP09
  public boolean isOnlineOSCARCase {get; set;}

  public ISSP_AddAttachment() {
    isCase = false;
    isClaim = false;
    isOSCARCase = false;
    isOnlineOSCARCase = false;

    String CaseId = ApexPages.currentPage().getParameters().get('Caseid');
    List<Case_excluded_w_status_action_needed__c> recordTypesToExclude = Case_excluded_w_status_action_needed__c.getall().values();

    if (CaseId != '' && CaseId != null) {

      tmpCase = [Select Id , CaseNumber, RecordType.Name, Status, CaseArea__c, Reason1__c, New_interaction__c, RecordType.Developername, New_Attachment_From_Portal_User__c, Reopening_reason__c, Reopened_case__c  From Case Where Id = : CaseId];

      tmpCase.New_Attachment_From_Portal_User__c = true;
      system.debug('TRUEEEE');
      isCase = true;
      String caseRT;

      for (Case_excluded_w_status_action_needed__c cs : recordTypesToExclude) {
        caseRT = cs.Record_Type_Name__c;
        if (caseRT.contains(tmpCase.RecordType.Developername)) {
          if (tmpCase.Status == 'Closed') {
            tmpCase.Status = 'Reopen';
            tmpCase.Reopening_reason__c = '';
            tmpCase.Reopened_case__c = tmpCase.Reopened_case__c + 1;
          } else {
            tmpCase.Status = 'Action Needed';
          }
        } else {
          tmpCase.New_interaction__c = 'New Attachment';
        }
      }

      //Verify if the case is a OSCAR Communication or SAAM Case
      if (tmpCase.RecordType.name == 'SAAM' || tmpCase.RecordType.name == 'OSCAR Communication' || tmpCase.RecordType.name == 'SIDRA') {
      	isOSCARCase = true;
      	List <AMS_Pax_Accreditation_Form__c> amsList = [SELECT Id, Operation_Type__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :caseId];
      		if (!amsList.isEmpty()) {
          		isOnlineOSCARCase = true; //SAAM, OSCAR case has associated online form and so was submitted via Portal (cannot use case origin since converted Case Queries also have Origin=Portal)    
        	}
      }
    }

    /**
    String claimId = ApexPages.currentPage().getParameters().get('claimId');
    if (claimId != '' && claimId != null){
      tmpClaim = [Select Id , Name From Baggage_Claim__c Where Id =: claimId];
      isClaim = true;
    }
    **/

  }


  public Attachment attachment {
    get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
    }
    set;
  }

  public PageReference upload() {
    ID CaseId = ApexPages.currentPage().getParameters().get('Caseid');
    ID claimId = ApexPages.currentPage().getParameters().get('claimId');
    attachment.OwnerId = UserInfo.getUserId();
    if (isCase) {
      attachment.ParentId = CaseId; // the record the file is attached to
    } else if (isClaim) {
      attachment.ParentId = claimId; // the record the file is attached to
    }
    attachment.IsPrivate = false;

    try {
      insert attachment;
      update tmpCase;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading attachment'));
      return null;
    } finally {
      attachment = new Attachment();
    }

    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Attachment uploaded successfully'));
    PageReference p;
    if (isCase) {
      p = new PageReference('/ISSP_Case?caseId=' + CaseId);
    } else if (isClaim) {
      p = new PageReference('/ISSP_Baggage_Proration_Claim?id=' + claimId);
    }
    p.setRedirect(true);
    return p;
  }

}