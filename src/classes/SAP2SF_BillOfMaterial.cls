global without sharing class SAP2SF_BillOfMaterial{
	/****************************************************************************************************
		Created by FM 2020-03-23
			Method to call by SAP to insaert BOM (Bill Of Material) information
	****************************************************************************************************/
	webService static void insertBOM(String BillOfMaterial, List<String> RelatedProducts){
		List<Product_Component__c> productComponentToInsert = new List<Product_Component__c>();
		try{
			Set<String> sSAPMaterialNumber = new Set<String>();
			Map<String,String> mSFID_vs_SAPMaterialNumber = new Map<String,String>();

			//gather all SAP_Material_Number in order to query SFDC
			sSAPMaterialNumber.add(BillOfMaterial);
			for(String pc : RelatedProducts){
				sSAPMaterialNumber.add(pc);
			}

			//Get the product Id based on the SAP_Material_Number sent on the parameters
			List<Product2> prodInfo = [SELECT Id, SAP_Material_Number__c FROM Product2 WHERE SAP_Material_Number__c in :sSAPMaterialNumber];

			//Map all results for easy association between SAP_Material_Number and SFDC Id
			for(Product2 prod : prodInfo){
				mSFID_vs_SAPMaterialNumber.put(prod.SAP_Material_Number__c, prod.Id);
			}

			//Get the main Product SFDC ID
			String mainProdId = mSFID_vs_SAPMaterialNumber.get(BillOfMaterial);
			
			//Prepare Product Component Records for insertion
			for(String pc : RelatedProducts){
				Product_Component__c pcToInsert = new Product_Component__c();
				pcToInsert.Product__c = mainProdId;
				pcToInsert.Related_Product__c =  mSFID_vs_SAPMaterialNumber.get(pc);
				productComponentToInsert.add(pcToInsert);
			}

			//Insert Product Component Records
			insert productComponentToInsert;
		}catch (Exception e){
			//Log exception for later validation on the error that happened
			IECErrorLogger.logApexException('SAP2SF_BillOfMaterial.insertBOM',
										'BillOfMaterial: ' + BillOfMaterial + '\nRelatedProducts: ' + RelatedProducts,
										String.valueOf(e), e.getStackTraceString(), true);
		}
	} //*** end of "insertBOM"
} //*** end of class