({
	sectorAndCategory : function(c, sector, category) {
		var account = c.get("v.account");
		account.Sector__c = sector;
		account.Category__c = category;		
		c.set("v.account", account);
	}
})