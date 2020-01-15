global Class AMS_FillAMSAccreditationGDS{

	global class Request{
		@InvocableVariable(label='Test' required=true)
		public String result;
	}

		@InvocableMethod(label='Get value for Account GDS given and transform it' description='Returns the value for AMS Online Accreditation GDS with signed contract')
		public static List<String> fillGDS(List<String> typeLst){

					 String GDSValue= AMS_AgencyHelper.transformGDS(typeLst.get(0));

					 List<String> output = new List<String>();

					 output.add(GDSValue);

					 return output;

		}
 }
