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

    private	List<String> caseMigratedFields = new List<String> {'Financial_Assessment_compliant__c','Financial_Assessment_received__c','Bank_Guarantee_deadline__c','Bank_Guarantee_received__c','Bank_Guarantee_requested__c','Change_effective_as_of__c','Criteria_remarks__c','Documentation_remarks__c','Dossier_reception_date__c','Fees_refund_requested__c','Finalization_checklist__c','Financial_Assessment_deadline__c','Financial_Assessment_requested__c','Financial_Review_Result__c','Invoice_number__c','Local_Inspection_compliant__c','Local_Inspection_deadline__c','Local_Inspection_received__c','Local_Inspection_requested__c','Process_Start_Date__c','Proof_of_payment_received__c','PSAA_EACP_Agreement_received__c','PSAA_signed_copy_sent__c','SAAM_Deadline_Date__c','AIMS_updated__c','Finalized_in_AIMS__c'};

	global Process.PluginResult invoke(Process.PluginRequest request) { 
        
		Map<String,Object> result = new Map<String,Object>();
        
        String oscarName = null;

        String oscarId = null;
        String errorMessage = null;

        boolean isFromPortal = false;

        String caseId = (String) request.inputParameters.get('caseId');
        String processType = (String) request.inputParameters.get('processType');

        System.debug('Case to migrate is ' + caseId);
        System.debug('Type of process is ' + processType);
        

		List<AMS_Pax_Accreditation_Form__c> accreditationFormsList =  [ SELECT Id FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.Id = :caseId];

		if(!accreditationFormsList.isEmpty()){
			isFromPortal = true;
		}

		List<Case> caseList = Database.query('SELECT Id, CaseNumber, OSCAR__c , OSCAR__r.Id ' + caseFieldsStr + toMigrateFields + ' , Account.IATACode__c ,  Contact.Email, Account.Category__c,Account.Location_Class__c,Account.ParentId,Account.Location_Type__c FROM CASE WHERE Id = :caseId');

		if(caseList.isEmpty()){
	        oscarId = '';
	        errorMessage = 'Could not find Case to match the id provided: ' + caseId;

	        result.put('oscarId',oscarId);
	        result.put('errorMessage',errorMessage);
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
	        result.put('caseNumber',oscarName);

	        System.debug('Finishing with oscarId ' + oscarId + ' and error message:' + errorMessage);
	        
	        return new Process.PluginResult(result); 

		}

		changeSubject = false;

		AMS_MigrationToolHelper.CaseContainer container = new AMS_MigrationToolHelper.CaseContainer(caseToMigrate,isFromPortal);

		System.debug('Starting SAAM case migration for case ' + caseToMigrate.Id + ' with comingFromPortal=' + isFromPortal);

		container = AMS_MigrationToolHelper.migratecases(container);

		changeSubject = true;

		System.debug('Migration completed.');

		if(container.errorMessage != null && container.errorMessage != ''){
	        
	        result.put('oscarId',oscarId);
	        result.put('errorMessage',container.errorMessage);
	        result.put('caseNumber',oscarName);

	        System.debug('Finishing with oscarId ' + oscarId + ' and error message:' + errorMessage);

	        return new Process.PluginResult(result); 

		}

        oscarId = container.oscarId;
        errorMessage = '';

        result.put('oscarId',oscarId);
        result.put('errorMessage',errorMessage);
        result.put('caseNumber',oscarName);

        System.debug('Finishing with oscarId ' + oscarId + ' and error message:' + errorMessage);

        return new Process.PluginResult(result); 
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
            Process.PluginDescribeResult.ParameterType.STRING, true)
            }; 
        result.outputParameters = new 
           List<Process.PluginDescribeResult.OutputParameter>{ 
             new Process.PluginDescribeResult.OutputParameter('oscarId', 
               Process.PluginDescribeResult.ParameterType.STRING),
             new Process.PluginDescribeResult.OutputParameter('errorMessage', 
               Process.PluginDescribeResult.ParameterType.STRING),
			new Process.PluginDescribeResult.OutputParameter('caseNumber', 
               Process.PluginDescribeResult.ParameterType.STRING)
           }; 
        return result; 
    }

}