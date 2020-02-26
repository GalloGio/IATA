/*
	Class Name: ISSP_AMC_Upload_Files
	Related Classes:

	Copyright @Right IT Services

	Purpose: Apex page to communicate with the server

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	Filipa Martins		27-11-2018   	INITIAL DEVELOPMENT
*/

public class ISSP_AMC_Upload_Files {
	public AmazonFile__c airOperator{get;set;}
	public AmazonFile__c airFerryBus{get;set;}
	public AmazonFile__c certificateIncorporationRegistration{get;set;}
	public AmazonFile__c breakdownOfShareholders{get;set;}
	public AmazonFile__c uld{get;set;}
	public AmazonFile__c nonScheduled{get;set;}
	public AmazonFile__c authorizationTransportationServices{get;set;}
	public AmazonFile__c trafficAgreementValidIATACode{get;set;}
	public AmazonFile__c signedLetterCrs{get;set;}
	public AmazonFile__c passengers{get;set;}
	public AmazonFile__c cargos{get;set;}
	public AmazonFile__c currentStructureLocation{get;set;}
	public AmazonFile__c caaLetterOpeningDate{get;set;}
	public AmazonFile__c commercialScheduledOperations{get;set;}
	public AmazonFile__c metropolitanLetteAirportA{get;set;}
	public AmazonFile__c metropolitanLetteAirportB{get;set;}
	public AmazonFile__c airlineIssuedAOC{get;set;}

	public Id recordTypeId{get;set;}
	public Boolean isPublic{get;set;}

	public ISSP_AMC_Upload_Files(){
		AMC_Configuration__c amcConfiguration = AMC_Configuration__c.getInstance();
		recordTypeId = amcConfiguration.amazonRecordTypeId__c;
		isPublic = amcConfiguration.isPublicAmazonFile__c;

		system.debug('DB::recordTypeId'+recordTypeId);
		system.debug('DB::isPublic'+isPublic);
	}


	public List<Participant_Online_App_Requirement__c> savedForms{get; set;}
	public Set<Id> myAmazon{get; set;}
	public String amazonFileId{get;set;}
	public Boolean hasFile{get;set;}

	public Participation_Online_Application__c participationBackend{
		get {
			return participationBackend;
		}
		set {
			participationBackend = value;
			getUploadedFileInfo();
		}

	}

	public void saveToAmazon(){

		ISSP_AMC_DAO.saveAmazonFileInJunctionObject(amazonFileId, participationBackend.Id);

	}

	public String credentialName  {
		get { return WrapperAttach.CREDENTIAL_NAME; }
	}

	public void getUploadedFileInfo(){
		try {
			savedForms = new List<Participant_Online_App_Requirement__c>(
					[SELECT id, AmazonFile__c, AmazonFile__r.Name, AmazonFile__r.Full_Name_Unique__c, Participation_Application_Requirement__c,
							Participation_Application_Requirement__r.Component_Key__c
							FROM Participant_Online_App_Requirement__c
							WHERE Participation_Online_Application__c = :participationBackend.Id
					LIMIT 100]);

			system.debug('DB::SIZE'+savedForms.size());
			system.debug('DB::'+savedForms);


			AmazonFile__c tempAmazonFile;

			airOperator = null;
			airFerryBus = null;
			certificateIncorporationRegistration = null;
			breakdownOfShareholders = null;
			uld = null;
			authorizationTransportationServices = null;
			trafficAgreementValidIATACode = null;
			signedLetterCrs = null;
			passengers = null;
			cargos = null;
			currentStructureLocation = null;
			caaLetterOpeningDate = null;
			commercialScheduledOperations = null;
			metropolitanLetteAirportA = null;
			metropolitanLetteAirportB = null;
			airlineIssuedAOC = null;
			nonScheduled = null;


			for(Participant_Online_App_Requirement__c eachAmazonFileInForm : savedForms){
				if(eachAmazonFileInForm.AmazonFile__c == null){
					continue;
				}
				tempAmazonFile = new AmazonFile__c(
					id = eachAmazonFileInForm.AmazonFile__c,
					Name = eachAmazonFileInForm.AmazonFile__r.Name,
					Full_Name_Unique__c = eachAmazonFileInForm.AmazonFile__r.Full_Name_Unique__c
					);


				/*if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIROPERATORCERTIFICATE)
					airOperator = tempAmazonFile;*/

				/*else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_RAIL_FERRY_OR_BUS)
					airFerryBus = tempAmazonFile;*/

				 if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CERTIFICATEINCORPORATIONREGISTRATION){
				 	//tempAmazonFile.File_Identifier_picklist__c = 'Official copy of Certificate of Incorporation/Registration (COI/COR)';
				 	certificateIncorporationRegistration = tempAmazonFile;
				 }


				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_BREAKDOWNOFSHAREHOLDERS){
					//tempAmazonFile.File_Identifier_picklist__c = 'Official copy of Breakdown of shareholders and percentages';
					breakdownOfShareholders = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ULD){
					//tempAmazonFile.File_Identifier_picklist__c = 'Copy of the Certificate of IATA Strategic Partnership';
					uld = tempAmazonFile;
				}


				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_NON_SCHEDULED){
					//tempAmazonFile.File_Identifier_picklist__c = 'Non-scheduled airlines documents';
					nonScheduled = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZATION_TRANSPORTATION_SERVICES){
					//tempAmazonFile.File_Identifier_picklist__c = 'Valid authorization issued by a government body to provide transportation services';
					authorizationTransportationServices = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TRAFFIC_AGREEMENT_VALID_IATA_CODE){
					//tempAmazonFile.File_Identifier_picklist__c = 'Copy of Intermodal Traffic Agreement with an airline holding a valid IATA Code';
					trafficAgreementValidIATACode = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SIGNED_LETTER_CRS){
					//tempAmazonFile.File_Identifier_picklist__c = 'Signed confirmation in letterhead from an airline holding a valid IATA Code that the CRS is providing services to the airline';
					signedLetterCrs = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PASSENGERS){
					//tempAmazonFile.File_Identifier_picklist__c = 'Passenger airlines document';
					passengers = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CARGOS){
					//tempAmazonFile.File_Identifier_picklist__c = 'Cargo Airlines document';
					cargos = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CURRENTSTRUCTURELOCATION){
					//tempAmazonFile.File_Identifier_picklist__c = 'Visual proof (pictures) of the current structure of the location and signage';
					currentStructureLocation = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CAALETTEROPENINGDATE){
					//tempAmazonFile.File_Identifier_picklist__c = 'Letter from the CAA informing the official opening date of the location';
					caaLetterOpeningDate = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_COMMERCIALSCHEDULEDOPERATIONS){
					//tempAmazonFile.File_Identifier_picklist__c = 'Confirmation of the commercial scheduled operations that will be performed in the location';
					commercialScheduledOperations = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AREA){
					//tempAmazonFile.File_Identifier_picklist__c = 'Copy of signed letter issued by the Airport Authority approving the creation of this Metropolitan Area (Airport 1)';
					metropolitanLetteAirportA = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AIRPORTB){
					//tempAmazonFile.File_Identifier_picklist__c = 'Copy of signed letter issued by the Airport Authority approving the creation of this Metropolitan Area (Airport 2)';
					metropolitanLetteAirportB = tempAmazonFile;
				}

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIRLINE_ISSUED_AOC){
					//tempAmazonFile.File_Identifier_picklist__c = 'Copy of a valid AOC (at least with 3 months of validity)';
					airlineIssuedAOC = tempAmazonFile;
				}
			}

		}
		catch(Exception ex){
			// no file exist, no need to show exception
			System.debug(ex.getMessage());
		}
	}


	/**
	Delete an attachment archived attachment or Amazon Attachment
	**/
	@RemoteAction
	public static Boolean deleteAttachment(string strId, String fullName) {

		String idType = String.ValueOf(Id.valueOf(strId).getSObjectType());
		Boolean result = false;
		if (idType.equals('Attachment')) {
			result = deleteSalesforceAttachment(strId);
		}
		if (idType.equals('AmazonFile__c')) {
			result = deleteAmazonAttachment(strId, fullName);
			result = deleteSalesforceJunctionAttachment(strId);
		}
		return result;
	}

	private static Boolean deleteSalesforceAttachment(String id) {
		try {
			delete [SELECT Id  FROM Attachment where Id = :id];
			return true;
		} catch (Exception e) {
			System.debug(e.getMessage());
			return false;
		}
	}

	private static Boolean deleteSalesforceJunctionAttachment(String id) {
		try {
			List <Participant_Online_App_Requirement__c> appReq = [SELECT AmazonFile__c, AmazonFile__r.Full_Name_Unique__c FROM Participant_Online_App_Requirement__c where AmazonFile__c = :id LIMIT 1];
			if(appReq != null && !appReq.isEmpty()){
				deleteAmazonAttachment(appReq[0].AmazonFile__c, appReq[0].AmazonFile__r.Full_Name_Unique__c);
				appReq[0].AmazonFile__c = null;
				update appReq;
			}
			return true;
		} catch (Exception e) {
			System.debug(e.getMessage());
			return false;
		}
	}

	private static Boolean deleteAmazonAttachment(String strId, String fullName) {
		try {
			Id sObjectId = Id.ValueOf(strId);
			WrapperAttach attach = WrapperAttach.getAmazonAttachment( sObjectId, fullName);
			Boolean result = attach.moveToBucket();
			return result;

		} catch (Exception e) {
			System.debug(e.getMessage());
			return false;
		}
	}

	public static void deleteAttachmentInFuture(string strId, String fullName) {

		String idType = String.ValueOf(Id.valueOf(strId).getSObjectType());
		Boolean result = false;
		if (idType.equals('Attachment')) {
			//result = deleteSalesforceAttachment(strId);
			deleteSalesforceAttachmentInFuture(strId);
		}
		if (idType.equals('AmazonFile__c')) {
			//deleteAmazonAttachment(strId, fullName);
			//result = deleteSalesforceJunctionAttachment(strId);
			deleteSalesforceJunctionAttachmentInFuture(strId);
		}
		//return result;
	}

	/**
		Delete a standard attachment in Salesforce
	**/
	@Future
	private static void deleteSalesforceAttachmentInFuture(String id) {
		deleteSalesforceAttachment(id);
	}

	/**
	Delete a standard attachment in junctionObject
	**/
	@Future
	private static void deleteSalesforceJunctionAttachmentInFuture(String id) {
		deleteSalesforceJunctionAttachment(id);
	}

	/**
		Delete a file in Amazon Bucket, including AmazonFile object in Amazon
	**/
	/*@Future
	private static void deleteAmazonAttachmentInFuture(String strId, String fullName) {
		deleteAmazonAttachment(strId, fullName);
	}*/

	/**
	Downlaod an attachment
	**/
	@RemoteAction
	public static string getExpiringLink(string fileName ) {
		Integer secondsValid = 300;
		String link = AmazonRest.genPublicExpiringAWSLink( fileName, WrapperAttach.CREDENTIAL, secondsValid);
		return link;
	}
}
