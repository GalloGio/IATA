/**
    Batch process to generate Airline Suspension cases for the input cases
    Those cases are for the Airline Participation Team and Customer Service Team 
**/
global class AirlineSuspensionChildCaseCreationBatch implements Database.Batchable<sObject>{
	global final Id ParentCaseId;
	Case ParentCase;
	Airline_Suspension__c ASrecord;
	String query;
	map<String, Case> mapCSChildCasesPerCountry;
	String errorLog;
	public Boolean isCloseChildCases {get; set;}
	
	public static final map<String,String> MAP_PARTICIPATION_NAME_PER_TYPE = new map<String, String>{
                            'CASS Participation' => 'CASS', 
                            'CASS via GSSA' => 'CASS', 
                            'CASS Import Direct Participation' => 'CASS',
                            'CASS Export Direct Participation' => 'CASS',
                            'CASS Export via GSSA' => 'CASS',
                            'BSP Participation' => 'BSP', 
                            'BSP via IBCS' => 'BSP'
                            };
	public static final map<String,list<String>> MAP_PARTICIPATION_TYPE_PER_NAME = new map<String,list<String>>{
                            'CASS' => new list<String>{
                                    'CASS Participation',
                                    'CASS via GSSA',
                                    'CASS Import Direct Participation',
                                    'CASS Export Direct Participation',
                                    'CASS Export via GSSA'
                                },
                            'BSP' => new list<String>{
                                    'BSP Participation',
                                    'BSP via IBCS'
                                }
                            };
    public static final set<String> SET_VALID_PARITICIPATIONS = MAP_PARTICIPATION_NAME_PER_TYPE.keyset();
	
	global AirlineSuspensionChildCaseCreationBatch(Id caseId, Boolean isAbandon){
		ParentCaseId = caseId;
		
		
		isCloseChildCases = isAbandon;
		
		
		system.debug('BATCH initialization: select the Case and the Airline Suspension record: ');
		
		ParentCase = [SELECT Id, Subject, Description, AccountId, Account.Name, Account.IATA_ISO_Country__r.Region__c, Account.IATA_ISO_Country__r.Name, RecordType.DeveloperName 
						FROM Case WHERE Id =: caseId];
		ASrecord = [SELECT Id, ChildSuspensionCasesGenerated__c, Reason_for_Suspension__c, Settle_Directly_To__c FROM Airline_Suspension__c WHERE Case__c =: caseId];
		
		if (isCloseChildCases) {
			// batch for closing all open child cases of the Airline Suspension parent
			query = 'SELECT Id, Status FROM Case WHERE ParentId = \'' +  ParentCase.Id + '\' AND isClosed = false AND Status <> \'Abandoned\'';
			
		} else if (ParentCase.RecordType.DeveloperName == 'Airline_Deactivation') {
			query = 'SELECT Id, ISO_Country_formula__c, Services_Rendered_to_Airline__c, Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Region__c, Services_Rendered_Type__c FROM Services_Rendered__c ' +
															'WHERE Services_Rendered_Status__c = \'Active\' ' +  
															'AND Services_Rendered_To_Airline__c = \'' +  ParentCase.AccountId + '\' ' + 
												            'ORDER BY ISO_Country_formula__c';
		} else { 
			// RT = Airline_Suspension
			query = 'SELECT Id, ISO_Country_formula__c, Services_Rendered_to_Airline__c, Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Region__c, Services_Rendered_Type__c, ' +
					'	Services_Rendered_to_Airline__r.Name, Services_Rendered_to_Airline__r.Airline_designator__c, Services_Rendered_to_Airline__r.IATACode__c ' +
					'FROM Services_Rendered__c ' +
					'WHERE Services_Rendered_Status__c = \'Active\' ' +  
					'AND (Services_Rendered_To_Airline__c = \'' +  ParentCase.AccountId + '\' ' + 
			        	'OR Services_Rendered_To_Airline__r.ParentId = \'' +  ParentCase.AccountId + '\' ' +
			            'OR Services_rendered_By__r.ParentId =\'' +  ParentCase.AccountId + '\' ' +
			            'OR Services_rendered_By__c = \'' + ParentCase.AccountId + '\') ' +
		            'ORDER BY ISO_Country_formula__c';
		}
		
        mapCSChildCasesPerCountry = new map<String, Case>();
        errorLog = '';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		if (isCloseChildCases) {
			// CLOSE ALL CHILD CASES
			list<Case> lstCasesToAbandon = new list<Case>();
			
			for(Sobject so : scope) {
				Case c = (Case)so;
				c.Status = 'Abandoned';
				lstCasesToAbandon.add(c);
			}
			
			system.debug('BATCH Child case update - Abandon ');
	      	Database.SaveResult[] srList = Database.update(lstCasesToAbandon,false);
	
			// Iterate through each returned result
			for (Database.SaveResult sr : srList) {
			    if (!sr.isSuccess()) {
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred on child Case closing.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Fields that affected this error: ' + err.getFields());
			            
			            errorLog += 'Child Case closing error\n';
			            errorLog += 'Error #' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
			            errorLog += 'Fields: ' + err.getFields() + '\n\n\n';
			        }
			    }
			}
			
		} else {
			// GENERATE CHILD CASES
			
			Id RT_AirlineParticipationProcess_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IDFS_Airline_Participation_Process');
			Id RT_InternalCases_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('InternalCasesEuropeSCE');
			
			List<Case> lstChildCases = new List<Case>();
			
			// Set the option to assign the new child cases using the default Assignment Rule
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule= true;
			
			// Prepare the documents for the CS teams
			// get all the ENGLISH document names
			map<String, String> mapASDocumentNamePerCountryName = new map<String, String>();
			for (Airline_Suspension_Documents__c asdoc : Airline_Suspension_Documents__c.getAll().values()) {
				mapASDocumentNamePerCountryName.put(asdoc.Country_Name__c, asdoc.Document_Name__c);
			}
			
			// get all the EXTRA document names (the 2nd languages)
			map<String, String> mapExtraDocumentNamePerCountryName = new map<String, String>();
			for (Airline_Suspension_Extra_Docs__c asdoc : Airline_Suspension_Extra_Docs__c.getAll().values()) {
				mapExtraDocumentNamePerCountryName.put(asdoc.Country_Name__c, asdoc.Document_Name__c);
			}
			
			
			////////////////////////////////////////////////////////////////////////
			///  This part is not used right now (custom settings empty)
			///  
			
			// get all second language assignments per country
			map<String, String> mapSecondLanguagePerCountry = new map<String, String>();
			for (Airline_Suspension_2nd_Language__c asl : Airline_Suspension_2nd_Language__c.getAll().values()) {
				mapSecondLanguagePerCountry.put(asl.Country_Name__c, asl.Language__c);
			}
			
			// get all the translations for the Reason for Suspension in the 2nd languages
			map<String, String> mapTranslationsPerReasonForSuspension = new map<String, String>();
			for (Airline_Suspension_Reason_Translations__c asr : Airline_Suspension_Reason_Translations__c.getAll().values()) {
				mapTranslationsPerReasonForSuspension.put(asr.Language_Key__c, asr.Translation__c);
			}
			///
			////////////////////////////////////////////////////////////////////////
			
			
			for(Sobject s : scope) {
				Services_Rendered__c sr = (Services_Rendered__c)s;
				
				// create 1 case for the Airline Participation team
				Case APchildCase = new Case();
				APchildCase.ParentId = ParentCase.Id;
				APchildCase.AccountId = sr.Services_Rendered_to_Airline__c; //ParentCase.AccountId;
				APchildCase.ContactId = Label.AirlineSuspensionContactId != 'null' ? Label.AirlineSuspensionContactId : null;
				APchildCase.Subject = 'Airline suspension - ' + sr.Services_Rendered_Type__c + ' participation in ' + sr.ISO_Country_formula__c;
				APchildCase.Description = ParentCase.Description;
				APchildCase.Origin = 'Internal Case';
				APchildCase.CaseArea__c = 'Airline Suspension Process'; //'Airline Change';
				APchildCase.Reason1__c = sr.Services_Rendered_Type__c;//'Airline suspension';
				APchildCase.RecordTypeId = RT_AirlineParticipationProcess_Id;
				APchildCase.Status = 'Open';
				APchildCase.Priority = 'Normal';
				APchildCase.Region__c = sr.Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Region__c;
				APchildCase.BSPCountry__c = sr.ISO_Country_formula__c;
				
				APchildCase.setOptions(dmo);
				
				lstChildCases.add(APchildCase);
				
				// create 1 case for the Customer Service team
				Case CSchildCase = new Case();
				CSchildCase.ParentId = ParentCase.Id;
				CSchildCase.AccountId = sr.Services_Rendered_to_Airline__c; //ParentCase.AccountId;
				CSchildCase.ContactId = Label.AirlineSuspensionContactId != 'null' ? Label.AirlineSuspensionContactId : null;
				CSchildCase.Subject = 'Suspension of ' + sr.Services_Rendered_to_Airline__r.Name + ' (' + sr.Services_Rendered_to_Airline__r.Airline_designator__c + '-' + 
						sr.Services_Rendered_to_Airline__r.IATACode__c + ') - Market Communication ' + sr.Services_Rendered_Type__c + ' ' + sr.ISO_Country_formula__c ;
				CSchildCase.Description = ParentCase.Description;
				CSchildCase.Origin = 'Internal Case';
				CSchildCase.CaseArea__c = 'Customer Service';
				CSchildCase.Reason1__c = 'Communication';
				CSchildCase.RecordTypeId = RT_InternalCases_Id;
				CSchildCase.Status = 'Open';
				CSchildCase.Priority = 'Normal';
				CSchildCase.Type_of_customer__c = 'IATA Employee';
				CSchildCase.Region__c = sr.Services_Rendered_to_Airline__r.IATA_ISO_Country__r.Region__c;
				CSchildCase.BSPCountry__c = sr.ISO_Country_formula__c;
				
				// Add the merge templates data
				String country_service = MAP_PARTICIPATION_NAME_PER_TYPE.get(sr.Services_Rendered_Type__c) + ' ' + sr.ISO_Country_formula__c + ' Settle to ' + ASrecord.Settle_Directly_To__c;
				
				/////// 1st doc, in English: if country has a specific document to be used then select it, otherwise use the default; reuse the Business_Justification__c field
				if (mapASDocumentNamePerCountryName.get(country_service) != null) {
					CSchildCase.Business_Justification__c = mapASDocumentNamePerCountryName.get(country_service);
				} else if (CSchildCase.Subject.contains('CASS')) {
				 	CSchildCase.Business_Justification__c = mapASDocumentNamePerCountryName.get('CASS Default Settle to ' + ASrecord.Settle_Directly_To__c);
				} else {
					CSchildCase.Business_Justification__c = mapASDocumentNamePerCountryName.get('BSP Default Settle to ' + ASrecord.Settle_Directly_To__c);
				}
				
				/////// 2nd doc, in other languages - reuse the Business_Process_es_Affected__c field 
				CSchildCase.Business_Process_es_Affected__c = mapExtraDocumentNamePerCountryName.get(country_service);
				
				////// Reason for suspension in English - reuse the DEF_Withdrawal_Remarks__c field
				CSchildCase.DEF_Withdrawal_Remarks__c = mapTranslationsPerReasonForSuspension.get('English ' + asrecord.Reason_for_Suspension__c);
				
				////// Reason for suspension in 2nd language - reuse the Documentation_remarks__c field
				if (mapSecondLanguagePerCountry.get(sr.ISO_Country_formula__c) != null) {
					CSchildCase.Documentation_remarks__c = mapTranslationsPerReasonForSuspension.get(mapSecondLanguagePerCountry.get(sr.ISO_Country_formula__c) + ' ' + asrecord.Reason_for_Suspension__c);
				}
					
				
				
				
				CSchildCase.setOptions(dmo);
				
				lstChildCases.add(CSchildCase);
				
				// insert in the map
				mapCSChildCasesPerCountry.put(MAP_PARTICIPATION_NAME_PER_TYPE.get(sr.Services_Rendered_Type__c) + ' ' + sr.ISO_Country_formula__c, CSchildCase);
				
	      	}
	      	
	      	system.debug('BATCH Child case insertion ');
	      	Database.SaveResult[] srList = Database.insert(lstChildCases,false);
	
			// Iterate through each returned result
			for (Database.SaveResult sr : srList) {
			    if (!sr.isSuccess()) {
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred on child Case insertion.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Fields that affected this error: ' + err.getFields());
			            
			            errorLog += 'Child Case creation error\n';
			            errorLog += 'Error #' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
			            errorLog += 'Fields: ' + err.getFields() + '\n\n\n';
			        }
			    }
			}
			
			
			
			// Create the attachments for the CS cases
			// Not used anymore, we fill the template names in the case itself instead
			/*
			list<Attachment> lstCSCasesAttachments = new list<Attachment>();
			
			// get all the ENGLISH document names
			map<String, String> mapASDocumentNamePerCountryName = new map<String, String>();
			for (Airline_Suspension_Documents__c asdoc : Airline_Suspension_Documents__c.getAll().values()) {
				mapASDocumentNamePerCountryName.put(asdoc.Country_Name__c, asdoc.Document_Name__c);
			}
			// get the AS ENGLISH documents into a map
			map<String, Document> mapASDocumentsPerDocName = new map<String, Document>();
			for (Document doc : [SELECT Id, Name, DeveloperName, Body, ContentType, Type FROM Document WHERE DeveloperName IN :mapASDocumentNamePerCountryName.values()]) {
				mapASDocumentsPerDocName.put(doc.DeveloperName, doc);
			}
			
			
			// get all the EXTRA document names (the 2nd languages)
			map<String, String> mapExtraDocumentNamePerCountryName = new map<String, String>();
			for (Airline_Suspension_Extra_Docs__c asdoc : Airline_Suspension_Extra_Docs__c.getAll().values()) {
				mapExtraDocumentNamePerCountryName.put(asdoc.Country_Name__c, asdoc.Document_Name__c);
			}
			// get the EXTRA documents into a map
			map<String, Document> mapExtraDocumentsPerDocName = new map<String, Document>();
			for (Document doc : [SELECT Id, Name, DeveloperName, Body, ContentType, Type FROM Document WHERE DeveloperName IN :mapExtraDocumentNamePerCountryName.values()]) {
				mapExtraDocumentsPerDocName.put(doc.DeveloperName, doc);
			}
			
			
			for (String country : mapCSChildCasesPerCountry.keyset()) {
				/////// 1st doc, in ENGLISH
				String strDocName;
				// if country has a specific document to be used then select it, otherwise use the default
				if (mapASDocumentNamePerCountryName.get(country) != null) {
					strDocName = mapASDocumentNamePerCountryName.get(country);
				} else if (mapCSChildCasesPerCountry.get(country).Subject.contains('CASS')) {
				 	strDocName = mapASDocumentNamePerCountryName.get('CASS Default');
				} else {
					strDocName = mapASDocumentNamePerCountryName.get('BSP Default');
				}
				
				if (strDocName != null && mapASDocumentsPerDocName.get(strDocName) != null) {
					Attachment att = new Attachment();
					
					att.ParentId = mapCSChildCasesPerCountry.get(country).Id;
					att.Name = mapASDocumentsPerDocName.get(strDocName).Name + '.' + mapASDocumentsPerDocName.get(strDocName).Type;
	    			att.Body = mapASDocumentsPerDocName.get(strDocName).Body;
					att.ContentType = mapASDocumentsPerDocName.get(strDocName).ContentType;
					
					lstCSCasesAttachments.add(att);
				}
				
				/////// 2nd doc, in other languages
				if (mapExtraDocumentNamePerCountryName.get(country) != null && mapExtraDocumentsPerDocName.get(mapExtraDocumentNamePerCountryName.get(country)) != null) {
					Attachment att = new Attachment();
					
					att.ParentId = mapCSChildCasesPerCountry.get(country).Id;
					att.Name = mapExtraDocumentsPerDocName.get(mapExtraDocumentNamePerCountryName.get(country)).Name + '.' + mapExtraDocumentsPerDocName.get(mapExtraDocumentNamePerCountryName.get(country)).Type;
	    			att.Body = mapExtraDocumentsPerDocName.get(mapExtraDocumentNamePerCountryName.get(country)).Body;
					att.ContentType = mapExtraDocumentsPerDocName.get(mapExtraDocumentNamePerCountryName.get(country)).ContentType;
					
					lstCSCasesAttachments.add(att);
				}
			}
			
			if (! lstCSCasesAttachments.isEmpty()) {
				srList.clear();
				srList = Database.insert(lstCSCasesAttachments,false);
	
				// Iterate through each returned result
				for (Database.SaveResult sr : srList) {
				    if (!sr.isSuccess()) {
				        // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {
				            System.debug('The following error has occurred on Attachment insertion.');                    
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            System.debug('Fields that affected this error: ' + err.getFields());
				            
				            errorLog += 'Attachment creation error\n';
				            errorLog += 'Error #' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
				            errorLog += 'Fields: ' + err.getFields() + '\n\n\n';
				        }
				    }
				}
				
			}*/
		}
	}
	
	global void finish(Database.BatchableContext BC){
		if (!isCloseChildCases) {
			// create one single case for AP for the suspension
			Id RT_AirlineParticipationProcess_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IDFS_Airline_Participation_Process');
			
			Case APchildCase = new Case();
			APchildCase.ParentId = ParentCase.Id;
			APchildCase.AccountId = ParentCase.AccountId;
			APchildCase.ContactId = Label.AirlineSuspensionContactId != 'null' ? Label.AirlineSuspensionContactId : null;
			APchildCase.Subject = 'Airline suspension - ' + parentCase.Account.Name;
			APchildCase.Description = ParentCase.Description;
			APchildCase.Origin = 'Internal Case';
			APchildCase.CaseArea__c = 'Airline Management';
			APchildCase.Reason1__c = 'Airline suspension';
			APchildCase.RecordTypeId = RT_AirlineParticipationProcess_Id;
			APchildCase.Status = 'Open';
			APchildCase.Priority = 'Normal';
			APchildCase.Region__c = ParentCase.Account.IATA_ISO_Country__r.Region__c;
			APchildCase.BSPCountry__c = ParentCase.Account.IATA_ISO_Country__r.Name;
					
			// Set the option to assign the new child case using the default Assignment Rule
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule= true;
			APchildCase.setOptions(dmo);
			
			insert APchildCase;
			
			
			// create one single case for the Coding Team
			Id RT_InternalCases_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('InternalCasesEuropeSCE');
			
			Case CodingChildCase = new Case();
			CodingChildCase.ParentId = ParentCase.Id;
			CodingChildCase.AccountId = ParentCase.AccountId;
			CodingChildCase.ContactId = Label.AirlineSuspensionContactId != 'null' ? Label.AirlineSuspensionContactId : null;
			CodingChildCase.Subject = ParentCase.Subject;
			CodingChildCase.Description = ParentCase.Description;
			CodingChildCase.Origin = 'Internal Case';
			CodingChildCase.CaseArea__c = 'Airline Coding';
			CodingChildCase.Reason1__c = 'Airline suspension';
			CodingChildCase.RecordTypeId = RT_InternalCases_Id;
			CodingChildCase.Status = 'Open';
			CodingChildCase.Priority = 'Normal';
			CodingChildCase.Region__c = ParentCase.Account.IATA_ISO_Country__r.Region__c;
			CodingChildCase.BSPCountry__c = ParentCase.Account.IATA_ISO_Country__r.Name;
					
			// Set the option to assign the new child case using the default Assignment Rule
			CodingChildCase.setOptions(dmo);
			listInsertCases.add(CodingChildCase);

			// Third new case 
			Case MitaCase = new Case();
			MitaCase.ParentId = ParentCase.Id;
			MitaCase.AccountId = ParentCase.AccountId;
			MitaCase.ContactId = Label.AirlineSuspensionContactId != 'null' ? Label.AirlineSuspensionContactId : null;
			MitaCase.Subject = ParentCase.Subject;
			MitaCase.Description = ParentCase.Description;
			MitaCase.Origin = 'Internal Case';
			MitaCase.CaseArea__c = 'MITA & BIETA';
			MitaCase.Reason1__c = 'Airline suspension';
			MitaCase.RecordTypeId = RT_InternalCases_Id;
			MitaCase.Status = 'Open';
			MitaCase.Priority = 'Normal';
			MitaCase.Region__c = ParentCase.Account.IATA_ISO_Country__r.Region__c;
			MitaCase.BSPCountry__c = ParentCase.Account.IATA_ISO_Country__r.Name;
					
			// Set the option to assign the new child case using the default Assignment Rule
			MitaCase.setOptions(dmo);
			listInsertCases.add(MitaCase);
			
			insert listInsertCases;
		}
		
		
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        String mailbody = 'The batch process that automatically ' + (isCloseChildCases ? 'closes' : 'generates') + ' the Airline Suspension child cases processed ' + a.TotalJobItems + 
        		' creation batches (containing up to 10 cases each) with '+ a.NumberOfErrors + ' failures.\n\nExtended status:\n' + a.ExtendedStatus;
        
        // Send an email to the Apex job's submitter notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Airline Suspension child cases ' + (isCloseChildCases ? 'closing' : 'creation') + ' status: ' + a.Status);
        mail.setPlainTextBody (mailbody);
		
		system.debug('ErrorLog: ' + errorLog);
		
        // check if there were errors logged, and attach them in a file
        if(errorLog != ''){    
		   	Messaging.EmailFileAttachment[] attachements = new Messaging.EmailFileAttachment[]{} ;
		    
		    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		    efa.setContentType('Text');
		    efa.setFileName('ErrorLog_' + date.today().format() + '.txt');
		    efa.setBody(blob.valueOf(errorLog));
		    attachements.add(efa);
		    
		    mail.setFileAttachments(attachements);
        }
        
        // send the email
        if ( !test.isRunningTest() ) {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
		
		if (!isCloseChildCases && a.TotalJobItems > a.NumberOfErrors) {
			// If at least 1 batch insert was successfull, then mark that the child cases have been generated for the case
			ASrecord.ChildSuspensionCasesGenerated__c = 'Generated';			
		} else {
			ASrecord.ChildSuspensionCasesGenerated__c = 'No';
		}
		
		update ASrecord;
	}
	
}
