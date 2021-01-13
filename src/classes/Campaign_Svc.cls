Global class Campaign_Svc{

	//Generate renewal notice from campaign page layout
	webService static String generateRenewalNotice(String campaignId,String campaignNumber){
		String sentMsg = '';
		Campaign campaign = Campaign_Sel.getCampaignById(campaignId);

		//Verified if the product
		Map<Id,Id> campaignProductMap = new CampaignProduct_Sel().getLastVersionProductIdById(campaignId);

		Boolean invalidProduct = false;
		String productsNumbers = '';

		if(campaignProductMap != null && campaignProductMap.size() > 0){
			Set<Id> prdIds = new Set<Id>();
			prdIds.addAll(campaignProductMap.values());
			List<Product2> products = new Product_Sel().selectById(prdIds);
			if(products != null && products.size() > 0){
				for(Product2 prd : products){
					if(!prd.Display_to_ECommerce__c){ productsNumbers += prd.SAP_Material_Number__c; invalidProduct = true; }
				}
			}

			//Set the product priceBookEntry if null
			if(prdIds.size() > 0 && !invalidProduct){
				List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
				//Set the pricebookEntry
				Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
				Map<Id, PricebookEntry> pricebookEntryByProductId = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, prdIds);
				for(Id productId : prdIds){
					PricebookEntry pbe = pricebookEntryByProductId.get(productId);
					if(pbe == null) {
						pbe = new PricebookEntry( IsActive = true, Pricebook2Id = stdPriceBook.Id, Product2Id = productId, UnitPrice = 1.00, CurrencyIsoCode = Utility.getDefaultCurrency() );
						pricebookEntries.add(pbe);
					}
				}

				if(pricebookEntries.size() > 0){ insert pricebookEntries; }
			}
		}


		if(invalidProduct){ sentMsg = 'There is some products not available in the Ecommerce portal \n ' + productsNumbers;
		}else if(campaign.Renewal_notice_generated__c == null && campaign.IsActive && campaign.Generate_Members_Completed_On__c != null){
			//Call the batch to create the renewal notice
			CampaignMembers_Batch cm = new CampaignMembers_Batch('renewalNotice', campaignId, campaignNumber);
			Database.ExecuteBatch(cm,Utility.getIntegerSetting('Campaign member batch size'));
			//Show the submitted message to the loggin user
			sentMsg = Label.Campaign_submitted;
		}else if(campaign.Renewal_notice_generated__c != null && campaign.IsActive && campaign.Generate_Members_Completed_On__c != null){
			//return an error
			sentMsg = Label.Campaign_already_created;}else{sentMsg = Label.Campaign_creation_error;}
		return sentMsg;
	}
}
