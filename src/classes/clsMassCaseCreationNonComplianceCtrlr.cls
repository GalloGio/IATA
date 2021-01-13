public with sharing class clsMassCaseCreationNonComplianceCtrlr {

		private Case caseParam = new Case();


		private String soql {get;set;}

		private string subject { get; set; }

	//public Date deadlineDate { get; set; }
	public Boolean isAgentCargoOrCASS { get; private set; }

		public Boolean SelAllIsChecked { get; set; }
		private Integer inPageSize { get; set; }
		private Integer totalNoOfRecs = 0;
		public Integer pageNumber{get;set;}
		public Integer noOfPages{get;set;}
		public Boolean isNbrRecordsDisplayed { get; set; }


		private Map<ID,Boolean> CasesCheckedList = new Map<ID,Boolean>();
		private List<ID> ALLCases;
		private List<cCase> displayList = new List<cCase>() ;



		public List<cCase> Cases{
				get {
						 if (CasesCheckedList != null){
										 for(cCase aCase : displayList){

											if (CasesCheckedList.containsKey(aCase.c.ID))
														aCase.selected = true;
										 }
							}
						return displayList;
				}

				set {Cases= value;}
		}

		public List<SelectOption> getcaseStatusItems()
		{
				List<SelectOption> options = new List<SelectOption>();
				options.add(new SelectOption('Agent Notified (Email)\' or c.Status =\'Agent Notified (Mail)','Agent Notified (Mail) / (Email)')); //added query value here inorder not to mess up the query
				//options.add(new SelectOption('Agent Notified (Email)','Agent Notified (Email)'));
				options.add(new SelectOption('Financial Security Requested','Financial Security Requested'));
				return options;
		}

	 // String[] caseStatus= new String[]{};
	 String caseStatus;

		public String getcaseStatus()
		{
				return caseStatus;
		}
		public void setcaseStatus(String caseStatus)
		{
				this.caseStatus= caseStatus;
		}


		public Case CaseParameter
		{
				get { return caseParam; }
				set;
		}



		// the current sort direction. defaults to asc
		public String sortDir {
				get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
				set;
		}

		// the current field to sort by. defaults to account Name
		public String sortField {
				get  { if (sortField == null) {sortField = 'account.Name'; } return sortField;  }
				set;
		}

		// format the soql for display on the visualforce page
		public String debugSoql {
				get { return soql + ' order by ' + sortField + ' ' + sortDir; }
				set;
		}




		// init the controller and display some sample data when the page loads
		public clsMassCaseCreationNonComplianceCtrlr() {
				inPageSize = 10;

		}

		// toggles the sorting of query from asc<-->desc
		public void toggleSort() {
				// simply toggle the direction
				sortDir = sortDir.equals('asc') ? 'desc' : 'asc';

				// run the query again
				runQuery();
		}


		public void updateNbrSelectedRecords() {
				 refreshCheckMap();
				// trigger the count of selected records
				Integer i = nbrSelectedRecords;
		}


		public PageReference SelectAll() {
					try{
				//select displayed contacts
				for (cCase aCase: displayList){
								aCase.selected = SelAllIsChecked;
					 }

				//select all contacts and add them to list
					for(Id id: AllCases)
						{
								if (SelAllIsChecked)
										CasesCheckedList.put(id,true);
								else
										{
											if(CasesCheckedList.containsKey(id))
												CasesCheckedList.remove(id);
										}
						}

					 refreshCheckMap();
			 }
			catch(Exception e){}
					 return null;
		}

		public void refreshCheckMap()
		{
			for(cCase aCase: displayList)
				{

						if(aCase.selected)
						{
								CasesCheckedList.put(aCase.c.Id,true);
						}
						else
						{
							 if(CasesCheckedList.containsKey(aCase.c.Id))
										CasesCheckedList.remove(aCase.c.Id);
						}
				}
		 }



			public Boolean isAllFilterFieldsFilled()
		 {

			 if (CaseParameter.Deadline_Date__c==null ||CaseParameter.BatchNumber__c==null )
							return true;

					return false;
		 }



		 public void runSearch(){

		 //validation
		 if (isAllFilterFieldsFilled())
				 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill all fliter criteria before searching'));

			else
			{

				 String batchNumber = CaseParameter.BatchNumber__c;
				 String status = caseStatus;
				 Date deadline = CaseParameter.Deadline_Date__c;

					 soql = 'Select c.CaseNumber,c.Status,c.ID, Account.Name, Account.IATACode__c, Account.Status__c, Account.Type,Account.Location_Type__c,Account.BillingCountry,Contact.Name, Contact.Email  FROM Case c  where c.BatchNumber__c = \''+batchNumber+'\'  and ( c.Status = \''+status+'\')';

						if(status == 'Financial Security Requested')
							 soql+= ' and c.FS_Deadline_Date__c =' + String.valueOf(deadline);
						else
							 soql+= ' and c.Deadline_Date__c =' +String.valueOf(deadline);


					 runQuery();

			}

		 }



		 // runs the actual query
		private void runQuery() {

				pageNumber = 0;
				isNbrRecordsDisplayed = true;
				AllCases = new List<Id>();
				CasesCheckedList = new Map<ID,Boolean>();
				displayList = new List<cCase>();
				SelAllIsChecked = false;
				String q;

				try {

						system.debug('Query to be executed: ' + soql + ' order by ' + sortField + ' ' + sortDir);

					 //get all cases and store them in AllCases list
						 for (Case ca: Database.query(soql + ' order by ' + sortField + ' ' + sortDir )){
										ALLCases.add(ca.Id);
						 }

						system.debug('ALL contacts Size = '+ AllCases.size());

						//initial display list first 10 items
						 String extraQuery = '';
						 Integer num = inPageSize ;
						 if (num>AllCases.size())
								 num = AllCases.size();

					 if (AllCases.size()>0)
					 {
								extraQuery = ' and (';
								for (Integer i = 0 ; i<num ; i++)
								{
										if (i== 0)
												extraQuery += ' Case.ID = \''+AllCases[i]+'\'';

										extraQuery += ' or Case.ID = \''+AllCases[i]+'\'';
								}
								 extraQuery +=  ' )';

								 // check the agent type of the first case in the list
						 	 Case c = [Select c.Account.Type from Case c where c.Id =:AllCases.get(0) limit 1];
								isAgentCargoOrCASS = (c != null && (c.Account.Type == 'IATA Cargo Agent' || c.Account.Type == 'CASS Associate'));
					 }

						q = soql + extraQuery +' order by ' + sortField + ' ' + sortDir;
						system.debug('Query to be executed::: ' + q );

						 for (Case cont : Database.query(q)){
							 displayList.add(new cCase(cont));
						 }

						totalNoOfRecs  = AllCases.size();

						if (totalNoOfRecs==0)
							{
									ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No cases Found, please change your search criterias'));
							}


				}
				catch (Exception e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unhandled error '+e));
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Query '+soql));
				}
		}


	 //create cases here
	 public void createCases()
	 {

				String Subject = CaseParameter.Subject;
				String Description = CaseParameter.Description;

			 if(Subject==''||Description==''||(isAgentCargoOrCASS && CaseParameter.New_IFAP_Deadline_date__c==null))
					 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill the required fields.'));

			 else
				 {

					//to make sure the back end and UI are in sync
					refreshCheckMap();

					 Set <ID> selectedID = new Set<ID>();
					 selectedID = casesCheckedList.KeySet();


						if (selectedID.size() == 0) {
							ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no selected cases.'));
						 }
						else{

							 List<Case> cases = [Select c.CaseNumber,c.ID,c.Status, Account.Name,c.AccountID,c.ContactID,c.Account.BillingCountry, Account.IATACode__c,Contact.Name, c.Account.Type,
							 Contact.Email,c.firstFSnonComplianceDate__c ,c.firstFAnonComplianceDate__c,c.secondFSnonComplianceDate__c,c.secondFAnonComplianceDate__c, c.SCF_Reason_IFAP__c
							 From Case c Where c.Id IN :selectedID];

							 clsMassCaseCreationNonComplianceBatch cBatch = new clsMassCaseCreationNonComplianceBatch();
							 cBatch.caseList = cases;
							 cBatch.Subject = Subject;
							 cBatch.Description = Description;
							 cBatch.Deadline = CaseParameter.New_IFAP_Deadline_date__c;
							 //29 Jan 2013. A temporarily fix for SOQL limit. The Batch size is reduced from 5 to 3 to prevent SOQL limit.
							 //ID batchprocessid = Database.executeBatch(cBatch,5);
							 ID batchprocessid = Database.executeBatch(cBatch,3);

								String extramsg = 'The cases are being created now. Please note that it may take time for all the batch to be completed.' ;

								ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, extramsg));
					}
		 }

 }


	 // returns true if the "First" link must be displayed
		public Boolean hasFirst {
				get {
						return (pageNumber!=0);
				}
		}

		// returns true if the "Last" link must be displayed
		public Boolean hasLast {
				get {
				if (totalPage == 1)
								return false;
						return (pageNumber+1 != totalPage);
				}
		}

		// indicates whether there are more records after the current page set.
		public Boolean hasNext {
				get {
						return (pageNumber+1<totalPage);
				}
		}

		// indicates whether there are more records before the current page set.
		public Boolean hasPrevious {
				get {
						return (pageNumber>0);
					}
		}


		 public PageReference first(){
				pageNumber = 0;
				queryCases();
				return null;
		}

		 public PageReference last(){
				pageNumber = totalPage - 1;
				queryCases();
				return null;
		}

		public PageReference next(){
				pageNumber++;
				queryCases();
				return null;
		}

		public PageReference previous(){
				pageNumber--;
				if (pageNumber < 0){
						pageNumber = 0;
				}
				queryCases();
				return null;
		}


 //triggered on next,prev, last and first actions
 private void queryCases()
		{

				refreshCheckMap();
				System.debug('query accounts');
				displayList = new List<cCase>();
				SelAllIsChecked = false;
				Integer offset = pageNumber * inPageSize ;
				System.debug('offset ' + offset );


					 String extraQuery = '';
					 if (AllCases.size()>0)
					 {
								extraQuery = ' and (';
								Integer k = offset+inPageSize;
								if (k>AllCases.size())
								 k = AllCases.size();

								for (Integer i = offset ; i<k ; i++)
								{
										if (i== offset)
												extraQuery += ' Case.ID = \''+AllCases[i]+'\'';

										extraQuery += ' or Case.ID = \''+AllCases[i]+'\'';
								}
								extraQuery +=  ' )';
					 }

						 System.debug('Query is '+ soql + extraQuery +' order by ' + sortField + ' ' + sortDir);

						 for (Case cas : Database.query(soql + extraQuery +' order by ' + sortField + ' ' + sortDir )){
							 displayList.add(new cCase(cas));
						}

		}



		// returns the number of selected records
		public Integer nbrSelectedRecords {
				get {
								return CasesCheckedList.size();
						}
		}

	 public Integer nbrFoundRecords {
				get {
						 return totalNoOfRecs;
				}
				set{
						nbrFoundRecords = value;
				}
		}

		public Integer currentPage {
				get {
						return  (pageNumber+1);
				}
				set{
						currentPage = value;
				}
		}

		 public Integer totalPage {
				get {

							Decimal d = totalNoOfRecs;
							Decimal dd = d.divide(inPageSize, 2, System.RoundingMode.CEILING);

						 Long i = dd.round(roundingMode.UP);

						 if (i==0)
								 i++;

						 return  (Integer)i;
				}
		}


			 public class cCase {
				public Case c {get; set;}
				public boolean selected {get; set;}


				//This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
				public cCase(Case ca) {
						c = ca;
						selected = false;
				}
		}

}
