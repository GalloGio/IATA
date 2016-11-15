@isTest
private class AmazonRestTest {

	static testMethod void getFileTest(){

                
                
               CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */
        
        
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'aprodconf' , Dev_Configuration__c = 'adevconf');
         insert Amazon_Cred;
         
         list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{new AWSKey__c(name = 'aprodconf',
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                       AWS_ENDPOINT_URL__c = 'asd'),
                                                         new AWSKey__c(name = 'adevconf' ,
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                      AWS_ENDPOINT_URL__c = 'asd')
                                                                       };  
        
         insert AWS_KEYs;   
                String FileNmae = 'IFAP/afile';
		
		AmazonRest.getFile('Test File Name', AmazonCredentials.getCredentials('IFAP'));
	}

         static testMethod void listBucketTest(){
                
                
               CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */
        
        
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'aprodconf' , Dev_Configuration__c = 'adevconf');
         insert Amazon_Cred;
         
         list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{new AWSKey__c(name = 'aprodconf',
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                       AWS_ENDPOINT_URL__c = 'asd'),
                                                         new AWSKey__c(name = 'adevconf' ,
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                      AWS_ENDPOINT_URL__c = 'asd')
                                                                       };  
        
         insert AWS_KEYs;   
                String FileNmae = 'IFAP/afile';
                list<AmazonRest.S3File> res = AmazonRest.getListFiles(FileNmae,AmazonCredentials.getCredentials('IFAP') );
            boolean resIsFull = res <> null;        
            system.assert(resIsFull,true);
            
            boolean check = AmazonRest.checkFile( FileNmae,AmazonCredentials.getCredentials('IFAP'));
            system.assertEquals(check,false);


            // AmazonRest.getFile(FileNmae,AmazonCredentials.getCredentials('IFAP'));
            AmazonRest.make_sig('',AmazonCredentials.getCredentials('IFAP'));
            AmazonRest.genPublicExpiringAWSLink('', AmazonCredentials.getCredentials('IFAP'), 10 );
            //AmazonRest.copyFile(AmazonCredentials sourceCredentials, String sourceFilename, AmazonCredentials destCredentials, string destFilename)

         }
         
          static testMethod void deleteTest(){
            CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */
        
        
         Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'aprodconf' , Dev_Configuration__c = 'adevconf');
         insert Amazon_Cred;
         
         list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{new AWSKey__c(name = 'aprodconf',
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                       AWS_ENDPOINT_URL__c = 'asd'),
                                                         new AWSKey__c(name = 'adevconf' ,
                                                                      Key__c = 'asd', 
                                                                      Secret__c = 'asd',  
                                                                      IAS_configuration_name__c = 'asdas', 
                                                                      IAS_Access_Point__c = 'asd',
                                                                      Bucket__c = 'asd',
                                                                      AWS_ENDPOINT_URL__c = 'asd')
                                                                       };  
        
         insert AWS_KEYs;   
            
            String FileNmae = 'IFAP/afile'; 
                boolean done = AmazonRest.deleteFile(FileNmae,AmazonCredentials.getCredentials('IFAP') );
          
            system.assert(done,true);
          }

}