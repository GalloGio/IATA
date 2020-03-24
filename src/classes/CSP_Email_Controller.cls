/**
 * Created by ukaya01 on 27/09/2019.
 */

public with sharing class CSP_Email_Controller {

	public string HeaderUrl;
	public string FirstName;
	public string CommunityUrl;
	public string FooterUrl;

	public String getHeaderUrl(){
	   return '{!HeaderUrl}';
	}

	public String getFooterUrl(){
		return '{!FooterUrl}';
	}

	public String getFirstName(){
		return '{!Receiving_User.FirstName}' ;
	}

	public String getCommunityUrl(){
		return '{!Community_Url}';
	}

}
