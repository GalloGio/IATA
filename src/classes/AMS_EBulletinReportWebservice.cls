global without sharing class AMS_EBulletinReportWebservice {


	private static String objectBaseQuery = 'Agency_Applied_Change_code__c';
	private static String objectHistBaseQuery = 'AMS_Agency_A_Change_code_History__c';
	private static String eBulletinCSVFormat = '","';
	private static AMSEBulletinFilters filters;
	//private static String typeEBulletin = 'W';

	/** 
		 Generate CSV main method to be called from an External Service
		 TO BE ADDED: INPUT FILTERS FROM THE PORTAL 
		 Filter: Type (Daily(D), Weekly(W))
	*/


	webservice static ID generateEBulletinReport( AMS_eBulletin_Profile__c eBulletinProfile,Datetime startDate, Datetime endDate, String period){


		if(period.equalsIgnoreCase('Last') && eBulletinProfile.Last_Run__c != null && eBulletinProfile.Last_Run__c > startDate)
			startDate = eBulletinProfile.Last_Run__c;


		filters = new AMSEBulletinFilters(eBulletinProfile, startDate, endDate);

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


		//Set the last run time
	 	eBulletinProfile.Last_Run__c = system.now();

		Attachment attachment = new Attachment();
		attachment.Body = Blob.valueOf( csv );
		attachment.Name = String.valueOf(eBulletinProfile.name + '_testChangeCodes_'+date.today()+'.csv');

		//'a8L3E0000008kzs'
			
		attachment.ParentId = eBulletinProfile.id; 
	 	
	 	insert attachment;

	 	update eBulletinProfile;

		return attachment.id;
	//}
	//catch(Exception e){	
	//	return false;
    //}
		

	}

	/** 
	
	*/	

	private static String getHeader(){

		System.debug('Get CSV Header...');
		AMS_EBulletinReportHelper.getEBulletinFields(filters,objectBaseQuery,eBulletinCSVFormat);

		return AMS_EBulletinReportHelper.headerCSV;
	}

	/** 
	
	*/	

	private static String getRecords(){
		System.debug('Get CSV Records...');

		AMS_EBulletinReportHelper EbulletinHelper = new AMS_EBulletinReportHelper();

		return EbulletinHelper.processEBulletinRecords(filters,objectBaseQuery,objectHistBaseQuery,eBulletinCSVFormat);

	}


	/** 
	 Wrapper Object with the filters from the Portal

	*/
	public class AMSEBulletinFilters {
		
		public String typeEBulletin;
        public List <String> areaList = new List <String>();
  		public List <String> programsList = new List <String>();
  		public List <String> countriesList = new List <String>();
  		public Datetime fromCCDate;
        public Datetime toCCDate;
       	public AMS_eBulletin_Profile__c eBulletinProfile;

        public AMSEBulletinFilters(AMS_eBulletin_Profile__c eBulletinProfile, Datetime fromCCDate, Datetime toCCDate){
        		//Daily or Weekly by record type
			
			this.typeEBulletin = Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosById.get(eBulletinProfile.RecordTypeId).Name.substring(0, 1).ToUpperCase();
			
			
			// map with field Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c
			List <String> areaList = new List<String>();

			if(eBulletinProfile.Area_1__c ) areaList.add('MIA');
			if(eBulletinProfile.Area_2__c ) areaList.addAll(new List <String>{'MAD','AMM'});
			if(eBulletinProfile.Area_3__c ) areaList.addAll(new List <String>{'SIN','BJS'});

			this.areaList = areaList;

			// Program = Location_Class__c. C = Cargo. P = Passenger. (R = CassAssociate. I = Import. Q = Courier). D = Domestic.

			List <String> programsList = new List<String>();
			
			if(eBulletinProfile.Program_Cargo__c)			programsList.add('C');		
			if(eBulletinProfile.Program_CASS_Associates__c)	programsList.addAll(new List <String>{'R','I','Q'});	
			if(eBulletinProfile.Program_Passage__c)			programsList.add('P');
			
			
			this.programsList = programsList;

			//map countries List
			
			this.countriesList = eBulletinProfile.CountriesList__c.split(';');

			// filter by Date

			this.fromCCDate = fromCCDate;
			this.toCCDate   = toCCDate;

			// Agency Information Mapping --- for this case the profile must be passed (mapped in the Custom Setting AMSEBulletinCCSections)
			
			this.eBulletinProfile = eBulletinProfile;
		/*eBulletinProfile.Agency_Info_Defaults__c;
			eBulletinProfile.Agency_Info_Reviews__c;
			eBulletinProfile.Agency_Info_New_Aplication_Processes__c;
			eBulletinProfile.Agency_Info_Agency_Changes__c;
			eBulletinProfile.Agency_Info_Irregularities__c;
			eBulletinProfile.Agency_Info_Termination_Closures__c;
			*/
        }


	}



}