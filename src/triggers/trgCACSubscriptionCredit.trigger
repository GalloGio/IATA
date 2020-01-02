trigger trgCACSubscriptionCredit on CAC_Subscription_Credit__c (before insert, before update, before delete) {
	if (Trigger.IsInsert || Trigger.IsUpdate)
	for( CAC_Subscription_Credit__c o:Trigger.new)
	{
	 if (CAC_Process.CACCreditProcess==null || CAC_Process.CACCreditProcess==false) { o.addError('No direct action is allowed on the credit, please use the Apply Credit Interface!');}

	}
	if (Trigger.IsDelete)
	for( CAC_Subscription_Credit__c o:Trigger.old)
	{
	 if (CAC_Process.CACCreditProcess==null || CAC_Process.CACCreditProcess==false) { o.addError('No direct action is allowed on the credit, please use the Apply Credit Interface!');}

	}
}
