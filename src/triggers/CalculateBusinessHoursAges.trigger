trigger CalculateBusinessHoursAges on Case (before update) {

    // Handling of DPC cases - automatic status change
    DPCCasesUtil.HandleStatusUpdate(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
    
    //INC147754
    for (Case updatedCase : System.Trigger.new) {
        if (updatedCase.First_closure_date__c <> null && updatedCase.First_Business_Day__c <> null) {
            updatedCase.ClosedSameDay__c =  BusinessDays.compareThisDates( updatedCase.First_Business_Day__c, updatedCase.First_closure_date__c) || (updatedCase.First_closure_date__c < updatedCase.First_Business_Day__c)  ? 'Yes' : 'No';
        }
        
         //Here we calculate the first contact with client in business hours
        Case oldCase = System.Trigger.oldMap.get(updatedCase.Id);
        if(updatedCase.BusinessHoursId <> null && updatedCase.First_Contact_with_Client__c <> null && (updatedCase.First_Contact_w_Client_in_Business_Hours__c != oldCase.First_Contact_w_Client_in_Business_Hours__c || updatedCase.First_Contact_w_Client_in_Business_Hours__c == null))
            updatedCase.First_Contact_w_Client_in_Business_Hours__c = BusinessHours.diff(updatedCase.BusinessHoursId, updatedCase.CreatedDate, updatedCase.First_Contact_with_Client__c) / 3600000.0;
        
    }

    if (Trigger.isUpdate && (!transformationHelper.CalculateBusinessHoursAgesGet() || BusinessDays.isAllowedRunTwice)) { // we are on the update so we have the caseIDS!Hurra!!

        //Get the default business hours (we might need it)

        set<id> casesIdSoCalculate = new set<id>();
        map<string, list<Case>> ListCasesIDsperbusinessHourId = new map<string, list<Case>>();

        for (Case updatedCase : System.Trigger.new) {

            updatedCase.Last_Status_Change__c  = updatedCase.Last_Status_Change__c <> null ? updatedCase.Last_Status_Change__c : System.now();

            Case oldCase = System.Trigger.oldMap.get(updatedCase.Id);
            // this very next section is for the kpi
            if (
                (oldCase.Status != updatedCase.Status)
                ||
                (updatedCase.BusinessHoursId <> null && updatedCase.BusinessHoursId <> oldCase.BusinessHoursId)
                ||
                (oldCase.First_Business_Day__c == null)
            ) {

                casesIdSoCalculate.add(updatedCase.id);
            }
            // the following section is used for the
            // nex short day , to find the very next business day
            if (updatedCase.BusinessHoursId <> null &&
                    updatedCase.Short_Payment_Date__c <> null ) {

                if (ListCasesIDsperbusinessHourId.get(updatedCase.BusinessHoursId) == null)
                    ListCasesIDsperbusinessHourId.put(updatedCase.BusinessHoursId, new list<Case>());
                ListCasesIDsperbusinessHourId.get(updatedCase.BusinessHoursId).add(updatedCase);

            }
           
        }

        if (!ListCasesIDsperbusinessHourId.isEmpty()) {
            // to do this goes to an helper class as well

            map<Id, Date> nextBusinessDayPerCaseID = BusinessDays.BusinessDaysPerCaseIdCalc(Trigger.newMap);

            for (Id caseID : nextBusinessDayPerCaseID.keySet()) {
                System.Trigger.newMap.get(caseID).Short_Payment_Next_Business_Date__c = nextBusinessDayPerCaseID.get(caseID);

            }
        }

        // we do the logic only if needed.....to avoid any unacessary soql queries....
        // to do...review the logic a bit
        if (!casesIdSoCalculate.isEmpty())
            BusinessDays.calculateTheKpis(casesIdSoCalculate , Trigger.NewMap, Trigger.OldMap);
        transformationHelper.CalculateBusinessHoursAgesSet();
    }
    
    
    // Handling of DPC cases - milestone tracking
    DPCCasesUtil.CreateMilestones(Trigger.newMap, Trigger.oldMap, Trigger.isUpdate);
    
}