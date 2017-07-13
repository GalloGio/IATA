public with sharing class ISSP_ANG_ProductComparison {
    public map<string, list<ProdFeature>> allFeaturesPerProduct	{get; set;}
    public list<string> lsAllFeatures {get; set;}

	public List<String> headers {get; set;}
	public List<List<String>> lines {get; set;}
    public Map<String, List<String>> linesMap {get; set;}
    public List<String> applyNowLine {get; set;}

    public map<string, Product2> mapProd {get;set;}
    public map<string, Product_Component__c> mapFeatures {get; set;}
    
    set<string> setAllFeatures = new set<string>();	//used for uniqueness
    set<Id> setProdId = new set<id>();
    
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    
    public ISSP_ANG_ProductComparison() {
    	pricebook2 thePricebook;
    	lsAllFeatures = new list<string>();
    	mapProd = new map<string, Product2>();
    	mapFeatures = new map<string, Product_Component__c>();
    	linesMap = new Map<String, List<String>>();
    	
    	list<Pricebook2> lsPB = [select id from Pricebook2 where name='NewGen Accreditation Models'];
    	if(!lsPB.isEmpty())	thePricebook = lsPB.get(0);
    	
    	allFeaturesPerProduct = new map<string, list<ProdFeature>>();
    	
    	if(thePricebook!=null) {
	    	for(PricebookEntry pbe:[select Product2Id, Product2.Name from Pricebookentry where Pricebook2Id=:thePricebook.Id]) {
	    		setProdId.add(pbe.Product2Id);
	    	}
	    	
	    	for(Product2 pr:[select id, ANG_HE_Application_Registration_Fees__c, ANG_AE_Application_Registration_Fees__c, ANG_ApplyNowUrl__c, Name,
	    					 ANG_CountrySpecRequirementsURL__c, ANG_AE_Fees_First_10_locations__c, ANG_HE_AnnualFees_Large_Agents__c, ANG_HE_AnnualFees_Medium_Agents__c
	    					 , ANG_AE_Fees_Next_15_Locations__c, ANG_HE_AnnualFees_Small_Agents__c
	    					 from Product2 where Id in:setProdId]) {
	    		mapProd.put(pr.Name, pr);
	    	}
	    	
	    	if(!setProdId.isEmpty()) {
	    		list<Product2> lsProd = [select Id, Name, (select id, Related_Product__r.Name, ANG_Description__c, ANG_Description_Label__c from Product_BOM__r) from Product2 where id in:setProdId];
	    		
	    		if(!lsProd.isEmpty()) {
	    			//First loop: get ALL available features univoquely and add into a list (ordered...)
	    			for(Product2 prod : lsProd) {
	    				if(!prod.Product_BOM__r.isEmpty()) {
	    					for(Product_Component__c pc:prod.Product_BOM__r) {
	    						setAllFeatures.add(pc.Related_product__r.Name);
	    						mapFeatures.put(pc.Related_product__r.Name, pc);
	    					}
	    				}
	    				allFeaturesPerProduct.put(prod.Name, new list<ProdFeature>());
	    			}
	    			
	    			lsAllFeatures.addAll(setAllFeatures);
	    			
	    			//system.debug('DTULLO 52 --> ' + allFeaturesPerProduct);
	    			for(Product2 prod : lsProd) {
	    				list<ProdFeature> lsTmp = new list<ProdFeature>();
    					for(string sf : setAllFeatures) {
    						boolean bExists = false;
    						for(Product_Component__c pc : prod.Product_BOM__r) {
    							if(sf == pc.Related_Product__r.Name) bExists = true;
    						}
    						lsTmp.add(new ProdFeature(sf, bExists));
    					}
	    				
	    				allFeaturesPerProduct.put(prod.Name, lsTmp);
	    			}
	    		}

	    		headers = new List<String>();
	    		lines = new List<List<String>>();
	    		applyNowLine = new List<String>();
	    		headers.add('');

	    		for(String key : allFeaturesPerProduct.keySet()) {
	    			headers.add(key);
	    			for(ProdFeature l : allFeaturesPerProduct.get(key)) {
						if(!linesMap.containsKey(l.sFeature)) {
							linesMap.put(l.sFeature, new List<String>());
						}
						linesMap.get(l.sFeature).add(String.valueOf(l.bActive));
	    			}
	    		}
	    		Boolean first = true;
	    		for(String key : linesMap.keySet()) {
	    			if(first) {
		    			List<String> lst = new List<String>();	    		
		    			lst.add('');
		    			for(String str : linesMap.get(key)) {
		    				lst.add('applyNow');
		    			}
		    			lines.add(lst);
		    			first = false;	    				
	    			}
	    			List<String> lst = new List<String>();	    		
	    			lst.add(key);
	    			lst.addAll(linesMap.get(key));
	    			lines.add(lst);
	    		}

	    		for(String key : linesMap.keySet()) {
	    			List<String> lst = new List<String>();	    		
	    			lst.add('Country Specific Requirements');
	    			for(String str : linesMap.get(key)) {
	    				lst.add('link');
	    			}
	    			lines.add(lst);

	    			lst = new List<String>();	    		
	    			lst.add('Cost');
	    			for(String str : linesMap.get(key)) {
	    				lst.add('very expensive');
	    			}
	    			lines.add(lst);
	    			break;
	    		}

	    		System.debug('Headers-->' + headers);
	    		System.debug('lines-->' + lines);
	    	}
    	}
    	
    	//system.debug('DTULLO --> mapFeatures ' + mapFeatures);
    }
    
    public class ProdFeature {
    	public string sFeature {get;set;}
    	public boolean bActive {get; set;}
    	public ProdFeature(string sFeature, boolean bActive) {
    		this.sFeature = sFeature;
    		this.bActive = bActive;
    	}
    }
}