public with sharing class ISSP_MIR_Metrics {

	public Decimal totalContacts {get; set;} // total number of contacts
	public Decimal totalReports {get; set;} // total number of reports
	
	public Map <String, Map<Id, Id>> reportUserMap {get; set;} // for usage percentage for each report
	public Map <String, Integer> reportUserSizeMap {get; set;} // for usage percentage for each report
	public Map <String, Decimal> reportUserPercentMap {get; set;} // for usage percentage for each report
	public List <String> reportUserMapOrdered {get; set;} // for usage percentage for each report
	
	public Map <String, String> totalContactsUsedMap {get; set;} // for percentage of users that never used MIR
	public Decimal totalContactsUsed {get; set;} // for percentage of users that never used MIR
	public Decimal totalContactsUsedPercent {get; set;} // for percentage of users that never used MIR
	public List<User> userListNeverUsed {get; set;} // for percentage of users that never used MIR
	public Set<Id> allContactIds {get; set;} // for percentage of users that never used MIR
	public Set<Id> allUserIds {get; set;} // for percentage of users that never used MIR
	
	public Map <Id, Map<Id, Id>> userReportMap {get; set;} // for percentage of users using MIR every week
	public Decimal totalContactsSeenAll {get; set;} // for percentage of users using MIR every week
	public Decimal totalContactsSeenAllPercent {get; set;} // for percentage of users using MIR every week
	public List<User> userListAlwaysUsed {get; set;} // for percentage of users using MIR every week
	public Set<Id> userListAlwaysUsedIds {get; set;} // for percentage of users using MIR every week
	
	public Decimal totalMonths {get; set;} // for percentage of users using MIR every month
	public Map <String, Map<Id,Id>> monthlyUsers {get; set;} // for percentage of users using MIR every month
	public Map <String, Integer> monthlyUserSizeMap {get; set;} // for percentage of users using MIR every month
	public Map <String, Decimal> monthlyUserPercentMap {get; set;} // for percentage of users using MIR every month
	public List <String> monthlyUsersOrdered {get; set;} // for percentage of users using MIR every month
	
	public Map <String, Map<Id,Id>> quarterUsers {get; set;} // for percentage of users using MIR every quarter
	public Map <String, Integer> quarterUserSizeMap {get; set;} // for percentage of users using MIR every quarter
	public Map <String, Decimal> quarterUserPercentMap {get; set;} // for percentage of users using MIR every quarter
	public List <String> quarterUsersOrdered {get; set;} // for percentage of users using MIR every quarter
	
	public List<User> userListUsedOnce {get; set;} // for percentage of users that used MIR once
	public Set<Id> userListUsedOnceIds {get; set;} // for percentage of users that used MIR once
	public Decimal totalContactsSeenOnce {get; set;} // for percentage of users that used MIR once
	public Decimal totalContactsSeenOncePercent {get; set;} // for percentage of users that used MIR once

	public ISSP_MIR_Metrics(){
		
		Map <Integer, String> monthMap = new Map <Integer, String>();
    	monthMap.put(1, 'January');
    	monthMap.put(2, 'February');
    	monthMap.put(3, 'March');
    	monthMap.put(4, 'April');
    	monthMap.put(5, 'May');
    	monthMap.put(6, 'June');
    	monthMap.put(7, 'July');
    	monthMap.put(8, 'August');
    	monthMap.put(9, 'September');
    	monthMap.put(10, 'October');
    	monthMap.put(11, 'November');
    	monthMap.put(12, 'December');
    	
    	Map <Integer, String> quarterMap = new Map <Integer, String>();
    	quarterMap.put(1, 'Jan-Mar');
    	quarterMap.put(2, 'Jan-Mar');
    	quarterMap.put(3, 'Jan-Mar');
    	quarterMap.put(4, 'Apr-Jun');
    	quarterMap.put(5, 'Apr-Jun');
    	quarterMap.put(6, 'Apr-Jun');
    	quarterMap.put(7, 'Jul-Aug');
    	quarterMap.put(8, 'Jul-Aug');
    	quarterMap.put(9, 'Jul-Aug');
    	quarterMap.put(10, 'Oct-Dec');
    	quarterMap.put(11, 'Oct-Dec');
    	quarterMap.put(12, 'Oct-Dec');
	
		reportUserMap = new Map <String, Map<Id, Id>>();
		reportUserSizeMap = new Map <String, Integer>();
		reportUserPercentMap = new Map <String, Decimal>();
		userReportMap = new Map <Id, Map<Id, Id>>();
		totalContactsUsedMap = new Map <String, String>();
		monthlyUsers = new Map <String, Map<Id,Id>>();
		monthlyUserSizeMap = new Map <String, Integer>();
		monthlyUserPercentMap = new Map <String, Decimal>();
		quarterUsers = new Map <String, Map<Id,Id>>();
		quarterUserSizeMap = new Map <String, Integer>();
		quarterUserPercentMap = new Map <String, Decimal>();
		userListNeverUsed = new List<User>();
		allContactIds = new Set<Id>();
		allUserIds = new Set<Id>();
		userListAlwaysUsed = new List<User>();
		userListAlwaysUsedIds = new Set<Id>();
		userListUsedOnce = new List<User>();
		userListUsedOnceIds = new Set<Id>();
		
		reportUserMapOrdered = new List<String>();
		monthlyUsersOrdered = new List<String>();
		quarterUsersOrdered = new List<String>();
	
		// getting all contacts
		List <Portal_Application_Right__c> appRight = 
			[SELECT Id, Contact__c FROM Portal_Application_Right__c
				WHERE Application_Name__c = 'Management Information Report'
				AND Right__c = 'Access Granted'];
		//totalContacts = appRight.size();
		system.debug('totalContacts: ' + totalContacts);
		for (Portal_Application_Right__c thisAppRight : appRight){
			allContactIds.add(thisAppRight.Contact__c);
			system.debug('adding 1 contact Id: ' + thisAppRight.Contact__c);
		}
		List <User> allUsers = [SELECT Id FROM User WHERE ContactId IN :allContactIds];
		for (User thisUser : allUsers){
			allUserIds.add(thisUser.Id);
			system.debug('adding 1 User Id: ' + thisUser.Id);
		}
		totalContacts = allUsers.size();
				
		// getting total number of reports
		List <ISSP_BO_Report__c> boReports = 
			[SELECT Id, Report_Date__c FROM ISSP_BO_Report__c ORDER BY Report_Date__c];
		totalReports = boReports.size();
		
		// getting total number of months
		Integer month = 0;
		totalMonths = 0;
		for (ISSP_BO_Report__c thisReport : boReports){
			if (month == 0){
				totalMonths = 1;
				month = thisReport.Report_Date__c.month();
			}
			else if (month != thisReport.Report_Date__c.month()){
				totalMonths++;
				month = thisReport.Report_Date__c.month();
			}
		}
		
		// getting all reports
		List <ISSP_Document_Tracker__c> trackerList = 
			[SELECT Id, Createddate, User__c, Management_Information_Report__c,
				Management_Information_Report__r.Report_Date__c,
				Management_Information_Report__r.Report_Date_format__c
				FROM ISSP_Document_Tracker__c
				WHERE Management_Information_Report__c != null
				ORDER BY Management_Information_Report__r.Report_Date__c DESC limit 5000];
		
		for (ISSP_Document_Tracker__c thisRecord : trackerList){
			// getting usage percentage for each report
			String dateString = thisRecord.Management_Information_Report__r.Report_Date_format__c;
			system.debug('DATE: ' + dateString);
			if (reportUserMap.containsKey(dateString)){
				if (!reportUserMap.get(dateString).containsKey(thisRecord.User__c)){
					reportUserMap.get(dateString).put(thisRecord.User__c, thisRecord.User__c);
					userListUsedOnceIds.add(thisRecord.User__c);
					system.debug('adding to userListUsedOnceIds: ' + thisRecord.User__c);
				}
			}
			else{
				reportUserMapOrdered.add(dateString);
				reportUserMap.put(dateString, new Map<Id, Id>{thisRecord.User__c => thisRecord.User__c});
				userListUsedOnceIds.add(thisRecord.User__c);
				system.debug('adding to userListUsedOnceIds: ' + thisRecord.User__c);
			}
			
			// getting percentage of users that never used MIR
			if (!totalContactsUsedMap.containsKey(thisRecord.User__c)){
				totalContactsUsedMap.put(thisRecord.User__c, thisRecord.User__c);
				allUserIds.remove(thisRecord.User__c);
				system.debug('Removing 1 user id because he saw a report: ' + thisRecord.User__c);
			}
            
            // getting percentage of users using MIR every week
            if (userReportMap.containsKey(thisRecord.User__c)){
				if (!userReportMap.get(thisRecord.User__c).containsKey(thisRecord.Management_Information_Report__c)){
					userReportMap.get(thisRecord.User__c).put(thisRecord.Management_Information_Report__c, thisRecord.Management_Information_Report__c);
				}
			}
			else{
				userReportMap.put(thisRecord.User__c, new Map<Id, Id>{thisRecord.Management_Information_Report__c => thisRecord.Management_Information_Report__c});
			}
			
			// getting percentage of users checking MIR every month
			String thisMonth = monthMap.get(thisRecord.Management_Information_Report__r.Report_Date__c.month()) + ', ' + thisRecord.Management_Information_Report__r.Report_Date__c.year();
			if (!monthlyUsers.containsKey(thisMonth)){
				monthlyUsersOrdered.add(thisMonth);
				monthlyUsers.put(thisMonth, new Map<Id, Id>{thisRecord.User__c => thisRecord.User__c});
			}
			else{
				if (!monthlyUsers.get(thisMonth).containsKey(thisRecord.User__c)){
					monthlyUsers.get(thisMonth).put(thisRecord.User__c, thisRecord.User__c);
				}
			}
			
			// getting percentage of users checking MIR every quarter
			String thisQuarter = quarterMap.get(thisRecord.Management_Information_Report__r.Report_Date__c.month()) + ', ' + thisRecord.Management_Information_Report__r.Report_Date__c.year();
			if (!quarterUsers.containsKey(thisQuarter)){
				quarterUsersOrdered.add(thisQuarter);
				quarterUsers.put(thisQuarter, new Map<Id, Id>{thisRecord.User__c => thisRecord.User__c});
			}
			else{
				if (!quarterUsers.get(thisQuarter).containsKey(thisRecord.User__c)){
					quarterUsers.get(thisQuarter).put(thisRecord.User__c, thisRecord.User__c);
				}
			}
		}
		
		// getting users that used MIR at least once
        userListUsedOnce = [SELECT Id, ContactId, Email, Contact.Name, Contact.IATA_Code__c, Contact.Account.Name
									FROM User WHERE Id IN :userListUsedOnceIds];
		totalContactsSeenOnce = userListUsedOnce.size();
		
		// getting percentage of users that never used MIR
        totalContactsUsed = allUserIds.size();
        if (!allUserIds.isEmpty()){
			userListNeverUsed = [SELECT Id, ContactId, Email, Contact.Name, Contact.IATA_Code__c, Contact.Account.Name
									FROM User WHERE Id IN :allUserIds
									ORDER BY Contact.IATA_Code_Numeric__c];
		}
		
		// getting full number of contacts
		totalContacts = totalContactsSeenOnce + totalContactsUsed;
		
		// getting percentages
		totalContactsSeenOncePercent = (totalContactsSeenOnce/totalContacts)*100;
		totalContactsSeenOncePercent = totalContactsSeenOncePercent.setscale(2);
		totalContactsUsedPercent = ((totalContactsUsed)/totalContacts)*100;
        totalContactsUsedPercent = totalContactsUsedPercent.setscale(2);

		// getting usage percentage for each report
		for(String key : reportUserMap.keySet())
        {
            reportUserSizeMap.put(key, reportUserMap.get(key).size());
            Decimal myPercent = ((reportUserMap.get(key).size())/totalContacts)*100;
            myPercent = myPercent.setscale(2);
            reportUserPercentMap.put(key, myPercent);
        }
        
        // getting percentage of users using MIR every week
        totalContactsSeenAll = 0;
        for(Id key : userReportMap.keySet()){
        	if (userReportMap.get(key).size() == totalReports){
        		totalContactsSeenAll++;
        		userListAlwaysUsedIds.add(key);
        	}
        }
        totalContactsSeenAllPercent = (totalContactsSeenAll/totalContacts)*100;
		totalContactsSeenAllPercent = totalContactsSeenAllPercent.setscale(2);
		if (!userListAlwaysUsedIds.isEmpty()){
			userListAlwaysUsed = [SELECT Id, ContactId, Email, Contact.Name, Contact.IATA_Code__c, Contact.Account.Name
									FROM User WHERE Id IN :userListAlwaysUsedIds
									ORDER BY Contact.IATA_Code_Numeric__c];
		}
		
		// getting percentage of users checking MIR every month
		for(String key : monthlyUsers.keySet())
        {
            monthlyUserSizeMap.put(key, monthlyUsers.get(key).size());
            Decimal myMonthlyPercent = ((monthlyUsers.get(key).size())/totalContacts)*100;
            myMonthlyPercent = myMonthlyPercent.setscale(2);
            monthlyUserPercentMap.put(key, myMonthlyPercent);
        }
        
        // getting percentage of users checking MIR every quarter
		for(String key : quarterUsers.keySet())
        {
            quarterUserSizeMap.put(key, quarterUsers.get(key).size());
            Decimal myQuarterPercent = ((quarterUsers.get(key).size())/totalContacts)*100;
            myQuarterPercent = myQuarterPercent.setscale(2);
            quarterUserPercentMap.put(key, myQuarterPercent);
        }
        
	}
	
	public class reportWrapper{
		public Date reportDate {get; set;}
		public List <Id> userList {get; set;}
	}
	
	public String excelName {
        get {
            return 'MIR_Metrics_' + Date.today().year() + Date.today().month() + Date.today().day();
        }
        set;
    }
	
	public PageReference export2Excel() {
        PageReference pr = Page.ISSP_MIR_Metrics_Export;

        pr.setRedirect(true);
            
        return pr;
    }
	
}