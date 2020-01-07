trigger RequireRejectionComment on Quality__c (before insert, before update)
{
	// copy all selections from the region country concerned multi picklists into the Countries_Exception__c field
	for (Quality__c q : Trigger.new) {
		q.Countries_Exception__c = '';
		String tempStr = (q.Africa_MENA_CC__c != NULL ? q.Africa_MENA_CC__c + ';' : '') +
					(q.Americas_CC__c != NULL ? q.Americas_CC__c + ';' : '')  +
					(q.Asia_Pacific_CC__c != NULL ? q.Asia_Pacific_CC__c + ';' : '') +
					(q.China_North_Asia_CC__c != NULL ? q.China_North_Asia_CC__c + ';' : '') +
					(q.Europe_CC__c != NULL ? q.Europe_CC__c + ';' : '');

		if (tempStr.replace(';','') != '') {
			for (String str : tempStr.split(';')) {
				q.Countries_Exception__c += (q.Countries_Exception__c == '' ? '' : ';') + str;
			}
		}
	}


	if (Trigger.isUpdate) {
		Map<Id, Quality__c> rejectedStatements
							 = new Map<Id, Quality__c>{};

		for(Quality__c inv: trigger.new)
		{
			/*
				Get the old object record, and check if the approval status
				field has been updated to rejected. If so, put it in a map
				so we only have to use 1 SOQL query to do all checks.
			*/
			Quality__c oldInv = System.Trigger.oldMap.get(inv.Id);

			if (oldInv.Approval_Status__c != 'Rejected'
			 && inv.Approval_Status__c == 'Rejected')
			{
				rejectedStatements.put(inv.Id, inv);
			}
		}

		if (!rejectedStatements.isEmpty())
		{
			// UPDATE 2/1/2014: Get the most recent approval process instance for the object.
			// If there are some approvals to be reviewed for approval, then
			// get the most recent process instance for each object.
			List<Id> processInstanceIds = new List<Id>{};

			for (Quality__c invs : [SELECT (SELECT ID
																								FROM ProcessInstances
																								ORDER BY CreatedDate DESC
																								LIMIT 1)
																				FROM Quality__c
																				WHERE ID IN :rejectedStatements.keySet()])
			{
					processInstanceIds.add(invs.ProcessInstances[0].Id);
			}

			// Now that we have the most recent process instances, we can check
			// the most recent process steps for comments.
			for (ProcessInstance pi : [SELECT TargetObjectId,
																		 (SELECT Id, StepStatus, Comments
																			FROM Steps
																			ORDER BY CreatedDate DESC
																			LIMIT 1 )
																 FROM ProcessInstance
																 WHERE Id IN :processInstanceIds
																 ORDER BY CreatedDate DESC])
			{
				if ((pi.Steps[0].Comments == null ||
						 pi.Steps[0].Comments.trim().length() == 0))
				{
					rejectedStatements.get(pi.TargetObjectId).addError(
						'*****Operation Cancelled: Reason for rejection is obligatory if the decision is to reject the exception request.***** ' + '</br>' + 'To return to the approval screen, please use the Back button in your browser');
				}



			}
		}

	}

}
