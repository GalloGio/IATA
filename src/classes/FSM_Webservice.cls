global without sharing class FSM_Webservice {

    public String relatedTo { get; set; }
    public static final string sEmailSubject = 'Financial Security Review/Renewal Letter';
    public static final string sEmailFrom = 'noreply.ifap@iata.org';
    public static final string sEmailFromName = '"IATA Financial Review" <noreply.ifap@iata.org>';
    
    public static final String PAX = 'Travel Agent';
    public static final String CARGO = 'Cargo Agent';

	public static String greeting{ get; set; }
	public static String section1{ get; set; }
	public static String section2{ get; set; }
	public static String section3{ get; set; }
	public static String signature{ get; set; }
	public static String text1{ get; set; }

    WebService static String sendFSRequestedLetter(String caseId) {
        //INC193737 10-08-2015 - select the attachments related list
        list<Case> listCase = [
            Select Id, Account.Id, FS_Letter_Sent__c, Reminder_EmailTemplate__c, FS_Deadline_Date__c, Account.RecordtypeId, Account.Industry, Account.Name, Contact.Id, Contact.Email, /*ThreadID__c,*/ Account.AIMS_ID__c, (select Id from Attachments)
            from Case where Id = :caseId 
        ];

        if ( sendListFSRequestedLetter( listCase ) ) {
            return  Label.Send_FS_Request_Letter_Ok;
        } else {
            return Label.Send_FS_Request_Letter_Error;
        }
        
    }

    private static String updateField( Object input, String replaceFrom, String replaceTo) {
		String fieldValue =  String.ValueOf( input );
		system.debug('fieldValue ' + fieldValue);
		try {
			system.debug('replaceFrom / replaceTo ' + replaceFrom + ' ' + replaceTo);
			replaceTo = replaceTo==null?'':replaceTo;
			fieldValue = fieldValue.replace( replaceFrom, replaceTo);
			system.debug('fieldValue ' + fieldValue);
			return  fieldValue;
			
		} catch ( Exception e ) {
			return fieldValue;
		}
	}

    public static Boolean sendListFSRequestedLetter( list<Case> listCase ) {
        list<Case> updateList = new list<Case>();
        for ( Case caseObj: listCase ) {
            if ( caseObj.Reminder_EmailTemplate__c != null ) {
            	
            	//caseObj.FS_Letter_Sent__c = true;
                caseObj.FS_Deadline_Date__c = getCaseDeadLineDate(caseObj);
                caseObj.Status = 'FS requested';
                updateList.add( caseObj );

            }
        } 
        if ( updateList.isEmpty() ) {
            return false;
        } else {

            //INC193737
            List<Messaging.EmailFileAttachment> Attachments = new List<Messaging.EmailFileAttachment>();
            List<Messaging.SingleEmailMessage> EmailMessages = new  List<Messaging.SingleEmailMessage>();
            system.debug('updateList size 1-' + updateList.size());


            for(Case c:updateList){
				
                Attachments.clear();
	            List<EmailTemplate__c> reminderEmailTemplate = [
				Select Id, Greeting_Line__c, Body_Section_1__c,Body_Section_2__c,Body_Section_3__c, Signature_Details__c, Text_1__c, (select Id from Attachments)
				From EmailTemplate__c
				Where id = :c.Reminder_EmailTemplate__c 
				LIMIT 1];

				for(EmailTemplate__c t : reminderEmailTemplate){
					greeting = updateField( t.Greeting_Line__c, '<ACCOUNT NAME>', c.Account.Name);
					section1 = updateField( t.Body_Section_1__c, '&lt;FS CURRENCY&gt;', c.CurrencyISOCode);
					if (c.Financial_Security_Amount_2__c == null ) {
						c.Financial_Security_Amount_2__c = 0;
					}
					section1 = updateField( section1, '&lt;FS AMOUNT&gt;', c.Financial_Security_Amount_2__c.format() );
					section1 = updateField( section1, '&lt;FS DEADLINE&gt;', String.ValueOf( c.FS_Deadline_Date__c) + ' (YYYY-MM-DD)' );
					section2 = t.Body_Section_2__c;
					section3 = t.Body_Section_3__c;
					signature = updateField( t.Signature_Details__c, '&lt;CASE&gt;', String.ValueOf( c.CaseNumber) );
					text1 = updateField( t.Text_1__c, '<IATA CODE>', String.ValueOf( c.Account.AIMS_ID__c ) );


					// build email body
        			String htmlEmailBody = '<html><body style=\'font-family:"Calibri","sans-serif";\'>';
        			//htmlEmailBody += '<td style="background-color:#FFFFFF; vertical-align:top; height:200px; text-align:left;">';
        			htmlEmailBody += '<img id="hi" src="'+ getImageHeader() + '"/>';
        			htmlEmailBody += '<br/><br/>' + greeting + ',<br/>';
        			htmlEmailBody += text1 + '<br/>';
        			htmlEmailBody += section1 + '<br/>';
        			if(section2 != null && section2 != '')htmlEmailBody += section2 + '<br/>';
                    	else htmlEmailBody += '';
                    if(section3 != null && section3 != '')htmlEmailBody += section3 + '<br/>';
                    	else htmlEmailBody += '';        			
        			htmlEmailBody += signature + '<br/>';
        			htmlEmailBody += '</body></html>';


					Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
                	em.setToAddresses(new list<string>{c.Contact.Email});
                	//em.setTemplateId(template[0].Id);
                	em.setTargetObjectId(c.Contact.Id);
                	em.saveAsActivity=false;
                	em.setSubject(sEmailSubject);
                	em.setHtmlBody(htmlEmailBody);

                    system.debug('EMAIL IS ' + em.getToAddresses());                    
                    
					if(t.Attachments.size()>0){

						List<Attachment> listAtt = [Select Name, Body, ContentType From Attachment where parentId = :t.Id];
						
						for(Attachment a : listAtt){
							Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
							efa.setFileName(a.Name);
                        	efa.setBody(a.Body);
                        	Attachments.add(efa);
						}

						em.setFileAttachments(Attachments);
					}
					EmailMessages.add(em);
				}



                
            }
            system.debug('EmailMessages size 2-' + EmailMessages.size());
            if(!Test.isRunningTest())	Messaging.sendEmail(EmailMessages);  

            //Database.insert(lsEM);
            Database.update(updateList);
            return true;
        }
    }
    
    private static Date getCaseDeadLineDate( Case caseObj ) { 
        
        system.debug('caseObj.Account.Industry' + caseObj.Account.Industry);
        
        if ( caseObj.Account.Industry == PAX ) {  
            return Date.today().addDays(30);
        }
        if ( caseObj.Account.Industry == CARGO ) {
            return Date.today().addDays(60);
        }
        return null;
    }


    public static String getImageHeader() {
        try{
		Document imageHeader = [Select Id from Document where Name = 'FSM Email Template Header'];
		return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + imageHeader.Id + '&oid=' + UserInfo.getOrganizationId();
        }catch(Exception e){
                return '';
            }
	}

}