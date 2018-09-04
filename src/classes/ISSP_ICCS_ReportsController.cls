public class ISSP_ICCS_ReportsController extends ISSP_ICCS_ComponentController{

	// Number of reports per page displayed in the reports table
	public static final Integer REPORTS_PER_PAGE;
	static{
		if(!Test.isRunningTest()){
			REPORTS_PER_PAGE = 20;
		}
		else{
			REPORTS_PER_PAGE = 1;
		}
	}
	

	/* Report Types */

	// List of report types
	public List<ReportTypeWrapper> reportTypesList {
		get{
			if(reportTypesList == null){
				pageController.resetMessage();

				reportTypesList = new List<ReportTypeWrapper>();
				
				try{
					// Retrieve the list of available report types from the core
					List<Portal_Service_Account_Preference__c> accountReportPreferences = [select Id, Name, Subscribed__c from Portal_Service_Account_Preference__c where Account__c =: pageController.topAccount.Id and Portal_Service__c =: ISSP_ICCS_Utils.getIccsPortalApplication().Id and Category__c = 'Report'];
					
					// Retrieve the set of report types the Top Account subscribed to
					Map<String, Portal_Service_Account_Preference__c> accountReportPreferencesMap = new Map<String, Portal_Service_Account_Preference__c>();
					for(Portal_Service_Account_Preference__c accountReportPreference : accountReportPreferences){
						accountReportPreferencesMap.put(accountReportPreference.Name, accountReportPreference);
					}
					
					// Map the core report types with the account's preferences
					for(ISSP_ICCS_CoreRest.ReportType reportType : pageController.coreRest.getReportTypes()){
						reportTypesList.add(new ReportTypeWrapper(this, reportType, accountReportPreferencesMap.get(reportType.code)));
					}
				}
				catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
					pageController.setMessage(e.getMessage(), false);
				}
			}
			return reportTypesList;
		}
		set;
	}
	
	public List<ReportTypeWrapper> types {
		get{
			if(isReportTypeListExpanded){
				return reportTypesList;
			}
			else{
				List<ReportTypeWrapper> typesList = new List<ReportTypeWrapper>();

				Integer i = 0;
				
				for(ReportTypeWrapper reportType : reportTypesList){
					typesList.add(reportType);
					i++;
					
					if(i == ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS){
						break;
					}
				}
				
				return typesList;
			}
		}
	}
	
	public Boolean isReportTypeListExpanded {get;set;}

	public Boolean isReportTypeListExpandable {
		get{
			return reportTypesList.size() > ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS;
		}
	}

	/* Reports */

	// Cycle selected by the user
	public String selectedCycleId {get;set;}

	// SelectOption list of cycles
	public List<SelectOption> cycles {
		get{
			System.debug('***** get Cycles SelectOptions - selected cycle : ' + selectedCycleId);
			List<SelectOption> cycles = new List<SelectOption>{new SelectOption('', 'All Cycles')};
			
			try{
				for(ISSP_ICCS_CoreRest.Cycle cycle : pageController.coreRest.getCycles(null)){
					cycles.add(new SelectOption(cycle.cycleId, cycle.cycleId));
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				pageController.setMessage(e.getMessage(), false);
			}
			
			return cycles;
		}
	}

	// Report type selected by the user
	public String selectedReportType {get;set;}

	// SelectOption list of report types
	public List<SelectOption> reportTypes {
		get{
			List<SelectOption> reportTypes = new List<SelectOption>{new SelectOption('', 'All Report Types')};
				
			try{
				for(ReportTypeWrapper wrappedReportType : reportTypesList){
					if(wrappedReportType.isSelected){
						reportTypes.add(new SelectOption(wrappedReportType.reportType.code, wrappedReportType.reportType.code));
					}
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				pageController.setMessage(e.getMessage(), false);
			}
			return reportTypes;
		}
	}

	// Date filters
	public String selectedFromDate {get;set;}
	public String selectedToDate {get;set;}

	// List of reports displayed to the user
	public List<ReportWrapper> reportsList {
		get{
			if(reportsList == null){
				pageController.resetMessage();
				
				reportsList = new List<ReportWrapper>();

				try{
					// Prepare the reportType parameter
					String reportTypeFilter = '';
					
					// Reset pageNumbers list
					pageNumbers = new List<Integer>();
					
					// If no report type is selected, retrieve all the report types the account subscribed to
					if(selectedReportType == '' || selectedReportType == null){
						List<String> subscribedReportTypes = new List<String>();
						for(ReportTypeWrapper wrappedReportType : reportTypesList){
							if(wrappedReportType.preference.Subscribed__c){
								subscribedReportTypes.add(wrappedReportType.reportType.code);
							}
						}
						reportTypeFilter = String.join(subscribedReportTypes, ',');
					}
					// Otherwise use the selected report type
					else{
						reportTypeFilter = selectedReportType;
					}
					
					// Retrieve the list of reports from the Core
					if(reportTypeFilter != ''){
						ISSP_ICCS_CoreRest.Reports reports = pageController.coreRest.getReports(selectedPage, REPORTS_PER_PAGE, selectedCycleId, selectedFromDate, selectedToDate, reportTypeFilter);
			
						for(ISSP_ICCS_CoreRest.Report report : reports.reports){
							reportsList.add(new ReportWrapper(this, report));
						}
							
						// Pagination setup
						Integer pages = 0;
						
						if(Math.mod(reports.pagingInfo.records, REPORTS_PER_PAGE) > 0){
							pages = reports.pagingInfo.records / REPORTS_PER_PAGE + 1;
						}
						else{
							pages = reports.pagingInfo.records / REPORTS_PER_PAGE;
						}
						
						if(pages < 9){
							for(Integer i = 1; i <= pages; i++){
								pageNumbers.add(i);
							}
						}
						else{
							pageNumbers.add(1);
			
							Boolean lastItemIsZero = false;
							for(Integer i = 2; i < pages; i++){
								if(i == selectedPage - 1 || i == selectedPage || i == selectedPage + 1){
									pageNumbers.add(i);
									lastItemIsZero = false;
								}
								else if(!lastItemIsZero){
									pageNumbers.add(0);
									lastItemIsZero = true;
								}
							}
							pageNumbers.add(pages);
						}
					}
				}
				catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
					pageController.setMessage(e.getMessage(), false);
				}
			}
			return reportsList;			
		}
		set;
	}
	
	public Boolean isReportListEmpty { get{ return reportsList == null || reportsList.size() == 0; }}

	// Number of reports pages
	public Integer numberOfPages { get{ return pageNumbers != null ? pageNumbers.size() : 0; }}

	// List of page numbers
	public List<Integer> pageNumbers {get;set;}
	
	// Number of the page currently displayed
	public Integer selectedPage {get;set;}


	/* Rerender */

	// When a report type selection is modified, the reports table has to be updated
	// As this table requires a callout to retrieve the data, this update can't happen in the same transaction than the DB update
	// This variable is used in a rendered parameter to call a javascript method which will trigger a second transaction to refresh the reports list
	public Boolean secondRefreshRequired {
		get{
			for(ReportTypeWrapper wrappedReportType : reportTypesList){
				if(wrappedReportType.subscriptionModified){
					return true;
				}
			}
			return false;
		}
	}


	/* CONSTRUCTOR */

	public ISSP_ICCS_ReportsController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.REPORTS;
	}

	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		selectedCycleId = selectedCycleId == null ? '' : selectedCycleId;
		selectedReportType = selectedReportType == null ? '' : selectedReportType;
		selectedPage = 1;
		
		isReportTypeListExpanded = isReportTypeListExpanded == null ? false : isReportTypeListExpanded;
		
		return true;
	}

	public override void cleanController(){
		reportTypesList = null;
		reportsList = null;

		pageNumbers = null;
		selectedPage = null;
	}

	public void expandCollapseReportTypesList(){
		isReportTypeListExpanded = !isReportTypeListExpanded;
	}

	// Called when the reportsList must be updated with data from the core, typically when changing a filter or updating the report types selection
	public void deleteReportsList(){
		reportsList = null;
	}
	
	// Called in a second transaction when an additional refresh is necessary because of the "Callout with uncommited work" problem
	public void completeRefresh(){
		for(ReportTypeWrapper wrappedReportType : reportTypesList){
			wrappedReportType.subscriptionModified = false;
		}
		deleteReportsList();
	}



	/* TO BE DELETED */
/*	public void testNotification(){
			ISSP_WS_CreateNotification.languageMessage inputMessage = new ISSP_WS_CreateNotification.LanguageMessage();
			inputMessage.languageCode = 'en_US';
			
			ISSP_WS_CreateNotification.inputData inputData = new ISSP_WS_CreateNotification.inputData();
	
	    	inputData.requestingSystem = 'ICCS Core';
	    	inputData.serviceName = ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME;
	    	inputData.templateName = 'R1ParticipantReportA'; 
	    	inputData.replaceStr = '%PARTICIPANT_CODE%!LX724';
	    	inputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>{inputMessage};
	    	
	    	ISSP_WS_CreateNotification.createNotification(inputData);
    }*/


	/* INNER CLASSES */
	

	public class ReportTypeWrapper{
		public ISSP_ICCS_ReportsController ctrl {get;set;}
		public ISSP_ICCS_CoreRest.ReportType reportType {get;set;}
		public Portal_Service_Account_Preference__c preference {get;set;}
		
		public Boolean subscriptionModified {get;set;}

		public Boolean isSelected { get{return preference != null && preference.Subscribed__c;} set;}
		
		public ReportTypeWrapper(ISSP_ICCS_ReportsController ctrl, ISSP_ICCS_CoreRest.ReportType reportType, Portal_Service_Account_Preference__c preference){
			this.ctrl = ctrl;
			this.reportType = reportType;
			this.preference = preference;
			subscriptionModified = false;
		}
		
		public void updateReportsSelection(){
			if(preference == null){
				preference = new Portal_Service_Account_Preference__c(
					Account__c = ctrl.pageController.topAccount.Id,
					Portal_Service__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id,
					Name = reportType.code,
					Category__c = 'Report',
					Subscribed__c = true
				);
			}
			else{
				preference.Subscribed__c = ! preference.Subscribed__c;
			}			
			subscriptionModified = true;

			// If report type has been unselected and is equal to the controller's selected report type, selection has to be reset
			if(!preference.Subscribed__c && reportType.code == ctrl.selectedReportType){
				ctrl.selectedReportType = '';
			}

			upsert preference;
		}
	}

	public class ReportWrapper{
		public ISSP_ICCS_ReportsController ctrl {get;set;}
		public ISSP_ICCS_CoreRest.Report report {get;set;}
		
		public String selectedMimetype {get;set;}
		
		public ReportWrapper(ISSP_ICCS_ReportsController ctrl, ISSP_ICCS_CoreRest.Report report){
			this.ctrl = ctrl;
			this.report = report;
			this.report.uploadDate = this.report.uploadDate == null ? null : this.report.uploadDate.substring(0,10);
		}

		public PageReference getReport(){
			ctrl.pageController.resetMessage();

			PageReference pageRef = null;
	
			try{
				pageRef = new PageReference(ctrl.pageController.coreRest.getReport(report.id, selectedMimetype));
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				ctrl.pageController.setMessage(e.getMessage(), false);
			}
			return pageRef;
		}
	}
}