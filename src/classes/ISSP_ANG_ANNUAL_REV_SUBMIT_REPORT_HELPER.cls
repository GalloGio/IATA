/*
	TEST CLASS : ISSP_ANG_ANNUAL_REVALIDATION_Test

*/
public with sharing class ISSP_ANG_ANNUAL_REV_SUBMIT_REPORT_HELPER {
	private static String OPEN_STATUS = 'O';
	private static String COMPLETED_STATUS = 'C';
	private static String UPDATE_PROGRESS_STATUS = 'UP';
	private static String UPDATE_COMPLETED_STATUS = 'UC';

	public List<String> notStarted {get; set;}
	public List<String> updateInProgress {get; set;}
	public List<String> detailsConfirmed {get; set;}
	public List<String> updateCompleted {get; set;}

	public String strListNotStarted{get {return listToString(notStarted);} set;}
	public String strListUpdateInProgress{get {return listToString(updateInProgress);} set;}
	public String strListDetailsConfirmed{get {return listToString(detailsConfirmed);} set;}
	public String strListUpdateCompleted{get {return listToString(updateCompleted);} set;}
	public Boolean showNotStarted {get; set;}
	public Boolean showDetailsConfirmed {get; set;}
	public Boolean showUpdateInProgress {get; set;}
	public Boolean showUpdateCompleted {get; set;}

	public Boolean allowSubmit {get; set;}

	public ISSP_ANG_ANNUAL_REV_SUBMIT_REPORT_HELPER(Map<String, String> iataCodes) {
		allowSubmit = true;
		showNotStarted = false;
		showDetailsConfirmed = false;
		showUpdateInProgress = false;
		showUpdateCompleted = false;
		notStarted = new List<String>();
		updateInProgress = new List<String>();
		detailsConfirmed = new List<String>();
		updateCompleted = new List<String>();

		for(String iataCode : iataCodes.keySet()) {
			putInSet(iataCode, iataCodes.get(iataCode));
		}

		System.debug('alex notStarted : ' + notStarted);
	}

	private void putInSet(String iataCode, String status) {
		if(status == OPEN_STATUS) {
			notStarted.add(iataCode);
			allowSubmit = false;
			showNotStarted = true;
		} else if(status == UPDATE_PROGRESS_STATUS) {
			updateInProgress.add(iataCode);
			allowSubmit = false;
			showUpdateInProgress = true;
		} else if(status == COMPLETED_STATUS) {
			detailsConfirmed.add(iataCode);
			showDetailsConfirmed = true;
		} else if(status == UPDATE_COMPLETED_STATUS) {
			updateCompleted.add(iataCode);
			showUpdateCompleted = true;
		}
	}

	private static String listToString(List<String> lst) {
		String rstr = '';
		Integer i = 0;
		for(String iataCode : lst) {
			i++;
			if(i < lst.size())
				rstr += iataCode + ', ';
			else
				rstr += iataCode;
		}
		return rstr;
	}
}