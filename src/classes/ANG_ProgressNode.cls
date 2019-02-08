public with sharing class ANG_ProgressNode {
	public String title {get; set;}
	public String description {get; set;}
	public String status {get; set;}
	public Integer nodeNumber {get; set;}

	public ANG_ProgressNode(String title, String description, String status, Integer nodeNumber) {
		this.title = title;
		this.description = description;
		this.status = status;
		this.nodeNumber = nodeNumber;
	}
}