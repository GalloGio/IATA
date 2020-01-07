public class FAResultsCtrl {

		private List<ENZ__FTPAttachment__c> docs;
		public Case cse;


		public FAResultsCtrl(ApexPages.StandardController controller) {

				try{
						this.cse= (Case)controller.getRecord();
						this.cse = [Select id, Status,CaseNumber,Financial_Results_Archived_Date__c from Case where id = :cse.id];
					 }
					 catch(Exception e){
					 String temp = ApexPages.currentPage().getParameters().get('fieldValue');
					 this.cse = [Select id, Status,CaseNumber,Financial_Results_Archived_Date__c from Case where id = :temp];
					 }
		}

		public List<ENZ__FTPAttachment__c> getDocs()
		{
				System.debug('**** Getting New documents');
				docs = [Select Name,ID From ENZ__FTPAttachment__c e where Financial_Assessment_Result__r.Case__c =:cse.id];

				return docs;

		}
		public Case getCse()
		{
				return cse;
		}
		public PageReference refreshDocs() {
		System.debug('****** Refreshing page');
		return null;
		}



}
