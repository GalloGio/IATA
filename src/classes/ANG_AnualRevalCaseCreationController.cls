public without sharing class ANG_AnualRevalCaseCreationController {

        public string region{get; private set;}
        public string mode{get; private set;}
        public String country{get;private set;}
		public String year{get; private set;}

        public List<String> countriesLst{get; set;}
        public Account account{get; set;}
		public boolean shouldDisableButton;
		public List<Account> accountsToCreate{get; set;}
		public Set<Id> accountsWithOscars{get;set;}
		public Map<Id,Id> caseOscars{get;set;}

		public boolean batchStatusBool{get;set;}
		public Id batchId {get;set;}
		public AsyncApexJob batchJob{get;set;}
		public boolean pollerBool{get;set;}
		public Integer getBatchStatus{get;set;}

		private final Set<String> invalidOscarStatus = new Set<String>{'Closed (Closed)','Closed (Closed)','Closed','Closed_ Not Accepted','Closed_Rejected','Closed_Withdrawn'};

        public ANG_AnualRevalCaseCreationController() {
		
			countriesLst = new List<String>();
			account = new Account();
			accountsToCreate = new List<Account>();
			accountsWithOscars = new Set<Id>();
			caseOscars = new Map<Id,Id>();
			batchStatusBool = false;
			getBatchStatus = 0;

		}

		public void setcountry(String value){
			if(country != value)
				accountsToCreate = new List<Account>();
			country = value;
		}

		public void setregion(String value){
			if(region != value)
				accountsToCreate = new List<Account>();
			region = value;
		}

		public void setmode(String value){
			if(mode != value)
				accountsToCreate = new List<Account>();
			mode = value;
		}

		public void setyear(String value){
			if(year != value)
				accountsToCreate = new List<Account>();
			year = value;
		}

	    public list<selectoption> getregionobj(){

                list<selectoption> options= new list<selectoption>();

                options.add(new selectoption('Select Region', 'Select Region'));

                options.add(new selectoption('Africa & Middle East','Africa & Middle East'));
                options.add(new selectoption('Americas','Americas'));
                options.add(new selectoption('Asia & Pacific','Asia & Pacific'));
                options.add(new selectoption('China & North Asia','China & North Asia'));
                options.add(new selectoption('Europe','Europe'));

                return options;

        }

	    public list<selectoption> getmodeObj(){

                list<selectoption> options= new list<selectoption>();

                options.add(new selectoption('Select Mode', 'Select Mode'));

                options.add(new selectoption('Financial year end','Financial year end'));
                options.add(new selectoption('Country','Country'));
                options.add(new selectoption('IATA Code','IATA Code'));

                return options;

        }

            public list<selectoption> getyearobj(){

                list<selectoption> options= new list<selectoption>();

				options.add(new selectoption('Please Select a Month','Please Select a Month'));
				options.add(new selectoption('January','January'));
				options.add(new selectoption('February','February'));
				options.add(new selectoption('March','March'));
				options.add(new selectoption('April','April'));
				options.add(new selectoption('May','May'));
				options.add(new selectoption('June','June'));
				options.add(new selectoption('July','July'));
				options.add(new selectoption('August','August'));
				options.add(new selectoption('September','September'));
				options.add(new selectoption('October','October'));
				options.add(new selectoption('November','November'));
				options.add(new selectoption('December','December'));

                return options;

        }

    	public list<selectoption> getcountryobj(){

                list<selectoption> options= new list<selectoption>();

                list<IATA_ISO_Country__c> contr= [select Id, Name  from IATA_ISO_Country__c where Region__c = :region];

                if(contr.isEmpty()){
                    options.add(new selectoption('Select Country', 'Select Country'));
                    countriesLst.clear();
                    
                }
                for( IATA_ISO_Country__c c:contr){

                        options.add(new selectoption(c.Id,c.name));
                }

                return options;

        }

		public boolean getshouldDisableButton(){
        	
        	boolean value = false;

            if(region == 'Select Region' || mode == 'Select Mode' || region == null || mode == null)
            	value = true;

            if(mode == 'Financial year end' && (year == null || year == '' || year == 'Please Select a Month'))
            	value =  true;

            return value;
        }

        public void searchAgencies(){

        	System.debug('Running for Financial year end with value:'+ year);
        	System.debug('Running for Country with value:'+ country);
        	System.debug('Running for IATA Code with value:'+ account.IATACode__c);

        	if(mode == 'Financial year end')
				accountsToCreate = [Select Id , (select id,name from OSCARs__r where Process__c = 'ANG.ANNUAL.REVALIDATION' AND STATUS__c NOT IN :invalidOscarStatus LIMIT 1), IATACode__c, Name, RecordType.Name, Status__c, Location_Class__c, Location_Type__c, IATA_ISO_Country__r.Region__c, IATA_ISO_Country__r.Name, Financial_Year_End__c from Account where Location_Type__c = 'HE' and Status__c NOT IN (null, 'Terminated', 'Listed', 'Not in operation', 'Not accreditated') and RecordType.Name = 'Agency' and IATA_ISO_Country__r.Region__c = :region and Financial_Year_End__c = :year];
			else if(mode == 'Country')
				accountsToCreate = [Select Id , (select id,name from OSCARs__r where Process__c = 'ANG.ANNUAL.REVALIDATION' AND STATUS__c NOT IN :invalidOscarStatus  LIMIT 1), IATACode__c, Name, RecordType.Name, Status__c, Location_Class__c, Location_Type__c, IATA_ISO_Country__r.Region__c, IATA_ISO_Country__r.Name, Financial_Year_End__c  from Account where Location_Type__c = 'HE' and Status__c NOT IN (null, 'Terminated', 'Listed', 'Not in operation', 'Not accreditated') and RecordType.Name = 'Agency' and IATA_ISO_Country__r.Region__c = :region and IATA_ISO_Country__c = :Country];
			else if(mode == 'IATA Code')
				accountsToCreate = [Select Id , (select id,name from OSCARs__r where Process__c = 'ANG.ANNUAL.REVALIDATION' AND STATUS__c NOT IN :invalidOscarStatus  LIMIT 1), IATACode__c, Name, RecordType.Name, Status__c, Location_Class__c, Location_Type__c, IATA_ISO_Country__r.Region__c, IATA_ISO_Country__r.Name, Financial_Year_End__c  from Account where Location_Type__c = 'HE' and Status__c NOT IN (null, 'Terminated', 'Listed', 'Not in operation', 'Not accreditated') and RecordType.Name = 'Agency' and IATACode__c = :account.IATACode__c];
			
			Set<Id> oscarsId = new Set<Id>();

			for(Account act:accountsToCreate){
				if(!act.Oscars__r.isEmpty()){
					oscarsId.add(act.Oscars__r.get(0).Id);
				}
			}

			for(Case c: [Select Id, OSCAR__c from Case where OSCAR__c in: oscarsId]){
				caseOscars.put(c.OSCAR__c,c.Id);
			}
        }

        public void launchCampaign(){

			Set<Id> accountsToCreateIds = new Set<Id>();

			For(Account acct: accountsToCreate){

				if(acct.Oscars__r.isEmpty())
					accountsToCreateIds.add(acct.Id);

			}

			system.debug('accountsToCreateIds is ' + accountsToCreateIds);

			if(!accountsToCreateIds.isEmpty()){

				System.debug('Running batch !');

				batchStatusBool = true;
				pollerBool = true;

				ANG_AnualRevalCaseCreationBatch aRCCbatch = new ANG_AnualRevalCaseCreationBatch(accountsToCreateIds); 
				batchId = Database.executeBatch(aRCCbatch,1);
			}

        }

	public void getBatchStatus(){
		
        if(batchId == null){
            pollerBool = true;
            return;
        }
        
		batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchId];

		if(batchJob.status == 'Ended' || batchJob.status == 'Completed')
			pollerBool = false;
		else
			pollerBool = true;

		getBatchStatus++;

	}
}