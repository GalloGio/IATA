trigger trgIFAPQualityIssue on IFAP_Quality_Issue__c (before insert, after insert, before update, after update, after delete) {
    // get the IFAP case recordtype
    ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    
    if(Trigger.isAfter && Trigger.isUpdate){
    
            list<id> qualityIssueId = new list<id>();
            for (IFAP_Quality_Issue__c newQualityIssue: Trigger.New) {  
                    if(newQualityIssue.Status__c == 'Approved') qualityIssueId.add(newQualityIssue.id);     
                
            }
            if(qualityIssueId.size() <> 0){IfapToolManager.submitCaseQualityIssuesToMFT(qualityIssueId);
                                            return;
                                            }
    }
    
    
    // get the Profile of the current user
    Profile currentUserProfile = [SELECT ID, Name FROM Profile WHERE id =: UserInfo.getProfileId() limit 1];

    if (Trigger.isBefore) {
    
        List<Case> parentsToUpdate = new List<Case>();
        // Check if at least one of the issues checkboxes is checked
        for (IFAP_Quality_Issue__c newQualityIssue: Trigger.New) {                
            if (Trigger.isInsert) {
                            
                // get parent IFAP case
                Case parentIFAPCase = [Select c.Id, c.Status, c.Quality_Issue_Approved_by_RPM_On__c,
                                              c.Quality_Issue_Rejected_by_RPM_on__c, c.Quality_Issue_rejected_on__c,
                                              c.Reassessment_rejection_reason__c 
                                                from Case c 
                                                where c.Id = :newQualityIssue.Related_Case__c 
                                                and c.RecordType.Id = :IFAPcaseRecordTypeID limit 1];
                
                if (parentIFAPCase == null) {
                    newQualityIssue.addError('Cannot find selected IFAP case.');
                }
                // can only create Reassessments when the case status is "Assessment Performed", "Sanity Check Failure" or "Financial Security Requested"
                else if (parentIFAPCase.Status != 'Assessment Performed' && parentIFAPCase.Status != 'Sanity Check Failure' && parentIFAPCase.Status != 'Financial Security Requested' && parentIFAPCase.Status != 'Quality Issue Rejected') {
                    newQualityIssue.addError('A Quality Issue cannot be created when the related IFAP case status is ' + parentIFAPCase.Status);
                }
                else{
                    // Check if there is an existing Active Quality issue related to the case (only one Quality active quality issue at a time)
                    List<IFAP_Quality_Issue__c> existingQI = [SELECT id  FROM IFAP_Quality_Issue__c WHERE Related_Case__c =: parentIFAPCase.Id AND Status__c <> 'Rejected' AND Status__c <> 'Sent to GFA'];
                    
                    if (existingQI.size() > 0){
                        newQualityIssue.addError('There is already an pending Quality Issue related to this case. Only one pending Quality Issue is allowed.');
                    }
                }
                
                /*
                **When a new Quality Issue is raised, the fields on the Quality Issue parent case must be cleared
                */
                parentIFAPCase.Quality_Issue_Approved_by_RPM_On__c = null;
                parentIFAPCase.Quality_Issue_Rejected_by_RPM_on__c = null;
                parentIFAPCase.Quality_Issue_rejected_on__c = null;
                parentIFAPCase.Reassessment_rejection_reason__c = null;
                parentIFAPCase.Quality_Issue_Raised_on__c = null;
                
                parentsToUpdate.add(parentIFAPCase);
                /*
                ** Commented by: Frederic Tremblay 2014-04-29
                ** No need to update the case status on a Quality issue creation, we have created an approval workflow to request the approval of a quality Issue request
                // only admins and RPMs can create reassessment request
                else if (!currentUserProfile.Name.toLowerCase().contains('system administrator') && !currentUserProfile.Name.toLowerCase().contains('rpm')) {
                    newReassessment.addError('Only admins and RPMs can create Quality Issue request');
                }
                // OK
                else {
                    // update related IFAP case status to Reassessment Request Pending Approval
                    // parentIFAPCase.Status = 'Quality Issue Request Pending Approval';
                    update parentIFAPCase;
                }*/

            }
            
            if (!IFAP_BusinessRules.isAtLeastOneQualityIssueIsSelected (newQualityIssue)){
                newQualityIssue.addError('No issue selected');
            }
            
            if (IFAP_BusinessRules.isOtherDetailsFieldRequired(newQualityIssue) && (newQualityIssue.Other_Issue_details__c == null || newQualityIssue.Other_Issue_details__c.trim() == '')){
                newQualityIssue.addError('Other Details field is mandatory if one of the field of the Accounting issue section is selected');
            }
            if (IFAP_BusinessRules.isFormattingIssueDetailsRequired(newQualityIssue) && (newQualityIssue.Formatting_Issue_details__c == null || newQualityIssue.Formatting_Issue_details__c.trim() == '')){
                newQualityIssue.addError('Formatting Issue Details field is mandatory if one of the field of the Formatting issue section is selected');
            }
        }
        
        update parentsToUpdate;
        
    }
    else {    
        if (Trigger.isUpdate) {
            for (IFAP_Quality_Issue__c updatedReassessment: Trigger.New) {
                
                // get parent IFAP case
                Case parentIFAPCase = [Select c.Id, c.Status from Case c where c.Id = :updatedReassessment.Related_Case__c and c.RecordType.Id = :IFAPcaseRecordTypeID limit 1];
                
                // a Reassessment cannot be updated if it has been approved or submitted to PwC
                if (parentIFAPCase.Status == 'Quality Issue Request Approved' || parentIFAPCase.Status == 'Quality Issue Requested') {
                    // Check if it is the status who changed. if not throw the error message else it's an automated process so it's fine.
                    IFAP_Quality_Issue__c oldQI = Trigger.oldMap.get(updatedReassessment.ID); 
                    
                    if (updatedReassessment.Name <> oldQI.Name || updatedReassessment.Financials_not_audited_certified__c <> oldQI.Financials_not_audited_certified__c ||
                        updatedReassessment.Assessment_using_wrong_template__c <> oldQI.Assessment_using_wrong_template__c || updatedReassessment.Challenge_Source__c <> oldQI.Challenge_Source__c || 
                        updatedReassessment.Formatting_Issue_details__c <> oldQI.Formatting_Issue_details__c || updatedReassessment.Incorrect_sales_used_for_the_assessment__c <> oldQI.Incorrect_sales_used_for_the_assessment__c ||
                        updatedReassessment.Incorrect_sanity_check_failure__c <> oldQI.Incorrect_sanity_check_failure__c || updatedReassessment.Missing_value_in_fields__c <> oldQI.Missing_value_in_fields__c ||
                        updatedReassessment.Need_to_update_the_template_instructions__c <> oldQI.Need_to_update_the_template_instructions__c || updatedReassessment.Other__c <> oldQI.Other__c ||
                        updatedReassessment.Other_Issue_details__c <> oldQI.Other_Issue_details__c || updatedReassessment.Parent_company_accounts_not_reviewed__c <> oldQI.Parent_company_accounts_not_reviewed__c ||
                        updatedReassessment.Output_is_empty_not_completed_has_errors__c <> oldQI.Output_is_empty_not_completed_has_errors__c || updatedReassessment.Related_Case__c <> oldQI.Related_Case__c || updatedReassessment.Template_working_properly__c <> oldQI.Template_working_properly__c ||
                        updatedReassessment.The_printout_of_the_result_is_unreadable__c <> oldQI.The_printout_of_the_result_is_unreadable__c || updatedReassessment.Wrong_figure_was_extracted__c <> oldQI.Wrong_figure_was_extracted__c ||
                        updatedReassessment.Wrong_financial_year__c <> oldQI.Wrong_financial_year__c){
                            updatedReassessment.addError('The Reassessment cannot be updated when the IFAP case status is ' + parentIFAPCase.Status);
                    }
                    continue;
                }
            }
        }
        else if (Trigger.isDelete) {
            for (IFAP_Quality_Issue__c deletedReassessment: Trigger.old) {
                
                // get parent IFAP case
                Case parentIFAPCase = [Select c.Id, c.Status from Case c where c.Id = :deletedReassessment.Related_Case__c and c.RecordType.Id = :IFAPcaseRecordTypeID limit 1];
                
                // a Reassessment cannot be deleted if it has been approved or submitted to PwC
                if (parentIFAPCase.Status == 'Quality Issue Request Approved' || parentIFAPCase.Status == 'Quality Issue Requested') {
                    deletedReassessment.addError('The Reassessment cannot be deleted when the IFAP case status is ' + parentIFAPCase.Status);
                    continue;
                }
            }
        }
    }
}