public without sharing class TIDS_Constant {
    public final static String RT_AIRLINE_BRANCH = 'AIRLINE BRANCH';
    public final static String RT_AIRLINE_HEADQUARTERS = 'AIRLINE HEADQUARTERS';
    public final static String RT_GENERAL_SALES_AGENT_HEADQUARTERS = 'GENERAL SALES AGENT HEADQUARTERS';
    public final static String RT_ICAO_MEMBER_STATE = 'ICAO MEMBER STATE';
    public final static String RT_AIRLINE_LOCAL_OFFICES='AIRLINE LOCAL OFFICES';
    public final static String RT_OPERATOR='OPERATOR';
    public final static String RT_VERIFIER='VERIFIER';
    public final static String RT_AIRPORT='AIRPORT';
    public final static String RT_AGENCY = 'AGENCY';
    public final static String RT_IATA_AGENCY = 'AGENCY';

    public final static String ERROR_CON1 = 'TIDS_ACCES_COND1';
    public final static String ERROR_CON2_1 = 'TIDS_ACCES_COND2_1';
    public final static String ERROR_CON2_2 = 'TIDS_ACCES_COND2_2';
    public final static String ERROR_CON3 = 'TIDS_ACCES_COND3';
    public final static String ERROR_CON4 = 'TIDS_ACCES_COND4';
    public final static String ERROR_CON4_1 = 'TIDS_ACCES_COND4_1';
    public final static String ERROR_CON4_2 = 'TIDS_ACCES_COND4_2';
    public final static String ERROR_CON5 = 'TIDS_ACCES_COND5';
    public final static String ERROR_CON6 = 'TIDS_ACCES_COND6';
    public final static String ERROR_CON7_1 = 'TIDS_ACCES_COND7_1';
    public final static String ERROR_CON7_2 = 'TIDS_ACCES_COND7_2';
    public final static String ERROR_CON7_3 = 'TIDS_ACCES_COND7_3';
    public final static String VETTING_DONE = 'TIDS_VETTING_DONE';
    // Case subjects
    public final static String CASE_SUBJECT_RELINQUISH='TIDS – Head Office Relinquishment';
    public final static String CASE_SUBJECT_HEAD_OFFICE = 'TIDS - Head Office Application';
    public final static String CASE_SUBJECT_BRANCH = 'TIDS - Branch Office Application';
    public final static String CASE_SUBJECT_VIRTUAL_BRANCH = 'TIDS - Virtual Branch Office Application';
    public final static String CASE_SUBJECT_NAME_COMPANY = 'TIDS - Change of Name or Company Details';
    public final static String CASE_SUBJECT_ADDRESS_CONTACT = 'TIDS - Change of Address or Contact Details';
    public final static String CASE_SUBJECT_BUSINESS_PROFILE_SPECIALIZATION = 'TIDS - Change of Business Profile or Specialization';
    // Duplicate account
    public final static String ERROR_CON8 = 'TIDS_ACCES_COND8';
    public final static String DATAJSONFILENAME = 'data.json';
    public final static String TIDSCONFIGURATIONFILE='tids-configuration.json';
    public final static String TIDSVALUE = 'TIDS';
    public final static String STATEISOCODE = 'CA-PE';
    public final static String GROUPS = 'TIDS Team';
    public final static String CASE_AREA = 'TIDS';
    public final static String CASE_PRIORITY = 'Normal';
    public final static String CASE_ORIGIN = 'TIDS Online Portal';

    public final static String NEW_BR='NEW_BR';
    public final static String NEW_VB='NEW_VB';
    public final static String NEW_HO='NEW_HO';
    public final static String ADM_HOS='TIDS Admin HO Secondary';
    public final static String ADM_HOP='TIDS Admin HO Primary';
    public final static String ADM_BRA='TIDS Branch Administrator';

    //NOTIFICATION
    public final static String NTF_APPROVED_VB='TIDS_VB_Service_Request_Approved_Notification';
    public final static String NTF_APPROVED_RL='TIDS_Relinquish_Request_Approved_Notification';
    public final static String NTF_APPROVED_RE='TIDS_Reinstate_Request_Approved_Notification';
    public final static String NTF_REJECTED_VB='TIDS_VB_Service_Request_Rejected_Notification';
    public final static String NTF_REJECTED_RL='TIDS_Relinquish_Request_Rejected_Notification';
    public final static String NTF_REJECTED_RE='TIDS_Reinstate_Request_Rejected_Notification';

    //Statues
    public final static String IS_REVIEWED= 'Pending Review';
    public final static String IS_DRAFT='Draft';
    public final static String IS_CLOSED='Closed';
    public final static String IS_INPROGRESS='Review in Progress';
    public final static String IS_CUSTOMER='Pending Customer';
    public final static String IS_APPROVED='Approved';
    public final static String IS_REJECTED='Rejected';

    public final static String CHG_NAME='chg-name-company';
    public final static String CHG_ADDRESS='chg-address-contact';
    public final static String CHG_PROFILE='chg-business-profile-specialization';

    //Message Errors
    public final static String MSG1='Case Not Found.';
    public final static String MSG2='Case already assigned to a different user agent.';
    public final static String MSG3='Duplicate Account';
    public final static String MSG4='Case Permissions are missing for your profile.';
    public final static String MSG5='Your deadline for reinstatement will be available within 24 hours.';

    //Error Messages
    public final static String MSG11 ='This application appears to have already been approved by IATA. Please verify the status of this account in Salesforce. You may now close this tab in your browser.';
    public final static String MSG12 ='Case Permissions are missing for your profile.';
    public final static String MSG13 ='Email Template Permissions are missing for your profile.';
    public final static String MSG14 ='Contact Permissions are missing for your profile.';
    public final static String MSG15 ='ISO State Permissions are missing for your profile.';
    public final static String MSG16 ='IATA Code Generator is locked by another IATA Agent, please try again...';
    public final static String MSG17 ='Case Comment Permissions are missing for your profile';

    public final static String MSG23 ='Email Template Permissions are missing for your profile.';
	public final static String MSG24 ='Contact Permissions are missing for your profile.';
	public final static String MSG31='Sorry, the request is now closed.';
	public final static String MSG32='Thank you, the request is now closed and approved.';
	public final static String MSG33='Please retry tomorrow.';
	public final static String MSG34='Error missing permissions.';
	public final static String MSG35='Thank you, the request is now closed and rejected.';
	
}