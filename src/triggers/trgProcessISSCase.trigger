trigger trgProcessISSCase on Case (before insert, before update) {
    
    // get the IFAP and ProcessISS case recordtype
    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    ID ProcessISSPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM
    
    //TF
    Set <Id> caseIds = new Set <Id>();

    if (Trigger.isInsert) {
        
        // loop tru cases to be created
        for(Case newCase: trigger.new) {
            
            // only process case of type SAAM
            if (newCase.RecordTypeId == ProcessISSPcaseRecordTypeID) {

                // get parent case
                Case[] parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.Account.Type, c.Deadline_Date__c, c.FA_Second_Deadline_Date__c, c.Third_FA_non_Compliance_Date__c, c.FS_Deadline_Date__c, c.FA_Third_Deadline_Date__c, FS_Second_Deadline_Date__c from Case c where c.Id =: newCase.ParentId];
                if (parentCase != null && parentCase.size() > 0) {
                    
                    // check if parent case is an IFAP case
                    if (parentCase[0].RecordTypeId == IFAPcaseRecordTypeID) {

                        // first business rule
                        if (parentCase[0].FA_Letter_Sent__c == False
                            && (parentCase[0].Status == 'Agent Notified (Mail)' || parentCase[0].Status == 'Agent Notified (Email)' || parentCase[0].Status == 'Financial Statements Uploaded' || parentCase[0].Status == 'Sanity Check Failure')
                            ) {
                            newCase.addError('The ?FA Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed.');
                        }
                        
                        // second business rule
                        if (parentCase[0].FS_Letter_Sent__c == False
                            && parentCase[0].Status == 'Financial Security Requested') {
                            newCase.addError('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed');
                        }
                        
                        // third business rule
                        if (newCase.Status == 'Open' && newCase.Reason1__c == 'FA/ FS Non-Compliance' && (parentCase[0].Status == 'Action Needed'
                            || parentCase[0].Status == 'Agent to be Notified'
                            || parentCase[0].Status == 'Agent to be notified (Email)'
                            || parentCase[0].Status == 'Assessment Performed'
                            || parentCase[0].Status == 'Financial Security Provided'
                            || parentCase[0].Status == 'Re-open/ed'
                            || parentCase[0].Status == 'Submitted'
                            || parentCase[0].Status == 'Assessment Cancelled'
                            || parentCase[0].Status == 'Closed'))
                            {
                                newCase.addError('A Non-compliance case cannot be created when the parent case status is ' + parentCase[0].Status);
                        }

                        // Fix for INC054114: 03-July-2013 - assign non-compliance dates
                        if(newCase.CaseArea__c == 'Accreditation Process' 
                            && newCase.reason1__c == 'FA/ FS Non-Compliance' 
                            && newCase.Origin == 'Internal Case') {

                            // flags
                            Boolean isPassengerDomestic = (parentCase[0].Account.Type == 'IATA Passenger Sales Agent' || parentCase[0].Account.Type == 'Domestic Agent');
                            Boolean isCargoCASS = (parentCase[0].Account.Type == 'IATA Cargo Agent' || parentCase[0].Account.Type == 'CASS Associate');

                            // the deadline date must not be set for Passenger/Domestic Agents
                            if (isPassengerDomestic && newCase.New_IFAP_Deadline_date__c != null) {
                                newCase.addError('The New IFAP Deadline date must be empty for non-compliance cases on Passenger and Domestic agents');
                                continue;
                            }

                            //set IFAP case non compliance date
                            //BRD: Item 2.4
                            if (parentCase[0].Status == 'Financial Security Requested') {
                                //FS non compliance case
                                if(parentCase[0].firstFSnonComplianceDate__c == null) {
                                    
                                    // cannot create a 1st FS non-compliance case if 1st deadline date has not been reached yet
                                    if (parentCase[0].FS_Deadline_Date__c >= Date.today()) {
                                        newCase.addError('Cannot create a 1st FS non-compliance case. The 1st FS Deadline is ' + parentCase[0].FS_Deadline_Date__c.format());
                                        continue;
                                    }
                                    
                                    parentCase[0].firstFSnonComplianceDate__c = Date.today();
                                    
                                    // set 2nd FS deadline date for PAX and Domestic agents
                                    if (isPassengerDomestic) {
                                        // business rule: 31 days after the non-compliance case is raised
                                        parentCase[0].FS_Second_Deadline_Date__c = parentCase[0].firstFSnonComplianceDate__c.addDays(31);
                                        
                                        // business rule changed: the last day of the following month after the non-compliance case is raised
                                        //Date inTwoMonths = parentCase[0].firstFSnonComplianceDate__c.addMonths(2);
                                        //Date newDeadline = Date.newInstance(inTwoMonths.year(), inTwoMonths.month(), 1);
                                        //newDeadline = newDeadline.addDays(-1);
                                        //parentCase[0].FS_Second_Deadline_Date__c = newDeadline;
                                        //System.debug('FS Second Deadline = ' + newDeadline);
                                        
                                    }
                                    else if (isCargoCASS) {
                                        
                                        if (newCase.New_IFAP_Deadline_date__c == null) {
                                            newCase.addError('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.');
                                            continue;
                                        }
                                        else {
                                            // copy deadline date to IFAP case
                                            parentCase[0].FS_Second_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                        }
                                    }
                                }
                                else if (parentCase[0].secondFSnonComplianceDate__c == null) {    
                                    
                                    // cannot create a 2nd FS non-compliance case if 2nd deadline date has not been reached yet
                                    if (parentCase[0].FS_Second_Deadline_Date__c >= Date.today()) {
                                        newCase.addError('Cannot create a 2nd FS non-compliance case. The 2nd FS Deadline is ' + parentCase[0].FS_Second_Deadline_Date__c.format());
                                        continue;
                                    }
                                    
                                    parentCase[0].secondFSnonComplianceDate__c = Date.today();
                                    
                                    // set 3rd FS deadline date for PAX and Domestic agents
                                    if (isPassengerDomestic) {
                                        // business rule: 31 days after the non-compliance case is raised
                                        Date inTwoMonths = parentCase[0].secondFSnonComplianceDate__c.addMonths(2);
                                        Date newDeadline = Date.newInstance(inTwoMonths.year(), inTwoMonths.month(), 1);
                                        newDeadline = newDeadline.addDays(-1);
                                        parentCase[0].FS_Third_Deadline_Date__c = newDeadline;
                                    }
                                    else if (isCargoCASS) {
                                        
                                        if (newCase.New_IFAP_Deadline_date__c == null) {
                                            newCase.addError('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.');
                                            continue;
                                        }
                                        else {
                                            // copy deadline date to IFAP case
                                            parentCase[0].FS_Third_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                        }
                                    }
                                }
                                else {
                                    newCase.addError('Cannot create a 3rd FS non-compliance case.');
                                }
                            }
                            else {

                                // 1st FA non-compliance case
                                if(parentCase[0].firstFAnonComplianceDate__c == null) {

                                    // cannot create a 1st FA non-compliance case if 1st deadline date has not been reached yet
                                    if (parentCase[0].Deadline_Date__c >= Date.today()) {
                                        newCase.addError('Cannot create a 1st FA non-compliance case. The 1st FA Deadline is ' + parentCase[0].Deadline_Date__c.format());
                                        continue;
                                    }
                                    
                                    parentCase[0].firstFAnonComplianceDate__c = Date.today();

                                    // set 2nd FA deadline date for PAX and Domestic agents
                                    if (isPassengerDomestic) {
                                        // business rule: 31 days after the non-compliance case is raised
                                        parentCase[0].FA_Second_Deadline_Date__c = parentCase[0].firstFAnonComplianceDate__c.addDays(31);
                                    }
                                    else if (isCargoCASS) {

                                        if (newCase.New_IFAP_Deadline_date__c == null) {
                                            newCase.addError('The New IFAP Deadline date is mandatory when creating a 1st non-compliance for Cargo or CASS agents.');
                                            continue;
                                        }
                                        else {
                                            // copy deadline date to IFAP case
                                            parentCase[0].FA_Second_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                        }
                                    }
                                }
                                // 2nd FA non-compliance
                                else if (parentCase[0].secondFAnonComplianceDate__c == null) {
                                    
                                    // cannot create a 2nd FA non-compliance case if 2nd deadline date has not been reached yet
                                    if (parentCase[0].FA_Second_Deadline_Date__c >= Date.today()) {
                                        newCase.addError('Cannot create a 2nd FA non-compliance case. The 2nd FA Deadline is ' + parentCase[0].FA_Second_Deadline_Date__c.format());
                                        continue;
                                    }
                                    
                                    parentCase[0].secondFAnonComplianceDate__c = Date.today();
                                    
                                    // set 3rd FA deadline date for PAX and Domestic agents
                                    if (isPassengerDomestic) {
                                        // business rule: the last day of the following month after the non-compliance case is raised
                                        Date inTwoMonths = parentCase[0].secondFAnonComplianceDate__c.addMonths(2);
                                        Date newDeadline = Date.newInstance(inTwoMonths.year(), inTwoMonths.month(), 1);
                                        newDeadline = newDeadline.addDays(-1);
                                        parentCase[0].FA_Third_Deadline_Date__c = newDeadline;
                                    }
                                    else if (isCargoCASS) {
                                        
                                        if (newCase.New_IFAP_Deadline_date__c == null) {
                                            newCase.addError('The New IFAP Deadline date is mandatory when creating a 2nd non-compliance for Cargo or CASS agents.');
                                            continue;
                                        }
                                        else {
                                            // copy deadline date to IFAP case
                                            parentCase[0].FA_Third_Deadline_Date__c = newCase.New_IFAP_Deadline_date__c;
                                        }
                                    }
                                }
                                // 3rd FA non-compliance
                                else if (parentCase[0].Third_FA_non_Compliance_Date__c == null) {
                                    
                                    // cannot create a 3rd FA non-compliance case if 3rd deadline date has not been reached yet
                                    if (parentCase[0].FA_Third_Deadline_Date__c >= Date.today()) {
                                        newCase.addError('Cannot create a 3rd FA non-compliance case. The 3rd FA Deadline is ' + parentCase[0].FA_Third_Deadline_Date__c.format());
                                        continue;
                                    }
                                    else {
                                        parentCase[0].Third_FA_non_Compliance_Date__c = Date.today();
                                    }
                                }
                                // 4th non-compliance is blocked
                                else {
                                    newCase.addError('Cannot create a 4th FA non-compliance case.');
                                }
                            }
                            
                            update parentCase[0];
                        }
                    }
                }
            }
        }
    }
    else if (Trigger.isUpdate) {
        
        // loop tru cases to be update
        for(Case updatedCase: trigger.New) {
        	
        	//TF
        	if (updatedCase.Make_All_Attachments_Public__c){
        		updatedCase.Make_All_Attachments_Public__c = false;
        		caseIds.add(updatedCase.Id);
        	}
        	if (!system.isFuture() &&!caseIds.isEmpty()){
        		AttachmentTriggerHelper.makeAllPublic(caseIds);
        	}
            
            // only process case of type SAAM
            if (updatedCase.RecordTypeId == ProcessISSPcaseRecordTypeID) {

                // get parent case
                Case[] parentCase = [Select c.Id, c.FA_Letter_Sent__c, c.FS_Letter_Sent__c, c.Status, c.RecordTypeId, c.firstFSnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.firstFAnonComplianceDate__c, c.secondFAnonComplianceDate__c from Case c where c.Id =: updatedCase.ParentId];
                if (parentCase != null && parentCase.size() > 0) {
                    
                    // check if parent case is an IFAP case
                    if (parentCase[0].RecordTypeId == IFAPcaseRecordTypeID) {

                        // first business rule
                        if (parentCase[0].FA_Letter_Sent__c == False
                            && (parentCase[0].Status == 'Agent Notified (Mail)' || parentCase[0].Status == 'Agent Notified (Email)' || parentCase[0].Status == 'Financial Statements Uploaded' || parentCase[0].Status == 'Sanity Check Failure')
                            ) {
                            updatedCase.addError('The ?FA Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed.');
                        }
                        
                        // second business rule
                        if (parentCase[0].FS_Letter_Sent__c == False
                            && parentCase[0].Status == 'Financial Security Requested') {
                            updatedCase.addError('The ?FS Letter Sent? check box has not been ticked, kindly send the physical letter requesting the financial documents to the Agent before you proceed');
                        }
                        
                        // third business rule
                        if (updatedCase.Status == 'Open' && updatedCase.Reason1__c == 'FA/ FS Non-Compliance' && (parentCase[0].Status == 'Action Needed'
                            || parentCase[0].Status == 'Agent to be Notified'
                            || parentCase[0].Status == 'Agent to be notified (Email)'
                            || parentCase[0].Status == 'Assessment Performed'
                            || parentCase[0].Status == 'Financial Security Provided'
                            || parentCase[0].Status == 'Re-open/ed'
                            || parentCase[0].Status == 'Submitted'
                            || parentCase[0].Status == 'Assessment Cancelled'
                            || parentCase[0].Status == 'Closed'))
                            {
                                updatedCase.addError('A Non-compliance case cannot be updated when the parent case status is ' + parentCase[0].Status);
                        }
                    }
                }
            }
        }
    }
}