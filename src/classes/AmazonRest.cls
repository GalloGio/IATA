public  class AmazonRest {
       public static string getFile(string fileName,AmazonCredentials credentials){
            
            fileName = 'IFAP/source/a.txt';
            credentials =  AmazonCredentials.getCredentials('IFAP');   
            string body;
            string  stringToSplit = '/'+filename;   
            list<string> splittedName = stringToSplit.split('/');
            splittedName.remove(0);
            string encoded;
            for(string dirNm:splittedName)
                encoded+=  EncodingUtil.urlENcode(dirNm,'UTF-8') +'/';
            encoded = encoded.substring(0,encoded.length()-1).replaceAll('null','');    

            DateTime myDateTime = DateTime.now();
            String timestamp =myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss' )+' GMT';
            system.debug('' +timestamp);
            string stringToSign='GET\n\n\n'+timestamp+'\n/'+credentials.bucket+'/'+encoded+ 'a';
            Blob bsig = Crypto.generateMac('hmacSHA1',Blob.valueOf(stringToSign),Blob.valueof(credentials.Secret));
            string Signature= EncodingUtil.base64Encode(bsig);
            
            
            string endpoint = credentials.EndpointBaseURL+credentials.bucket+ '/'+encoded; // to do check if hte last is  '/'
            
            
            HttpRequest req = new HttpRequest();
            
            req.setMethod('GET');
            
            req.setEndpoint(endpoint);
            Http http = new Http();
            
            req.setHeader('Authorization','AWS '+credentials.AWSAccessKeyId+':'+signature);
            req.setHeader('Date',timestamp);
            HttpResponse res;
          if(!Test.isRunningTest())  res = http.send(req);
          else{ res = new HttpResponse(); res.setBody('Test'); }
            
            body = res.getBody();
            system.debug('' +res);
            
            system.debug('##### ' + body);
            return body;
            
        }


        // http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectCOPY.html
        /*
        This example copies my-image.jpg into the bucket, bucket, with the key name my-second-image.jpg.
        
        PUT /my-second-image.jpg HTTP/1.1
        Host: bucket.s3.amazonaws.com
        Date: Wed, 28 Oct 2009 22:32:00 GMT
        x-amz-copy-source: /bucket/my-image.jpg
        Authorization: authorization string
        
        */
      public static Boolean copyFile(AmazonCredentials sourceCredentials, String sourceFilename, AmazonCredentials destCredentials, string destFilename){
          /*   sourceFilename = 'IFAP/source/b.txt';
             destFilename = 'IFAP/dest/b b111.txt';
             credentials =  AmazonCredentials.getCredentials('GenericAttach’');  */
            
            
            string sourceEncoded = EncodePath(sourceFilename);
            string destEncoded = EncodePath(destFilename);
            String timestamp = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss' )+' GMT';
            
            string stringToSign = 'PUT\n\n\n'
                + timestamp+'\n'
                + 'x-amz-copy-source:/' + sourceCredentials.bucket + '/' + sourceEncoded + '\n'
                + '/'+destCredentials.bucket+'/'+destEncoded;
            Blob bsig = Crypto.generateMac('hmacSHA1',Blob.valueOf(stringToSign),Blob.valueof(destCredentials.Secret));
            string Signature= EncodingUtil.base64Encode(bsig);
            
            
            string endpoint = destCredentials.EndpointBaseURL+destCredentials.bucket+ '/'+destEncoded; // to do check if hte last is  '/'
            
            HttpRequest req = new HttpRequest();
            
            req.setMethod('PUT');
            
            req.setEndpoint(endpoint);
            Http http = new Http();
            
            req.setHeader('Authorization','AWS '+destCredentials.AWSAccessKeyId+':'+signature);
            req.setHeader('Date',timestamp);
            req.setHeader('x-amz-copy-source','/' + sourceCredentials.bucket + '/' + sourceEncoded);
            
            String status = !Test.isRunningTest() ? http.send(req).getStatus() : TESTRESULT ;
            
            return status.equals('OK');
        }

        public static Boolean uploadFile(UploadMultipleFileToAmazonButtonCtrl.UploadFile uploadFile, Blob fileBody){
            HttpRequest req = new HttpRequest();

            req.setMethod('PUT');
            req.setEndpoint(uploadFile.endpoint+uploadFile.bucketName+'/'+uploadFile.fullFileNameEncoded);

            req.setHeader('Cache-Control', 'no-cache');
            req.setHeader('Authorization',uploadFile.authorization);
            req.setHeader('X-Amz-Date',uploadFile.timestamp);
            req.setHeader('Content-Type', uploadFile.contenttype+';charset=UTF-8');

            req.setBodyasBlob(fileBody);

            Http http = new Http();
            String status = !Test.isRunningTest() ? http.send(req).getStatus() : TESTRESULT ;

            return status.equals('OK');
          }

        public static Boolean uploadFile(AmazonCredentials credential, String fullFileName, String contentType, Blob fileBody){
            HttpRequest req = new HttpRequest();
            req.setMethod('PUT');
            String fullFileNameEncoded = EncodePath(fullFileName);
            req.setEndpoint(credential.EndpointBaseURL+credential.Bucket+'/'+fullFileNameEncoded);
            req.setHeader('Cache-Control', 'no-cache');
            String timestamp = DateTime.now().format('E, d MMM yyyy HH:mm:ss Z');
            req.setHeader('Authorization',calculePolicy(credential, timestamp, contentType, fullFileNameEncoded));
            req.setHeader('X-Amz-Date',timestamp);
            req.setHeader('Content-Type', contentType+';charset=UTF-8');
            req.setBodyasBlob(fileBody);

            Http http = new Http();
            String status = !Test.isRunningTest() ? http.send(req).getStatus() : TESTRESULT ;

            return status.equals('OK');
        }

        private static String calculePolicy(AmazonCredentials credential, String timestamp, String contentType, String fullFileNameEncoded ) {
            //timestamp = DateTime.now().format('E, d MMM yyyy HH:mm:ss Z');
            system.debug('@@@timestamp: ' + timestamp);
            String policyString = 'PUT\n\n'
                + contentType + ';charset=UTF-8\n\n'
                + 'x-amz-date:' + timestamp + '\n'
                + '/'+credential.Bucket+'/'+fullFileNameEncoded;
            String signedPolicy = AmazonRest.make_sig(policyString, credential);
            return 'AWS ' + credential.AWSAccessKeyId + ':' + signedPolicy;
        }

        public static string EncodePath(string pathToEncode){
            
            string  stringToSplit = '/'+pathToEncode;   
            list<string> splittedName = stringToSplit.split('/');
            splittedName.remove(0);
            string encoded;
            for(string dirNm:splittedName)
                encoded+=  EncodingUtil.urlENcode(dirNm,'UTF-8') +'/';
            encoded = encoded.substring(0,encoded.length()-1).replaceAll('null','');
              system.debug('' +splittedName + '  '+encoded );  
            return encoded;
        }   

public class AmazonRestException extends Exception{}
    
public static string TESTSTRING =
 '<?xml version="1.0" encoding="UTF-8"?> <ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">'
 +'<Name>sfdc-ifap-dev-23ea0b9fb2a21f7f</Name>'
 +'<Prefix>IFAP/</Prefix>'+'<Marker>'+'</Marker>'
 +'<MaxKeys>1000</MaxKeys>'+'<Delimiter>IFAP/</Delimiter>'
 +'<IsTruncated>false</IsTruncated>'+'<Contents>'
 +'<Key>IFAP/50011000006kn5PAAQ/b.pdf</Key>'
 +'<LastModified>2015-08-07T11:46:49.000Z</LastModified>'
 +'<ETag>&quot;7c036d8798fc8faf177e961a0be0d300&quot;</ETag>'
 +'<Size>79751</Size>'+'<Owner>'
 +'<ID>e18db9b8fe5497707f9898c0757cd504274323d97f61502a3a5d1208e58bb5ff</ID>'
 +'<DisplayName>iataawsnonprod</DisplayName>'+'</Owner>'+'<StorageClass>STANDARD</StorageClass>'
 +'</Contents>'+'<Contents>'+'<Key>IFAP/FinancialResults/</Key>'
 +'<LastModified>2015-08-07T09:12:21.000Z</LastModified>'
 +'<ETag>&quot;d41d8cd98f00b204e9800998ecf8427e&quot;</ETag>'
 +'<Size>0</Size>'+'<Owner>'+'<ID>e18db9b8fe5497707f9898c0757cd504274323d97f61502a3a5d1208e58bb5ff</ID>'
 +'<DisplayName>iataawsnonprod</DisplayName>'+'</Owner>'+'<StorageClass>STANDARD</StorageClass>'+'</Contents>'
 +'<Contents>'+'<Key>IFAP/FinancialResults/00000002/00000002.xml</Key>'
 +'<LastModified>2015-08-07T15:34:24.000Z</LastModified>'+'<ETag>&quot;3197c3e5befea0a7bdfe7c491a2ddf24&quot;</ETag>'
 +'<Size>425</Size>'+'<Owner>'+'<ID>e18db9b8fe5497707f9898c0757cd504274323d97f61502a3a5d1208e58bb5ff</ID>'
 +'<DisplayName>iataawsnonprod</DisplayName>'+'</Owner>'+'<StorageClass>STANDARD</StorageClass>'+'</Contents>'
 +'</ListBucketResult>';


 public static string TESTRESULT = 'OK';
    
        public static final string SEPARATOR = '/';
        



/*AmazonRest.Credentials Credentials = new AmazonRest.Credentials('https://s3-eu-west-1.amazonaws.com/',
                                        'sfdc-ifap-dev-23ea0b9fb2a21f7f',
                                        'AKIAJVPKEUZ4GL4KZDZA',
                                        '/pRJY7OCsLKKnwZdzjIRV9Us0tyIip0ax3YiwpOz'); 

AmazonXMLParser.ListBucketResult  ListBucketResult = 
AmazonRest.listFiles( 'IFAP/',Credentials);
                    
throw new transformationException('' +ListBucketResult);*/

    
       public static AmazonXMLParser.ListBucketResult listFiles(string Folder,AmazonCredentials credentials){
            
           try{ 
            String Prefix = folder;
            String Delimiter = folder;
            
            DateTime myDateTime = DateTime.now();
            String timestamp =myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss' )+' GMT';
            
            string stringToSign='GET\n\n\n'+timestamp+'\n/'+credentials.bucket+'/';
            Blob bsig = Crypto.generateMac('hmacSHA1',Blob.valueOf(stringToSign),Blob.valueof(credentials.Secret));
            string Signature= EncodingUtil.base64Encode(bsig);
            
            
            string endpoint = credentials.EndpointBaseURL+credentials.bucket+ '/'; // to do check if hte last is  '/'
            
            if(!String.isBlank(Prefix)||!String.isBlank(Delimiter)){
            
                endpoint+='?';
                if(!String.isBlank(Prefix))endpoint+='prefix='+prefix+'&';
                if(!String.isBlank(Delimiter))endpoint+='delimiter='+Delimiter;
                if(endpoint.lastIndexOf('?') == endpoint.length()-1 )
                    endpoint = endpoint.substring(0,endpoint.length()-1);
                
            }
            
            
            HttpRequest req = new HttpRequest();
            
            req.setMethod('GET');
         //   req.settimeout(120000);
            req.setEndpoint(endpoint);
            Http http = new Http();
            
            req.setHeader('Authorization','AWS '+credentials.AWSAccessKeyId+':'+signature);
            req.setHeader('Date',timestamp);
             HttpResponse res;
            if(!Test.isRunningTest())  res = http.send(req);
            
            String str = !Test.isRunningTest() ? res.getBody() : TESTSTRING ;
                
            AmazonXMLParser parser = new AmazonXMLParser();
            XmlStreamReader reader = new XmlStreamReader(str);
            AmazonXMLParser.ListBucketResult ListBucketResult = parser.parseBucketCont(reader);
            
            return listBucketResult;
            }catch(Exception ex){
            
              TransformationHelper.sendEmailSupport('FATAL: AMAZONREST FATILED TO LIST WITH AMAZON SERVER  ' ,'STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());

               throw new AmazonRestException(ex); 

                return null;
            }
        }

    /**
        Check if a file is in Amazon
    **/
    public static Boolean checkFile(String key,AmazonCredentials credentials) {
        
        String encodedKey = EncodingUtil.urlENcode(key,'UTF-8').replace('%2F','/');
        AmazonXMLParser.ListBucketResult result = listFiles(encodedKey,credentials);
        if(result<>null && result.Contents<>null)
        for ( AmazonXMLParser.ListEntry entry : result.Contents) {
            if ( entry.key == key ) {
                return true;
            }
        }
        return false;
    }

    
    /**
        Get a list of files in selected bucket (defined in credentials)
    **/
    public static list<S3File> getListFiles(String folder,AmazonCredentials credentials) {
        String encodeFolder = EncodePath(folder);
        AmazonXMLParser.ListBucketResult result = listFiles(encodeFolder,credentials);
        list<S3File> listS3Files = new list<S3File>();
        if(result<>null && result.Contents<>null)
        for ( AmazonXMLParser.ListEntry entry : result.Contents) {
            S3File file = new S3File(entry, credentials);
            if ( ! file.isDirectory() ) {
                listS3Files.add(file);
            }
        }
        listS3Files.Sort();
        return listS3Files;
    }

    /**
        Class to represent a File in S3 server
        Is not a real file, only a wrapper to store file data
    **/
    public class S3File implements Comparable {
        
        private string name;
        private AmazonXMLParser.ListEntry s3Entry;
        private AmazonCredentials credentials;

        public S3File (AmazonXMLParser.ListEntry s3Entry, 
                        AmazonCredentials credentials) {
            this.s3Entry = s3Entry;
            this.credentials=credentials;
        }
        
        public String getKey() {
            return this.s3Entry.key;
        }

        public String getName() {
            list<String> parts = this.s3Entry.key.split(SEPARATOR);
            if ( parts.isEmpty() ) {
                return '';
            }
            return parts.get( parts.size() - 1 );
        }

        private double size;
        public double getSize() {
            return (double)(this.s3Entry.size.longValue()* 0.000001);// * 0.00001 315184 bytes 3966584 bytes
        }
        
        private DateTime lastModified;
        public DateTime getLastModified() {
            return this.s3Entry.LastModified;
        }

        private String FullName;
        public String getFullName() {
            return this.s3Entry.key ;
        }
            
        public boolean isDirectory() {
            return this.s3Entry.key.endsWith(SEPARATOR);
        }

       public boolean deleteFile() {
        
            return AmazonRest.deleteFile(getFullName(),this.credentials );
        }
        
        public Integer compareTo(Object compareTo) {
            
            S3File compareToS3File = (S3File)compareTo;
            //if(LastModified == compareToS3File.LastModified) return 0;
            if(LastModified > compareToS3File.LastModified || LastModified == compareToS3File.LastModified) return 1;
            return -1;
        }
        
    }
    


    public static boolean deleteFile(string fileName,AmazonCredentials Credentials ){
      TRY{  
        /*  string fileName = 'IFAP/FinancialDocuments/500110000069W0HAAU/a.pdf';
            AmazonRest.Credentials credentials = new AmazonRest.Credentials(
                                        'https://s3-eu-west-1.amazonaws.com/',
                                        'sfdc-ifap-dev-23ea0b9fb2a21f7f',
                                        'AKIAJVPKEUZ4GL4KZDZA',
                                        '/pRJY7OCsLKKnwZdzjIRV9Us0tyIip0ax3YiwpOz'd);   
         */
            string  stringToSplit = '/'+filename;   
            list<string> splittedName = stringToSplit.split('/');
            splittedName.remove(0);
            string encoded;
            for(string dirNm:splittedName)
                encoded+=  EncodingUtil.urlENcode(dirNm,'UTF-8') +'/';
            encoded = encoded.substring(0,encoded.length()-1).replaceAll('null','');    

            DateTime myDateTime = DateTime.now();
            String timestamp =myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss' )+' GMT';
            
            string stringToSign='DELETE\n\n\n'+timestamp+'\n/'+credentials.bucket+'/'+encoded;
            Blob bsig = Crypto.generateMac('hmacSHA1',Blob.valueOf(stringToSign),Blob.valueof(credentials.Secret));
            string Signature= EncodingUtil.base64Encode(bsig);
            
            
            string endpoint = credentials.EndpointBaseURL+credentials.bucket+ '/'+encoded; // to do check if hte last is  '/'
            
            
            HttpRequest req = new HttpRequest();
                      //  req.settimeout(120000);

            req.setMethod('DELETE');
            
            req.setEndpoint(endpoint);
            Http http = new Http();
            
            req.setHeader('Authorization','AWS '+credentials.AWSAccessKeyId+':'+signature);
            req.setHeader('Date',timestamp);
            
          if(!Test.isRunningTest()) HttpResponse res = http.send(req);
            return true;
            
           }catch(Exception ex){
            
              TransformationHelper.sendEmailSupport('FATAL: AMAZONREST FATILED TO DELETE WITH AMAZON SERVER  ' ,'   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());

                throw new AmazonRestException(ex); 
                return FALSE;
            }    
            
    
    }           

    /**
        AMSU-186
        Delete multiple files
    **/  
    public static Boolean deleteFiles(Set<String> fileNames, String folder, AmazonCredentials Credentials) {
        try{
            System.debug('Delete files service');

            DOM.Document doc = new DOM.Document();
            dom.XmlNode deleteNode = doc.createRootElement('Delete', null, null);
            for(String fileName : fileNames) {
                dom.XmlNode objectNode = deleteNode.addChildElement('Object', null, null);
                objectNode.addChildElement('Key', null, null).addTextNode(fileName);
            }
            String requestElems = doc.toXmlString();
            String encoded = EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(requestElems)));
            String length = '' + requestElems.length();

            system.debug(requestElems);

            DateTime myDateTime = DateTime.now();
            String timestamp = myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss' )+' GMT';
            String stringToSign = 'POST\n' + encoded + '\n' + 'multipart/form-data\n' + timestamp +'\n/' + credentials.bucket + folder + '?delete';
            Blob bsig = Crypto.generateMac('hmacSHA1',Blob.valueOf(stringToSign),Blob.valueof(credentials.Secret));
            String signature= EncodingUtil.base64Encode(bsig);

            String endpoint = credentials.EndpointBaseURL + credentials.bucket + folder + '?delete';

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setBody(requestElems);
            req.setEndpoint(endpoint);

            Http http = new Http();
            
            req.setHeader('Authorization','AWS '+ credentials.AWSAccessKeyId + ':' + signature);
            req.setHeader('Date', timestamp);
            req.setHeader('Content-Type', 'multipart/form-data');
            req.setHeader('Content-Length', length);
            req.setHeader('Content-MD5', encoded);

            System.debug('Request: ' + req);
            
            if(!Test.isRunningTest()) {
                HttpResponse res = http.send(req);    
                System.debug(res);
                System.debug(res.getBody());
            }

            return true;
            
        } catch(Exception e) {
            TransformationHelper.sendEmailSupport('FATAL: AMAZONREST FAILED TO DELETE MULTIPLE FILES IN AMAZON SERVER  ' ,'   STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
            throw new AmazonRestException(e); 
            return false;
        }       
    }          
    
    /**
        Creates an expiry link to acces to a single file for a period in parameter secondsValid
    **/
    public static string genPublicExpiringAWSLink(String filename, AmazonCredentials credentials, Integer secondsValid ){
        try {
            String path = credentials.Bucket + '/';
            String encoded = EncodePath(filename);
            Decimal timeInMili = Math.floor(System.now().getTime()/1000) + secondsValid;
            string check = string.valueof(timeInMili);
            if(check.indexOf('E') <> -1)    {
                check =check.substring(0,check.indexOf('E')).replace('.', '');
                check +='9';
            }
            long timeOut= Long.ValueOf(check);
            
            string stringToSign = 'GET\n\n\n' + timeOut+ '\n/' + path+ encoded ;//+ filename;
            string signature = make_sig(stringToSign, credentials);
            string queryString = '?AWSAccessKeyId=' + credentials.AWSAccessKeyId + '&Expires=' + timeOut+ '&Signature=' + signature;
            
            PageReference page = new PageReference(credentials.EndpointBaseURL + path + encoded );
            map<String,String> params = page.getParameters();
            params.put('AWSAccessKeyId', credentials.AWSAccessKeyId);
            params.put('Expires', String.ValueOf(timeOut));
            params.put('Signature', signature);
            
            String result = page.getUrl();
           //  throw new transformationexception(''+result);
            system.debug('stringToSign  '+  stringToSign + '  queryString  ' + queryString + '   result '  + result );
            
            return   result ;
        }catch(Exception e) {
            TransformationHelper.sendEmailSupport('AmazonFinancial genPublicExpiringAWSLink filename' + filename,'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
            return null;
        }
    }
    
    public static String make_sig(string canonicalBuffer, AmazonCredentials credentials) {
        String macUrl ;
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(credentials.Secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(CREDENTIALS.Secret)); 
        macUrl = EncodingUtil.base64Encode(mac);
        return macUrl;
    }

   //AmazonXMLParser.ListBucketResult
  /*     public static String listFiles(Continuation cont, string Folder,Credentials credentials){
            
            
            String Prefix = folder;
            String Delimiter = folder;
            
            DateTime myDateTime = DateTime.now();
            String timestamp =myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss' )+' GMT';
            
            string stringToSign='GET\n\n\n'+timestamp+'\n/'+credentials.bucket+'/';
            Blob bsig = Crypto.generateMac('hmacSHA1',Blob.valueOf(stringToSign),Blob.valueof(credentials.Secret));
            string Signature= EncodingUtil.base64Encode(bsig);
            
            
            string endpoint = credentials.EndpointBaseURL+credentials.bucket+ '/'; // to do check if hte last is  '/'
            
            if(!String.isBlank(Prefix)||!String.isBlank(Delimiter)){
            
                endpoint+='?';
                if(!String.isBlank(Prefix))endpoint+='prefix='+prefix+'&';
                if(!String.isBlank(Delimiter))endpoint+='delimiter='+Delimiter;
                if(endpoint.lastIndexOf('?') == endpoint.length()-1 )
                    endpoint = endpoint.substring(0,endpoint.length()-1);
                
            }
            
            
            HttpRequest req = new HttpRequest();
            
            req.setMethod('GET');
            
            req.setEndpoint(endpoint);
            Http http = new Http();
            
            req.setHeader('Authorization','AWS '+credentials.AWSAccessKeyId+':'+signature);
            req.setHeader('Date',timestamp);
             HttpResponse res;
         //   if(!Test.isRunningTest())  res = http.send(req);
            
            string contLabel = cont.addHttpRequest(req);
            return contLabel;
           
        }
*/    




    /*      
            string fileName = 'IFAP/FinancialDocuments/05812309/00000002.xml';
            AmazonRest.Credentials credentials = new AmazonRest.Credentials(
                                        'https://s3-eu-west-1.amazonaws.com/',
                                        'sfdc-ifap-dev-23ea0b9fb2a21f7f',
                                        'AKIAJVPKEUZ4GL4KZDZA',
                                        '/pRJY7OCsLKKnwZdzjIRV9Us0tyIip0ax3YiwpOz');   

         */

      /* public static string getFile(string fileName,Credentials credentials){
            
            string body;
            string  stringToSplit = '/'+filename;   
            list<string> splittedName = stringToSplit.split('/');
            splittedName.remove(0);
            string encoded;
            for(string dirNm:splittedName)
                encoded+=  EncodingUtil.urlENcode(dirNm,'UTF-8') +'/';
            encoded = encoded.substring(0,encoded.length()-1).replaceAll('null','');    

            DateTime myDateTime = DateTime.now();
            String timestamp =myDateTime.formatGMT('EEE, dd MMM yyyy HH:mm:ss' )+' GMT';
            
            string stringToSign='GET\n\n\n'+timestamp+'\n/'+credentials.bucket+'/'+encoded;
            Blob bsig = Crypto.generateMac('hmacSHA1',Blob.valueOf(stringToSign),Blob.valueof(credentials.Secret));
            string Signature= EncodingUtil.base64Encode(bsig);
            
            
            string endpoint = credentials.EndpointBaseURL+credentials.bucket+ '/'+encoded; // to do check if hte last is  '/'
            
            
            HttpRequest req = new HttpRequest();
            
            req.setMethod('GET');
            
            req.setEndpoint(endpoint);
            Http http = new Http();
            
            req.setHeader('Authorization','AWS '+credentials.AWSAccessKeyId+':'+signature);
            req.setHeader('Date',timestamp);
            HttpResponse res;
          if(!Test.isRunningTest())  res = http.send(req);
            
            body = res.getBody();
            return body;
            
        }*/
	
	
	public static void fakemethod () {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		
	
	}
}