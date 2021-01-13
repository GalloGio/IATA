global class SISHelpDesk_SLAUpdate_Batch implements Database.Batchable<sObject>
{
	global  List<Case> casesToBeUpdate  = new List<Case>();

	global  list<Case> start(Database.BatchableContext BC)
	{
		return casesToBeUpdate;
	}

	//Update the Cases
	global void execute(Database.BatchableContext BC,  List<Case> scope)
	{

		try
		{
			update scope;
		}
		catch(Exception e)
		{
			System.debug('Updating SIS HelpDesk Cases  Error '+ e);
		}

	}

	global void finish(Database.BatchableContext BC)
	{
	}
}
