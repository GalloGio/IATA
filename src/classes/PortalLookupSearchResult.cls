/**
* Class used to serialize a single Lookup search result item
* The Lookup controller returns a List<PortalLookupSearchResult> when sending search result back to Lightning
*/
public class PortalLookupSearchResult {

	private Id id;
	private String sObjectType;
	private String icon;
	private String title;
	private String subtitle;
	public Map<String,String> extraFields;

	public PortalLookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
		this.id = id;
		this.sObjectType = sObjectType;
		this.icon = icon;
		this.title = title;
		this.subtitle = subtitle;
	}

	public void setExtraFields(Map<String,String> extras) {
		this.extraFields = extras;
	}

	@AuraEnabled
	public Id getId() {
		return id;
	}

	@AuraEnabled
	public String getSObjectType() {
		return sObjectType;
	}

	@AuraEnabled
	public String getIcon() {
		return icon;
	}

	@AuraEnabled
	public String getTitle() {
		return title;
	}

	@AuraEnabled
	public String getSubtitle() {
		return subtitle;
	}

	@AuraEnabled
	public Map<String,String> getExtraFields() {
		return extraFields;
	}
}
