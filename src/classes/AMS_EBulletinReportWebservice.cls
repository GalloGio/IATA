global class AMS_EBulletinReportWebservice {

	private static String objectBaseQuery = 'Agency_Applied_Change_code__c';
	private static String typeEBulletin;

	/** 
		 Generate CSV main method to be called from an External Service
		 TO BE ADDED: INPUT FILTERS FROM THE PORTAL 
		 Filter: Type (Daily(D), Weekly(W))
	*/

	webservice static Boolean generateEBulletinReport(String typeEBulletinOverride){
		System.debug('Initializing...');

		typeEBulletin = typeEBulletinOverride;
		//try
		//{
			String csv = getHeader() + '\n' + getRecords();

			ContentVersion file = new ContentVersion(
				  title = 'testChangeCodes_'+date.today()+'.csv',
				  versionData = Blob.valueOf( csv ),
				  pathOnClient = '/testChangeCodes_'+date.today()+'.csv'
				);
			 
			insert file;
			System.debug('CSV File Generated: ' + file);

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
		AMS_EBulletinReportHelper.getEBulletinFields(typeEBulletin,objectBaseQuery,'";"');

		return AMS_EBulletinReportHelper.headerCSV;
	}

	private static String getRecords(){
		System.debug('Get CSV Records...');

		AMS_EBulletinReportHelper EbulletinHelper = new AMS_EBulletinReportHelper();

		return EbulletinHelper.processEBulletinRecords(typeEBulletin,objectBaseQuery,'";"');


	}

}