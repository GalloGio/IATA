trigger trgIFAPContact_BeforeInsertUpdate on Contact (before insert, before update) {

  private String ERRORMSG = 'Only one Contact per Account can be defined as Financial Assessment Contact';

  if (test.isrunningTest()) {
  
      //insert new ISSP_CS__c(name = 'SysAdminProfileId' , value__c = '00e20000000h0gFAAQ');
        ISSP_CS__c myCS1 = ISSP_CS__c.getValues('SysAdminProfileId');
        if(myCS1 == null) 
        insert new ISSP_CS__c(name = 'SysAdminProfileId' , value__c = '00e20000000h0gFAAQ');
        
      

  }

  List<Contact> lCons = new List<Contact>();
  for (Contact theContact : trigger.new) {
    if (theContact.Financial_Assessment_Contact__c) lCons.add(theContact);
  }

  //When contact is created from Portal self-registration this trigger have to be bypassed
  if (userinfo.getLastName() != 'Site Guest User') {
    system.debug('not guest user');
    // get the Standard Contact recordtype
    ID standardContactRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('Standard');
    system.debug('standardContactRecordTypeID: ' + standardContactRecordTypeID);
    // Get the list of Profiles that we allow to create an FA contact for BR
    //list<Profile> profs = [SELECT Name, Id FROM Profile WHERE Name = 'System Administrator' limit 1];
    String sysAdminProfileId = String.ValueOF(ISSP_CS__c.getValues('SysAdminProfileId').value__c);
    list<Profile> profs = new List<Profile>();
    if (sysAdminProfileId != null && sysAdminProfileId != '')
      profs = [SELECT Name, Id FROM Profile where id = :sysAdminProfileId limit 1];
    profile prof;
    system.debug('profs: ' + profs);
    if (!profs.isEmpty()) {
      prof = profs[0];
      // For all contacts (Created or updated)
      for (Contact theContact : lCons) {
        system.debug('one contact: ' + theContact);
        try {
          system.debug('is IFAP: ' + theContact.Financial_Assessment_Contact__c);
          if (theContact.Financial_Assessment_Contact__c) {
            // check if a financial assessment contact already exists for the same account
            if (IFAP_BusinessRules.CheckFinancialAssessmentContactExist(theContact)) {
              theContact.addError(ERRORMSG);
            }

            Account theAccount = [Select a.Name, a.Location_Type__c, a.Type From Account a where a.Id = :theContact.AccountId];
            // check the Agent Type of the Account
            if (theAccount.Type != 'IATA Passenger Sales Agent' && theAccount.Type != 'IATA Cargo Agent' && theAccount.Type != 'CASS Associate' && theAccount.Type != 'Import Agent') {
              theContact.addError('Cannot associate an IFAP Contact to an Account of type ' + theAccount.Type);
            }

            // check if the account is BR; if yes, only admins can create FA contacts for BR
            //if (theAccount.Location_Type__c == 'BR' && UserInfo.getProfileId() != prof.Id){
            //modified may 2014 to allow if Contact was already Financial_Assessment_Contact__c (INC096598)
            /*
            if (theAccount.Location_Type__c == 'BR' && UserInfo.getProfileId() != prof.Id && (theContact.Financial_Assessment_Contact__c != Trigger.oldMap.get(theContact.Id).Financial_Assessment_Contact__c || theContact.AccountId != Trigger.oldMap.get(theContact.Id).AccountId)){
              theContact.addError('Only an admin can assign a Financial Assessment contact to a branch agency (BR)');
            }
            */ // INC196770: removed from trigger and performed on Contact's validation rules using custom permissions: 'Validate_FA_Contact_creation'
          }

        } catch (Exception e) {
          theContact.adderror('An unhandled error has occured. Error Message: ' + e.getMessage());
        }
      }
    }
  }
}