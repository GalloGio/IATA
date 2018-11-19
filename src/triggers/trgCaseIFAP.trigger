/**
 * Business rules for Case creation for the IFAP project
 * Created by Alexandre McGraw on 2012-01-09
 */
trigger trgCaseIFAP on Case (before insert, before update) {
    if (CaseChildHelper.noValidationsOnTrgCAseIFAP)return;
    // get the IFAP case recordtype
    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

    Boolean isIFAp = false;

    //User currentUser;
    Profile currentUserProfile;
    Set<Id> contactIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    Boolean isIfapAuthorizedUser = false;

    for (Case aCase : trigger.New) {
        if (aCase.RecordTypeId == IFAPcaseRecordTypeID) {
            isIFAp = true;

        } else {
            break;
        }
        system.debug('Contact Id: ' + aCase.contactId  + ' Account ID: ' + aCase.accountId);
        contactIds.add(aCase.contactId);
        accountIds.add(aCase.accountId);
    }
    map<id, Contact> contactMap = new map<id, Contact>();
    map<id, Account> accountMap = new map<id, Account>();

    if (isIFAp) {
        //currentUser = [Select Id, FirstName, LastName, ProfileId from User where Id =: UserInfo.getUserId() limit 1];
        //currentUserProfile = [SELECT ID, Name FROM Profile WHERE id =: currentUser.ProfileId limit 1];
        currentUserProfile = [SELECT ID, Name FROM Profile WHERE id = : UserInfo.getProfileId() limit 1];

        List<Contact> contacts = [Select c.Id, c.Agent_Type__c, c.AccountId From Contact c where Id IN : contactIds];
        List<Account> accounts = [Select a.Id, a.IATACode__c, a.BillingCountry, a.Type From Account a where Id IN : accountIds];

        System.debug('QUERY DEBUG' + Limits.getQueryRows());
        //Ifap Authorized users have a specific permission set
        List<PermissionSet> PSet = [SELECT Id FROM PermissionSet WHERE Name = 'IFAP_Authorized_Users'];
        if(PSet <> null && PSet.size()>0)
        {
            ID PSetID = PSet[0].Id;
            List<PermissionSetAssignment> authorizedUserIds = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.ID = :PSetID];
    
            for (PermissionSetAssignment psa : authorizedUserIds)
                if (psa.AssigneeId == UserInfo.getUserId())
                    isIfapAuthorizedUser = true;
        }

        // Create Account and contact Map (in order to decrease the number of SOQL queries executed)
        for (Case aCase : trigger.New) {
            // Search for the contact related to the case
            for (Contact aContact : contacts) {
                if (aContact.Id == acase.ContactId) {
                    contactMap.put(aCase.id, aContact);
                    break;
                }
            }

            // Search for the account related to the case
            for (Account aAccount : accounts) {
                if (aAccount.Id == aCase.AccountId) {
                    accountMap.put(aCase.id, aAccount);
                    break;
                }
            }
        }
    }

    if (Trigger.isInsert) {

        for (Case newCase : Trigger.New) {

            // only consider IFAP cases
            if (newCase.RecordTypeId == IFAPcaseRecordTypeID) {

                // validate the account's country
                if (!IFAP_BusinessRules.isCountryValid(newCase, accountMap))
                    newCase.addError('The account\'s country is not valid.');
                else
                    IFAP_BusinessRules.setCountryAreaAndISOCode(newCase, accountMap);

                // validate the Agent Type
                /*if (!IFAP_BusinessRules.isAgentTypeValid(newCase, contactMap))
                    newCase.addError('The contact\'s Agent Type is not valid.');*/

                // validate the Agent Code if the financial review type is not 'New'
                if (newCase.Financial_Review_Type__c != 'New applications')
                    if (!IFAP_BusinessRules.isAgentCodeValid(newCase, accountMap))
                        newCase.addError('The contact\'s Agent Code is not valid.');


                if (!IFAP_BusinessRules.IsStatusCanBeSelected(true, newCase, null, currentUserProfile, isIfapAuthorizedUser)) {
                    newCase.addError('This following case status cannot be selected: ' + newCase.status);
                }

                // check if the FA template's country matches the case country
                EmailTemplate__c[] et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : newCase.EmailTemplate__c and et.recordType.Name = 'IFAP'];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], newCase.IFAP_Country_ISO__c)) {
                    newCase.addError('The selected Initial Request Email Template does not match the case country.');
                }

                // check if the FA reminder template's country matches the case country
                et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : newCase.Reminder_EmailTemplate__c and et.recordType.Name = 'IFAP'];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], newCase.IFAP_Country_ISO__c)) {
                    newCase.addError('The selected Reminder Email Template does not match the case country.');
                }

                // check if the FS template's country matches the case country
                et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : newCase.FS_EmailTemplate__c and et.recordType.Name = 'IFAP'];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], newCase.IFAP_Country_ISO__c)) {
                    newCase.addError('The selected FS Email Template does not match the case country.');
                }

                // check if the FS reminder template's country matches the case country
                et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : newCase.FS_Reminder_EmailTemplate__c and et.recordType.Name = 'IFAP'];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], newCase.IFAP_Country_ISO__c)) {
                    newCase.addError('The selected FS Reminder Email Template does not match the case country.');
                }

                ////////////
                // Phase 4

                // check if the agent already has closed case for the same financial year and if the checkbox has been checked
                if (IFAP_BusinessRules.accountHasClosedCases(newCase.AccountId, newCase.IFAP_Financial_Year__c) && newCase.IFAP_CanCreateWhileClosedCase__c == false)
                    newCase.addError('The selected agent already has a closed IFAP case for the financial year ' + newCase.IFAP_Financial_Year__c + '. Please confirm that you really wish to create another IFAP case for this account by checking the confirmation check box at the bottom of this page.');
                else if (!IFAP_BusinessRules.accountHasClosedCases(newCase.AccountId, newCase.IFAP_Financial_Year__c) && newCase.IFAP_CanCreateWhileClosedCase__c)
                    newCase.addError('The selected account does not have any closed IFAP cases. Please uncheck the confirmation check box at the bottom of this page');

                // check if Parent case already has child IFAP cases
                if (String.valueOf(newCase.ParentId) != '' && IFAP_BusinessRules.isSAAMCase(newCase.ParentId) && IFAP_BusinessRules.caseHasChildIFAPCases(newCase.ParentId)) {
                    newCase.addError('The parent SAAM case already has an IFAP case.');
                }
            }
        }
    } else if (Trigger.isUpdate) {

        for (Case updatedCase : Trigger.New) {
            // ** May 2014 modif: Forbid change of recordtype FROM or TO IFAP case
            if (updatedCase.RecordTypeId == IFAPcaseRecordTypeID && Trigger.oldMap.get(updatedCase.ID).RecordTypeId != IFAPcaseRecordTypeID) updatedCase.addError('You cannot create an IFAP case by changing the case record type. If you want to create an IFAP case, create the IFAP case as a child case.');
            if (updatedCase.RecordTypeId != IFAPcaseRecordTypeID && Trigger.oldMap.get(updatedCase.ID).RecordTypeId == IFAPcaseRecordTypeID) updatedCase.addError('You cannot change the record type of an IFAP case.');
            // ** End May 2014 modif

            // only consider IFAP cases
            if (updatedCase.RecordTypeId == IFAPcaseRecordTypeID) {

                Case oldCase = Trigger.oldMap.get(updatedCase.ID);

                //if(updatedCase.AccountId <> oldCase.AccountId){
                if (updatedCase.Country__c <> oldCase.Country__c) {
                    // validate the account's country
                    if (!IFAP_BusinessRules.isCountryValid(updatedCase, accountMap))
                        updatedCase.addError('The account\'s country is not valid.');
                }
                if (updatedCase.IFAP_Agent_Type__c <> oldCase.IFAP_Agent_Type__c) {
                    // validate the Agent Type
                    if (!IFAP_BusinessRules.isAgentTypeValid(updatedCase, contactMap))
                        updatedCase.addError('The contact\'s Agent Type is not valid.');
                }

                // validate the Agent Code if the financial review type is not 'New'
                if (updatedCase.Financial_Review_Type__c != 'New applications') {
                    if (updatedCase.IFAP_Agent_Code__c <> oldCase.IFAP_Agent_Code__c) {
                        if (!IFAP_BusinessRules.isAgentCodeValid(updatedCase, accountMap))
                            updatedCase.addError('The contact\'s Agent Code is not valid.');
                    }
                }
                //}

                if (UpdatedCase.status != 'Closed' && !TransformationHelper.NoStatusValidation ) {
                    if (UpdatedCase.status <> oldCase.status) {

                        if (!IFAP_BusinessRules.IsStatusCanBeSelected(false, updatedCase, oldCase , currentUserProfile, isIfapAuthorizedUser)) {
                            System.debug('IFAP_BusinessRules.IsStatusCanBeSelected............trg');
                            updatedCase.addError('The following case status cannot be selected: ' + updatedCase.status);
                        } else if (IFAP_BusinessRules.FSValidationCheckBox(updatedCase, oldCase , currentUserProfile)) {
                            System.debug('IFAP_BusinessRules.FSValidationCheckBox..........');
                            updatedCase.addError('The case cannot be saved. Tick ALL the Financial Security Validation checkboxes and enter FS Submitted Date to save the case.' );
                        }
                    }
                }
                /*
                // check if the FA template's country matches the case country
                EmailTemplate__c[] et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id =: updatedCase.EmailTemplate__c];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                  updatedCase.addError('The selected Initial Request Email Template does not match the case country.');
                }

                // check if the FA reminder template's country matches the case country
                et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id =: updatedCase.Reminder_EmailTemplate__c];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                  updatedCase.addError('The selected Reminder Email Template does not match the case country.');
                }

                // check if the FS template's country matches the case country
                et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id =: updatedCase.FS_EmailTemplate__c];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                  updatedCase.addError('The selected FS Email Template does not match the case country.');
                }

                // check if the FS reminder template's country matches the case country
                et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id =: updatedCase.FS_Reminder_EmailTemplate__c];
                if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                  updatedCase.addError('The selected FS Reminder Email Template does not match the case country.');
                }*/

                // check if the FA template's country matches the case country
                if (UpdatedCase.EmailTemplate__c != null && (UpdatedCase.EmailTemplate__c <> oldCase.EmailTemplate__c)) {
                    EmailTemplate__c[] et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : updatedCase.EmailTemplate__c and et.recordType.Name = 'IFAP'];
                    if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                        updatedCase.addError('The selected Initial Request Email Template does not match the case country.');
                    }
                }

                // check if the FA reminder template's country matches the case country
                if (UpdatedCase.Reminder_EmailTemplate__c != null && (UpdatedCase.Reminder_EmailTemplate__c <> oldCase.Reminder_EmailTemplate__c)) {
                    EmailTemplate__c[] et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : updatedCase.Reminder_EmailTemplate__c and et.recordType.Name = 'IFAP'];
                    if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                        updatedCase.addError('The selected Reminder Email Template does not match the case country.');
                    }
                }

                // check if the FS template's country matches the case country
                if (UpdatedCase.FS_EmailTemplate__c != null && (UpdatedCase.FS_EmailTemplate__c <> oldCase.FS_EmailTemplate__c)) {
                    EmailTemplate__c[] et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : updatedCase.FS_EmailTemplate__c and et.recordType.Name = 'IFAP'];
                    if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                        updatedCase.addError('The selected FS Email Template does not match the case country.');
                    }
                }

                // check if the FS reminder template's country matches the case country
                if (UpdatedCase.FS_Reminder_EmailTemplate__c != null && (UpdatedCase.FS_Reminder_EmailTemplate__c <> oldcase.FS_Reminder_EmailTemplate__c)) {
                    EmailTemplate__c[] et = [Select et.IATA_ISO_Country__r.Id from EmailTemplate__c et where et.Id = : updatedCase.FS_Reminder_EmailTemplate__c and et.recordType.Name = 'IFAP'];
                    if (et.size() > 0 && !IFAP_BusinessRules.isTemplateCountryValid(et[0], updatedCase.IFAP_Country_ISO__c)) {
                        updatedCase.addError('The selected FS Reminder Email Template does not match the case country.');
                    }
                }

                // check if the account country was changed
                if (IFAP_BusinessRules.AccountCountryHasChanged(oldCase, UpdatedCase)) {
                    // validate the account's country
                    if (!IFAP_BusinessRules.isCountryValid(UpdatedCase, accountMap))
                        UpdatedCase.addError('The account\'s country is not valid.');
                    else
                        IFAP_BusinessRules.setCountryAreaAndISOCode(UpdatedCase, accountMap);
                }

                //check if region is missing
                if (UpdatedCase.Region__c == '' || UpdatedCase.Region__c == null) {
                    IFAP_BusinessRules.setCountryAreaAndISOCode(UpdatedCase, accountMap);
                }

                //updatedCase.IsComplaint__c = false;

                /////////////////
                // Phase 4

                // check if Parent case is a SAAM case
                if (String.valueOf(updatedCase.ParentId) != '' && IFAP_BusinessRules.isSAAMCase(updatedCase.ParentId)) {
                    Case theParentCase = [Select c.Id, c.CaseNumber from Case c where c.Id = :updatedCase.ParentId limit 1];

                    // check if a new parent SAAM case has been assigned
                    if (oldCase.ParentId <> updatedCase.ParentId) {
                        //INC158616 - changed to list and check if size > 0
                        Case childCaseOfParent;
                        List<Case> listChildCaseOfParent = [Select c.Id, c.CaseNumber, c.RecordTypeId FROM Case c WHERE c.ParentId = :updatedCase.ParentId AND c.Id <> :updatedCase.Id AND c.RecordTypeId = : IFAPcaseRecordTypeID LIMIT 1];
                        if (listChildCaseOfParent <> null && listChildCaseOfParent.size() > 0) {
                            updatedCase.addError('The selected parent SAAM case already has a child IFAP case.');
                        }
                    }

                    // update some fields in the parent SAAM case
                    IFAP_BusinessRules.updateParentSAAMCase(oldCase, updatedCase);
                }
                
                //don not allow change of Financial Review Result for unauthorized users
                if (updatedCase.Financial_Review_Result__c <> oldCase.Financial_Review_Result__c && !isIfapAuthorizedUser && !currentUserProfile.Name.toLowerCase().contains('system administrator')) {
                    updatedCase.addError('Your user does not have the permission to change the Financial Review Result field.');
                }

                //when case has an OSCAR attached must synchronize fields
                if(updatedCase.Oscar__c != null)
                    AMS_Utils.syncOSCARwithIFAP(oldCase, updatedCase);

            }
        }
    }
}