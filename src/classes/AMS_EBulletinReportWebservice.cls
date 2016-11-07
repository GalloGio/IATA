global class AMS_EBulletinReportWebservice {


	private static String objectBaseQuery = 'Agency_Applied_Change_code__c';
	private static String objectHistBaseQuery = 'AMS_Agency_A_Change_code_History__c';
	private static String eBulletinCSVFormat = '","';
	private static String typeEBulletin = 'W';

	/** 
		 Generate CSV main method to be called from an External Service
		 TO BE ADDED: INPUT FILTERS FROM THE PORTAL 
		 Filter: Type (Daily(D), Weekly(W))
	*/

	webservice static Boolean generateEBulletinReport( AMS_eBulletin_Profile__c eBulletinProfile){



		System.debug('Initializing...');

		//getAMSEBulletinProfile(eBulletinProfile);


		String header = getHeader();
		String body = getRecords();

		//try
		//{
		String csv = header + '\n' + body;

		/*ContentVersion file = new ContentVersion(
			  title = 'testChangeCodes_'+date.today()+'.csv',
			  versionData = Blob.valueOf( csv ),
			  pathOnClient = '/testChangeCodes_'+date.today()+'.csv'
			);
		 
		//insert file;
		System.debug('CSV File Generated: ' + file);
		*/


		Attachment attachment = new Attachment();
		attachment.Body = Blob.valueOf( csv );
		attachment.Name = String.valueOf(eBulletinProfile.name + '_testChangeCodes_'+date.today()+'.csv');

		//'a8L3E0000008kzs'
			
		attachment.ParentId = eBulletinProfile.id; 
	 	
	 	insert attachment;

		return true;
	//}
	//catch(Exception e){	
	//	return false;
    //}
		

	}

	/** 
	
	*/	

	private static String getHeader(){

		System.debug('Get CSV Header...');
		AMS_EBulletinReportHelper.getEBulletinFields(typeEBulletin,objectBaseQuery,eBulletinCSVFormat);

		return AMS_EBulletinReportHelper.headerCSV;
	}

	/** 
	
	*/	

	private static String getRecords(){
		System.debug('Get CSV Records...');

		AMS_EBulletinReportHelper EbulletinHelper = new AMS_EBulletinReportHelper();

		return EbulletinHelper.processEBulletinRecords(typeEBulletin,objectBaseQuery,objectHistBaseQuery,eBulletinCSVFormat);

	}

	/** 
	
	*/	


	private static void getAMSEBulletinFilters(AMS_eBulletin_Profile__c eBulletinProfile, Datetime startDate, Datetime endDate){
		//Daily or Weekly by record type
		
		typeEBulletin = eBulletinProfile.recordType.name.substring(0, 1).ToUpperCase();
		
		
		// map with field Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c
		List <String> countriesList;

		if(eBulletinProfile.Area_1__c ) countriesList.add('MIA');
		if(eBulletinProfile.Area_2__c ) countriesList.addAll(new List <String>{'MAD','AMM'});
		if(eBulletinProfile.Area_3__c ) countriesList.addAll(new List <String>{'SIN','BJS'});


		// Program = Location_Class__c. C = Cargo. P = Passenger. (R = CassAssociate. I = Import. Q = Courier). D = Domestic.

		List <String> programsList;
		
		if(eBulletinProfile.Program_Cargo__c)			programsList.add('C');		
		if(eBulletinProfile.Program_CASS_Associates__c)	programsList.addAll(new List <String>{'R','I','Q'});	
		if(eBulletinProfile.Program_Passage__c)			programsList.add('P');
		
		//Add filter by Date
		
		
		//Add Opt_out_Bulletin__c this field is to be used in the schedule batch		
	}


	/** 
	Exceptions handling for E Bulletin	
	*/	

	class AMS_EBulletinException extends Exception {}


}