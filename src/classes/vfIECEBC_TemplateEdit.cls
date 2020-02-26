public class vfIECEBC_TemplateEdit extends vfIECEBC_Controller{

	public ApexPages.StandardController con {
		public get;
		private set;
	}

	 public PageReference previous() {

		return Page.IECEBC_TemplateList;
	}

	public vfIECEBC_TemplateEdit(ApexPages.StandardController stdController) {
		this.con = stdController;


	}

}
