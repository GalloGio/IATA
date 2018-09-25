global class AMS_OscarMigrationFromCase  implements Process.Plugin{

	public static boolean changeSubject = true;

    private List<Schema.SObjectField> caseFields{
        get{
            return new List<Schema.SObjectField>{
                Case.OwnerId,
                Case.Status,
                Case.RecordType__c,
                Case.Reason1__c,
                Case.AccountId,
                Case.BSPCountry__c
                
            };
        }
    }

    public List<String> caseFieldNames {
        get{
            if(caseFieldNames == null){
                caseFieldNames = new List<String>();
                for(Schema.SObjectField field : caseFields) caseFieldNames.add(field.getDescribe().getName());
            }
            return caseFieldNames;
        }
        set;
    }

    private String caseFieldsStr{
        get{
            caseFieldsStr = '';         
            for(String field : caseFieldNames) caseFieldsStr += ', '+field;
            return caseFieldsStr;
        }
        set;
    }

    private String toMigrateFields{
        get{
            toMigrateFields = '';         
            for(String field : caseMigratedFields) toMigrateFields += ', '+field;
            return toMigrateFields;
        }
        set;
    }

    private List<String> caseMigratedFields = new List<String> {'Financial_Assessment_compliant__c','Financial_Assessment_received__c','Bank_Guarantee_deadline__c','Bank_Guarantee_received__c','Bank_Guarantee_requested__c','Change_effective_as_of__c','Criteria_remarks__c','Documentation_remarks__c','Dossier_reception_date__c','Fees_refund_requested__c','Finalization_checklist__c','Financial_Assessment_deadline__c','Financial_Assessment_requested__c','Financial_Review_Result__c','Invoice_number__c','Local_Inspection_compliant__c','Local_Inspection_deadline__c','Local_Inspection_received__c','Local_Inspection_requested__c','Process_Start_Date__c','Proof_of_payment_received__c','PSAA_EACP_Agreement_received__c','PSAA_signed_copy_sent__c','SAAM_Deadline_Date__c','AIMS_updated__c','Finalized_in_AIMS__c'};

	global Process.PluginResult invoke(Process.PluginRequest request) { 
        
		Map<String,Object> result = new Map<String,Object>();
        
        String oscarName = null;

        String oscarId = null;
        String errorMessage = null;
        String summaryMessage = null;

        boolean isFromPortal = false;

        String caseId = (String) request.inputParameters.get('caseId');
        String processType = (String) request.inputParameters.get('processType');
        String scopeOfChange = (String) request.inputParameters.get('scopeOfChange');
        String concernedAgencyCodes = (String) request.inputParameters.get('concernedAgencyCodes');
        String concernedContactId = (String) request.inputParameters.get('concernedContact');

        System.debug('Case to migrate is ' + caseId);
        System.debug('Type of process is ' + processType);
        System.debug('Scope of Change is ' + scopeOfChange);
        System.debug('Concerned agency codes: ' + concernedAgencyCodes);
        System.debug('Concerned CotactId: ' + concernedContactId);
        

		List<AMS_Pax_Accreditation_Form__c> accreditationFormsList =  [ SELECT Id FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.Id = :caseId];

		if(!accreditationFormsList.isEmpty()){
			isFromPortal = true;
		}

        List<Case> caseList = Database.query('SELECT Id, CaseNumber, account.ANG_FA_Opt_out__c, OSCAR__c , OSCAR__r.Id, Account_Concerned__c ' + caseFieldsStr + toMigrateFields + ' , Account.IATACode__c ,  Contact.Email, ContactId, Account.Category__c,Account.Location_Class__c,Account.Location_Type__c, Account.ANG_IsNewGenAgency__c, Account.Name, Account.Parent.Remittance_frequency__c, Account.Parent.ANG_Accreditation_Model__c, Account.Company_Type__c, Account.TradeName__c, Account.ParentId FROM CASE WHERE Id = :caseId');

		if(caseList.isEmpty()){
	        oscarId = '';
	        errorMessage = 'Could not find Case to match the id provided: ' + caseId;

	        result.put('oscarId',oscarId);
	        result.put('errorMessage',errorMessage);
            result.put('summaryMessage', '');
	        result.put('caseNumber',oscarName);

	        return new Process.PluginResult(result); 

		}

		Case caseToMigrate = caseList.get(0);

		oscarName = caseToMigrate.CaseNumber;

		if(caseToMigrate.OSCAR__c != null){
	        oscarId = '';
	        errorMessage = 'The case already has an oscar attached: ' + caseToMigrate.OSCAR__c;

	        result.put('oscarId',oscarId);
	        result.put('errorMessage',errorMessage);
            result.put('summaryMessage', '');
	        result.put('caseNumber',oscarName);

	        System.debug('Finishing with oscarId ' + oscarId + ' and error message:' + errorMessage);
	        
	        return new Process.PluginResult(result); 

		}

		changeSubject = false;

       // AMS_MigrationToolHelper.CaseContainer container = new AMS_MigrationToolHelper.CaseContainer(caseToMigrate,isFromPortal);
        AMS_MigrationToolHelper.CaseContainer container = new AMS_MigrationToolHelper.CaseContainer(caseToMigrate,isFromPortal,concernedContactId);

		System.debug('Starting SAAM case migration for case ' + caseToMigrate.Id + ' with comingFromPortal=' + isFromPortal);

        AMS_OscarMigrationFromCase.changeSubject = true;
		container = AMS_MigrationToolHelper.migratecases(container,processType);
        AMS_OscarMigrationFromCase.changeSubject = false;

		changeSubject = true;

		System.debug('Migration completed.');
        
        map<String, String> childCaseCreationResult = new map<String, String>();

        // CB - AMS enhancements / AMSU-3
        if (processType == AMS_Utils.BANKACCCHANGES && scopeOfChange != null) {
            // add scope of change and concerned branches to AMS Online Accreditation record
            updateAccreditationForm(container.oscarCaseId, scopeOfChange, concernedAgencyCodes);

            // set the Case Area & Reason values for correct KPI calculation
            container.c.CaseArea__c = 'Accreditation Process';
            container.c.Reason1__c = 'Bank Detail Update';
            update container.c;

            //Create child OSCAR Comm cases for Change of Bank details where one or more (but not all) Branches are involved
            if (scopeOfChange == 'HO - Selected Branches' || scopeOfChange == 'Selected Branches Only'){
                childCaseCreationResult = createChildCases(concernedAgencyCodes, container.c, container.oscarCreated);
            }
        }
        ////

        /*** AMSU-174 ***/
        if (processType == AMS_Utils.new_TIDS) {
            container.c.CaseArea__c = 'Accreditation Products';
            update container.c;
        }

		if((container.errorMessage != null && container.errorMessage != '') || (childCaseCreationResult.get('errorMessage') != null && childCaseCreationResult.get('errorMessage') != '')){
	        
	        result.put('oscarId',oscarId);
	        result.put('errorMessage',container.errorMessage + ' ' + childCaseCreationResult.get('errorMessage'));
            result.put('summaryMessage', '');
	        result.put('caseNumber', oscarName);

	        System.debug('Finishing with oscarId ' + oscarId + ' and error message:' + errorMessage + ' ' + childCaseCreationResult.get('errorMessage') + '; Summary: ' + childCaseCreationResult.get('summaryMessage'));

	        return new Process.PluginResult(result); 

		}

        oscarId = container.oscarId;
        errorMessage = '';

        result.put('oscarId',oscarId);
        result.put('errorMessage',errorMessage);
        result.put('summaryMessage', childCaseCreationResult.get('summaryMessage'));
        result.put('caseNumber',oscarName);

        System.debug('Finishing with oscarId ' + oscarId + ' and error message:' + errorMessage);

        return new Process.PluginResult(result); 
    }

    @future
    static void updateAccreditationForm(String caseId, String scopeOfChange, String concernedAgencyCodes) {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'AMS_Pax_Accreditation_Form__c' AND DeveloperName = 'Change_of_Bank_Account_Details'];

        list<AMS_Pax_Accreditation_Form__c> accreditationFormsList = [SELECT Id, SAAM_Case__c, Scope_of_Change__c,Agency_Codes_Concerned__c, Is_change_bank_account_details__c FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :caseId];
        if (accreditationFormsList.isEmpty()) {
            system.debug('Accreditation Form for case ' + caseId + ' not found.');
            return;
        }        

        AMS_Pax_Accreditation_Form__c accreditationForm = accreditationFormsList[0];
        accreditationForm.Scope_of_Change__c = scopeOfChange;
        accreditationForm.Agency_Codes_Concerned__c = concernedAgencyCodes;
        accreditationForm.Is_change_bank_account_details__c = true;
        accreditationForm.RecordTypeId = rt.Id;

        update accreditationForm;
        system.debug('accreditation form updated with scope of change "' + scopeOfChange + '" and concerned agency codes "' + concernedAgencyCodes + '" and record type id ' + rt.Id);
    }

    // Used for processType == AMS_Utils.BANKACCCHANGES
    private map<String, String> createChildCases(String concernedAgencyCodes, Case parentCase, AMS_OSCAR__c hoOscar) {

        String summaryPos = 'Cases and OSCARs have been created for the following agencies: ';
        Boolean hasSuccesses = false;
        String summaryNeg = 'The agencies with the following IATA Codes could not be found: ';
        Boolean hasErrors = false;
        
        if(parentCase == null) return new map<String,String>{'errorMessage' => 'Invalid parent case: null'};
        if(hoOscar == null) return new map<String,String>{'errorMessage' => 'Invalid HO Oscar: null'};

        List<String> agencySelectedBranches = concernedAgencyCodes.split(',');

        // determine the HO account
        Case tmpCase = [SELECT Id, AccountId, Account.Top_Parent__c FROM Case WHERE Id = :parentCase.Id];
        if (tmpCase.AccountId == null) return new map<String,String>{'errorMessage' => 'Could not determine the top parent account. There is no account on the case.'};

        Id TopParentId = tmpCase.Account.Top_Parent__c != null ? tmpCase.Account.Top_Parent__c : tmpCase.AccountId;

        // get all branches
        Map<String, Account> agencies = new Map<String, Account>();
        for(Account branch : [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry
                                    FROM Account
                                    WHERE Top_Parent__c = :TopParentId AND IATACode__c != null AND RecordType.DeveloperName IN ('IATA_Agency') AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) 
                                    ]){
            agencies.put(branch.IATACode__c, branch);
        }

        if(agencies.isEmpty()) return new map<String,String>{'errorMessage' => 'Could not find any branches for the selected account.'};

        Id auxId = null;
        map<Id, Case> mapChildCasesPerAccountConcernedId = new map<Id, Case>();
        map<Id, AMS_OSCAR__c> mapOscarsPerAccountConcernedId = new map<Id, AMS_OSCAR__c>();

        for(String iataCode : agencySelectedBranches){
            Account accConcerned = agencies.get(iataCode.trim());
            if(accConcerned != null && accConcerned.Id != parentCase.Account_Concerned__c && accConcerned.Id != parentCase.AccountId){
                
                Case child = parentCase.clone(false, true);
                
                child.Subject = Label.ISSP_AMS_NoC_Direct_Debit_Change + ' – ' + accConcerned.IATACode__c + ' – ' + accConcerned.Name;
                child.Account_Concerned__c = accConcerned.Id;
                child.ParentId = parentCase.Id;
                child.Status = 'Open';
                child.Origin = 'Portal';
                child.Product_Category_ID__c = '-'; //Set Product Id so picked up by case assign to AM Regional queue

                //FM 31-10-2016 - Set IATA Country to 'All Countries' so auto-response doesn't get sent for child cases
                auxId = child.ContactId;
                child.ContactId = ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c == null? null : ISSP_CS__c.getValues('No Notification Email Contact Id').Value__c;
                
                mapChildCasesPerAccountConcernedId.put(accConcerned.Id, child);

                AMS_OSCAR__c childOscar = hoOscar.clone(false, true);
                childOscar.Process__c = AMS_Utils.BANKACCCHANGES; 
                childOscar.AMS_Online_Accreditation__c = null;
                childOscar.Account__c = accConcerned.Id;

                mapOscarsPerAccountConcernedId.put(accConcerned.Id, childOscar);

                summaryPos += (hasSuccesses? ', ' : '') + iataCode.trim();
                hasSuccesses = true;
            } else if(accConcerned == null) {
                summaryNeg += (hasErrors? ', ' : '') + iataCode.trim();
                hasErrors = true;
            }
        }
        
        if(!mapChildCasesPerAccountConcernedId.isEmpty()) {

            insert mapOscarsPerAccountConcernedId.values();

            for (Id AcctConcernedId : mapOscarsPerAccountConcernedId.keyset()) {
                 mapChildCasesPerAccountConcernedId.get(AcctConcernedId).OSCAR__c = mapOscarsPerAccountConcernedId.get(AcctConcernedId).Id;
            }

            insert mapChildCasesPerAccountConcernedId.values();
            //FM 31-10-2016 - Set IATA Country to the Country of the parent case (because of auto-response that was being sent for child cases)
            for(Case auxCase :  mapChildCasesPerAccountConcernedId.values()){
                auxCase.ContactId = auxId;
            }
            
            update  mapChildCasesPerAccountConcernedId.values(); 

        }

        String strSummary = (hasSuccesses ? summaryPos + '.\n' : '') + (hasErrors ? summaryNeg + '.' : '');
        
        return new map<String,String>{'errorMessage' => '', 'summaryMessage' => strSummary};
    }

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'AMS_OscarMigrationFromCase';
        result.Tag = 'APEX';
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
            new Process.PluginDescribeResult.InputParameter('caseId', 
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('processType', 
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('scopeOfChange', 
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('concernedAgencyCodes', 
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('concernedContact', 
            Process.PluginDescribeResult.ParameterType.STRING, true)
            }; 
        result.outputParameters = new 
           List<Process.PluginDescribeResult.OutputParameter>{ 
             new Process.PluginDescribeResult.OutputParameter('oscarId', 
               Process.PluginDescribeResult.ParameterType.STRING),
             new Process.PluginDescribeResult.OutputParameter('errorMessage', 
               Process.PluginDescribeResult.ParameterType.STRING),
             new Process.PluginDescribeResult.OutputParameter('summaryMessage', 
               Process.PluginDescribeResult.ParameterType.STRING),
			new Process.PluginDescribeResult.OutputParameter('caseNumber', 
               Process.PluginDescribeResult.ParameterType.STRING)
           }; 
        return result; 
    }

}