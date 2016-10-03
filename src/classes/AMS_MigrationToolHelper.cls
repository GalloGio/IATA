public with sharing class AMS_MigrationToolHelper {
	// this class is responsible for migrating Portal SAAM cases and SAAM cases that need to be converted into Comunication Cases (w/ AMS_OSCAR__c objects)
	
	final static ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

    private static Map<String, String> processTypeMap {
        get {
            return new Map<String, String> {
		    'New BR / IP' => 'NEW.BR',
			'New BR Abroad' => 'NEW.BR.ABROAD',
			'New HO' => 'NEW.HO.1.0',
			'Manage Changes / Major' => 'MAJOR.CHANGES',
			'CHL - Change of Location' => 'MAJOR.CHANGES',
            'CHO / CHS – Change of Ownership / Legal Status' => 'MAJOR.CHANGES',
            'CHN - Change of Name' => 'MAJOR.CHANGES',
            'CHC – Change of Shareholding' => 'MAJOR.CHANGES'
            };
        }
        set;
    }


	public static CaseContainer migratecases(CaseContainer cont){

		Savepoint sp = null;

		try {

			sp = Database.setSavepoint();

			if(cont.fromPortal)
				cont = processFromPortal(cont); //call portal method
			else
				cont = processNotFromPortal(cont);

		} catch(Exception e) {
			System.debug(e.getMessage());
			cont.errorMessage = e.getMessage(); //or other stuff
			cont.migrated = true;
			cont.processing = false;

			if(sp != null)
				Database.rollback(sp);

		}



		return cont;
	}

	private static CaseContainer processFromPortal(CaseContainer cont){

		Case caseToProcess = cont.c;

		caseToProcess.RecordTypeId = rtCommCase;

		AMS_Pax_Accreditation_Form__c accreditationObj = fetchAccreditation(caseToProcess.Id);

		String processType = processTypeMap.get(caseToProcess.Reason1__c);

		if(processType == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not match case reason from case ('+caseToProcess.Reason1__c+') with type of process to be run.';
			
			return cont;
		}

		String oscarId = AMS_RecordCreatorWebservice.createAccreditation(caseToProcess.AccountId, accreditationObj.Id, processType, caseToProcess.Id);

		cont.oscarId = oscarId;
		cont.oscarCaseId = caseToProcess.Id;
		cont.processing = false;
		cont.migrated = true;

		if(accreditationObj.IATACode__c == null && caseToProcess.Account.IATACode__c != null){
			
			accreditationObj.IATACode__c = caseToProcess.Account.IATACode__c;
			
			update accreditationObj;
		}

		return cont;

	}

	private static CaseContainer processNotFromPortal(CaseContainer cont){
		
		Case caseToProcess = cont.c;

		AMS_Pax_Accreditation_Form__c accreditationObj = fetchAccreditation(caseToProcess.Id);

		String processType = processTypeMap.get(caseToProcess.Reason1__c);

		if(processType == null){

			cont.migrated = true;
			cont.processing = false;
			cont.errorMessage = 'Could not match case reason from case ('+caseToProcess.Reason1__c+') with type of process to be run.';
			
			return cont;
		}


		String resultValidations = performValidations(caseToProcess,processType);

		Map<String, Object> flowVarMap = new Map<String, Object>();
      	
      	flowVarMap.put('accountId', caseToProcess.AccountId);
      	flowVarMap.put('Type_of_OSCAR_process_in', processType);
      	flowVarMap.put('ContactChooserEmailInput_in', caseToProcess.Contact.Email);
      	

      	System.debug('Starting with flow ...');
		
		Flow.Interview.OSCAR_Wizard_SIMPLEX_Automatic_v2_0 wizardFlow = new Flow.Interview.OSCAR_Wizard_SIMPLEX_Automatic_v2_0(flowVarMap);
		wizardFlow.start();

		System.debug('Flow has ended...');

		String oscarCaseId = (String)(wizardFlow.getVariableValue('OscarCaseId'));
		String oscarId = (String)(wizardFlow.getVariableValue('OscarId'));

		Case caseCreated = (Case)(wizardFlow.getVariableValue('CaseCreatedObject'));
		AMS_OSCAR__c oscarCreated = (AMS_OSCAR__c)(wizardFlow.getVariableValue('CreatedOscarObject'));


		System.debug('Oscar case id is ' + oscarCaseId);
		System.debug('Oscar id is ' + oscarId);
		
		caseToProcess.ParentId = oscarCaseId;

		update caseToProcess;

		System.debug('Case updated.');

		cont.oscarId = oscarId;
		cont.oscarCaseId = oscarCaseId;
		cont.oscarCreated = oscarCreated;
		cont.caseCreated = caseCreated;
		cont.processing = false;
		cont.migrated = true;

		if(accreditationObj == null)
			accreditationObj = fetchAccreditation(oscarCaseId);

		if(accreditationObj.IATACode__c == null && caseToProcess.Account.IATACode__c != null){
			
			accreditationObj.IATACode__c = caseToProcess.Account.IATACode__c;
			
			update accreditationObj;
		}

		System.debug('Process finished.');

		return cont;
		
		return null;
	}

	private static String performValidations(Case c, String processType){


		Set<String> categories = new Set<String> {
		'TIDS Agent',
		'MSO Member Sales Office',
		'GSA General Sales Agent',
		'GSSA Cargo',
		'Handling Agent'	
		};

		Account acct = c.Account;

		if(processType == 'MAJOR.CHANGES' && categories.contains(acct.Category__c)){
			return 'The wizard for Agency changes is not available for TIDS, MSO, GSA, GSSA and AHA Accounts. Please make sure your account is correct or has the correct Category.';			
		}


		if((acct.Category__c == 'GSA General Sales Agent' || acct.Category__c == 'GSSA Cargo') && acct.Location_Class__c != 'G')
			return 'The process only starts if the account has the proper process / location class.';
		if(acct.Category__c == 'MSO Member Sales Office' && acct.Location_Class__c != 'M')
			return 'The process only starts if the account has the proper process / location class.';
		if(acct.Category__c == 'TIDS Agent' && acct.Location_Class__c != 'T')
			return 'The process only starts if the account has the proper process / location class.';
		if(acct.Category__c == 'Handling Agent' && acct.Location_Class__c != 'X')
			return 'The process only starts if the account has the proper process / location class.';
		

		if((acct.Location_Type__c == 'BR' || acct.Location_Type__c == 'SA' ) && acct.ParentId == null)
			return 'The Account does not have a parent Id.';

		return null;
	}


	private static AMS_Pax_Accreditation_Form__c fetchAccreditation(Id caseId){

		List<AMS_Pax_Accreditation_Form__c> toReturn = new List<AMS_Pax_Accreditation_Form__c>([SELECT Id , IATACode__c from AMS_Pax_Accreditation_Form__c where SAAM_Case__c = :caseId]);
	
		if(!toReturn.isEmpty())
			return toReturn.get(0);

		return null;
	}

	//************************************
	//*********** wrapper ****************
	//************************************

	public class CaseContainer{

		public Case c				{ get; set; }
		public Boolean selected		{ get; set; }
		public Boolean processing	{ get; set; }		
		public Boolean migrated		{ get; set; }		
		public Boolean fromPortal	{ get; set; }

		public String errorMessage	{ get; set; }

		public String oscarId { get; set; }
		public String oscarCaseId { get; set; }

		public AMS_OSCAR__c oscarCreated {get; set;}
		public Case caseCreated {get; set;}

		public Boolean hasError{
			get{
				return String.isNotEmpty(errorMessage);
			}
			set;
		}

		public CaseContainer(Case c, Boolean fromPortal){
			this.c = c;
			this.selected = false;
			this.processing = false;
			this.migrated = false;
			this.fromPortal = fromPortal;
		}
	}
}