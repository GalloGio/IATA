public with sharing class ANG_ProductComparisonHelper {
    public map<string, list<ProdFeature>> allFeaturesPerProduct	{get; set;}
    public list<string> lsAllFeatures {get; set;}

	public List<String> headers {get; set;}
	public List<List<TableCell>> lines {get; set;}
    public Map<String, List<TableCell>> linesMap {get; set;}

    public map<string, Product2> mapProd {get;set;}
    public map<string, Product_Component__c> mapFeatures {get; set;}
    
    set<string> setAllFeatures = new set<string>();	//used for uniqueness
    set<Id> setProdId = new set<id>();
    public String type {get; set;}
    public String costTooltip {get; set;}
    public Boolean multiCountryEnabled {get; set;}
       
    public ANG_ProductComparisonHelper(String type) {

    	This.type = type;

    	this.multiCountryEnabled = [SELECT Contact.Account.IATA_ISO_Country__r.Multicountry_Enabled__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Contact.Account.IATA_ISO_Country__r.Multicountry_Enabled__c;

    	pricebook2 thePricebook;
    	lsAllFeatures = new List<string>();
    	mapProd = new Map<string, Product2>();
    	mapFeatures = new Map<string, Product_Component__c>();

    	Map<String, String> mapProductLabels = new Map<String, String>();
    	Map<String, String> mapTooltipLabels = new Map<String, String>();

		list<Pricebook2> lsPB;
		if(!Test.isRunningTest()) {
    		lsPB = [select id from Pricebook2 where name='NewGen Accreditation Models'];
		} else {
			lsPB = [select id from Pricebook2 where name='NewGen Accreditation Models test'];
		}

		if(Type == 'A') {
			this.costTooltip = Label.ISSP_ANG_ProdCompCostTooltip;
		} else {
			this.costTooltip = Label.ISSP_ANG_ProdCompCostTooltipConvert;
		}

    	if(!lsPB.isEmpty())	thePricebook = lsPB.get(0);
    	
    	allFeaturesPerProduct = new map<string, list<ProdFeature>>();
    	
    	if(thePricebook!=null) {
	    	for(PricebookEntry pbe:[select Product2Id, Product2.Name from Pricebookentry where Pricebook2Id=:thePricebook.Id]) {
	    		setProdId.add(pbe.Product2Id);
	    	}
	    	
	    	if(!setProdId.isEmpty()) {
	    		List<Product2> lsProd = new List<Product2>();
	    		for (Product2 p2: [SELECT Id, Name, ANG_Description_Label__c, ANG_Tooltip__c,
	    							ANG_HE_Annual_fees__c, ANG_AE_Annual_fees__c,
									ANG_HE_Application_Registration_Fees__c, ANG_HE_AnnualFees_Small_Agents__c, ANG_HE_AnnualFees_Medium_Agents__c,
									ANG_HE_AnnualFees_Large_Agents__c, ANG_AE_Application_Registration_Fees__c, ANG_AE_Fees_First_10_locations__c,
									ANG_AE_Fees_Next_15_Locations__c, ANG_AE_Fees_Additional_Locations__c,
									ANG_Fees_GoStandard_GoLite__c, ANG_Fees_GoLite_GoStandard__c, ANG_Fees_GoGlobal_GoLite__c, ANG_Fees_GoGlobal_GoStandard__c, ANG_Fees_GoLite_GoGlobal__c, ANG_Fees_GoStandard_GoGlobal__c,
	    							(SELECT id, Related_Product__r.Name, ANG_Tooltip__c, ANG_Description__c, ANG_Description_Label__c, Order__c from Product_BOM__r ORDER BY Order__c)
	    						FROM Product2 WHERE id in:setProdId]) {
					if (!this.multiCountryEnabled && p2.Name == 'MultiCountry') continue;
					lsProd.add(p2);
				}
	    		
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

	  							if(!mapTooltipLabels.containsKey(pc.ANG_Description__c)) {
    								mapTooltipLabels.put(pc.ANG_Description__c, getCustomLabel(pc.ANG_Tooltip__c));
    							}

    							if(!mapProductLabels.containsKey(pc.ANG_Description__c)) {
    								mapProductLabels.put(pc.ANG_Description__c, getCustomLabel(pc.ANG_Description_Label__c));
    							}

    							if(sf == pc.Related_Product__r.Name) bExists = true;
    						}
    						lsTmp.add(new ProdFeature(sf,
    												  bExists,
    												  new Fees(prod.ANG_HE_Annual_fees__c,
															   prod.ANG_AE_Annual_fees__c,
    												  		   prod.ANG_HE_Application_Registration_Fees__c,
														       prod.ANG_HE_AnnualFees_Small_Agents__c,
														       prod.ANG_HE_AnnualFees_Medium_Agents__c,
														       prod.ANG_HE_AnnualFees_Large_Agents__c,
														       prod.ANG_AE_Application_Registration_Fees__c,
														       prod.ANG_AE_Fees_First_10_locations__c,
														       prod.ANG_AE_Fees_Next_15_Locations__c,
														       prod.ANG_AE_Fees_Additional_Locations__c,
														       prod.ANG_Fees_GoStandard_GoLite__c,
														       prod.ANG_Fees_GoLite_GoStandard__c,
														       prod.ANG_Fees_GoGlobal_GoLite__c,
														       prod.ANG_Fees_GoGlobal_GoStandard__c, 
														       prod.ANG_Fees_GoLite_GoGlobal__c, 
														       prod.ANG_Fees_GoStandard_GoGlobal__c)
    												  ));
    					}

						if(!mapTooltipLabels.containsKey(prod.Name)) {
							mapTooltipLabels.put(prod.Name, getCustomLabel(prod.ANG_Tooltip__c));
						}


						if(!mapProductLabels.containsKey(prod.Name)) {
							mapProductLabels.put(prod.Name, getCustomLabel(prod.ANG_Description_Label__c));
						}
	    				
	    				allFeaturesPerProduct.put(prod.Name, lsTmp);
	    			}
	    		}

				linesMap = new Map<String, List<TableCell>>();
	    		headers = new List<String>();
	    		lines = new List<List<TableCell>>();
	    		headers.add('');

	    		// headers
	    		for(String key : allFeaturesPerProduct.keySet()) { 
	    			headers.add(mapProductLabels.get(key));

	    			for(ProdFeature l : allFeaturesPerProduct.get(key)) {
						if(!linesMap.containsKey(l.sFeature)) {
							linesMap.put(l.sFeature, new List<TableCell>());
						}
						linesMap.get(l.sFeature).add(new TableCell(String.valueOf(l.bActive),'', l.fees, mapProductLabels.get(l.sFeature), ''));
	    			}
	    		}

	    		Boolean first = true;
	    		for(String key : linesMap.keySet()) {
	    			if(first && type == 'A') {
		    			List<TableCell> lst = new List<TableCell>();	    		
		    			lst.add(new TableCell('','','',''));
		    			Integer i = 1;
		    			for(TableCell tc : linesMap.get(key)) {
		    				lst.add(new TableCell('applyNow', translateKeyAccreditation(headers.get(i)), tc.sLabel, tc.tooltip));
		    				i++;
		    			}
		    			lines.add(lst);
		    			first = false;	    				
	    			}

	    			//System.debug('key---->' + key + '----->' + mapProductLabels.get(key) + '----->' + mapTooltipLabels.get(key));

	    			List<TableCell> lst = new List<TableCell>();		
	    			lst.add(new TableCell(key, '', mapProductLabels.get(key), mapTooltipLabels.get(key)));
	    			lst.addAll(linesMap.get(key));
	    			lines.add(lst);
	    		}

	    		for(String key : linesMap.keySet()) {
	    			List<TableCell> lst;

	    			if(type == 'A') {
		    			lst = new List<TableCell>();	    		
		    			lst.add(new TableCell(Label.ANG_ISSP_ProductComparisonCountrySpecificRequirements,
		    								  '',
		    								  Label.ANG_ISSP_ProductComparisonCountrySpecificRequirements,
		    								  ''));

		    			Integer i = 1;
		    			for(TableCell tc : linesMap.get(key)) {
		    				lst.add(new TableCell('link',translateKeyCountryRequirements(headers.get(i)), tc.sLabel, tc.tooltip));
							i++;
		    			}
		    			lines.add(lst);
	    			}

	    			
	    			lst = new List<TableCell>();	 
	    			
	    			lst.add(new TableCell('Cost',
	    								  '',
	    								  Label.ANG_ISSP_ProductComparisonCost,
	    								  ''));

	    			for(TableCell tc : linesMap.get(key)) {
	    				lst.add(new TableCell('Application Fee','',tc.fees, tc.sLabel, tc.tooltip));
	    			}
	    			lines.add(lst);

	    			break;
	    		}

	    		//System.debug('Headers-->' + headers);
	    		//System.debug('lines-->' + lines);
	    	}
    	}
    }

    public class Fees {
    	public String HE_Annual_Fees {get;set;}
	    public String HE_Application_Registration_Fees {get;set;}
	    public String HE_AnnualFees_Small_Agents {get;set;}
	    public String HE_AnnualFees_Medium_Agents {get;set;}
	    public String HE_AnnualFees_Large_Agents {get;set;}

		public String AE_Annual_Fees {get;set;}
	    public String AE_Application_Registration_Fees {get;set;}
	    public String AE_Fees_First_10_locations {get;set;}
	    public String AE_Fees_Next_15_Locations {get;set;}
	    public String AE_Fees_Additional_Locations {get;set;}

	    public String Fees_GoStandard_GoLite {get; set;}
	    public String Fees_GoLite_GoStandard {get; set;}
	    public String Fees_GoGlobal_GoLite {get; set;}
	    public String Fees_GoGlobal_GoStandard {get; set;}
	    public String Fees_GoLite_GoGlobal {get; set;}
	    public String Fees_GoStandard_GoGlobal {get; set;}

	    public List<String> ConversionFeesValuesList {get; set;}
	    public String ConversionFeesTooltip {get; set;}

    	public Fees(String HE_Annual_Fees, String AE_Annual_Fees, String HE_Application_Registration_Fees, String HE_AnnualFees_Small_Agents, String HE_AnnualFees_Medium_Agents, String HE_AnnualFees_Large_Agents,
    			    String AE_Application_Registration_Fees, String AE_Fees_First_10_locations, String AE_Fees_Next_15_Locations, String AE_Fees_Additional_Locations,
    			    String Fees_GoStandard_GoLite, String Fees_GoLite_GoStandard, String Fees_GoGlobal_GoLite,
					String Fees_GoGlobal_GoStandard, String Fees_GoLite_GoGlobal, String Fees_GoStandard_GoGlobal) {

    		this.HE_Annual_Fees = HE_Annual_Fees;
		    this.HE_Application_Registration_Fees = HE_Application_Registration_Fees;
		    this.HE_AnnualFees_Small_Agents = HE_AnnualFees_Small_Agents;
		    this.HE_AnnualFees_Medium_Agents = HE_AnnualFees_Medium_Agents;
		    this.HE_AnnualFees_Large_Agents = HE_AnnualFees_Large_Agents;

		    this.ConversionFeesValuesList = new List<String>();

			this.AE_Annual_Fees = AE_Annual_Fees;
		    this.AE_Application_Registration_Fees =	AE_Application_Registration_Fees;
		    this.AE_Fees_First_10_locations = AE_Fees_First_10_locations;
		    this.AE_Fees_Next_15_Locations = AE_Fees_Next_15_Locations;
		    this.AE_Fees_Additional_Locations = AE_Fees_Additional_Locations;
		    this.Fees_GoStandard_GoLite = Fees_GoStandard_GoLite;
		    this.Fees_GoLite_GoStandard = Fees_GoLite_GoStandard;
		    this.Fees_GoGlobal_GoLite = Fees_GoGlobal_GoLite;
		    this.Fees_GoGlobal_GoStandard = Fees_GoGlobal_GoStandard;
		    this.Fees_GoLite_GoGlobal = Fees_GoLite_GoGlobal;
		    this.Fees_GoStandard_GoGlobal = Fees_GoStandard_GoGlobal;

			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SObjectType leadSchema = schemaMap.get('Product2');
			Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();		    

		    if (Fees_GoStandard_GoLite != null && Fees_GoStandard_GoLite != '') {
		    	ConversionFeesValuesList.add(fieldMap.get('ANG_Fees_GoStandard_GoLite__c').getDescribe().getLabel() + ': ' + Fees_GoStandard_GoLite);
		    	ConversionFeesTooltip = Label.ANG_ISSP_ConversionFromGoStandardTooltip;
		    } 

		    if (Fees_GoLite_GoStandard != null && Fees_GoLite_GoStandard != '') {
		    	ConversionFeesValuesList.add(fieldMap.get('ANG_Fees_GoLite_GoStandard__c').getDescribe().getLabel() + ': ' + Fees_GoLite_GoStandard);
		    	ConversionFeesTooltip = Label.ANG_ISSP_ConversionFromGoLiteTooltip;
		    }

		    if (Fees_GoGlobal_GoLite != null && Fees_GoGlobal_GoLite != '') {
		    	ConversionFeesValuesList.add(fieldMap.get('ANG_Fees_GoGlobal_GoLite__c').getDescribe().getLabel() + ': ' + Fees_GoGlobal_GoLite);
		    	ConversionFeesTooltip = Label.ANG_ISSP_ConversionFromGoGlobalTooltip;
		    } 

		    if (Fees_GoGlobal_GoStandard != null && Fees_GoGlobal_GoStandard != '') {
		    	ConversionFeesValuesList.add(fieldMap.get('ANG_Fees_GoGlobal_GoStandard__c').getDescribe().getLabel() + ': ' + Fees_GoGlobal_GoStandard);
		    	ConversionFeesTooltip = Label.ANG_ISSP_ConversionFromGoGlobalTooltip;
		    }

		    if (Fees_GoLite_GoGlobal != null && Fees_GoLite_GoGlobal != '') {
		    	ConversionFeesValuesList.add(fieldMap.get('ANG_Fees_GoLite_GoGlobal__c').getDescribe().getLabel() + ': ' + Fees_GoLite_GoGlobal);
		    	ConversionFeesTooltip = Label.ANG_ISSP_ConversionFromGoLiteTooltip;
		    } 

		    if (Fees_GoStandard_GoGlobal != null && Fees_GoStandard_GoGlobal != '') {
		    	ConversionFeesValuesList.add(fieldMap.get('ANG_Fees_GoStandard_GoGlobal__c').getDescribe().getLabel() + ': ' + Fees_GoStandard_GoGlobal);
		    	ConversionFeesTooltip = Label.ANG_ISSP_ConversionFromGoStandardTooltip;
		    }
    	}
    }
    
    public class ProdFeature {
    	public String sFeature {get;set;}
    	public Boolean bActive {get; set;}
    	public Fees fees {get;set;}

    	public ProdFeature(string sFeature, boolean bActive, Fees fees) {
    		this.sFeature = sFeature;
    		this.bActive = bActive;
    		this.fees = fees;
    	}
    }

    public class TableCell {
    	public String name {get;set;}
    	public String sLabel {get;set;}
    	public String attribute {get;set;}
    	public Boolean flagFees {get;set;}
    	public Fees fees {get;set;}
    	public String tooltip {get;set;}

    	public TableCell(String name, String attribute, String sLabel, String tooltip) {
    		this.name = name;
			this.sLabel = sLabel;
    		this.attribute = attribute;
    		this.flagFees = false;
    		this.tooltip = tooltip;
    	}

    	public TableCell(String name, String attribute, Fees fees, String sLabel, String tooltip) {
    		this.flagFees = true;
    		this.sLabel = sLabel;
    		this.fees = fees;
    		this.name = name;
    		this.attribute = attribute;
    		this.tooltip = tooltip;
    	}
    }

    public String getCustomLabel(String labelName) {
    	if(labelName != null && labelName != '') {
			Component.Apex.OutputText output = new Component.Apex.OutputText();
			output.expressions.value = '{!$Label.' + labelName + '}';
			return string.valueOf(output.value);
		} else {
			return labelName;
		}
    }

    private String translateKeyAccreditation(String key) {
    	if(key == Label.ANG_ISSP_ProductStandardAccreditationWithCash) {
    		return 'New HE standard - Standard with Cash';
    	} else if (key == Label.ANG_ISSP_ProductStandardAccreditationWithNoCash) {
    		return 'New HE lite - Standard no Cash';
    	} else if (key == Label.ANG_ISSP_ProductStandardAccreditationWithMultiCountry) {
    		return 'New HE multicountry - Multicountry';
    	} else {
    		return '';
    	}
    }

    private String translateKeyCountryRequirements(String key) {
    	if(key == Label.ANG_ISSP_ProductStandardAccreditationWithCash) {
    		return AMS_Utils.ACCREDITATIONMODEL_CASH;
    	} else if (key == Label.ANG_ISSP_ProductStandardAccreditationWithNoCash) {
    		return AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
    	} else if (key == Label.ANG_ISSP_ProductStandardAccreditationWithMultiCountry) {
    		return AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
    	} else {
    		return '';
    	}
    }
}