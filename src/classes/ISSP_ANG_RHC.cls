public with sharing class ISSP_ANG_RHC {

	public Account account {get;set;}
	public String accountId{ get{ return ApexPages.currentPage().getParameters().get('accountId'); }set;}

	public ISSP_ANG_RHC() {
		
	}

	public void initActions() {
		// this.account = [Select Name From Account Where Id = :accountId];
	}
}