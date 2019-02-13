public class ISSP_AMC_Application_And_Changes {

	public List <Case> AMCDraftCases { get; set; }

	public ISSP_AMC_Application_And_Changes(){
		AMCDraftCases = ISSP_AMC_DAO.getOngoingApplicationsChanges();
	}
}