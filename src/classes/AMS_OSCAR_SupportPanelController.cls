public class AMS_OSCAR_SupportPanelController {
	public AMS_IntegerCarrier complaintsInt {get; set;}
	public AMS_IntegerCarrier relatedCasesInt {get; set;}
	public AMS_IntegerCarrier historyInt {get; set;}
	public AMS_IntegerCarrier attachmentInt {get; set;}

	public AMS_OSCAR_SupportPanelController(ApexPages.StandardController controller){
		complaintsInt = new AMS_IntegerCarrier();
		relatedCasesInt = new AMS_IntegerCarrier();
		historyInt = new AMS_IntegerCarrier();
		attachmentInt = new AMS_IntegerCarrier();
	}
}
