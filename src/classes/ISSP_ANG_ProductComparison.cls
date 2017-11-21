public with sharing class ISSP_ANG_ProductComparison {

	public List<String> headers {get; set;}

	public ANG_ProductComparisonHelper helper {get; set;}
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

	public ISSP_ANG_ProductComparison() {
		this.helper = new ANG_ProductComparisonHelper('A');
	}
}