public with sharing class ANG_AnnualRevRoHelper {
	public ANG_AnnualRevRoCurrentAccount ca {get; set;}

	public ANG_AnnualRevRoHelper(ANG_AnnualRevRoCurrentAccount ca) {
		this.ca = ca;
	}

	public Account getCurrentAccount() {
		return this.ca.account;
	}
}