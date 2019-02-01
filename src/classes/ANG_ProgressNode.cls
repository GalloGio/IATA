
public with sharing class ANG_ProgressNode {
	public String title {get; set;}
	public String description {get; set;}
	public String status {get; set;}
	public Decimal nodeNumber {get; set;}

	public ANG_ProgressNode(String title, String description, String status, Decimal nodeNumber) {
		this.title = title;
		this.description = description;
		this.status = status;
		this.nodeNumber = nodeNumber;
	}
}