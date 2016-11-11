global class AMS_EBulletinReportWebservice {

	private static String objectBaseQuery = 'Agency_Applied_Change_code__c';

	/** 
		 Generate CSV main method to be called from an External Service
		 TO BE ADDED: INPUT FILTERS FROM THE PORTAL 
	*/

	webservice static Boolean generateEBulletinReport(){

		System.debug('Initializing...');

		//try
		//{
			String csv = getHeader() + '\n' + getRecords();

			ContentVersion file = new ContentVersion(
				  title = 'testChangeCodes_2.csv',
				  versionData = Blob.valueOf( csv ),
				  pathOnClient = '/testChangeCodes_2.csv'
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
		AMS_EBulletinReportHelper.getEBulletinFields('";"',objectBaseQuery);

		return AMS_EBulletinReportHelper.headerCSV;
	}

	private static String getRecords(){
		System.debug('Get CSV Records...');

		AMS_EBulletinReportHelper EbulletinHelper = new AMS_EBulletinReportHelper();

		return EbulletinHelper.processEBulletinRecords(objectBaseQuery,'";"');


	}


}