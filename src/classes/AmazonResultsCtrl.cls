global class AmazonResultsCtrl {
		public boolean techinicalProb{get;set;}
		public boolean renderLast2Columns {get;set;}
		public boolean Archived {get; private set;}
		public List<ENZ__FTPAttachment__c> docs {get;set;}
		public static final String SEPARATOR = '/';
		private Id id {get;set;}
		public list<AmazonFile> listFile {get; set;}
		private static string FOLDER ;
		public case cse {get; private set;}
		private static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME);

		public AmazonResultsCtrl(ApexPages.StandardController controller) {
					try{
					techinicalProb = false;
						 if ( ! Test.isRunningTest() ) controller.addFields(new list<string>{'CaseNumber','Financial_Results_Archived_Date__c','CaseNumber'});
						 this.id = controller.getId();
						 if(this.id== null) throw new transformationException('Empty constructor not allowed!');
						 cse = (Case)Controller.getRecord();
						 this.Archived = cse.Financial_Results_Archived_Date__c <> null;
										FOLDER = 'IFAP/FinancialResults/'+  cse.CaseNumber;
						 if(Archived){
										docs = [Select Name,ID From ENZ__FTPAttachment__c e where Financial_Assessment_Result__r.Case__c =:cse.id];
						 }else{
								 this.listFile = new list<AmazonFile>();
								 refreshListDoc();
						}

							}catch(AmazonRest.AmazonRestException ex){
													techinicalProb = true;

							 apexpages.addmessage(new apexpages.message(apexpages.severity.Error, 'Technical problem: we are fixing it, please try again later'));

							TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal AmazonRestException ' ,'   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
						}catch(Exception ex){

							TransformationHelper.sendEmailSupport('FATAL: AmazonFinancialCtrl constructor portal  ' ,'   STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());

													 apexpages.addmessage(new apexpages.message(apexpages.severity.Error, ex.getMessage()));


						}


		}



			 public Pagereference refreshListDoc() {
				map<String,AmazonFile__c> mapAmazonFiles = getMapAmazonFile();
				 this.renderLast2Columns = true;
			 list<AmazonRest.S3File> dirtyList = AmazonRest.getListFiles(FOLDER,CREDENTIALS);
				this.listFile = new list<AmazonFile>();
				for(AmazonRest.S3File s3File : dirtyList ){
						String name = s3File.getname();
						if( name.endsWith('.pdf') ) {

								AmazonFile__c amazonFile = mapAmazonFiles.get('/'+s3File.getFullName());
							//  throw new transformationException(s3File.getFullName());
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
		private map<String,AmazonFile__c> getMapAmazonFile() {
				list<AmazonFile__c> listAmazonFile = [
						Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c
						From AmazonFile__c
						Where Case__c = :this.cse.Id
				];



				map<String,AmazonFile__c> mapAmazonFile = new map<String,AmazonFile__c>();
				for ( AmazonFile__c amazonFile: listAmazonFile) {
						mapAmazonFile.put(amazonFile.Full_Name_Unique__c.replace('zip','pdf'), amazonFile);
				}

				return mapAmazonFile;
		}

	@remoteAction
		global static string getExpiringLinkIfap(string fileName ) {

						return  genPublicExpiringAWSLinkIFAP( CREDENTIALS.Bucket + SEPARATOR ,fileName);
				}


				private static string genPublicExpiringAWSLinkIFAP(string path, string filename){

						string  stringToSplit = '/'+filename;
						list<string> splittedName = stringToSplit.split('/');
						splittedName.remove(0);
						string encoded;
						for(string dirNm:splittedName)
								encoded+=  EncodingUtil.urlENcode(dirNm,'UTF-8') +'/';
						encoded = encoded.substring(0,encoded.length()-1).replaceAll('null','');

						Decimal timeInMili = Math.floor(System.now().getTime()/1000)+300;
						string check = string.valueof(timeInMili);
						if(check.indexOf('E') <> -1)    {
								check =check.substring(0,check.indexOf('E')).replace('.', '');
								check +='9';
						}
						long timeOut= Long.ValueOf(check);

						string stringToSign = 'GET\n\n\n' + timeOut+ '\n/' + path+ encoded ;//+ filename;
						string signature = make_sig(stringToSign);
						string queryString = '?AWSAccessKeyId=' + CREDENTIALS.AWSAccessKeyId + '&Expires=' + timeOut+ '&Signature=' + signature;


						PageReference page = new PageReference(CREDENTIALS.EndpointBaseURL + path+encoded );
						map<String,String> params = page.getParameters();
						params.put('AWSAccessKeyId', CREDENTIALS.AWSAccessKeyId);
						params.put('Expires', String.ValueOf(timeOut));
						params.put('Signature', signature);

						String result = page.getUrl();
					 //  throw new transformationexception(''+result);
						system.debug('stringToSign  '+  stringToSign + '  queryString  ' + queryString + '   result '  + result );

						return   result ;


						}






				 private static String make_sig(string canonicalBuffer) {
						String macUrl ;
						String signingKey = EncodingUtil.base64Encode(Blob.valueOf(CREDENTIALS.Secret));
						Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(CREDENTIALS.Secret));
						macUrl = EncodingUtil.base64Encode(mac);
						return macUrl;
				}



}
