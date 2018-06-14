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
    //***************************************************************
    // T.E.S.T M.E.T.H.O.D.S
    //***************************************************************
    static testmethod void testSomeSkills() 
    {
        // Create agent
        Agents__c agent = new Agents__c(Region__c='Africa & Middle East',Name='Test User', User__c=UserInfo.getUserId());
        insert agent;
        
        // Set some skills
        Skill_Types__c type1 = new Skill_Types__c(Region__c='Africa & Middle East',Skill_Weight__c=1,Name='Type1', Case_Location__c='Field1');
        Skill_Types__c type2 = new Skill_Types__c(Region__c='Africa & Middle East',Skill_Weight__c=1,Name='Type2', Case_Location__c='Field2');
        Skill_Types__c type3 = new Skill_Types__c(Region__c='Africa & Middle East',Skill_Weight__c=1,Name='Type3', Case_Location__c='Field3');
        insert type1;
        insert type2;
        insert type3;
        
        Skill__c skill1 = new Skill__c(Name='Skill1', Skill_Types__c =type1.id);
        Skill__c skill2 = new Skill__c(Name='Skill2', Skill_Types__c =type2.id);
        Skill__c skill3 = new Skill__c(Name='Skill3', Skill_Types__c =type3.id);
        insert skill1;
        insert skill2;
        insert skill3;
        
        Skill_Assignment__c assignment1 = new Skill_Assignment__c(Agents__c=agent.Id, Priority__c='1.0', Skills__c=skill1.id);
        Skill_Assignment__c assignment2 = new Skill_Assignment__c(Agents__c=agent.Id, Priority__c='2.0', Skills__c=skill2.id);
        Skill_Assignment__c assignment3 = new Skill_Assignment__c(Agents__c=agent.Id, Priority__c='3.0', Skills__c=skill3.id);
        insert assignment1;
        insert assignment2;
        insert assignment3;     
        
        PageReference ref = new PageReference(Page.Skill_Assignment_by_Agent.getUrl() + '?aid=' + agent.Id);
        Test.setCurrentPage(ref);
        SkillAssignmentController con = new SkillAssignmentController();
        
        // assert if getAgent method in the controller retrives the agent whose Id is passed on the Page as a URL parameter
        system.assertEquals(agent.Id,con.getAgent().Id);
                
        system.assertNotEquals(null, con.getPriorities());
        
        // skill assignment before save for the agent 
        System.assertEquals([Select count() From Skill_Assignment__c  where Agents__c = :agent.Id and (Skills__c = :skill1.id or Skills__c =: skill2.Id or Skills__c =: skill3.Id)], 3);
        
        con.save();
        
        // skill assignment after save for the agent 
        System.assertEquals([Select count() From Skill_Assignment__c  where Agents__c = :agent.Id and (Skills__c = :skill1.id or Skills__c =: skill2.Id or Skills__c =: skill3.Id)], 3);
        
        
    }
    static testmethod void testNoSkills() {
        // Create agent
        Agents__c agent = new Agents__c(Name='Test User', User__c=UserInfo.getUserId());
        insert agent;
        
        // Set some skills
        Skill_Types__c type1 = new Skill_Types__c(Skill_Weight__c=1,Name='Type1', Case_Location__c='Field1');
        Skill_Types__c type2 = new Skill_Types__c(Skill_Weight__c=1,Name='Type2', Case_Location__c='Field2');
        Skill_Types__c type3 = new Skill_Types__c(Skill_Weight__c=1,Name='Type3', Case_Location__c='Field3');
        insert type1;
        insert type2;
        insert type3;
        Skill__c skill1 = new Skill__c(Name='Skill1', Skill_Types__c =type1.id);
        Skill__c skill2 = new Skill__c(Name='Skill2', Skill_Types__c =type2.id);
        Skill__c skill3 = new Skill__c(Name='Skill3', Skill_Types__c =type3.id);
        insert skill1;
        insert skill2;
        insert skill3;
        
        PageReference ref = new PageReference(Page.Skill_Assignment_by_Agent.getUrl() + '?aid=' + agent.Id);
        Test.setCurrentPage(ref);
        SkillAssignmentController con = new SkillAssignmentController();
        con.getAgent();
        System.assert(con.getSkillTypes().size() >= 3);
                
        // skill assignment before save for the agent 
        System.assertEquals([Select count() From Skill_Assignment__c  where Agents__c = :agent.Id], 0);
        
        con.save();
        // skill assignment after save for the agent 
        System.assert([Select count() From Skill_Assignment__c  where Agents__c = :agent.Id and (Skills__c = :skill1.id or Skills__c = :skill2.Id or Skills__c = :skill3.Id)] == 3);
    }
    

}