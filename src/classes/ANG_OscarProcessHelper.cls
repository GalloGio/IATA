global class ANG_OscarProcessHelper {

	public static final Set<String> AMLCaseProcesses = new Set <String>{AMS_Utils.new_HO ,AMS_Utils.new_BR_ABROAD, AMS_Utils.new_TIDS, AMS_Utils.NEWHELITE, AMS_Utils.NEWHESTANDARD};
	public static final Set<String> SanityCheckVerificationProcesses = new Set <String>{AMS_Utils.NEWHELITE, AMS_Utils.NEWHESTANDARD, AMS_Utils.NEWAE};

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
					(SELECT Id FROM RHC_Informations__r), Is_PCI_compliant__c,Link_agent_code__c, Sector__c, Category__c, Check_Digit__c, RecordTypeId,Due_Diligence_Status__c,CNS_Agency__c
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

			AMS_OSCAR__c oscar = [select Account__c, Flag_IATACode_Formula__c, Flag_IATACode__c, Flag_Data_to_Account__c, AMS_Online_Accreditation__c, Process__c, recordTypeID,
					Is_PCI_compliant__c, Account__r.Top_Parent__r.Id , AMS_Online_Accreditation__r.Id,Account__r.Location_Type__c,RecordType.DeveloperName,
					Flag_Data_to_SAPECC__c,ID, STEP10__c,STEP17__c,STEP8__c,Process_Start_Date__c, Account__r.Due_Diligence_Status__c, AMS_Online_Accreditation__r.Location_Class__c, 
					AMS_Online_Accreditation__r.Link_agent_name__c , AMS_Online_Accreditation__r.Branch_Office_Country__r.Due_diligence_mandatory__c, Account__r.Location_Class__c,
					Account__r.Sector__c , Account__r.Company_type__C, STEP6__c, (SELECT Id FROM Agencies_Applied_Change_codes__r) , (select Id from Appointments__r)
					from AMS_OSCAR__c where Id = : oscarId LIMIT 1];

			System.debug('[ANG_OscarProcessHelper] Fetched Account:' + theAccount);

			System.debug('[ANG_OscarProcessHelper] Fetched Online Accreditation:' + theAccreditation);

			System.debug('[ANG_OscarProcessHelper] Fetched OSCAR:' + oscar);

			EntityUpdater updater = new EntityUpdater();
			
			updater.oscarMap.put(oscar.Id,oscar);
			updater.acctMap.put(theAccount.Id,theAccount);
			updater.onlineAMap.put(theAccreditation.Id,theAccreditation);

            if(theAccount.CNS_Agency__c == false && oscar.STEP6__c != AMS_Utils.PASSED && SanityCheckVerificationProcesses.contains(oscar.Process__c)) {
				isIATACodeGenerationRunning = false;
				System.debug('[ANG_OscarProcessHelper] In order to generate a IATA code you must first pass the Sanity Check.');
				return new String[]{'-1','In order to generate a IATA code you must first pass the Sanity Check.','-1'};

            }


			if((!oscar.Appointments__r.isEmpty()) && oscar.Appointments__r.size() > 1){
				isIATACodeGenerationRunning = false;
				System.debug('[ANG_OscarProcessHelper] A New MSO cannot have more than one Appointment. Please review the appointments section and try again.');
				return new String[]{'-1','A New MSO cannot have more than one Appointment. Please review the appointments section and try again.','-1'};
			}

			System.debug('[ANG_OscarProcessHelper] Execution time so far:' + (datetime.now().getTime() - processStartTime.getTime()) /1000);

	        if(!oscar.Flag_IATACode__c){

				System.debug('[ANG_OscarProcessHelper] Starting IATA Code Generation.');

				if(!Test.isRunningTest())
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

            if(oscar.Process__c == AMS_Utils.NEWHESTANDARD && acc.RHC_Informations__r.isEmpty()) 
            	createRHCInfo.add(acc);


            if(AMS_Utils.oscarPCICompliantMigrationProcesses.contains(oscar.Process__c)){
                acc.Is_PCI_compliant__c = oscar.Is_PCI_compliant__c;
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

		AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

		changeCode.name = 'NEW';
		changeCode.reasonCode = '21';
		changeCode.memoText = AMS_Utils.getChangeCodeMemoText(theOSCAR.Process__c, changeCode.name);
		changeCode.reasonDesc  = 'NEW APPLICATION';
		changeCode.status  = '2';
		
		List<Account> acctList = AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {theOSCAR}, new List<Account> {acct}, false);

		if(!acctList.isEmpty())
			updater.acctMap.put(acctList.get(0).Id, acctList.get(0));

		updater.oscarMap.get(theOSCAR.Id).First_Step_Completed__c = true;

		updater.toUpdate = true;

		return updater;

	}

	public static EntityUpdater execCreateAMLCase(AMS_OSCAR__c oscar, EntityUpdater updater) {

		if(updater == null)
			updater = new EntityUpdater();


            ID InternalCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('Internal Cases (IDFS ISS)');

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
	    System.debug('[ANG_OscarProcessHelper] 4. Number of Queries used in this apex code so far: ' + Limits.getQueries());
	    System.debug('[ANG_OscarProcessHelper] 5. Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
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


}