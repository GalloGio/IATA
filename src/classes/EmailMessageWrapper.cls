public class  EmailMessageWrapper{


public string  FromAddress    {get;set;}
public string ToAddress     {get;set;}
public string   ToAddressId   {get;set;}
public string  BccAddress    {get;set;}
public string Subject     {get;set;}
public Map<String, String> ParameterSubjectMap    {get;set;}
public string  Body    {get;set;}
public Map<String, String>ParameterBodyMap    {get;set;}



 public EmailMessageWrapper(String fromAddr, String toAddr, Id toAddrId, String bccAddr, String sub, Map<String, String>  mapSubjectParams, String body, Map<String, String> mapBodyParams) {
     this.FromAddress = fromAddr;
     this.ToAddress = toAddr;
     this.ToAddressId = toAddrId;
     this.BccAddress = bccAddr;
     this.Subject = sub;
     this.ParameterSubjectMap = mapSubjectParams;
     this.Body = body;
     this.ParameterBodyMap = mapBodyParams;
 }

 public static void sendEmail(List<EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateNameDeveloperName, String community) {
 	sendEmail(listEmailMessageWrapper, emailTemplateNameDeveloperName, null, community);
 }

 public static void sendEmail(List<EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateNameDeveloperName, String userId, String community) {

 //throw new TransformationException(' ' + listEmailMessageWrapper  + '   '+ emailTemplateNameDeveloperName);
    if(community == null) community = '';
     List<Messaging.SendEmailResult> listEmailResult = null;
     List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
     EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateNameDeveloperName ];
     Map <Id, OrgWideEmailAddress> orgAddressMap = new Map <Id, OrgWideEmailAddress> ([SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org' or Address = 'cns_noreply@cnsc.us']);
     Map <String, Id> orgAddressByEmail = new Map <String, Id> ();
     for(OrgWideEmailAddress oea: orgAddressMap.values()){
        orgAddressByEmail.put(oea.Address, oea.Id);
     }

     for (EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

         if (!orgAddressMap.isEmpty()){
            if(community.contains('CNS') ){
                mail.setOrgWideEmailAddressId(orgAddressByEmail.get('cns_noreply@cnsc.us'));
            }else{
                mail.setOrgWideEmailAddressId(orgAddressByEmail.get('noreply@iata.org'));
            }

         }
         else{
            if(community.contains('CNS') ){
                mail.setSenderDisplayName('CNS noreply');
            }else{
            mail.setSenderDisplayName('IATA no reply');
            }
            if(emailMessageWrapper.FromAddress != null && emailMessageWrapper.FromAddress.length() > 0)
                mail.setReplyTo(emailMessageWrapper.FromAddress);
         }
         if (userId == null){
	         if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0)
	             mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
	         else
	             mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
         }
         else{
         	mail.setTargetObjectId(userId);
         }
         if(emailMessageWrapper.BccAddress != null && emailMessageWrapper.BccAddress.length() > 0)
             mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });
         String subject = null;
         if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0) {
             mail.setSubject(emailMessageWrapper.Subject);
             subject = emailMessageWrapper.Subject;
         }
         else
             subject = emailTemplate.Subject;

         for(String key: emailMessageWrapper.ParameterSubjectMap.keySet())
             subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));

         mail.setSubject(subject);
         String htmlBody = emailTemplate.HtmlValue;
         String plainBody = emailTemplate.Body;
         for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
             if(htmlBody <> null && emailMessageWrapper.ParameterBodyMap <> null)
             htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
             plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
         }

         if(htmlBody <> null)
         mail.setHtmlBody(htmlBody);
         mail.setSaveAsActivity(false);
         mail.setPlainTextBody(plainBody);
         listSingleEmailMessages.add(mail);
     }
     if(!Test.isRunningTest())
         listEmailResult = Messaging.sendEmail(listSingleEmailMessages);


          //throw new TransformationException(' ' + listEmailResult  + '   '+ emailTemplateNameDeveloperName);
 }

 }
