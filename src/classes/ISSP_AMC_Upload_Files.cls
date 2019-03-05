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
				tempAmazonFile = new AmazonFile__c(id = eachAmazonFileInForm.AmazonFile__c, Name = eachAmazonFileInForm.AmazonFile__r.Name, Full_Name_Unique__c = eachAmazonFileInForm.AmazonFile__r.Full_Name_Unique__c);
				/*if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIROPERATORCERTIFICATE)
					airOperator = tempAmazonFile;*/

				/*else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_RAIL_FERRY_OR_BUS)
					airFerryBus = tempAmazonFile;*/

				 if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CERTIFICATEINCORPORATIONREGISTRATION)
					certificateIncorporationRegistration = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_BREAKDOWNOFSHAREHOLDERS)
					breakdownOfShareholders = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ULD)
					uld = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_NON_SCHEDULED)
					nonScheduled = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZATION_TRANSPORTATION_SERVICES)
					authorizationTransportationServices = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TRAFFIC_AGREEMENT_VALID_IATA_CODE)
					trafficAgreementValidIATACode = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SIGNED_LETTER_CRS)
					signedLetterCrs = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PASSENGERS)
					passengers = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CARGOS)
					cargos = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CURRENTSTRUCTURELOCATION)
					currentStructureLocation = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CAALETTEROPENINGDATE)
					caaLetterOpeningDate = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_COMMERCIALSCHEDULEDOPERATIONS)
					commercialScheduledOperations = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AREA)
					metropolitanLetteAirportA = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AIRPORTB)
					metropolitanLetteAirportB = tempAmazonFile;

				else if(eachAmazonFileInForm.Participation_Application_Requirement__r.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIRLINE_ISSUED_AOC)
					airlineIssuedAOC = tempAmazonFile;
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
	public static void deleteAttachment(string strId, String fullName) {

		String idType = String.ValueOf(Id.valueOf(strId).getSObjectType());
		Boolean result = false;
		if (idType.equals('Attachment')) {
			//result = deleteSalesforceAttachment(strId);
			deleteSalesforceAttachment(strId);
		}
		if (idType.equals('AmazonFile__c')) {
			//result = deleteAmazonAttachment(strId, fullName);
			//result = deleteSalesforceJunctionAttachment(strId);
			deleteSalesforceJunctionAttachment(strId);
		}
		//return result;
	}

	/**
        Delete a standard attachment in Salesforce
    **/
    @Future
	private static void deleteSalesforceAttachment(String id) {
		try {
			delete [SELECT Id  FROM Attachment where Id = :id];
			//return true;
		} catch (Exception e) {
			System.debug(e.getMessage());
			//return false;
		}
	}

	/**
	Delete a standard attachment in junctionObject
	**/
	@Future
	private static void deleteSalesforceJunctionAttachment(String id) {
		try {
			List <Participant_Online_App_Requirement__c> appReq = [SELECT AmazonFile__c, AmazonFile__r.Full_Name_Unique__c FROM Participant_Online_App_Requirement__c where AmazonFile__c = :id LIMIT 1];
			if(appReq != null && !appReq.isEmpty()){
				deleteAmazonAttachment(appReq[0].AmazonFile__c, appReq[0].AmazonFile__r.Full_Name_Unique__c);
				appReq[0].AmazonFile__c = null;
				update appReq;
			}
			//return true;
		} catch (Exception e) {
			System.debug(e.getMessage());
			//return false;
		}
	}

	/**
        Delete a file in Amazon Bucket, including AmazonFile object in Amazon
    **/
    @Future
	private static void deleteAmazonAttachment(String strId, String fullName) {
		try {
			Id sObjectId = Id.ValueOf(strId);
			WrapperAttach attach = WrapperAttach.getAmazonAttachment( sObjectId, fullName);
			Boolean result = attach.moveToBucket();
			//return result;

		} catch (Exception e) {
			System.debug(e.getMessage());
			//return false;
		}
	}

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