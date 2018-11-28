@isTest
public class AmazonRestTest {

  static testMethod void getFileTest(){     
    CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */

    createCredentials('IFAP');

    AmazonRest.getFile('Test File Name', AmazonCredentials.getCredentials('IFAP'));
  }

  static testMethod void listBucketTest(){
    CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */
    
    createCredentials('IFAP');
 
    String Filename = 'IFAP/afile';
    List<AmazonRest.S3File> res = AmazonRest.getListFiles(Filename,AmazonCredentials.getCredentials('IFAP') );
    Boolean resIsFull = res <> null;        
    System.assert(resIsFull,true);

    Boolean check = AmazonRest.checkFile( Filename,AmazonCredentials.getCredentials('IFAP'));
    System.assertEquals(check,false);

    // AmazonRest.getFile(Filename,AmazonCredentials.getCredentials('IFAP'));
    AmazonRest.make_sig('',AmazonCredentials.getCredentials('IFAP'));
    AmazonRest.genPublicExpiringAWSLink('', AmazonCredentials.getCredentials('IFAP'), 10 );
    //AmazonRest.copyFile(AmazonCredentials sourceCredentials, String sourceFilename, AmazonCredentials destCredentials, string destFilename)
  }

  static testMethod void deleteTest(){
    CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */
    
    createCredentials('IFAP');

    String Filename = 'IFAP/afile'; 
    Boolean done = AmazonRest.deleteFile(Filename,AmazonCredentials.getCredentials('IFAP') );
    
    System.assert(done,true);
  }

  static testMethod void uploadFile() {
    createCredentials('GenericAttach');
    createCredentials('RecycleBin');

    Blob pdfArchive = Blob.valueOf('Test');
    Long size = pdfArchive.size();

    //get amazon info
    String fileName = 'Certificate.pdf';
    String contentType = 'application/pdf';
    String folder = WrapperAttach.getAmazonFolder(UserInfo.getOrganizationId());

    UploadMultipleFileToAmazonButtonCtrl.UploadFile upF = UploadMultipleFileToAmazonButtonCtrl.createUploadFile('TestFolder', fileName, contentType, size, folder,  WrapperAttach.CREDENTIAL_NAME);

    Test.startTest();
    System.assert(AmazonRest.uploadFile(upF, pdfArchive));
    Test.stopTest();
  }

  static testMethod void uploadFile2() {
    createCredentials('GenericAttach');
    createCredentials('RecycleBin');

    Blob pdfArchive = Blob.valueOf('Test');
    String fileName = 'Certificate.pdf';
    String contentType = 'application/pdf';
    AmazonCredentials credential = AmazonCredentials.getCredentials(WrapperAttach.CREDENTIAL_NAME);

    Test.startTest();
    Boolean result = AmazonRest.uploadFile(credential, 'TestFolder', contentType, pdfArchive);
    Test.stopTest();

    System.assert(true, result);
  }
 
  public static void createCredentials(String credentialName){
    Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = credentialName, Prod_Configuration__c = credentialName+'aprodconf' , Dev_Configuration__c = credentialName+'adevconf');
    insert Amazon_Cred;

    List<AWSKey__c> AWS_KEYs = new List<AWSKey__c>{new AWSKey__c(name = credentialName+'aprodconf',
                                  Key__c = 'asd', 
                                  Secret__c = 'asd',  
                                  IAS_configuration_name__c = 'asdas', 
                                  IAS_Access_Point__c = 'asd',
                                  Bucket__c = 'asd',
                                  AWS_ENDPOINT_URL__c = 'asd'),
                            new AWSKey__c(name = credentialName+'adevconf' ,
                                  Key__c = 'asd', 
                                  Secret__c = 'asd',  
                                  IAS_configuration_name__c = 'asdas', 
                                  IAS_Access_Point__c = 'asd',
                                  Bucket__c = 'asd',
                                  AWS_ENDPOINT_URL__c = 'asd')
    };  

    insert AWS_KEYs;
  }
}