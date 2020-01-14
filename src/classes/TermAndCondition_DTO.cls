public with sharing class TermAndCondition_DTO
{
	public String tncId{get;set;}
	public String tncName{get;set;}
	public String status{get;set;}
	public Date startDate{get;set;}
	public String attachmentURL{get;set;}
	public Boolean accepted{get;set;}

	public TermAndCondition_DTO(Product_Term_Condition__c pTnC)
	{
		tncId = pTnC.Term_Condition__c;
		tncName = pTnC.Term_Condition__r.Name;
		status = pTnC.Term_Condition__r.Status__c;
		startDate = pTnC.Term_Condition__r.Effective_Start_Date__c;
		attachmentURL = 'viewTNC';
		accepted = false;
	}
}
