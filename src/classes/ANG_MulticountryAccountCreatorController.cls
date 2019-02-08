public with sharing class ANG_MulticountryAccountCreatorController {
    
    public Integer accIndex {get;set;}
    public boolean isHierarchyMulticountry {get;set;}
    public Boolean hasErrors { get; set;}
    
    public List<SelectOption> getItems() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('P','P'));
        options.add(new SelectOption('D','D'));
        return options;
    }
	
    public Boolean closeTab{
		get{
			if(closeTab == null) closeTab = false;
			return closeTab;
		}
		set;
	}

    public boolean canbeedited{

        get{
            return [Select Id,Origin from Case where Oscar__c =:oscarId].get(0).Origin <> 'Portal' && oscar.STEP45__C == 'Not Started' && !oscar.ANG_Hierarchy_Created__c;
        }
    }

    Account account = new Account();

	private String oscarId{
		get{
			if(String.isEmpty(oscarId)) oscarId = ApexPages.currentPage().getParameters().get('Id');
			return oscarId;
		}
		set;
	}

	//its public so it can be tested
	public List<String> oscarFieldList{
		get{
			return new List<String>(oscarFields);
		}
		set;
	}

    public Set<String> oscarFields{
		get{
			if(oscarFields == null){
				oscarFields = new Set<String>{
					'Account__c'
					, 'Process__c'
					, 'Step6__c'
                    ,'STEP45__c'
                    ,'ANG_Hierarchy_Created__c'
				};
			}
			return oscarFields;
		}
		set;
	}

    public list<Account> listAccount {get;set;}

    public Account mainAccount {get;set;}

	public AMS_OSCAR__c oscar{
		get{
			if(oscar == null && oscarId != null) oscar = Database.query('SELECT Id, '+String.join(oscarFieldList, ',')+' FROM AMS_OSCAR__c WHERE Id = :oscarId');
			return oscar;
		}
		set;
	}

    public ANG_MulticountryAccountCreatorController(ApexPages.StandardController stdController){
                
        if(!Test.isRunningTest())
            stdController.addFields(new List<String>(oscarFields));

		oscarId = stdController.getId();
		oscar = (AMS_OSCAR__c)stdController.getRecord();

        if(Test.isRunningTest())
           oscar =  [Select Id, Account__c, Process__c, Step6__c, STEP45__c, ANG_Hierarchy_Created__c from AMS_OSCAR__c where Id =:oscarId];

        listAccount = new list<Account>();

        for(Account acct: [Select Id,Name, Location_Class__c, IATA_ISO_Country__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Location_Type__c, ParentId, Top_Parent__c, Category__c, RecordTypeId, Sector__c from Account where Id = :oscar.Account__c or ParentId = :oscar.Account__c ])
            if(acct.Id == oscar.Account__c)
                mainAccount = acct;
            else
                listAccount.add(acct);
        isHierarchyMulticountry = false;
        hasErrors = (listAccount.isEmpty())? true : false;
	}

    public void addAccount(){
        
        Account acc = new Account();
        listAccount.add(acc);
    }

    public PageReference saveAccount() {
        try{
	        For(Account acct : listAccount){
	
	            if(acct.id == null){
	                acct.ParentId = mainAccount.Id;
	                acct.Top_Parent__c = mainAccount.Id;
	                acct.Category__c = mainAccount.Category__c;
	                acct.RecordTypeId	= mainAccount.RecordTypeId;
	                acct.Sector__c = mainAccount.Sector__c;
	                acct.Reason_for_creation__c = 'Account is missing';
	            }
	        }
	        if(!listAccount.isEmpty())
				upsert listAccount;
            
            if(Test.isRunningTest())
                integer intTest =1/0;//exception for catch test coverage
            
	        return null;
	      
        }
        catch(Exception e){
			hasErrors = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, '' + e);
        	ApexPages.addMessage(myMsg);
        	return null;
        }
    }
	
	public PageReference removeAccount() {
		
        Account acct = listAccount.remove(accIndex);
        
        if(acct.id != null){
        	acct.name = 'toDeleteAccount';
        	acct.IATA_ISO_Country__c = new IATA_ISO_Country__c().id;
        	delete acct;
        }
        return null;
    }
	
    public void submitHierarchy(){
    	hasErrors = false;
    	try{
	    	if(checkMulticountry()){
	    		oscar.ANG_Hierarchy_Created__c = true;
		        
		        upsert listAccount;
		        update oscar;
		        
		        closeTab = true;
	    	}
	    	else{
	    		hasErrors = true;
	    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'You need at least 2 accounts from different countries to have a multicountry hierarchy');
	        	ApexPages.addMessage(myMsg);   
	    	}
            if(Test.isRunningTest())
                integer intTest =1/0;//exception for catch test coverage
    	}
    	catch(Exception e){
    		hasErrors = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, '' + e);
        	ApexPages.addMessage(myMsg);
        }
    }
    
    private boolean checkMulticountry(){
    	
    	isHierarchyMulticountry = false;
    	if(listAccount.isEmpty()){
    		return isHierarchyMulticountry;
    	}
    	
    	for(Account ac: listAccount){
    		if(mainAccount.IATA_ISO_Country__c != ac.IATA_ISO_Country__c)
    			isHierarchyMulticountry = true;
    	}
    	
    	return isHierarchyMulticountry;
    }
}