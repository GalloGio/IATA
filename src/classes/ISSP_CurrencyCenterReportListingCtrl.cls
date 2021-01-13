public with sharing class ISSP_CurrencyCenterReportListingCtrl {

	public List<String> listOfSections {get; set;}
	public Set<String> sectionNameRBF {get; set;}
	public Set<String> sectionNameMisc {get; set;}

	public List<String> listOfYearsSection {get; set;}
	public Map<String, List<ccReport>> mapOfYearsSection {get; set;}
	public Map<String, Map<String, List<ccReport>>> reportsMap {get; set;}

	public Map<String, List<ccReport>> reportsMapRBF {get; set;}
	public Map<String, List<ccReport>> reportsMapMisc {get; set;}

	public class ccReport implements Comparable{
		public String Id {get;set;}
		public Integer Month {get;set;}
		public String MonthName {get; set;}
		public String YearName {get; set;}
		public String Title {get; set;}

		public Integer compareTo(Object compareTo) {
			try {
				ccReport report = (ccReport)compareTo;
				return Month - report.Month;
			} catch (Exception e) {
				return -1;
			}
		}
	}

	public ISSP_CurrencyCenterReportListingCtrl() {

		// Currency Repatriation - Monthly Reports
		this.reportsMap = new Map<String, Map<String, List<ccReport>>>();
		this.reportsMap.put('Currency Repatriation - Monthly Reports', getCurrencyRepatriationReports());
		this.listOfSections = new List<String>(this.reportsMap.keyset());
		this.listOfSections.sort();
		this.listOfSections = reverse(this.listOfSections);

		this.listOfYearsSection = new List<String>(this.reportsMap.get('Currency Repatriation - Monthly Reports').keyset());
		this.listOfYearsSection.sort();
		this.listOfYearsSection = reverse(this.listOfYearsSection);
		this.mapOfYearsSection = this.reportsMap.get('Currency Repatriation - Monthly Reports');
		for (String year: this.listOfYearsSection) {
			list<ccReport> listSection = this.mapOfYearsSection.get(year);
			listSection.sort();
		}

		// Annual RBF Reports
		this.reportsMapRBF = new Map<String, List<ccReport>>();
		this.reportsMapRBF.put('Annual RBF Reports', getCurrencyRBFReports());
		this.sectionNameRBF = new Set<String>{'Annual RBF Reports'};

		// Miscelaneous
		this.reportsMapMisc = new Map<String, List<ccReport>>();
		this.reportsMapMisc.put('Other reports', getCurrencyMiscReports());
		this.sectionNameMisc = new Set<String>{'Other reports'};
	}


		public Map<String, List<ccReport>> getCurrencyRepatriationReports() {

				List<ContentVersion> tmp  = [SELECT Id, Title, Description, FileType, Owner.Name, VersionNumber FROM ContentVersion WHERE Title LIKE 'CurrencyCenterCurrencyRepatriation_%' AND IsLatest=True ORDER BY Title];

		Map<String, List<ccReport>> returnMap = new Map<String, List<ccReport>>();

		for (ContentVersion s: tmp) {

			String yearName = s.Title.substringAfter('_').left(4);
			if (returnMap.get(yearName) == null)
				returnMap.put(yearName, new List<ccReport>());
		}

				for (ContentVersion s: tmp) {

					List<ccReport> ccrList  = new List<ccReport>();

				 	ccReport ccr = new ccReport();
				 	ccr.Id = s.Id;
				 	ccr.Title = s.Title;
				 	ccr.YearName = s.Title.substringAfter('_').left(4);
			ccr.Month = Integer.ValueOf(s.Title.right(2));

				 	switch on s.Title.right(2) {
					when '01' { ccr.MonthName = 'January'; 		}
					when '02' { ccr.MonthName = 'February'; 	}
					when '03' { ccr.MonthName = 'March'; 		}
					when '04' { ccr.MonthName = 'April'; 		}
					when '05' { ccr.MonthName = 'May'; 			}
					when '06' { ccr.MonthName = 'June'; 		}
					when '07' { ccr.MonthName = 'July'; 		}
					when '08' { ccr.MonthName = 'August'; 		}
					when '09' { ccr.MonthName = 'September';	}
					when '10' { ccr.MonthName = 'October'; 		}
					when '11' { ccr.MonthName = 'November'; 	}
					when '12' { ccr.MonthName = 'December'; 	}
					when else {}
			}

			returnMap.get(ccr.YearName).add(ccr);

				 }

				 return returnMap;
		}

		public List<ccReport> getCurrencyRBFReports() {

				List<ContentVersion> tmp  = [SELECT Id, Title, Description, FileType, Owner.Name, VersionNumber FROM ContentVersion WHERE Title LIKE 'CurrencyCenterAnnualRBF_%' AND IsLatest=True ORDER BY Title];

				System.debug('Luis ' + tmp);
				List<ccReport> ccrList = new List<ccReport>();

				for (ContentVersion s: tmp) {

				 	ccReport ccr = new ccReport();
				 	ccr.Id = s.Id;
				 	ccr.Title = s.Title;
				 	ccr.YearName = s.Title.substringAfter('_').left(4);

			ccrList.add(ccr);

				 }

				 return ccrList;
		}

		public List<ccReport> getCurrencyMiscReports() {

				List<ContentVersion> tmp  = [SELECT Id, Title, Description, FileType, Owner.Name, VersionNumber FROM ContentVersion WHERE Title LIKE 'CurrencyCenterMiscelaneous_%' AND IsLatest=True ORDER BY Title];

				List<ccReport> ccrList = new List<ccReport>();

				for (ContentVersion s: tmp) {

				 	ccReport ccr = new ccReport();
				 	ccr.Id = s.Id;
				 	ccr.Title = s.Title;
				 	ccr.YearName = s.Title.substringAfter('_').left(4);

			ccrList.add(ccr);

				 }

				 return ccrList;
		}

	public static List<String> reverse(List<String> listString) {
		List<String> listResult = new List<String>();
		for(Integer i = listString.size()-1; i >= 0; i--) {
			listResult.add(listString[i]);
		}
		return listResult;
	}
}
