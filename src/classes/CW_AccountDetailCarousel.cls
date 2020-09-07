/*
* @Description: CW_AccountDetailCarousel class, used to create Carousel wrapper
*/
public without sharing class CW_AccountDetailCarousel {
	/*
	* @Description: getFacilityFiles: generate a list of wrapper (Carousel) with the needed info to be displayed in frontside
	* @input: String recordId (of ContentDocumentLink)
	* @output: List<Carousel>
	*/
	@AuraEnabled
	public static List<Carousel> getFacilityFiles(String recordId) {
		Set<Id> listId = new Set<Id>();
		List<Carousel> listImages = new List<Carousel>();

		for (ContentDocumentLink currentItem : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId]) {
			listId.add(currentItem.ContentDocumentId);
		}
		Integer index = 0;
		for (ContentVersion doc : [SELECT Id, VersionData, FileExtension
									FROM ContentVersion 
									WHERE ContentDocumentId in :listId 
										AND IsLatest = true 
										AND Is_Company_Logo__c = false
									LIMIT 5]) {
			Carousel car = new Carousel();
			car.id = doc.Id;
			car.image= EncodingUtil.base64Encode(doc.VersionData);
			car.tabindex = index == 0 ? '0' : '-1';
			car.position = 'slds-carousel__panels translate-x'+String.valueOf(index)+'00';
			car.hidden =  index == 0 ? true : false;
			String indicatorClass = 'slds-carousel__indicator-action';
			indicatorClass = index == 0 ? indicatorClass + ' slds-is-active' : indicatorClass;
			car.indicatorClass = indicatorClass;
			String panelClass = 'slds-carousel__panel carousel-size';
			panelClass = index == 0 ? panelClass + ' panelSelected' : panelClass;
			car.panelClass = panelClass;
			car.fileExtension = doc.FileExtension;
			listImages.add(car);
			index++;
		}

		return listImages;
	}
/*
	* @Description: getFacilityFiles: generate a list of wrapper (Carousel) with the needed info to be displayed in frontside
	* @input: String recordId (of ContentDocumentLink)
	* @output: List<Carousel>
	*/
	@AuraEnabled
	public static String hideImageSelected(String imageId) {
		Result res = new Result();
		try{
			ContentVersion contentV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :imageId];
			ContentDocument contentD = [SELECT Id FROM ContentDocument WHERE Id = :contentV.ContentDocumentId];
			delete contentD;
			res.success = true;
		}
		catch(Exception e){
			res.success = false;
			res.message = e.getMessage();
		}

		return JSON.serialize(res);
	}

	/*
	* @Description: wrapper Carousel
	*/
	public class Carousel{
		@AuraEnabled String id {set;get;}
		@AuraEnabled String image {set;get;}
		@AuraEnabled String tabindex {set;get;}
		@AuraEnabled Boolean hidden {set;get;}
		@AuraEnabled String indicatorClass {set;get;}
		@AuraEnabled String panelClass {set;get;}
		@AuraEnabled String fileExtension {set;get;}
		@AuraEnabled String position {set;get;}
	}
	
	public class Result{
		public Boolean success;
		public String message;
	}
}