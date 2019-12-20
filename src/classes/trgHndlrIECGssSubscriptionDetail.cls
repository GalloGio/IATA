/*
 * Trigger Helper class for GSS_Subscription_Detail
 *  - trigger helper class, mainly intended for GSS_Subscription_Detail
 *  - current functionality:
 *	= initialize GSS_Subscription_Detail.Calendar_Next_Submission_Date
 *  - also used by non trigger:
 *    = calculateCalendarNextSubmissionDate()
 *
 * Change Log:
 *  - 20160210-sl :initial version: use calculateCalendarNextSubmissionDate
 */
public with sharing class trgHndlrIECGssSubscriptionDetail {

	// same default values as defined in trgHndlrIECSubscriptionToDetail
	private static final String CALENDAR_OPTION_DEFAULT_WEEKLY = 'Monday';
	private static final String CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_1 = '10';
	private static final String CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_2 = '24';
	private static final String CALENDAR_OPTION_DEFAULT_MONTHLY = '10';
	private static final Integer CALENDAR_OPTION_MIDDLE_OF_MONTH = 15;


	// ========================================================================
	// initialized fields on GSS_Subscription_Detail on upsert, if necessary
	//  - Calendar_Next_Submission_Date__c
	public static void onUpsertGssSubscriptionDetail( List<GSS_Subscription_Detail__c> subDetailList)
	{
		// get related zuora subscription and file description
		Set<Id> zuoraSubIdSet = new Set<Id>();
		Set<Id> fileDescriptionIdSet = new Set<Id>();

		for (GSS_Subscription_Detail__c sd : subDetailList)
		{
			if (sd.Zuora_Subscription__c != null) {
				zuoraSubIdSet.add(sd.Zuora_Subscription__c);
			}
			if (sd.GDP_File_Description__c != null) {
				fileDescriptionIdSet.add(sd.GDP_File_Description__c);
			}
		} // end for
		Map<Id, Zuora__Subscription__c> zuoraSubsIdToObjMap = new Map<Id,Zuora__Subscription__c> ([select Id, Zuora__SubscriptionStartDate__c
				from Zuora__Subscription__c
				where Id in : zuoraSubIdSet
			]);
		Map<Id, GDP_File_Description__c> fileDescIdToObjMap = new Map<Id,GDP_File_Description__c> ([select Id, Frequency__c
				from GDP_File_Description__c
				where Id in : fileDescriptionIdSet
			]);

		// initialize GSS_Subscription_Detail__c.Calendar_Next_Submission_Date__c, if necessary
		for (GSS_Subscription_Detail__c sd : subDetailList)
		{
			// reset irrelevant calendar options, populate required calendar options that are blank
			setDefaultCalendarOptionsAsRequired(sd, fileDescIdToObjMap.get(sd.GDP_File_Description__c).Frequency__c);
			// set Calendar Next Submision Date
			if ( (sd.Calendar_Next_Submission_Date__c == null)
				&& (sd.GDP_File_Description__c != null)
				&& (sd.Zuora_Subscription__c != null) )
			{
				sd.Calendar_Next_Submission_Date__c = calculateCalendarNextSubmissionDate( sd
					, fileDescIdToObjMap.get(sd.GDP_File_Description__c).Frequency__c
					, zuoraSubsIdToObjMap.get(sd.Zuora_Subscription__c).Zuora__SubscriptionStartDate__c
					);
			}
		} // end for
	} // end of onUpsertGssSubscriptionDetail



	// ========================================================================
	// this will calculate the value for Calendar_Next_Submission_Date
	// based on current date, Frequency, related Calendar_Option, and subscription start date.
	//
	// the calculated nextSubmissionDate can be used for replacing GSS_Subscription_Detail__c.Calendar_Next_Submission_Date.
	// the calculated value nextSubmissionDate will be on the future date.
	// intent in: subDetail.Calendar_*_Option, deliveryFrequency, zuoraSubscriptionStartDate,
	// return valuet: subDetail.Calendar_Next_Submission_Date
	public static Date calculateCalendarNextSubmissionDate(GSS_Subscription_Detail__c subDetail, String deliveryFrequency, Date zuoraSubscriptionStartDate)
	{
		Date dToday = (Test.isRunningTest()) ? vfIECGSSCalendar_tst.dToday : Date.today(); // Used to simulate specific dates during test methods
		System.debug( 'calculateCalendarNextSubmissionDate(): dToday:' + dToday);

		// earliestDate is used to take the Zuora__SubscriptionStartDate__c into consideration, in addition to the current day
		Date earliestDate = ((zuoraSubscriptionStartDate != null) && (dToday < zuoraSubscriptionStartDate)) ? zuoraSubscriptionStartDate : dToday;
		Integer iTodayDay = earliestDate.day();
		Integer iTodayMonth = earliestDate.month();
		Integer iTodayYear = earliestDate.year();
		Integer iTodayYearMonth = (iTodayYear * 10) + iTodayMonth;

		Date nextSubmissionDate; // this return value will be calculated below
		System.debug( 'calculateCalendarNextSubmissionDate(): earliestDate:' + earliestDate);

		// Calculate the coming next submission based on the delivery frequency and the calendar options
		if (deliveryFrequency == 'Weekly') {
			String sTodayDayOfWeek = DateTime.newInstance(dToday, Time.newInstance(0, 0, 0, 0)).format('EEEE');
			Integer iTodayDayOfWeek = getDayNumberFromWeekDay(sTodayDayOfWeek);
			Integer iWeekOption = getDayNumberFromWeekDay(subDetail.Calendar_Weekly_Option__c);

			// if Calendar_Next_Submission_Date is null, assume that it is the first current week's DayOfWeek
			nextSubmissionDate = earliestDate.addDays(iWeekOption - iTodayDayOfWeek);
			if (nextSubmissionDate <= earliestDate) {
				nextSubmissionDate = nextSubmissionDate.addDays(7);
			}
		} // end if weekly
		else if (deliveryFrequency == 'Semi-Monthly') {
			Integer iSemiMonthlyOption1 = integer.valueOf(subDetail.Calendar_Semi_Monthly_First_Option__c);
			Integer iSemiMonthlyOption2 = integer.valueOf(subDetail.Calendar_Semi_Monthly_Second_Option__c);

			if (10 < iTodayDay && iTodayDay < 15)
			{ // Today is in a free window where no submission is possible
				nextSubmissionDate = Date.newInstance(iTodayYear, iTodayMonth, iSemiMonthlyOption2);
			}
			else if (iTodayDay <= 10)
			{ // Today is in the window of the first semi-monthly submission window
				nextSubmissionDate = Date.newInstance(iTodayYear, iTodayMonth, iSemiMonthlyOption1);
				if (nextSubmissionDate <= earliestDate)
				{
					nextSubmissionDate = Date.newInstance(iTodayYear, iTodayMonth, iSemiMonthlyOption2);
				}
			} // end else if iTodayDay <= 10
			else if (15 <= iTodayDay)
			{ // Today is in the window of the Second semi-monthly submission window
				nextSubmissionDate = Date.newInstance(iTodayYear, iTodayMonth, iSemiMonthlyOption2);
				if (nextSubmissionDate <= earliestDate)
				{
					nextSubmissionDate = Date.newInstance(iTodayYear, iTodayMonth, iSemiMonthlyOption1).addMonths(1);
				}
			} // end else if 15 <= iTodayDay
		} // end else if semi-monthly
		else if (deliveryFrequency == 'Monthly') {
			Integer iMonthOption = integer.valueOf(subDetail.Calendar_Monthly_Option__c);
			nextSubmissionDate = Date.newInstance(iTodayYear, iTodayMonth, iMonthOption);
			nextSubmissionDate = (earliestDate < nextSubmissionDate) ? nextSubmissionDate : nextSubmissionDate.addMonths(1);
		}

		return nextSubmissionDate;
	} // end calculateCalendarNextSubmissionDate


	// =======================================================================================
	// the value is returned as side effect in subDetail.Calendar_*_Option
	// set default on null values only if needed
	// reset to null if that field is irrelevant
	private static void setDefaultCalendarOptionsAsRequired(GSS_Subscription_Detail__c subDetail, String deliveryFrequency)
	{
		if (deliveryFrequency == 'Weekly')
		{
			subDetail.Calendar_Weekly_Option__c = (subDetail.Calendar_Weekly_Option__c != null) ? subDetail.Calendar_Weekly_Option__c : CALENDAR_OPTION_DEFAULT_WEEKLY;
		} else {
			subDetail.Calendar_Weekly_Option__c = null;
		}
		if (deliveryFrequency == 'Monthly')
		{
			subDetail.Calendar_Monthly_Option__c = (subDetail.Calendar_Monthly_Option__c != null) ? subDetail.Calendar_Monthly_Option__c : CALENDAR_OPTION_DEFAULT_MONTHLY;
		} else {
			subDetail.Calendar_Monthly_Option__c = null;
		}
		if (deliveryFrequency == 'Semi-Monthly')
		{
			subDetail.Calendar_Semi_Monthly_First_Option__c = (subDetail.Calendar_Semi_Monthly_First_Option__c != null) ? subDetail.Calendar_Semi_Monthly_First_Option__c : CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_1;
			subDetail.Calendar_Semi_Monthly_Second_Option__c = (subDetail.Calendar_Semi_Monthly_Second_Option__c != null) ? subDetail.Calendar_Semi_Monthly_Second_Option__c : CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_2;
		} else {
			subDetail.Calendar_Semi_Monthly_First_Option__c = null;
			subDetail.Calendar_Semi_Monthly_Second_Option__c = null;
		}
	} // end of setDefaultCalendarOptionsAsRequired

	// ========================================================================
	private static Integer getDayNumberFromWeekDay(String sDayOfWeek) {
		if (sDayOfWeek == 'Monday') return 1;
		else if (sDayOfWeek == 'Tuesday') return 2;
		else if (sDayOfWeek == 'Wednesday') return 3;
		else if (sDayOfWeek == 'Thursday') return 4;
		else if (sDayOfWeek == 'Friday') return 5;
		else if (sDayOfWeek == 'Saturday') return 6;
		else if (sDayOfWeek == 'Sunday') return 7;
		else return -1;
	} // end of getDayNumberFromWeekDay

}
