public class VFEmailTemplateController{
  
  // this variable must be set in the parameters of the component
  public String caseId{get;
    set{     
      caseId= value; VFEmailTemplateController();
    }  
  }    

  // this variable must be set in the parameters of the component
  public String templateName {get;set{templateName = value;}}

  public Boolean isEnglish {get;set;}  
   
  public String checkValue{get;set;}  

  public boolean displayReminderContent {get;set;} 


   public String caseURL {get; set;}


  public String ContactName {get; set;}  
  public String caseNumber {get;set;}
  public String IATAcodeTag{get;set;}
  public String reviewType {get;set;}
  
  public String accountName {get;set;}
  public String FScurrency {get;set;}
  public String FSammount {get;set;}
  
   public String agentType {get;set;}
  
   public String agentCode {get;set;}
   
   public String ISOCode {get;set;} 
   
   public String emailBody1 {get;set;}
  
   public String emailBody2 {get;set;}
   
   public String emailBody3 {get;set;}
  
   public String text1 {get;set;}
   public String text2 {get;set;}
   public String text3 {get;set;}
   public String text4 {get;set;} 
   public String text5 {get;set;}
   
  public String uploadInst {get;set;} 
  
  public String uploadInstPortal {get;set;}
   
  public String deadline {get; set;} 
  public String year {get;set;}
  public String FSdeadline {get; set;} 
  
  public String greeting{get; set;} 
    
  public String signature{get; set;}
     
  public Datetime casedate; 
    
  EmailTemplate__c e;
  
  public boolean displayDeadline {get;set;}
  
  
  private Date tmp {get;set;} 
  
  public static final map<string,map<integer,string>> numMonthPerWordMonthPerLanguage = new map<string,map<integer,string>>{
  
    'French' => new map<integer,string>{1 => 'Janvier',2=>'Février',3=>'Mars',4=>'Avril',
                                        5=>'Mai',6=>'Juin',7=>'Juillet',8=>'Août',
                                        9=>'Septembre',10=>'Octobre',11=>'Novembre',12=>'Décembre'}
    ,
    'Spanish' => new map<integer,string>{1 => 'Enero',2=>'Febrero',3=>'Marzo',4=>'Abril',
                                        5=>'Mayo',6=>'Junio',7=>'Julio',8=>'Agosto',
                                        9=>'Septiembre',10=>'Octubre',11=>'Noviembre',12=>'Diciembre'}
    ,
    'Portuguese' => new map<integer,string>{1 => 'Janeiro',2=>'Fevereiro',3=>'Março',4=>'Abril',
                                        5=>'Maio',6=>'Junho',7=>'Julho',8=>'Agosto',
                                        9=>'Setembro',10=>'Outubro',11=>'Novembro',12=>'Dezembro'}  
    ,
    'Otherz' => new map<integer,string>{1 => 'January',2=>'February',3=>'March',4=>'April',
                                        5=>'May',6=>'June',7=>'July',8=>'August',
                                        9=>'September',10=>'October',11=>'November',12=>'December'} 
    
    } ;
  
  
  
 private  string formatThisDate(string language,Date dateToFormat){
    
        
        if(dateToFormat == null)
            return null;
            
        if(language == null || numMonthPerWordMonthPerLanguage.get(language) == null)
        language = 'Otherz';
        
        
        string returnString = string.valueof(dateToFormat.day()) + ' ' 
                            + numMonthPerWordMonthPerLanguage.get(language).get(dateToFormat.month()) + ' ' +
                            string.valueof(dateToFormat.year());    
        
 
        return returnString;
 }  


    public void VFEmailTemplateController(){
        IATAcodeTag = 'IATA numeric code:';
        try{
            System.debug('*** VFEmailTemplateController');

            String pRem = Apexpages.currentpage().getParameters().get('reminder');
            String pRemError = Apexpages.currentpage().getParameters().get('noReminderSelected');
            
            // this variable will be set if the template is called from the sendSingleTrackedEmail page
            //String templateDeveloperName = Apexpages.currentpage().getParameters().get('template');
            String templateId = Apexpages.currentpage().getParameters().get('template_id');
            String caseIdParam = Apexpages.currentpage().getParameters().get('p3_lkid');
            greeting = caseIdParam;
            Case c = new Case();
            if(caseIdParam != null){     
                //c = [Select FA_Letter_Sent__c, FS_Mass_Email_Send__c,Mass_Case_Creation_Email_Send__c, FS_Request_Mass__c, Mass_Email_Send__c, status,FS_EmailTemplate__r.name,FS_Reminder_EmailTemplate__r.name,Reminder_EmailTemplate__r.name ,Reminder_EmailTemplate__c, deadline_date__c,casenumber,FormattedDate__c,Formatted_FS_Deadline_Date__c, id ,EmailTemplate__r.name,EmailTemplate__r.Id,Account.IATACode__c, IFAP_Agent_type__c, financial_review_type__c, Account.BillingCountry, Account.Agent_Type_Code__c from Case where id =: +caseIdParam];
                //IFAP Enhancement 3
                c = [Select FS_Mass_Email_Send__c,Mass_Case_Creation_Email_Send__c, FS_Request_Mass__c, FS_Second_Deadline_Date__c,FA_Second_Deadline_Date__c,
                        IFAP_Financial_Year__c,Mass_Email_Send__c, status,FS_EmailTemplate__r.name,FA_Third_Deadline_Date__c,
                        FS_Reminder_EmailTemplate__r.name,Reminder_EmailTemplate__r.name ,Reminder_EmailTemplate__c,
                        deadline_date__c,FS_Deadline_Date__c,casenumber,FS_Third_Deadline_Date__c,
                        //FormattedDate__c,
                        //Formatted_FS_Deadline_Date__c,
                        id ,EmailTemplate__r.name,EmailTemplate__r.Id,Account.IATACode__c, IFAP_Agent_type__c, financial_review_type__c, 
                        Account.BillingCountry,Account.Name, Account.Agent_Type_Code__c,Financial_Security_Currency__c,Financial_Security_Amount__c,Contact.Email
                    from Case 
                    where id =: +caseIdParam];
            } else if (caseIdParam == null){
                //c = [Select FA_Letter_Sent__c, FS_Mass_Email_Send__c,Mass_Case_Creation_Email_Send__c, FS_Request_Mass__c, Mass_Email_Send__c, status,FS_EmailTemplate__r.name,FS_Reminder_EmailTemplate__r.name,Reminder_EmailTemplate__r.name ,Reminder_EmailTemplate__c, deadline_date__c,casenumber,FormattedDate__c, id ,EmailTemplate__r.name,EmailTemplate__r.Id,Account.IATACode__c, IFAP_Agent_type__c, financial_review_type__c, Account.BillingCountry, Account.Agent_Type_Code__c from Case where id =: +caseId];
                //IFAP 3 Enhancement
                c = [Select FS_Mass_Email_Send__c,Mass_Case_Creation_Email_Send__c, FA_Second_Deadline_Date__c,FA_Third_Deadline_Date__c,
                        FS_Request_Mass__c, IFAP_Financial_Year__c,Mass_Email_Send__c, status,FS_Second_Deadline_Date__c,
                        FS_EmailTemplate__r.name,FS_Reminder_EmailTemplate__r.name,Reminder_EmailTemplate__r.name ,FS_Third_Deadline_Date__c,
                        Reminder_EmailTemplate__c, deadline_date__c,FS_Deadline_Date__c,casenumber,
                        //  FormattedDate__c,
                        //Formatted_FS_Deadline_Date__c,
                        id ,EmailTemplate__r.name,EmailTemplate__r.Id,Account.IATACode__c, 
                        IFAP_Agent_type__c, financial_review_type__c, Account.BillingCountry,Account.Name, Account.Agent_Type_Code__c,
                        Financial_Security_Currency__c,Financial_Security_Amount__c,Contact.Email 
                    from Case 
                    where id =: +caseId];
            }

            caseNumber = c.caseNumber;
            ContactName= c.Contact.Email;

            System.debug('*** Case '+c);
            System.debug('*** Case status '+c.Status);
            System.debug('*** before EmailTemplate__c ' + e);
      
            // Enhancement Requested by Snjezana Ivancan (INC088579)
            // With the new ISS Customer Portal we have to amend IFAP email templates for the countries that have been rolled-out to the portal and for the coming countries.
            // One of the items that has to be changed is in the email template section 'Upload Instructions- Portal' and it is link to the IFAP portal (not visible):
            // This link for the rolled out countries needs to be changed to the new portal link. For the countries that have still not been rolled out we need to keep existing email templates with the 'old' link.
            // Added by: Frederic Tremblay
            // Added date: 2014-02-26
            caseURL = '';

            // Get the list of settings in the IFAP Portal URL Links (Custom settings)
            List <IATA_ISO_Country_Set__c> isoCountryInfo = IATA_ISO_Country_Set__c.getAll().values();

            // Search in the list of setting if the current country exist (Country of of the Account billing address)
            for (IATA_ISO_Country_Set__c CountryInfo: isoCountryInfo){
                if (c.Account.BillingCountry.toUppercase() == CountryInfo.Country_Name__c.toUppercase()){
                    // In case the current country is in the list we use the setting value for the Portal URL link.
                    caseURL = CountryInfo.Portal_URL__c;
                }
            }
   
            // In case the country is not found in the list of settings, we use the default value.
            if (caseURL == ''){
                caseURL = Label.IFAP_Portal_URL_default_value;
            } 

            //Enhancement 3.0
            if ((c.Status == 'Financial Security Requested' && c.FS_Request_Mass__c == true) || c.Status == 'Assessment Performed')//e = c.FS_EmailTemplate__r;
                e = [Select id,name, is_reminder__c, upload_instructions_portal__c,
                        Deadline_Date_Required__c, review_types__c, Body_Section_1__c,
                        Body_Section_2__C, Body_Section_3__c, Template_Language__c, Signature_Details__c,
                        greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c 
                    from EmailTemplate__c
                    where name =: c.FS_EmailTemplate__r.name and recordType.Name = 'IFAP'];

            else if (c.Status.contains('Agent Notified') && c.Mass_Email_Send__c == true && c.Reminder_EmailTemplate__c != null)  //e = c.Reminder_EmailTemplate__r;  FINANCIAL ASSESMENT REMINDER
                e = [Select id,name, is_reminder__c, upload_instructions_portal__c,
                        Deadline_Date_Required__c, review_types__c, Body_Section_1__c, 
                        Body_Section_2__C, Body_Section_3__c, Template_Language__c, Signature_Details__c,
                        greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c
                    from EmailTemplate__c
                    where name =: c.Reminder_EmailTemplate__r.name and recordType.Name = 'IFAP'];

            else if (c.Status.contains('Agent Notified') && c.Mass_Case_Creation_Email_Send__c == true && c.EmailTemplate__c != null)  
                e = [Select id,name, is_reminder__c, 
                        upload_instructions_portal__c,Deadline_Date_Required__c,
                        review_types__c, Body_Section_1__c, Body_Section_2__C,
                        Body_Section_3__c, Template_Language__c, Signature_Details__c,
                        greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c
                    from EmailTemplate__c 
                    where name =: c.EmailTemplate__r.name and recordType.Name = 'IFAP'];

            else if (c.Status.contains('Agent Notified (Tracked Email)') && c.EmailTemplate__c != null)  
                e = [Select id,name, is_reminder__c, 
                        upload_instructions_portal__c,Deadline_Date_Required__c,
                        review_types__c, Body_Section_1__c, Body_Section_2__C,
                        Body_Section_3__c, Template_Language__c, Signature_Details__c,
                        greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c
                    from EmailTemplate__c 
                    where name =: c.EmailTemplate__r.name and recordType.Name = 'IFAP'];

            else if (c.FS_Mass_Email_Send__c == true && c.Status == 'Financial Security Requested')//e = c.FS_Reminder_EmailTemplate__r;        
                e = [Select id,name, is_reminder__c, upload_instructions_portal__c,
                        Deadline_Date_Required__c, review_types__c, Body_Section_1__c, Body_Section_2__C,
                        Body_Section_3__c, Template_Language__c, Signature_Details__c, greeting_line__c, 
                        upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c 
                    from EmailTemplate__c
                    where name =: c.FS_Reminder_EmailTemplate__r.name and recordType.Name = 'IFAP'];


//            if(pRem == 'true' || templateId  == '00X20000001SfWW') { // IFAP FA Reminder
            if(templateName  == 'IFAP_FA_Reminder') { // IFAP FA Reminder

                e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c, 
                        review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c,
                        Signature_Details__c, greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c 
                    from EmailTemplate__c 
                    where name =: c.Reminder_EmailTemplate__r.name and recordType.Name = 'IFAP'];
                System.debug('*** pREm - FA rem');
//            }else if(pRem == 'famanual' || templateId  == '00X20000001Rxu0') {    //IFAP
            }else if(templateName  == 'IFAP') {    //IFAP

                e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c,
                        review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c, 
                        Signature_Details__c, greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c 
                    from EmailTemplate__c 
                    where name =: c.EmailTemplate__r.name and recordType.Name = 'IFAP'];
                System.debug('*** pREm - FA manual');
//            } else  if(pRem == 'fsreminder' || templateId  == '00X20000001SfWX') {  // IFAP FS Reminder
            } else  if(templateName  == 'IFAP_FS_Reminder') {  // IFAP FS Reminder
                e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c,
                        review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c,
                        Signature_Details__c, greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c 
                    from EmailTemplate__c 
                    where name =: c.FS_Reminder_EmailTemplate__r.name and recordType.Name = 'IFAP'];
                System.debug('*** pREm - FS rem manual');
//            } else  if(pRem == 'fsmanual' || templateId  == '00X20000001SfWY') { // IFAP FS Request
            } else  if(templateName  == 'IFAP_FS_Request') { // IFAP FS Request
                e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c, 
                        review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c,
                        Signature_Details__c, greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c
                    from EmailTemplate__c 
                    where name =: c.FS_EmailTemplate__r.name and recordType.Name = 'IFAP'];
                System.debug('*** pREm - FS rem manual');
            }

            if(c.deadline_date__c != null) {
                if(e.Deadline_Date_Required__c){
                    displayDeadline = true;
                }
            }


            isEnglish = true;      
            //reviewType = e.review_type__c;
            emailBody2 = e.Body_section_2__c;
            emailBody3 = e.body_section_3__c;
            uploadInst = e.upload_instructions__c;
            uploadInstPortal = e.Upload_Instructions_Portal__c;

            tmp = c.FA_Third_Deadline_Date__c <> null ?  c.FA_Third_Deadline_Date__c :
                                     c.FA_Second_Deadline_Date__c <> null ?  c.FA_Second_Deadline_Date__c : c.deadline_date__c;

            deadline = this.formatThisDate(e.Template_Language__c,tmp); 
            tmp = null;
            //c.FormattedDate__c; THIS IS THE FA
            year = c.IFAP_Financial_Year__c;
            signature = e.signature_details__c;
            greeting = e.greeting_line__c;    
            emailBody1 = e.Body_Section_1__c;

            //New          
            text1 = e.Text_1__c;
            text2 = e.Text_2__c;
            text3 = e.Text_3__c;
            text4 = e.Text_4__c;
            text5 = e.Text_5__c;

            agentCode = c.Account.IATACode__c;
            FScurrency= c.Financial_Security_Currency__c;
            FSammount = String.valueOf(c.Financial_Security_Amount__c);
            accountName = c.Account.Name;
            tmp = c.FS_Third_Deadline_Date__c <> null ?  c.FS_Third_Deadline_Date__c :c.FS_Second_Deadline_Date__c <> null ?  c.FS_Second_Deadline_Date__c :c.FS_Deadline_Date__c;
            FSdeadline  =   this.formatThisDate(e.Template_Language__c,tmp); // c.Formatted_FS_Deadline_Date__c;// String.valueOf(c.FS_Deadline_Date__c); THIS IS THE FINANCIAL SECURITY
            tmp = null;
            if(pRemError == null && e == null){
                agentType = c.Account.Agent_Type_Code__c;
                agentCode = c.Account.IATACode__c;
                ISOCode = c.IFAP_Country_ISO__c;

                if(pRem == null){
                    //e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c, review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c, Signature_Details__c, greeting_line__c, upload_instructions__C from EmailTemplate__c where name =: c.EmailTemplate__r.name];//: c.EmailTemplate__r.Id];
                    e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c,
                            review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c,
                            Signature_Details__c, greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c 
                        from EmailTemplate__c
                        where name =: c.EmailTemplate__r.name
                        and recordType.Name = 'IFAP'];
                }
                else{
                    // e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c, review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c, Signature_Details__c, greeting_line__c, upload_instructions__C from EmailTemplate__c where name =: c.Reminder_EmailTemplate__r.name];
                    e = [Select id,name, is_reminder__c, upload_instructions_portal__c,Deadline_Date_Required__c, 
                            review_types__c, Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Template_Language__c, 
                            Signature_Details__c, greeting_line__c, upload_instructions__C,Text_1__c,Text_2__c,Text_3__c,Text_4__c,Text_5__c 
                        from EmailTemplate__c
                        where name =: c.Reminder_EmailTemplate__r.name and recordType.Name = 'IFAP'];          
                }
            
                if(c.deadline_date__c != null) {
                    if(e.Deadline_Date_Required__c){
                        displayDeadline = true;
                    }
                }

                isEnglish = true;      
                //reviewType = e.review_type__c;
                emailBody2 = e.Body_section_2__c;
                emailBody3 = e.body_section_3__c;
                uploadInst = e.upload_instructions__c;
                uploadInstPortal = e.Upload_Instructions_Portal__c;

                //New  
                text1 = e.Text_1__c;
                text2 = e.Text_2__c;
                text3 = e.Text_3__c;
                text4 = e.Text_4__c;
                text5 = e.Text_5__c;
          
                agentCode = c.Account.IATACode__c;
                FScurrency= c.Financial_Security_Currency__c;
                FSammount = String.valueOf(c.Financial_Security_Amount__c);
                accountName = c.Account.Name;
                tmp = c.FS_Third_Deadline_Date__c <> null ?  c.FS_Third_Deadline_Date__c :c.FS_Second_Deadline_Date__c <> null ?  c.FS_Second_Deadline_Date__c :c.FS_Deadline_Date__c;
                FSdeadline  =   this.formatThisDate(e.Template_Language__c,tmp); // c.Formatted_FS_Deadline_Date__c;// String.valueOf(c.FS_Deadline_Date__c); THIS IS THE FINANCIAL SECURITY
                tmp = null; 
                year = c.IFAP_Financial_Year__c;
                /////

                tmp = c.FA_Third_Deadline_Date__c <> null ?  c.FA_Third_Deadline_Date__c :
                                     c.FA_Second_Deadline_Date__c <> null ?  c.FA_Second_Deadline_Date__c : c.deadline_date__c;
                deadline = this.formatThisDate(e.Template_Language__c,tmp); 
                tmp = null;
                signature = e.signature_details__c;
                greeting = e.greeting_line__c;
                emailBody1 = e.Body_Section_1__c;
            }
        }
        catch(Exception ex){
            emailBody2 = 'Exception!!!!' + ex;
        }
    }	
}