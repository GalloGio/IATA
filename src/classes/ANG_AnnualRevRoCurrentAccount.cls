public with sharing class ANG_AnnualRevRoCurrentAccount {
	public Account account {get; set;}
	public String status {get; set;} // C  - Confirmed
									 // UP - Update in progress
									 // UC - Update confirmed
									 // O  - Open

	public String statusDesc {
		get{
			if(this.status == 'C') {
				return Label.ISSP_ANG_ANNUAL_STATUS_CONFIRMED;
			} else if(this.status == 'UP') {
				return Label.ISSP_ANG_ANNUAL_STATUS_UPDATE_PROGRESS;
			} else if(this.status == 'UC') {
				return Label.ISSP_ANG_ANNUAL_STATUS_UPDATE_COMPLETED;
			} else {
				return Label.ISSP_ANG_ANNUAL_STATUS_OPEN;
			}
		}
		set;
	}

	public ANG_AnnualRevRoCurrentAccount(Account account, String status) {
		this.account = account;
		this.status = status;
	}
}