public class BusinessDays {

	// private map<Id,map<integer,boolean>> businessDayPerCaseId  = new map<Id,map<integer,boolean>>();
	//private List<Boolean> businessDay = new Boolean[7];
	// is the bshours id changing making fire the trigger and what is the filed related to the business days.....

	private static final Id RT_CASES_GLOBAL = RecordTypeSingleton.getInstance().getRecordType('Case', 'Cases_Global').Id;
	private static final Date knownSunday = date.newInstance(2012, 7, 1);

	public static boolean isAllowedRunTwice = False;

	public static map<Id, Date> BusinessDaysPerCaseIdCalc(map<id, Case> triggerNewMap) {

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

	public static boolean compareThisDates(dateTime date1, dateTime date2) {

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
			updatedCase.Case_age_natural_hours__c = updatedCase.Case_age_natural_hours__c == null ? 0 : updatedCase.Case_age_natural_hours__c;

		}
		return  TriggerNewMap;
	}

	private static final set<String> REOPENINGREASONS = new set<string> {'new query', 'thank you', 'no action'};


	//Get a map with the stop statuses on the stopstatus object
	private static BusinessHours defaultHours {
		get {
			if (defaultHours==null) {
				defaultHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
			}
			return defaultHours;
		}
		set;
	}

	//Get a map with the stop statuses on the stopstatus object
	private static map<string, string> stopStatusSetPerBucket {
		get {
			if (stopStatusSetPerBucket==null) {
				stopStatusSetPerBucket = new map<string, string>();
				for (Stop_Status__c stopStatus : [SELECT Name, Status_Bucket__c FROM Stop_Status__c]) {
					stopStatusSetPerBucket.put(stopStatus.Name, stopStatus.Status_Bucket__c );
				}
			}
			return stopStatusSetPerBucket;
		}
		set;
	}

	public static void calculateTheKpis( set<Id> casesIdSoCalculate , map<Id, Case> TriggerNewMap, map<Id, Case> TriggerOldMap) {

		TriggerNewMap = initializTheOldOnes(TriggerNewMap);

		//For any case where the status is changed, recalc the business hours in the buckets
		for (ID caseID : casesIdSoCalculate) {

			Case updatedCase = TriggerNewMap.get(caseID);
			Case oldCase = TriggerOldMap.get(caseID);

			//OK, the status has changed or the businessHoursChanged

			dateTime originalCreated = updatedCase.CreatedDate;
			dateTime createdDatePlusOne = updatedCase.CreatedDate.addHours(1);

			boolean isCreatedDateWithinBH = businessHours.isWithin(updatedCase.businessHoursId, originalCreated);
			boolean isCreatedDatePlusOneWithinBH = businessHours.isWithin(updatedCase.businessHoursId, createdDatePlusOne);

			//------- Covers the 4 scenarios: ---------
			//CD - True  && CD+1 - True  - Created date time
			//CD - False && CD+1 - False - Next start date time
			//CD - True  && CD+1 - False - Next start date time
			//CD - False && CD+1 - True  - Next start date time
			if(isCreatedDateWithinBH && isCreatedDatePlusOneWithinBH){
				updatedCase.First_Business_Day__c = originalCreated;
			} else {
				updatedCase.First_Business_Day__c =  businessHours.nextStartDate( updatedCase.businessHoursId, createdDatePlusOne);
			}

			if (
				!oldCase.IsClosed
				||
				(oldCase.IsClosed && updatedCase.Reopening_reason__c <>  null && !REOPENINGREASONS.contains(updatedCase.Reopening_reason__c) ) // as required

			) {

				//We only update the buckets for open cases
				//to do be sure that the business hours default are not assigned to any other country

				//On the off-chance that the business hours on the case are null, use the default ones instead
				Id hoursToUse = updatedCase.BusinessHoursId != null ? updatedCase.BusinessHoursId : defaultHours.Id;

				Double timeSinceLastStatus = 0;
				if(!oldCase.IsClosed){
					//The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
					timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now()) / 3600000.0;
				}

				Double normaleDatetimeSinceLastStatus = (System.now().getTime() -  updatedCase.Last_Status_Change__c.getTime()) / 3600000.0;

				Double unassignedTime = Math.abs(normaleDatetimeSinceLastStatus - timeSinceLastStatus);

				// Set the time that the case is in an opened status
				if(!oldCase.IsClosed){
					updatedCase.Case_age_natural_hours__c += normaleDatetimeSinceLastStatus;
				}

				if (oldCase.RecordTypeId != RT_CASES_GLOBAL && oldCase.BusinessHoursId  == defaultHours.Id) {
					updatedCase.Time_Unassigned__c += normaleDatetimeSinceLastStatus;
				}
				else if (stopStatusSetPerBucket.get(oldCase.Status) == 'With Customer') {

					// to do  hard coded.....beware.....how about a custom setting?

					updatedCase.Time_With_Customer__c += normaleDatetimeSinceLastStatus;

				} else  if (stopStatusSetPerBucket.get(oldCase.Status) == 'Escalated Internally') { // Internally

					// to do  hard coded.....beware.....how about a custom setting?

					updatedCase.Time_Escalated__c += timeSinceLastStatus;
					if (oldCase.RecordTypeId == RT_CASES_GLOBAL) {
						updatedCase.Time_Unassigned__c += unassignedTime;
					}


					//Time_Escalated_Externally__c
				} else  if (stopStatusSetPerBucket.get(oldCase.Status) == 'Escalated Externally') { // eXTERNALLY

					updatedCase.Time_Escalated_Externally__c += timeSinceLastStatus;

					if (oldCase.RecordTypeId == RT_CASES_GLOBAL) {
						updatedCase.Time_Unassigned__c += unassignedTime;
					}


				} else {

					updatedCase.Time_With_Support__c += timeSinceLastStatus;
					if (oldCase.RecordTypeId == RT_CASES_GLOBAL) {
						updatedCase.Time_Unassigned__c += unassignedTime;
					}
				}
			}

			updatedCase.Last_Status_Change__c = System.now();

		}
	}

	/**
	 * add n working days to input date based on given BusinessHours
	**/
	public static DateTime addNBusinessDays(DateTime inputDate, Integer addDays, Id BusinessHoursId) {
		DateTime currentDate = BusinessHours.nextStartDate(BusinessHoursId, inputDate);
		for ( integer i = 0; i<addDays; i++) {
			currentDate = BusinessHours.nextStartDate(BusinessHoursId, currentDate.addDays(1) );
		}
		return currentDate;
	}
}
