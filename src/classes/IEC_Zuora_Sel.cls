public class IEC_Zuora_Sel {

	/**
	 * Returns the Zuora Account object
	 * @param setAccountZId Zuora Ids of the Accounts
	 */
	public static Map<String, Zuora.zObject> getAccountsByZId(Set<String> setAccountZId) {
		try {
			if (setAccountZId == null || setAccountZId.isEmpty()) return null;

			List<String> lstWhereCondition = new List<String>();

			for (String sAccountZId : setAccountZId)
			{
				lstWhereCondition.add('Id = \'' + sAccountZId + '\'');
			}

			//List<Zuora.zObject> lstAccount = IECZuoraHelper.queryApiCall('select Id, CRMContactID__c from Account where ' + String.join(lstWhereCondition, ' OR '));
			List<Zuora.zObject> lstAccount = ZuoraUtil.zquery('select Id, CRMContactID__c from Account where ' + String.join(lstWhereCondition, ' OR '),'Account',1);

			Map<String, Zuora.zObject> mapAccountZId_Account = new Map<String, Zuora.zObject>();

			if (lstAccount != null && !lstAccount.isEmpty())
			{
				for (Zuora.zObject acc : lstAccount)
				{
					mapAccountZId_Account.put((String) acc.getValue('Id'), acc);
				}
			}

			return mapAccountZId_Account;
		}
		catch (Exception e) {
			throw new IECApplicationException('Could not retreive Accounts ' + setAccountZId + '. Error: ' + e.getMessage());
		}
	}

	/**
	 * Returns the Zuora Subscription object
	 * @param setSubscriptionZId Zuora Ids of the Subscriptions
	 */
	public static Map<String, Zuora.zObject> getSubscriptionsByZId(Set<String> setSubscriptionZId) {
		try {
			if (setSubscriptionZId == null || setSubscriptionZId.isEmpty()) return null;

			List<String> lstWhereCondition = new List<String>();

			for (String sSubscriptionZId : setSubscriptionZId)
			{
				lstWhereCondition.add('Id = \'' + sSubscriptionZId + '\'');
			}

			//List<Zuora.zObject> lstSubscription = IECZuoraHelper.queryApiCall('select Id, Source__c from Subscription where ' + String.join(lstWhereCondition, ' OR '));
			List<Zuora.zObject> lstSubscription = ZuoraUtil.zquery('select Id, Source__c from Subscription where ' + String.join(lstWhereCondition, ' OR '),'Subscription',1);

			Map<String, Zuora.zObject> mapSubscriptionZId_Subscription = new Map<String, Zuora.zObject>();

			if (lstSubscription != null && !lstSubscription.isEmpty())
			{
				for (Zuora.zObject sub : lstSubscription)
				{
					mapSubscriptionZId_Subscription.put((String) sub.getValue('Id'), sub);
				}
			}

			return mapSubscriptionZId_Subscription;
		}
		catch (Exception e) {
			throw new IECApplicationException('Could not retreive subscriptions' + setSubscriptionZId + '. Error: ' + e.getMessage());
		}
	}

	/**
	 * Returns the Rate Plan records (from Zuora) derived from the Subscription
	 * @param sSubscriptionZId Zuora Id of the Subscription
	 */
	public static List<Zuora.zObject> getRatePlanFromSubscription(String sSubscriptionZId) {
		try {
			if (String.isBlank(sSubscriptionZId)) return null;

			//List<Zuora.zObject> ratePlans = IECZuoraHelper.queryApiCall('select Id, ProductRatePlanId from RatePlan where SubscriptionId = \'' + sSubscriptionZId + '\'');
			List<Zuora.zObject> ratePlans = ZuoraUtil.zquery('select Id, ProductRatePlanId from RatePlan where SubscriptionId = \'' + sSubscriptionZId + '\'', 'RatePlan',1);

			return (ratePlans == null || ratePlans.isEmpty()) ? null : ratePlans;
		}
		catch (Exception e) {
			throw new IECApplicationException('Could not retreive Rate Plans for subscription ' + sSubscriptionZId + '. Error: ' + e.getMessage());
		}
	}

	/**
	 * Returns the Rate Plan charges records (from Zuora) derived from the RatePlans
	 * @param setRatePlanZId Zuora Ids of the Rate Plan
	 */
	public static Map<String, List<Zuora.zObject>> getRatePlanChargeFromRatePlan(Set<String> setRatePlanZId) {
		try {
			if (setRatePlanZId == null || setRatePlanZId.isEmpty()) return null;

			List<String> lstWhereCondition = new List<String>();

			for (String sRatePlanZId : setRatePlanZId)
			{
				lstWhereCondition.add('RatePlanId = \'' + sRatePlanZId + '\'');
			}

			//List<Zuora.zObject> ratePlanCharges = IECZuoraHelper.queryApiCall('select Id, RatePlanId, Price, Quantity, ChargeType from RatePlanCharge where ' + String.join(lstWhereCondition, ' OR '));
			List<Zuora.zObject> ratePlanCharges = ZuoraUtil.zquery('select Id, RatePlanId, Price, Quantity, ChargeType from RatePlanCharge where ' + String.join(lstWhereCondition, ' OR '),'RatePlanCharge',1);

			Map<String, List<Zuora.zObject>> mapRatePlanZId_ZCharge = new Map<String, List<Zuora.zObject>>();

			if (ratePlanCharges != null && !ratePlanCharges.isEmpty())
			{
				for (Zuora.zObject rp : ratePlanCharges)
				{
					if (!mapRatePlanZId_ZCharge.containsKey((String) rp.getValue('RatePlanId')))
						mapRatePlanZId_ZCharge.put((String) rp.getValue('RatePlanId'), new List<Zuora.zObject> {rp});
					else
						mapRatePlanZId_ZCharge.get((String) rp.getValue('RatePlanId')).add(rp);
				}
			}

			return mapRatePlanZId_ZCharge;
		}
		catch (Exception e) {
			throw new IECApplicationException('Could not retreive Rate Plan Charges for rate plans' + setRatePlanZId + '. Error: ' + e.getMessage());
		}
	}
}
