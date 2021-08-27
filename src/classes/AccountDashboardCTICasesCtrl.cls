public with sharing class AccountDashboardCTICasesCtrl {

	@AuraEnabled
	public static List<CasesList> getAccountCases(Id accountId, Id contactId) {
		List<Case> casesRecords = searchCases(accountId, 5);
		List<CasesList> casesListWrapper = new List<CasesList>();
		for(Case cas : casesRecords) {
			casesListWrapper.add(new CasesList(cas));
		}
		return casesListWrapper;
	}

	public static List<Case> searchCases(Id accountId, Integer recs) {
		List<Case> keyCases = [SELECT Id, CaseNumber, Subject, Case_Type__c, Type, Owner.Name, Origin, ContactId, Contact.Name, LastModifiedDate, CreatedDate, ClosedDate 
									FROM Case 
									WHERE AccountId = :accountId 
									ORDER BY LastModifiedDate DESC, CreatedDate DESC, ClosedDate DESC 
									LIMIT :recs
							];
		return keyCases;
	}

	public class CasesList {
		@AuraEnabled public Id caseId {get;set;}
		@AuraEnabled public String caseLink {get;set;}
		@AuraEnabled public String caseNumber {get;set;}
		@AuraEnabled public String caseTypeImg {get;set;}
		@AuraEnabled public String caseType {get;set;}
		@AuraEnabled public String caseSubject {get;set;}
		@AuraEnabled public String caseChannel {get;set;}
		@AuraEnabled public String caseDate {get;set;}
		@AuraEnabled public String caseResolTime {get;set;}
		@AuraEnabled public String caseOwnerName {get;set;}
		@AuraEnabled public String contactLink {get;set;}
		@AuraEnabled public String contactName {get;set;}

		public CasesList(Case con) {
			this.caseId = con.Id;
			this.caseLink = '/' + con.Id;
			this.caseNumber = con.CaseNumber;
			this.caseTypeImg = con.Case_Type__c;
			this.caseType = con.Type;
			this.caseSubject = con.Subject;
			this.caseChannel = con.Origin;
			this.caseDate = String.valueOf(con.CreatedDate);
			this.caseResolTime = String.valueOf(con.ClosedDate);
			this.caseOwnerName = con.Owner.Name;
			this.contactName = con.Contact.Name;
			this.contactLink = '/' + con.ContactId;
		}
	}
}