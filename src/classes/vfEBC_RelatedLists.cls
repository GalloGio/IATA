public class vfEBC_RelatedLists {
	public vfEBC_RelatedLists(ApexPages.StandardController controller) {}

	public Map<String, Report> reports {
		get {
			if (reports == null) {
				reports = new Map<String, Report>();
				List<Report> rawReports = [Select Id, Name, DeveloperName From Report Where FolderName = 'eBroadcast'];
				for(Report r : rawReports) {
					reports.put(r.DeveloperName, r);
				}
			}
			return reports;
		}
		set;
	}
}
