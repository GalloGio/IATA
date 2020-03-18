global Class AMS_FillAccountIndustryClass{

		@InvocableMethod(label='Get value for Account Industry given its type' description='Returns the value for Account Industry given its type')
		public static List<String> fillIndustry(List<String> typeLst){

					 String industry = AMS_AgencyHelper.fillIndustry(typeLst.get(0));

					 List<String> output = new List<String>();

					 output.add(industry);

					 return output;

		}
 }
