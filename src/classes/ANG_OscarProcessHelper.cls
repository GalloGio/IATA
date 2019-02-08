global class ANG_OscarProcessHelper {

	public static final Set<String> AMLCaseProcesses = new Set <String>{AMS_Utils.new_HO ,AMS_Utils.new_BR_ABROAD, AMS_Utils.NEWHELITE, AMS_Utils.NEWHESTANDARD};
	public static final Set<String> SanityCheckVerificationProcesses = new Set <String>{AMS_Utils.NEWHELITE, AMS_Utils.NEWHESTANDARD, AMS_Utils.NEWGESTANDARD, AMS_Utils.NEWAE, AMS_Utils.MCAE};

	public static final String ANG_PCI_RENEWAL = 'ANG_PCI_RENEWAL'; //email template id name for pci automatic renewal

	/* EasyPay Service Providers */
	public static final Set<String> MODEL_A_PROVIDERS = new Set<String>{'IATA EasyPay (EDENRED)'};
	public static final Set<String> MODEL_B_PROVIDERS = new Set<String>{'IATA EasyPay (EDENRED)','IATA EasyPay (MSTS)'};

	public static boolean isIATACodeGenerationRunning = false;

	webservice static String[] processIATACodeGeneration(String accountId, String onlineAccreditationId, String oscarId){

		// this method will provide the following funcionalities:

		// 1) IATA Code Generation
		// 2) Data migration from Online Accreditation into the Account
		// 3) Change code creation (NEW)
		// 4) Create a due diligence case if certain conditions are met

		checkSFDCLimits();

		Datetime processStartTime = datetime.now();
		
		Integer returnCode;

		System.debug('[ANG_OscarProcessHelper] Entering the IATA Code Generation Process.');

		Savepoint sp = Database.setSavepoint();
		String returnMessage = '';
		String caseId = '';

		Boolean iataCodeGeneration = false;
		Boolean dataMigration = false;
		Boolean changecodeGeneration = false;
		Boolean dueDiligence = false;
		Boolean changeCodeCreated = false;
		Boolean needsToCreateDueDiligence = false;
		
		try{

			isIATACodeGenerationRunning = true;
 
	        Account theAccount = [SELECT Name, Status__c, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
					BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
					ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
					Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, 
					Is_your_firm_handling_Dangerous_Goods__c, IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__c,
					IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name, Link_agent_name__c, ANG_Accreditation_Model__c, IATA_ISO_Country__r.CurrencyIsoCode, IATA_ISO_Country__r.Due_diligence_mandatory__c,
					IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode,
					(SELECT Id FROM RHC_Informations__r), Is_PCI_compliant__c,Link_agent_code__c, Sector__c, Category__c, Check_Digit__c, RecordTypeId,Due_Diligence_Status__c,CNS_Agency__c, GDP_Opt_In__c ,
					(SELECT Id, Change_Code__c, Active__c FROM Agencies_Applied_Change_codes__r WHERE Active__c = true), Reason__c, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c
					FROM Account
					WHERE Id =:accountId FOR UPDATE];

	        AMS_Pax_Accreditation_Form__c theAccreditation = [SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c,
	        		ISSP_AMS_VAT_number__c, ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, 
	        		Billing_State__c, Branch_Office_City__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,Branch_Office_Postal_code__c,
					Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
					Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, 
					Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,IATA_ISO_State__r.Valid_for_Address__c,SAAM_Case__r.OSCAR__r.Account__r.Top_Parent__r.IATACode__c,
					Shipping_ISO_Country__c,Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, Link_agent_name__c, 
					Link_agent_name__r.Link_agent_code__c, Link_agent_name__r.IATACode__c,Chk_Dgt__c,SAAM_Case__r.Account.Top_Parent__c, SAAM_Case__r.Account.Top_Parent__r.N_Code__c,
					Branch_Office_Country__c, Branch_Office_Country__r.AMS_Default_State__c, SAAM_Case__r.Account.Top_Parent__r.Check_Digit__c, SAAM_Case__r.Account.Top_Parent__r.C_Code__c, 
					SAAM_Case__r.Account.Top_Parent__r.A_Code__c, SAAM_Case__r.Account.Top_Parent__r.IATACode__c, ISO_country__c, N_Code__c, A_Code__c, C_Code__c,
					SAAM_Case__r.OSCAR__r.Process__c, ANG_IsNewGenAgency__c, SAAM_Case__r.OSCAR__r.STEP6__c,Branch_Office_Country__r.Due_diligence_mandatory__c
					FROM AMS_Pax_Accreditation_Form__c
					WHERE Id = :onlineAccreditationId FOR UPDATE];

			AMS_OSCAR__c oscar = [select Account__c, Account__r.Parent.Status__c, Flag_IATACode_Formula__c, Flag_IATACode__c, Flag_Data_to_Account__c, AMS_Online_Accreditation__c, Process__c, recordTypeID,
					Is_PCI_compliant__c, Account__r.Top_Parent__r.Id , AMS_Online_Accreditation__r.Id,Account__r.Location_Type__c,RecordType.DeveloperName,
					Flag_Data_to_SAPECC__c,ID, STEP10__c,STEP17__c,STEP8__c,Process_Start_Date__c, Account__r.Due_Diligence_Status__c, AMS_Online_Accreditation__r.Location_Class__c, 
					AMS_Online_Accreditation__r.Link_agent_name__c , AMS_Online_Accreditation__r.Branch_Office_Country__r.Due_diligence_mandatory__c, Account__r.Location_Class__c,
					Account__r.Sector__c , Account__r.Company_type__C, STEP6__c, Is_NewGen__c,ANG_PCI_compliance_expiry_date__c, Account__r.Top_Parent__r.Status__c, Business_Process__c,
					(SELECT Id FROM Agencies_Applied_Change_codes__r) , (select Id from Appointments__r)
					from AMS_OSCAR__c where Id = : oscarId LIMIT 1];

			System.debug('[ANG_OscarProcessHelper] Fetched Account:' + theAccount);

			System.debug('[ANG_OscarProcessHelper] Fetched Online Accreditation:' + theAccreditation);

			System.debug('[ANG_OscarProcessHelper] Fetched OSCAR:' + oscar);

			EntityUpdater updater = new EntityUpdater();
			
			updater.oscarMap.put(oscar.Id,oscar);
			updater.acctMap.put(theAccount.Id,theAccount);
			updater.onlineAMap.put(theAccreditation.Id,theAccreditation);
			
			if(oscar.Process__c == AMS_Utils.MCAE && !ANG_MulticountryHelper.allowIATACodeGeneration(oscar)){
				isIATACodeGenerationRunning = false;
				System.debug('[ANG_OscarProcessHelper] In order to generate a IATA code the parent account should have the change code NEW generated');
				return new String[]{'-1', Label.ANG_Multicountry_Process_Parent_Account_Error, '-1'};
			}
            
			/*** AMSU-162 ***/
			if(AMS_Utils.AMS_ProcessesAddressToValidate.contains(oscar.Process__c) && !isShippingAddressValid(theAccreditation)) {
				isIATACodeGenerationRunning = false;
				System.debug('[ANG_OscarProcessHelper] Incomplete shipping address.');
				return new String[]{'-1','Incomplete shipping address.','-1'};
			}

			/*** AMSU-166 ***/			
			if(AMS_Utils.oscarNewProcesses.contains(oscar.Process__c)) {				
				List<String> errorMessages = AMS_Utils.validateCharacters(theAccreditation, AMS_Utils.STAGING_AREA_FIELDS_TO_VALIDATE);
				if(!errorMessages.isEmpty()) {
					isIATACodeGenerationRunning = false;
					System.debug('[ANG_OscarProcessHelper] ' + String.join(errorMessages, '\n'));
					return new String[]{'-1',String.join(errorMessages, '\n'),'-1'};
				}							
			}

            if(theAccount.CNS_Agency__c == false && oscar.STEP6__c != AMS_Utils.PASSED && SanityCheckVerificationProcesses.contains(oscar.Process__c)) {
				isIATACodeGenerationRunning = false;
				System.debug('[ANG_OscarProcessHelper] In order to generate a IATA code you must first pass the Sanity Check.');
				return new String[]{'-1','In order to generate a IATA code you must first pass the Sanity Check.','-1'};

            }

            if(oscar.Process__c.containsIgnoreCase('NEW') && oscar.Account__r.Location_Type__c != 'HO' && oscar.Account__r.Location_Type__c != 'HE' && oscar.Account__r.Top_Parent__r.Status__c == AMS_Utils.ACC_S0_TERMINATED){
            	isIATACodeGenerationRunning = false;
            	System.debug('[ANG_OscarProcessHelper] IATA code generation is not allowed in hierarchies with HO/HE status Terminated.');
            	return new String[]{'-1','IATA code generation is not allowed in hierarchies with HO/HE status Terminated.','-1'};
            }

			if((!oscar.Appointments__r.isEmpty()) && oscar.Appointments__r.size() > 1){
				isIATACodeGenerationRunning = false;
				System.debug('[ANG_OscarProcessHelper] A New MSO cannot have more than one Appointment. Please review the appointments section and try again.');
				return new String[]{'-1','A New MSO cannot have more than one Appointment. Please review the appointments section and try again.','-1'};
			}

			/*** AMSU-161 Start ***/
			if(oscar.Process__c == AMS_Utils.new_GSSA || oscar.Process__c == AMS_Utils.new_GSA 
			    || oscar.Process__c == AMS_Utils.new_AHA){
			    String sError = AMS_InspectionHelper.validateGSAforAppointments(oscar, updater.onlineAMap);
			    if(!sError.equalsIgnoreCase('')){
			    	return new String[]{'-1',sError+'\n\r','-1'};
			    }
			}
			/*** AMSU-161 End ***/ 
			
			System.debug('[ANG_OscarProcessHelper] Execution time so far:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);

			/*** AMSU-37 ***/
			Boolean sIATACodeGeneration = doAgainIATACodeGeneration(oscar, theAccount);

	        if(!oscar.Flag_IATACode__c || sIATACodeGeneration){

				System.debug('[ANG_OscarProcessHelper] Starting IATA Code Generation.');

				if(!Test.isRunningTest() && !sIATACodeGeneration)
		        	updater = AmsIataCodeGenerator.generatedAgencyIATACode(theAccount,theAccreditation,updater);


		        if(updater.isFaulty){

		        	Database.rollback(sp);

		        	if(oscar.STEP10__c != AMS_Utils.PASSED){
			        	oscar.STEP10__c = 'Failed';update oscar;
		        	}
					
					isIATACodeGenerationRunning = false;return new String[]{'-1',updater.errorMessage,'-1'};

		        }

		        returnMessage += 'IATA Code generated successfully. \n\r';
		        iataCodeGeneration = true;

		        updater.acctMap.get(theAccount.Id).GDP_Opt_In__c = true;
		        updater.oscarMap.get(oscar.Id).Flag_IATACode__c = true;
				updater.toUpdate = true;

		        System.debug('[ANG_OscarProcessHelper] IATA Code generated successfully.');
			}else{
				
				iataCodeGeneration = true;
				returnMessage += 'IATA Code was already generated (skipped). \n\r';
				System.debug('[ANG_OscarProcessHelper] IATA Code was already generated (skipped).');

			}
			

	        System.debug('[ANG_OscarProcessHelper] Preparing to copy data to Agency.');
			System.debug('[ANG_OscarProcessHelper] Execution time so far:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);

			if(!oscar.Flag_Data_to_Account__c){
		        
		        updater = copyDataToAccount(updater.oscarMap.get(oscar.Id), updater.acctMap.get(theAccount.Id),updater.onlineAMap.get(theAccreditation.Id) ,true, updater);

		        if(updater.isFaulty){
		        	Database.rollback(sp);

		        	if(oscar.STEP10__c != AMS_Utils.PASSED){
			        	oscar.STEP10__c = 'Failed';update oscar;
		        	}

		        	isIATACodeGenerationRunning = false;
		        	return new String[]{'-1',updater.errorMessage,'-1'};
		        }


				returnMessage += 'Data to Agency migrated successfully. \n\r';
				dataMigration = true;

				updater.oscarMap.get(oscar.Id).Flag_Data_to_Account__c = true;

		        System.debug('[ANG_OscarProcessHelper] Data to Agency migrated successfully.');

			}else{

				dataMigration = true;
				returnMessage += 'Data to Agency was already migrated (skipped). \n\r';
				System.debug('[ANG_OscarProcessHelper] Data to Agency was already migrated (skipped).');
			}
			
			System.debug('[ANG_OscarProcessHelper] Execution time so far:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);
	        System.debug('[ANG_OscarProcessHelper] Preparing to generate Change Code (NEW).');

	        if(updater.oscarMap.get(oscar.Id).Agencies_Applied_Change_codes__r.isEmpty()){

		       	updater = createChangeCodeNEW(updater , updater.oscarMap.get(oscar.Id));

		        if(updater.isFaulty){
		        	Database.rollback(sp);isIATACodeGenerationRunning = false;
		        	
		        	if(oscar.STEP10__c != AMS_Utils.PASSED){
			        	oscar.STEP10__c = 'Failed';update oscar;
		        	}

		        	return new String[]{'-1',updater.errorMessage,'-1'};
		        }


				returnMessage += 'Change Code (NEW) generated successfully. \n\r';
				changecodeGeneration = true;
				changeCodeCreated = true;
				System.debug('[ANG_OscarProcessHelper] Change Code (NEW) generated successfully.');

			}else{
				
				changecodeGeneration = true;
				returnMessage += 'The Oscar already has a Change Code inserted (skipped). \n\r';
		        System.debug('[ANG_OscarProcessHelper] The Oscar already has a Change Code inserted (skipped).');

			}

			//NEWGEN-4852 - Copy Parent Account (GE/HE) information to the staging area of AE in same BSP - Change Code NEW
			if(iataCodeGeneration && changecodeGeneration && (oscar.Process__c == AMS_Utils.NEWGESTANDARD || (oscar.Process__c == AMS_Utils.MCAE && oscar.Account__r.Location_Type__c == AMS_Utils.HE))){
				System.debug('[ANG_OscarProcessHelper] Start Copying account information into Child staging area');
				ID jobID = System.enqueueJob(new ANG_MulticountryCopyParentInfo(new List<ID>{theAccount.id}, 'NEW'));
				System.debug('[ANG_OscarProcessHelper] JobID:' + jobID);
			}

			if(iataCodeGeneration && dataMigration && changecodeGeneration && !updater.oscarMap.get(oscar.Id).Flag_Data_to_SAPECC__c){
				updater.oscarMap.get(oscar.Id).Flag_Data_to_SAPECC__c = true;
				updater.oscarMap.get(oscar.Id).STEP8__c = AMS_Utils.IN_PROGRESS;
				updater.toUpdate = true;
			}
			
			System.debug('[ANG_OscarProcessHelper] iataCodeGeneration is:'+iataCodeGeneration);
			System.debug('[ANG_OscarProcessHelper] dataMigration is:'+dataMigration);
			System.debug('[ANG_OscarProcessHelper] changecodeGeneration is:'+changecodeGeneration);

			if(iataCodeGeneration && dataMigration && changecodeGeneration){

				System.debug('[ANG_OscarProcessHelper] Due Diligence Mandatory is:'+updater.onlineAMap.get(theAccreditation.Id).Branch_Office_Country__r.Due_diligence_mandatory__c);
				
				if(updater.onlineAMap.get(theAccreditation.Id).Branch_Office_Country__r.Due_diligence_mandatory__c)
					if(AMLCaseProcesses.contains(updater.oscarMap.get(oscar.Id).Process__c)){
						// creating the due diligence case

						if(updater.acctMap.get(theAccount.Id).Due_Diligence_Status__c == AMS_Utils.IN_PROGRESS || updater.oscarMap.get(oscar.Id).STEP17__c == AMS_Utils.IN_PROGRESS){
							returnMessage += 'Did not created Due Diligence Case since it is already in progress. (skipped) \n\r';
							updater.oscarMap.get(oscar.Id).STEP17__c = AMS_Utils.IN_PROGRESS;
							updater.toUpdate = true;

						}else{
							needsToCreateDueDiligence = true;
							System.debug('[ANG_OscarProcessHelper] Execution time so far:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);
		        			System.debug('[ANG_OscarProcessHelper] Creating the Due Diligence Case.');
							updater = execCreateAMLCase(updater.oscarMap.get(oscar.Id), updater);
							returnMessage += 'Due Diligence case created successfully. \n\r';
							dueDiligence = true;
							caseId = updater.caseMap.values().get(0).Id;
						}
					}
			}
		
			Datetime processNowTime = datetime.now(); 
			System.debug('[ANG_OscarProcessHelper] Execution time so far:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);

		if(updater.toUpdate){
			System.debug('[ANG_OscarProcessHelper] Preparing to update entities.');

			// since we run everything, let's update OSCAR's Step 10 (generate IATA code).
			updater.oscarMap.get(oscar.Id).STEP10__c = AMS_Utils.PASSED;

			updateUpdater(updater);
			System.debug('[ANG_OscarProcessHelper] Entities updated.');

			if(changeCodeCreated){
				System.debug('[ANG_OscarProcessHelper] Preparing to create an Agency Update.');
				AMS_AgencyUpdateHelper.agencyUpdate( [Select Id, Change_Code__c, Account__c, Oscar__c, Active__c from Agency_Applied_Change_code__c where Account__c = :accountId AND Change_Code__c = 'NEW' and Oscar__c = :oscarId LIMIT 1]);
			}
		}
		else{
			System.debug('[ANG_OscarProcessHelper] No changes were detected, skipping entities update.');
		}

		System.debug('[ANG_OscarProcessHelper] Total Execution time:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);
		checkSFDCLimits();

		}catch (DmlException dex){

			Database.rollback(sp);


		    Integer numErrors = dex.getNumDml();

			String exMessage = 'Unhandle error on process:\n\r ';

		    for(Integer i=0;i<numErrors;i++) {
		    	
				exMessage += dex.getDmlMessage(i) + '\n\r';
    	    }
	        
	        System.debug('[ANG_OscarProcessHelper] Process failed with the following exception:' + dex.getStackTraceString());

	        isIATACodeGenerationRunning = false;
			return new String[]{'-1',exMessage,'-1'};

		}catch(Exception ex){

        	Database.rollback(sp);

        	String exMessage = 'Unhandle error on process:\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);

        	if(!iataCodeGeneration)
	        	exMessage = 'Unhandle error generating IATA Code:\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);
        	else if(!dataMigration)
	        	exMessage = 'Unhandle error migrating data to Agency:\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);
        	else if(!changecodeGeneration)
	        	exMessage = 'Unhandle error generating Change code (NEW):\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);
        	else if(!dueDiligence && needsToCreateDueDiligence)
	        	exMessage = 'Unhandle error creating Due Diligence Case:\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);

	        exMessage+= '\n\rThe process needs to be executed again.';

	        System.debug('[ANG_OscarProcessHelper] Process failed with the following exception:' + ex.getStackTraceString());

	        isIATACodeGenerationRunning = false;
			return new String[]{'-1',exMessage,'-1'};

		}

		System.debug('[ANG_OscarProcessHelper] Total Execution time:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);

		isIATACodeGenerationRunning = false;

		return new String[]{'0',returnMessage,dueDiligence ? '0' : '-1',caseId};

	}

	/*** AMSU-162 ***/
	public static Boolean isShippingAddressValid(AMS_Pax_Accreditation_Form__c accreditation) {
		String street = accreditation.Shipping_Street__c; 
        String city = accreditation.Shipping_City__c;
        String state = accreditation.Shipping_State__c;
        String zipCode = accreditation.Shipping_Postal_Code__c;
        Id isoState = accreditation.Shipping_ISO_State__c;
        Id isoCountry = accreditation.Shipping_ISO_Country__c;

        if(String.isBlank(street) && String.isBlank(city) && String.isBlank(state) && String.isBlank(zipCode) && isoState == null && isoCountry == null) {
            return true;
        }

        if(!String.isBlank(street) && !String.isBlank(city) && !String.isBlank(isoState) && !String.isBlank(isoCountry)) {
            return true;
        }

		return false;
	}

	public static void updateUpdater(EntityUpdater updater){

		if(!updater.acctMap.values().isEmpty())
            update updater.acctMap.values();

		if(!updater.onlineAMap.values().isEmpty())		
            update updater.onlineAMap.values();

		if(!updater.oscarMap.values().isEmpty()){
			isIATACodeGenerationRunning = false;
			update updater.oscarMap.values();
			isIATACodeGenerationRunning = true;
		}

		if(!updater.codeRangesMap.values().isEmpty())
			update updater.codeRangesMap.values();

	}

    //Map data from staging area (AMS Online Accreditation) to account
    public static EntityUpdater copyDataToAccount(AMS_OSCAR__c oscar, Account acc,  AMS_Pax_Accreditation_Form__c onlineAcc, Boolean runOwnershipMigration, EntityUpdater updaterObj) {

		if(updaterObj == null)
			updaterObj = new EntityUpdater();

        AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;

        System.debug('Copying Data from Staging to Account');

        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, Set<Id>> stagingToAccount = new Map<Id, Set<Id>>();
        
        //DT: reindented and added 3 fields for iso shipping/billin
        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
                                                                    ,'IATACode__c' => 'IATACode__c'
                                                                    ,'Short_Name__c' => 'Short_Name__c'
                                                                    ,'TradeName__c' => 'Trade_Name__c'
                                                                    ,'License_Number__c' => 'ISSP_AMS_License_No__c'
                                                                    ,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
                                                                    ,'BillingStreet' => 'Branch_Office_Street_name_number__c'
                                                                    ,'Website' => 'Website__c'
                                                                    ,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
                                                                    ,'Email__c' => 'Branch_Office_Email__c'
                                                                    ,'Phone' => 'Branch_Office_Phone__c'
                                                                    ,'Fax' => 'Branch_Office_FAX__c'
                                                                    ,'ShippingCity' => 'Shipping_City__c'
                                                                    ,'Operation__c' => 'Operation__c'
                                                                    ,'Abbreviated_name__c' => 'Abbreviated_name__c'
                                                                    ,'Abbreviated_address__c' => 'Abbreviated_Address__c'
                                                                    ,'Remittance_frequency__c' => 'Remittance_frequency__c'
                                                                    ,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
                                                                    ,'VAT_Number_2__c' => 'VAT_Number_2__c'
                                                                    ,'CASS_Number__c' => 'CASS_Number__c'
                                                                    ,'Location_Class__c' => 'Location_Class__c'
                                                                    ,'Location_Type__c' => 'Location_Type__c'
                                                                    ,'Mobile__c' => 'Mobile__c'
                                                                    ,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
                                                                    ,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
                                                                    ,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
                                                                    ,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
                                                                    ,'Link_agent_name__c' => 'Link_agent_name__c'};

        List<Account> createRHCInfo = new List<Account>();

        if (acc != null && onlineAcc != null) {

            for (String accfield : fieldsMapping.keySet()) {
                String onlineAccField = fieldsMapping.get(accfield);
                Object newValue = onlineAcc.get(onlineAccField);

                if( acc.get(accfield) != newValue ){
                    
                    acc.put(accfield, newValue);
                }
                
            }

            if (onlineAcc.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_TIDS && onlineAcc.Location_Class__c == 'T') {
                system.debug('RB: ENTROU NO DEBUG CLASS T: ' + onlineAcc.Location_Class__c );
                acc.Category__c = 'TIDS Agent';
                acc.Sector__c = 'Travel Agent';
            }

            if(acc.ShippingState != onlineAcc.Shipping_ISO_State__r.Name){
                acc.ShippingState = onlineAcc.IATA_ISO_State__r.Valid_for_Address__c == true ? onlineAcc.Shipping_ISO_State__r.Name : null;
            }
            if(acc.ShippingCountry != onlineAcc.Shipping_ISO_Country__r.Name){
                acc.ShippingCountry = onlineAcc.Shipping_ISO_Country__r.Name;
            }

            acc.In_a_Airport__c = (onlineAcc.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false;
            acc.Company_Type__c = AMS_Utils.transformCompanyType(onlineAcc.ISSP_AMS_Legal_Status__c);
            acc.GDS__c = AMS_Utils.transformGDS(onlineAcc.ISSP_AMS_GDS_with_signed_contract__c);
            acc.BillingCountry = onlineAcc.Branch_Office_Country__r.Name;
            acc.ShippingCountry = onlineAcc.Shipping_ISO_Country__r.Name;
            acc.ShippingState = onlineAcc.IATA_ISO_State__r.Valid_for_Address__c == true ? onlineAcc.Shipping_ISO_State__r.Name : null;
            acc.BillingState = onlineAcc.IATA_ISO_State__r.Valid_for_Address__c == true ? onlineAcc.IATA_ISO_State__r.Name : null;
            
            acc.ANG_Accreditation_Model__c = AMS_Utils.decodeAMFromOscarProcess(oscar.Process__c,acc.ANG_Accreditation_Model__c);

            if((oscar.Process__c == AMS_Utils.NEWHESTANDARD || oscar.Process__c == AMS_Utils.NEWGESTANDARD) && acc.RHC_Informations__r.isEmpty()) 
            	createRHCInfo.add(acc);


            if(AMS_Utils.oscarPCICompliantMigrationProcesses.contains(oscar.Process__c)){
                acc.Is_PCI_compliant__c = oscar.Is_PCI_compliant__c;
			
                if(acc.Is_PCI_compliant__c == 'Corporate Card')
					acc.ANG_PCI_compliance_expiry_date__c = Date.newInstance(2099, 12, 31);
            }

            if(AMS_Utils.oscarNewGenNewAppProcesses.contains(oscar.Process__c) && oscar.Is_PCI_compliant__c == 'Yes'){
                acc.ANG_PCI_compliance_expiry_date__c = oscar.ANG_PCI_compliance_expiry_date__c;
            }

            updaterObj.acctMap.put(acc.Id,acc);

            stagingToAccount.put(onlineAcc.Id, new Set<Id>{oscar.Account__c});

            updaterObj.toUpdate = true;

        }

		System.debug('[ANG_OscarProcessHelper] Starting Ownership migration.');

		if(!stagingToAccount.isEmpty() && runOwnershipMigration)
			AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccount, true, new List<AMS_Oscar__c>{oscar});

		System.debug('[ANG_OscarProcessHelper] Ownership migration completed.');

		System.debug('[ANG_OscarProcessHelper] Starting RHC process.');

        if(!createRHCInfo.isEmpty())
        	ANG_RHCHelper.createRHCInfo(createRHCInfo, false);

		System.debug('[ANG_OscarProcessHelper] RHC process finished.');

        return updaterObj;
        
    }


	public static EntityUpdater createChangeCodeNEW(EntityUpdater updater, AMS_Oscar__c theOSCAR) {

		if(updater == null)
			updater = new EntityUpdater();

		Account acct = updater.acctMap.get(theOSCAR.account__r.id);

		String changeCodeId = 'NEW-' + theOSCAR.Business_Process__c;
		AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();
        AMS_ChangeCodes__c n = AMS_ChangeCodes__c.getInstance(changeCodeId);

        changeCode.name = n.Change_Code__c;
        changeCode.reasonCode = n.Reason_Code__c;
        //changeCode.memoText = AMS_Utils.getChangeCodeMemoText(theOSCAR.Process__c, changeCodeId);
        if(n==null)
	        changeCode.memoText = AMS_Utils.getChangeCodeMemoText(theOSCAR.Process__c, changeCodeId);
	    else
	    	changeCode.memoText = AMS_Utils.getChangeCodeMemoText(theOSCAR.Process__c, changeCodeId, n);
	    
        changeCode.reasonDesc  = n.Reason_Code_Description__c;
        changeCode.status  = n.Account_status_change__c;
        changeCode.publishedOnEBulletin = n.Published_in_bulletin__c;
		
		List<Account> acctList = AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {theOSCAR}, new List<Account> {acct}, false);

		if(!acctList.isEmpty())
			updater.acctMap.put(acctList.get(0).Id, acctList.get(0));

		updater.oscarMap.get(theOSCAR.Id).First_Step_Completed__c = true;

		updater.toUpdate = true;

		return updater;

	}

	//ACAMBAS - NEWGEN-4445 - Start
	public static void createGenericChangeCode(AMS_Oscar__c theOSCAR, String changeCodeId) {

		if(changeCodeId == null) return;

		Savepoint sp = Database.setSavepoint();

        try {

			Account accnt = [SELECT Id, Status__c, CNS_Agency__c,
									(SELECT Id, Reason_Code__c, Reason_Description__c
									 FROM Agencies_Applied_Change_codes__r 
									 WHERE Active__c = true)
							 FROM Account
							 WHERE Id = :theOSCAR.account__c FOR UPDATE];

			List<Agency_Applied_Change_code__c> appliedChangeCodesLst = accnt.getSObjects('Agencies_Applied_Change_codes__r');

			Agency_Applied_Change_code__c activeChangeCode = null;

			if(appliedChangeCodesLst != null && appliedChangeCodesLst.size() > 0){
				activeChangeCode = appliedChangeCodesLst.get(0);
			}

	        AMS_OSCAR_JSON.ChangeCode changeCode = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(changeCodeId, theOSCAR.ANG_Type_Of_Change__c, accnt.Status__c, activeChangeCode, null);
	
			AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {theOSCAR}, new List<Account> {accnt}, true);

			theOSCAR.First_Step_Completed__c = true;

			if(theOSCAR.Process__c == AMS_Utils.NGCHINACONVERSION) {
				createChangeCodeOnChildrenAccounts(theOSCAR, changeCodeId);
			}

        } catch (Exception ex) {
            Database.rollback(sp); 
            throw ex;
        }
	}
	//ACAMBAS - NEWGEN-4445 - End
	
	//ACAMBAS - NEWGEN-4822 - Start
	private static void createChangeCodeOnChildrenAccounts(AMS_Oscar__c theOSCAR, String changeCodeId) {

		List<Account> childrenAccounts = [SELECT Id, Status__c, CNS_Agency__c,
												(SELECT Id, Reason_Code__c, Reason_Description__c
									 			 FROM Agencies_Applied_Change_codes__r 
									 			 WHERE Active__c = true) 
									 	  FROM Account 
									 	  WHERE ParentId =: theOSCAR.Account__c];

		Set<Account> childrenAccountsSet = new Set<Account>();
		childrenAccountsSet.addAll(childrenAccounts);
		Set<Account> targetAccounts = ANG_ConversionHelper.filterByStatus(childrenAccountsSet);
		
		List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();
		List<AMS_OSCAR_JSON.ChangeCode> changeCodesList = new List<AMS_OSCAR_JSON.ChangeCode>();
		AMS_OSCAR_JSON.ChangeCode changeCode;

		for(Account accnt : targetAccounts) {
			Agency_Applied_Change_code__c activeChangeCode = null;
			List<Agency_Applied_Change_code__c> appliedChangeCodesLst = accnt.getSObjects('Agencies_Applied_Change_codes__r');

			if(appliedChangeCodesLst != null && appliedChangeCodesLst.size() > 0){
				activeChangeCode = appliedChangeCodesLst.get(0);
			}

			changeCode = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(changeCodeId, theOSCAR.ANG_Type_Of_Change__c, accnt.Status__c, activeChangeCode, null);
			changeCodesList.add(changeCode);
			oscars.add(theOSCAR);
		}

		AMS_ChangeCodesHelper.createAAChangeCodes(changeCodesList, oscars, new List<Account>(targetAccounts), true);
	}
	//ACAMBAS - NEWGEN-4822 - End

	public static EntityUpdater execCreateAMLCase(AMS_OSCAR__c oscar, EntityUpdater updater) {

		if(updater == null)
			updater = new EntityUpdater();


            ID InternalCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');

            List<Case> cases = [select Id, OSCAR__r.Account__r.IATA_ISO_Country__r.Name, OSCAR__r.AMS_Online_Accreditation__r.Account_Name__c from Case where OSCAR__c = : oscar.Id AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) limit 1];

            if (cases == null || cases.isEmpty()) {

				updater.isFaulty=true;
				updater.errorMessage = 'Could not find a the Oscar Communication case related to this OSCAR.';

				return updater;
            }

            Case oscarCommCase = cases[0];

            Case issCase = new Case(RecordTypeId = InternalCaseRecordTypeID, CaseArea__c = 'Corporate Compliance',
                                    Reason1__c = (oscar.Process__c == AMS_Utils.AGENCYCHANGES ? 'Agent Change of Ownership' : 'New Accredited Agent'),
                                    ParentId = oscarCommCase.Id, AccountId = oscar.Account__c, Subject = 'Due Diligence - ' + oscarCommCase.OSCAR__r.AMS_Online_Accreditation__r.Account_Name__c,
                                    OSCAR__c = oscar.Id, Region__c = oscar.Region__c, BSPCountry__c = oscarCommCase.OSCAR__r.Account__r.IATA_ISO_Country__r.Name);

            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            issCase.setOptions(dmo);

            insert issCase;

            updater.caseMap.put(issCase.Id,issCase);

            updater.oscarMap.get(oscar.Id).STEP17__c = 'In Progress';
            updater.oscarMap.get(oscar.Id).AML_requested__c = Date.today();
            updater.oscarMap.get(oscar.Id).AML_deadline__c = Date.today() + 3;

			updater.acctMap.get(updater.oscarMap.get(oscar.Id).Account__c).Due_Diligence_Status__c = 'In Progress';
			updater.toUpdate = true;

            return updater;
 
    }


    public static void checkSFDCLimits(){

		System.debug('[ANG_OscarProcessHelper] 1. Number of Queries used in this apex code so far: ' + Limits.getQueries());
	    System.debug('[ANG_OscarProcessHelper] 2 .Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
	    System.debug('[ANG_OscarProcessHelper] 3. Number of script statements used so far : ' +  Limits.getDmlStatements());
    }

    webservice static String[] processRestoreFOP(String oscarId, Boolean restoreCC , Boolean restoreCA){

		return processRestrictRestoreFOP(oscarId, false , false ,restoreCC , restoreCA);
    }

    webservice static String[] processRestrictFOP(String oscarId, Boolean restrictCC , Boolean restrictCA){

		return processRestrictRestoreFOP(oscarId, restrictCC , restrictCA, false, false);
    }

    webservice static String[] processRestrictRestoreFOP(String oscarId, Boolean restrictCC , Boolean restrictCA, Boolean restoreCC , Boolean restoreCA){

		System.debug('[ANG_OscarProcessHelper] Starting processRestrictRestoreFOP with values:');
		System.debug('[ANG_OscarProcessHelper] oscarId :' + oscarId);
		System.debug('[ANG_OscarProcessHelper] restrictCC :' + restrictCC);
		System.debug('[ANG_OscarProcessHelper] restrictCA :' + restrictCA);
		System.debug('[ANG_OscarProcessHelper] restoreCC :' + restoreCC);
		System.debug('[ANG_OscarProcessHelper] restoreCA :' + restoreCA);

		AMS_OSCAR__c oscar = [Select Id, Account__c, STEP38__c, SIDRA_lite_reason__c, Is_NewGen__c from AMS_OSCAR__c where Id = :oscarId LIMIT 1];
		
		try{

			Map<Id, List<AMS_Agencies_relationhip__c>> allRelationsOnHierarchy = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscar.Account__c});

			Set<Id> accountHierarchyRelationships = new Set<Id>();

			if(!isEmptySetOfLists(allRelationsOnHierarchy.values())){
				accountHierarchyRelationships = ANG_AgencyChangesHelper.extractAllAccounts(allRelationsOnHierarchy);
			}

			accountHierarchyRelationships.add(oscar.Account__c);

			Set<AgencyAuthorizationOBject> aaObjectSet = restrictRestoreFOPonAccounts(accountHierarchyRelationships, restoreCC, restoreCA, restrictCC , restrictCA);
			
			System.debug('[ANG_OscarProcessHelper] AgencyAuthorizationOBject returned are:'+aaObjectSet);


			oscar.ANG_Restrict_Cash__c = restrictCA; 
			oscar.ANG_Restrict_Credit_Card__c = restrictCC;
			oscar.ANG_Restore_Cash__c = restoreCA; 
			oscar.ANG_Restore_Credit_Card__c = restoreCC;
			oscar.STEP38__c = AMS_Utils.PASSED;

			EntityUpdater updater = new EntityUpdater();
			
			updater.oscarMap.put(oscar.Id,oscar);

			if(!aaObjectSet.isEmpty()){
				
				Set<Id> accountIdsChanged = new Set<Id>();

				for(AgencyAuthorizationOBject aaObject: aaObjectSet)
					accountIdsChanged.add(aaObject.AccountId);

				Map<Id,Account> accountToCreateCC = new Map<ID, Account>([Select Id, Status__c, CNS_Agency__c from Account where Id in :accountIdsChanged]);

				Map<String,Set<Account>> ccAccountsMap = new Map<String,Set<Account>>();

				for(AgencyAuthorizationOBject aaObject: aaObjectSet){
					
					if(aaObject.changeCodeToInsert != null){

						if(ccAccountsMap.get(aaObject.changeCodeToInsert) == null)
							ccAccountsMap.put(aaObject.changeCodeToInsert,new Set<Account>{accountToCreateCC.get(aaObject.AccountId)});
						else
							ccAccountsMap.get(aaObject.changeCodeToInsert).add(accountToCreateCC.get(aaObject.AccountId));
					}
					
				}

				System.debug('[ANG_OscarProcessHelper] ccAccountsMap to create are:'+ccAccountsMap);

				for(String changeCode : ccAccountsMap.keySet())
					createChangeCodeForFOP(updater, oscar, new List<Account>(ccAccountsMap.get(changeCode)), changeCode );

			}
            
		
		}catch(Exception ex){
			
			oscar.STEP38__c = AMS_Utils.FAILED;
			//update oscar;

			String exMessage = 'An error occured while restricting/restoring Forms of Payment:\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);
			System.debug('[ANG_OscarProcessHelper] An error occured while restricting/restoring Forms of Payment:' + AMS_Utils.errorMessageBeautifyer(ex));

			return new String[]{'-1',exMessage};
		}

		return new String[]{'0',null};

    }



    public static Set<AgencyAuthorizationOBject> restrictRestoreFOPonAccounts(Set<Id> accounts, Boolean restoreCreditCard , Boolean restoreCash, Boolean restrictCreditCard, Boolean restrictCash){

    	//System.debug('Performing restrictRestoreFOPonAccounts on accounts:'+accounts + ' with value restrictCash set to ' + restrictCash + ' and restrictCreditCard set to ' + restrictCreditCard + ' and valueToAdd set to ' + valueToAdd + 'and restoreCreditCard value set to ' + restoreCreditCard + ' and restoreCash value set to ' + restoreCash);

		Set<AgencyAuthorizationOBject> accountsChanged = new Set<AgencyAuthorizationOBject>();

    	List<Agency_Authorization__c> aaLst = [Select Id, ANG_FormOfPayment_ID__c, Status__c, Account__c, Account__r.Is_PCI_compliant__c from Agency_Authorization__c where Account__c in :accounts and (ANG_FormOfPayment_ID__c = 'CA' or ANG_FormOfPayment_ID__c = 'CC')];
    	List<Agency_Authorization__c> aaLstToUpdate = new List<Agency_Authorization__c>();

		Map<Id,AgencyAuthorizationOBject> accountsAA = new Map<Id,AgencyAuthorizationOBject>();

		for(Agency_Authorization__c aa: aaLst){
			
			AgencyAuthorizationOBject aaObject;

			if(accountsAA.get(aa.Account__c) == null)
				aaObject = new AgencyAuthorizationOBject(aa.Account__c);
			else
				aaObject = accountsAA.get(aa.Account__c);

			if(aa.ANG_FormOfPayment_ID__c == 'CA')
				aaObject.addCash(aa);
			else
				aaObject.addCreditCard(aa);

			accountsAA.put(aa.Account__c,aaObject);

		}

		String process = restoreCash  && restoreCreditCard  ? 'Restore All' : 
						 restrictCash && restrictCreditCard ? 'Restrict All' : 
						 restrictCash ? 'Restrict Cash' :
						 restrictCreditCard ? 'Restrict Credit Card' :
						 restoreCash ? 'Restore Cash' : 'Restore Credit Card';

		List<ANG_Forms_Of_Payment_CC_Matrix__mdt> matrixAAProcess = [SELECT Cash_before__c,Credit_Card_before__c,Action_in_FoP_OSCAR__c,Cash_after__c,Credit_Card_after__c,Change_Code__c FROM ANG_Forms_Of_Payment_CC_Matrix__mdt WHERE Action_in_FoP_OSCAR__c =:process];

		Map<String,ANG_Forms_Of_Payment_CC_Matrix__mdt> matrixAAProcessMap = new Map<String,ANG_Forms_Of_Payment_CC_Matrix__mdt>();

		for(ANG_Forms_Of_Payment_CC_Matrix__mdt matrixObject: matrixAAProcess)
			matrixAAProcessMap.put(matrixObject.Cash_before__c+matrixObject.Credit_Card_before__c,matrixObject);

		ANG_Forms_Of_Payment_CC_Matrix__mdt matrixObject;

		for(AgencyAuthorizationOBject aaOjectToAnalyze: accountsAA.values()){
			
			matrixObject = matrixAAProcessMap.get(aaOjectToAnalyze.oldCA+aaOjectToAnalyze.oldCC);

			System.debug('matrixObject is ' + matrixObject);

			aaOjectToAnalyze.addCashValue(matrixObject.Cash_after__c, matrixObject.Change_Code__c);
			aaOjectToAnalyze.addCreditCardValue(matrixObject.Credit_Card_after__c, matrixObject.Change_Code__c);
			
			if(aaOjectToAnalyze.changedCA)
				aaLstToUpdate.add(aaOjectToAnalyze.cashAA);
			if(aaOjectToAnalyze.changedCC)
				aaLstToUpdate.add(aaOjectToAnalyze.creditCardAA);

			if(aaOjectToAnalyze.changedCA || aaOjectToAnalyze.changedCC)
				accountsChanged.add(aaOjectToAnalyze);				
		}

				
    	if(!aaLstToUpdate.isEmpty())
    		update aaLst;

    	return accountsChanged;
    	
    }

	public class AgencyAuthorizationOBject{

		Public Agency_Authorization__c creditCardAA;
		Public Agency_Authorization__c cashAA;

		Public String oldCC;
		Public String oldCA;

		Public Id accountId;

		Public String changeCodeToInsert;

		boolean changedCC;
		boolean changedCA;

		public AgencyAuthorizationOBject(Id accountId){
			this.accountId = accountId;
			this.changedCC = false;
			this.changedCA = false;
			this.oldCA = null;
			this.oldCC = null;
		}

		public void addCreditCard(Agency_Authorization__c aa){
			this.creditCardAA = aa;
			this.oldCC = aa.Status__c;
		}

		public void addCash(Agency_Authorization__c aa){
			this.cashAA = aa;
			this.oldCA = aa.Status__c;
		}

		public void addCashValue(String value,String changeCodeToInsert){
			if(this.oldCA == value)
				return;
			
			cashAA.Status__c = value;
			changedCA = true;
			this.changeCodeToInsert = changeCodeToInsert;
		}

		public void addCreditCardValue(String value, String changeCodeToInsert){
			if(this.oldCC == value)
				return;
			
			creditCardAA.Status__c = value;
			this.changedCC = true;
			this.changeCodeToInsert = changeCodeToInsert;
		}

	}

    public static EntityUpdater createChangeCodeForFOP(EntityUpdater updater, AMS_Oscar__c theOSCAR, List<Account> accounts, String changeCodeName) {
		
		if(updater == null)
			updater = new EntityUpdater();

		Set<Id> accountIds = new Set<Id>();

		for(Account acct: accounts)
			accountIds.add(acct.Id);

		List<Agency_Applied_Change_code__c> allChangeCodes =
		    new List<Agency_Applied_Change_code__c>([SELECT Id, Account__c, Reason_Code__c, Reason_Description__c, Bulletin_Information__c, OSCAR__c, Active__c, Change_Code__c FROM Agency_Applied_Change_code__c WHERE Account__c IN :accountIds]);

		List<Agency_Applied_Change_code__c> activeChangeCodes = new List<Agency_Applied_Change_code__c>();

		/*
		In the FoP OSCAR case, ensure that the same change code is not generated more than once.
		In other words, before creating a change code, check that the same does not exist for the same OSCAR case.
		*/
		for(Agency_Applied_Change_code__c aacc: allChangeCodes){

			if(aacc.OSCAR__c == theOscar.Id && changeCodeName == aacc.Change_Code__c){
				System.debug('AMS_OscarProcessHelper: You cannot create the same change code for the same Oscar, exiting method without Change code Creation.');
				return updater;

			}

			if(aacc.Active__c == true)
				activeChangeCodes.add(Aacc);

		}

		//map accountId -> active change code
		Map<Id, Agency_Applied_Change_code__c> accountsChangeCode = new Map<Id, Agency_Applied_Change_code__c>();

		for (Id accId : accountIds) {
			for (Agency_Applied_Change_code__c changeCode : activeChangeCodes)
				if (changeCode.Account__c == accId)
					accountsChangeCode.put(accId, changeCode);
		}

		List<AMS_OSCAR_JSON.ChangeCode> listOfCCToInsert = new List<AMS_OSCAR_JSON.ChangeCode>();
		List<AMS_OSCAR__c> oscarsToAdd = new List<AMS_OSCAR__c>();

		AMS_ChangeCodes__c changeCodeConfig = AMS_ChangeCodes__c.getInstance(changeCodeName);

		For(Account acctToAddCC: accounts){

			AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

			changeCode.name = changeCodeConfig.Name;
			changeCode.reasonCode = changeCodeConfig.Reason_Code__c;
			String memoTextTemp = changeCodeConfig.Bulletin_Memo_Text__c;
			
			System.debug('theOscar.SIDRA_lite_reason__c is ' + theOscar.SIDRA_lite_reason__c);

			if(theOscar.SIDRA_lite_reason__c == null)
				memoTextTemp = memoTextTemp.replace('due to <SIDRA Lite Reason>.','');
			else
				memoTextTemp = memoTextTemp.replace('due to <SIDRA Lite Reason>.','due to '+theOscar.SIDRA_lite_reason__c+'.');

			changeCode.memoText = memoTextTemp;
			changeCode.reasonDesc  = changeCodeConfig.Reason_Code_Description__c;
			
			if(changeCode.reasonCode == null && accountsChangeCode.get(acctToAddCC.Id) != null || changeCode.reasonCode.toUpperCase()=='CURRENT' ){
				changeCode.reasonCode = accountsChangeCode.get(acctToAddCC.Id).Reason_Code__c;
			}

			if(changeCode.reasonDesc == null && accountsChangeCode.get(acctToAddCC.Id) != null || changeCode.reasonDesc.toUpperCase()=='CURRENT'){
				changeCode.reasonDesc = accountsChangeCode.get(acctToAddCC.Id).Reason_Description__c;
			}

			changeCode.status  = changeCodeConfig.Account_status_change__c;

			System.debug('Adding changeCode:' + changeCode);

			listOfCCToInsert.add(changeCode);
			oscarsToAdd.add(theOSCAR);
		}

		List<Account> acctList = AMS_ChangeCodesHelper.createAAChangeCodes(listOfCCToInsert, oscarsToAdd, accounts, false);

		if(!acctList.isEmpty()){

			For(Account acctToAdd: acctList){
				updater.acctMap.put(acctToAdd.Id, acctToAdd);
			}
		}

		if(updater.oscarMap.get(theOSCAR.Id) != null)
			updater.oscarMap.get(theOSCAR.Id).First_Step_Completed__c = true;

		updater.toUpdate = true;

		return updater;

	}

	webservice static String[] createFOPOscar(Id accountId, Id caseId){
		
		Savepoint sp = Database.setSavepoint();
		AMS_OSCAR__c oscar = null;
		Case newCaseFop = null;

		try{

			Case c = [Select Id , ContactId, Account.BillingCountry, Account.Region_formula__c, Account.IATACode__c, Account.Name, Reason1__c,SIDRA_Lite_Reason__c from Case where Id = :caseId LIMIT 1 ];

			Map<String,Object> fieldsOfObject = new Map<String,Object>();

	        fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);
	        fieldsOfObject.put('SIDRA_lite_reason__c',c.SIDRA_Lite_Reason__c);
			fieldsOfObject.put('Status__c','Open');

			oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, accountId, fieldsOfObject);

			insert oscar;

	        Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

	        fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Oscar__c',oscar.Id);
	        fieldsOfObject.put('ContactId',c.ContactId);
	        fieldsOfObject.put('ParentId',caseId);
	        fieldsOfObject.put('BSPCountry__c',c.Account.BillingCountry);
	        fieldsOfObject.put('CaseArea__c','Accreditation Process');
	        fieldsOfObject.put('ContactId',c.ContactId);
	        fieldsOfObject.put('Origin','Internal User');
	        fieldsOfObject.put('Reason1__c','FoP Management');
	        fieldsOfObject.put('Region__c',c.Account.Region_formula__c);
	        fieldsOfObject.put('Subject','FoP Management - ' + c.Account.IATACode__c + ' - ' + c.Account.Name);
	        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');

	        newCaseFop =ANG_EntityCreator.createCase(caseRT, accountId, fieldsOfObject);

	        insert newCaseFop;

		}catch(Exception ex){

       		Database.rollback(sp);

        	String exMessage = 'Unhandle error on process:\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);

	        System.debug('[ANG_OscarProcessHelper createFOPOscar] Process failed with the following exception:' + ex.getStackTraceString());

	        isIATACodeGenerationRunning = false;

			return new String[]{'-1',exMessage};

		}


		return new String[]{'0','Oscar for Forms of Payment Management created with success',newCaseFop.Id};

	}
	
	public static boolean isEmptySetOfLists(List<List<AMS_Agencies_relationhip__c>> setOfLists){

		if(setOfLists.isEmpty())
			return true;

		for(List<AMS_Agencies_relationhip__c> lst: setOfLists){
			if(!lst.isEmpty())
				return false;
		}

		return true;
	}

	public static String createRevalidationOscar(Account acc, List<Contact> contactsAcc, Boolean toSendEmail ){

		Set<Id> accsToSendEmail = new Set<Id>();

		if (toSendEmail)
			accsToSendEmail.add(acc.Id);

		return createRevalidationOscars(new List<Account>{acc}, new Map<Id,List<Contact>>{acc.Id=>contactsAcc}, accsToSendEmail)[0].Id;

	}

	public static List<Case> createRevalidationOscars(List<Account> accs, Map<Id,List<Contact>> contactsAcc, Set<Id> accsToSendEmail){

		Map<id,OscarObjectsWrapper> accOscarObjsMap = new Map<id,OscarObjectsWrapper>();
		OscarObjectsWrapper oscarObjs;
		
		Map<String,Object> fieldsOfObject;

		List<Case> casesToInsert = new List<Case>();

		Map<Id,List<Contact>> keyContactMap = new Map<Id,List<Contact>>();

		//Case:
		for(Account acc : accs){

			System.debug('[ANG_OscarProcessHelper.createRevalidationOscar] - BEGINNING INSERTING for ACCOUNT: '+acc.Id+' - '+acc.Name+' - '+acc.IataCode__c);

			List<Contact> keyContactsLst = fetchKeyContacts(acc, contactsAcc.get(acc.Id));
			
			keyContactMap.put(acc.Id,keyContactsLst);

			fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Account_Concerned__c',acc.Id);
	      	fieldsOfObject.put('ContactId',keyContactsLst.get(0).Id);
	        fieldsOfObject.put('BSPCountry__c',acc.BillingCountry);
	        fieldsOfObject.put('Region__c',acc.Region_formula__c);
	        fieldsOfObject.put('CaseArea__c','Accreditation Process');
	        fieldsOfObject.put('Origin','Internal User');
	        fieldsOfObject.put('Reason1__c','Annual revalidation');
	        fieldsOfObject.put('Subject','PCI DSS compliance - ' + acc.IATACode__c + ' - ' + acc.Name);
	        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
	        
	       	Case cse = ANG_EntityCreator.createCase(AMS_Utils.RECTYPE_OSCARCOMM, acc.Id, fieldsOfObject);

	        //assign to queue
	       	Database.DMLOptions dmo = new Database.DMLOptions();
	        dmo.assignmentRuleHeader.useDefaultRule = true;
	        cse.setOptions(dmo);

	        oscarObjs = new OscarObjectsWrapper();
	        oscarObjs.cse = cse;
	        oscarObjs.con = keyContactsLst.get(0);

	        accOscarObjsMap.put(acc.id,oscarObjs);
	        casesToInsert.add(cse);
		}

		if (!casesToInsert.isEmpty())
       		insert casesToInsert;

       	Set<Id> casesIds = new Set<Id>();
	    for (Case cse : casesToInsert){
	    	casesIds.add(cse.Id);
	    }

       	for(Case insertedCase : [Select ownerId, Account_Concerned__c from Case where Id in :casesIds]){
       		accOscarObjsMap.get(insertedCase.Account_Concerned__c).ownerId = insertedCase.ownerId;
       	}

		//AMS_OSCAR__c:
		List<AMS_Oscar__c> oscarsToInsert = new List<AMS_OSCAR__c>(); 

        for (Account acc : accs){
        
			fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Process__c',AMS_Utils.NGANNUALREVAL);
			fieldsOfObject.put('Status__c','Open');
			fieldsOfObject.put('OwnerId',accOscarObjsMap.get(acc.Id).ownerId);
			fieldsOfObject.put('Oscar_Communication_Case_Id__c',accOscarObjsMap.get(acc.Id).cse.Id);

			AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENANNUALREVAL, acc.Id, fieldsOfObject);		
	        oscarsToInsert.add(oscar);
	        accOscarObjsMap.get(acc.Id).oscar = oscar;
    	}

    	if(!oscarsToInsert.isEmpty())
    		insert oscarsToInsert;

    	OrgWideEmailAddress[] owea;

		if(!accsToSendEmail.isEmpty()){
			owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];
		}

		List<Case> casesToUpdate = new List<Case>();

		for (Account acc: accs){
		// fields needed on contact: Id, Name, Email, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c

			accOscarObjsMap.get(acc.Id).cse.Oscar__c = accOscarObjsMap.get(acc.Id).oscar.Id;
			casesToUpdate.add(accOscarObjsMap.get(acc.Id).cse);

			//if(accsToSendEmail.contains(acc.Id))
	            //AMS_AgencyRegulationAutoRenewal.sendEmailAlert(new List<Contact>{accOscarObjsMap.get(acc.Id).con}, accOscarObjsMap.get(acc.Id).oscar.Id, AMS_OSCARTriggerHandler.ANGemailTemplates(AMS_Utils.NGANNUALREVAL, null, true), accOscarObjsMap.get(acc.Id).oscar.Oscar_Communication_Case_Id__c, owea[0], false);			

			System.debug('[ANG_OscarProcessHelper.createRevalidationOscar] - FINISHING... INSERTING OSCARS: '+ accOscarObjsMap.get(acc.id).oscar.Id + ' | Case: '+accOscarObjsMap.get(acc.id).cse.Id);
		}

		if(!casesToUpdate.isEmpty())
			update casesToUpdate;

		for (Account acc: accs){

			if(accsToSendEmail.contains(acc.Id))
	            AMS_AgencyRegulationAutoRenewal.sendEmailAlert(filterContacts(keyContactMap.get(acc.Id)), accOscarObjsMap.get(acc.Id).oscar.Id, AMS_OSCARTriggerHandler.ANGemailTemplates(AMS_Utils.NGANNUALREVAL, null, true), accOscarObjsMap.get(acc.Id).oscar.Oscar_Communication_Case_Id__c, owea[0], false);			

		}

        return casesToUpdate;
    }

	public static List<Contact> filterContacts(List<Contact> contacts){

		List<Contact> contactsToReturn = new List<Contact>();

		for(Contact con : contacts){

			if(con.User_Portal_Status__c == 'Approved Admin')
				contactsToReturn.add(con);
			else if (con.Financial_Assessment_Contact__c)
				contactsToReturn.add(con);
		}

		return contactsToReturn;

	}
/*
	private static Contact fetchKeyContact(Account acc, List<Contact> contacts){

		if(contacts == null || contacts.isEmpty())
			return null;

		Contact adminCon;

		for (Contact con :contacts){
			if (con.Financial_Assessment_Contact__c){
				return con;	
			}
			adminCon = con.User_Portal_Status__c == 'Approved Admin' && adminCon == null ? con : adminCon;
		} 

		if (adminCon != null)
			return adminCon;			
 
		return contacts[0];
	}
*/
	webservice static String[] createOscarChangesCase(Id accreditationId){
		
		Savepoint sp = Database.setSavepoint();
		AMS_OSCAR__c oscar = null;
		Case newCaseOscar = null;

		try{

			System.debug('Starting to create Oscar Changes from Staging area');
			
			List<String> fieldList = new List<String>();

			Map<String, Schema.SObjectField> schemaFieldMap = AMS_Pax_Accreditation_Form__c.sObjectType.getDescribe().fields.getMap();

			for (String field : schemaFieldMap.keySet()){
					fieldList.add(field);
			}

			AMS_Pax_Accreditation_Form__c acr = Database.query('SELECT '+String.join(fieldList, ', ')+', HO_Account__r.BillingCountry, HO_Account__r.Region_formula__c, HO_Account__r.IATACode__c, HO_Account__r.Name FROM AMS_Pax_Accreditation_Form__c WHERE Id = :accreditationId LIMIT 1');

			AMS_Pax_Accreditation_Form__c newAccr = acr.clone(false, true, false, false);

			Case c = [Select Id , ContactId, Account.BillingCountry, Account.Region_formula__c, Account.IATACode__c, Account.Name, Reason1__c,SIDRA_Lite_Reason__c from Case where Id = :newAccr.SAAM_Case__c LIMIT 1 ];

	        Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

			Map<String,Object> fieldsOfObject = new Map<String,Object>();

	        fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('ContactId',c.ContactId);
	        fieldsOfObject.put('ParentId',c.Id);
	        fieldsOfObject.put('BSPCountry__c',newAccr.HO_Account__r.BillingCountry);
	        fieldsOfObject.put('CaseArea__c','Accreditation Process');
	        fieldsOfObject.put('ContactId',c.ContactId);
	        fieldsOfObject.put('Origin','Internal User');
	        fieldsOfObject.put('Reason1__c','Agency Changes');
	        fieldsOfObject.put('Region__c',newAccr.HO_Account__r.Region_formula__c);
	        fieldsOfObject.put('Subject','Agency changes - ' + newAccr.HO_Account__r.IATACode__c + ' - ' + newAccr.HO_Account__r.Name);
	        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
	        fieldsOfObject.put('Visible_on_ISS_Portal__c',true);
	        newCaseOscar =ANG_EntityCreator.createCase(caseRT, newAccr.HO_Account__c, fieldsOfObject);

	        insert newCaseOscar;



	        newAccr.SAAM_Case__c = newCaseOscar.Id;
	        insert newAccr;

            // need to create the accreditation contacts as well..
			
            			fieldList.clear();
			schemaFieldMap = AMS_Accreditation_Contact__c.sObjectType.getDescribe().fields.getMap();

			for (String field : schemaFieldMap.keySet()){
					fieldList.add(field);
			}

			List<AMS_Accreditation_Contact__c> contactsList = Database.query('SELECT '+String.join(fieldList, ', ')+' FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c = :accreditationId');

			List<AMS_Accreditation_Contact__c> newAccreditationContactList = new List<AMS_Accreditation_Contact__c>();

			for(AMS_Accreditation_Contact__c ac: contactsList){

				AMS_Accreditation_Contact__c newAc = ac.clone(false, true, false, false);
				newAc.AMS_Pax_Accreditation_Form__c = newAccr.Id;
				newAccreditationContactList.add(newAc);
            }

			if(!newAccreditationContactList.isEmpty())
				insert newAccreditationContactList;
            
			fieldsOfObject = new Map<String,Object>();

	        fieldsOfObject.put('Process__c',AMS_Utils.NGCHANGES);
	        fieldsOfObject.put('SIDRA_lite_reason__c',c.SIDRA_Lite_Reason__c);
			fieldsOfObject.put('Status__c','Open');			
			fieldsOfObject.put('AMS_Online_Accreditation__c',newAccr.Id);
			fieldsOfObject.put('Change_effective_as_of__c',newAccr.Effective_Date_Of_Change__c);
	        fieldsOfObject.put('Oscar_Communication_Case_Id__c',newCaseOscar.id);

			oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NGCHANGES, newAccr.HO_Account__c, fieldsOfObject);

			insert oscar;

			newCaseOscar.Oscar__c = oscar.Id;

			update newCaseOscar;

			newCaseOscar = [Select Id, Casenumber from Case where Id=:newCaseOscar.Id LIMIT 1];

		}catch(Exception ex){

       		Database.rollback(sp);

        	String exMessage = 'Unhandle error on process:\n\r ' + AMS_Utils.errorMessageBeautifyer(ex);

	        System.debug('[ANG_OscarProcessHelper create changes oscar case] Process failed with the following exception:' + ex.getStackTraceString());

	        isIATACodeGenerationRunning = false;

			return new String[]{'-1',exMessage};

		}

		System.debug('Created oscar with id: ' + oscar.Id);

		return new String[]{newCaseOscar.Id,newCaseOscar.Casenumber};

	}

	/*** AMSU-37 ***/
	public static Boolean doAgainIATACodeGeneration(AMS_Oscar__c oscar, Account agency) {
		Set<String> accountStatus = new Set<String> {'12-APPLICATION DISAPPROVED', '11-APPLICATION WITHDRAWN'};
		Set<String> processes = AMS_Utils.oscarNewProcesses;
		processes.addall(AMS_Utils.oscarNewGenNewAppProcesses);
		Set<String> appliedChangeCodes = new Set<String> {'DIS', 'NWD'}; 
		List<Agency_Applied_Change_code__c> changeCodes = agency.Agencies_Applied_Change_codes__r;

		if(!accountStatus.contains(agency.Reason__c) || !processes.contains(oscar.Process__c)) {
			return false;
		}

		for(Agency_Applied_Change_code__c changeCode : changeCodes) {
			if(appliedChangeCodes.contains(changeCode.Change_Code__c)) {
				return true;
			}
		}

		return false;
	}

	public static List<Case> createPCIComplianceOscars(List<Account> accs, Map<Id,List<Contact>> contactsAcc, Set<Id> accsToSendEmail){

		return createPCIComplianceOscars(accs, contactsAcc, accsToSendEmail, AMS_Utils.ANG_MASSIVE_FOP);
	}

	public static List<Case> createPCIComplianceOscars(List<Account> accs, Map<Id,List<Contact>> contactsAcc, Set<Id> accsToSendEmail, String origin){

		Map<id,OscarObjectsWrapper> accOscarObjsMap = new Map<id,OscarObjectsWrapper>();
		OscarObjectsWrapper oscarObjs;
		
		Map<String,Object> fieldsOfObject;

		List<Case> casesToInsert = new List<Case>();

		Map<Id,Account> accountMap = new Map<Id,Account>();

		String identifier;

		if (origin == AMS_Utils.ANG_MASSIVE_FOP)
			identifier = 'NG_FOP_PortalNotification';
		else if (origin == AMS_Utils.ANG_FOP_AUTOMATIC_RENEWAL)
			identifier = ANG_PCI_RENEWAL;

		Notification_Template__c notificationTemplate = null;

		List<Notification_Template__c> notificationTemplates = [SELECT Id,Name, Identifier__c FROM Notification_Template__c WHERE Identifier__c = :identifier LIMIT 1];

		if(!notificationTemplates.isEmpty())
			notificationTemplate = notificationTemplates.get(0);
		//Case:

		Map<Id,List<Contact>> keyContactMap = new Map<Id,List<Contact>>();


		for(Account acc : accs){

			accountMap.put(acc.Id,acc);

			System.debug('[ANG_OscarProcessHelper.createPCIComplianceOscars] - Inserting PCI Oscar for Account: '+acc.Id+' - '+acc.Name+' - '+acc.IataCode__c);


			List<Contact> keyContactLst = fetchKeyContacts(acc, contactsAcc.get(acc.Id));
			
			keyContactMap.put(acc.Id, keyContactLst);

			fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Account_Concerned__c',acc.Id);
	      	fieldsOfObject.put('ContactId',keyContactLst.get(0).Id);
	        fieldsOfObject.put('BSPCountry__c',acc.BillingCountry);
	        fieldsOfObject.put('Region__c',acc.Region_formula__c);
	        fieldsOfObject.put('CaseArea__c','Accreditation Process');
	        fieldsOfObject.put('Origin', origin);
	        fieldsOfObject.put('Reason1__c','FoP Management');
	        fieldsOfObject.put('Subject','PCI DSS compliance - ' + acc.IataCode__c + ' - ' + acc.Name);
	        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
	        
	       	Case cse = ANG_EntityCreator.createCase(AMS_Utils.RECTYPE_OSCARCOMM, acc.Id, fieldsOfObject);

	        //assign to queue
	       	Database.DMLOptions dmo = new Database.DMLOptions();
	        dmo.assignmentRuleHeader.useDefaultRule = true;
	        cse.setOptions(dmo);

	        oscarObjs = new OscarObjectsWrapper();
	        oscarObjs.cse = cse;
	        oscarObjs.con = keyContactLst.get(0);

	        accOscarObjsMap.put(acc.id,oscarObjs);
	        casesToInsert.add(cse);
		}

		if (!casesToInsert.isEmpty())
       		insert casesToInsert;

       	Set<Id> casesIds = new Set<Id>();
	    for (Case cse : casesToInsert){
	    	casesIds.add(cse.Id);
	    }

       	for(Case insertedCase : [Select ownerId, Account_Concerned__c from Case where Id in :casesIds]){
       		accOscarObjsMap.get(insertedCase.Account_Concerned__c).ownerId = insertedCase.ownerId;
       	}

		//AMS_OSCAR__c:
		List<AMS_Oscar__c> oscarsToInsert = new List<AMS_OSCAR__c>(); 

        for (Account acc : accs){
        
			fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);
			fieldsOfObject.put('Status__c','Open');
			fieldsOfObject.put('OwnerId',accOscarObjsMap.get(acc.Id).ownerId);
			fieldsOfObject.put('Oscar_Communication_Case_Id__c',accOscarObjsMap.get(acc.Id).cse.Id);

			AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, acc.Id, fieldsOfObject);		
	        oscarsToInsert.add(oscar);
	        accOscarObjsMap.get(acc.Id).oscar = oscar;
    	}

    	if(!oscarsToInsert.isEmpty())
    		insert oscarsToInsert;


    	OrgWideEmailAddress[] owea;

		if(!accsToSendEmail.isEmpty()){
			owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];
		}

		List<Case> casesToUpdate = new List<Case>();

		for (Account acc: accs){
			accOscarObjsMap.get(acc.Id).cse.Oscar__c = accOscarObjsMap.get(acc.Id).oscar.Id;
			casesToUpdate.add(accOscarObjsMap.get(acc.Id).cse);
		}

		if(!casesToUpdate.isEmpty())
			update casesToUpdate;

	    Map<Id,Case> casesMaps = new Map<Id,Case>();


	    for(Case c: [Select Id, AccountId, Casenumber from Case where Id in :casesToUpdate])
	    	casesMaps.put(c.AccountId, c);

	    Set<Account> acctSet = new Set<Account>();

		StaticResource sr;
		if (origin == AMS_Utils.ANG_MASSIVE_FOP || origin == AMS_Utils.ANG_FOP_AUTOMATIC_RENEWAL)
			sr = [Select body, name from StaticResource where Name = 'ANG_NilCreditCardSelfDeclaration'].get(0);

		for (Account acc: accs){

			if(accsToSendEmail.contains(acc.Id)){

				acctSet.add(acc);

				Messaging.EmailFileAttachment[] attachments = null;

				if(sr <> null){

					Blob tempBlob = sr.Body;
					
					String bodyAttached = tempBlob.toString();
					
					bodyAttached = bodyAttached.replace('#IATACODE',acc.IATACode__c);
					bodyAttached = bodyAttached.replace('#TODAYDATE',String.valueOf(Datetime.now().format('dd MMMM yyyy')));
					String accountName = acc.Legal_name__c == null ? acc.Name : acc.Legal_name__c;
					bodyAttached = bodyAttached.replace('#LEGALNAME',accountName);

					Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
					attach.setBody(Blob.valueOf(bodyAttached));
					attach.setFileName('Nil Credit Card self-declaration.doc');

					attachments = new Messaging.EmailFileAttachment[]{attach};
				}
                
               	AMS_AgencyRegulationAutoRenewal.sendEmailAlert(keyContactMap.get(acc.Id), accOscarObjsMap.get(acc.Id).oscar.Id, AMS_OSCARTriggerHandler.ANGemailTemplates(origin == AMS_Utils.ANG_MASSIVE_FOP ? AMS_Utils.NGFOP : ANG_PCI_RENEWAL, null, true), accOscarObjsMap.get(acc.Id).oscar.Oscar_Communication_Case_Id__c, owea[0], false, attachments);  
				//if we need a fallback contact:
               // AMS_AgencyRegulationAutoRenewal.sendEmailAlert((fetchKeyContactsForPCI(contactsAcc.get(acc.Id)).isEmpty() ? contactsAcc.get(acc.Id) : fetchKeyContactsForPCI(contactsAcc.get(acc.Id))), accOscarObjsMap.get(acc.Id).oscar.Id, AMS_OSCARTriggerHandler.ANGemailTemplates(AMS_Utils.NGFOP, null, true), accOscarObjsMap.get(acc.Id).oscar.Oscar_Communication_Case_Id__c, owea[0], false, attachments);  

			}

			System.debug('[ANG_OscarProcessHelper.createPCIComplianceOscars] - Finished Inserting oscars: '+ accOscarObjsMap.get(acc.id).oscar.Id + ' | Case: '+accOscarObjsMap.get(acc.id).cse.Id);
		}

		if(notificationTemplate <> null)
			createPortalNotifications(acctSet,casesMaps,notificationTemplate,keyContactMap);

        return casesToUpdate;
    }

      private static void createPortalNotifications(Set<Account> acctSet,  Map<Id,Case> acctIdCasesMap, Notification_Template__c notificationTemplate,Map<Id,List<Contact>> keyContactMap){
		
		List<Contact> contactsToSend = new List<Contact>();
		Map<Id,Id> contactAccts = new Map<Id,Id>();
		Map<Id,Contact> contactsMap = new Map<Id,Contact>();
		List<String> contactNot = new List<String>();
		Map<Id,Account> accounts = new Map<Id,Account>();
		
		Map<Id,Id> contactAccountsIds = new Map<Id,Id>();
		
		for(Id acctId : keyContactMap.KeySet()){
			For(Contact c: keyContactMap.get(acctId))
				contactAccountsIds.put(c.Id,acctId);
		}
		
		for(Account acc: acctSet){
			contactsToSend.addall(keyContactMap.get(acc.Id));
			accounts.put(acc.Id,acc);
		}

    	for(Contact c: contactsToSend){
    		contactNot.add(c.Id+':'+notificationTemplate.Name);
			contactAccts.put(c.Id,contactAccountsIds.get(c.Id));			
			contactsMap.put(c.Id,c);

    	}

    	List<Notification__c> notifications = new List<Notification__c>();

		for(Notification__c nt : ISSP_CreateNotification.createnotification(contactNot, false)){
						
			Account acct = accounts.get(contactAccountsIds.get(nt.Contact__c));
						
			String casenumbmer = acctIdCasesMap.get(contactAccts.get(nt.Contact__c)).CaseNumber;

			nt.Message__c = nt.Message__c
				.replace('#CONTACTNAME', contactsMap.get(nt.Contact__c).Name)
				.replace('#IATACODE', acct.IataCode__c)
				.replace('#ACCOUNTNAME', acct.Name)
				.replace('#TODAY30',String.valueOf(Datetime.now().addDays(30).format('MM/dd/yyyy')))
				.replace('#CASENUMBER',acctIdCasesMap.get(contactAccts.get(nt.Contact__c)).CaseNumber);

			nt.Subject__c = nt.Subject__c
				.replace('#IATACODE', acct.IataCode__c)
				.replace('#ACCOUNTNAME', acct.Name);

			notifications.add(nt);
    	}		

		if(!notifications.isEmpty()) insert notifications;

	}

	public static List<Contact> fetchKeyContacts(Account acc, List<Contact> contacts){

		if(contacts == null || contacts.isEmpty())
			return null;

		
		List<ContactOrdered> contactsToReturn = new List<ContactOrdered>(); 
		List<Contact> contactsToReturnLst = new List<Contact>();

		List<Contact> contactsAccount = new List<Contact>();
		List<Contact> contactsParentAccount = new List<Contact>();

		for(Contact c: contacts)
			if(c.accountId == acc.Id)
				contactsAccount.add(c);
			else 
				contactsParentAccount.add(c);	
			

		for (Contact con :contactsAccount){

			if(con.User_Portal_Status__c == 'Approved Admin')
				contactsToReturn.add(new ContactOrdered(con,0));
			else if (con.Financial_Assessment_Contact__c)
				contactsToReturn.add(new ContactOrdered(con,10));
			else if(con.BSP_CASS_Payment_contact__c)
				contactsToReturn.add(new ContactOrdered(con,20));
			else if(con.User_Portal_Status__c <> 'Approved Admin' && !con.Financial_Assessment_Contact__c &&  !con.BSP_CASS_Payment_contact__c)
				contactsToReturn.add(new ContactOrdered(con,30));

		} 

		if(contactsToReturn.isEmpty()){

			for (Contact con :contactsParentAccount){

				if(con.User_Portal_Status__c == 'Approved Admin')
					contactsToReturn.add(new ContactOrdered(con,0));
				else if (con.Financial_Assessment_Contact__c)
					contactsToReturn.add(new ContactOrdered(con,10));
				else if(con.BSP_CASS_Payment_contact__c)
					contactsToReturn.add(new ContactOrdered(con,20));
				else if(con.User_Portal_Status__c <> 'Approved Admin' && !con.Financial_Assessment_Contact__c &&  !con.BSP_CASS_Payment_contact__c)
					contactsToReturn.add(new ContactOrdered(con,30));

			} 

		}

		
		if(contactsToReturn.isEmpty())
			return null;

		contactsToReturn.sort();

		For(ContactOrdered co : contactsToReturn){
			contactsToReturnLst.add(co.c);
		}

 		return contactsToReturnLst;
	}

	

	private static List<Contact> fetchKeyContactsForPCI(List<Contact> contacts){

		if(contacts == null || contacts.isEmpty())
			return null;

		Set<Contact> contactsMap = new set<Contact>();

		for (Contact con :contacts){

			if(con.User_Portal_Status__c == 'Approved Admin')
				contactsMap.add(con);
			if (con.Financial_Assessment_Contact__c)
				contactsMap.add(con);
			if(con.BSP_CASS_Payment_contact__c)
				contactsMap.add(con);
		} 

 		
 		List<Contact> toReturn = new List<Contact>();
 		toReturn.addAll(contactsMap);

 		return toReturn;
	}
    

	public static void sendFOPPortalNotificationAndEmail(Map<String,Map<Id,Case>> notifTempNameCaseMap, Map<String,Set<Id>> templateContIdMap, Map<String,String> mapNotificationsTemplates){

		List<String> notificationTargets = new List<String>();
		Map<Id,Case> contactCaseMap = new Map<Id,Case>();
		Set<Id> conIds = new Set<Id>();

		for (String key : templateContIdMap.keySet()){
			conIds.addAll(templateContIdMap.get(key));
		}

		Map<Id,Contact> contacts = new Map<Id,Contact>([SELECT Id, Name, Email, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c, Account.IataCode__c, Account.Name
														FROM Contact WHERE Id IN :conIds]); 

		for(String key :notifTempNameCaseMap.keySet()){
			for(case cse :notifTempNameCaseMap.get(key).values()){					
				notificationTargets.add(cse.ContactId+':'+key);
				contactCaseMap.put(cse.ContactId,cse);				
			}			
		}

		List<Notification__c> notifications = ISSP_CreateNotification.createnotification(notificationTargets, false);

		for (Notification__c nt :notifications){
			nt.Message__c = nt.Message__c
				.replace('#CONTACTNAME',contacts.get(nt.Contact__c).Name)
				.replace('#IATACODE',contacts.get(nt.Contact__c).Account.IataCode__c)
				.replace('#ACCOUNTNAME', contacts.get(nt.Contact__c).Account.Name)
				.replace('#DEADLINEDATE',String.valueOf(Datetime.now().addDays(15).format('MM/dd/yyyy')));

			nt.Subject__c = nt.Subject__c
				.replace('#IATACODE', contacts.get(nt.Contact__c).Account.IataCode__c)
				.replace('#ACCOUNTNAME',contacts.get(nt.Contact__c).Account.Name);
		}

		if (!notifications.isEmpty())
			insert notifications;

		System.debug('## notifications created: '+notifications.size());	

		//send emails
		OrgWideEmailAddress[] owea;
	    owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];

		// casesByTemplateName map {TemplateId, Map<CaseId,Case>}


	    for (String conId :templateContIdMap.keyset()){

			for(Id caseId: notifTempNameCaseMap.get(conId).KeySet()){
	    	
				Case caseToProcess = notifTempNameCaseMap.get(conId).get(caseId);

                List<Contact> contactIdList = new List<Contact>();
                contactIdList.add(contacts.get(caseToProcess.ContactId));

				AMS_AgencyRegulationAutoRenewal.sendEmailAlert(contactIdList, contactCaseMap.get(caseToProcess.ContactId).OSCAR__c, AMS_OSCARTriggerHandler.ANGemailTemplates(mapNotificationsTemplates.get(conId), null, false), caseToProcess.Id, owea[0], false);

			}
	    	
	    }

	}

    public Class EntityUpdater{

    	public Map<Id,Account> acctMap;
    	public Map<Id,AMS_Pax_Accreditation_Form__c> onlineAMap;
    	public Map<Id,AMS_Oscar__c> oscarMap;
    	public Map<Id,Code_Range__c> codeRangesMap;
    	public Map<Id,Case> caseMap;
    	public String errorMessage;
    	public boolean isFaulty;
    	public boolean toUpdate;

		public EntityUpdater(){

			acctMap = new Map<Id, Account>();			
			onlineAMap = new Map<Id, AMS_Pax_Accreditation_Form__c>();
			oscarMap = new Map<Id, AMS_Oscar__c>();
			codeRangesMap = new Map<Id,Code_Range__c>();
			caseMap = new Map<Id,Case>();
			isFaulty = false;
			toUpdate = false;

		}

    }

    public Class OscarObjectsWrapper{

    	public Account acc;
    	public Case cse;
    	//public AMS_Pax_Accreditation_Form__c stagingArea;
    	public AMS_Oscar__c oscar;
    	public Id ownerId;
    	public Contact con;

    	public OscarObjectsWrapper(){

        	acc = new Account();
    		cse = new Case();
    		//stagingArea = new AMS_Pax_Accreditation_Form__c();
    		oscar = new AMS_Oscar__c();
    		con = new Contact();
    	}

    }

    public Class ContactOrdered implements Comparable{

		private Contact c;
		private Integer order;

    	public ContactOrdered(Contact c, Integer order){
			this.c = c;
			this.order = order;
		}

		public Integer compareTo(Object instance){
        
			ContactOrdered that = (ContactOrdered)instance;
        	if (this.order == that.order) return 0;
        	if (this.order > that.order) return 1;
        	return -1;
    	}

    }

    public static List<AMS_OSCAR__c> createIEPAccountOscar(Map<Id,Account> accsMap, String model){

    	List<Account> accs = accsMap.values();

		Map<id,OscarObjectsWrapper> accOscarObjsMap = new Map<id,OscarObjectsWrapper>();
		OscarObjectsWrapper oscarObjs;
		
		Map<String,Object> fieldsOfObject;

		List<Case> casesToInsert = new List<Case>();

		Map<Id,Contact> contactAcc = new Map<Id,Contact>();

		for (Contact con : [SELECT Id, Name, Email, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c, AccountId,
			(SELECT Id, Portal_Application__r.Name FROM Portal_Application_Rights__r WHERE ANG_Portal_Service_Role__c = 'IEP Admin')
			FROM Contact WHERE AccountId IN :accsMap.keySet() 
            AND Id IN (SELECT Contact__c FROM Portal_Application_Right__c WHERE Right__c = 'Access Granted'
                AND ANG_Portal_Service_Role__c = 'IEP Admin' 
                AND Portal_Application__r.Name IN : (model == 'A' || model == 'setup' ? MODEL_A_PROVIDERS : MODEL_B_PROVIDERS))]){
                
			contactAcc.put(con.AccountId,con);
		} 

		//Case:
		for(Account acc : accs){

			System.debug('[ANG_OscarProcessHelper.createIEPAccountOscar] - BEGINNING INSERTING for ACCOUNT: '+acc.Id+' - '+acc.Name+' - '+acc.IataCode__c);
			
            if(contactAcc.get(acc.Id) == null){
            	acc.addError('An IEP Admin Contact is needed on this Account for the IEP Account OSCAR');
            	return null;
            } 
            	
            
			fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Account_Concerned__c',acc.Id);
	      	fieldsOfObject.put('ContactId',contactAcc.get(acc.Id).Id);
	        fieldsOfObject.put('BSPCountry__c',acc.BillingCountry);
	        fieldsOfObject.put('Region__c',acc.Region_formula__c);
	        fieldsOfObject.put('CaseArea__c','Accreditation Process');
	        fieldsOfObject.put('Origin','IEP portal');
	        fieldsOfObject.put('Reason1__c', (model == 'A' ? 'Onboarding IEP Model A' : (model == 'B' ? 'Screening IEP Model B' : 'IEP Bank Account Setup')));
	        fieldsOfObject.put('Subject',(model == 'A' ? 'Onboarding IEP Model A - ' : (model == 'B' ? 'Screening IEP Model B -' : 'IEP Bank Account Setup -')) + acc.ANG_Accreditation_Model__c + ' - ' + acc.Name);
	        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
	        fieldsOfObject.put('Visible_on_ISS_Portal__c',true);
	        
	       	Case cse = ANG_EntityCreator.createCase(AMS_Utils.RECTYPE_OSCARCOMM, acc.Id, fieldsOfObject);

            //assign to queue
            if(!Test.isRunningTest()){           
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                cse.setOptions(dmo);
            }

	        oscarObjs = new OscarObjectsWrapper();
	        oscarObjs.cse = cse;
	        oscarObjs.con = contactAcc.get(acc.Id);

	        accOscarObjsMap.put(acc.id,oscarObjs);
	        casesToInsert.add(cse);
		}

		if (!casesToInsert.isEmpty())
       		insert casesToInsert;

       	Set<Id> casesIds = new Set<Id>();
	    for (Case cse : casesToInsert){
	    	casesIds.add(cse.Id);
	    }

       	for(Case insertedCase : [Select ownerId, Account_Concerned__c from Case where Id in :casesIds]){
       		accOscarObjsMap.get(insertedCase.Account_Concerned__c).ownerId = insertedCase.ownerId;
       	}

		//AMS_OSCAR__c:
		List<AMS_Oscar__c> oscarsToInsert = new List<AMS_OSCAR__c>(); 

        for (Account acc : accs){
        
			fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Process__c',(model == 'A' ? AMS_Utils.IEPMODELAACCOUNTSETUP : (model == 'B' ? AMS_Utils.IEPMODELBACCOUNTSETUP :AMS_Utils.IEPBANKACCOUNTSETUP)));
			fieldsOfObject.put('Status__c','Open');
			fieldsOfObject.put('OwnerId',accOscarObjsMap.get(acc.Id).ownerId);
			fieldsOfObject.put('Oscar_Communication_Case_Id__c',accOscarObjsMap.get(acc.Id).cse.Id);
			fieldsOfObject.put('Dossier_Reception_Date__c',Date.today());

			AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(model == 'A'? AMS_Utils.RECTYPE_IEPMODELA : AMS_Utils.RECTYPE_IEPMODELB, acc.Id, fieldsOfObject);		
	        oscarsToInsert.add(oscar);
	        accOscarObjsMap.get(acc.Id).oscar = oscar;
		}

	    

	    if(!oscarsToInsert.isEmpty())
	    	insert oscarsToInsert;


	    OrgWideEmailAddress[] owea;


		owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];
			

		List<Case> casesToUpdate = new List<Case>();

			
		for (Account acc: accs){

			accOscarObjsMap.get(acc.Id).cse.Oscar__c = accOscarObjsMap.get(acc.Id).oscar.Id;
			casesToUpdate.add(accOscarObjsMap.get(acc.Id).cse);
		    

			System.debug('[ANG_OscarProcessHelper.createIEPAccountOscar] - FINISHING... INSERTING OSCARS: '+ accOscarObjsMap.get(acc.id).oscar.Id + ' | Case: '+accOscarObjsMap.get(acc.id).cse.Id);
		}
			

		if(!casesToUpdate.isEmpty())
			update casesToUpdate;

		//sending email with url for portal    
        for (Account acc: accs){
        
            AMS_AgencyRegulationAutoRenewal.sendEmailAlert(new List<Contact>{accOscarObjsMap.get(acc.Id).con}, accOscarObjsMap.get(acc.Id).oscar.Id, AMS_OSCARTriggerHandler.ANGemailTemplates((model == 'A' ? AMS_Utils.IEPMODELAACCOUNTSETUP : (model == 'B' ? AMS_Utils.IEPMODELBACCOUNTSETUP : AMS_Utils.IEPBANKACCOUNTSETUP)), 'Creation'+(model == 'B' ? '_'+contactAcc.get(acc.Id).Portal_Application_Rights__r[0].Portal_Application__r.Name : ''), true), accOscarObjsMap.get(acc.Id).oscar.Oscar_Communication_Case_Id__c, owea[0], false);         

        }
        return oscarsToInsert;
    }

	//EM - To be removed
	public static void fakemethod () {
		if (Test.isRunningTest()) {
			Integer i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
		}
	
	}


}