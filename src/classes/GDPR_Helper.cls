public without sharing class GDPR_Helper {

    private static final String characters = 'ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmonpqrstuvwxyz';
    public enum UserType{USER, CONTACT, LEAD, NONE, FORBID}

    public static Boolean isDisposalEmail(String email){      
        // Check if email domain is in the black list (disposal email)
        String domain =  email.split('@')[1];
        return [select count() from Fobidden_Disposal_Email_Domain__mdt where Domain_Name__c =: domain ] > 0;
    }

    public static UserType doUserExists(String email){      
        
        List<User> searchUsers = new List<User>();
        List<Contact> searchContacts = new List<Contact>();
        List<Lead> searchLeads = new List<Lead>();
        // Check if email is fobidden first
        if(GDPR_Helper.isDisposalEmail(email))
            return UserType.FORBID;

        try{
            searchUsers = [SELECT ID FROM USER WHERE Email = :email ORDER BY LastModifiedDate];        
            System.debug('[SEARCH USERS] - '+searchUsers);
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
        
        Integer users = searchUsers.size();
        
        /***IF THERE ARE USERS***/
        if(users > 0){
            
            //Send Email
            // Link to oneId with redirection to GDPR Portal
            String link = Label.OneId_URL_To_GDPR;
            sendAccessEmail(email, link);
            
            return UserType.USER;
        
        }else{
            
            searchContacts = searchContactsHelper(email);

            Integer contacts = searchContacts.size();

        /***IF THERE ARE NO USERS AND THERE ARE CONTACTS***/
            if(contacts > 0){

                Contact c = searchContacts[0];           
                
                //If already exists an Individual associated with the Contact.

                if(c.IndividualId!=null){
                    String individualId = String.valueOf(c.IndividualId);
                    
                    //Fetch the Individual record
                    Individual ind = doIndividualExists(null, individualId);
                    
                    updateEncryptEmailProcess(ind, email);
                    
                    return UserType.CONTACT;

                //If there is NO Individual associated with the Contact.
                }else{

                    //Search for the existance of an Individual with the same email
                    Individual ind = doIndividualExists(email, null);
                    
                    //If already exists an Individual that has the inserted email.
                    if(ind!=null){
                        
                        //Associate this Individual with the contact.
                        c.IndividualId = ind.Id;
                    
                        //Update the contact.
                        contactUpdateHelper(c);
                        
                        updateEncryptEmailProcess(ind, email);
                        
                        return UserType.CONTACT;
                    
                    //If there is NO Individual associated with the contact and there is NO Individual that has the inserted email
                    }else{
                        
                        //Create new Individual                        
                        ind = createIndividual(c.firstName, c.lastName, email);

                        //Associate this Individual with the contact.
                        c.IndividualId = ind.Id;
                        
                        //Update the contact.
                        contactUpdateHelper(c);
                        
                        updateEncryptEmailProcess(ind, email);
                        
                        return UserType.CONTACT;
                    
                    }                    
                }

            /*IF THERE IS NO CONTACTS WITH THE INTRODUCED EMAIL -> REPEAT THE PROCESS FOR LEADS */
            
            }else{
                
                searchLeads = searchLeadsHelper(email);

                Integer leads = searchLeads.size();
                
                /***IF THERE ARE NO USERS AND THERE ARE CONTACTS***/
                if(leads>0){

                    Lead l = searchLeads[0];
                    
                    //If already exists an Individual associated with the Lead.
                    if(l.IndividualId!=null){
                        
                        String individualId = String.valueOf(l.IndividualId);

                        //Fetch the Individual record
                        Individual ind = doIndividualExists(null, individualId);
                        
                        updateEncryptEmailProcess(ind, email);
                        
                        return UserType.LEAD;

                    //If there is NO Individual associated with the Contact.
                    }else{
                        //Search for the existance of an Individual with the same email
                        Individual ind = doIndividualExists(email, null);

                        //If already exists an Individual that has the inserted email.
                        if(ind!=null){

                            //Associate this Individual with the lead.
                            l.IndividualId = ind.Id;  
                            
                            //Update the lead.
                            leadUpdateHelper(l);
                            
                            updateEncryptEmailProcess(ind, email);
                            
                            return UserType.LEAD;

                        //If there is NO Individual associated with the lead and there is NO Individual that has the inserted email
                        }else{
                            
                            //Create new Individual
                            ind = createIndividual(l.firstName, l.lastName, email);
                            
                            //Associate this Individual with the lead.
                            l.IndividualId = ind.Id;

                            //Update the lead.
                            leadUpdateHelper(l);

                            updateEncryptEmailProcess(ind, email);
                            
                            return UserType.LEAD;
                        }
                    }
            
                }else{
                
                    //Send an email to the entered email that redirects to a web to lead form

                    String token = String.valueOf(System.TODAY()).left(10)+email.toLowerCase(); //Ex: 2018.12.24myemail@gmail.com
                    String encryptedToken = Comm_User_Helper.EncryptString(token);
                    String link = Label.IATA_GDPR_URL+'/s/guest-information?token='+encryptedToken;
                    system.debug('link'+link);
                    sendAccessEmailUnknown(email, link);
                    
                    return UserType.NONE;
                }                                 
            }
        }
    }
    public static Individual createIndividual(String firstName, String lastName, String email){
        Individual indiv = new Individual(FirstName = firstName, LastName = lastName, Email__c = email);
        
        try{
            INSERT indiv;
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
        return indiv;
    }

    public static void createLead(String firstName, String lastName, String email, String company){
        // Create lead. Lead trigger will attach the individual record. The connector will sync the prospect (SF=>Pardot)
        Lead lead = new Lead(FirstName = firstName, LastName = lastName, Email = email, company = company);
        try{
            INSERT lead;
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
    }

    

     public static String headerHtml() {
        String str = '<div style="background-color: #1E32FA; margin-bottom: 30px; font-family: Arial, Helvetica, sans-serif;">'+
        '<table style="color:white; font-size: 23px;font-weight: 600;">'+
            '<tr>'+
            '<td><img style="width:100px;max-width:100%;height:auto; padding: 20px;" src="'+Label.IATA_GDPR_White_Logo+'" </td>'+
            '<td>Signup &amp; Privacy Portal </td>'+
            '</tr>'+
        '</table>'+
        '</div>';
        return str;
    }

    public static String footerHtml() {
       String str = '<div style="background-color: #535151; margin-top: 30px; font-family: Arial, Helvetica, sans-serif;">'+
        '<table style="color:white; font-size: 1.5em;">'+
            '<tr>'+
            '<td><img style="width:100px;max-width:100%;height:auto; padding: 20px;" src="'+Label.IATA_GDPR_White_Logo+'" </td>'+
            '<td>Our mission is to represent, lead and serve the airline industry</td>'+
            '</tr>'+
        '</table>'+
        '</div>';
        return str;
    }

    public static void sendEmail(String email, String htmlBody) {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'IATA Noreply'];
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setOrgWideEmailAddressId(owea.get(0).Id); 	                            
        emailMsg.setToAddresses(new String[]{email});
        emailMsg.saveAsActivity = false;
        emailMsg.setHtmlBody(htmlBody);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailMsg});
    }

    public static void sendAccessEmailUnknown(String email, String link){
        String htmlBody = '<html>'+
                            '<body>'+
                                headerHtml()+
                                'Dear user,<br/><br/>'+ 
                                'Please click on the following <a href="'+link+'">link</a> to complete your Portal registration.<br/><br/>'+
                                'Best regards,<br/>'+
                                'IATA Team'+
                                    footerHtml()+
                            '</body>'+
                            '</html>';  
        sendEmail(email, htmlBody);
    }

    public static void sendAccessEmail(String email, String link){
        String htmlBody = '<html>'+
                            '<body>'+
                                headerHtml()+
                                'Dear user,<br/><br/>'+ 
                                'Please click on the following <a href="'+link+'">link</a> to access the Portal.<br/><br/>'+
                                'Best regards,<br/>'+
                                'IATA Team'+
                                footerHtml()+
                            '</body>'+
                            '</html>';  

         sendEmail(email, htmlBody);
    }

    public static void sendWelcomeEmail(String email){
        String htmlBody = '<html>'+
                            '<body>'+
                                headerHtml()+
                                'Welcome to IATA<br/><br/>'+ 
                                'Thank you for registering to the IATA Signup & Privacy Portal, your one place to:<br/>'+
                                '- Manage Your Profile;<br/>'+
                                '- Manage Your Subscriptions (newsletters, products and services);<br/>'+
                                '- Manage Your Interests for Our Products & Services (events, training, publications);<br/>'+
                                '- Exercise Your Privacy Rights (access, modify, and object).<br/><br/>'+
                                'Best regards,<br/>'+
                                'IATA Team'+
                                    footerHtml()+
                            '</body>'+
                            '</html>';  
        sendEmail(email, htmlBody);
    }

    public static void sendSubscriptionModificationEmail(String email, Boolean optout){
        String htmlBody = '<html>'+
                            '<body>'+
                                headerHtml()+
                                'Dear user,<br/><br/>'+ 
                                'We confirm that your modifications of your subscriptions and interests have been taken into account.<br/><br/>';
                                if(optout) {
                                    htmlBody += 'You decided to unsubsribe from all IATA communication. You will no longer receive any email from our service.<br/><br/>';
                                }
                                htmlBody +='Best regards,<br/>'+
                                'IATA Team'+
                                footerHtml()+
                            '</body>'+
                            '</html>';  

         sendEmail(email, htmlBody);
    }

    public static void controlGDPRAccess(String link){

    }
    private static String generateToken(String sObjectId){
        String token = sObjectId+'-'+generateTokenHelper();

        return token;
    }
    private static String generateTokenHelper(){    

        Integer randomNumber = Integer.valueOf(Math.floor(Math.random()*100));
        Integer randomCharPointer = Integer.valueOf(Math.floor(Math.random()*50));
        String randomString = String.valueOf(randomNumber)+characters.subString(randomCharPointer, randomCharPointer+1);
        
        return randomString;
    }

    private static List<Contact> searchContactsHelper(String email){
        List<Contact> searchContacts = new List<Contact>();
        try{
            searchContacts = [SELECT ID, LastName, FirstName, IndividualId FROM CONTACT WHERE Email = :email ORDER BY LastModifiedDate];        
            System.debug('[SEARCH CONTACTS] - '+searchContacts);
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
        return searchContacts;
    }

    private static List<Lead> searchLeadsHelper(String email){
        List<Lead> searchLeads = new List<Lead>();
        try{
            searchLeads = [SELECT ID, LastName, FirstName, IndividualId FROM LEAD WHERE Email = :email ORDER BY LastModifiedDate];
            System.debug('[SEARCH LEADS] - '+searchLeads);
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }        
        return searchLeads;   
    }

    public static Individual doIndividualExists(String email, String indId){
        List<Individual> il = new List<Individual>();
        
        String searchString = 'SELECT ID, Token__c, Timestamp__c FROM INDIVIDUAL WHERE ';
        
        if(email!=null){
            searchString+='Email__c = '+'\''+email+'\'';
        }else{
            searchString+='Id = '+'\''+indId+'\'';
        }
            
        try{
            il = Database.query(searchstring);
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
        System.debug('[INDIVIDUAL] - '+il.size());

        return (il.size()>0)?il[0]:null;
    }

    private static void contactUpdateHelper(Contact c){
        try{
            UPDATE c;
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
    }

    private static void leadUpdateHelper(Lead l){
        try{
            UPDATE l;
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
    }

    private static void individualUpdateHelper(Individual ind){         
        try{
            UPDATE ind;
        }catch(Exception e){
            System.debug('[GDPR_HELPER] - '+e.getStackTraceString());
        }
    }
    
    public static void updateEncryptEmailProcess(Individual ind, String email){
        updateEncryptEmailProcessWithLink(ind, email);
    }

    public static String updateEncryptEmailProcessWithLink(Individual ind, String email){
        String individualId = String.valueOf(ind.Id);
        String token = generateToken(individualId);
        ind.Token__c = token;
        ind.Timestamp__c = String.valueOf(System.now().getTime());
        
        //Update Individual
        individualUpdateHelper(ind);                            
        
        //Encrypt token
        String encryptedToken = Comm_User_Helper.EncryptString(token);
        String encryptedId = Comm_User_Helper.EncryptString(individualId);
        
        //Send Email
        String link = Label.IATA_GDPR_URL+'/s/guest?token='+encryptedToken+'&indId='+encryptedId;
        sendAccessEmail(email, link);  
        
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
		Individual indiv = new Individual();
		list<Individual> indivs = [SELECT id, FirstName, LastName, Salutation, Country__c, Company__c, Job_Title__c, Phone__c, Industry__c, Email__c FROM Individual WHERE Id =: individualId];
		indiv = ! indivs.isEmpty() ? indivs[0] : null;

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