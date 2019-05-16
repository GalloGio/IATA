public with sharing class ANG_ProgressNode {
	public String title {get; set;}
	public String description {get; set;}
	public String status {get; set;}
	public Integer nodeNumber {get; set;}
	public String iconProgress {get; set;}
	public String iconOk {get; set;}
	public String iconError {get; set;}
	public String iconNotDone {get; set;}

	public ANG_ProgressNode(ANG_ProgressBarStep__mdt step, String status) {
		this.title = step.MasterLabel;
		this.description = step.Description__c;
		this.status = status;
		this.nodeNumber = Integer.ValueOf(step.Order__c);
		this.iconProgress = step.iconProgress__c;
		this.iconOk = step.iconOk__c;
		this.iconError = step.iconError__c;
		this.iconNotDone = step.iconNotDone__c;
	}
}