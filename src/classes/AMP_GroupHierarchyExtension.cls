public with sharing class AMP_GroupHierarchyExtension {

		public LocalGovernance__c lg;
		public Id recordId {get;set;}
		public String JSONHierarchy {get;set;}

	public AMP_GroupHierarchyExtension(ApexPages.StandardController stdController) {
			lg = (LocalGovernance__c)stdController.getRecord();
			recordId = lg.Id;
			System.debug(lg);
			List<LocalGovernance__c> l =  getHierarchy(lg.Id);
			l = reverse(l);
			JSONHierarchy = JSON.serialize(l);
	}

		public List<LocalGovernance__c> reverse(List<LocalGovernance__c> inputList) {
			List<LocalGovernance__c> tmpList = new List<LocalGovernance__c>();
			if(inputList != null) {
				for(Integer i = inputList.size()-1; i >= 0; i--) {
					tmpList.add(inputList[i]);
				}
			}
			return tmpList;
		}

		public List<LocalGovernance__c> getHierarchy(Id lgId) {
			if(lgId == null) return null;
			LocalGovernance__c tmpLg = [SELECT Id, Name, 	Reporting_to__c	FROM LocalGovernance__c	WHERE Id = :lgId];
			List<LocalGovernance__c> lsHierarchy = new List<LocalGovernance__c>();
			System.debug(tmpLg);
			// LocalGovernance__c tmpLg = lg;
			lsHierarchy.add(tmpLg);
			while(tmpLg != null) {
				tmpLg = getParent(tmpLg);
				if(tmpLg != null) lsHierarchy.add(tmpLg);
				System.debug(tmpLg);
			}
			//lsHierarchy = reverse(lsHierarchy);
			return lsHierarchy;
		}

		LocalGovernance__c getParent(LocalGovernance__c child) {
			List<LocalGovernance__c> lsParents = [SELECT Id, Name, Reporting_to__c FROM LocalGovernance__c WHERE Id = :child.Reporting_to__c ];
			if(lsParents.isEmpty()) return null;
			else return lsParents[0];
		}

}
