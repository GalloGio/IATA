public with sharing class ISSP_NonTD_Report {

	public String reportId {get; set;}
	public List<reportWrapper> fullList {get; set;}
	public String currentMonthString {get; set;}
	public Boolean emptyList {get; set;}

	public ISSP_NonTD_Report(){

	}

	public PageReference pageLoad(){
		emptyList = true;
		//check if user has access to MIR service
		PageReference pr = new PageReference('/ISSP_Homepage');
		//PageReference pr = null;
		String userId = UserInfo.getUserId();
		if (userId != null && userId != ''){
			List <User> userList = [SELECT Id, ContactId FROM User WHERE Id = :userId];
			if(!userList.isEmpty()){
				String contactId = userList[0].ContactId;
				if (contactId != null && contactId != ''){
					List <Portal_Application_Right__c> appList =
											[SELECT Id FROM Portal_Application_Right__c
											WHERE Portal_Application__r.Name LIKE 'Treasury Dashboard%'
											AND Right__c = 'Access Granted'
											AND Contact__c = :contactId];
					if (appList.isEmpty()){
						return pr;
					}
				}
				else{
					return pr;
				}
			}
			else{
				return pr;
			}
		}
		else{
			return pr;
		}

		Map <Integer, String> monthMap = new Map <Integer, String>();
		monthMap.put(1, 'January, ');
		monthMap.put(2, 'February, ');
		monthMap.put(3, 'March, ');
		monthMap.put(4, 'April, ');
		monthMap.put(5, 'May, ');
		monthMap.put(6, 'June, ');
		monthMap.put(7, 'July, ');
		monthMap.put(8, 'August, ');
		monthMap.put(9, 'September, ');
		monthMap.put(10, 'October, ');
		monthMap.put(11, 'November, ');
		monthMap.put(12, 'December, ');
		Integer currentMonth = system.today().month();
		Integer currentYear = system.today().year();
		currentMonthString = monthMap.get(currentMonth) + currentYear;
		List <ISSP_NonTD_Report__c> fullReportList = [SELECT Id, Posted_Date__c,
										(SELECT Id, Name FROM Attachments)
										FROM ISSP_NonTD_Report__c
										ORDER BY Posted_Date__c DESC];
		system.debug('fullReportList: ' + fullReportList);
		List <ISSP_NonTD_Report__c> newlist = new List <ISSP_NonTD_Report__c>();
		for (ISSP_NonTD_Report__c thisReport : fullReportList){
			if (!thisReport.Attachments.isEmpty()){
				emptyList = false;
				newlist.add(thisReport);
			}
		}
		Integer month = 0;
		Integer year = 0;
		Integer myIndex = 1;
		fullList = new List<reportWrapper>();
		reportWrapper thisWrapperRecord;
		if (!newlist.isEmpty()){
			for (ISSP_NonTD_Report__c thisReport : newlist){
				if (month == 0){
					month = thisReport.Posted_Date__c.month();
					year = thisReport.Posted_Date__c.year();
					thisWrapperRecord = new reportWrapper();
					thisWrapperRecord.recordId = myIndex;
					thisWrapperRecord.month = monthMap.get(month) + year;
					thisWrapperRecord.reportList = new List <ISSP_NonTD_Report__c>();
					thisWrapperRecord.reportList.add(thisReport);
				}
				else if (month != thisReport.Posted_Date__c.month() || year != thisReport.Posted_Date__c.year())
				{
					fullList.add(thisWrapperRecord);
					month = thisReport.Posted_Date__c.month();
					year = thisReport.Posted_Date__c.year();
					thisWrapperRecord = new reportWrapper();
					myIndex++;
					thisWrapperRecord.recordId = myIndex;
					thisWrapperRecord.month = monthMap.get(month) + year;
					thisWrapperRecord.reportList = new List <ISSP_NonTD_Report__c>();
					thisWrapperRecord.reportList.add(thisReport);
				}
				else{
					thisWrapperRecord.reportList.add(thisReport);
				}
			}
			fullList.add(thisWrapperRecord);
		}

		return null;
	}

	public Pagereference refresh(){
		setCon = null;
		return null;
	}

	private String sortDirection = 'DESC';
	private String sortExp  = 'Posted_Date__c';

	public String sortExpression {
	 get { return sortExp; }
	 set {
		//if the column is clicked on then switch between Ascending and Descending modes
		if (value == sortExp)
			sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
		else
			sortDirection = 'ASC';
		sortExp = value;
		}
	}

	public String getSortDirection() {
		//if not column is selected
		if (sortExpression == null || sortExpression == '')
			return 'ASC';
		else
			return sortDirection;
	}

	public void setSortDirection(String value) {
		sortDirection = value;
	}

	Public List<ISSP_NonTD_Report__c> getReports(){
		return (List<ISSP_NonTD_Report__c>)setCon.getRecords();
	}

	public Integer noOfRecords{get; set;}
	public Integer size{get;set;}
	public ApexPages.StandardSetController setCon {
		get{
			if(setCon == null){
				string sortFullExp = sortExpression  + ' ' + sortDirection;
				size = 10;
				string queryString = 'select id, Posted_Date__c, (Select id, name from Attachments) from ISSP_NonTD_Report__c ';
				queryString = queryString + ' order by '+ sortFullExp;
				ISSP_Utilities.log('SQL String: ' + queryString);
				setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
				setCon.setPageSize(size);
				noOfRecords = setCon.getResultSize();
			}
			return setCon;
		}set;
	}

	public class reportWrapper {
		public Integer recordId {get; set;}
		public String month {get; set;}
		public List<ISSP_NonTD_Report__c> reportList {get; set;}
	}

	public PageReference viewReport(){
		system.debug('reportId: ' + reportId);
		if (reportId != null && reportId != ''){
			List <ISSP_NonTD_Report__c> boReports = [SELECT id, Posted_Date__c,
											(SELECT id, name from Attachments)
											FROM ISSP_NonTD_Report__c
											WHERE Id = :reportId];
			if (!boReports.isEmpty()){
				if (!boReports[0].Attachments.isEmpty()){
					ISSP_Document_Tracker__c tracker = new ISSP_Document_Tracker__c(
															NonTD_Report__c = reportId,
															User__c = UserInfo.getUserId(),
															Type__c = 'NonTD Report');
					insert tracker;
					PageReference pr = new PageReference('/servlet/servlet.FileDownload?file=' + boReports[0].Attachments[0].Id);
					pr.setRedirect(true);
					return pr;
				}
			}
		}
		return null;
	}

}
