public with sharing class AccountDashboardCTI {
	public String accountId {get;set;}
	public String contactId {get;set;}

	public AccountDashboardCTI(ApexPages.StandardController stdc){
		try{
			accountId = stdc.getRecord().Id;
			contactId = ApexPages.currentPage().getParameters().get('ContactId');
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' No Account has been selected'));
		}
	}

	public PageReference checkandredirect(){
		String urlToRedirect = '/';
		PageReference pageRef = new PageReference(urlToRedirect);
		try{
			String contactId = ApexPages.currentPage().getParameters().get('id');
			if (contactId != null && (contactId.length() == 15 || contactId.length() == 18)) {
				Contact accContact = [SELECT AccountId FROM Contact WHERE Id = :contactId LIMIT 1];
				if (accContact!=null) {
					accountId = String.valueOf(accContact.AccountId);
				}
			}
			if (contactId != '' && accountId != '') {
				urlToRedirect = '/apex/AccountDashboardCTI?contactId='+contactId+'&id='+accountId;
			} else if (contactId!=null) {
				urlToRedirect = '/'+contactId;
			}
			pageRef = new PageReference(urlToRedirect);
			pageRef.setRedirect(true);
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' No Contact/Account has been selected'));
		}
		return pageRef;
	}
}