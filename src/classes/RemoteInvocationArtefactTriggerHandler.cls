public with sharing class RemoteInvocationArtefactTriggerHandler {

	public static List<Remote_Invocation_Artefact__c> triggerNew = (List<Remote_Invocation_Artefact__c>) Trigger.new;
	public static List<Remote_Invocation_Artefact__c> triggerOld = (List<Remote_Invocation_Artefact__c>) Trigger.old;

	public static Map<Id, Remote_Invocation_Artefact__c> newMap = (Map<Id,Remote_Invocation_Artefact__c>) Trigger.newMap;
	public static Map<Id, Remote_Invocation_Artefact__c> oldMap = (Map<Id,Remote_Invocation_Artefact__c>) Trigger.oldMap;

	public static void handleBeforeInsert(){
	//	assignRecordtypeToRequest();
	//	performSanityCheck();
	}

	public static void performSanityCheck(){
		
		/*List<Remote_Invocation_Artefact__c> reqsWithError = new List<Remote_Invocation_Artefact__c>(); 
		Map<String,Remote_Invocation_Artefact__c> mapNewgenIATAcodeReqsToProcess = new Map<String,Remote_Invocation_Artefact__c>(); 
		Set<String> iataCodes = new set<String>();
		for(Remote_Invocation_Artefact__c artifact : triggerNew){
			iataCodes.add(artifact.IATA_Code__c);
		}

		Map<ID,Account> mapIDAccs = new Map<ID,Account>([SELECT ID,IATACode__c FROM Account WHERE IATACode__c IN :iataCodes]);
		mapIATACodeAccs = new Map<String,Account>();
		
		for(Account acc : mapIDAccs.values()){
			mapIATACodeAccs.put(acc.iataCode__c, acc);
		}

		for(Remote_Invocation_Artefact__c artifact : triggerNew){
			
			if(!mapIATACodeAccs.contains(artifact.IATA_Code__c) 
				|| artifact.Request_Type__c == '' || artifact.Request_Type__c == null 
				|| artifact.Source_system__c == '' || artifact.Source_system__c == null){
				
				//NewGen validations
				if(artifact.Request_Type__c == NEWGEN_EASY_PAY){
					if(mapIATACodeAccs.get(artifact.IATA_Code__c).recordtypeid == AMS_Utils.RECTYPE_IATAAGENCY){ 
						mapNewgenIATAcodeReqsToProcess.add(artifact.IATA_Code__c, re);
					}
				}
			}

			else{
				artifact.Status__c = 'Failed';
				artifact.Completed__c = true;
				reqsWithError.add(re);
			}
		}

		if(!mapNewgenIATAcodeReqsToProcess.isEmpty()) process_NewGen_Model_A(mapNewgenIATAcodeReqsToProcess, mapIDAccs);
		if(!reqsWithError.isEmpty()) update reqsWithError;*/
		
	}

	public static void process_NewGen_Model_A(Map<String,Remote_Invocation_Artefact__c> reqsToCreateOSCAR, Map<ID,Account> mapIDAccs){
		/*
		1.	Fetch Account ID from IATA Code received
		2.	Fetch Active, Authorized signatory Contact associated to Account
		3.	Create OSCAR Communication case
		4.	Create Staging Area
		5.	Create Oscar

		*/
	/*	List<Remote_Invocation_Artefact__c> requestToUpdate = new List<Remote_Invocation_Artefact__c>();
		List<ID> listOSCARIDs = ANG_OSCARProcessHelper.createIEPAccountOscar(mapIDAccs,'A'); //mudar o metodo para devolver a lista de oscars
		
		for(AMS_OSCAR__c oscar : listOSCARIDs){
			String iataCode = mapIDAccs.get(oscar.Account__c).IATACode__c;
			
			reqsToCreateOSCAR.get(iataCode).Completed__c = true;
			reqsToCreateOSCAR.get(iataCode).Status__c = 'Success';
			reqsToCreateOSCAR.get(iataCode).Object_ID_Created__c = oscar.id;

			requestToUpdate.add(reqsToCreateOSCAR.get(iataCode));
			reqsToCreateOSCAR.remove(iataCode);
		}

		//probabbly impossible but ... who knows?
		if(!reqsToCreateOSCAR.isEmpty()){
			for(Remote_Invocation_Artefact__c artifact : reqsToCreateOSCAR.values()){
				artifact.Status__c = 'Failed';
				artifact.Completed__c = true;
				requestToUpdate.add(re);
				reqsToCreateOSCAR.remove(artifact.IATA_Code__c);
			}
		}

		update requestToUpdate;*/


		/*
		Map<id,ANG_OSCARProcessHelper.OscarObjectsWrapper> accOscarObjsMap = new Map<id,ANG_OSCARProcessHelper.OscarObjectsWrapper>();
		ANG_OSCARProcessHelper.OscarObjectsWrapper oscarObjs;
		
		Map<String,Object> fieldsOfObject;

		List<Case> casesToInsert = new List<Case>();


		Set<ID> accsIDs = new Set<ID>();
		List<AMS_OSCAR__c> oscarsToInsert = new List<AMS_OSCAR__c>();
		Map<ID,Contact>  mapAccontIdContact = new map<ID,Contact>();

		//query to fetch contacts
		for(Contact c :[SELECT ID FROM Contact WHERE ##### IS ACTIVE AND AUTORIZED AND AccountID IN accsIDs]){
			mapAccontIdContact.put(c.AccountID, c);
		}

		for(Remote_Invocation_Artefact__c artifact : reqs){

			Account acc = mapIATACodeAccs.get(artifact.IATA_Code__c);

			fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Account_Concerned__c',acc.id);
	      	fieldsOfObject.put('ContactId',mapAccontIdContact.get(acc.id).Id);
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
	        dmo.artifact.useDefaultRule = true;
	        cse.setOptions(dmo);

	        oscarObjs = new ANG_OSCARProcessHelper.OscarObjectsWrapper();
	        oscarObjs.cse = cse;
	        oscarObjs.con = mapAccontIdContact.get(acc.id);

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
	            //AMS_AgencyRegulationAutoRenewal.sendEmailAlert(new List<Contact>{accOscarObjsMap.get(acc.Id).con}, accOscarObjsMap.get(acc.Id).oscar.Id, artifact.ANGemailTemplates(AMS_Utils.NGANNUALREVAL, null, true), accOscarObjsMap.get(acc.Id).oscar.Oscar_Communication_Case_Id__c, owea[0], false);			

			System.debug('[ANG_OscarProcessHelper.createRevalidationOscar] - FINISHING... INSERTING OSCARS: '+ accOscarObjsMap.get(acc.id).oscar.Id + ' | Case: '+accOscarObjsMap.get(acc.id).cse.Id);
		}

		if(!casesToUpdate.isEmpty())
			update casesToUpdate;

		for (Account acc: accs){

			if(accsToSendEmail.contains(acc.Id))
	            AMS_AgencyRegulationAutoRenewal.sendEmailAlert(keyContactMap.get(acc.Id), accOscarObjsMap.get(acc.Id).oscar.Id, artifact.ANGemailTemplates(AMS_Utils.NGANNUALREVAL, null, true), accOscarObjsMap.get(acc.Id).oscar.Oscar_Communication_Case_Id__c, owea[0], false);			

		}
        */

	}

}