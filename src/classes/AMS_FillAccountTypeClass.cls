global Class AMS_FillAccountTypeClass{


				@InvocableMethod(label='Get value for Account Type given its agency location class' description='Returns the value for Account Type given its agency location class')
				public static List<String> fillType(List<String> locationClassLst){

					 String type = AMS_AgencyHelper.fillType(locationClassLst.get(0));

					 List<String> output = new List<String>();

					 output.add(type);

					 return output;

		}

		}
