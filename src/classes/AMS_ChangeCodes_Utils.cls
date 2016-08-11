public with sharing class AMS_ChangeCodes_Utils {
	
	/** 
	 Wrapper Object for Change Codes
	*/
	public class ChangeCodeStruct {

    private Agency_Applied_Change_code__c changeCode {get; set;}
    private Account acct {get; set;}
    private List<AMS_Agency_A_Change_code_History__c> changeCodeFielsHistory {get; set;}

	    public ChangeCodeStruct(Agency_Applied_Change_code__c changeCode, Account acct, List<AMS_Agency_A_Change_code_History__c> changeCodeFielsHistory) {

    	    this.changeCode = changeCode;
    	    this.acct = acct;
    	    this.changeCodeFielsHistory = changeCodeFielsHistory;
		}

	}

	/** 
	 Wrapper Object for Tracking the fiels changed for each object
	*/
	
	public class ObjectChange {
		
		public String objectAPI{get;set;}
        public String fieldAPI{get;set;}
        public String oldValue{get;set;}
        public String newValue{get;set;}
        
        public ObjectChange(String objectAPI,String fieldAPI, String oldValue, String newValue){

            this.objectAPI = objectAPI;
            this.fieldAPI = fieldAPI;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }

    }


    /** 
	 Struct Class for Saving all the changes
	*/
	
	public class ObjectChangesStruct {

        public List<ObjectChange> changes{get;set;}

        public ObjectChangesStruct(List<ObjectChange> changes){

            this.changes = changes;

        }

    }


    /** 
	     convertAccountToObjectChanges
	*/

	public static List<ObjectChangesStruct> convertAccountToObjectChanges(List<AMS_AccountTriggerHandler.AccountChangesStruct> accountChanges)
	{
		List<ObjectChangesStruct> objChangesStructList = new List<ObjectChangesStruct>();

		for (AMS_AccountTriggerHandler.AccountChangesStruct accountChange : accountChanges)
		{
			
			List <ObjectChange> ObjectChangeList = new List <ObjectChange> ();

			for(AMS_RecordCreatorWebservice.AccountChanges changes : accountChange.changes){

				ObjectChange objChange = new ObjectChange('Account',changes.accountFieldAPI, changes.oldValue, changes.newValue);
				ObjectChangeList.add(objChange);

			}

			objChangesStructList.add(new ObjectChangesStruct(ObjectChangeList));

		}

		return objChangesStructList;
	}




    /** 

	 Create Change Codes

	*/

	public static void createAAChangeCodes(List<ObjectChangesStruct> objectChanges, List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts) {

        Map<Account, Boolean> accountsChecker = new Map<Account, Boolean>();

        Integer index = 0;

        Set<Account> accountsToUpdate = new Set<Account>();

        List<Agency_Applied_Change_code__c> aaccToInsert = new List<Agency_Applied_Change_code__c>();
		
		List<list<AMS_Agency_A_Change_code_History__c>> aaccHistoryToProcess = new List <List <AMS_Agency_A_Change_code_History__c>>();

        for (AMS_OSCAR_JSON.ChangeCode cc : changeCodes) {

            Boolean isActive = false;

            if (!accountsChecker.containsKey(oscarAgencies.get(index))) {
                accountsChecker.put(oscarAgencies.get(index), false);
                isActive = true;
            }

            ChangeCodeStruct changeCodeResult = createAAChangeCode(objectChanges.get(index),cc, oscars.get(index), oscarAgencies.get(index), isActive);

            aaccToInsert.add(changeCodeResult.changeCode);
            aaccHistoryToProcess.add(changeCodeResult.changeCodeFielsHistory);

            if (changeCodeResult.acct != null && !accountsToUpdate.contains(changeCodeResult.acct))
                accountsToUpdate.add(changeCodeResult.acct);

            index++;

        }

        if (!accountsToUpdate.isEmpty() && (!Trigger.isExecuting || isToUpdateAccounts)) {
            System.debug('The list of Accounts to update is ' + accountsToUpdate.size());
            update new List<Account>(accountsToUpdate);
        }

        if (!aaccToInsert.isEmpty()) {

            System.debug('The list of Change Codes to add is ' + aaccToInsert.size());

            insert aaccToInsert;
        }

        Integer index2 = 0;

        
        // Add the IDs of the Change Codes after they are inserted

        list<AMS_Agency_A_Change_code_History__c> aaccHistoryToInsert = new List <AMS_Agency_A_Change_code_History__c>();

         
        if(!aaccHistoryToProcess.isEmpty())
	       	{for (Agency_Applied_Change_code__c aaccCreated : aaccToInsert){

		      	for (AMS_Agency_A_Change_code_History__c aaccHist : aaccHistoryToProcess.get(index2))
		      	{
		      		//Add Agency_Applied_Change_Code__c IDs to AMS_Agency_A_Change_code_History__c
		      		
		      		aaccHist.Agency_Applied_Change_Code__c = aaccCreated.id;
		      		aaccHistoryToInsert.add(aaccHist);
		      	}


	       		index2++;
	       	}
		}

        if (!aaccHistoryToInsert.isEmpty()) {

            System.debug('The list of Change Codes History to add is ' + aaccHistoryToInsert.size());

            insert aaccHistoryToInsert;
        }
    }

    /** 
	 Add Change Code to be Created
	*/

    private static ChangeCodeStruct createAAChangeCode(ObjectChangesStruct objectChangesByChangeCode, AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive) {

        Account toReturn = null;

        Id oscarId = null;

        if (oscar != null)
            oscarId = oscar.Id;

        System.debug('Creating a new Agency Applied Change Code for Account ' + oscarAgency.Id + ' with flag active set to ' + isActive);

        Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(Active__c = isActive, Account__c = oscarAgency.Id, Change_Code__c = changeCode.name,
                OSCAR__c = oscarId, Bulletin_Information__c = changeCode.memoText,
                Reason_Code__c = changeCode.reasonCode, Reason_Description__c = changeCode.reasonDesc);

        //insert aacNEW;

		List<AMS_Agency_A_Change_code_History__c> changeCodeFielsHistory = new List <AMS_Agency_A_Change_code_History__c>();

        for (ObjectChange change : objectChangesByChangeCode.changes){

        	system.debug('aacNEW.id : ' + aacNEW.id);
        	system.debug('change.objectAPI : ' + change.objectAPI);
        	system.debug('change.fieldAPI  : ' + change.fieldAPI );
			system.debug('change.newValue: ' + change.newValue);                	
			system.debug('change.oldValue: ' + change.oldValue);

        	AMS_Agency_A_Change_code_History__c aacNEWHistory = 
				        	new AMS_Agency_A_Change_code_History__c(
													Agency_Applied_Change_Code__c = null 			    , //ID will be added after the Insert
													Object_API_Name__c 			  = change.objectAPI 	,
													Field_API_Name__c             = change.fieldAPI     ,
													Field_New_Value__c			  = change.newValue	   	,
													Field_Old_Value__c			  = change.oldValue		);


        	changeCodeFielsHistory.add(aacNEWHistory);
        }


        //update Agency Status
        String newVal = AMS_Utils.getIATAReadableStatus(changeCode.status);


        System.debug('Change code status is ' + changeCode.status);
        System.debug('Account status is ' + oscarAgency.Status__c);
        System.debug('New val is ' + newVal);


        if (newVal <> oscarAgency.Status__c && newVal != null) {

            oscarAgency.Status__c = newVal;
            toReturn = oscarAgency;
        }

        return new ChangeCodeStruct(aacNEW, toReturn,changeCodeFielsHistory);
    }
}