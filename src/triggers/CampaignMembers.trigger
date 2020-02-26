trigger CampaignMembers on CampaignMember (after delete, after insert, after update, before delete, before insert, before update) {
	CampaignMember_Dom.triggerHandler();
}
