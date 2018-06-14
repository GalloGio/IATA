/*
	This class is the controller for:
	- the page TrackedEmailHtmlBody, which can be reached from the layout of a tracked email once it has been sent
	- the component TrackedEmailPreview, which is included in the page sendSingleTrackedEmail
	
	Either the "parent" variable will be set or the "trackedEmail" variable
*/
public without sharing class TrackedEmailPreviewController {

    public sendSingleTrackedEmailController parent {get; set;}
    
    public Tracked_Email__c trackedEmail {
        get{
            if(trackedEmail == null){
                String id = ApexPages.currentPage().getParameters().get('id');
                trackedEmail = [select Html_Body__c from Tracked_Email__c where Id =:id];
            }
            return trackedEmail;
        }
        set;
    }

    public String getHtmlBody() {
    	if(parent != null){
	        String rawText = parent.rawText;
	        if(rawText != null){
	            rawText = rawText.replace(SignaturitUtils.pStyle, '');
	        }
	        return parent.bodyHeader + rawText + parent.bodyFooter;
    	}
    	else{
    		if(trackedEmail.Html_Body__c != null){
	            return trackedEmail.Html_Body__c.replace(SignaturitUtils.pStyleShort, '');
    		}
    		return '';
        }
    }
    
    public void closePreview(){
        parent.showPreviewPanel = false;
    }
}