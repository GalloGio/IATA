public class GDPR_ContactHandler {

    public List<contact> triggerNew = (List<contact>) Trigger.new;
    public List<contact> triggerOld = (List<contact>) Trigger.old;

    public Map<Id, contact> newMap = (Map<Id,contact>) Trigger.newMap;
    public Map<Id, contact> oldMap = (Map<Id,contact>) Trigger.oldMap;

    /*** Before Insert ***/
    public void onBeforeInsert(){
        
        List<contact> newcontacts = triggerNew;

        Integer numOfcontacts = newcontacts.size();
        
        List<String> contactsEmails = new List<String>();
        List<Individual> il = new List<Individual>();
        Map<String, Contact> mapMailContact = new Map<String, Contact>();

        for (contact c : newcontacts){
            contactsEmails.add(c.Email);
            mapMailContact.put(c.Email, c);
        }

        try{
            il = [SELECT ID, Email__c FROM Individual WHERE Email__c IN :contactsEmails];
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
        Integer numOfIndivs = il.size();
        
        //If at least one contact has an individual with a similar email on contact        
        if(numOfIndivs>0){

            attachIndividualToContactHelper(il, newcontacts);    
        }

        System.debug('Map Mail Contact -> '+mapMailContact);
        List<String> uniqueEmails = new List<String>(new Set<String>(contactsEmails));
		Integer numOfUniqueEmails = uniqueEmails.size();
        //If there are more contacts being inserted than individuals in the system. Some individuals have to be created and attached to the contacts 
        if((numOfUniqueEmails - numOfIndivs) > 0){

            List<Individual> individualsToCreate = new List<Individual>();

            for(String s : uniqueEmails){
                
                if(mapMailContact.containsKey(s)){
                
                    //TODO review if these are the only fields needed
                    Contact c = mapMailContact.get(s);
                    individualsToCreate.add(new Individual(FirstName = c.FirstName, LastName = c.LastName, Salutation = c.Salutation,  Email__c = c.Email, Area_of_Interest__c = c.Pardot_Area_of_Interest__c));                
                }
            }

            try{
                INSERT individualsToCreate;
            }catch(Exception e){
                System.debug(e.getMessage());
            }
            
            attachIndividualToContactHelper(individualsToCreate, newcontacts);
        }
              
    }

    /*** Before Update ***/
    public void onBeforeUpdate(){
        
        List<contact>  oldcontacts = triggerOld;
        List<contact>  newcontacts = triggerNew;
        Map<Id, contact> newcontactMap = newMap;
        Map<Id, contact> oldcontactMap = oldMap;
        
        
        Map<String, contact> mapEmailcontact = new Map<String, contact>();

        List<Individual> individualsToUpdate = new List<Individual>();
        List<Individual> individualsToCreate = new List<Individual>();
        List<String> individualsToUpdateEmails = new List<String>();

        //Map the emails with the contacts looping on oldcontacts because the change field could be Email itself
        for(contact l : oldcontacts){
            mapEmailcontact.put(l.Email.toLowerCase(), l);
        }
   
        List<String> individualsToSearchByEmail = new List<String>(mapEmailcontact.keySet());
        
        
        //Search for existing Individuals, by Email
        for(Individual i : [SELECT Id, FirstName, LastName, Salutation, Email__c, Area_of_Interest__c, job_title__c, phone__c, company__c, country__c, industry__c FROM Individual WHERE Email__c IN :individualsToSearchByEmail]){
                System.debug('[INDIVIDUAL] - '+i);
                //Get the respective contact with the new version of the object
                contact newcontact = newcontactMap.get(mapEmailcontact.get(i.Email__c.toLowerCase()).Id);

               
                    //Save the individual email before update
                    individualsToUpdateEmails.add(i.Email__c.toLowerCase());

                    //update the individual record with contact data
                    i.FirstName = newcontact.FirstName;
                    i.LastName = newcontact.LastName;
                    i.Salutation = newcontact.Salutation;
                    i.Email__c = newcontact.Email.toLowerCase();
                    i.Area_of_Interest__c = newcontact.Pardot_Area_of_Interest__c;
                     // extend missing mapping
                    i.job_title__c = newcontact.title;
                    i.phone__c = newcontact.phone;
                    list<Contact> aContact = [SELECT accountId, account.Name FROM Contact WHERE Id =: newcontact.id];
                    i.company__c = aContact.isEmpty() ? '' : aContact[0].accountId != null ? aContact[0].account.Name : '';
                    i.country__c = newcontact.mailingcountry;
                    //i.industry__c = newcontact.industry; // No industry field in contact in standard

                    individualsToUpdate.add(i);
                             
                      
        }
        
        System.debug('[INDIVIDUALS TO UPDATE] - '+individualsToUpdate);
        
        try{
            UPDATE individualsToUpdate;
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        if(individualsToUpdate.size()>0){
            attachIndividualTocontactHelper(individualsToUpdate, newcontacts);
        }
        
        for(contact oldcontact : oldcontacts){
        
            System.debug('oldcontactEmail --- '+oldcontact.Email);
        
            contact newcontact = newcontactMap.get(oldcontact.Id);

            if(!individualsToUpdateEmails.contains(oldcontact.Email) && newcontact.IndividualId == null ){

                contact l = newcontactMap.get(oldcontact.Id);
                
                individualsToCreate.add(new Individual(FirstName = l.FirstName, LastName = l.LastName, Salutation = l.Salutation,  Email__c = l.Email, Area_of_Interest__c=l.Pardot_Area_of_Interest__c));
            
            }
        }

       
        try{

            INSERT individualsToCreate;
        
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        if(individualsToCreate.size()>0){
            attachIndividualToContactHelper(individualsToCreate, newcontacts);    
        }
        
    }


    /*** After Delete ***/
    public void onAfterDelete(){
        
        List<contact>  oldcontacts = triggerOld;        
        
        Map<Id, contact> oldcontactMap = oldMap;
    
        Map<Id, contact> mapIdIndividual = new Map<Id, contact>(); 
        
        List<Id> potentialDeleteInd = new List<Id>();
        
        for(Contact oc : oldcontacts){
            
            mapIdIndividual.put(oc.IndividualId, oc);

        }

        List<Id> individualsIds = new List<Id>(mapIdIndividual.keySet());

        List<Individual> inds = [SELECT ID, (SELECT Id FROM Contacts), (Select Id FROM Leads) FROM Individual WHERE Id IN :individualsIds];

        for(Individual ind : inds){

            if(ind.Contacts.size() == 0 && ind.contacts.size() == 0){
            
                potentialDeleteInd.add(ind.Id);
            
            }
        }

        List<User> usersWithInd = [SELECT ID, IndividualId FROM User WHERE IndividualId in :potentialDeleteInd];

        for(User u : usersWithInd){
            
            mapIdIndividual.remove(u.IndividualId);
     
        }
        List<Id> individualsToDeleteIds = new List<Id>(mapIdIndividual.keySet());
        List<Individual> individualsToDelete = [SELECT ID FROM Individual WHERE Id in :individualsToDeleteIds];
        Database.DeleteResult[] results = new List<Database.DeleteResult>();
        if(individualsToDelete.size()>0){
            results = Database.delete(individualsToDeleteIds, false);
        }
        

        System.debug('DeleteResult - '+results);

    }

    private void attachIndividualToContactHelper(List<Individual> il, List<contact> newContacts){

     
        for(Individual i : il){
            
            for (Contact c : newContacts){
                
                //If the email on the individual equals the email on the contact and there is no individual associated with the contact
                if( (i.Email__c == c.Email) && (c.IndividualId==null) ){
                        
                    //Attach the individual to the contact
                    c.IndividualId = i.Id; 
                }           
            }        
        }
    } 

}