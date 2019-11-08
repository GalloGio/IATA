public class vfIECEBC_Recipient extends vfIECEBC_Controller {
	public String wizardStep {
		get {
			if (wizardStep == null) wizardStep = 'Audience';
			return wizardStep;
		}
		set;
	}

	public ApexPages.StandardController con {
		public get;
		private set;
	}

	public vfIECEBC_Recipient(ApexPages.StandardController stdController) {
		this.con = stdController;

		this.filter = (EBC_Master_Filter__c)stdController.getRecord();
	}

	public EBC_Master_Filter__c filter {
		get;
		set;
	}
}
