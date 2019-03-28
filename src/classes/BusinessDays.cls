public class BusinessDays {
    
    // private map<Id,map<integer,boolean>> businessDayPerCaseId  = new map<Id,map<integer,boolean>>();
    //private List<Boolean> businessDay = new Boolean[7];
    // is the bshours id changing making fire the trigger and what is the filed related to the business days.....
    
    private static final Date knownSunday = date.newInstance(2012, 7, 1);
    
    public static boolean isAllowedRunTwice = False;
    
    public static   map<Id, Date>  BusinessDaysPerCaseIdCalc(map<id, Case> triggerNewMap) {
        
        map<Id, Date> nextBusinessDay = new map<Id, Date>();
        
        for (Id CaseID : triggerNewMap.keyset()) {
            
            DateTime Nextdate ;
            Datetime targetTime;
            Date returnDate;
            DateTime returnDatetime;
            
            if (triggerNewMap.get(CaseID).Short_Payment_Date__c <> null) {
                
                Case c = triggerNewMap.get(CaseID);
                integer day = c.Short_Payment_Date__c.day();
                integer year = c.Short_Payment_Date__c.year();
                integer month = c.Short_Payment_Date__c.month();
                
                targetTime = Datetime.newInstance(year, month, day, 10, 30, 0);
                
                
                NextDate = BusinessHours.nextStartDate(c.BusinessHoursId, targetTime);
                dateTime businessNextDayAfter = NextDate;
                
                do {
                    businessNextDayAfter = BusinessHours.add(c.BusinessHoursId, businessNextDayAfter, 3600000); // we add one hour until we reach the other Biz day
                    
                } while (businessNextDayAfter.day() ==  NextDate.day());
                
                returnDateTime = compareThisDates(targetTime, NextDate) ? businessNextDayAfter : NextDate; // 1 day in milliseconds
                
                returnDate = Date.newInstance(returnDatetime.year(), returnDatetime.month(), returnDatetime.day());
                
                nextBusinessDay.put(CaseID, returnDate);
                
            }
        }
        
        
        return nextBusinessDay;
        
    }
    
    
    public static  boolean compareThisDates(dateTime date1, dateTime date2) {
        
        if (date1.year() == date2.year() && date1.month() == date2.month() && date1.day() == date2.day() )
            return true;
        
        return false;
    }
    
    
    private static map<Id, Case> initializTheOldOnes(map<Id, Case> TriggerNewMap) {
        
        for (ID caseID : TriggerNewMap.keySet()) {
            Case updatedCase = TriggerNewMap.get(caseID);
            //  updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Case_Age_In_Business_Hours__c == null ? 0 : updatedCase.Case_Age_In_Business_Hours__c;
            updatedCase.Time_Unassigned__c = updatedCase.Time_Unassigned__c == null ? 0 : updatedCase.Time_Unassigned__c;
            updatedCase.Time_With_Customer__c = updatedCase.Time_With_Customer__c == null ? 0 : updatedCase.Time_With_Customer__c;
            updatedCase.Time_With_Support__c = updatedCase.Time_With_Support__c == null ? 0 : updatedCase.Time_With_Support__c;
            updatedCase.Time_Escalated__c = updatedCase.Time_Escalated__c == null ? 0 : updatedCase.Time_Escalated__c;
            updatedCase.Time_Escalated_Externally__c = updatedCase.Time_Escalated_Externally__c == null ? 0 : updatedCase.Time_Escalated_Externally__c;
            
        }
        return  TriggerNewMap;
        
    }
    
    private static final set<String> REOPENINGREASONS = new set<string> {'new query', 'thank you', 'no action'};
        
        public static void calculateTheKpis( set<Id> casesIdSoCalculate , map<Id, Case> TriggerNewMap, map<Id, Case> TriggerOldMap) {
            
            
            // TO DO THIS GOES TO ANOTHER CLASS.....
            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault = true];
            
            map<string, string> stopStatusSetPerBucket = new map<string, string>();
            // to do we should handle somehow the uniquess of the statutess making another field filled
            // via workflow on te stopstatus object
            
            //Get the stop statuses
            for (Stop_Status__c stopStatus : [Select Name, Status_Bucket__c From Stop_Status__c]) {
                stopStatusSetPerBucket.put(stopStatus.Name, stopStatus.Status_Bucket__c );
                
            }
            
            
            //Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)
            Set<String> closedStatusSet = new Set<String>();
            for (CaseStatus status : [Select MasterLabel From CaseStatus where IsClosed = true]) {
                closedStatusSet.add(status.MasterLabel);
            }
            
            TriggerNewMap = initializTheOldOnes(TriggerNewMap);
            
            //For any case where the status is changed, recalc the business hours in the buckets
            for (ID caseID : casesIdSoCalculate) {
                
                Case updatedCase = TriggerNewMap.get(caseID);
                Case oldCase = TriggerOldMap.get(caseID);
                
                //if(updatedCase.BusinessHoursId <> oldCase.BusinessHoursId){
                dateTime originalCreated = updatedCase.CreatedDate;
                dateTime createDatePlusOne = updatedCase.CreatedDate.addHours(1);
                dateTime result  =   businessHours.nextStartDate( updatedCase.businessHoursId, createDatePlusOne);
                updatedCase.First_Business_Day__c   = createDatePlusOne.day() == result.day() ?  originalCreated : result;
                //}
                /*    if(updatedCase.First_Business_Day__c.hour() == updatedCase.createdDate.addHours(1).hour())
throw new transformationException('updatedCase.First_Business_Day__c' +  updatedCase.First_Business_Day__c
+'createDatePlusOne.day()' +createDatePlusOne.day()
+'result.day()' +result.day()
+'result     ' +      result
+'originalCreated ' +originalCreated);*/
                
                
                //OK, the status has changed or the businessHoursChanged
                
                if (
                    !oldCase.IsClosed
                    ||
                    (oldCase.IsClosed && updatedCase.Reopening_reason__c <>  null && !REOPENINGREASONS.contains(updatedCase.Reopening_reason__c) ) // as required
                    
                ) {
                    
                    //We only update the buckets for open cases
                    //to do be sure that the business hours default are not assigned to any other country
                    
                    //On the off-chance that the business hours on the case are null, use the default ones instead
                    Id hoursToUse = updatedCase.BusinessHoursId != null ? updatedCase.BusinessHoursId : defaultHours.Id;


                    Id processRTId = RecordTypeSingleton.getInstance().getRecordType('Case', 'CS_Process_IDFS_ISS').Id;
                    Id globalRT = RecordTypeSingleton.getInstance().getRecordType('Case', 'Cases_Global').Id;
                    //hoursToUse  = '01m200000000S6AAAU'; // germany
					
					Double timeSinceLastStatus = 0;
					if(!oldCase.IsClosed){
						//The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
						timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now()) / 3600000.0;
						System.debug(timeSinceLastStatus);
						// millisecond()
					}
					
                    Double normaleDatetimeSinceLastStatus = (System.now().getTime() -  updatedCase.Last_Status_Change__c.getTime()) / 3600000.0;
                    System.debug('+++TA in BA: '+ normaleDatetimeSinceLastStatus);
                    
                    Double unassignedTime = Math.abs(normaleDatetimeSinceLastStatus - timeSinceLastStatus);
                 
                    System.debug('+++TA as unassigned: '+ unassignedTime);
                    
                    System.debug('+++ST ' + oldCase.Status);
                    System.debug('+++STB '+ stopStatusSetPerBucket.get(oldCase.Status));
                    
                    // if record type == process it is a escalated internally case
                   // if (oldCase.RecordTypeId == processRTId) {
                     //   updatedCase.Time_Escalated__c += timeSinceLastStatus;
                       // updatedCase.Time_Unassigned__c += unassignedTime;
                        
                    //} else 
                    if (oldCase.RecordTypeId != globalRT && oldCase.BusinessHoursId  == defaultHours.Id) {
                        updatedCase.Time_Unassigned__c += normaleDatetimeSinceLastStatus;
                    }
                    else if (stopStatusSetPerBucket.get(oldCase.Status) == 'Pending Customer') {
                        
                        // to do  hard coded.....beware.....how about a custom setting?
                        
                        updatedCase.Time_With_Customer__c += normaleDatetimeSinceLastStatus;
                        
                    } else  if (stopStatusSetPerBucket.get(oldCase.Status) == 'Escalated Internally') { // Internally
                        
                        // to do  hard coded.....beware.....how about a custom setting?
                        
                        updatedCase.Time_Escalated__c += timeSinceLastStatus;
                        if (oldCase.RecordTypeId == globalRT) {
                            updatedCase.Time_Unassigned__c += unassignedTime;
                        }

                        
                        //Time_Escalated_Externally__c
                    } else  if (stopStatusSetPerBucket.get(oldCase.Status) == 'Escalated Externally') { // eXTERNALLY
                        
                        updatedCase.Time_Escalated_Externally__c += timeSinceLastStatus;

                        if (oldCase.RecordTypeId == globalRT) {
                            updatedCase.Time_Unassigned__c += unassignedTime;
                        }
                        
                        
                    } else {
                        
                        updatedCase.Time_With_Support__c += timeSinceLastStatus;
                        if (oldCase.RecordTypeId == globalRT) {
                            updatedCase.Time_Unassigned__c += unassignedTime;
                        }                        
                    }
                }
                
                updatedCase.Last_Status_Change__c = System.now();
                
                
                //throw new transformationException('  asdsasd  ' + updatedCase.Last_Status_Change__c  +    '  updatedCase.First_closure_date__c  ' + updatedCase.First_closure_date__c );
                
                /*if (updatedCase.First_closure_date__c <> null ) {
updatedCase.ClosedSameDay__c =  compareThisDates( updatedCase.First_Business_Day__c, updatedCase.First_closure_date__c) || (updatedCase.First_closure_date__c < updatedCase.First_Business_Day__c)  ? 'Yes' : 'No';
// throw new transformationException('updatedCase.First_Business_Day__c    '+ updatedCase.First_Business_Day__c
//                                     +   '   updatedCase.First_closure_date__c    ' + updatedCase.First_closure_date__c);
}*/
                
            }
        }
    
    /**
add n working days to input date based on given BusinessHours
**/
    public static DateTime addNBusinessDays(DateTime inputDate, Integer addDays, Id BusinessHoursId) {
        DateTime currentDate = BusinessHours.nextStartDate(BusinessHoursId, inputDate);
        for ( integer i = 0; i<addDays; i++) {
            currentDate = BusinessHours.nextStartDate(BusinessHoursId, currentDate.addDays(1) );
        }
        return currentDate;
    }
}