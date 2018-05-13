({
	sectorAndCategory : function(c, sector, category) {
		var filters = c.get("v.filters");
		console.log('aqui filter name' + category);
		filters['Sector__c'] = sector;
		filters['Category__c'] = category;		

		//c.set('v.account.Sector__c', sector);
		//c.set('v.account.Category__c', category);
		var account = c.get("v.account");
		account.Sector__c = sector;
		account.Category__c = category;		
		c.set("v.account", account);
	}
})