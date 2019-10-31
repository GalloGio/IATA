/**
  * Description: This class is the VisualForce controller for the component IECTermsAndConditions
  * It accepts a String[] of Product Information IDs as a parameter, then displays the T&Cs related to those products
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
 */
public with sharing class VfIECTermsAndConditionsComponent extends IECComponentControllerBase {

	// component parameters
	public String[] listProductInformationIDs { get; set; }
	public String componentIdToRerender { get; set; }
	
	// member variables
	public List<UITermsAndConditions> lstTnCsToDisplay;
	
	public Boolean hasAcceptedAllTCs { 
		get {
			try {
				if (lstTnCsToDisplay == null)
					return false;
					
				Boolean bAllTnCChecked = true;
				for (UITermsAndConditions tc : lstTnCsToDisplay) {
					bAllTnCChecked &= tc.checked;
				}
				return bAllTnCChecked;
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
				return false;
			}
		}
		private set; 
	}
	
	public List<UITermsAndConditions> listTermsAndConditionsToDisplay { 
		get {
			try {
				if (lstTnCsToDisplay == null)
					lstTnCsToDisplay = getTermsAndConditions();
				return lstTnCsToDisplay;
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
				return null;
			}
		} 
		private set; 
	}
	
	public List<Terms_and_Conditions__c> listTermsAndConditions { 
		get {
			try {
				List<Terms_and_Conditions__c> lstTnC = new List<Terms_and_Conditions__c>();
				if (lstTnCsToDisplay != null) {
					for (UITermsAndConditions uiTnC : lstTnCsToDisplay)
						lstTnC.add(uiTnc.TermsAndConditions);
				}
				return lstTnC;
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
				return null;
			}
		} 
		private set; 
	}
	
	public Boolean hasTermsAndConditions {
		get {
			try {
				return (listTermsAndConditionsToDisplay != null && !listTermsAndConditionsToDisplay.isEmpty());
			}
			catch (Exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
				return false;
			}
		}
		private set;
	}
	
	/**
	 * Constructor
	 */
	public VfIECTermsAndConditionsComponent() {
		try {
			lstTnCsToDisplay = null;
			hasAcceptedAllTCs = false;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
	
	/**
	 * Gets all the T&Cs for the product infos specified as parameter
	 * @return A list of current UITermsAndConditions associated to the product infos
	 */
	private List<UITermsAndConditions> getTermsAndConditions() {
		try {
			List<UITermsAndConditions> listTCToDisplay = new List<UITermsAndConditions>();
			
			if (listProductInformationIDs != null) {
				// for each product information id passed as component parameter
				for (String productInformationID : listProductInformationIDs) {
					Terms_and_Conditions__c oTC = IECProductManager.getCurrentTermsAndConditionForProduct(productInformationID);
					if (oTC != null) {
						listTCToDisplay.add(new UITermsAndConditions(oTC));
					}
				}
			}
			return listTCToDisplay;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}
	
	public void reset() {
		try {
			lstTnCsToDisplay = null;
			List<UITermsAndConditions> lst = this.listTermsAndConditionsToDisplay;
			return;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return;
		}
	}
	
	/**
	 * Inner class to display and capture the acceptance of T&Cs
	 */
	public class UITermsAndConditions {
		
		public Terms_and_Conditions__c TermsAndConditions { get; private set; }
		public Boolean checked { get; set; }

		/**
		 * Constructor
		 */
		public UITermsAndConditions (Terms_and_Conditions__c oTnC) {
			TermsAndConditions = oTnC;
			checked = false;
		}
	}
}