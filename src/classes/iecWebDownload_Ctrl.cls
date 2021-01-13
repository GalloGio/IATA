/****************************************************************************************************
	Created by CGI, Kevin 2016-01-03
	Generate an Amazon S3 unique link for web download
****************************************************************************************************/
public class iecWebDownload_Ctrl extends IEC_PageController {

	public String accessKeyId {get;set;}
	public String secretAccessKey {get;set;}
	public String itemNumber {get;set;}
	public Boolean allowDownload {get;set;}
	public Integer expires{get;set;}
	public String bucketName {get;set;}
	public String fileName {get;set;}
	public String awsRegion{get;set;}


	public iecWebDownload_Ctrl(){
	}

	public PageReference pageLoad(){

		itemNumber = ApexPages.currentPage().getParameters().get('itemNumber');

		allowDownload = true;

		PageReference pageRef;
		//Validate User is LoggedIn
		if(loggedCustomer == null){

			//redirect user to login page
			pageRef = new PageReference('/IEC_Login?returl=/iecWebDownload?itemNumber=' + itemNumber);
			pageRef.setRedirect(true);
			return pageRef;

		}else if(itemNumber != null){

			//set the AWS account region
			awsRegion = Utility.getTextSetting('AWS Region'); //us-east-1 us-west-2 eu-west-1

			//Set AWS credentials
			if(!Test.isRunningTest()){
				accessKeyId = IECUtil.DecryptParameter(Utility.getTextSetting('AWS accessKeyId'));
				secretAccessKey = IECUtil.DecryptParameter(Utility.getTextSetting('AWS secretAccessKey'));
			}

			//Get Url parameters from customer email and make sur that the order exist
			List<OrderItem> orderItems = new OrderItem_Sel().getDownloadableItem(itemNumber, loggedCustomer.sfUser.ContactId);

			if(orderItems != null && orderItems.size() > 0){

				OrderItem orderItem = orderItems[0];

				//get the product AWS path
				//String filePath = orderItem.File_Path__c;
				fileName = orderItem.File_Path__c;

				//set the bucket name and the sub folders
				bucketName = Utility.getTextSetting('AWS bucket name') + '/' + orderItem.Product_Number__c; // + '/' + filePath;

				//set the expires link days
				if(orderItem.Days_available_for_download_1__c == null || orderItem.Days_available_for_download_1__c == 0){
					expires = Utility.getIntegerSetting('AWS download expires default time');
				}else{
					Decimal day = orderItem.Days_available_for_download_1__c;
					expires = (Integer) day * 24 * 60 * 60;
				}

				if(orderItem.AWS_download_link__c != null){
					//redirect customer to the existing AWS download link
					allowDownload = false;
					pageRef = new PageReference(orderItem.AWS_download_link__c);
					pageRef.setRedirect(true);
					return pageRef;
				}
			}

		}

		return null;
	}

	//update the orderItem Number_of_download__c and AWS_download_link__c if the customer download the document
	@remoteAction
	public static String updateOrderItemDownloadNumber(String itemNumber, String awsLink){

		List<OrderItem> toUpdate = new List<OrderItem>();

		Map<Id,OrderItem> orderItemMap = new OrderItem_Sel().getOrderItemByNumber(new set<String>{itemNumber});
		for(OrderItem oi : orderItemMap.values()){
			oi.Number_of_download__c = (oi.Number_of_download__c == null) ? 1 : oi.Number_of_download__c + 1;
			oi.AWS_download_link__c = awsLink;
			toUpdate.add(oi);
		}

		if(toUpdate.size() > 0){
			update toUpdate;
		}

		return '';
	}

}
