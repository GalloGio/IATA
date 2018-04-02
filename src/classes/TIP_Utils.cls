public class TIP_Utils{

	//##=============CONSTANTS=====================###


	//Case RT's
	public static String CASE_PROCESS_IDFS_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');
	private static String PROCESS_CASE_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');    

	//Account RT's
    private static String STANDARD_ACCOUNT_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account');  
    private static String PAYMENT_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('TIP_Payment_Provider');

	//Case Reason
	public static String CASE_REASON_PAYMENT_PROVIDER_MANAGMENT= 'Payment Provider Management';

	//Case Areas
	public static String CASE_AREA_TRANSPARENCY_IN_PAYMENTS= 'Transparency in Payments (TIP)';

	//Case origin
	public static String CASE_ORIGIN_PORTAL = 'Portal';

	//case Description
	public static String CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER = 'Request for Enlistment as Payment provider';


}