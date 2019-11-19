public without sharing class WorkflowHelper {

	public static final String ACCOUNT_TYPE = 'Account';
	public static final String CONTACT_TYPE = 'Contact';
	public static final String CASE_TYPE = 'Case';

	private static final ID AIRLINERT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
	private  static final ID GSART = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_GSA');
	private  static final Id STANDARDRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
	private  static final Id AIRLINEBRRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;

	//Case Record Types
	private static final ID DPCSYSTEMRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request');
	private static final ID DPCSYSTEMSLOCKEDRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_DPC_Systems_locked');
	private static final ID INTERNALCASESRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');
	private static final ID OPERATIONALMANAGEMENTHORT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Case_Operational_Management_Head_Office');

	private static Set<String> accountTypes = new Set<String>{'GSA General Sales Agent','IATA Passenger Sales Agent','SSI','TIDS Agent','ERSP Agent','Domestic Agent','Associations','Handling Agent','NISI','Airline Point of Sale','MSO Member Sales Office'};

	private static Map<Id,List<Account>> accountsToSearchParents = new Map<Id,List<Account>>();

	public static void performActions(String objectType){
		
		switch on objectType { 
			when 'Account' {
				System.debug('[WorkflowHelper]: starting to process work for:'+objectType); 
				performActionsAccount();
				System.debug('[WorkflowHelper]: ended process work for:'+objectType); 
			}
			when 'Case' {
				System.debug('[WorkflowHelper]: starting to process work for:'+objectType); 
				performActionsCase();
				System.debug('[WorkflowHelper]: ended process work for:'+objectType); 
			}
			when else{
				System.debug(LoggingLevel.ERROR,'[WorkflowHelper]: object was not identified so no job to perform here:'+objectType); 
			}
		}
		
	}

	public static void performActionsAccount(){

		// runs on both Update and Insert

		Map<Id,sObject> oldMap = trigger.oldMap;
		List<sObject> newMap = trigger.new;

		Account oldAcct;
		Account newAcct;

		for(sObject acct: newMap){
			
			newAcct = (Account)acct;
			oldAcct = oldMap == null ? null : oldMap.get(acct.Id) == null ? null : (Account)oldMap.get(acct.Id);

			updateIndustryFieldFromAIMS(newAcct);
			updateAirlineMembership(newAcct);
			updateLastModifiedDateByIntegrations(newAcct);
			updateWebstarAccountCategory(newAcct);
			updateAIMSAccountRecordtype(newAcct);
			resetAccountIdCardDiscount(newAcct);
			resetAccountType(newAcct);
			restoreAccountType(newAcct);
			setAccountSite(newAcct);
			setAccountBranchNamePre(newAcct);
			setACLIAccountName(oldAcct,newAcct);

			if(Trigger.isUpdate){
				setDataQualityHistory(oldAcct,newAcct);
				setAccountDDSUpdateDate(oldAcct,newAcct);
			}
		}

		if(!accountsToSearchParents.isEmpty()){
			setAccountBranchNamePos((List<Account>) newMap, oldMap <> null);
		}
	}

	public static void performActionsCase(){

		// runs on both Update and Insert

		Map<Id,sObject> oldMap = trigger.oldMap;
		List<sObject> newMap = trigger.new;

		Case oldCase;
		Case newCase;

		for(sObject cse: newMap){
			
			newCase = (Case)cse;
			oldCase = oldMap == null ? null : oldMap.get(cse.Id) == null ? null : (Case)oldMap.get(cse.Id);

			if(Trigger.isInsert){
				changeCaseOriginToFax(newCase);
				updateRecordTypeToLocked(newCase);
				updateRTExternalInternal(newCase);
			}

			updateACCADatetimeCaseEscalated(oldCase, newCase);
			updateACCADatetimeCaseScheduled(oldCase, newCase);
			updateACCADatetimeCaseCompleted(oldCase, newCase);
			uncheckNewCommentforACCA(oldCase, newCase);
			updateStatusToEscalated(oldCase, newCase);
			updateDPCStatus(oldCase, newCase);
			updateCSRScheduled(oldCase, newCase);
		}
	}

	//Updates the field Industry in the travel agent accounts that are uploaded from AIMS
	//Workflow Name: AIMS: Update Industry - travel agents
	public static void updateIndustryFieldFromAIMS(Account newAccount){ 

		if(newAccount.Is_AIMS_Account__c && newAccount.Industry <> 'Travel Agent' && accountTypes.contains(newAccount.type)){
			newAccount.Industry = 'Travel Agent';
		}

	}
	//Updates IATA_Member__c field if Parent has IATA_Member__c field set to true
	//Workflow Name: Parent account IS member airline
	public static void updateAirlineMembership(Account newAccount){
		if(!newAccount.Is_parent_IATA_airline_member__c){
			newAccount.IATA_Member__c = !newAccount.IATA_Member__c;
		}
	}

	//Updates Last_Modified_by_Source__c field if LastModifiedById is System Integrations User
	//Workflow Name: AIMS: Update Last Modified By Source
	public static void updateLastModifiedDateByIntegrations(Account newAccount){

		if(UserInfo.getName() == 'System Integrations'){
			newAccount.Last_Modified_by_Source__c = System.now();
		}
	}

	//Updates the Account category when the Source System is webstar, the record type is Agency and has no Category
	//Workflow Name:AMS Webstar set sector and category	
	public static void updateWebstarAccountCategory(Account newAccount){

		if( newAccount.Source_System__c == 'Webstar' && 
			newAccount.Category__c == null &&
			newAccount.recordtypeId == AMS_Utils.RECTYPE_IATAAGENCY
			){

			newAccount.Sector__c = 'Travel Agent';
			newAccount.Category__c = 'IATAN Passenger agent';
		}
	}

	//Assign "Agency" as Record Type when an AIMS Account is created
	//Workflow Name:AIMS Accounts RT Assignment Rule
	public static void updateAIMSAccountRecordtype(Account newAccount){

		If( newAccount.Is_AIMS_Account__c && 
			newAccount.recordtypeId == standardRT){

			newAccount.recordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		}
	}
	//Assign 0% discount when Account is not Id Card key Account
	//Workflow Name:Reset ID Card Discount
	public static void resetAccountIdCardDiscount(Account newAccount){

		if(!newAccount.IDCard_Key_Account__c){
			newAccount.ID_Card_Key_Account_Discount__c = 0;
		}
	}


	//Reset Account type when meets the criteria
	//Workflow Name:Clear Account Type when the field is applicable
	public static void resetAccountType(Account newAccount){

		if(newAccount.RecordTypeId == airLineRT &&
			newAccount.Sector__c == 'Airline' &&
			newAccount.Membership_status__c <> 'IATA member' &&
			newAccount.ACLI_Status__c == 'Active Company' &&
			newAccount.Account_Type__c == 'Not Applicable'
		){
			newAccount.Account_Type__c = null;
		}
	}

	//Update Account Type field to 'Not Applicable' when the field should not be filled
	//Workflow Name:Set Account Type when Not Applicable	
	public static void restoreAccountType(Account newAccount){

		if(newAccount.RecordTypeId == airLineRT &&
		  !(newAccount.Sector__c == 'Airline' &&
			newAccount.Membership_status__c <> 'IATA member' &&
			newAccount.ACLI_Status__c == 'Active Company'
			)
		){
			newAccount.Account_Type__c = 'Not Applicable';
		}
	}

	//Update account site if the account Record Type is Airline Branch or Airline Headquarters
	//Workflow Name:Account site update	
	public static void setAccountSite(Account newAccount){

		Set<Id> accountRecordTypes = new Set<Id>{AMS_Utils.RECTYPE_AIRLINE_BR,airLineRT,gsaRT};

		if(accountRecordTypes.contains(newAccount.RecordTypeId) || 
		(newAccount.recordTypeId == standardRT && newAccount.Sector__c == 'Airline')
		){            
			if(newAccount.Industry == 'Travel Agent'){
				return;
			}
			
			if(newAccount.IATACode__c == null){
				if(newAccount.Airline_Prefix__c == null){
					newAccount.site = newAccount.Airline_designator__c + ' ' + newAccount.Country_ISO_Code__c;
				}
				else {
					newAccount.site = newAccount.Airline_designator__c + ' ' + newAccount.Airline_Prefix__c + ' ' + newAccount.Country_ISO_Code__c;
				}
			}else{
				newAccount.site = newAccount.Airline_designator__c + ' ' + newAccount.IATACode__c + ' ' + newAccount.Country_ISO_Code__c;
			}
		}
	}

	//Update account Historize the data quality feedback comment
	//Workflow Name:Data quality comment history
	public static void setDataQualityHistory(Account oldAccount , Account newAccount){
		
		if(oldAccount.Comment_data_quality_feedback__c <> newAccount.Comment_data_quality_feedback__c){
			newAccount.Data_quality_history__c = (newAccount.Data_quality_history__c == null ? '' : newAccount.Data_quality_history__c + '\n') + System.now().format('YYYY-MM-dd') + ': ' + newAccount.Comment_data_quality_feedback__c;
		}

	}

	//Update account name based on its parent
	//Workflow Name:Rename Branch
	public static void setAccountBranchNamePre(Account newAccount){
		

		if(newAccount.RecordTypeId == AMS_Utils.RECTYPE_AIRLINE_BR && newAccount.ParentId <> null) {
				if(accountsToSearchParents.get(newAccount.ParentId) == null){
					accountsToSearchParents.put(newAccount.ParentId,new List<Account>{newAccount});
					}
				else {
					accountsToSearchParents.get(newAccount.ParentId).add(newAccount);
				}
			}
	}

	public static void setAccountBranchNamePos(List<AccounT> triggerNew, Boolean isUpdate){
		
		Map<Id,Account> newMap = new Map<Id,Account>();

		for(Account acct: triggerNew){
			newMap.put(acct.Id,acct);
		}

		for(List<Account> acctLst : accountsToSearchParents.values()){
			for(Account acct: acctLst){
				if(newMap.get(acct.ParentId) <> null){
					accountsToSearchParents.remove(acct.ParentId);
				}
			}
		}

		List<Account> accountLst;

		for(Account acctParent: [Select Id, TradeName__c, Name from Account where Id in:accountsToSearchParents.keySet()]){
			
			accountLst = accountsToSearchParents.get(acctParent.Id);

			For(Account acct :accountLst){
				acct.Name = acctParent.TradeName__c == null ? acctParent.Name : acctParent.TradeName__c;
				newMap.remove(acct.Id);
			}

		}

		// only for Updates
		if(isUpdate && !newMap.isEmpty()){          
			
			Account parentAccount = null;
			
			for(Account acctObject: newMap.values()){

				if(acctObject.RecordTypeId == AMS_Utils.RECTYPE_AIRLINE_BR && acctObject.ParentId <> null){

					parentAccount =  newMap.get(acctObject.ParentId);
					acctObject.Name = parentAccount.TradeName__c == null ? parentAccount.Name : parentAccount.TradeName__c;

				}
			}
		}

	}

	//Update account EU Agent Consent Last Update Date with todays date uppon DDS Update Date field change
	//Workflow Name:DDS Update Date
	public static void setAccountDDSUpdateDate(Account oldAccount , Account newAccount){
	
		if(oldAccount.DDS_Status__c <> newAccount.DDS_Status__c){
			newAccount.DDS_Last_Update_Date__c = System.today();
		}
	}

	//Set the name of an ACLI account (RT = Airline Headquarters ) using its Trade Name or AOC Name
	//Workflow Name:ACLIAccountSetName
	public static void setACLIAccountName(Account oldAccount ,Account newAccount){
		
		if(newAccount.recordTypeId <> airLineRT){
			return;
		}

		if( oldAccount == null || 
			oldAccount.TradeName__c <> newAccount.TradeName__c ||
			oldAccount.Legal_name__c <> newAccount.Legal_name__c ||
			oldAccount.Name_on_AOC__c <> newAccount.Name_on_AOC__c
		){

			if(newAccount.TradeName__c <> null && newAccount.TradeName__c <> ''){
				newAccount.Name = newAccount.TradeName__c;
				return;
			}

			if(newAccount.Legal_name__c <> null && newAccount.Legal_name__c <> ''){
				newAccount.Name = newAccount.Legal_name__c;
				return;
			}

			if(newAccount.Name_on_AOC__c <> null && newAccount.Name_on_AOC__c <> ''){
				newAccount.Name = newAccount.Name_on_AOC__c;
				return;
			}

		}
	
	}

	/*CASE ACTIONS START*/

	//Change Case Origin to Fax
	//Workflow Name: SCE Infofax cases
	public static void changeCaseOriginToFax(Case newCase){

		if(newCase.Subject != null && newCase.Subject.left(23) == 'Infofax recibido desde:')
			newCase.Origin = 'Fax';
	}

	//Updates the ACCA: Date/Time Opened field with the time the case was escalated to ACCA
	//Workflow Name: ACCA: Date/Time case was escalated
	public static void updateACCADatetimeCaseEscalated(Case oldCase, Case newCase){

		if(newCase.Escalate_to_ACCA__c && (oldCase == null || !oldCase.Escalate_to_ACCA__c))
			newCase.ACCA_Date_Time_New__c = Datetime.now();
	}

	//Updates the ACCA: Date/Time Scheduled field with the time the case was scheduled
	//Workflow Name: ACCA: Date/Time case was scheduled
	public static void updateACCADatetimeCaseScheduled(Case oldCase, Case newCase){

		if((newCase.Planned_End_CR__c != null || newCase.Planned_Start_CR__c != null) && (oldCase == null || oldCase.Planned_End_CR__c != newCase.Planned_End_CR__c || oldCase.Planned_Start_CR__c != newCase.Planned_Start_CR__c))
			newCase.ACCA_Date_Time_Scheduled__c = Datetime.now();
	}

	//Updates the ACCA: Date/Time Opened field with the time the case was escalated to ACCA
	//Workflow Name: ACCA: Date/Time case was completed
	public static void updateACCADatetimeCaseCompleted(Case oldCase, Case newCase){

		if((newCase.CR_Status__c == 'Completed' || newCase.Escalated_Status_ACCA__c == 'Completed') && (oldCase == null || oldCase.CR_Status__c != newCase.CR_Status__c || oldCase.Escalated_Status_ACCA__c != newCase.Escalated_Status_ACCA__c))
			newCase.ACCA_Date_Time_Completed__c = Datetime.now();
	}

	//Changes the Record Type of a CR for DPC to enable a page layout with the fields entered by the requestor locked from editing.
	//Workflow Name: ACR: DPC Change Record Type
	public static void updateRecordTypeToLocked(Case newCase){

		if(newCase.RecordTypeId == DPCSYSTEMRT)
			newCase.RecordTypeId = DPCSYSTEMSLOCKEDRT;
	}

	//Removes case from ACCA: New comment added view when case is completed by ACCA
	//Workflow Name: ACCA: Uncheck new comment for ACCA
	public static void uncheckNewCommentforACCA(Case oldCase, Case newCase){

		if(newCase.Escalated_Status_ACCA__c == 'Completed' && newCase.New_Comment_for_ACCA__c && (oldCase == null || oldCase.Escalated_Status_ACCA__c != newCase.Escalated_Status_ACCA__c || !oldCase.New_Comment_for_ACCA__c))
			newCase.New_Comment_for_ACCA__c = false;
	}

	//Update the Case Status to Escalated when the Escalated Status DPC is set to 'Reopened by IATA'
	//Workflow Name: ACCA: Update Case Status when ACCA case is reopened
	public static void updateStatusToEscalated(Case oldCase, Case newCase){

		if(newCase.Escalated_Status_ACCA__c == 'Reopend by IATA' && (oldCase == null || oldCase.Escalated_Status_ACCA__c != newCase.Escalated_Status_ACCA__c))
			newCase.Status = '2.0 IE approved - Escalated DPC for PQ';
	}

	//Updates the Escalated Status DPC 'DPC Investigating' once the 'DPC Owner' has been selected.
	//Workflow Name: ACCA: Update Escalated Status DCP with DPC Investigating
	public static void updateDPCStatus(Case oldCase, Case newCase){

		if(newCase.ACCA_Owner__c != null && (oldCase == null || oldCase.ACCA_Owner__c != newCase.ACCA_Owner__c))
			newCase.Escalated_Status_ACCA__c = '2.0 DPC Investigating';
	}

	//Once one or both the Planned Start (CR) and Planned End (CR) case fields are filled, the Escalated Status ACCA shall be changed
	//Workflow Name: ACCA: Update Escalated Status DPC with CSR Scheduled and CSR Status with Scheduled
	public static void updateCSRScheduled(Case oldCase, Case newCase){

		if((newCase.Planned_Start_CR__c != null || newCase.Planned_End_CR__c != null) && newCase.CR_Status__c == null){
			newCase.CR_Status__c = 'Scheduled';
			newCase.Escalated_Status_ACCA__c = 'CSR Scheduled';
		}
	}

	//Rule to define if a case is an internal or external query.
	//Workflow Name: Internal split for OPS Mgt cases AND External split for OPS Mgt cases
	public static void updateRTExternalInternal(Case newCase){

		Set<String> caseOrigins = new Set<String>{'E-mail to Case - EMD Testing', 
												'E-mail to Case - BSPlink', 
												'E-mail to Case - TSP Certification', 
												'E-mail to Case - BSP Support', 
												'E-mail to Case - SNAP', 
												'E-mail to Case - CASSlink GVA', 
												'E-mail to Case - Cargolink'};

		if(caseOrigins.contains(newCase.Origin))
			newCase.RecordTypeId = newCase.SuppliedEmail != null && newCase.SuppliedEmail.contains('iata') ? INTERNALCASESRT : OPERATIONALMANAGEMENTHORT;
	}

	/*CASE ACTIONS END*/

}