public class vfIECEBC_AccountSettings extends vfIECEBC_Controller {
	public String primaryContactMode {
		get {
			if (primaryContactMode == null) primaryContactMode = 'readonly';
			return primaryContactMode;
		}
		set;
	}
	public vfIECEBC_AccountSettings() {}

	public PageReference save() {
		update preferences;
		primaryContactMode = null;

		return null;
	}
}
