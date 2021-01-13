/*
	* Controller for the IECEBC_AccountUserGuide page (eBroadcast Account User Guide)
	* Initial Author: Sonny Leman
	*
	* Description:
	*  - For a given Billing Account (Zuora__CustomerAccount)/User display the EBC related user guide
	*
	* History:
	*  - 20160816-sl: initial version, based on vfIECEBC_Controller
	*/

public with sharing class vfIECEBC_AccountUserGuide extends vfIECEBC_Controller {


	// ========================================================================
	// constructor
	public vfIECEBC_AccountUserGuide()
	{

	} // vfIECEBC_AccountUserGuide constructor



	// ========================================================================
	// attachment list provides list of related document/user guide
		public List<Attachment> attachmentList{
				get {
						if (attachmentList==null)
						{
								Map<Id,EBC_Setup__c> ebcSetupIdToObjectMap = new Map<Id,EBC_Setup__c>( [select id
																						from EBC_Setup__c]);

								List<Attachment> ebcAttachmentList = [select Id, Name, Description
					from Attachment
					where ParentId in : ebcSetupIdToObjectMap.keyset()
					order by Name, Id
					limit 1000];
								attachmentList = ebcAttachmentList;
						}
						return attachmentList;
				}
				set;
		} // attachmentList

} // end of  vfIECEBC_AccountUserGuide
