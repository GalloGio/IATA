/****************************************************************************************************
	Created by CGI, Thai 2015-10-20
		Data Transfer Object for country-state structure
****************************************************************************************************/
public class ISO_Country_State_DTO {


public Id CountryId;
public String CountryCode;
public String CountryName;
public List<Id> StateId;
public List<String> StateCode;
public List<String> StateName;

public ISO_Country_State_DTO(Id CountryId, String CountryCode, String CountryName) {
	this.CountryId = CountryId;
	this.CountryCode = CountryCode;
	this.CountryName = CountryName;
	this.StateId = new List<Id>();
	this.StateCode = new List<String>();
	this.StateName = new List<String>();
} //*** end of contructor "ISO_Country_State_DTO"

/*public ISO_Country_State_DTO(String CountryCode, String CountryName) {
	this.CountryCode = CountryCode;
	this.CountryName = CountryName;
	this.StateCode = new List<String>();
	this.StateName = new List<String>();
}*/ //*** end of contructor "ISO_Country_State_DTO"


} //*** end of class
