public without sharing class DPCCasesUtil {

    public static final Id CASE_RT_DPC = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Inter_DPCs');

    private static final map<String,String> mapMainStatusControllingDPCStatus = new map<String, String>{
                                        '2.0 IE approved - Escalated DPC for PQ' => '2.0 New', 
                                        '2.3 BC - Pending DPC feedback' => '2.3 BC - IATA feedback provided', 
                                        '3.3 PQ approved - Stakeholder comm done' => '3.3 PQ approved', 
                                        '4.2 Development - pending DPC feedback' => '4.2 Development - pending DPC feedback', 
                                        /*'5.1 UAT Approval-Pend Internal Approval' => '5.0 UAT results - pending IATA approval',*/ 
                                        '5.2 UAT approval - pending DPC feedback' => '5.2 UAT approval - pending DPC feedback', 
                                        '6.0 UAT Approval - DD - s/holder comm' => '6.0 UAT Approved - DD in progress', 
                                        '7.1 Doc review - pending DPC feedback' => '7.1 Doc review - Pending DPC feedback', 
                                        '8.0 Doc review - completed' => '8.0 Doc review - completed', 
                                        '9.0 Closed' => '9.0 Closed',
                                        'Closed' => '9.0 Closed', 
                                        '10. Rejected - before PQ' => '10. Rejected - before PQ', 
                                        '11. Rejected - after PQ' => '11. Rejected - after PQ'
                                        };
    
    private static final map<String,String> mapDPCStatusControllingMainStatus = new map<String, String>{
                                        '2.1 BC - pending IATA feedback' => '2.1 BC - Pending DPCM feedback',
                                        '3.0 BC completed - PQ in progress' => '3.0 BC completed - PQ in progress',
                                        '3.1 PQ delivered - waiting IATA approval' => '3.1 PQ received - pending DPCM feedback',
                                        '4.0 UAT date provided - Dev in progress' => '4.0 UAT date received - Dev in progress',
                                        '4.1 Development - Pending IATA feedback' => '4.1 Development - pending IATA feedback',
                                        '5.0 UAT results - pending IATA approval' => '5.0 UAT results - pending DPCM approval',
                                        '5.3 UAT approval - DPC feedback provided' => '5.3 UAT approval - DPC feedback received',
                                        '6.1 DD Date Provided - DD in Progress' => '6.1 DD Date Provided - DD in Progress',
                                        '7.0 DD completed - Pending IATA review' => '7.0 DD Completed - Doc review ongoing',
                                        '7.2 Doc review - DPC Feedback Provided' => '7.2 Doc Review - DPC feedback received'
                                        };
    
    private static final map<String,Double> mapStatusNumberPerStatusValue = new map<String, Double>{
                                        '0. New - pending case assignment' => 0,
                                        'New' => 0,
                                        '1.0 IE - Case Assigned' => 1,
                                        '1.1 IE - pending internal eval/approval' => 1.1,
                                        '1.2 IE - pending DPCM eval/ approval' => 1.2,
                                        '2.0 IE approved - Escalated DPC for PQ' => 2,
                                        '2.1 BC - Pending DPCM feedback' => 2.1,
                                        '2.2 BC - Pending internal feedback' => 2.2,
                                        '2.3 BC - Pending DPC feedback' => 2.3,
                                        '3.0 BC completed - PQ in progress' => 3,
                                        '3.1 PQ received - pending DPCM feedback' => 3.1,
                                        '3.2 PQ received - pend Internal feedback' => 3.2,
                                        '3.3 PQ approved - Stakeholder comm done' => 3.3,
                                        '4.0 UAT date received - Dev in progress' => 4,
                                        '4.1 Development - pending IATA feedback' => 4.1,
                                        '4.2 Development - pending DPC feedback' => 4.2,
                                        '5.0 UAT results - pending DPCM approval' => 5,
                                        '5.1 UAT Approval-Pend Internal Approval' => 5.1,
                                        '5.2 UAT approval - pending DPC feedback' => 5.2,
                                        '5.3 UAT approval - DPC feedback received' => 5.3,
                                        '6.0 UAT Approval - DD - s/holder comm' => 6,
                                        '6.1 DD Date Provided - DD in Progress' => 6.1,
                                        '7.0 DD Completed - Doc review ongoing' => 7,
                                        '7.1 Doc review - pending DPC feedback' => 7.1,
                                        '7.2 Doc Review - DPC feedback received' => 7.2,
                                        '8.0 Doc review - completed' => 8,
                                        '9.0 Closed' => 9,
                                        'Closed' => 9,
                                        '10. Rejected - before PQ' => 0,
                                        '11. Rejected - after PQ' => 0
                                        };
    
    private static final map<String,String> mapPhasePerStatus = new map<String, String>{
                                        '0. New - pending case assignment' => 'Initial evaluation and approval',
                                        'New' => 'Initial evaluation and approval',
                                        '1.0 IE - Case Assigned' => 'Initial evaluation and approval',
                                        '1.1 IE - pending internal eval/approval' => 'Initial evaluation and approval',
                                        '1.2 IE - pending DPCM eval/ approval' => 'Initial evaluation and approval',
                                        '2.0 IE approved - Escalated DPC for PQ' => 'Business clarification by DPC',
                                        '2.1 BC - Pending DPCM feedback' => 'Business clarification by DPC',
                                        '2.2 BC - Pending internal feedback' => 'Business clarification by DPC',
                                        '2.3 BC - Pending DPC feedback' => 'Business clarification by DPC',
                                        '3.0 BC completed - PQ in progress' => 'PQ delivery and approval',
                                        '3.1 PQ received - pending DPCM feedback' => 'PQ delivery and approval',
                                        '3.2 PQ received - pend Internal feedback' => 'PQ delivery and approval',
                                        '3.3 PQ approved - Stakeholder comm done' => 'PQ delivery and approval',
                                        '4.0 UAT date received - Dev in progress' => 'Development',
                                        '4.1 Development - pending IATA feedback' => 'Development',
                                        '4.2 Development - pending DPC feedback' => 'Development',
                                        '5.0 UAT results - pending DPCM approval' => 'UAT approval',
                                        '5.1 UAT Approval-Pend Internal Approval' => 'UAT approval',
                                        '5.2 UAT approval - pending DPC feedback' => 'UAT approval',
                                        '5.3 UAT approval - DPC feedback received' => 'UAT approval',
                                        '6.0 UAT Approval - DD - s/holder comm' => 'Deployment and Documentation',
                                        '6.1 DD Date Provided - DD in Progress' => 'Deployment and Documentation',
                                        '7.0 DD Completed - Doc review ongoing' => 'Deployment and Documentation',
                                        '7.1 Doc review - pending DPC feedback' => 'Documentation Review',
                                        '7.2 Doc Review - DPC feedback received' => 'Documentation Review',
                                        '8.0 Doc review - completed' => 'Documentation Review',
                                        '9.0 Closed' => 'Finalization',
                                        'Closed' => 'Finalization',
                                        '10. Rejected - before PQ' => 'Finalization',
                                        '11. Rejected - after PQ' => 'Finalization'
                                        };
    
    private static final set<String> setMilestoneStatuses = new set<String>{
                                        '0. New - pending case assignment',
                                        'New',
                                        '1.0 IE - Case Assigned',
                                        '2.0 IE approved - Escalated DPC for PQ',
                                        '3.0 BC completed - PQ in progress',
                                        '3.1 PQ received - pending DPCM feedback',
                                        '3.3 PQ approved - Stakeholder comm done',
                                        '4.0 UAT date received - Dev in progress',
                                        '5.0 UAT results - pending DPCM approval',
                                        '6.0 UAT Approval - DD - s/holder comm',
                                        '7.0 DD Completed - Doc review ongoing',
                                        '8.0 Doc review - completed',
                                        '9.0 Closed',
                                        'Closed',
                                        '10. Rejected - before PQ',
                                        '11. Rejected - after PQ'
                                        };
    
    private static final map<String,String> mapMilestonePerStatus = new map<String, String>{
                                        '0. New - pending case assignment' => '0. New - pending case assignment',
                                        'New' => '0. New - pending case assignment',
                                        '1.0 IE - Case Assigned' => '1.0 IE - Case Assigned',
                                        '1.1 IE - pending internal eval/approval' => '1.0 IE - Case Assigned',
                                        '1.2 IE - pending DPCM eval/ approval' => '1.0 IE - Case Assigned',
                                        '2.0 IE approved - Escalated DPC for PQ' => '2.0 IE approved - Escalated DPC for PQ',
                                        '2.1 BC - Pending DPCM feedback' => '2.0 IE approved - Escalated DPC for PQ',
                                        '2.2 BC - Pending internal feedback' => '2.0 IE approved - Escalated DPC for PQ',
                                        '2.3 BC - Pending DPC feedback' => '2.0 IE approved - Escalated DPC for PQ',
                                        '3.0 BC completed - PQ in progress' => '3.0 BC completed - PQ in progress',
                                        '3.1 PQ received - pending DPCM feedback' => '3.1 PQ received - pending DPCM feedback',
                                        '3.2 PQ received - pend Internal feedback' => '3.1 PQ received - pending DPCM feedback',
                                        '3.3 PQ approved - Stakeholder comm done' => '3.3 PQ approved - Stakeholder comm done',
                                        '4.0 UAT date received - Dev in progress' => '4.0 UAT date received - Dev in progress',
                                        '4.1 Development - pending IATA feedback' => '4.0 UAT date received - Dev in progress',
                                        '4.2 Development - pending DPC feedback' => '4.0 UAT date received - Dev in progress',
                                        '5.0 UAT results - pending DPCM approval' => '5.0 UAT results - pending DPCM approval',
                                        '5.1 UAT Approval-Pend Internal Approval' => '5.0 UAT results - pending DPCM approval',
                                        '5.2 UAT approval - pending DPC feedback' => '5.0 UAT results - pending DPCM approval',
                                        '5.3 UAT approval - DPC feedback received' => '5.0 UAT results - pending DPCM approval',
                                        '6.0 UAT Approval - DD - s/holder comm' => '6.0 UAT Approval - DD - s/holder comm',
                                        '6.1 DD Date Provided - DD in Progress' => '6.0 UAT Approval - DD - s/holder comm',                                       
                                        '7.0 DD Completed - Doc review ongoing' => '7.0 DD Completed - Doc review ongoing',
                                        '7.1 Doc review - pending DPC feedback' => '7.0 DD Completed - Doc review ongoing',
                                        '7.2 Doc Review - DPC feedback received' => '7.0 DD Completed - Doc review ongoing',
                                        '8.0 Doc review - completed' => '8.0 Doc review - completed',
                                        '9.0 Closed' => '9.0 Closed',
                                        'Closed' => '9.0 Closed',
                                        '10. Rejected - before PQ' => '10. Rejected - before PQ',
                                        '11. Rejected - after PQ' => '11. Rejected - after PQ'
                                        };
                                        
    private static final map<String, Integer> mapMilestoneOrderPerMilestone = new map<String, Integer>{
    									'0. New - pending case assignment' => 0,
    									'1.0 IE - Case Assigned' => 1,
    									'2.0 IE approved - Escalated DPC for PQ' => 2,
    									'3.0 BC completed - PQ in progress' => 3,
    									'3.1 PQ received - pending DPCM feedback' => 4,
    									'3.3 PQ approved - Stakeholder comm done' => 5,
    									'4.0 UAT date received - Dev in progress' => 6,
    									'5.0 UAT results - pending DPCM approval' => 7,
    									'6.0 UAT Approval - DD - s/holder comm' => 8,
    									'7.0 DD Completed - Doc review ongoing' => 9,
    									'8.0 Doc review - completed' => 10,
    									'9.0 Closed' => 11,
    									'10. Rejected - before PQ' => -1,
    									'11. Rejected - after PQ' => -1
    									};
                                        
    private static final map<Integer, String> mapMilestoneNamePerMilestoneOrder = new map<Integer, String>{
    									0 => '0. New - pending case assignment',
    									1 => '1.0 IE - Case Assigned',
    									2 => '2.0 IE approved - Escalated DPC for PQ',
    									3 => '3.0 BC completed - PQ in progress',
    									4 => '3.1 PQ received - pending DPCM feedback',
    									5 => '3.3 PQ approved - Stakeholder comm done',
    									6 => '4.0 UAT date received - Dev in progress',
    									7 => '5.0 UAT results - pending DPCM approval',
    									8 => '6.0 UAT Approval - DD - s/holder comm',
    									9 => '7.0 DD Completed - Doc review ongoing',
    									10 => '8.0 Doc review - completed',
    									11 => '9.0 Closed'
    									};
    
    // to prevent the trigger from running twice (because of the WF rules changing the record) and generating the case milestones twice
    private static boolean isMilestoneAlreadyGenerated = false;
    
    
    /*
     * Changes the Escalated Status DPC and Status one in function of the other, only for DPC cases and only when the values of the fields change
     */
    public static void HandleStatusUpdate (map<Id,Case> TriggerNew, map<Id,Case> TriggerOld, Boolean isInsert, Boolean isUpdate) {
        Id RT_ACR_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request');
        Id RT_ACR_locked_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_DPC_Systems_locked');
        Id RT_ACR_ACCA_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_DPC_Systems_ACCA');
                
        for (Case c : TriggerNew.values()) {
            if (c.RecordTypeId == RT_ACR_Id || c.RecordTypeId == RT_ACR_locked_Id || c.RecordTypeId == RT_ACR_ACCA_Id) {
                // Update the cases's Status or Escalated Status DPC fields as necessary
                if (mapMainStatusControllingDPCStatus.get(c.Status) != null && ( isInsert || TriggerNew.get(c.Id).Status != TriggerOld.get(c.Id).Status ) ) {
                    c.Escalated_Status_ACCA__c = mapMainStatusControllingDPCStatus.get(c.Status);
                }
                
                if (mapDPCStatusControllingMainStatus.get(c.Escalated_Status_ACCA__c) != null && ( isInsert || TriggerNew.get(c.Id).Escalated_Status_ACCA__c != TriggerOld.get(c.Id).Escalated_Status_ACCA__c ) ) {
                    c.Status = mapDPCStatusControllingMainStatus.get(c.Escalated_Status_ACCA__c);
                }
                
                ValidateMandatoryFields(c);
            }
        }
                
    }
    
    
    /*
     * Validate that mandatory fields with special conditions are filled (mandatory starting only starting from a certain Status onwards) 
     */
    private static void ValidateMandatoryFields(Case c) {
        // From this point on, field Source of Case is mandatory
        if (mapStatusNumberPerStatusValue.get(c.Status) >= 2 && c.Source_of_Case__c == null) {
            c.addError('The field Source of Case is mandatory.');
        }
        
        // From this point on, Estimated Delivery Date field is mandatory
        if (mapStatusNumberPerStatusValue.get(c.Status) >= 4 && c.Estimated_Delivery_Date__c == null) {
            c.addError('The field Estimated Delivery Date is mandatory.');
        }
        
        // For any status from this point on, the following fields are mandatory: Evaluation effort, Specification/design effort, Coding effort, Unit Test effort, System test effort, 
        //      QA Effort, Documentation effort, Implementation effort, Estimated total person days, Case Currency, Estimated total quotation
        if (mapStatusNumberPerStatusValue.get(c.Status) >= 3.1) {
            if (c.Evaluation_Effort__c == null) {
                c.addError('The field Evaluation Effort is mandatory.');
            }
            
            if (c.Specification_Effort__c == null) {
                c.addError('The field Specification/Design Effort is mandatory.');
            }
            
            if (c.Coding_Effort__c == null) {
                c.addError('The field Coding Effort is mandatory.');
            }
            
            if (c.Unit_Test_Effort__c == null) {
                c.addError('The field Unit Test Effort is mandatory.');
            }
            
            if (c.System_Test_Effort__c == null) {
                c.addError('The field System Test Effort is mandatory.');
            }
            
            if (c.QA_Effort__c == null) {
                c.addError('The field QA Effort is mandatory.');
            }
            
            if (c.Documentation_Effort__c == null) {
                c.addError('The field Documentation Effort is mandatory.');
            }
            
            if (c.Implementation_Effort__c == null) {
                c.addError('The field Implementation Effort is mandatory.');
            }
            
            if (c.Estimated_Total_Person_days__c == null) {
                c.addError('The field Estimated Total Person-days is mandatory.');
            }
            
            if (c.Estimated_Total_Development_Cost__c == null) {
                c.addError('The field Estimated Total Quotation is mandatory.');
            }
            
            if (c.CurrencyIsoCode == null) {
                c.addError('The field Case Currency is mandatory.');
            }           
            
        }
        
        // From this point on, P.O. Number field is mandatory
        if (mapStatusNumberPerStatusValue.get(c.Status) >= 3.3) {
            if (c.PO_Number__c == null) {
                c.addError('The field P.O. Number is mandatory.');
            }
        }
        
        // From this point on, the Planned Documentation Date and Planned Deployment Date fields are mandatory
        if (mapStatusNumberPerStatusValue.get(c.Status) >= 6.1) {
            if (c.Planned_Documentation_Date__c == null) {
                c.addError('The field Planned Documentation Date is mandatory.');
            }
            if (c.Planned_Implementation_Date__c == null) {
                c.addError('The field Planned Deployment Date is mandatory.');
            }
            /*
            if (c.Planned_Documentation_Date__c != null && c.Planned_Implementation_Date__c != null && c.Planned_Documentation_Date__c >= c.Planned_Implementation_Date__c) {
                c.addError('The Planned Documentation Date should be before the Planned Deployment Date.');
            }*/
        }
        
        // From this point on, the Deployment Completed and Documentation Complete fields are mandatory
        if (mapStatusNumberPerStatusValue.get(c.Status) >= 7) {
            if (c.Deployment_date_to_acca__c == null) { // label Deployment Completed
                c.addError('The field Deployment Completed is mandatory.');
            }
            if (c.Documentation_Complete__c == null) {
                c.addError('The field Documentation Complete is mandatory.');
            }
        }
    }
    
    
    /*
     * creates the Case Milestone records for the cases passed in the first parameter 
     */
    public static void CreateMilestones(map<Id,Case> TriggerNew, map<Id,Case> TriggerOld, Boolean isInsert, Boolean isUpdate) {
        Id RT_ACR_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request');
        Id RT_ACR_locked_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_DPC_Systems_locked');
        Id RT_ACR_ACCA_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_DPC_Systems_ACCA');
        
        // Continue only if the milestones have not already been generated
        if (isMilestoneAlreadyGenerated) {
            system.debug(LoggingLevel.error,'################### isMilestoneAlreadyGenerated : ' + isMilestoneAlreadyGenerated );
            return;
        }
                
        // create a map of the cases that have reached a milestone
        map<Id, Case> mapCasesWithMilestonesPerId = new map<Id, Case>();
        
        for (Case c : TriggerNew.values()) {
            if (c.RecordTypeId == RT_ACR_Id || c.RecordTypeId == RT_ACR_locked_Id || c.RecordTypeId == RT_ACR_ACCA_Id) {
                // if the case reaches a milestone, handle the milestone creation 
                if ( isUpdate && TriggerOld.get(c.Id).Status != c.Status && mapMilestonePerStatus.get( TriggerOld.get(c.Id).Status ) != mapMilestonePerStatus.get( c.Status )){ // setMilestoneStatuses.contains(c.Status)
                	mapCasesWithMilestonesPerId.put(c.Id, c);
                }
            }
        }
        
        // we only create Case Milestone records on update, because we create the records at the end of the actual milestone, to be able to track the time spent on it.
        if (!mapCasesWithMilestonesPerId.values().isEmpty() && isUpdate) {
                        
            List<Case_Milestone__c> lstNewMilestones = new List<Case_Milestone__c>();
            
            // get a list of the previous milestones from the cases that reached new milestones
            List<Case> lstCasesWithPrevMilestones = [SELECT Id, 
            											(SELECT Id, Time_Escalated_Externally__c, Time_Escalated_Internally__c, Time_With_Support__c, 
            												Total_Time_Escalated_Externally__c, Total_Time_Escalated_Internally__c, Total_Time_With_Support__c, End_Date__c, 
            												StatusName__c 
                										 FROM Case_Milestones__r 
                										 ORDER BY CreatedDate DESC, Id DESC LIMIT 1) 
            										 FROM Case 
            										 WHERE Id = :mapCasesWithMilestonesPerId.keyset()];
            										 // ORDER BY CreatedDate DESC, StatusName__c DESC LIMIT 1
            // put them in a map
            map<Id, Case_Milestone__c> mapPrevMilestonePerCaseId = new map<Id, Case_Milestone__c>();
            
            for (Case c : lstCasesWithPrevMilestones) {
                if (c.Case_Milestones__r.size() > 0) {
                    mapPrevMilestonePerCaseId.put(c.Id, c.Case_Milestones__r[0]);
                }
            }
            
            // Create the new milestones: we create a Case Milestone record for the milestone that has just ended - this way we know the time spent in that milestone. The
            // Milestone Date represents the date the milestone has been reached, and it equals the end date of the previous milestone (or the creation date of the case for the first one). 
            // The last milestone will be created when the case is closed - no further milestones needed afterwards (for closed / rejected).
            for (Case c : mapCasesWithMilestonesPerId.values()){
                Case_Milestone__c cm = new Case_Milestone__c();
                cm.Case__c = c.Id;
                cm.StatusName__c = mapMilestonePerStatus.get( TriggerOld.get(c.Id).Status ); // get the old status
                cm.Classification_Phase__c = mapPhasePerStatus.get(TriggerOld.get(c.Id).Status); // get the phase name for the old status
                cm.Type__c = 'DPC Application Change Request';
                
                // End Date is by default the moment when the next milestone is hit ("now")
                cm.End_Date__c = DateTime.now();
                
                // previous milestone (can be NULL)
                Case_Milestone__c prev = mapPrevMilestonePerCaseId.get(c.Id);
                
                // calculate time spent
                if (prev != null) {
                    // if there is a previous milestone, time spent = overall time spent on the case until now - time spent on the case until the last milestone
                    cm.Time_Escalated_Externally__c = c.Time_Escalated_Externally__c - prev.Total_Time_Escalated_Externally__c;
                    cm.Time_Escalated_Internally__c = c.Time_Escalated__c - prev.Total_Time_Escalated_Internally__c;
                    cm.Time_With_Support__c = c.Time_With_Support__c - prev.Total_Time_With_Support__c;
                    cm.Milestone_Date__c = prev.End_Date__c;
                } else {
                    // no previous milestone => this is the first milestone => all the times spent on the case belong to this milestone
                    cm.Time_Escalated_Externally__c = c.Time_Escalated_Externally__c;
                    cm.Time_Escalated_Internally__c = c.Time_Escalated__c;
                    cm.Time_With_Support__c = c.Time_With_Support__c;
                    cm.Milestone_Date__c = c.CreatedDate;
                }
                
                // fill the total time values from the case - will be used for the calculations in the next milestones
                cm.Total_Time_Escalated_Externally__c = c.Time_Escalated_Externally__c;
                cm.Total_Time_Escalated_Internally__c = c.Time_Escalated__c;
                cm.Total_Time_With_Support__c = c.Time_With_Support__c;
                
                // MOVED INSERT BELOW
                //lstNewMilestones.add(cm);
                
                
                // Check if any milestone was skipped between the current one and the previous milestone. If so create them with 0 time spent and total times the same as the previous.
                // Only do this when skipping forward (e.g. when jumping from 3.0 to 8.0, but not when going from 8.0 to 3.0)
                if (prev != null && mapMilestoneOrderPerMilestone.get(cm.StatusName__c) != null && mapMilestoneOrderPerMilestone.get(prev.StatusName__c) != null && 
                	mapMilestoneOrderPerMilestone.get(cm.StatusName__c) - mapMilestoneOrderPerMilestone.get(prev.StatusName__c) > 1) {
                		
                	for (Integer i = mapMilestoneOrderPerMilestone.get(prev.StatusName__c) + 1; i < mapMilestoneOrderPerMilestone.get(cm.StatusName__c); i++) {
                		Case_Milestone__c ms = new Case_Milestone__c();
			            ms.Case__c = c.Id;
			            ms.StatusName__c = mapMilestoneNamePerMilestoneOrder.get(i);
			            ms.Classification_Phase__c = mapPhasePerStatus.get(ms.StatusName__c);
			            ms.Milestone_Date__c = prev.End_Date__c;
                		ms.End_Date__c = prev.End_Date__c;
                		
                		// all the times spent on this milestone are 0
	                    ms.Time_Escalated_Externally__c = 0;
	                    ms.Time_Escalated_Internally__c = 0;
	                    ms.Time_With_Support__c = 0;
                		
                		// fill the total time values from the previous milestone
		                ms.Total_Time_Escalated_Externally__c = prev.Total_Time_Escalated_Externally__c;
		                ms.Total_Time_Escalated_Internally__c = prev.Total_Time_Escalated_Internally__c;
		                ms.Total_Time_With_Support__c = prev.Total_Time_With_Support__c;
		                
		                lstNewMilestones.add(ms);
                	}
                }
                
                // ADD TO THE LIST HERE, so it's inserted after the potentially skipped milestones above and before the ones below - for the correctly ordered display in the related list
                lstNewMilestones.add(cm);
                
                // Create the milestones from the last one created up until the current milestone (exclusively), if needed
                // If so create them with 0 time spent and total times the same as the new "real" milestone being created.
                if (mapMilestoneOrderPerMilestone.get(cm.StatusName__c) != null && mapMilestoneOrderPerMilestone.get(mapMilestonePerStatus.get(c.Status)) != null) {
	                for (Integer i = mapMilestoneOrderPerMilestone.get(cm.StatusName__c) + 1; i < mapMilestoneOrderPerMilestone.get(mapMilestonePerStatus.get(c.Status)); i++) {
	            		Case_Milestone__c ms = new Case_Milestone__c();
			            ms.Case__c = c.Id;
			            ms.StatusName__c = mapMilestoneNamePerMilestoneOrder.get(i);
			            ms.Classification_Phase__c = mapPhasePerStatus.get(ms.StatusName__c);
			            ms.Milestone_Date__c = cm.End_Date__c;
	            		ms.End_Date__c = cm.End_Date__c;
	            		
	            		// all the times spent on this milestone are 0
	                    ms.Time_Escalated_Externally__c = 0;
	                    ms.Time_Escalated_Internally__c = 0;
	                    ms.Time_With_Support__c = 0;
	            		
	            		// fill the total time values from the newly created "real" milestone
		                ms.Total_Time_Escalated_Externally__c = cm.Total_Time_Escalated_Externally__c;
		                ms.Total_Time_Escalated_Internally__c = cm.Total_Time_Escalated_Internally__c;
		                ms.Total_Time_With_Support__c = cm.Total_Time_With_Support__c;
		                
		                lstNewMilestones.add(ms);
	            	}
                }
            	
                // If the case is closing with a "9.0 Closed" status, create the milestone with 0 time spent and total times the same as the new "real" milestone being created
                if (c.Status == '9.0 Closed') {
                	Integer i = mapMilestoneOrderPerMilestone.get(mapMilestonePerStatus.get(c.Status));
                	
            		Case_Milestone__c ms = new Case_Milestone__c();
		            ms.Case__c = c.Id;
		            ms.StatusName__c = mapMilestoneNamePerMilestoneOrder.get(i);
		            ms.Classification_Phase__c = mapPhasePerStatus.get(ms.StatusName__c);
		            ms.Milestone_Date__c = cm.End_Date__c;
            		ms.End_Date__c = cm.End_Date__c;
            		
            		// all the times spent on this milestone are 0
                    ms.Time_Escalated_Externally__c = 0;
                    ms.Time_Escalated_Internally__c = 0;
                    ms.Time_With_Support__c = 0;
            		
            		// fill the total time values from the newly created "real" milestone
	                ms.Total_Time_Escalated_Externally__c = cm.Total_Time_Escalated_Externally__c;
	                ms.Total_Time_Escalated_Internally__c = cm.Total_Time_Escalated_Internally__c;
	                ms.Total_Time_With_Support__c = cm.Total_Time_With_Support__c;
	                
	                lstNewMilestones.add(ms);
                	
                }
            }
            
            if (!lstNewMilestones.isEmpty()) {
            	system.debug('Inserting new milestones: ' + lstNewMilestones);
                insert lstNewMilestones;
                
                // Mark that the Case Milestones have been generated 
                isMilestoneAlreadyGenerated = true;
                system.debug(LoggingLevel.error,'################### SETTING isMilestoneAlreadyGenerated : ' + isMilestoneAlreadyGenerated );
            }
            
        }
    }


    private static list<Case> LIST_NEW_DPC_CASES;   // static list to keep only DPC cases in current trigger
    private static map<Id,list<User>> MAP_ACCOUNT_USERS;  // static map to keep all portal users per DPC account
    /**
        Add additional Contact to a new DPC case
        Only for internal users, becase for portal users it is handeled by the VF ISSP_Case
        Executed on Case Before insert
    **/
    public static void addAdditionalContactsBefore(list<Case> listNews) {
        LIST_NEW_DPC_CASES = new list<Case>();
        MAP_ACCOUNT_USERS = new map<Id,list<User>>();

        //only for internal users
        if (UserInfo.getUserType()!='Standard') return;

        //only for Cases DPC recordtype
        list<Id> listAccountId = new list<Id>();
        for (Case cse: listNews) {
            if (cse.RecordTypeId == CASE_RT_DPC) {
               LIST_NEW_DPC_CASES.add(cse);
               listAccountId.add(cse.Account_Concerned__c);
            }
        }

        //find all portal users for the related accounts in the incoming cases
        for (User user: [SELECT ContactId, Contact.Name, Contact.Email, Contact.AccountId
                FROM User
                WHERE isActive = true
                AND Contact.AccountId IN :listAccountId
                AND Contact.User_Portal_Status__c IN ('Approved Admin', 'Approved User')
                AND Contact.Status__c = 'Active']) {
            list<User> listUser = MAP_ACCOUNT_USERS.get(user.Contact.AccountId);
            if (listUser==null) listUser = new list<User>();
            listUser.add(user);
            MAP_ACCOUNT_USERS.put(user.Contact.AccountId, listUser);
        }

        //update AdditionalCC field on the incoming DPC cases
        for (Case dpcCase: LIST_NEW_DPC_CASES) {
            list<User> listUser = MAP_ACCOUNT_USERS.get(dpcCase.Account_Concerned__c);
            dpcCase.E2CP__AdditionalCC__c = getAdditionalCCEmails(listUser);
        }
    }

    /**
        Following the process initiated by addAdditionalContactsBefore()
        Executed on Case After Insert
    **/
    public static void addAdditionalContactsAfter() {
        // get the list of Case Team Members to add to new DPC Cases and all emails to notify them
        List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
        List<Messaging.SingleEmailMessage> listMemberEmail = new List<Messaging.SingleEmailMessage>();
        for (Case dpcCase: LIST_NEW_DPC_CASES) {
            list<User> listUsers = MAP_ACCOUNT_USERS.get(dpcCase.Account_Concerned__c);
            //Create All case Team members
            list<CaseTeamMember> listMembers = getListCCOthersToDPC(dpcCase,listUsers);
            listCaseTeamMembers.addAll(listMembers);
            //create an email message to notify the new Team member
            list<Messaging.SingleEmailMessage> listEmail = getListEmailForDPC(dpcCase,listUsers);
            listMemberEmail.addAll(listEmail);
        }

        // insert found users as a team member of their DPC Cases
        Savepoint sp = Database.setSavepoint();
        try {
            if (!listCaseTeamMembers.isEmpty()) insert listCaseTeamMembers;
            //finally sends an email to the full recipients list
            if (!listMemberEmail.isEmpty()) Messaging.sendEmail(listMemberEmail);

        } catch (DMLException e) {
            Database.rollback(sp);
        }
    }

    /**
        Get Partner user Role Id but with a single query
    **/
    private static Id PARTNER_USER_ROLE = null;
    public static id getPartnerUserRoleId() {
        if (PARTNER_USER_ROLE==null) {
            PARTNER_USER_ROLE = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role'].Id;
        }
        return PARTNER_USER_ROLE;
    }

    /**
        Get iata no reply Org Address with a single query
    **/
    private static Id NO_REPLAY_ADDRESS = null;
    public static Id getNoReplyAddressId() {
        if (NO_REPLAY_ADDRESS==null) {
            NO_REPLAY_ADDRESS = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'].Id;
        }
        return NO_REPLAY_ADDRESS;
    }

    /**
        Get template used to notify a new DPC case with a single query
    **/
    private static Id NEW_DPC_TEMPLATE = null;
    public static Id getDPCTemplateId() {
        if (NEW_DPC_TEMPLATE==null) {
            NEW_DPC_TEMPLATE = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'New_DPC_Case'].Id;
        }
        return NEW_DPC_TEMPLATE;
    }

    /**
        Add a list of Case Team Members to the incoming case
        This will create one Case Team Member by each user in the incoming list
    **/
    public static List<CaseTeamMember> getListCCOthersToDPC(Case dpcCase, list<User> listUsers) {
        List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
        if (listUsers==null) listUsers = new list<User>();
        listUsers.add(new User(Id=UserInfo.getUserId())); //adding current user
        for(User user : listUsers) {
            CaseTeamMember teammember = new CaseTeamMember(
                ParentId = dpcCase.Id,
                MemberId = user.Id,
                TeamRoleId = getPartnerUserRoleId());
            listCaseTeamMembers.add(teammember);
        }
        return listCaseTeamMembers;
    }

    /**
        Returns a list of email messages to notify incoming users that a DPC case
        has been created
    **/
    public static List<Messaging.SingleEmailMessage> getListEmailForDPC(Case cse, list<User> listUsers) {
        List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
        if (listUsers!=null) {
            for(User user : listUsers) {
                if (user.ContactId!=null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setOrgWideEmailAddressId(getNoReplyAddressId());
                    mail.setTargetObjectId(user.ContactId);
                    mail.setWhatId(cse.Id);
                    mail.setUseSignature(false);
                    mail.setBccSender(false);
                    mail.setSaveAsActivity(false);
                    mail.setTemplateId(getDPCTemplateId());
                    listEmail.add(mail);
                }
            }
        }
        return listEmail;
    }

    /**
        Returns a list user emails into a string comma separated
    **/
    public static String getAdditionalCCEmails(list<User> listUsers) {
        set<String> setEmails = new set<String>();
        if (listUsers!=null) {
            for(User user : listUsers) {
                setEmails.add(user.Contact.Email);
            }
        }
        setEmails.add(UserInfo.getUserEmail()); //adding current user email
        return String.join(new list<String>(setEmails),';');
    }

}