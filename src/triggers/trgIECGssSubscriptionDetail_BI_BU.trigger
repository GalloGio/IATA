/* trgIECGssSubscriptionDetail_BI_BU: trigger on GSS_Subscription_Detail__c before upsert.
 *  - field initialization: Calendar_Next_Submission_Date__c
 *
 * Author: Sonny Leman
 * Change log:
 *  20160209-sl: initial version
 *
 */

trigger trgIECGssSubscriptionDetail_BI_BU on GSS_Subscription_Detail__c (before insert, before update) {
	trgHndlrIECGssSubscriptionDetail.onUpsertGssSubscriptionDetail(trigger.New);
} // end of trigger
