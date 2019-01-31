public class SkillAssignmentController {

    public final Agents__c agent;
    public Skill_Types__c[] skillTypes;
    public Set<Id> skills = new Set<Id>();
    public Skill__c[] sourceSkills;
    List<Skill_Assignment__c> agSkills = new List<Skill_Assignment__c>();
    
    public SkillAssignmentMetadata__c[] metadataRows {get; private set;}
    
    //*****************
    // Controller
    //***************** 
    public SkillAssignmentController() 
    {
        this.agent = [select Id, Name, region__c from Agents__c where Id = :ApexPages.currentPage().getParameters().get('aid') limit 1];
        this.metadataRows = new List<SkillAssignmentMetadata__c>();
        
        for (Skill_Assignment__c curagent : [Select s.Skills__c, Skills__r.Auto_queue__r.Name, Skills__r.Skill_Types__r.Name, s.Id, s.Skills__r.Name, s.SystemModstamp, s.Priority__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.CurrencyIsoCode, s.CreatedDate, s.CreatedById, s.Agents__c From Skill_Assignment__c s where s.Agents__c = :this.agent.Id and Skills__r.Auto_queue__r.Region__c =: this.agent.Region__c]) {
            skills.add(curagent.Skills__c);
            this.metadataRows.add(new SkillAssignmentMetadata__c(Skill_Assignment__c = curagent.Id, Skill__c = curagent.Skills__c, Name=curagent.Skills__r.Auto_queue__r.Name, Skill_Type__c=curagent.Skills__r.Skill_Types__c, Skill_Type_Name__c = curagent.Skills__r.Skill_Types__r.Name,  Priority__c = curagent.Priority__c));
        }
        
        this.sourceSkills = [Select s.Id, s.SystemModstamp, s.Skill_Types__c, s.Skill_Types__r.Name, Auto_queue__r.Name, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.CurrencyIsoCode, s.CreatedDate, s.CreatedById From Skill__c s where Auto_queue__r.Region__c =: this.agent.Region__c];
        for (Skill__c cur : sourceSkills) {
            // work out which skills already exist in the agent skills, and insert ones that are missing
            if (!skills.contains(cur.Id)) {
                this.metadataRows.add(new SkillAssignmentMetadata__c(Skill__c = cur.Id, Skill_Type_Name__c = cur.Auto_queue__r.Name,Name=cur.Name, Skill_Type__c=cur.Skill_Types__c, Priority__c='0'));
            }
        }   
    }
            
    //*****************
    // GETTERS
    //*****************
    public Agents__c getAgent() {
        return this.agent;
    }
    
    public List<SelectOption> getPriorities() 
    {
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry entry : Schema.SObjectType.SkillAssignmentMetadata__c.fields.Priority__c.getPicklistValues()) {
            options.add(new SelectOption(entry.value, entry.value));
        }
        return options;           
    }
    
    public Skill_Types__c[] getSkillTypes() 
    {
        List<Skill_Types__c> skType = [Select Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.CurrencyIsoCode, s.CreatedDate, s.CreatedById From Skill_Types__c s where region__c =: this.agent.Region__c Order by Name];
        return skType;
    }
    
    //*****************
    // SAVE METHOD
    //*****************
    public PageReference save() 
    {
        system.debug('DEBBUG====>SAVE');
        List<Skill_Assignment__c> Skills = new List<Skill_Assignment__c>();
        for (SkillAssignmentMetadata__c metadata : this.metadataRows) 
        {
            system.debug('DEBBUG====>metadata : '+metadata);
            if (metadata.Skill_Assignment__c != null) {
                Skills.add(new Skill_Assignment__c(Id=metadata.Skill_Assignment__c, Skills__c = metadata.Skill__c, Priority__c = metadata.Priority__c, Agents__c = this.agent.Id));
            }
            else {
                Skills.add(new Skill_Assignment__c(Skills__c = metadata.Skill__c, Priority__c = metadata.Priority__c, Agents__c = this.agent.Id));
            }
        }
        upsert Skills;
        return null;
    }

}