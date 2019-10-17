public without sharing class GDPR_Helper {

    private static final String characters = 'ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmonpqrstuvwxyz';
    public enum UserType{USER, CONTACT, LEAD, NONE, FORBID}

    public static Boolean isDisposalEmail(String email){      
        // Check if email domain is in the black list (disposal email)
        String domain =  email.split('@')[1];
        return [select count() from Fobidden_Disposal_Email_Domain__mdt where Domain_Name__c =: domain ] > 0;
    }

    public static UserType doUserExists(String email){      
        
        // Check if email is fobidden first
        if(GDPR_Helper.isDisposalEmail(email)) return UserType.FORBID;

        List<User> searchUsers = [SELECT ID FROM USER WHERE Contact.Email = :email ORDER BY LastModifiedDate DESC LIMIT 1];
        
        /***IF THERE ARE USERS***/
        if(!searchUsers.isEmpty()){
            
            //Send Email
            // Link to oneId with redirection to GDPR Portal
            sendAccessEmail(email, Label.OneId_URL_To_GDPR);
            
            return UserType.USER;
        
        }else{
            
            List<Contact> searchContacts = [SELECT ID, LastName, FirstName, IndividualId FROM CONTACT WHERE Email = :email ORDER BY LastModifiedDate DESC LIMIT 1];

            /***IF THERE ARE NO USERS AND THERE ARE CONTACTS***/
            if(!searchContacts.isEmpty()){

                Contact c = searchContacts[0];
                Individual ind;
                
                //If already exists an Individual associated with the Contact.
                if(c.IndividualId!=null){                   
                    //Fetch the Individual record
                    ind = findIndividual(c.IndividualId);
                    
                //If there is NO Individual associated with the Contact.
                }else{

                    //Search for the existance of an Individual with the same email
                    ind = findIndividual(email);
                    
                    if(ind==null){
                        //If there is NO Individual associated with the contact and there is NO Individual that has the inserted email
                        //Create new Individual                        
                        ind = createIndividual(c.firstName, c.lastName, email);
                    }     
                    
                    //Associate this Individual with the contact.
                    c.IndividualId = ind.Id;
                    //Update the contact.
                    update c;               
                }
                
                updateEncryptEmailProcessWithLink(ind, email);
                return UserType.CONTACT;

            /*IF THERE IS NO CONTACTS WITH THE INTRODUCED EMAIL -> REPEAT THE PROCESS FOR LEADS */
            }else{
                
                List<Lead> searchLeads = [SELECT ID, LastName, FirstName, IndividualId FROM LEAD WHERE Email = :email ORDER BY pi__url__c ASC NULLS LAST, LastModifiedDate DESC LIMIT 1];

                /***IF THERE ARE NO USERS AND THERE ARE CONTACTS***/
                if(!searchLeads.isEmpty()){

                    Lead l = searchLeads[0];
                    Individual ind;
                    
                    //If already exists an Individual associated with the Lead.
                    if(l.IndividualId!=null){
                        //Fetch the Individual record
                        ind = findIndividual(l.IndividualId);
                    //If there is NO Individual associated with the Contact.
                    }else{
                        //Search for the existance of an Individual with the same email
                        ind = findIndividual(email);

                        if(ind==null){
                            //Create new Individual
                            ind = createIndividual(l.firstName, l.lastName, email);
                        }
                        
                        //Associate this Individual with the lead.
                        l.IndividualId = ind.Id;  
                        
                        //Update the lead.
                        update l;
                    }

                    
                    updateEncryptEmailProcessWithLink(ind, email);
                    return UserType.LEAD;
            
                }else{
                
                    //Send an email to the entered email that redirects to a web to lead form

                    String token = String.valueOf(System.TODAY()).left(10)+email.toLowerCase(); //Ex: 2018.12.24myemail@gmail.com
                    String encryptedToken = Comm_User_Helper.EncryptString(token);
                    String link = Site.getBaseURL()+'/s/guest-information?token='+encryptedToken;
                    sendAccessEmailUnknown(email, link);
                    
                    return UserType.NONE;
                }                                 
            }
        }
    }

    public static Individual createIndividual(String firstName, String lastName, String email){
        Individual i = new Individual(FirstName = firstName, LastName = lastName, Email__c = email);
        insert i;
        return i;
    }

    public static void createLead(String firstName, String lastName, String email, String company){
        // Create lead. Lead trigger will attach the individual record. The connector will sync the prospect (SF=>Pardot)
        Lead l = new Lead(FirstName = firstName, LastName = lastName, Email = email, company = company);
        insert l;
    }
    

    public static String headerHtml() {
        String str = '<table style="background-color: #1E32FA; width:100%;"><tr><td style="padding: 15px 40px;">'+
                '<table style="color:white; font-family: Arial, Helvetica, sans-serif; font-size: 23px;font-weight: 600;">'+
                '<tr>'+
                    '<td style="padding: 0;"><img width="73" height="50" src="'+Label.IATA_GDPR_White_Logo+'"/></td>'+
                    '<td style="border-left: 2px solid white; padding-left: 20px; width: 100%;">Signup &amp; Privacy Portal</td>'+
                '</tr>'+
                '</table>'+
            '</td></tr></table>';
        return str;
    }

    public static String footerHtml() {
        String str = '<table style="background-color: #535151; color:white; font-family: Arial, Helvetica, sans-serif; font-size: 23px; width:100%; padding: 15px 40px">'+
            '<tr>'+
                '<td style="width:20%"><img width="73" height="50" src="'+Label.IATA_GDPR_White_Logo+'" /></td>'+
                '<td colspan="2">Our mission is to represent, lead and serve the airline industry</td>'+            
            '</tr>'+

            '<tr><td colspan="3"><hr/></td></tr>'+

            '<tr >'+
                '<td style="width:20%; text-align:center;">'+
                    '<span><a style="font-size:15px; text-decoration: none; color:#ffffff;" href="https://www.iata.org" target="_blank">www.IATA.org</a></span>'+
                '</td>'+
                '<td style="width:60%; text-align:center;">'+
                    '<span style="font-size:15px;">© International Air Transportation Association (IATA). All rights reserved.</span>'+
                '</td>'+
                '<td style="width:20%; text-align:center;">'+
                    '<a style="font-size:15px; text-decoration: none; color:#ffffff;" class="terms" href="https://www.iata.org/Pages/privacy.aspx" target="_blank">Privacy policy</a>'+
                '</td>'+
            '</tr>'+
            
            '</table>';
        return str;
    }

    public static void sendEmail(String email, String htmlBody) {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'IATA Noreply'];
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setOrgWideEmailAddressId(owea.get(0).Id);                             
        emailMsg.setToAddresses(new String[]{email});
        emailMsg.saveAsActivity = false;
        emailMsg.setHtmlBody(htmlBody);
        emailMsg.setSubject('Signup & Privacy Portal');
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailMsg});
    }

    public static void sendAccessEmailUnknown(String email, String link){
        String htmlBody = '<html>'+
                '<body>'+
                    headerHtml()+
                    '<p style="margin: 30px 0">Thank you for your interest in IATA.<br/>'+ 
                    'Please <a href="'+link+'">follow this link</a> to access our Signup & Privacy portal.<br/><br/>'+
                    'All the best,<br/>'+
                    'The IATA Team</p>'+
                    footerHtml()+
                '</body>'+
            '</html>';   
        sendEmail(email, htmlBody);
    }

    public static void sendAccessEmail(String email, String link){
        String htmlBody = '<html>'+
                '<body>'+
                    headerHtml()+
                    '<p style="margin: 30px 0">Thank you for your interest in IATA.<br/>'+ 
                    'Please <a href="'+link+'">follow this link</a> to access our Signup & Privacy portal.<br/><br/>'+
                    'All the best,<br/>'+
                    'The IATA Team</p>'+
                    footerHtml()+
                '</body>'+
            '</html>';  

        sendEmail(email, htmlBody);
    }

    // CR3: Merge 2 emails into 1 (a new version)
    public static void sendAccessEmailNewVersion(String email, String link){
        String htmlBody = '<html>'+
                            '<body>'+
                                headerHtml()+
                                '<p style="margin: 30px 0">Welcome to IATA<br/><br/>'+
                                'Thank you for registering to the IATA Signup & Privacy Portal.<br/><br/>'+
                                'Please click on the following <a href="'+link+'">link</a> to access the Portal.<br/><br/>'+
                                'Best regards,<br/>'+
                                'IATA Team</p>'+
                                footerHtml()+
                            '</body>'+
                            '</html>';  

        sendEmail(email, htmlBody);
    }

    public static void sendWelcomeEmail(String email){
        String htmlBody = '<html>'+
                            '<body>'+
                                headerHtml()+
                                '<p style="margin: 30px 0">Welcome to IATA<br/><br/>'+ 
                                'Thank you for registering to the IATA Signup & Privacy Portal, your one place to:<br/>'+
                                '- Manage Your Profile;<br/>'+
                                '- Manage Your Subscriptions (newsletters, products and services);<br/>'+
                                '- Manage Your Interests for Our Products & Services (events, training, publications);<br/><br/>'+
                                'Best regards,<br/>'+
                                'IATA Team</p>'+
                                    footerHtml()+
                            '</body>'+
                            '</html>';  
        sendEmail(email, htmlBody);
    }

    public static void sendSubscriptionModificationEmail(String email, Boolean optout){
        String htmlBody = '<html>'+
                            '<body>'+
                                headerHtml()+
                                '<p style="margin: 30px 0">Dear user,<br/><br/>'+ 
                                'We confirm that your modifications of your subscriptions and interests have been taken into account.<br/><br/>';
                                if(optout) {
                                    htmlBody += 'You decided to unsubsribe from all IATA communication. You will no longer receive any email from our service.<br/><br/>';
                                }
                                htmlBody +='Best regards,<br/>'+
                                'IATA Team</p>'+
                                footerHtml()+
                            '</body>'+
                            '</html>';  

        sendEmail(email, htmlBody);
    }

    private static String generateToken(String sObjectId){

        Integer randomNumber = Integer.valueOf(Math.floor(Math.random()*100));
        Integer randomCharPointer = Integer.valueOf(Math.floor(Math.random()*50));
        String randomString = String.valueOf(randomNumber)+characters.subString(randomCharPointer, randomCharPointer+1);
        
        return sObjectId+'-'+randomString;
    }


    public static Individual findIndividual(String identifier){
        String whereClause;
        
        try{
            whereClause = 'Id = '+'\''+Id.valueOf(identifier)+'\'';
        }catch(System.StringException e){
            //not an id, it must be a string (we use a try catch because other ways of checking for id are more complicated)
            whereClause = 'Email__c = '+'\''+identifier+'\'';
        }
            
        List<Individual> il = Database.query('SELECT ID, Token__c, Timestamp__c FROM INDIVIDUAL WHERE ' + whereClause);

        return il.isEmpty() ? null : il[0];
    }


    public static String updateEncryptEmailProcessWithLink(Individual ind, String email){
        String individualId = String.valueOf(ind.Id);
        String token = generateToken(individualId);
        ind.Token__c = token;
        ind.Timestamp__c = String.valueOf(System.now().getTime());
        
        //Update Individual
        update ind;                            
        
        //Encrypt token
        String encryptedToken = Comm_User_Helper.EncryptString(token);
        String encryptedId = Comm_User_Helper.EncryptString(individualId);
        
        //Send Email
        String link = Site.getBaseURL()+'/s/guest?token='+encryptedToken+'&indId='+encryptedId;
        sendAccessEmailNewVersion(email, link);  
        
        return link;                   
     }

    @AuraEnabled
    public static String retrieveUserInfo(String individualId, Boolean isGuest) {
        UserInfoWrapper uiw = new UserInfoWrapper();

        if(isGuest) {
            // Decrypt token to get individual Id in clear
            individualId = Comm_User_Helper.DecryptString(individualId);
            uiw.individualId = individualId;
        }

        if(String.isBlank(individualId)) {
            User registreredUser = [SELECT  Contact.IndividualId, Contact.LastName, Contact.FirstName, Contact.email FROM User WHERE Id =: UserInfo.getUserId() limit 1];
            // Create indivudal if not exist for existing contact
            if(registreredUser.Contact.IndividualId == null) {
                Individual ind = createIndividual(registreredUser.Contact.firstName, registreredUser.Contact.lastName, registreredUser.Contact.email);
                individualId = ind.id;
            } else 
                individualId = registreredUser.Contact.IndividualId;
            
            uiw.individualId = individualId;
        }
        list<Individual> indivs = [SELECT id, FirstName, LastName, Salutation, Country__c, Company__c, Job_Title__c, Phone__c, Industry__c, Email__c FROM Individual WHERE Id =: individualId];
        Individual indiv = ! indivs.isEmpty() ? indivs[0] : null;

        if(indiv != null) {
            // Retrieve from Pardot based on email
            Pardot_API.Pardot_Prospect prospect = new Pardot_API.Pardot_Prospect();
            prospect = Pardot_API.getProspect(indivs[0].email__c);
            if(prospect != null) {
                indiv = prospectToIndividual(indiv, prospect);
                uiw.prospectId = prospect.Id;
                uiw.subscriptions = prospect.list_subscription;
                uiw.salesforceId = prospect.salesforceId;
            } 
            // Return individual informatino if Pardot is down or no prospect found
        }
        uiw.individual = indiv;
        
        return JSON.serialize(uiw);
    }

    private static Individual prospectToIndividual(Individual indiv, Pardot_API.Pardot_Prospect prospect) {
        if(prospect == null) return null;

        //indiv.Name = prospect.last_name; // not writable
        indiv.Email__c = prospect.email;
        indiv.FirstName = prospect.first_name;
        indiv.LastName = prospect.last_name;
        indiv.Salutation = prospect.salutation;
        indiv.Company__c = prospect.company;
        indiv.Job_Title__c = prospect.job_title;
        indiv.Phone__c = prospect.phone;
        indiv.Country__c = prospect.country;
        indiv.Industry__c = prospect.industry;

        return indiv;
    }

    public class UserInfoWrapper {
        @AuraEnabled
        public Individual individual {get;set;} 
        @AuraEnabled
        public String individualId {get;set;} 
        @AuraEnabled
        public String prospectId {get;set;}
        @AuraEnabled
        public String salesforceId {get;set;} 
        @AuraEnabled
        public list<Pardot_API.List_Subscription> subscriptions {get;set;} 
        @AuraEnabled
        public String interests {get;set;} 
    
    }
}