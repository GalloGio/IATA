public class AgentStatusExtension {
    public Boolean IsAgent {get; set;}
    public Agents__c agent {get; set;}
    public DateTime logoutTime{get; set;}
    
    public AgentStatusExtension () {
        try
        {
            IsAgent = true;
            this.agent = [Select a.Exact_Log_Off_Time__c, a.Log_Off_Time_After_Timeout__c,
                          a.User__c, a.Region__c, a.SystemModstamp, a.Request_next_case__c, a.OwnerId,
                          a.Next_case_request_date_time__c, a.Name, a.Maximum_cases_at_one_time__c,
                          a.Maximum_case_workload__c, a.Logged_on__c, a.LastModifiedDate, a.LastModifiedById,
                          a.IsDeleted, a.Id, a.CurrencyIsoCode, a.CreatedDate, a.CreatedById, a.Log_on_picklist__c
                          From Agents__c a where a.User__c = :UserInfo.getUserId() limit 1];
            if(this.agent.Logged_on__c!=False) {
                this.agent.Exact_Log_Off_Time__c = DateTime.now();
                Case_Agent_To_Queue_Assignment_Timeout__mdt timeout = [SELECT Timeout_In_Minutes__c FROM Case_Agent_To_Queue_Assignment_Timeout__mdt
                                                                       WHERE Region__c=:agent.Region__c LIMIT 1];
                if(timeout != null)
                    this.agent.Log_Off_Time_After_Timeout__c = DateTime.now().addMinutes(timeout.Timeout_In_Minutes__c.intValue());
                else {
                    Case_Agent_To_Queue_Assignment_Timeout__mdt defaultTimeout = [SELECT Timeout_In_Minutes__c FROM Case_Agent_To_Queue_Assignment_Timeout__mdt
                                                                                  WHERE DeveloperName='Default_Timeout'];
                    if(defaultTimeout != null)
                        this.agent.Log_Off_Time_After_Timeout__c = DateTime.now().addMinutes(defaultTimeout.Timeout_In_Minutes__c.intValue());
                    else
                        this.agent.Log_Off_Time_After_Timeout__c =  this.agent.Exact_Log_Off_Time__c;
                }
            }
        }
        catch(System.QueryException e){
            IsAgent = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The Current User is not an agent, to update your status please associate the User to an agent');
            ApexPages.addMessage(myMsg);
        }
    }

    public PageReference save()
    {
        // Rémi de Jouvencel 27/01/2009
        // Put the log On/log Off logic here
        if (agent.Request_next_case__c)
        {
            agent.Next_case_request_date_time__c = datetime.now();
            agent.Request_next_case__c=false;
        }
        if (agent.Log_on_picklist__c == 'Log on') {
            agent.Logged_on__c = true;
        }
        if (agent.Log_on_picklist__c == 'Log off') {
            agent.Logged_on__c = false;
        }

        agent.Log_on_picklist__c = null;

        upsert agent;
        return ApexPages.currentPage().setRedirect(true);
    }

    //*********************************************
    //* T.E.S.T M.E.T.H.O.D
    //*********************************************
    static testmethod void test()
    {
        TestUtilities.setupDefaultSystemSettings();
        TestUtilities.setupSkillType('Priority','Priority');
        Skill_Types__c aSkillType = [Select name, Case_Location__c from Skill_Types__c where Case_Location__c =: 'Priority' and Name =: 'Priority' limit 1];
        TestUtilities.setupSkill(aSkillType.id,'Low');
        
        // Create agent
        Agents__c agent = new Agents__c(Name='Test User', User__c=UserInfo.getUserId());
        insert agent;
        
        PageReference ref = new PageReference(Page.Agent_Status_Page.getUrl());
        Test.setCurrentPage(ref);
        AgentStatusExtension con = new AgentStatusExtension();
        system.assertEquals(con.save(), ref);
        
        con.agent.Request_next_case__c=true;
        con.save();
        
        con.agent.Log_on_picklist__c='Log on';
        con.save();
        system.assertEquals(con.agent.Logged_on__c,true);
        
        con.agent.Log_on_picklist__c='Log off';
        con.save();
        system.assertEquals(con.agent.Logged_on__c,false);
    }
}