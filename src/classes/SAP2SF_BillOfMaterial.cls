global without sharing class SAP2SF_BillOfMaterial{
	/****************************************************************************************************
		Created by FM 2020-03-23
			Method to call by SAP to insaert BOM (Bill Of Material) information
	****************************************************************************************************/
	webService static void insertBOM(String BillOfMaterial, List<String> RelatedProducts, List<String> RelatedProductsToDelete){
		List<Product_Component__c> productComponentToInsert = new List<Product_Component__c>();
		List<Product_Component__c> productComponentToDelete = new List<Product_Component__c>();

		try{
			Set<String> sSAPMaterialNumber = new Set<String>();
			Set<String> sExistingProductComponents = new Set<String>();
			Map<String,String> mProdID_vs_SAPMaterialNumber = new Map<String,String>();
			Map<String,String> mProdCompID_vs_SAPMaterialNumber = new Map<String,String>();
			

			//gather all SAP_Material_Number in order to query SFDC
			sSAPMaterialNumber.add(BillOfMaterial);
			for(String pc : RelatedProducts){
				sSAPMaterialNumber.add(pc);
			}
			for(String pc : RelatedProductsToDelete){
				sSAPMaterialNumber.add(pc);
			}

			//Get the product Id based on the SAP_Material_Number sent on the parameters
			List<Product2> prodInfo = [SELECT Id, SAP_Material_Number__c FROM Product2 WHERE SAP_Material_Number__c in :sSAPMaterialNumber];
			
			//Map all results for easy association between SAP_Material_Number and SFDC Id
			for(Product2 prod : prodInfo){
				mProdID_vs_SAPMaterialNumber.put(prod.SAP_Material_Number__c, prod.Id);
				
			}
		
			//Get the main Product SFDC ID
			String mainProdId = mProdID_vs_SAPMaterialNumber.get(BillOfMaterial);
			//Checks if the SFDC id are not null, if soo a exception is raised
			if(mainProdId == null){
				throw new DmlException('Product not existing in SF - ' + BillOfMaterial);
			}

			//Get the related product Id based on the header product (BillOfMaterial), 
			//this will serve to check duplicates and the deletions
			List<Product_Component__c> prodComponents = [SELECT Id, Product__c, Related_Product__c FROM Product_Component__c WHERE Product__c = :mainProdId];
			for(Product_Component__c prodComponent : prodComponents){
				sExistingProductComponents.add(prodComponent.Related_Product__c);
				mProdCompID_vs_SAPMaterialNumber.put(prodComponent.Related_Product__c, prodComponent.Id);
			}

			//Prepare Product Component Records for insertion
			for(String pc : RelatedProducts){

				//Checks if the SFDC id are not null, if soo a exception is raised
				if(mProdID_vs_SAPMaterialNumber.get(pc) == null){
					throw new DmlException('Product not existing in SF - ' + pc);
				}
				
				Product_Component__c pcToInsert = new Product_Component__c();
				pcToInsert.Product__c = mainProdId;
				pcToInsert.Related_Product__c =  mProdID_vs_SAPMaterialNumber.get(pc);

				//validates if the product already exist, if so we don't add it to the list
				if(!sExistingProductComponents.contains(pcToInsert.Related_Product__c)){
					productComponentToInsert.add(pcToInsert);
				}
			}

			//Insert Product Component Records
			if(!productComponentToInsert.isEmpty()){
				insert productComponentToInsert;
			}

			//Prepare Product Component Records for deletion
			for(String pc : RelatedProductsToDelete){
				Product_Component__c pcToDelete = new Product_Component__c();
				String auxId =  mProdID_vs_SAPMaterialNumber.get(pc);
				pcToDelete.Id = mProdCompID_vs_SAPMaterialNumber.get(auxId);
				productComponentToDelete.add(pcToDelete);
			}

			//Delete Product Component Records
			if(!productComponentToDelete.isEmpty()){
				delete productComponentToDelete;
			}
		}catch (Exception e){
			//Log exception for later validation on the error that happened
			IECErrorLogger.logApexException('SAP2SF_BillOfMaterial.insertBOM',
										'BillOfMaterial: ' + BillOfMaterial + '\nRelatedProducts: ' + RelatedProducts,
										String.valueOf(e), e.getStackTraceString(), true);
		}
	} //*** end of "insertBOM"
} //*** end of class