public without sharing class GenerateLateRemittanceCSVController {
	public String strRegion {get; set;}
	public String strFileName {get; set;}

	public List<SelectOption> lstRegions {
		public get {
			List<SelectOption> options = new List<SelectOption>();

			Schema.DescribeFieldResult fieldResult = Case.Region__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

			for( Schema.PicklistEntry f : ple) {
				options.add(new SelectOption(f.getLabel(), f.getValue()));
			}

			return options;
		} private set;
	}

	public Case dummyStart {get;set;}
	public Case dummyEnd {get;set;}

	private Date startDate {
		get {return dummyStart.Bank_Guarantee_deadline__c;}
		set;
	}
	private Date endDate {
		get{return dummyEnd.Bank_Guarantee_deadline__c;}
		set;
	}

	public String contentType {public get; private set;}
	public Boolean filterView {public get; private set;}

	public String CSVcontent;

	private list<String> listExcludedCountries;


	public GenerateLateRemittanceCSVController() {
		// initialize the report dates to the first day and last day of the current month

		this.dummyStart = new Case(Bank_Guarantee_deadline__c = Date.today());
		this.dummyEnd = new Case(Bank_Guarantee_deadline__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1));

		// initialize the page in the view filter mode
		filterView = true;
		contentType = 'text/html';

		// initialize the default extracted filename
		strFileName = 'Late_Payment_Fee_Report.csv';

		system.debug('### Start date: ' + this.startDate.format() + '; End date: ' + this.endDate.format());

		this.listExcludedCountries = new list<String>();
		for (Late_Payment_Fees_CASS_ISO_Countries_Exc__c country: Late_Payment_Fees_CASS_ISO_Countries_Exc__c.getall().values()) {
			this.listExcludedCountries.add(country.Name);
		}
	}


	public void GenerateCSV () {
		contentType = 'application/octet-stream#' + (strFileName != '' ? strFileName : 'Late_Payment_Fee_Report.csv');
		filterView = false;

		system.debug('### Parsed dates for the CSV generation >>> Start date: ' + startDate + '; End date: ' + endDate);
	}


	public String getCSVcontent () {
		// the string that will hold the generated CSV contents; initialized with the table header
		String strCSVReport = 'DocType,SalesOrg,DistChan,Division,SalesOffice,CustName,AgentCode,ContractNo,Ponumber,Podate,Sodesc,DocCurr,PayMethod,BillingDate,TextPrint,InternalRemark,Material,MatDesc,Quantity,UnitPrice,UnitPriceCurr,DateFrom,DateTo,CaseNumber,Region,IATACountry';

		/* REPORT 1 - Late payment fee report */
		List<Case> tmpListCases = [SELECT Id, Account.IATA_ISO_Country__r.SAP_Sales_Org__c, IFAP_Agent_Code__c, Short_Payment_Amount__c, Short_Payment_Date__c, Late_Payment_Date__c,
										Remittance_Date__c, Remittance_Period__c, Currency__c, BSP_CASS__c, CaseNumber, Region__c, Account.IATA_ISO_Country__r.Name, Confirm_ALL_Outstanding_Amounts_Paid__c
									FROM Case
									WHERE RecordType.DeveloperName = 'SIDRA'
									AND Update_AIMS_IRR__c <> null
									AND (
										Update_AIMS_IRRWITH__c = null
										OR IRR_Withdrawal_Reason__c = 'Bank Error'
									)
									AND Update_AIMS_DEF__c = null
									AND (
										BSP_CASS__c = 'BSP'
										OR (
											BSP_CASS__c = 'CASS'
											AND Account.Category__c IN ('CASS Associate', 'IATA Cargo Agent')
											AND Account.IATA_ISO_Country__r.ISO_Code__c NOT IN :listExcludedCountries
										)
									)
									AND BSPCountry__c NOT IN ('Israel', 'Russia & CIS')

									AND Account.IATA_ISO_Country__r.SAP_Sales_Org__c != null
									AND Update_AIMS_IRR__c >= :startDate
									AND Update_AIMS_IRR__c <= :endDate
									AND Region__c = :strRegion
									ORDER BY Id];

		for (Case c : tmpListCases) {
			// create the case wrapper for: Late payment fix fee
			CaseWrapper cw = new CaseWrapper();
			cw.DocType = 'ZO01';
			cw.SalesOrg = c.Account.IATA_ISO_Country__r.SAP_Sales_Org__c;
			cw.DistChan = '01';
			cw.Division = '51';
			cw.SalesOffice = '';
			cw.CustName = '';
			cw.AgentCode = c.IFAP_Agent_Code__c != null ? c.IFAP_Agent_Code__c : '';
			cw.ContractNo = '';
			cw.Ponumber = '';
			cw.Podate = '';
			cw.Sodesc = '';
			cw.DocCurr = '';
			cw.PayMethod = '';
			cw.BillingDate = '';
			cw.TextPrint = '';
			cw.InternalRemark = '';
			//cw.Material = '800395';
			if (c.BSP_CASS__c == 'BSP') {
				cw.Material = '800395';
			}
			if (c.BSP_CASS__c == 'CASS') {
				cw.Material = '800931';
			}
			cw.MatDesc = 'Late Remittance Recovery ' + c.Remittance_Period__c;
			cw.Quantity = '1';
			cw.UnitPrice = '';
			cw.UnitPriceCurr = '';
			cw.DateFrom = startDate.format().replace('/','.');
			cw.DateTo = endDate.format().replace('/','.');
			cw.CaseNumber = c.CaseNumber;
			cw.Region = c.Region__c;
			cw.IATACountry = c.Account.IATA_ISO_Country__r.Name;

			strCSVReport += '\n' + cw.toCSV();

			// create the case wrapper for: Late payment variable fee
			cw = new CaseWrapper();
			cw.DocType = 'ZO01';
			cw.SalesOrg = c.Account.IATA_ISO_Country__r.SAP_Sales_Org__c;
			cw.DistChan = '01';
			cw.Division = '51';
			cw.SalesOffice = '';
			cw.CustName = '';
			cw.AgentCode = c.IFAP_Agent_Code__c != null ? c.IFAP_Agent_Code__c : '';
			cw.ContractNo = '';
			cw.Ponumber = '';
			cw.Podate = '';
			cw.Sodesc = '';
			cw.DocCurr = '';
			cw.PayMethod = '';
			cw.BillingDate = '';
			cw.TextPrint = '';
			cw.InternalRemark = '';
			//cw.Material = '800394';
			if (c.BSP_CASS__c == 'BSP') {
				cw.Material = '800394';
			}
			if (c.BSP_CASS__c == 'CASS') {
				cw.Material = '801185';
			}
			cw.MatDesc = 'Late Remittance Interest ' + c.Remittance_Period__c;
			//WMO-778 - ACAMBAS - Begin
			Datetime tempDatetime;
			Date confirmAllOutstandingAmountsPaid;

			if(c.Confirm_ALL_Outstanding_Amounts_Paid__c != null) {
				tempDatetime = c.Confirm_ALL_Outstanding_Amounts_Paid__c;
				confirmAllOutstandingAmountsPaid = Date.newinstance(tempDatetime.year(), tempDatetime.month(), tempDatetime.day());
			}

			//cw.Quantity = (c.Late_Payment_Date__c != null && c.Remittance_Date__c != null) ? String.valueOf(c.Remittance_Date__c.daysBetween(c.Late_Payment_Date__c)) : 'ERROR: Remittance Date or Late Payment Date missing';
			if(c.Late_Payment_Date__c != null && c.Remittance_Date__c != null) {
				cw.Quantity = String.valueOf(c.Remittance_Date__c.daysBetween(c.Late_Payment_Date__c));
			}
			else {
				if(c.Remittance_Date__c != null && c.Confirm_ALL_Outstanding_Amounts_Paid__c != null) {
					cw.Quantity = String.valueOf(c.Remittance_Date__c.daysBetween(confirmAllOutstandingAmountsPaid));
				}
				else {
					cw.Quantity = 'ERROR: Remittance Date or Late Payment Date/Confirm ALL Outst. Amounts Paid missing';
				}
			}
			//WMO-778 - ACAMBAS - End
			cw.UnitPrice = c.Short_Payment_Amount__c != null ? String.valueOf(c.Short_Payment_Amount__c) : '';
			cw.UnitPriceCurr = c.Currency__c != null ? c.Currency__c : '';
			cw.DateFrom = c.Remittance_Date__c != null ? c.Remittance_Date__c.format().replace('/','.') : '';
			//WMO-778 - ACAMBAS - Begin
			//cw.DateTo = c.Late_Payment_Date__c != null ? c.Late_Payment_Date__c.format().replace('/','.') : '';
			if(c.Late_Payment_Date__c != null) {
				cw.DateTo = c.Late_Payment_Date__c.format().replace('/','.');
			}
			else if(c.Confirm_ALL_Outstanding_Amounts_Paid__c != null) {
				cw.DateTo = confirmAllOutstandingAmountsPaid.format().replace('/','.');
			}
			else {
				cw.DateTo = '';
			}
			//WMO-778 - ACAMBAS - End
			cw.CaseNumber = c.CaseNumber;
			cw.Region = c.Region__c;
			cw.IATACountry = c.Account.IATA_ISO_Country__r.Name;

			strCSVReport += '\n' + cw.toCSV();
		}

		/* REPORT 3 - Minor error policy (IFAP) */
		tmpListCases = [SELECT Id, Account.IATA_ISO_Country__r.SAP_Sales_Org__c, IFAP_Agent_Code__c, CaseNumber, Region__c, Account.IATA_ISO_Country__r.Name
						FROM Case
						WHERE RecordType.DeveloperName IN ('IATA_Financial_Review','ProcessEuropeSCE')
						AND SIDRA_Exclude_from_report_exceptions__c = true
						AND Account.IATA_ISO_Country__r.SAP_Sales_Org__c != null
						AND (
							(   RecordType.DeveloperName = 'IATA_Financial_Review'
								AND Deadline_Date__c >= :startDate
								AND Deadline_Date__c <= :endDate
							) OR (
								RecordType.DeveloperName = 'ProcessEuropeSCE'
								AND Bank_Guarantee_deadline__c >= :startDate
								AND Bank_Guarantee_deadline__c <= :endDate
							)
						)
						AND Region__c = :strRegion
						ORDER BY Id];

		for (Case c : tmpListCases) {
			CaseWrapper cw = new CaseWrapper();
			cw.DocType = 'ZO01';
			cw.SalesOrg = c.Account.IATA_ISO_Country__r.SAP_Sales_Org__c;
			cw.DistChan = '01';
			cw.Division = '51';
			cw.SalesOffice = '';
			cw.CustName = '';
			cw.AgentCode = c.IFAP_Agent_Code__c != null ? c.IFAP_Agent_Code__c : '';
			cw.ContractNo = '';
			cw.Ponumber = '';
			cw.Podate = '';
			cw.Sodesc = '';
			cw.DocCurr = '';
			cw.PayMethod = '';
			cw.BillingDate = '';
			cw.TextPrint = '';
			cw.InternalRemark = '';
			cw.Material = '752026';
			cw.MatDesc = '';
			cw.Quantity = '1';
			cw.UnitPrice = '';
			cw.UnitPriceCurr = '';
			cw.DateFrom = startDate.format().replace('/','.');
			cw.DateTo = endDate.format().replace('/','.');
			cw.CaseNumber = c.CaseNumber;
			cw.Region = c.Region__c;
			cw.IATACountry = c.Account.IATA_ISO_Country__r.Name;

			strCSVReport += '\n' + cw.toCSV();
		}

		/* REPORT 4 - Interest invoices/charges  */
		tmpListCases = 
			[SELECT Id, Account.IATA_ISO_Country__r.SAP_Sales_Org__c, IFAP_Agent_Code__c, Short_Payment_Amount__c, Short_Payment_Date__c, Late_Payment_Date__c,
				Remittance_Date__c, Remittance_Period__c, Currency__c, BSP_CASS__c, CaseNumber, Region__c, Account.IATA_ISO_Country__r.Name, Confirm_ALL_Outstanding_Amounts_Paid__c,
				(SELECT Id, Interest_Amount__c FROM Case_Details__r WHERE RecordType.DeveloperName = 'Repayment_Instalment_Details' LIMIT 1)
			FROM Case
			WHERE RecordType.DeveloperName = 'SIDRA'
			AND Update_AIMS_REI_DEFWITH__c <> null
			AND Update_AIMS_Repayment_agreed__c <> null
			AND (
				(
					BSP_CASS__c = 'BSP'
					AND Account.Location_Class__c = 'P'
				)OR (
					BSP_CASS__c = 'CASS'
					AND Account.Category__c IN ('CASS Associate', 'IATA Cargo Agent')
					AND Account.IATA_ISO_Country__r.ISO_Code__c NOT IN :listExcludedCountries
				)
			)
			AND BSPCountry__c NOT IN ('Israel', 'Russia & CIS')
			AND Account.IATA_ISO_Country__r.SAP_Sales_Org__c != null
			AND Update_AIMS_REI_DEFWITH__c >= :startDate
			AND Update_AIMS_REI_DEFWITH__c <= :endDate
			AND Region__c = :strRegion
			ORDER BY Id];

		for (Case c : tmpListCases) {
			// only records with interest will be included in the csv
			if ( c.Case_Details__r.size()>0) {
				// create the case wrapper for: Late payment fix fee
				CaseWrapper cw = new CaseWrapper();
				cw.DocType = 'ZO01';
				cw.SalesOrg = c.Account.IATA_ISO_Country__r.SAP_Sales_Org__c;
				cw.DistChan = '01';
				cw.Division = '51';
				cw.SalesOffice = '';
				cw.CustName = '';
				cw.AgentCode = c.IFAP_Agent_Code__c != null ? c.IFAP_Agent_Code__c : '';
				cw.ContractNo = '';
				cw.Ponumber = '';
				cw.Podate = '';
				cw.Sodesc = '';
				cw.DocCurr = '';
				cw.PayMethod = '';
				cw.BillingDate = '';
				cw.TextPrint = '';
				cw.InternalRemark = '';
				if (c.BSP_CASS__c == 'BSP') {
					cw.Material = '801330';
				}
				if (c.BSP_CASS__c == 'CASS') {
					cw.Material = '801331';
				}
				cw.MatDesc = 'Repayment Interest ' + c.BSP_CASS__c;
				cw.Quantity = '1';
				cw.UnitPrice = String.ValueOf(c.Case_Details__r[0].Interest_Amount__c);
				cw.UnitPriceCurr = c.Currency__c;
				cw.DateFrom = startDate.format().replace('/','.');
				cw.DateTo = endDate.format().replace('/','.');
				cw.CaseNumber = c.CaseNumber;
				cw.Region = c.Region__c;
				cw.IATACountry = c.Account.IATA_ISO_Country__r.Name;
	
				strCSVReport += '\n' + cw.toCSV();
			}
		}

		return strCSVReport;
	}

	public class CaseWrapper {
		public String DocType {get; set;}
		public String SalesOrg {get; set;}
		public String DistChan {get; set;}
		public String Division {get; set;}
		public String SalesOffice {get; set;}
		public String CustName {get; set;}
		public String AgentCode {get; set;}
		public String ContractNo {get; set;}
		public String Ponumber {get; set;}
		public String Podate {get; set;}
		public String Sodesc {get; set;}
		public String DocCurr {get; set;}
		public String PayMethod {get; set;}
		public String BillingDate {get; set;}
		public String TextPrint {get; set;}
		public String InternalRemark {get; set;}
		public String Material {get; set;}
		public String MatDesc {get; set;}
		public String Quantity {get; set;}
		public String UnitPrice {get; set;}
		public String UnitPriceCurr {get; set;}
		public String DateFrom {get; set;}
		public String DateTo {get; set;}
		public String CaseNumber {get; set;}
		public String Region {get; set;}
		public String IATACountry {get; set;}

		public String toCSV() {
			return DocType + ',' + SalesOrg + ',' + DistChan + ',' + Division + ',' + SalesOffice + ',' + CustName + ',' + AgentCode +
				',' + ContractNo + ',' + Ponumber + ',' + Podate + ',' + Sodesc + ',' + DocCurr + ',' + PayMethod + ',' + BillingDate +
				',' + TextPrint + ',' + InternalRemark + ',' + Material + ',' + MatDesc + ',' + Quantity + ',' + UnitPrice + ',' + UnitPriceCurr +
				',' + DateFrom + ',' + DateTo + ',' + CaseNumber + ',' + Region + ',' + IATACountry;
		}

	}
}
