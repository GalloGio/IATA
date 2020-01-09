// *************************************
// Rémi de Jouvencel (sfdc)
// 27/01/2009
// Make sure that there is only one
// active system settings at a time
// *************************************
public class SystemSettingsTriggers
{
	public static boolean isRunning=false;

	public static void InactiveOtherSystemSetttings(System_Settings__c[] aSystem_Settings)
	{
		System_Settings__c curset=aSystem_Settings[0];

		if (!isRunning) // Make sure that we are not triggered by the same trigger
		/// Will only work if only one system settings has changed
			if (aSystem_Settings.size()==1 && curset.Active__c)
			{
				isRunning=true;

				// Set all others to inactive
				System_Settings__c[] otherset = [select Id, Active__c from System_Settings__c where Id <> :curset.Id];
				for (System_Settings__c chng : otherset)
				{
					chng.Active__c = False;
					chng.Status__c = 'Off';
				}
				try
				{
					update otherset;
				}
				catch (DMLException e){curset.addError(e.getDMLMessage(0));}
			}
	}
//****************************************
// T.E.S.T   M.E.T.H.O.D
//****************************************
	public static testMethod void test()
	{
		System_Settings__c s1 = new System_Settings__c(Active__c = true);
		insert s1;
		SystemSettingsTriggers.isRunning = false;
		System_Settings__c s2 = new System_Settings__c(Active__c = true);
		insert s2;
		List<System_Settings__c> listSystemSetting = new List<System_Settings__c>();
		listSystemSetting.add(s1);
		SystemSettingsTriggers.InactiveOtherSystemSetttings(listSystemSetting);


	}
}
