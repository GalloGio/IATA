/**
 * Description: Controller for the component IECGADAgencyDetails: displays agency fields
 * Author: Alexandre McGraw
 * Version: 1.0
 * History:
 *			2014-08-22: creation
 */
public class vfIECGADAgencyDetailsComponent {

	public String sAgencyID {get; set;}
	public String sParentAgencyID {get; set;}
	public GDP_Products_Account_View__c oAgency {
		get {
			return getAgencyByID(sAgencyID);
		}
		private set;
	}
	public GDP_Products_Account_View__c oParentAgency { get; private set; }

	/**
	 * Constructor
	 */
	public vfIECGADAgencyDetailsComponent() {
		oAgency = null;
		oParentAgency = null;
	}

	/**
	 * Query agency by provided ID
	 */
	private GDP_Products_Account_View__c getAgencyByID(String sAgencyID) {

		try {
			if(String.isBlank(sAgencyID))
				throw new IECApplicationException('Agency ID not provided');

			return IECApplicationsManager.getAgencyByID(sAgencyID);
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Query the parent agency to display it in a popup
	 */
	public void loadParentAgency() {
		try {
			if(String.isBlank(sParentAgencyID))
				throw new IECApplicationException('Parent Agency ID not provided');

			oParentAgency = IECApplicationsManager.getAgencyByID(sParentAgencyID);
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
}
