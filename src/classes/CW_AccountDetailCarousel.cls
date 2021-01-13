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
		List<String> acceptFormats = new List<String>{'pdf'};
		List<String> listId = new List<String>();
		List<String> listCapabPhotoId = new List<String>();
		List<Carousel> listImages = new List<Carousel>();
		List<Carousel> listImagesVisible = new List<Carousel>();

		Integer index = 0;

		try{

			//Read capabilities photos from the station
			listImages.addAll(CW_CapabilitiesUtilities.getCapabilitiesPhotosFromStation(recordId));
			for(Carousel capabPhoto : listImages){
				listCapabPhotoId.add(capabPhoto.id);
			}

			//Read photos alocated in salesforce
			for (ContentDocumentLink currentItem : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId]) {
				if(!listCapabPhotoId.contains(currentItem.ContentDocumentId)){
					listId.add(currentItem.ContentDocumentId);
				}
			}

			//Read only visible photos
			for(Carousel capabPhoto : listImages){
				if(capabPhoto.visible){
					capabPhoto.position = 'slds-carousel__panels translate-x'+String.valueOf(index)+'00';
					listImagesVisible.add(capabPhoto);
					index++;
				}
			}

			index = listImagesVisible.size();
			
			for (ContentVersion doc : [SELECT Id, VersionData, FileExtension, ContentDocumentId, Title
										FROM ContentVersion 
										WHERE ContentDocumentId in :listId 
											AND IsLatest = true 
											AND Is_Company_Logo__c = false]) {
				Carousel car = new Carousel();
				car.id = doc.ContentDocumentId;
				car.name = doc.Title;
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
				car.isInternal = true;
				car.isDocument = acceptFormats.contains(doc.FileExtension);
				listImagesVisible.add(car);
				index++;
			}

			
		}
		catch(Exception e){
			System.debug(LoggingLevel.FINE, '____[CW_AccountDetailCarousel - getFacilityFiles] Error: ' + e.getMessage() + ' Trace:' + e.getStackTraceString());
		}

		return listImagesVisible;
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
			ContentDocument contentD = [SELECT Id FROM ContentDocument WHERE Id = :imageId];
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
		public String name {set;get;}
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
		@AuraEnabled 
		public Boolean isInternal {set;get;}
		@AuraEnabled 
		public Boolean isDocument {set;get;}
		@AuraEnabled 
		public Boolean visible {set;get;}
	}
	
	public class Result{
		public Boolean success { get; set; }
		public String message { get; set; }
	}
}