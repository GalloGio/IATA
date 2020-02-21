/**
* @author Alexandre Jaimes
* @date 2016
* @group CACW
* @description This is an extension to the Vf Page IEC_CACWkey
* This class extends the Controller: vfIEC_CACW
*/
public with sharing class vfIEC_CACWKey {
	/*******************************************************************************************************
	 * @description This is an instance of the Controller
	 */
	private final vfIEC_CACW iecCacWeb;

	/*******************************************************************************************************
	* @description Constructor
	* @param controller This class extends the Controller: vfIEC_CACW
	*/
	public vfIEC_CACWKey(vfIEC_CACW controller) {
		this.iecCacWeb = controller;
	}

	/*******************************************************************************************************
	* @description This getter methods returns the list of available CAC Subscription details
	* It is used by the visualforce page to show the Service Token
	*/
	public list<CAC_Subscription_Detail__c> CAC_SubscriptionDetailList{
		get{
			return [SELECT Id
					,Service_Token__c
					,Service_Specification__r.Name
					,Subscription__r.Name
					//,Actions__c
					//,Max_API_Call_Per_Month__c
					//,Name,Service_Activation_Date__c
					//,Service_Specification__c
					//,Status__c
					//,Subscription__c
					FROM CAC_Subscription_Detail__c
					WHERE Subscription__r.Name =:iecCacWeb.ctrSubsInfo.oSubscription.Name
					AND Status__c = 'Active'];
		}
	}
}
