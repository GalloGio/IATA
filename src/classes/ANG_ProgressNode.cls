public with sharing class ANG_ProgressNode {
	public String title {get; set;}
	public String titleTranslatable {get; set;}
	public String status {get; set;}
	public Decimal nodeNumber {get; set;}

	public ANG_ProgressNode(String title, String titleTranslatable, String status, Decimal nodeNumber) {
		this.title = title;
		this.titleTranslatable = titleTranslatable;
		this.status = status;
		this.nodeNumber = nodeNumber;
	}
}