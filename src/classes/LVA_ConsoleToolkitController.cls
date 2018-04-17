/*
Class Name: LVA_ConsoleToolkitController
Related Classes/Pages: LiveAgentConsoleToolkit.

Copyright © IATA

Purpose: This class aims to handle live agent console in terms of handling agent custom events like
         onChatRequest, onAgentStatusChanged, stc...

VERSION  AUTHOR                                    DATE              DETAIL/CHANGE REFERENCE
1.0 -    paulo.bastos@rightitservices.com          23/10/2017        Initial development

*/
public class LVA_ConsoleToolkitController {
	/*****************************************
	* Configuration Parameters               *
	******************************************/
	//List of suppervisor profiles
	public static final String LVA_CFG_SUPERV_PROFILES   = 'LVA_CFG_SUPERV_PROFILES';

	//Alert mode configured paramter
	public static final String LVA_CONSOLE_ALERT_MODE='LVA_CONSOLE_ALERT_MODE';
	public static final String LVA_CONSOLE_ALERT_IS_ACCUMULATIVE='LVA_CONSOLE_ALERT_IS_ACCUMULATIVE';

	//ALERTS MODES
	public static final String LVA_CONSOLE_ALERT_MODE_DIALOG='LVA_CONSOLE_ALERT_MODE_DIALOG';
	public static final String LVA_CONSOLE_ALERT_MODE_POPUP='LVA_CONSOLE_ALERT_MODE_POPUP';
	public static final String LVA_CONSOLE_ALERT_MODE_ALERT='LVA_CONSOLE_ALERT_MODE_ALERT';
	public static final String LVA_CONSOLE_ALERT_MODE_NOTIFICATION='LVA_CONSOLE_ALERT_MODE_NOTIFICATION';


	//List of supervisor profiles attribute
	private static Set<Id> listSupervisorProfileIds;

	public static String lvaChatConsoleAlertMode{
		get{
			String retVal=vfISSP_FAQ2Case.getLivAgConfig(LVA_CONSOLE_ALERT_MODE);
			System.debug('basto1p - isChatSupervisor.retVal=' + retVal);
			return retVal;
		}
		set;
	}
	public static Boolean isChatSupervisor {
		get{
			Boolean retVal=false;
			if (listSupervisorProfileIds.contains(UserInfo.getProfileId())) {
				retVal=true;
			}

			System.debug('basto1p - isChatSupervisor.retVal=' + retVal);
			return retVal;
		}
		set;
	}
	public static Id myUserId {
		get{
			return UserInfo.getUserId();
		}
		set;
	}
	public static Boolean isAccumulative {
		get{
			return Boolean.valueOf(vfISSP_FAQ2Case.getLivAgConfig(LVA_CONSOLE_ALERT_IS_ACCUMULATIVE));
		}
		set;
	}


	/*******************************************************************************************************
    * @description Class constructor: initializes listSupervisorProfileIds according with list of profiles
    *              names liested separated by coma in parameter LVA_CFG_SUPERV_PROFILES from LVA_Configs__mdt
    *
    *
    * @return {Void} Updates this class static variable listSupervisorProfileIds
    *
    * @example
    * this.LVA_ConsoleToolkitController();
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-10-23   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
	public LVA_ConsoleToolkitController(){

		initConfigs();
	}

	/*******************************************************************************************************
    * @description initializes listSupervisorProfileIds according with list of profiles
    *              names liested separated by coma in parameter LVA_CFG_SUPERV_PROFILES from LVA_Configs__mdt
    *
    *
    * @return {Void} Updates this class static variable listSupervisorProfileIds
    *
    * @example
    * this.LVA_ConsoleToolkitController();
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-10-23   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
	public static void initConfigs(){
		Set<String> listOfSuervisorProfilesNames =
				new Set<String>(vfISSP_FAQ2Case.getLivAgConfig(LVA_CFG_SUPERV_PROFILES).split(','));

		List<Profile> profilesListAux=
				new List<Profile>([SELECT Id
						FROM Profile
						WHERE Name
				IN : listOfSuervisorProfilesNames]);

		listSupervisorProfileIds=(new Map<Id,Profile>(profilesListAux)).keySet();
	}
}