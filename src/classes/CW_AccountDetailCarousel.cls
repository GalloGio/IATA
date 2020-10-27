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
		List<String> listId = new List<String>();
		List<Carousel> listImages = new List<Carousel>();
		Integer index = 0;

		try{

			for (ContentDocumentLink currentItem : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId]) {
				listId.add(currentItem.ContentDocumentId);
			}
			
			for (ContentVersion doc : [SELECT Id, VersionData, FileExtension, ContentDocumentId
										FROM ContentVersion 
										WHERE ContentDocumentId in :listId 
											AND IsLatest = true 
											AND Is_Company_Logo__c = false]) {
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
				car.urlImage = CW_AccountDetailCarousel.generateImageURL(doc.ContentDocumentId);
				listImages.add(car);
				index++;
			}

			//Read capabilities photos from the station
			listImages.addAll(CW_CapabilitiesUtilities.getCapabilitiesPhotosFromStation(listId,recordId));
		}
		catch(Exception e){
			system.debug('Error: '+e.getMessage() + ' Trace:' + e.getStackTraceString());			
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

	private static String generateImageURL(Id conDoc) {
		String URL_Base = ISSP_CS__c.getValues('ICG_URL_Base').Value__c;
		return URL_Base.removeEnd('/s/') + '/sfc/servlet.shepherd/document/download/' + conDoc;
	}

	/*
	* @Description: wrapper Carousel
	*/
	public class Carousel{
		@AuraEnabled 
		public String id {set;get;}
		@AuraEnabled 
		public String image {set;get;}
		@AuraEnabled 
		public String tabindex {set;get;}
		@AuraEnabled 
		public Boolean hidden {set;get;}
		@AuraEnabled 
		public String indicatorClass {set;get;}
		@AuraEnabled 
		public String panelClass {set;get;}
		@AuraEnabled 
		public String fileExtension {set;get;}
		@AuraEnabled 
		public String position {set;get;}
		@AuraEnabled 
		public String urlImage {set;get;}
	}
	
	public class Result{
		public Boolean success { get; set; }
		public String message { get; set; }
	}
}