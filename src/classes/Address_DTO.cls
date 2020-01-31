public class Address_DTO
{
	public String street1{get;set;}
	public String street2{get;set;}
	public String city{get;set;}
	public String stateLabel{get;set;}
	public String stateCode{get;set;}
	public String postalCode{get;set;}
	public String countryLabel{get;set;}
	public String countryCode{get;set;}
	public String vatNumber{get;set;}
	public String email{get;set;}
	public String phone{get;set;}
	public String attention{get;set;}
	public String addressName{get;set;}
	public Id     locationId{get;set;}
	public Boolean isPostalCodeRequired{get;set;}

	public static Address_DTO format2DTO(Location__c loc)
	{
		Address_DTO dto = new Address_DTO();
		if(loc != null)
		{
			dto.street1 		= loc.Street__c;
			//dto.street2 =
			dto.city 			= loc.City__c;
			dto.stateLabel 		= loc.ISO_State_Name__c;
			dto.stateCode 		= loc.ISO_State_Code__c;
			dto.postalCode 		= loc.ZipCode__c;
			dto.countryLabel 	= loc.ISO_Country_Name__c;
			dto.countryCode 	= loc.ISO_Country_Code__c;
			dto.vatNumber 		= loc.VAT_Number__c;
			dto.email 			= loc.Email__c;
			dto.phone 			= loc.Phone__c;
			dto.attention 		= loc.Attention__c;
			dto.addressName 	= loc.Address_Name__c;
			dto.locationId		= loc.Id;
			dto.isPostalCodeRequired = loc.Is_Postal_Code_Required__c;
		}

		return dto;
	}

	public static Address_DTO format2DTO(Id locationId)
	{
		Address_DTO dto = new Address_DTO();

		List<Location__c> locations = new Location_sel().getLocations(new Set<Id>{locationId});
		if(locations != null && locations.size() > 0)
		{
			dto =  format2DTO(locations[0]);
		}

		return dto;
	}

}
