public class AMS_OSCAR_ApprovalHelper
{

	public class ApprovalException extends Exception {}

	public static Map<Id,ProcessInstanceStep> getLastApprovalSteps(Set<Id> objectIds)
	{
		Map<Id,ProcessInstanceStep> processInstanceSteps = new Map<Id,ProcessInstanceStep>();
		for(ProcessInstanceStep pis : [SELECT Id, ProcessInstance.TargetObjectId, ActorId, Comments, CreatedDate FROM ProcessInstanceStep where ProcessInstance.TargetObjectId IN: objectIds order by ProcessInstance.TargetObjectId, CreatedDate DESC]) {
			
			if(processInstanceSteps.containsKey(pis.ProcessInstance.TargetObjectId)) {
				
				ProcessInstanceStep pisAux = processInstanceSteps.get(pis.ProcessInstance.TargetObjectId);
				
				if(pisAux.CreatedDate < pis.CreatedDate) processInstanceSteps.put(pis.ProcessInstance.TargetObjectId, pis);
			}else{
				
				processInstanceSteps.put(pis.ProcessInstance.TargetObjectId, pis);
			}
		}
	
		return processInstanceSteps;
	}

	//return a list of workitemids
	public static List<Id> getAllApprovals(List<Id> objectIds)
	{
		List<Id> workItemIds = new List<Id>();
		for(ProcessInstanceWorkItem pwi : [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :objectIds AND ProcessInstance.Status = 'Pending']) workItemIds.add(pwi.Id);

		return workItemIds;
	}

	//submits a record to approval
	public static void submit(String approvalNameOrId, Id recordId, Id userId, String comments)
	{
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments(comments);
		req.setObjectId(recordId);
		
		// Submit on behalf of a specific submitter
		req.setSubmitterId(userId); 
		
		// Submit the record to specific process and skip the criteria evaluation
		if(String.isNotBlank(approvalNameOrId)) {
			req.setProcessDefinitionNameOrId(approvalNameOrId);
			req.setSkipEntryCriteria(true);        	
		}
		
		// Submit the approval request for the account
		Approval.ProcessResult result = Approval.process(req);
		
		if(!result.isSuccess()) handleError(result);
	}

	//Approve or rejects a single ProcessInstanceWorkItem with comments
	public static void processForObject(String action, Id recordId, Id[] userIds, String comments)
	{
		process(action, getAllApprovals(new List<Id> { recordId })[0], userIds, comments);
	}

	//Approve or rejects a single ProcessInstanceWorkItem with comments
	public static void process(String action, Id workItemId, Id[] userIds, String comments)
	{
		Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		
		if(comments != null) req.setComments(comments);
		if(action != null) req.setAction(action);
		if(userIds != null) req.setNextApproverIds(userIds);
		if(workItemId != null) req.setWorkitemId(workItemId);

		System.debug(loggingLevel.FINE, '____ [cls AMS_OSCAR_ApprovalHelper - process] req - ' + req);
		
		Approval.ProcessResult result =  Approval.process(req, false);

		System.debug(loggingLevel.FINE, '____ [cls AMS_OSCAR_ApprovalHelper - process] result - ' + result);

		if(!result.isSuccess()) handleError(result);
	}

	//Approves all records
	public static void approveAll(Id[] workItemIds, Id[] userIds, String comments)
	{
		for(Id workItemId : workItemIds) process('Approve', workItemId, userIds, comments);
	}

	private static void handleError(Approval.ProcessResult result){
		String msg = '';
		for(Database.Error err : result.getErrors()) msg += '\n'+err.getMessage();
		msg = msg.substring(1);

		//error should be handled by caller class
		throw new ApprovalException(msg);
	}
}