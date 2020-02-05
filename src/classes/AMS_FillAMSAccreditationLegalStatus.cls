global Class AMS_FillAMSAccreditationLegalStatus{

		@InvocableMethod(label='Get value for Account Company Type given and transform it' description='Returns the value for AMS Online Accreditation Specify Legal Status')
		public static List<String> fillLegalStatus(List<String> typeLst){

					 String legalStatus = AMS_AgencyHelper.transformCompanyType(typeLst.get(0));

					 List<String> output = new List<String>();

					 output.add(legalStatus );

					 return output;

		}
 }
