/**
* Tools class used to communicate with AWS web services class.
* This class will load configuration from SFDC et is in charge of sending data
*
*/
global  class AWSTools {
	

	 private S3.AmazonS3 as3 = null;
	 private AWSKeys credentials = null;
	 private static Map<String,AWSTools> instance = new Map<string,AWSTools>();
	 private String OwnerId ;
	 public static String ERROR_MESSAGE  = 'ERROR';
	 public static String SUCCESS_MESSAGE  = 'SUCCESS';
	 private static String default_permission  = 'authenticated-read';
	 
	 private AWSTools(String name ){
	 	if(Test.isRunningTest()) return;
	 	//change : get name from custom setting
	 	AWSKeys credentials = new AWSKeys(name);
	 	if(!Test.isRunningTest())
		as3 = new S3.AmazonS3(credentials.key,credentials.secret);
		Datetime now = Datetime.now();
		//This performs the Web Service call to Amazon S3 and retrieves all the Buckets in your AWS Account. 
		S3.ListAllMyBucketsResult allBuckets = as3.ListAllMyBuckets(as3.key,now,as3.signature('ListAllMyBuckets',now));
		//Store the Canonical User Id for your account
		OwnerId = allBuckets.Owner.Id;
	 }
	 
	 /**
	 * Singleton éethod to get alway the same object & limit access to init config
	 */
	 public static AWSTools getInstance(String Name){
	 	AWSTools r  = AWSTools.instance.get(name);
	 	if (r==null){
	 		r = new AWSTools(name);
	 		AWSTools.instance.put(name,  r);
	 	}
	 	return r;
	 }

	 /**
	 *
	 * Create a bucket on Amazon S3
	 * if saveInSystem = true , will erase default bucket with new one on SFDC Configuration
	 */
	 public boolean createBucket(String bucketNameToCreate, boolean saveInSystem){
		  try{	 
			   Datetime now = Datetime.now();        
			  
			   //This performs the Web Service call to Amazon S3 and create a new bucket.
			   if(!Test.isRunningTest())
		       S3.CreateBucketResult createBucketReslt = as3.CreateBucket(bucketNameToCreate,null,as3.key,now,as3.signature('CreateBucket',now));
		        system.debug('[Attachment Migration Process debug] Successfull bucket creation');
		       return true;
	       }
	
	       catch(Exception ex){
			   	 system.debug('[Attachment Migration Process debug] Error while creating a BucketAmazon');
			   return false;	
		   }
       
	}
	 
	 /**
	 *
	 * Push a file on S3 on dedicat
	 */
	 public boolean pushFileInAWS(String bucketToUploadObject, String accessTypeSelected, Blob objectData, String fileName, Integer fileSize ){
	 	try{  
			  Datetime now = Datetime.now();	  
			  String docBody = EncodingUtil.base64Encode(objectData);
			  if(!Test.isRunningTest()){
					Boolean putObjResult = as3.PutObjectInline_ACL(bucketToUploadObject,fileName,null,docBody,fileSize,accessTypeSelected,as3.key,now,as3.signature('PutObjectInline',now),as3.secret, OwnerId);
					if(putObjResult==true){
						system.debug('[Attachment Migration Process debug] Successfull upload file on Amazon');
					}else {
						system.debug('[Attachment Migration Process debug] Error while uploading file on Amazon');
						return false;
					}
			  }
			  return true;
	    }catch(Exception ex){
		     system.debug('[Attachment Migration Process debug] Error while uploading file on Amazon : '+ex.getMessage());
		    return false;
		}
	 }
	 
	 /**
	 * Ask to S3 to delete a file
	 */
	 public boolean removeFileFromS3(String bucketObject, String fileName){
	 	try{  
	 		  system.debug('[Attachment Migration Process debug] try to delete   '+fileName+ ' from Bucket '+bucketObject);
			  Datetime now = Datetime.now();	
			  if(!Test.isRunningTest())  
			  	as3.DeleteObject(bucketObject,fileName,as3.key,now,as3.signature('DeleteObject',now),as3.secret);
			  return true;
	    }catch(Exception ex){
		    system.debug('[Attachment Migration Process debug] Error while deleting file on Amazon : '+ex.getMessage());
		    return false;
		}
	 	
	 	
	 }

	 /**
	 * Ask to S3 rename a file by copying with the new name and deleting the old file
	 */
	 public boolean renameFileInS3(String bucketObject, String originalFileName, String newFileName){
	 	try{  
	  		system.debug('[File rename debug] try to rename ' + originalFileName + ' to ' + newFileName + ' in Bucket ' + bucketObject);
			Datetime now = Datetime.now();	
			if(!Test.isRunningTest())  {
				as3.CopyObject(bucketObject,originalFileName,bucketObject,newFileName,null,null,null,null,null,null,null,null,as3.key,now,as3.signature('CopyObject',now),as3.secret);

			  	as3.DeleteObject(bucketObject,originalFileName,as3.key,now,as3.signature('DeleteObject',now),as3.secret);
			}
			return true;
	    }catch(Exception ex){
		    system.debug('[File rename debug] Error while renaming file on Amazon : '+ex.getMessage());
		    return false;
		}
	 	
	 	
	 }
	 
	/**
	*
	*/
    webService static Boolean DeleteAttachment (String attId)
    {  
        try
        {
            Attachment att = [SELECT Id  FROM Attachment where Id=:attId];
            delete att;
            return true;
        }
        catch (Exception e)
        {
            System.debug('** Delete Attachment issue '+e.getMessage());
            
        }
    	return false;
    }   
	 
}