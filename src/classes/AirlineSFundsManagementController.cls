public with sharing class AirlineSFundsManagementController {
	public Airline_Suspension__c asrecord {public get; private set;}
	public Case c {public get; private set;}
	public List<Funds_Management_Line__c> lstHeldFMLines {get; set;}
	public List<Funds_Management_Line__c> lstDueFMLines {get; set;}
	public Boolean isAddNew {get; set;}
	public Boolean isEditMode {get; set;}
	public Boolean isNewLine {get; set;}
	public Id IdConcerned {get; set;}
	public Boolean isEditCommentsMode {get;set;}

	public List<ExcelExportWrapper> lstExportExcel {
		get {
			List<ExcelExportWrapper> tmpList = new List<ExcelExportWrapper>();

			for (Integer i = 0; i < math.max(lstHeldFMLines.size(),lstDueFMLines.size()); i++) {
				ExcelExportWrapper ew = new ExcelExportWrapper();

				ew.RepBy_Held = lstHeldFMLines.size() <= i ? '' : (lstHeldFMLines[i].Reported_by__c == null ? '' : lstHeldFMLines[i].Reported_by__c);
				ew.Currency_Held = lstHeldFMLines.size() <= i ? '' : (lstHeldFMLines[i].CurrencyIsoCode == null ? '' : lstHeldFMLines[i].CurrencyIsoCode);
				ew.Amount_Held = lstHeldFMLines.size() <= i ? '' : (lstHeldFMLines[i].Amount__c == null ? '' : String.valueOf(lstHeldFMLines[i].Amount__c));
				ew.Estimated_Held = lstHeldFMLines.size() <= i ? '' : (lstHeldFMLines[i].Estimated_in_USD__c == null ? '' : String.valueOf(lstHeldFMLines[i].Estimated_in_USD__c));
				ew.Remarks_Held = lstHeldFMLines.size() <= i ? '' : (lstHeldFMLines[i].Remarks__c == null ? '' : lstHeldFMLines[i].Remarks__c);
				ew.RepBy_Due = lstDueFMLines.size() <= i ? '' : (lstDueFMLines[i].Reported_by__c == null ? '' : lstDueFMLines[i].Reported_by__c);
				ew.Currency_Due = lstDueFMLines.size() <= i ? '' : (lstDueFMLines[i].CurrencyIsoCode == null ? '' : lstDueFMLines[i].CurrencyIsoCode);
				ew.Amount_Due = lstDueFMLines.size() <= i ? '' : (lstDueFMLines[i].Amount__c == null ? '' : String.valueOf(lstDueFMLines[i].Amount__c));
				ew.Estimated_Due = lstDueFMLines.size() <= i ? '' : (lstDueFMLines[i].Estimated_in_USD__c == null ? '' : String.valueOf(lstDueFMLines[i].Estimated_in_USD__c));
				ew.Remarks_Due = lstDueFMLines.size() <= i ? '' : (lstDueFMLines[i].Remarks__c == null ? '' : lstDueFMLines[i].Remarks__c);

				tmpList.add(ew);
			}

			return tmpList;
		} set;
	}

	public AirlineSFundsManagementController (ApexPages.StandardController controller) {
		if (controller.getRecord().Id != null ) {
			c = (Case)controller.getRecord();

			List<Airline_Suspension__c> lstASRecords = [SELECT Id, Total_amount_due__c, Total_amount_held__c, Net_amount_due__c, Comments__c, Airline_Name__c, Statement_of_Account_Date__c
														FROM Airline_Suspension__c
														WHERE Case__c = :c.Id];

			if (lstASRecords.size() == 1) {
				asrecord = lstASRecords[0];

				if (asrecord  != null) {
					refreshlstHeldFMLines();
					refreshlstDueFMLines();
				}

			} else if (lstASRecords.isEmpty()) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No associated Airline Suspension record found! Please contact support.'));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'More than 1 associated Airline Suspension record found! Please contact support.'));
			}

			isAddNew = false;
			isEditMode = false;
			isNewLine = false;
			isEditCommentsMode = false;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case'));
		}
	}

	private void refreshlstHeldFMLines() {
		lstHeldFMLines = [SELECT Id, Airline_Suspension__c, Type__c, Amount__c, Estimated_in_USD__c, Remarks__c, Reported_by__c, CurrencyIsoCode, Comments__c
																		FROM Funds_Management_Line__c
																		WHERE Airline_Suspension__c = :asrecord.Id
																		AND Type__c = 'Held'
																		ORDER BY Id ASC];
	}

	private void refreshlstDueFMLines() {
		lstDueFMLines = [SELECT Id, Airline_Suspension__c, Type__c, Amount__c, Estimated_in_USD__c, Remarks__c, Reported_by__c, CurrencyIsoCode, Comments__c
																		FROM Funds_Management_Line__c
																		WHERE Airline_Suspension__c = :asrecord.Id
																		AND Type__c = 'Due'
																		ORDER BY Id ASC];
	}

	public void AddNewHeldLine() {
		try {
			Funds_Management_Line__c newLine = new Funds_Management_Line__c();
			newLine.Airline_Suspension__c = asrecord.Id;
			newLine.Amount__c = 0;
			newLine.Estimated_in_USD__c = 0;
			newLine.Type__c = 'Held';
			insert newLine;

			refreshlstHeldFMLines();

			IdConcerned = newLine.Id;
			isEditMode = true;
			isNewLine = true;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}

	public void AddNewDueLine() {
		try {
			Funds_Management_Line__c newLine = new Funds_Management_Line__c();
			newLine.Airline_Suspension__c = asrecord.Id;
			newLine.Amount__c = 0;
			newLine.Estimated_in_USD__c = 0;
			newLine.Type__c = 'Due';
			insert newLine;

			refreshlstDueFMLines();

			IdConcerned = newLine.Id;
			isEditMode = true;
			isNewLine = true;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}

	public void EditLine() {
		isEditMode = true;
	}


	public void SaveLine() {
		try {
			update lstHeldFMLines;
			update lstDueFMLines;

			isEditMode = false;
			isNewLine = false;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}

	public void EditComments() {
		isEditCommentsMode = true;
	}

	public PageReference CancelEditComments() {
		//isEditCommentsMode = false;

		PageReference retPage = new PageReference('/apex/AirlineSFundsManagement?id=' + c.Id);
		retPage.setRedirect(true);
		return retPage;
	}


	public void SaveComments() {
		try {
			update asrecord;

			isEditCommentsMode = false;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}


	public void DeleteLine() {
		try {
			Funds_Management_Line__c newLine = new Funds_Management_Line__c(Id = IdConcerned);
			delete newLine;
			refreshlstHeldFMLines();
			refreshlstDueFMLines();
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}


	public void CancelEdit() {
		try {
			if (isNewLine) {
				Funds_Management_Line__c newLine = new Funds_Management_Line__c(Id = IdConcerned);
				delete newLine;
			}

			refreshlstHeldFMLines();
			refreshlstDueFMLines();

			isEditMode = false;
			IdConcerned = null;
			isNewLine = false;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}

	// Uses the conversion rates in IATA to convert the values in the Amount column from the currency of the FMLine into USD
	// and puts the result in the column Estimated in USD
	public PageReference RefreshEstimatedValues() {
		// get all currencies used
		set<String> setCurrenciesInvolved = new set<String>();

		for (Funds_Management_Line__c fm : lstHeldFMLines) {
			setCurrenciesInvolved.add(fm.CurrencyIsoCode);
		}

		for (Funds_Management_Line__c fm : lstDueFMLines) {
			setCurrenciesInvolved.add(fm.CurrencyIsoCode);
		}

		// get the conversion rates for these currencies and put them in a map of exchange rate per currency code
		map<String, CurrencyType> mapCurrencyTypePerCurrencyCode = new map<String, CurrencyType>();
		for (CurrencyType ct : [SELECT Id, IsoCode, ConversionRate FROM CurrencyType WHERE IsoCode IN :setCurrenciesInvolved]) {
			mapCurrencyTypePerCurrencyCode.put(ct.IsoCode, ct);
		}

		// update the estiamted in USD values of the FMLines
		for (Funds_Management_Line__c fm : lstHeldFMLines) {
			if (mapCurrencyTypePerCurrencyCode.get(fm.CurrencyIsoCode) != null && mapCurrencyTypePerCurrencyCode.get(fm.CurrencyIsoCode).ConversionRate != null ) {
				fm.Estimated_in_USD__c = fm.Amount__c / mapCurrencyTypePerCurrencyCode.get(fm.CurrencyIsoCode).ConversionRate;
			}
		}

		for (Funds_Management_Line__c fm : lstDueFMLines) {
			if (mapCurrencyTypePerCurrencyCode.get(fm.CurrencyIsoCode) != null && mapCurrencyTypePerCurrencyCode.get(fm.CurrencyIsoCode).ConversionRate != null ) {
				fm.Estimated_in_USD__c = fm.Amount__c / mapCurrencyTypePerCurrencyCode.get(fm.CurrencyIsoCode).ConversionRate;
			}
		}


		try {
			update lstHeldFMLines;
			update lstDueFMLines;

			PageReference retPage = new PageReference('/apex/AirlineSFundsManagement?id=' + c.Id);
			retPage.setRedirect(true);
			return retPage;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;
		}
	}


	public class ExcelExportWrapper{
		public String RepBy_Held {get; set;}
		public String Currency_Held {get; set;}
		public String Amount_Held {get; set;}
		public String Estimated_Held {get; set;}
		public String Remarks_Held {get; set;}
		public String RepBy_Due {get; set;}
		public String Currency_Due {get; set;}
		public String Amount_Due {get; set;}
		public String Estimated_Due {get; set;}
		public String Remarks_Due {get; set;}
	}

}
