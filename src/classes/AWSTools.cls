/**
Tools class used to communicate with AWS web services class.
This class will load configuration from SFDC et is in charge of sending data
*/
global class AWSTools{

	private S3.AmazonS3 as3 = null;
	private AWSKeys credentials = null;
	private static Map<String,AWSTools> instance = new Map<string,AWSTools>();
	private String OwnerId ;
	public static String ERROR_MESSAGE = 'ERROR';
	public static String SUCCESS_MESSAGE = 'SUCCESS';
	private static String default_permission = 'authenticated-read';

	private AWSTools(String name ){
		Datetime now = Datetime.now();
		if(Test.isRunningTest()) return;
		//change : get name from custom setting		
		AWSKeys credentials = new AWSKeys(name);
		as3 = new S3.AmazonS3(credentials.key,credentials.secret);
		//This performs the Web Service call to Amazon S3 and retrieves all the Buckets in your AWS Account.
		S3.ListAllMyBucketsResult allBuckets = as3.ListAllMyBuckets(as3.key,now,as3.signature('ListAllMyBuckets',now));
		//Store the Canonical User Id for your account
		OwnerId = allBuckets.Owner.Id;
	}

	/**
	Singleton method to get alway the same object & limit access to init config
	*/
	public static AWSTools getInstance(String Name){
		AWSTools r = AWSTools.instance.get(name);
		if (r==null){
			r = new AWSTools(name);
			AWSTools.instance.put(name, r);
		}
		return r;
	}

	/**
	 Ask to S3 to delete a file
	*/
	public boolean removeFileFromS3(String bucketObject, String fileName){
		try{
			Datetime now = Datetime.now();
			if(!Test.isRunningTest())
				as3.DeleteObject(bucketObject,fileName,as3.key,now,as3.signature('DeleteObject',now),as3.secret);
				return true;
		}catch(Exception ex){
			system.debug(LoggingLevel.ERROR, '[Attachment Migration Process debug] Error while deleting file on Amazon : '+ex.getMessage());
			return false;
		}
	}

	/**
	 Ask to S3 rename a file by copying with the new name and deleting the old file
	*/
	public boolean renameFileInS3(String bucketObject, String originalFileName, String newFileName){
		try{
			system.debug(LoggingLevel.ERROR, '[File rename debug] try to rename ' + originalFileName + ' to ' + newFileName + ' in Bucket ' + bucketObject);
			Datetime now = Datetime.now();
			if(!Test.isRunningTest()) {
				as3.CopyObject(bucketObject,originalFileName,bucketObject,newFileName,null,null,null,null,null,null,null,null,as3.key,now,as3.signature('CopyObject',now),as3.secret);
				as3.DeleteObject(bucketObject,originalFileName,as3.key,now,as3.signature('DeleteObject',now),as3.secret);
			}
			return true;
		}catch(Exception ex){
			system.debug(LoggingLevel.ERROR, '[File rename debug] Error while renaming file on Amazon : '+ex.getMessage());
			return false;
		}
	}

	webService static Boolean DeleteAttachment (String attId){
		try{
			Attachment att = [SELECT Id FROM Attachment where Id=:attId];
			delete att;
			return true;
		}
		catch (Exception e)	{
			System.debug(LoggingLevel.ERROR, '** Delete Attachment issue '+e.getMessage());
		}
		return false;
	}
}
