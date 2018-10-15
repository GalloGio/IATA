public with sharing class ANG_MulticountryAccountCreatorController {
    
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

    private Set<String> oscarFields{
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
        
        stdController.addFields(new List<String>(oscarFields));

		oscarId = stdController.getId();
		oscar = (AMS_OSCAR__c)stdController.getRecord();

        listAccount = new list<Account>();

        for(Account acct: [Select Id,Name, Location_Class__c, IATA_ISO_Country__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Location_Type__c, ParentId, Top_Parent__c, Category__c, RecordTypeId, Sector__c from Account where Id = :oscar.Account__c or ParentId = :oscar.Account__c ])
            if(acct.Id == oscar.Account__c)
                mainAccount = acct;
            else
                listAccount.add(acct);
            
        
    }

    public void addAccount(){
        
        Account acc = new Account();
        listAccount.add(acc);
    }

    public PageReference saveAccount() {
        
        For(Account acct : listAccount){

            if(acct.id == null){
                acct.Location_Type__c = 'AE';
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

        return null;
    }

    public void submitHierarchy(){
        oscar.ANG_Hierarchy_Created__c = true;
        update oscar;

        if(!listAccount.isEmpty())
            upsert listAccount;

        closeTab = true;
    }
}
