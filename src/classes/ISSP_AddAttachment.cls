public class ISSP_AddAttachment {
  private static Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
  public String CaseId;
  public Case tmpCase {get; set;}
  public String claimId;
  //public Baggage_Claim__c tmpClaim {get;set;}
  public Boolean isCase {get; set;}
  public Boolean isClaim {get; set;}
  public boolean isOSCARCase {get; set;} //AS - ISSP AMS SP09
  public boolean isOnlineOSCARCase {get; set;}
  private Id vHQAccountId;
  public Id vAccountConcerned {get; set;}
  public Contact con {get; set;}
  Account hqAccount;

  //CNS
  public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
  public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

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
        
      popContact();
        
      if (con.Account.Top_Parent__c == null) { //User is from HQ Account
            vHQAccountId = con.AccountId;
        } else {
            vHQAccountId = con.Account.Top_Parent__c;
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
    
  //FOR VR process
    public Map<String, String> mVR_LocationClassTypes 
        {get { return new Map<String, String>{'P'=>'P','C'=>'C','R'=>'R','I'=>'I','Q'=>'Q','D'=>'D'}; }}


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
      p = new PageReference('/ISSP_Case?caseId=' + CaseId + commParam);
    } else if (isClaim) {
      p = new PageReference('/ISSP_Baggage_Proration_Claim?id=' + claimId);
    }
    p.setRedirect(true);
    return p;
  }
    
    public pageReference submitToIATA() { 
           String typeOfProcess = '';
                if (tmpCase.RecordTypeId == OSCAR_RECORD_TYPE_ID && (tmpCase.Reason1__c == 'CLO - Closure' || tmpCase.Reason1__c == 'New SA / CHV – New Code')){
                   
                  if(tmpCase.Status=='Draft') {
                    if (tmpCase.Reason1__c == 'CLO - Closure') {
                    	if(mVR_LocationClassTypes.containsKey(con.Account.Location_Class__c)   ){
                        	typeOfProcess = AMS_RecordCreatorWebservice.NEWVR_PV;
                    	}else{
                        	typeOfProcess = AMS_RecordCreatorWebservice.NEWVRCA_PV;
                        }
                    } else {
                        typeOfProcess = 'NEW.SA.1.0';
                       
                        SYSTEM.DEBUG('vAccountConcerned: ' + vAccountConcerned);
                        if(vAccountConcerned==null) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_SA_Office_Select));
            				return null;
        				}
                        
                      	tmpCase.Account_concerned__c = vAccountConcerned;
                        
                        /** AMS to create non-verified SA account as part of OSCAR Integration
                       	Account newSAAccount = new Account(Name = hqAccount.Name, ParentId = vAccountConcerned);
                        newSAAccount.Location_type__c = 'SA';
                       	newSAAccount.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        				if (!test.isRunningTest()) {
            				newSAAccount.OwnerId = ISSP_Constant.newAccountOwnerId;
        				} else if (test.isRunningTest()) {
            				newSAAccount.OwnerId = userInfo.getUserId();
        				}
                        insert newSAAccount;
						**/
                    }
                      
                    list<AmazonFile__c> listAmazonFile = [
                		Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c , File_Identifier__c
                		From AmazonFile__c
                		Where Case__c = :tmpCase.Id
                                             ];
                        if( listAmazonFile.size()==0) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_Upload_Form_message));
            				return null;
                        }
                    
                    //Fetching the assignment rules on case
					AssignmentRule AR = new AssignmentRule();
					AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                    
                    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
					Database.DMLOptions dmlOpts = new Database.DMLOptions();
					dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                    
                    tmpCase.setOptions(dmlOpts);
                    tmpCase.Status = 'Open';
					update tmpCase;
                    
                      if(typeOfProcess == 'NEW.SA.1.0') {
                      	AMS_RecordCreatorWebservice.createAccreditationForSA(tmpCase.Id);
                      } else {
                      	AMS_RecordCreatorWebservice.createAccreditation(vHQAccountId, AMS_RecordCreatorWebservice.EMPTYACCREDITATIONID, typeOfProcess, tmpCase.Id);    
                      }
                    
                    sendConfirmationEmail(tmpCase);
                    }
                }
                
                 return new Pagereference('/ISSP_Case?caseId=' + tmpCase.Id + commParam);   
                }

    
    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);
    }
    
    public List<SelectOption> getNoNSAOffices() {
        
        fetchHQAccountDetails ();
        
        System.DeBUG('vHQAccountId for BR Accounts: ' + vHQAccountId);
        
        List<SelectOption> options = new List<SelectOption>();

        List <Account> branchList = [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry
                                      FROM Account
                                      WHERE Top_Parent__c = :vHQAccountId AND RecordType.DeveloperName IN ('IATA_Agency') AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending'))
                                      										AND IATACode__c != null AND Location_Type__c != 'SA'
                                              ORDER BY Location_Type__c,Name, IATACode__c
                                     ];
       
        SYSTEM.DEBUG('ALL Branch Size: ' + branchList.size());
        
        options.add(new SelectOption('', '- Select Office -'));
        
        String sBillingAddress = null;
        String theLabel;
        
        if(hqAccount.BillingCity != null || hqAccount.BillingState != null){
                sBillingAddress = '(' +  (hqAccount.BillingCity!= null ? hqAccount.BillingCity : '') + (hqAccount.BillingState!= null ? ' ' + hqAccount.BillingState : '')+ ')';
        }
        theLabel = hqAccount.IATACode__c + ' - ' + hqAccount.Location_Type__c + ' ' + (sBillingAddress!= null ? sBillingAddress : '');    
        options.add(new SelectOption(hqAccount.Id, theLabel));
        
        for (Account thisAccount : branchList) {
            theLabel = null;
            sBillingAddress = null;

            if(thisAccount.BillingCity != null || thisAccount.BillingState != null){
                sBillingAddress = '(' +  (thisAccount.BillingCity!= null ? thisAccount.BillingCity : '') + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '')+ ')';
            }

            theLabel = thisAccount.IATACode__c + ' - ' + thisAccount.Location_Type__c + ' ' + (sBillingAddress!= null ? sBillingAddress : '');
            
            options.add(new SelectOption(thisAccount.Id, theLabel));
        }
        return options;
    }
    
    public void fetchHQAccountDetails () {
        hqAccount = [
                        SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                        TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                        Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                        Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                        Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                        VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c
                        FROM Account
                        WHERE Id = :vHQAccountId
                                   LIMIT 1
                    ];
    }
    
    public void sendConfirmationEmail(Case saCase) {
        String emailTemplateName;
        String fromaddress;

        emailTemplateName = 'ISSP AMS Process Notification';
        fromaddress = 'IATA Agency Management (noreply@iata.org)';

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> ets = [Select Name, Id From EmailTemplate where Name = :emailTemplateName];
        EmailTemplate et = ets[0];

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(et.Id);
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        //mail.setSenderDisplayName(fromaddress);
        mail.setTargetObjectId(con.Id);
        mail.setWhatId(saCase.Id);
        mail.setSaveAsActivity(true);

        emails.add(mail);
        SYSTEM.DEBUG('Sending Confirmation emails: ' + emails);
        if (Test.IsRunningTest() == false) {
            SYSTEM.DEBUG('Sending NoC Confirmation 2');
            Messaging.sendEmail(emails);
        }
    }
}