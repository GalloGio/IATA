public class vfIECEBC_CampaignPreview extends vfIECEBC_Controller {
	public final EBC_Template__c tpl;

	public vfIECEBC_CampaignPreview(ApexPages.StandardController stdController) {
		this.tpl = (EBC_Template__c)stdController.getRecord();
	}

	public Attachment att {
		get {
			if (att == null) {
				List<Attachment> atts = [SELECT Body,BodyLength,ContentType,Name FROM Attachment WHERE ParentId = :this.tpl.Id LIMIT 1];
				if (atts.size() > 0) att = atts[0];
			}

			return att;
		}
		set;
	}

	public String getBody() {
		if (att != null) {
			return att.Body.toString();
		}

		return null;
	}
}
