global with sharing class ProvisionKaviAccess {

    //In this class we will provide all the functionality needed to provision existing internal user with Identity License with Kavi Access
    //For that, we will create first an associated account(only the first time) and also an associated contact
    //Then, we will call the newAppsRequest method from  ISSP_AvailableServices class to create a new record of Portal_Application_Rights object
    //Then, a trigger will be launched automatically and will call the ISSP_WS_KAVI web service that will provision in Kavi that User/Contact

    webservice static String EnableInternalUserKaviAccess (String userId, String profileName, Boolean isKaviInternalUser)
   
   {
       //First of all, we check if current User has "KaviProvisioningUser" profile
       //If NOT.. We Abort the process
       //If YES, we check if exists a contact with the same Email Address
       //If not, we will associate the current user with a new Contact assigning the user info details (firstname, lastname, email address,etc.)
       //We will associate this new Contact with the current user thru the custom lookup(user) relationship
       //When contact is created, the contact trigger (ISSP_UpdateContactKaviIdOnUser) will be launched and the ContactKavId on User will be updated.
       //
       //
       //if (profileName == 'KaviProvisioningUser'){
        if (isKaviInternalUser){
               
          String contactId = createContact(userId);
          System.debug('@@@ contactId: '+contactId);
           //System.debug('This is the ContactID returned:' + contactId);
           if (contactId != null){
             //Once the contact has been created, we need to create the PortalApplciationRight record...
             return createPortalApplicationRightMethod(contactId);  
            }
            else {
               return null;
            } 
       }
       
       else 
       {
           String result = 'We abort the process of provisioning because this user is not defined as an Internal Kavi User';
           System.debug(result);
           return result;
       }
   }
    
    
    public static String createContact (string userId) {
        
        //Creation of Contact...
        Account acc = new Account();
		    acc = getFakeAccount();     
        User usr = [Select Id, FirstName, LastName,Profile_Name__c, Email From User Where id = :userId limit 1][0];
        if(usr.Id != null){
                Contact contact = new Contact();
                contact.FirstName = usr.FirstName;
                contact.LastName = usr.LastName;
                contact.AccountId = acc.Id;
                contact.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
                contact.Email = usr.Email;
                contact.Status__c = 'Active';
            	   //We associate the new Contact with the user thru the lookup(User) field
            	   contact.Kavi_User__c= usr.Id;
                //We insert the new Contact using DML sentence
        		try{ insert contact;} catch(DmlException e){System.debug('Error when inserting the new contact ...: ' + e);}
                return contact.Id;
        }
        else return null;
        
    }
        public static Account getFakeAccount (){
        
        
        list<Account> acc2 = [Select Id from Account Where Name= 'IATA SSW ACCOUNT'];
        if (! acc2.isEmpty())       
            return acc2[0];
        else 
        {
          Account acc = new Account();
            acc = new Account();
            acc.Name = 'IATA SSW ACCOUNT';
            acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
            //acc.Sector__c = 'IATA';
            //acc.Category__c = 'IATA Cargo Agent';
            try {insert acc;}
            
            catch(Exception e) {System.debug('Account has not been created becasu wrong: ' + e);}
            return acc;
        }
     }
    
   public static String createPortalApplicationRightMethod(String contactId) {
           //check if this is returning something      
       Portal_Applications__c portalApp = [SELECT Id From Portal_Applications__c WHERE Name = 'Standards Setting Workspace' LIMIT 1][0];
       
       return ISSP_AvailableServices.newAppsRequest(portalApp.Id, 'Standards Setting Workspace', contactId);
       
}
    
}