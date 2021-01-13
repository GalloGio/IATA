/**
 * This is a test library for CAC related classes
 *  - List<GDP_File_Description__c> generateFileDescCACNonRef(): create GDP_File_Description, w/ Product_Type__c : CAC, CACEWS, CACSWS
 *
 * Original Author: Sonny Leman
 * Change Log:
 *   - 20160425-sl: initial version
 *
 */
@isTest(seeAllData=false)
public class CAC_TestLibrary {

	// ========================================================================
	// name for the GDP_File_Descriptions
	public static final String CAC_AGENCY_COMPLEX_WEB_REF = 'CAC Agency Complex Webs Reference';
	public static final String CAC_AGENCY_SIMPLE_WEB_REF  = 'CAC Agency Simple Webs Reference';
	public static final String CAC_IDCARD_COMPLEX_WEB_REF = 'CAC IDCard Complex Webs Reference';
	public static final String CAC_IDCARD_SIMPLE_WEB_REF  = 'CAC IDCard Simple Webs Reference';
	public static final String CAC_SUBSCRIPTION_DETAIL_REF = 'CAC Subscription Details Reference';

	public static final String CAC_AGENCY_COMPLEX_WEB_SVC = 'CAC Agency Complex Web Service';
	public static final String CAC_AGENCY_SIMPLE_WEB_SVC = 'CAC Agency Simple Web Service';
	public static final String CAC_IDCARD_COMPLEX_WEB_SVC = 'CAC IDCard Complex Web Service';
	public static final String CAC_IDCARD_SIMPLE_WEB_SVC = 'CAC IDCard Simple Web Service';
	public static final String CAC_SUBSCRIPTION_DETAIL_SVC = 'CAC Subscription Details';

	// ========================================================================
	// create and insert test GDP_File_Description records
	// create both the reference and non reference records
	// return the list of non reference GDP_File_Description records
	static public List<GDP_File_Description__c> generateFileDescCACNonRef()
		{
		// insert the references
		List<GDP_File_Description__c> lstCacFileDescRef = new List<GDP_File_Description__c>();
		lstCacFileDescRef.add( new GDP_File_Description__c(Name = CAC_AGENCY_COMPLEX_WEB_REF, Description__c = 'CAC Agency Complex Webs Reference'
									, Maximum_API_Request__c = 2000, Minimum_Digit_Search__c = 7, Payload_Procedure__c = 'Agency', Product_Type__c = 'CACEWS'
									, Reference_Clause__c = 'Agency_Status_Code__c >= 4', Service_Target__c = 'Response'
									, Atom__c = '255'));
		lstCacFileDescRef.add( new GDP_File_Description__c(Name = CAC_AGENCY_SIMPLE_WEB_REF, Description__c = 'CAC Agency Simple Webs Reference'
									, Maximum_API_Request__c = 2000, Minimum_Digit_Search__c = 7, Payload_Procedure__c = 'Agency', Product_Type__c = 'CACSWS'
									, Reference_Clause__c = 'Agency_Status_Code__c >= 4', Service_Target__c = 'Response'
									, Atom__c = '255'));
		lstCacFileDescRef.add( new GDP_File_Description__c(Name = CAC_IDCARD_COMPLEX_WEB_REF, Description__c = 'CAC IDCard Complex Webs Reference'
									, Maximum_API_Request__c = 1000, Minimum_Digit_Search__c = 10, Payload_Procedure__c = 'IDCard', Product_Type__c = 'CACEWS'
									, Reference_Clause__c = 'Json_Is_Active__c=true', Service_Target__c = 'Response'
									, Atom__c = '255'));
		lstCacFileDescRef.add( new GDP_File_Description__c(Name = CAC_IDCARD_SIMPLE_WEB_REF, Description__c = 'CAC IDCard Simple Webs Reference'
									, Maximum_API_Request__c = 1000, Minimum_Digit_Search__c = 10, Payload_Procedure__c = 'IDCard', Product_Type__c = 'CACSWS'
									, Reference_Clause__c = 'Json_Is_Active__c=true', Service_Target__c = 'Response'
									, Atom__c = '255'));
		lstCacFileDescRef.add( new GDP_File_Description__c(Name = CAC_SUBSCRIPTION_DETAIL_REF, Description__c = 'CAC Subscription Details Reference'
									, Maximum_API_Request__c = 1000, Payload_Procedure__c = 'Subscription', Product_Type__c = 'CAC'
									, Reference_Clause__c = 'Subscription__r.Zuora__SubscriptionStartDate__c <= TODAY AND subscription__r.Zuora__SubscriptionEndDate__c >= TODAY AND Subscription__r.Zuora__Status__c = \'Active\', Service_Target__c = \'Subscription\''
									, Atom__c = '255'));
		insert lstCacFileDescRef;

		// insert non references
		List<GDP_File_Description__c> lstCacFileDescNonRef = new List<GDP_File_Description__c>();
		lstCacFileDescNonRef.add(new GDP_File_Description__c(Name = 'CAC_AGENCY_COMPLEX_WEB_SVC', Description__c = 'CAC Agency Complex Web Service', File_Format__c = 'Database'
									, File_Naming_Convention__c = 'agency_websimple.txt', Frequency__c = 'Daily', Magnitude__c = 'Master', Product_Type__c = 'CACEWS', Reference__c = lstCacFileDescRef[0].Id));
		lstCacFileDescNonRef.add(new GDP_File_Description__c(Name = 'CAC_AGENCY_SIMPLE_WEB_SVC', Description__c = 'CAC Agency Simple Web Service', File_Format__c = 'Database'
									, File_Naming_Convention__c = 'agency_websimple.txt', Frequency__c = 'Daily', Magnitude__c = 'Master', Product_Type__c = 'CACSWS', Reference__c = lstCacFileDescRef[1].Id));
		lstCacFileDescNonRef.add(new GDP_File_Description__c(Name = 'CAC_IDCARD_COMPLEX_WEB_SVC', Description__c = 'CAC IDCard Complex Web Service', File_Format__c = 'Database'
									, File_Naming_Convention__c = 'idcard.txt', Frequency__c = 'Daily', Magnitude__c = 'Master', Minimum_Digit_Search__c = 10, Product_Type__c = 'CACEWS', Reference__c = lstCacFileDescRef[2].Id));
		lstCacFileDescNonRef.add(new GDP_File_Description__c(Name = 'CAC_IDCARD_SIMPLE_WEB_SVC', Description__c = 'CAC IDCard Simple Web Service', File_Format__c = 'Database'
									, File_Naming_Convention__c = 'idcard.txt', Frequency__c = 'Daily', Magnitude__c = 'Master', Product_Type__c = 'CACSWS', Reference__c = lstCacFileDescRef[3].Id));
		lstCacFileDescNonRef.add(new GDP_File_Description__c(Name = 'CAC_SUBSCRIPTION_DETAIL_SVC', Description__c = 'CAC Subscription Details', File_Format__c = 'Database'
									, File_Naming_Convention__c = 'subscription.txt', Frequency__c = 'Daily', Magnitude__c = 'Master', Product_Type__c = 'CAC', Reference__c = lstCacFileDescRef[4].Id));
		insert lstCacFileDescNonRef;

		return lstCacFileDescNonRef;
	} // generateFileDescCACNonRef


}
