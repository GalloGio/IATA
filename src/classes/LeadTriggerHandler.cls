public class LeadTriggerHandler {

    public List<Lead> triggerNew = (List<Lead>) Trigger.new;
    public List<Lead> triggerOld = (List<Lead>) Trigger.old;

    public Map<Id, Lead> newMap = (Map<Id,Lead>) Trigger.newMap;
    public Map<Id, Lead> oldMap = (Map<Id,Lead>) Trigger.oldMap;

    /*** Before Insert ***/
    public void onBeforeInsert(){
        
        List<Lead> newLeads = triggerNew;

        Integer numOfLeads = newLeads.size();
        
        List<String> leadsEmails = new List<String>();
        List<Individual> il = new List<Individual>();
        Map<String, Lead> mapMailLead = new Map<String, Lead>();

        for (Lead l : newLeads){
            leadsEmails.add(l.Email);
            mapMailLead.put(l.Email, l);
        }

        try{
            il = [SELECT ID, Email__c FROM Individual WHERE Email__c IN :leadsEmails];
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
        Integer numOfIndivs = il.size();
        
        //If at least one Lead has an individual with a similar email on lead        
        if(numOfIndivs>0){

            attachIndividualToLeadHelper(il, newLeads);    
        }
        
        System.debug('[MAIL AND LEAD MAP] -> '+mapMailLead);
        List<String> uniqueEmails = new List<String>(new Set<String>(leadsEmails));
		Integer numOfUniqueEmails = uniqueEmails.size();

        //If there are more leads being inserted than individuals in the system. Some individuals have to be created and attached to the leads 
        if((numOfUniqueEmails - numOfIndivs) > 0){

            List<Individual> individualsToCreate = new List<Individual>();

            for(String s : uniqueEmails){
                
                if(mapMailLead.containsKey(s)){
                //TODO review if these are the only fields needed
                Lead l = mapMailLead.get(s); 
                individualsToCreate.add(new Individual(FirstName = l.FirstName, LastName = l.LastName, Salutation = l.Salutation,  Email__c = l.Email, Area_of_Interest__c = l.Pardot_Area_of_Interest__c));                
                }
            }

            try{
                INSERT individualsToCreate;
            }catch(Exception e){
                System.debug(e.getMessage());
            }
            
            attachIndividualToLeadHelper(individualsToCreate, newLeads);
        }
              
    }

    /*** Before Update ***/
    public void onBeforeUpdate(){
        
        List<Lead>  oldLeads = triggerOld;
        List<Lead>  newLeads = triggerNew;
        Map<Id, Lead> newLeadMap = newMap;
        Map<Id, Lead> oldLeadMap = oldMap;
        
        
        Map<String, Lead> mapEmailLead = new Map<String, Lead>();

        List<Individual> individualsToUpdate = new List<Individual>();
        List<Individual> individualsToCreate = new List<Individual>();
        List<String> individualsToUpdateEmails = new List<String>();

        //Map the emails with the leads looping on oldLeads because the change field could be Email itself
        for(Lead l : oldLeads){
            String email = String.isBlank(l.Email) ? null : l.Email.toLowerCase();
            mapEmailLead.put(l.email, l);
        }
   
        List<String> individualsToSearchByEmail = new List<String>(mapEmailLead.keySet());
        
        
        //Search for existing Individuals, by Email
        for(Individual i : [SELECT Id, FirstName, LastName, Salutation, Email__c, Area_of_Interest__c, job_title__c, phone__c, company__c, country__c, industry__c, job_function__c, Department__c FROM Individual WHERE Email__c IN :individualsToSearchByEmail]){
                System.debug('[INDIVIDUAL] - '+i);
                //Get the respective Lead with the new version of the object
                String email = String.isBlank(i.Email__c) ? null : i.Email__c.toLowerCase();
                Lead newLead = newLeadMap.get(mapEmailLead.get(email).Id);

               
                    //Save the individual email before update
                    individualsToUpdateEmails.add(email);

                    //update the individual record with Lead data
                    i.FirstName = newLead.FirstName;
                    i.LastName = newLead.LastName;
                    i.Salutation = newLead.Salutation;
                    i.Email__c = email;
                    i.Area_of_Interest__c = newLead.Pardot_Area_of_Interest__c;
                    // extend missing mapping
                    i.job_title__c = newLead.title;
                    i.phone__c = newLead.phone;
                    i.company__c = newLead.company;
                    i.country__c = newLead.country;
                    i.industry__c = newLead.industry;
                    // Change request
                    i.job_function__c = newLead.Membership_Function__c;
                    i.Department__c = newLead.Department__c;

                    individualsToUpdate.add(i);
                             
                      
        }
        
        System.debug('[INDIVIDUALS TO UPDATE] - '+individualsToUpdate);
        
        try{
            UPDATE individualsToUpdate;
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        if(individualsToUpdate.size()>0){
            attachIndividualToLeadHelper(individualsToUpdate, newLeads);
        }
        
        for(Lead oldLead : oldLeads){
        
            System.debug('oldLeadEmail --- '+oldLead.Email);
        
            Lead newLead = newLeadMap.get(oldLead.Id);

            if(!individualsToUpdateEmails.contains(oldLead.Email) && newLead.IndividualId == null ){

                Lead l = newLeadMap.get(oldLead.Id);
                
                individualsToCreate.add(new Individual(FirstName = l.FirstName, LastName = l.LastName, Salutation = l.Salutation,  Email__c = l.Email, Area_of_Interest__c=l.Pardot_Area_of_Interest__c));
            
            }
        }

       
        try{

            INSERT individualsToCreate;
        
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        if(individualsToCreate.size()>0){
            attachIndividualToLeadHelper(individualsToCreate, newLeads);    
        }
        
    }


    /*** After Delete ***/
    public void onAfterDelete(){
        
        List<Lead>  oldLeads = triggerOld;        
        
        Map<Id, Lead> oldLeadMap = oldMap;
    
        Map<Id, Lead> mapIdIndividual = new Map<Id, Lead>(); 
        
        List<Id> potentialDeleteInd = new List<Id>();
        
        for(Lead ol : oldLeads){
            
            mapIdIndividual.put(ol.IndividualId, ol);

        }

        List<Id> individualsIds = new List<Id>(mapIdIndividual.keySet());

        List<Individual> inds = [SELECT ID, (SELECT Id FROM Contacts), (Select Id FROM Leads) FROM Individual WHERE Id IN :individualsIds];

        for(Individual ind : inds){

            if(ind.Contacts.size() == 0 && ind.Leads.size() == 0){
            
                potentialDeleteInd.add(ind.Id);
            
            }
        }

        List<User> usersWithInd = [SELECT ID, IndividualId FROM User WHERE IndividualId in :potentialDeleteInd];

        for(User u : usersWithInd){
            
            mapIdIndividual.remove(u.IndividualId);
     
        }
        List<Id> individualsToDeleteIds = new List<Id>(mapIdIndividual.keySet());
        List<Individual> individualsToDelete = [SELECT ID FROM Individual WHERE Id in :individualsToDeleteIds];

         if(! individualsToDelete.isEmpty()) Database.delete(individualsToDeleteIds, false);

    }

    private void attachIndividualToLeadHelper(List<Individual> il, List<Lead> newLeads){

     
        for(Individual i : il){
            
            for (Lead l : newLeads){
                
                //If the email on the individual equals the email on the lead and there is no individual associated with the lead
                if( (i.Email__c == l.Email) && (l.IndividualId==null) ){
                        
                    //Attach the individual to the lead
                    l.IndividualId = i.Id; 
                }           
            }        
        }
    } 
}