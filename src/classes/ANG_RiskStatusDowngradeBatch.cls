public class ANG_RiskStatusDowngradeBatch implements Database.Batchable<SObject>, Database.Stateful
{
	private Set<Id> accounts;

	public ANG_RiskStatusDowngradeBatch(Set<Id> accounts)
	{
		this.accounts = accounts;
	}

	public List<Account> start(Database.BatchableContext BC)
	{
		return ANG_MulticountryHelper.getChildHEAccounts(accounts).values();
	}

	public void execute(Database.BatchableContext BC, List<SObject> scope)
	{
		Map<Id, Id> rhcContacts = new Map<Id, Id>();

		Map<Id, Account> involvedAccounts = new Map<Id, Account>();
		for (Account a : (List<Account>) scope)
			involvedAccounts.put(a.Id, a);

		Map<String, Set<Id>> allRhcContacts = ANG_ISSP_IEPMailRecipientsUtils.getRecipientsPortalServices(
			involvedAccounts.keySet(),
			new Set<String>{ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE});

		for (String accId : allRhcContacts.keySet())
			rhcContacts.put(accId, new List<Id>(allRhcContacts.get(accId))[0]);

		ANG_AccountTriggerHandler handler = new ANG_AccountTriggerHandler();
		handler.newMap = involvedAccounts;
		handler.createVMFROscars(involvedAccounts.values(), rhcContacts);
	}

	public void finish(Database.BatchableContext BC)
	{
	}
}