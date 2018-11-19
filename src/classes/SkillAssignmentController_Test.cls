@isTest
private class SkillAssignmentController_Test {

    static testmethod void testSomeSkills(){
    	
        // Create agent
        Agents__c agent = new Agents__c(Region__c='Africa & Middle East',Name='Test User', User__c=UserInfo.getUserId());
        insert agent;
        
        // Set some skills
        Skill_Types__c type1 = new Skill_Types__c(Region__c='Africa & Middle East',Skill_Weight__c=1,Name='Type1', Case_Location__c='Field1');
        Skill_Types__c type2 = new Skill_Types__c(Region__c='Africa & Middle East',Skill_Weight__c=1,Name='Type2', Case_Location__c='Field2');
        Skill_Types__c type3 = new Skill_Types__c(Region__c='Africa & Middle East',Skill_Weight__c=1,Name='Type3', Case_Location__c='Field3');
        
        insert new List<Skill_Types__c>{type1, type2, type3};
        
        Skill__c skill1 = new Skill__c(Name='Skill1', Skill_Types__c =type1.id);
        Skill__c skill2 = new Skill__c(Name='Skill2', Skill_Types__c =type2.id);
        Skill__c skill3 = new Skill__c(Name='Skill3', Skill_Types__c =type3.id);
        
        insert new List<Skill__c>{skill1, skill2, skill3};
        
        Skill_Assignment__c assignment1 = new Skill_Assignment__c(Agents__c=agent.Id, Priority__c='1.0', Skills__c=skill1.id);
        Skill_Assignment__c assignment2 = new Skill_Assignment__c(Agents__c=agent.Id, Priority__c='2.0', Skills__c=skill2.id);
        Skill_Assignment__c assignment3 = new Skill_Assignment__c(Agents__c=agent.Id, Priority__c='3.0', Skills__c=skill3.id);
        
        insert new List<Skill_Assignment__c>{assignment1, assignment2, assignment3};
        
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
    
    static testmethod void testNoSkills(){
    	
        // Create agent
        Agents__c agent = new Agents__c(Name='Test User', User__c=UserInfo.getUserId());
        insert agent;
        
        // Set some skills
        Skill_Types__c type1 = new Skill_Types__c(Skill_Weight__c=1,Name='Type1', Case_Location__c='Field1');
        Skill_Types__c type2 = new Skill_Types__c(Skill_Weight__c=1,Name='Type2', Case_Location__c='Field2');
        Skill_Types__c type3 = new Skill_Types__c(Skill_Weight__c=1,Name='Type3', Case_Location__c='Field3');
        
        insert new List<Skill_Types__c>{type1, type2, type3};

        Skill__c skill1 = new Skill__c(Name='Skill1', Skill_Types__c =type1.id);
        Skill__c skill2 = new Skill__c(Name='Skill2', Skill_Types__c =type2.id);
        Skill__c skill3 = new Skill__c(Name='Skill3', Skill_Types__c =type3.id);
        
        insert new List<Skill__c>{skill1, skill2, skill3};

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