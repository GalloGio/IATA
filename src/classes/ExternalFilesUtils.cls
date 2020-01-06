public class ExternalFilesUtils implements Queueable{

	public Map<Id,Set<Id>> inUserList;
	public String inPermissionType;

	public ExternalFilesUtils(Map<Id,Set<Id>> inUserList, String inPermissionType)
	{
		this.inUserList = inUserList;
		this.inPermissionType = inPermissionType;
	}

	public void execute(QueueableContext context){
		List<ISSP_External_Report__Share> externalReportShares  = new List<ISSP_External_Report__Share>();
		for(Id inNewReportId : inUserList.keySet()){
			for (Id usId : inUserList.get(inNewReportId))
			{
				// Create a new ISSP_External_Report__Share record to be inserted in to the Job_Share table.
				ISSP_External_Report__Share externalReportShare = new ISSP_External_Report__Share();

				// Populate the ISSP_External_Report__Share record with the ID of the record to be shared.
				externalReportShare.ParentId = inNewReportId;

				// Then, set the ID of user or group being granted access.
				externalReportShare.UserOrGroupId = usId;

				// Specify  the AccessLevel (Edit / Read )
				externalReportShare.AccessLevel = inPermissionType;

				// Add the new Share record to the list of new Share records.
				externalReportShares.add(externalReportShare);
			}
		}
		// Insert all of the newly created Share records and capture save result
		Database.SaveResult[] jobShareInsertResult = Database.insert(externalReportShares,false);
	}
}
