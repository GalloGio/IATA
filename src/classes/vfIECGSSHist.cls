/**
 * Description: This class contains the controller for the Visualforce page (File Delivery - Delivery History)
 * Author: Samy Saied
 * Version: 1.0
 * History:
 *  - 20160104-sl: change the GDP_File_Description__c.Frequency option from Bi-Monthly to Semi-Monthly
 */

public without sharing class vfIECGSSHist extends IECPageController {
	public vfIECSubscriptionInfo ctrSubsInfo { get; set; }
	public List<SubmissionRecord> lstSubmissionRecords {get; private set;}
	public Integer iSelectedSubmissionID {get; set;}
	public SubmissionRecord submissionObj {get; private set;}
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
	}

	public String sApplicationTitleUpperCase {
		get {
			return sApplicationTitle.toUpperCase();
		}
	}

	/**
	 * Constructor Method
	 **/
	public vfIECGSSHist() {
		try {
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
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	public Pagereference pageLoad() {
		// first check if the user is logged in
		try {
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IECLogin;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			} else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateSubscriptionAccess();

				// if no access, redirect to the unauthorized page
				if (!ctrSubsInfo.hasPageAccess)
					return Page.IECUnauthorized;
				}

				//Query for the submission history list related to the current logged user and subscription
				lstSubmissionRecords = getSubmissionHistory();
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Returns the submission records for the current subscription
	private List<SubmissionRecord> getSubmissionHistory() {
		List<GDP_File_Delivery__c> lstDelivery =
			[SELECT Delivery_Date__c, File_Specification__r.Class__c, File_Specification__r.Frequency__c
				, File_Specification__r.Description__c, File_Size_KB__c, Status__c
			FROM GDP_File_Delivery__c
			WHERE GSS_Subscription_Detail__r.Name = :ctrSubsInfo.sSubscriptionName
			ORDER BY Delivery_Date__c DESC, File_Specification__r.Class__c];

		List<SubmissionRecord> lstSubHist = new List<SubmissionRecord>();
		// Use two dates to determine if the submission record has changed or not
		Date dPrev, dCurr;
		// Use a counter to allow retrieval of the previously created submission
		integer i = -1;

		// Create SubmissionRecord list to be used for the UI display
		for (GDP_File_Delivery__c oDelivery : lstDelivery) {
			dCurr = oDelivery.Delivery_Date__c;

			if (dCurr != dPrev) {
				i++;
				lstSubHist.add(new SubmissionRecord(i, oDelivery.Delivery_Date__c));
			}

			lstSubHist.get(i).lstFiles.add(oDelivery);
			dPrev = dCurr;
		}

		// Build up the record label knowing the final size of the SubmissionRecord list
		for (i = 0; i < lstSubHist.size(); i++) {
			lstSubHist.get(i).RecordLabel = ctrSubsInfo.sSubscriptionName + '-' + String.valueOf(lstSubHist.size() - i).leftPad(3).replace(' ', '0');
		}

		return lstSubHist;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the selection of one submission record (by submissionID) and query for its details
	public void selectSubmission() {
		try {
			if (iSelectedSubmissionID != null) {
				submissionObj = lstSubmissionRecords.get(iSelectedSubmissionID);
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	public class SubmissionRecord {
		public Integer RecordID {get; set;}
		public String RecordLabel {get; set;}
		public Date DeliveryDate {get; set;}
		public List<GDP_File_Delivery__c> lstFiles {get; set;}

		public Integer FileCount {
			get {
				return lstFiles.size();
			}
		}

		public String Frequency {
			get {
				return (lstFiles.size() > 0) ? lstFiles.get(0).File_Specification__r.Frequency__c : null;
			}
		}

		public Date ReportingFrom {
			get {
				if (Frequency == 'Daily') {
					return DeliveryDate.addDays(-1);
				}
				else if (Frequency == 'Weekly') {
					String sDayOfWeek = DateTime.newInstance(DeliveryDate, Time.newInstance(0, 0, 0, 0)).format('EEEE');
					Integer iDayOfWeek = new vfIECGSSCalendar().getDayNumberFromWeekDay(sDayOfWeek) - 1; //-1 is to offset the calculation to zero if it is Monday
					return DeliveryDate.addDays(-7 - iDayOfWeek);
				}
				else if (Frequency == 'Semi-Monthly') {
					if (DeliveryDate.day() < 16)
						return Date.newInstance(DeliveryDate.year(), DeliveryDate.month(), 16).addMonths(-1);
					else
						return Date.newInstance(DeliveryDate.year(), DeliveryDate.month(), 1);
				}
				else if (Frequency == 'Monthly') {
					return Date.newInstance(DeliveryDate.year(), DeliveryDate.month(), 1).addMonths(-1);
				}

				return null;
			}
		}

		public Date ReportingTo {
			get {
				if (Frequency == 'Daily') {
					return null;
				}
				else if (Frequency == 'Weekly') {
					String sDayOfWeek = DateTime.newInstance(DeliveryDate, Time.newInstance(0, 0, 0, 0)).format('EEEE');
					Integer iDayOfWeek = new vfIECGSSCalendar().getDayNumberFromWeekDay(sDayOfWeek);
					return DeliveryDate.addDays(-iDayOfWeek);
				}
				else if (Frequency == 'Semi-Monthly') {
					if (DeliveryDate.day() < 16)
						return Date.newInstance(DeliveryDate.year(), DeliveryDate.month(), 1).addDays(-1);
					else
						return Date.newInstance(DeliveryDate.year(), DeliveryDate.month(), 15);
				}
				else if (Frequency == 'Monthly') {
					return Date.newInstance(DeliveryDate.year(), DeliveryDate.month(), 1).addDays(-1);
				}

				return null;
			}
		}

		public String Status {
			get {
				Boolean bInProgress = false;
				for (GDP_File_Delivery__c oDelivery : lstFiles) {
					if (oDelivery.Status__c == 'Failed')
						return oDelivery.Status__c;
					else if (oDelivery.Status__c == 'In Progress')
						bInProgress = true;
				}
				return bInProgress ? 'In Progress' : 'Completed';
			}

		}

		public SubmissionRecord (Integer iRecordID, Date dDeliveryDate) {
			RecordID = iRecordID;
			DeliveryDate = dDeliveryDate;
			lstFiles = new List<GDP_File_Delivery__c>();
		}
	}
}
