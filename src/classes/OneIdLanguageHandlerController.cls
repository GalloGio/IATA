/**
 * @description Controller pex class for Language Handler
 *              lightning component
 *
 *
 * @creation  2017-04-04
 * @category  Controller
 * @package   LanguageHandler
 * @author    Paulo Bastos <paulo.bastos@rightitservices.com>
 * @copyright 2017 Rightit Services
 * @license   Copyright Rightit Services.
 *            All rights reserved.
 *            Reproduction in whole or part is
 *            prohibited without written consent of
 *            the copyright owner.
 * @link      http://www.rightitservices.com
 */
public class OneIdLanguageHandlerController {
	public class LanguageHandlerModel {
		//static maps
		public List<LanguageHandlerCustMT__mdt> languages;
		public String currentLanguage='en_US';
	}

	public static LanguageHandlerModel LanguageInfo;
	public static User currentUser;

	/*******************************************************************************************************
	* @description Initializes Languages list retriving the languages (sets languages controller attribute)
	* codes and descriptions from Custom Metadata Type called LanguageHandlerCustMT__mdt
	* where fields:
	*     DeveloperName --> language code
	*     MasterLabel   --> language description
	*
	* @example
	* initLanguageInfo();
	*/
	public static void initLanguageInfo(){
		//Get current user current language info
		if (Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.Fields.LanguageLocaleKey.isAccessible()) {
			currentUser = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		}
		else
		{
			currentUser.LanguageLocaleKey=null;
		}

		LanguageInfo=new LanguageHandlerModel();
		LanguageInfo.currentLanguage=currentUser.LanguageLocaleKey;

		//Get all language values from cutoms setting
		//languages = LanguageHandlerCustSet__c.getall().values();
		LanguageInfo.languages = [SELECT DeveloperName, MasterLabel FROM LanguageHandlerCustMT__mdt ORDER BY MasterLabel ASC];
	}

	/*******************************************************************************************************
   * @description Returns Languages Handler tool list of support languages
   *
   * @return {List<LanguageHandlerCustMT__mdt>} languages - Returns list of languages.
   *
   * @example
   * getLanguages();
   */
	@AuraEnabled
    //public static List<LanguageHandlerCustSet__c> getLanguages(){
	public static String getLanguageInfo(){
		initLanguageInfo();
		return JSON.serialize(LanguageInfo);
	}


	/*******************************************************************************************************
    * @description Changes current language to the given one
    *
    * @param {string} newLanguage - New language code
    *
    * @return {string} currentLanguage - Return the new language set.
    *
    * @example
    * changeLanguage('pt_BR');
    */
	@AuraEnabled
	public static String changeLanguage(String newLanguage) {
		initLanguageInfo();
		System.debug('APEX LanguageHandlerController.changeLanguage newLanguage='+newLanguage);


		//Change user sales force language if user logged
		if (Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.Fields.LanguageLocaleKey.isAccessible()){
			if (newLanguage != null && currentUser.LanguageLocaleKey != newLanguage
					&& Schema.SObjectType.User.isUpdateable()
					&& Schema.SObjectType.User.Fields.LanguageLocaleKey.isUpdateable()
			){
				currentUser.LanguageLocaleKey = newLanguage;
				update currentUser;
				System.debug('APEX LanguageHandlerController.changeLanguage Updated User language settings in sales force');
			}
		}

		LanguageInfo.currentLanguage=newLanguage;

		return LanguageInfo.currentLanguage;
	}
}