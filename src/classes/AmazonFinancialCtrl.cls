global class AmazonFinancialCtrl {

  public boolean techinicalProb {get; set;}

  public boolean hasMess {get{return Apexpages.hasMessages();} private set;}
  public boolean renderLast2Columns {get; private set;}

  public static final Integer FILE_SIZE_LIMIT_MB = 20;
  public static final Integer FILE_SIZE_LIMIT_BYTES = FILE_SIZE_LIMIT_MB * 1024 * 1024;
  private static final string FOLDER = 'IFAP/FinancialDocuments/';

  public List<ENZ__FTPAttachment__c> docs {get; private set;} /// this just for the legacy documents on the drive in the YMQ


  private static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME);
  public string AMAZONURL {get; private set;}



  public boolean canUploadAndDelete {
    get {
      if (cse == null || cse.id == null) return true;
      Case thiscse = [Select id, Status from Case where id = :cse.id];
      return (thiscse.Status.equals('Agent Notified (Mail)') ||
      thiscse.Status.equals('Agent Notified (Email)') ||
	  thiscse.Status.equals('Action Needed') ||
      thiscse.Status.equals('Sanity Check Failure'));
    }
    set;
  }


  public boolean hasMessage {get{return (ApexPages.hasmessages());} private set;}
  @TestVisible
  public IfapToolManager.Response response {get; private set;}
  public string fileNameFromPage {get; set;}
  public static final String SEPARATOR = '/';
  public final boolean PORTALUSER = UserInfo.getUserType() <> 'PowerPartner' ?  false : true;
  public boolean Archived {get; private set;}
  public Id id {get; set;}
  public list<AmazonFile> listFile {get; set;}
  public double totalSize {get{if (listfile == null || listfile.size() == 0) return 0;
                               double retVal = 0;
  for (AmazonFile s3f : listfile ) {
    retVal += s3f.getSize();
    }
  return retval;
                              }
  private set;
                          }
  public boolean submit {get{ return (totalSize < 20);} private set;}
  public UploadFile file {get; set;}
  public String filenameupload {get; set;}
  public String filetypeupload {get; set;}
  public string message {get; private set;}

  private  AsyncWSToolmasterIfap.mergeAndSubmitParametersResponse_elementFuture futureElement {get; set;}
  private String caseFolder;
  public Case cse {get; private set;}
  private Account acc {get; set;}
    
  public AmazonFinancialCtrl(ISSP_IFAPCases controller) {
    //Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=EmulateIE9');
    try {
      techinicalProb = false;
      this.id = ApexPages.currentPage().getParameters().get('id');
      AMAZONURL  =
        AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME).EndpointBaseURL
        +  AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME).Bucket;
      List<Case> cases = controller.getIFAPCasesOnly();
      this.id = cases  <> null && cases.size()  > 0 ? cases[0].id : null;
      if (this.id<> null) { // throw new transformationException('Empty constructor not allowed!');


        this.cse = [Select id, Status, CaseNumber, ArchivedDate__c, account.type,
                    account.IATA_ISO_Country__r.iso_code__c , account.Country_ISO_Code__c,
                    IFAP_Agent_Code__c, AccountId , Financial_Review_Type__c, IsComplaint__c
                    from Case where id = : this.id];

        this.Archived = cse.ArchivedDate__c <> null;
        if (Archived) {


          docs = [Select id, Name from ENZ__FTPAttachment__c where Case__c  = :cse.id];

        } else {

          this.casefolder = FOLDER + cse.CaseNumber;
          //  if(cse.IFAP_Agent_Code__c == null || cse.IFAP_Agent_Code__c.length() < 7  )
          //      throw new transformationException(' Please check the Agent\'s Code ');

          this.refreshListDoc();
          this.acc = [select Id , Country_ISO_Code__c, Type from Account where Id  = :cse.AccountId];

          this.message = initMessage(cse);

        }
      }
    } catch (AmazonRest.AmazonRestException ex) {
      techinicalProb = true;
      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Technical problem: we are fixing it, please try again later'));

      TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal AmazonRestException ' , '   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
    } catch (Exception ex) {
      techinicalProb = true;
      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Technical problem: we are fixing it, please try again later'));

      TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal  ' , '   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());

      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage()));


    }
  }
    
    
  public AmazonFinancialCtrl(ISSP_Case controller) {
    //Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=EmulateIE9');
    try {
      techinicalProb = false;
      this.id = ApexPages.currentPage().getParameters().get('caseId');
      AMAZONURL  =
        AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME).EndpointBaseURL
        +  AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME).Bucket;
      this.cse = DAL_ISSP.getCase(this.id);
      
      if (this.cse<> null) { // throw new transformationException('Empty constructor not allowed!');

        this.Archived = cse.ArchivedDate__c <> null;
        if (Archived) {


          docs = [Select id, Name from ENZ__FTPAttachment__c where Case__c  = :cse.id];

        } else {

          this.casefolder = FOLDER + cse.CaseNumber;
          //  if(cse.IFAP_Agent_Code__c == null || cse.IFAP_Agent_Code__c.length() < 7  )
          //      throw new transformationException(' Please check the Agent\'s Code ');

          this.refreshListDoc();
          this.acc = [select Id , Country_ISO_Code__c, Type from Account where Id  = :cse.AccountId];

          this.message = initMessage(cse);

        }
      }
    } catch (AmazonRest.AmazonRestException ex) {
      techinicalProb = true;
      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Technical problem: we are fixing it, please try again later'));

      TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal AmazonRestException ' , '   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
    } catch (Exception ex) {
      techinicalProb = true;
      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Technical problem: we are fixing it, please try again later'));

      TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal  ' , '   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());

      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage()));


    }
  }  

  public AmazonFinancialCtrl( ApexPages.StandardController controller) {
    try {

      techinicalProb = false;

      //Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=EmulateIE9');
      this.id = controller.getId();
      this.renderLast2Columns = false;
      if (this.id<> null) { //throw new transformationException('Empty constructor not allowed!');
        AMAZONURL  =
          AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME).EndpointBaseURL
          +  AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME).Bucket;

        this.cse = [Select id, Status, CaseNumber, ArchivedDate__c, account.type,
                    account.IATA_ISO_Country__r.iso_code__c , account.Country_ISO_Code__c,
                    IFAP_Agent_Code__c, AccountId , Financial_Review_Type__c, IsComplaint__c
                    from Case where id = : this.id];

        this.Archived = cse.ArchivedDate__c <> null;
        if (Archived) {


          docs = [Select id, Name from ENZ__FTPAttachment__c where Case__c  = :cse.id];

        } else {

          this.casefolder = FOLDER + cse.CaseNumber;
          // if(cse.IFAP_Agent_Code__c == null || cse.IFAP_Agent_Code__c.length() < 7  )
          //  throw new transformationException(' Please check the Agent\'s Code ');

          this.refreshListDoc();
          this.acc = [select Id , Country_ISO_Code__c, Type from Account where Id  = :cse.AccountId];

          this.message = initMessage(cse);

        }
      }



    } catch (AmazonRest.AmazonRestException ex) {
      techinicalProb = true;
      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Technical problem: we are fixing it, please try again later'));

      TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal AmazonRestException ' , '   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
    } catch (Exception ex) {
      techinicalProb = true;
      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Technical problem: we are fixing it, please try again later'));

      TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal  ' , '   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());

      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage()));


    }

  }





  public class AmazonFinancialException extends Exception {}

  public oBject processResponse() {
    try {
      // know issue https://success.salesforce.com/issues_view?id=a1p30000000sXyr     we set the response in the test class
      response = !Test.isRunningTest() ? New IfapToolManager.Response(futureElement.getValue())
                 : response ;
      if (!response .success) {
        string errorMessage = response.message
                              .replace(']', '')
                              .replace('[', '')
                              .replace(caseFolder + '/', '')
                              .replace('is protected, cannot be merged', System.label.IfapPassordFile); //'is password protected and cannot be processed, please remove the protection and submit it again'
        if (response.message.contains('exceeds maximum size allowed'))  errorMessage  = System.label.IfapMaxSizeYouAre //'The overall maximum size of the files is 20 MB. The sum of the files you are submitting is   '
              + (double)(Math.round((totalSize + 0.00001) * 100) / 100) + ' MB ';
        throw new transformationException(errorMessage);

      }
      throw new AmazonFinancialException();

    } catch (AmazonFinancialException e) {

      try {
        system.debug('aqui old way...');
      case check = [Select id, status FROM Case where Id =: cse.id limit 1];
        if (check.status <> 'Submitted') {
          TransformationHelper.NoStatusValidation = true;
          cse.status = 'Submitted';
          update cse;
          TransformationHelper.NoStatusValidation = false;

          AmazonFinancialCtrl.createAmazonFileObject(FOLDER + cse.caseNumber + '/' + mergedFileName , (long) ((totalSize + 0.00001) * 100 / 100), string.valueOf(cse.id) );

          //remove files which are inside the merged file
          for ( AmazonFile amazonFile : this.listFile ) {
            amazonFile.deleteAmazonFile();
          }
        }
      } catch (Exception ex) {

        TransformationHelper.sendEmailSupport('FATAL: AmazonFinancial processResponse update the case INCOSISTENCY ' + cse.id, 'STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());

      }

    } catch (TransformationException e) {

      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, e.getMessage()));

    } catch (Exception e) {

      apexpages.addmessage(new apexpages.message(apexpages.severity.Error, e.getMessage()));
      TransformationHelper.sendEmailSupport('AmazonFinancial processResponse ' + cse.id, 'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
    }
    return null;
  }


  public string mergedFileName ;

  public continuation mergeFilesAndSubmitParams() {
    try {
      if (ApexPages.getMessages()<> null && ApexPages.getMessages().size() > 0) ApexPages.getMessages().clear();
      mergedFileName = mergedFileName(Cse, listFile );

      IfapXmlGenerator.FinancialDocument fd = new IfapXmlGenerator.FinancialDocument(
        new IfapXmlGenerator.Casexml(cse.CaseNumber),
        new IfapXmlGenerator.FileXml(mergedFileName),
        new IfapXmlGenerator.ReviewType(cse.Financial_Review_Type__c ),
        new IfapXmlGenerator.SubmittedDate(Date.Today())
      );

      Continuation cont = new Continuation(120);
      Cont.continuationMethod = 'processResponse';
      if (!test.isRunningTest()) futureElement = IfapToolManager.startMergeAllPDFForCase(cont, cse.CaseNumber,  mergedFileName, fd.getXML() );
      // know issue https://success.salesforce.com/issues_view?id=a1p30000000sXyr

      return cont;
    } catch (Exception e) {

      apexpages.addmessage(new apexpages.message(apexpages.severity.error, 'Error during the submission of the documents: please REFRESH the page'));
      TransformationHelper.sendEmailSupport('AmazonFinancial merge ' + cse.id , 'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
      return null;

    }

  }

  private static string validateName(string filenameupload) {
    string toExamine = filenameupload;
    toExamine = toExamine.toLowerCase().replace('.pdf', '');
    string returnS = '';
    String SPECIAL_CHAR_PATTERN = '[\\[\\]\\^\\$\\.\\|\\?\\*\\+\\\\~`\\!@#%&+={}()<>:;,\']';

    Pattern p = Pattern.compile(SPECIAL_CHAR_PATTERN);
    Matcher pm = p.matcher(toExamine);
    while (pm.find()) {
      returnS += pm.group() + ' ';
    }

    if (returnS.contains('\'')) returnS = 'apostrophe';

    return returnS;
  }

  /*Initialize the message on the popup when submit */
  private string initMessage(Case cse) {

    string jdocs;
    list<StaticResource> bodies = [select name, body from StaticResource where name = 'IFAPmessages'];
    if (bodies<> null && bodies.size() > 0)
      jdocs = bodies[0].body.toString();

    List<IfapMessage> desFile =  (List<IfapMessage>)JSON.deserialize(jdocs , List<IfapMessage>.class);
    string messageHere =  this.messageDocumentsFromJson(desFile, cse);

    messageHere = messageHere <> null ?  messageHere.replace('\'', '\\\'').replace(';', '\\r') : '';

    return messageHere;

  }



  /* THIS METHOD TO BE USED TO GIVE A NAME TO THE MERGED FILE*/
private static String mergedFileName(case Cse, list<AmazonFile> listFile) {

    string name = '';

    string firstPart =  Cse.account.Country_ISO_Code__c + '-' + (Cse.account.Type == 'IATA Cargo Agent' || Cse.account.type == 'CASS Associate' ? 'C' : 'P');

    firstPart += cse.Financial_Review_Type__c <> 'New applications'
                 ?
                 '-' + cse.IFAP_Agent_Code__c.substring(0, 7)
                 :
                 '-NA' + cse.casenumber.right(5)
                 ;

    list<string> containgTheName = new list<string>();
    for (AmazonFile  file : listFile) {
      string nm = file.getname();
      if (nm.contains(firstPart)) {
        containgTheName.add(nm);
      }
    }

    integer numericPostfix = containgTheName<>null && containgTheName.size() > 0 ? parseTheIntegerForName(containgTheName) : 1;
    name = firstPart + '-' +  string.valueOf(numericPostfix) + '.pdf';
    return name;
  }

  @TestVisible
  private static integer parseTheIntegerForName(list<string> names) {
    integer tmp = 1;
    for (string name : names) {
      name = name.toLowerCase().replace('.pdf', '');
      name = name.substring(name.lastIndexOf('-') + 1, name.length());
      try {
        tmp = name.isnumeric() ?
              integer.valueOf(name) >= tmp ? integer.valueOf(name) + 1 : tmp
              : tmp;
      }
      catch(Exception e)
      {
        tmp = 1;
        return tmp;
      }
    }
    return tmp;
  }

  public Pagereference refreshListDoc() {
    map<String, AmazonFile__c> mapAmazonFiles = getMapAmazonFile();
    this.renderLast2Columns = true;
    list<AmazonRest.S3File> dirtyList = AmazonRest.getListFiles(this.caseFolder, CREDENTIALS);
    // throw new transformationException(''+dirtyList);
    this.listFile = new list<AmazonFile>();
    for (AmazonRest.S3File s3File : dirtyList ) {
      String name = s3File.getname();
      if ( name.endsWithIgnoreCase('.pdf') ) {
        AmazonFile__c amazonFile = mapAmazonFiles.get(s3File.getFullName());
        AmazonFile local = new AmazonFile( s3File, amazonFile);
        listFile.add( local );
        renderLast2Columns  =  local.getCreatedBy() == null ? false : renderLast2Columns;
      }
    }
    return null;
  }

  /**
      Return a AmazonFile__c map with key = amazon key
  **/
  private map<String, AmazonFile__c> getMapAmazonFile() {
    list<AmazonFile__c> listAmazonFile = [
                                           Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c
                                           From AmazonFile__c
                                           Where Case__c = :this.cse.Id
                                         ];

    map<String, AmazonFile__c> mapAmazonFile = new map<String, AmazonFile__c>();
    for ( AmazonFile__c amazonFile : listAmazonFile) {
      mapAmazonFile.put(amazonFile.Full_Name_Unique__c, amazonFile);
    }
    return mapAmazonFile;
  }

  /*to refrehs all the page */
  public pageReference RefreshAll() {
    this.refreshListDoc();
    return null;
  }

  public void sendFileInfo() {
    file = new UploadFile(id, filenameupload, cse.caseNumber, filetypeupload);
  }



  @RemoteAction
  global static UploadFile createUploadFile(String id, String filenameupload, String contentType, Long filesize) {

  case   cse  = [Select id, CaseNumber
                     from Case where id = :id];
    list<AmazonRest.S3File>listFileLoc = AmazonRest.getListFiles(FOLDER + cse.caseNumber, CREDENTIALS);

    UploadFile upF = new UploadFile(id, filenameupload, cse.caseNumber, contentType);


    if (!fileNameUpload.containsIgnoreCase('.pdf')) {

      upf.isSuccess = false;
      upf.errorMessage =  System.label.IfapNotPdf;
      return upf;


    }

    if (validateName(filenameupload) <> null &&  validateName(filenameupload) <> '') {
      upf.isSuccess = false;
      upf.errorMessage =  'File name not accepted special characters not allowed: ' + validateName(filenameupload) +  ' Please rename the file ' ;
      return upf;
    }

    if ( ! validateFileSize( filesize)) {
      upf.isSuccess = false;
      upf.errorMessage = System.label.IFAPFiletooLarge; // 'You cannot upload this file, its size is ' + (filesize/1024/1024) + ' MB and the limit is ' + FILE_SIZE_LIMIT_MB +  ' MB' ;
      return upf;
    }

    if ( ! validateTotalSize( listFileLoc, filesize) ) {
      upf.isSuccess = false;
      upf.errorMessage =   System.label.IfapMaxSizeYouAre  + FILE_SIZE_LIMIT_MB + ' MB '; //'You cannot upload this file, total file size limit of ' + FILE_SIZE_LIMIT_MB + ' MB has been exceeded';
      return upf;
    }

    for (AmazonRest.S3File  file : listFileLoc ) {
      if (file.getname().equalsIgnoreCase(filenameupload)) {
        upf.isSuccess = false;
        upf.errorMessage =  'File already existing';
        return upf;
      }
    }
    upf.isSuccess = true;
    return upF ;
  }

  /**
      Check if the file size is lower than limit size
  **/
  private static Boolean validateFileSize( Long filesize) {
    return filesize < FILE_SIZE_LIMIT_BYTES;

  }

  /**
      Check if all file in the case combined are lower than limit size
  **/
  private static Boolean validateTotalSize( list<AmazonRest.S3File> listS3File, Long filesize) {
    double totalSizeInMB = filesize * 0.000001;
    for ( AmazonRest.S3File s3File : listS3File) {
      if (s3File.getName().endsWithIgnoreCase('.pdf')) {
        totalSizeInMB += s3File.getSize();
      }
    }
    return totalSizeInMB < FILE_SIZE_LIMIT_MB;
  }

private string messageDocumentsFromJson(List<IfapMessage> desFile, case c) {

    string returnMessage;
    if (c.account == null || c.account.type == null
        ||  c.account.IATA_ISO_Country__c == null
        ||  c.account.IATA_ISO_Country__r.iso_code__c == null)
      return null;

    for (IfapMessage mess : desFile) {
      if ( mess.AgentType == C.ACCOUNT.TYPE && mess.ISOCountryCodes == C.account.IATA_ISO_Country__r.iso_code__c) {
        returnMessage = mess.Documents;
        break;
      }
    }

    return returnMessage;

  }


  @RemoteAction
  global static boolean deleteFile(String id, String filenamedelete) {

  case   cse  = [Select id, CaseNumber
                     from Case where id = :id];
    list<AmazonRest.S3File>listFileLoc = AmazonRest.getListFiles(FOLDER + cse.caseNumber, CREDENTIALS);

    for (AmazonRest.S3File  file : listFileLoc ) {
      if (file.getname().equalsIgnoreCase(filenamedelete)) {
        file.deleteFile();
        return true;
      }
    }
    return false;
  }


  @RemoteAction
  global static boolean checkIfFileWasUploaded( String key ) {
    return AmazonRest.checkFile(key, CREDENTIALS);
  }

  @remoteAction
  global static boolean createAmazonFileObject(string amazonKey, Long filesize, String caseId ) {

    list<String> parts = amazonKey.split(SEPARATOR);
    String filename = parts.isEmpty() ? '' : parts.get( parts.size() - 1 );

    try {
      AmazonFile__c amazonFile = new AmazonFile__c(
        Name = filename,
        Full_Name_Unique__c = amazonKey,
        Size_MB__c = filesize * 0.000001, //convert to MB
        Case__c = caseId
      );
      insert amazonFile;
      return true;
    } catch ( Exception e) {
      System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
      return false;
    }
  }


  @remoteAction
  global static string getExpiringLinkIfap(string fileName ) {

    return  genPublicExpiringAWSLinkIFAP( CREDENTIALS.Bucket + SEPARATOR , fileName);
  }


  private static string genPublicExpiringAWSLinkIFAP(string path, string filename) {
    try {
      string  stringToSplit = '/' + filename;
      list<string> splittedName = stringToSplit.split('/');
      splittedName.remove(0);
      string encoded;
      for (string dirNm : splittedName)
        encoded +=  EncodingUtil.urlENcode(dirNm, 'UTF-8') + '/';
      encoded = encoded.substring(0, encoded.length() - 1).replaceAll('null', '');

      Decimal timeInMili = Math.floor(System.now().getTime() / 1000) + 300;
      string check = string.valueof(timeInMili);
      if (check.indexOf('E') <> -1)    {
        check = check.substring(0, check.indexOf('E')).replace('.', '');
        check += '9';
      }
      long timeOut = Long.ValueOf(check);

      string stringToSign = 'GET\n\n\n' + timeOut + '\n/' + path + encoded ; //+ filename;
      string signature = make_sig(stringToSign);
      string queryString = '?AWSAccessKeyId=' + CREDENTIALS.AWSAccessKeyId + '&Expires=' + timeOut + '&Signature=' + signature;


      PageReference page = new PageReference(CREDENTIALS.EndpointBaseURL + path + encoded );
      map<String, String> params = page.getParameters();
      params.put('AWSAccessKeyId', CREDENTIALS.AWSAccessKeyId);
      params.put('Expires', String.ValueOf(timeOut));
      params.put('Signature', signature);

      String result = page.getUrl();
      //  throw new transformationexception(''+result);
      system.debug('stringToSign  ' +  stringToSign + '  queryString  ' + queryString + '   result '  + result );

      return   result ;
    } catch (Exception e) {

      TransformationHelper.sendEmailSupport('AmazonFinancial genPublicExpiringAWSLinkIFAP filename' + filename, 'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
      return null;

    }

  }

  private static String make_sig(string canonicalBuffer) {
    String macUrl ;
    String signingKey = EncodingUtil.base64Encode(Blob.valueOf(CREDENTIALS.Secret));
    Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer), blob.valueof(CREDENTIALS.Secret));
    macUrl = EncodingUtil.base64Encode(mac);
    return macUrl;
  }




  public class IfapMessage {

    public string ISOCountryCodes {get; set;}
    public string AgentType     {get; set;}
    public string Country {get; set;}
    public string Documents {get; set;}
  }


  global class UploadFile {

    public String id {get; set;}
    public String filenameupload {get; set;}
    public String policy {get; set;}
    public String signedPolicy {get; set;}
    public String contentType {get; set;}
    public String path {get; set;}
    public String url {get; set;}
    public String accessKey {get; set;}
    public String returnUrl {get; set;}
    public String actionStatus {get; set;}
    public boolean isSuccess {get; set;}
    public String errorMessage {get; set;}



    public UploadFile( String id, String filenameupload, string caseNumber, String contentType ) {
      this.id = id;
      this.filenameupload = FOLDER + caseNumber + '/' + filenameupload;
      this.contentType = contentType;
      this.path = CREDENTIALS.Bucket + caseNumber + '/' +  filenameupload;
      this.url = CREDENTIALS.EndpointBaseURL + '/' + CREDENTIALS.Bucket;
      this.accessKey = CREDENTIALS.AWSAccessKeyId;
      this.returnUrl = null;
      this.actionStatus = '201';
      this.isSuccess = true;
      this.errorMessage = '';
      calculePolicy();
    }


    public void calculePolicy() {
      datetime expire = system.now().addDays(1);
      String formattedexpire = expire.formatGmt('yyyy-MM-dd') + 'T' +
                               expire.formatGmt('HH:mm:ss') + '.' + expire.formatGMT('SSS') + 'Z';

      String policyString =
        '{ "expiration": "' + formattedexpire + '","conditions": [ {"bucket": "' +
        CREDENTIALS.Bucket + '" } ,'
        +
        '{"content-type":"' +  contentType + '"},' +
        '{"success_action_status": "' + actionStatus + '" },' +
        '["starts-with", "$key", ""],' +
        '["content-length-range", 0, ' + FILE_SIZE_LIMIT_BYTES + '] ]}';
      policy = EncodingUtil.base64Encode(Blob.valueOf(policyString));
      signedPolicy = make_sig(EncodingUtil.base64Encode(Blob.valueOf(policyString)));
    }


  }

}