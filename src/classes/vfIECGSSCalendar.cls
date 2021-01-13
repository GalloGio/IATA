/**
	* Description: This class contains the controller for the Visualforce page (File Delivery - File Submission Calendar)
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*  - 20160125-sl: fix onClickSave related to the use of Calendar_Next_Submission_Date__c
	*  - 20160217-sl: add getZuoraSubscription (cancelled), ensure Calendar_Next_Submission_Date is in a future date
	*/

public without sharing class vfIECGSSCalendar extends IECPageController {
	//Controller to handle the subscription information
	public vfIECSubscriptionInfo ctrSubsInfo {get; set;}
	public list<String> lstErrorMessage   {get; set;}
	public Boolean bViewMode {get; set;}

	public GSS_Subscription_Detail__c oGSSDetail {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail;
		}
	}

	public String sWeeklyOption {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.Calendar_Weekly_Option__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.Calendar_Weekly_Option__c = value;
		}
	}

	public String sBiMonthlyOption1 {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.Calendar_Semi_Monthly_First_Option__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.Calendar_Semi_Monthly_First_Option__c = value;
		}
	}

	public String sBiMonthlyOption2 {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.Calendar_Semi_Monthly_Second_Option__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.Calendar_Semi_Monthly_Second_Option__c = value;
		}
	}

	public String sMonthlyOption {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.Calendar_Monthly_Option__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.Calendar_Monthly_Option__c = value;
		}
	}

	public String sProductCode {get; set;}
	public String sApplicationTitle {
		get {
			if (sProductCode == IECConstants.ProductCategory_SF_GSS)
				return IECConstants.ProductCategory_Zuora_GSS;
			else if (sProductCode == IECConstants.ProductCategory_SF_MDP)
				return IECConstants.ProductCategory_Zuora_MDP;
			else
				return '';
		}
	} // end of sApplicationTitle

	public String sApplicationTitleUpperCase {
		get {
			return sApplicationTitle.toUpperCase();
		}
	} // end of sApplicationTitleUpperCase

	/**
	 * Constructor Method
	 **/
	public vfIECGSSCalendar() {
		try {
			lstErrorMessage = new list<string>();
			bViewMode = true;

			// Retrieve page parameters
			String sParamProductCode = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE);
			sProductCode = IECUtil.DecodeDecryptParameter(sParamProductCode);

			//Initilize subscription component
			ctrSubsInfo = new vfIECSubscriptionInfo();
			ctrSubsInfo.loggedCustomer = loggedCustomer;
			ctrSubsInfo.sSelectedSubscriptionName = null;
			ctrSubsInfo.sApplicationName = sProductCode;

			// check if Subscription Name was passed as a parameter
			String sParamSubscriptionName = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_NAME);
			if (sParamSubscriptionName!=null && !String.isEmpty(sParamSubscriptionName))
				ctrSubsInfo.sSelectedSubscriptionName = IECUtil.DecodeDecryptParameter(sParamSubscriptionName);
			else
				ctrSubsInfo.sSelectedSubscriptionName = null;

			// ensure that the Calendar_Next_Submission_Date__c displayed is a future date
			if ( (oGSSDetail.Calendar_Next_Submission_Date__c == null)
				|| (oGSSDetail.Calendar_Next_Submission_Date__c < Date.today()))
			{
				//Zuora__Subscription__c zuoraSubscription = getZuoraSubscription(oGSSDetail.Zuora_Subscription__c);
				oGSSDetail.Calendar_Next_Submission_Date__c = trgHndlrIECgssSubscriptionDetail.calculateCalendarNextSubmissionDate(oGSSDetail
					, oGSSDetail.GDP_File_Description__r.Frequency__c
					, oGSSDetail.Zuora_Subscription__r.Zuora__SubscriptionStartDate__c);
			}
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	} // end of vfIECGSSCalendar

	public Pagereference pageLoad() {
		// first check if the user is logged in
		try {
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IECLogin;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateSubscriptionAccess();

				// if no access, redirect to the unauthorized page
				if (!ctrSubsInfo.hasPageAccess)
					return Page.IECUnauthorized;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	} // end of pageLoad

	public void onClickEdit() {
		bViewMode = false;
	}

	public PageReference onClickCancel() {
		Pagereference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(ctrSubsInfo.oSubscription.Name));
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(sProductCode));
		pgRef.setRedirect(true);
		return pgRef;
	} // end of onClickCancel

	// ========================================================================
	// onClickSave :
	//  - save oGSSDetail by calling trSubsInfo.saveFileSubscriptionDetails()
	// in addition, based on the updated fields from visual force page, the following are done
	//  - calendar option validation
	//  - clearing up the irrelevant calendar option (should be in trigger)
	//  - update Calendar_Next_Submission_Date and Calendar_New_Submission_Effective_Date
	// Current interpretation:
	//  - Calendar_New_Submission_Effective_Date: only populated/used if the value of Calendar_Next_Submission_Date is not align with Calendar Option
	public void onClickSave() {
		 try {
			// Reset showing the result sections
			lstErrorMessage.clear();

			// Validate and clear unused options
			validateAndCleanCalendarOptions(); // this might updates lstErrorMessage, *Option

			// set Calendar_Next_Submission_Date and Calendar_New_Submission_Effective_Date
			// Calendar_New_Submission_Effective_Date will be set to null if Calendar_Next_Submission_Date is updated with new calendar option
			if (lstErrorMessage.isEmpty()) {
				// Initializing some variables to help with submission date calculations
				Date dToday = (Test.isRunningTest()) ? vfIECGSSCalendar_tst.dToday : Date.today(); // Used to simulate specific dates during test methods
				Integer iTodayDay = dToday.day();
				Integer iTodayMonth = dToday.month();
				Integer iTodayYear = dToday.year();
				Integer iTodayYearMonth = (iTodayYear * 10) + iTodayMonth;

				// normally, this Calendar_Next_Submission_Date__c should not be null, but, just in case , initialize it.
				// in addition if it is a past date, update it to the future
				if ( (oGSSDetail.Calendar_Next_Submission_Date__c == null)
					|| (oGSSDetail.Calendar_Next_Submission_Date__c < dToday))
				{
					//Zuora__Subscription__c zuoraSubscription = getZuoraSubscription(oGSSDetail.Zuora_Subscription__c);
					oGSSDetail.Calendar_Next_Submission_Date__c = trgHndlrIECgssSubscriptionDetail.calculateCalendarNextSubmissionDate(oGSSDetail
						, oGSSDetail.GDP_File_Description__r.Frequency__c
						, oGSSDetail.Zuora_Subscription__r.Zuora__SubscriptionStartDate__c);
				}

				// Calculate the next submission based on the selection and existing submission dates
				if (oGSSDetail.GDP_File_Description__r.Frequency__c == 'Weekly') {
					String sTodayDayOfWeek = DateTime.newInstance(dToday, Time.newInstance(0, 0, 0, 0)).format('EEEE');
					Integer iTodayDayOfWeek = getDayNumberFromWeekDay(sTodayDayOfWeek);
					Integer iWeekOption = getDayNumberFromWeekDay(sWeeklyOption);

					String sSubmissionDayOfWeek = DateTime.newInstance(oGSSDetail.Calendar_Next_Submission_Date__c, Time.newInstance(0, 0, 0, 0)).format('EEEE');
					Integer iSubmissionDayOfWeek = getDayNumberFromWeekDay(sSubmissionDayOfWeek);

					if (iTodayDayOfWeek > iSubmissionDayOfWeek)
					{ // current day has passed submission for this week, then next submission should be next week
						oGSSDetail.Calendar_Next_Submission_Date__c = dToday.addDays(7 - iTodayDayOfWeek + iWeekOption);
						oGSSDetail.Calendar_New_Submission_Effective_Date__c = null;
					} else {
						// else then the submission date remains this week, but the effective date is next week
						oGSSDetail.Calendar_New_Submission_Effective_Date__c = dToday.addDays(7 - iTodayDayOfWeek + iWeekOption);
					}
				} // end if weekly
				else if (oGSSDetail.GDP_File_Description__r.Frequency__c == 'Semi-Monthly') {
					Integer iBiMonthOption1 = integer.valueOf(sBiMonthlyOption1);
					Integer iBiMonthOption2 = integer.valueOf(sBiMonthlyOption2);
					Integer iSubmissionDay = oGSSDetail.Calendar_Next_Submission_Date__c.day();
					System.debug( 'iTodayDay:' + iTodayDay+ ' ; iSubmissionDay:' + iSubmissionDay + ' ; iBiMonthOption1:'+ iBiMonthOption1 + ' ; iBiMonthOption2:'+ iBiMonthOption2);

					// Today is in a free window where no submission is possible
					if (10 < iTodayDay && iTodayDay < 15) {
						// Set the submission date to the second bi-month option day in the same month
						oGSSDetail.Calendar_Next_Submission_Date__c = Date.newInstance(iTodayYear, iTodayMonth, iBiMonthOption2);
						oGSSDetail.Calendar_New_Submission_Effective_Date__c = null;
					}
					// Today is in the window of the first semi-monthly submission window
					else if (iTodayDay <= 10) {
						// If submission is scheduled for the first half of the month
						if (iTodayDay <= iSubmissionDay && iSubmissionDay <= 10) {
							// Leave current submission date, and set effective date to the second bi-month option day
				 			oGSSDetail.Calendar_New_Submission_Effective_Date__c = Date.newInstance(iTodayYear, iTodayMonth, iBiMonthOption2);
						}
						// File delivery has already been processed for this period
						else {
							// Set the submission date to the option day in the same month
							oGSSDetail.Calendar_Next_Submission_Date__c = Date.newInstance(iTodayYear, iTodayMonth, iBiMonthOption2);
							oGSSDetail.Calendar_New_Submission_Effective_Date__c = null;
						}
					} // end else if iTodayDay <= 10
					// Today is in the window of the Second semi-monthly submission window
					else if (15 <= iTodayDay) {
						// If submission is scheduled for the second half of the month
						if (iTodayDay <= iSubmissionDay && 15 <= iSubmissionDay) {
							// Leave current submission date, and set effective date to the first bi-month option day plus one month
							oGSSDetail.Calendar_New_Submission_Effective_Date__c = Date.newInstance(iTodayYear, iTodayMonth, iBiMonthOption1).addMonths(1);
						}
						// File delivery has already been processed for this period
						else {
							// Set the submission date to the option day in the next semi-monthly period
							oGSSDetail.Calendar_Next_Submission_Date__c = Date.newInstance(iTodayYear, iTodayMonth, iBiMonthOption1).addMonths(1);
							oGSSDetail.Calendar_New_Submission_Effective_Date__c = null;
						}
					} // end else if 15 <= iTodayDay
				} // end else if semi-monthly
				else if (oGSSDetail.GDP_File_Description__r.Frequency__c == 'Monthly') {
					Integer iMonthOption = integer.valueOf(sMonthlyOption);

					// iSubmissionDay = oGSSDetail.Calendar_Next_Submission_Date__c.day();

					Integer iSubmissionMonth = oGSSDetail.Calendar_Next_Submission_Date__c.month();
					Integer iSubmissionYear = oGSSDetail.Calendar_Next_Submission_Date__c.year();
					Integer iSubmissionYearMonth = (iSubmissionYear * 10) + iSubmissionMonth;

					// If current month is smaller submission month, that means submission has already been done
					if (iTodayYearMonth < iSubmissionYearMonth) {
						// Set the submission date to the option day plus one month
						oGSSDetail.Calendar_Next_Submission_Date__c = Date.newInstance(iTodayYear, iTodayMonth, iMonthOption).addMonths(1);
						oGSSDetail.Calendar_New_Submission_Effective_Date__c = null;
					}
					// else current month and submission month are the same, that means submission is not yet done
					else {
						// Set the new submission effective date to the option day plus one month
						oGSSDetail.Calendar_New_Submission_Effective_Date__c = Date.newInstance(iTodayYear, iTodayMonth, iMonthOption).addMonths(1);
					}
				} // end else if monthly

				ctrSubsInfo.saveFileSubscriptionDetails();

				addConfirmMessage(Label.IEC_Confirm_SaveSuccessful);
				bViewMode = true;
			}
			else {
				addErrorMessages(lstErrorMessage);
			}
		} // if (lstErrorMessage.isEmpty())
		catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
} // end of onClickSave


	// ========================================================================
	// check relevant calendar options, clear irrelevant options (GSS_Subscription_Detail__c.Calendar_*_Option__c)
	// input: oGSSDetail.GDP_File_Description__r.Frequency__c
	// intent in/out, intended side effects: lstErrorMessage, sMonthlyOption, sWeeklyOption, sBimonthlyOption1, sBimonthlyOption2.
	//
	private void validateAndCleanCalendarOptions()
	{
		// Validate and clear unused options
		if (oGSSDetail.GDP_File_Description__r.Frequency__c == 'Weekly') {
			if (String.isBlank(sWeeklyOption))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Day of Week');

			sBiMonthlyOption1 = null;
			sBiMonthlyOption2 = null;
			sMonthlyOption = null;
		}
		else if (oGSSDetail.GDP_File_Description__r.Frequency__c == 'Semi-Monthly') {
			if (String.isBlank(sBiMonthlyOption1))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' First submission of the month');

			if (String.isBlank(sBiMonthlyOption2))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Second submission of the month');

			sWeeklyOption = null;
			sMonthlyOption = null;
		}
		else if (oGSSDetail.GDP_File_Description__r.Frequency__c == 'Monthly') {
			if (String.isBlank(sMonthlyOption))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Day of Month');

			sWeeklyOption = null;
			sBiMonthlyOption1 = null;
			sBiMonthlyOption2 = null;
		}
	} // end of validateAndCleanCalendarOptions

	// ========================================================================
	// convert day of the week name to number
	public Integer getDayNumberFromWeekDay(String sDayOfWeek) {
		if (sDayOfWeek == 'Monday') return 1;
		else if (sDayOfWeek == 'Tuesday') return 2;
		else if (sDayOfWeek == 'Wednesday') return 3;
		else if (sDayOfWeek == 'Thursday') return 4;
		else if (sDayOfWeek == 'Friday') return 5;
		else if (sDayOfWeek == 'Saturday') return 6;
		else if (sDayOfWeek == 'Sunday') return 7;
		else return -1;
	} // end of getDayNumberFromWeekDay

	/*
	// this was an alternative way, if the fields required is not available through oGSS_Detail
	// getZuoraSubscription is used to get some necessary field from Zuora__Subscription object
	// in calendar, we need to know Zuora__SubscriptionStartDate__c
	private Zuora__Subscription__c getZuoraSubscription(Id zuoraSubId)
	{
		Zuora__Subscription__c zuoraSubscription = null;
		if (zuoraSubId != null){
			zuoraSubscription = [select Id, Zuora__SubscriptionStartDate__c
									from Zuora__Subscription__c
									where id = :zuoraSubId limit 1];
		}
		return zuoraSubscription;
	} // end of getZuoraSubscription
	*/

}
