@isTest
private class AgentStatusExtensionTest {

	@isTest
	static void test() {
		TestUtilities.setupDefaultSystemSettings();
		TestUtilities.setupSkillType('Priority', 'Priority');
		Skill_Types__c aSkillType = [Select name, Case_Location__c from Skill_Types__c where Case_Location__c = : 'Priority' and Name = : 'Priority' limit 1];
		TestUtilities.setupSkill(aSkillType.id, 'Low');

		// Create agent
		Agents__c agent = new Agents__c(Name = 'Test User', User__c = UserInfo.getUserId());
		insert agent;

		PageReference ref = new PageReference(Page.Agent_Status_Page.getUrl());
		Test.setCurrentPage(ref);
		AgentStatusExtension con = new AgentStatusExtension();
		system.assertEquals(con.save(), ref);

		con.agent.Request_next_case__c = true;
		con.save();

		con.agent.Log_on_picklist__c = 'Log on';
		con.save();
		system.assertEquals(con.agent.Logged_on__c, true);

		con.agent.Log_on_picklist__c = 'Log off';
		con.save();
		system.assertEquals(con.agent.Logged_on__c, false);
	}

}