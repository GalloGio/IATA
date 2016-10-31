global class AMS_VoucherPDFCreationBatch implements Database.Batchable<sObject>, Database.Stateful  {
	
	String query;

	public Set<Id> vouchersToPrint; 

	public List<Attachment> attachments;

	public Integer run = 0;

	public AMS_Voucher_Region__c region;

	public AMS_Voucher_Process_Run__c process;
	
	global AMS_VoucherPDFCreationBatch(Set<Id> vouchersToPrintSet, AMS_Voucher_Region__c regionInput, AMS_Voucher_Process_Run__c process)  {

		vouchersToPrint = vouchersToPrintSet;

		this.query = 'SELECT Id FROM AMS_Voucher__c WHERE Id in :vouchersToPrint';

		this.region = regionInput;

		this.process = process;

		this.attachments = new List<Attachment>();

		run = fetchProperRun(regionInput);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	
	}

   	global void execute(Database.BatchableContext BC, List<AMS_Voucher__c> scope) {
		
		run ++;

		String filename = savePDF(scope,run);

		List<AMS_Voucher__c> toUpdate = new List<AMS_Voucher__c>();

		for(AMS_Voucher__c v : scope){

			v.Pdf_Attachment_File__c = filename;
			toUpdate.add(v);
		}

		if(!toUpdate.isEmpty())
			update toUpdate;

			System.debug('Vouchers to Update pdf name:' + toUpdate);
            

	}
	
	global void finish(Database.BatchableContext BC) {
	
		if(!attachments.isEmpty())
			insert attachments;

		String userName = UserInfo.getUserName();

		User activeUser = [Select Email From User where Username = : userName limit 1];

		if(!Test.isRunningTest())
			sendSingleMail(buildCustomReport(),activeUser,region);

		process.Status__c = 'Ended';

		update process;

	}


	
	private String savePDF(List<AMS_Voucher__c> scope, Integer runExe) {
        
		Datetime nowDate = Datetime.now();
		String formattedDate = nowDate.format('yyyyMMdd');

        String filename = 'Vouchers_'+ region.Name + '_' + runExe + '_' + formattedDate + '.pdf';

		PageReference pdf = Page.AMS_VoucherPDFGeneratorPage;
		
        
        List<String> idsVouchers = buildIdsString(scope);
        
        System.debug('AMS_VoucherPDFCreationBatch__ Ids to print are:'+idsVouchers);

		pdf.getParameters().put('sizeList',JSON.serialize(idsVouchers.size()));

		Integer i = 0;

		For(String ids: idsVouchers){

			pdf.getParameters().put('list'+i,JSON.serialize(ids));
			i++;
		}

	    Attachment attach = new Attachment();

	    Blob body;

	    if(Test.isRunningTest()){
			body = Blob.valueOf('Test');
	    }else
			body = pdf.getContent();

		attach.Body = body;

		attach.Name = filename;

		attach.IsPrivate = false;
	
		attach.ParentId = region.Id;

		attachments.add(attach);

		return filename;

	}

	public static void sendSingleMail(String myCustomString,User activeUser, AMS_Voucher_Region__c region){

		String userEmail = activeUser.Email;

	    // grab the email template
	    EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where name = 'Vouchers Creation Report'];

	     // process the merge fields
	    String subject = emailTemplate.Subject;

	    String htmlBody = emailTemplate.HtmlValue;
	    htmlBody = htmlBody.replace('##REPORT##', myCustomString);
	    htmlBody = htmlBody.replace('##PDFLINK##', buildCustomPDFLink(region));
	   
	    String plainBody = emailTemplate.Body;
	    plainBody = plainBody.replace('##REPORT##', myCustomString);
	    plainBody = plainBody.replace('##PDFLINK##', buildCustomPDFLink(region));

	        //build the email message
	    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();

	    email.setToAddresses(new String[]{userEmail});
	    email.setReplyTo('testuserdonotreply@iatas.test');
	    email.setSenderDisplayName('IATA PDF Generation Process');

	    email.setSubject(subject);
	    email.setHtmlBody(htmlBody);
	    //email.setPlainTextBody(plainBody);

	    Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
	}

	private String buildCustomReport(){
		
		Report rep = [select id, name, description from report where Name = 'Voucher Batch Report' LIMIT 1];

		String urlCode = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());

		return urlCode + '/' + rep.Id +  '?pn0=eq&pv0=' +  String.valueOf(process.Id).substring(0, 15);
	}

	private static String buildCustomPDFLink(AMS_Voucher_Region__c region){

		String urlCode = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());

		return urlCode + '/' + region.Id ;

	}
  
  	private List<String> buildIdsString(List<AMS_Voucher__c> scope){

  		List<String> toReturn = new List<String>();
  		String stringIds = '';
  		Integer i = 0;

  		for(AMS_Voucher__c v : scope){

  			if(i == 200){
  				toReturn.add(stringIds);
  				stringIds = '';
  				i =0;
  			}

  			i++;

  			stringIds += v.Id + ';';

  		}
		
        toReturn.add(stringIds);
        
  		return toReturn;

  	}

	public Integer fetchProperRun(AMS_Voucher_Region__c regionInput){

		try{
			Datetime nowDate = Datetime.now();
			String formattedDate = '%'+nowDate.format('yyyy')+'%';

			List<Attachment> attcs = [SELECT Id, Name from attachment where ParentId = :regionInput.Id and name like :formattedDate order by name desc limit 1];

			System.debug('Attachment list is :' + attcs);

			if(attcs.isEmpty())
				return 0;

			String filenameLast = attcs.get(0).Name;

			System.debug('filenameLast is :' + filenameLast);

			String oldRun = filenameLast.split('_').get(2);

			System.debug('oldRun is :' + oldRun);

			return Integer.valueOf(oldRun);

		}catch(Exception e){
			System.debug('Did not find anything ?:' + e);
		}

		return 0;

	}
}