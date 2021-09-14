public without sharing class TIDS_Constant {
	public final static String RT_AIRLINE_BRANCH = 'IATA_Airline_BR';
	public final static String RT_AGENCY= 'IATA_Agency';
	public final static String RT_AIRLINE_HEADQUARTERS = 'IATA_Airline';
	public final static String RT_GENERAL_SALES_AGENT_HEADQUARTERS = 'IATA_GSA';
	public final static String RT_ICAO_MEMBER_STATE = 'ICAO_Member_State';
	public final static String RT_AIRLINE_LOCAL_OFFICES='Branch';
	public final static String RT_OPERATOR='Operator';
	public final static String RT_VERIFIER='Verifiers';
	public final static String RT_AIRPORT='Airport';

	public final static String ERROR_CON0_1 = 'TIDS_ACCES_COND0';
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
	public final static String TIDS_ADM_EMAIL='TIDS_ADM_EMAIL';
	public final static String CASCADE_PASSWORD='TIDS_CASCADE_PASSWORD';

	public final static String NEW_AGENT='New agent';
	// Case subjects
	public final static String CASE_REASON_RELINQUISH='TIDS – Relinquishment';
	public final static String CASE_REASON_REINSTATEMENT='TIDS – Reinstatement';
	public final static String CASE_SUBJECT_RELINQUISH='TIDS – Head Office Relinquishment';
	public final static String CASE_SUBJECT_BRANCH_RELINQUISH='TIDS – Branch Office Relinquishment';
	public final static String CASE_SUBJECT_VIRTUAL_RELINQUISH='TIDS – Virtual Branch Relinquishment';
	public final static String CASE_SUBJECT_REINSTATE='TIDS – Head Office Reinstatement';
	public final static String CASE_SUBJECT_BRANCH_REINSTATE='TIDS – Branch Office Reinstatement';
	public final static String CASE_SUBJECT_VIRTUAL_REINSTATE='TIDS – Virtual Branch Reinstatement';
	public final static String CASE_SUBJECT_HEAD_OFFICE = 'TIDS - Head Office Application';
	public final static String CASE_SUBJECT_BRANCH = 'TIDS - Branch Office Application';
	public final static String CASE_SUBJECT_VIRTUAL_BRANCH = 'TIDS - Virtual Branch Office Application';
	public final static String CASE_SUBJECT_VIRTUAL_ACCREQ= 'TIDS – Virtual Branch Access Request';
	public final static String CASE_SUBJECT_NAME_COMPANY = 'TIDS - Change of Name or Company Details';
	public final static String CASE_SUBJECT_ADDRESS_CONTACT = 'TIDS - Change of Address or Contact Details';
	public final static String CASE_SUBJECT_CHANGE_BUS_PROFILE = 'TIDS - Change of Business Profile Specialization';
	public final static String CASE_SUBJECT_BUSINESS_PROFILE_SPECIALIZATION = 'TIDS - Change of Business Profile or Specialization';
	
	public final static String ERROR_CON8 = 'TIDS_ACCES_COND8';
	public final static String DATAJSONFILENAME = 'data.json';
	public final static String TIDSCONFIGURATIONFILE='tids-configuration.json';
	public final static String TIDSTERMSANDCONDITIONS='TIDS_Terms_and_Conditions.pdf';
	public final static String TIDSVALUE = 'TIDS';
	public final static String STATEISOCODE = 'CA-PE';
	public final static String GROUPS = 'TIDS Team';
	public final static String CASE_AREA = 'TIDS';
	public final static String CASE_PRIORITY = 'Normal';
	public final static String CASE_ORIGIN = 'TIDS Online Portal';

	public final static String NEW_BR='NEW_BR';
	public final static String NEW_VB='NEW_VB';
	public final static String NEW_HO='NEW_HO';

	public final static String RELINQ_HO = 'request-relinquish-ho';
	public final static String RELINQ_VB = 'request-relinquish-vb';
	public final static String RELINQ_BR = 'request-relinquish-br';
	public final static String REINSTATE_HO = 'request-reinstate-ho';
	public final static String REINSTATE_BR = 'request-reinstate-br';
	public final static String REINSTATE_VB = 'request-reinstate-vb';

	public final static String CHG_NAME='chg-name-company';
	public final static String CHG_ADDRESS='chg-address-contact';
	public final static String CHG_PROFILE='chg-business-profile-specialization';
	public final static String RQT_VIRTUALB='request-virtual-branch-service';

	public final static String TIDS_T='T';
	public final static String TIDS_BR='BR';
	public final static String TIDS_VB='VB';
	public final static String TIDS_HO='HO';
	public final static String ADM_HOS='TIDS Admin HO Secondary';
	public final static String ADM_HOP='TIDS Admin HO Primary';
	public final static String ADM_BRA='TIDS Branch Administrator';
	public final static String NEW_APP='TIDS - new HO Application';
	public final static String TIDS_VOL='Voluntary Relinquishment';

	//Actions
	public final static String ACTION_VETTING='vetting';
	public final static String ACTION_DISCARD='discard';
	public final static String ACTION_RECALL='recall';
	public final static String ACTION_RESUME='resume';
	public final static String ACTION_MAILING='mailing';

	//Decision
	public final static String DECISION_AUTOAPPROVED='AUTO-APPROVED';
	public final static String DECISION_APPROVED='APPROVED';
	public final static String DECISION_REJECTED='REJECTED';

	//GEONAME
	public final static String  GEONAME_URL_CODEPOSTAL = 'TIDS_GEONAME_URL_CODEPOSTAL';
	public final static String  GEONAME_URL_CITY = 'TIDS_GEONAME_URL_CITY';

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
	public final static String IS_ACTIVE='Active';
	public final static String IS_ABANDONED='Abandoned';
	public final static String IS_TERMINATED='Terminated';
	public final static String IS_REJECTED='Rejected';
	public final static String IS_APPREJECTED='Application Rejected';

	public final static String TIDS_ACTION_ADD='add';
	public final static String TIDS_ACTION_REMOVE='remove';
	public final static String TIDS_ACTION_SWAP='swap';
	
	//Message Errors
	public final static String MSG1='TIDS_MSG1';
	public final static String MSG2='TIDS_MSG2';
	public final static String MSG3='TIDS_MSG3';
	public final static String MSG4='TIDS_MSG4';
	public final static String MSG5='TIDS_MSG5';
	public final static String MSG6='TIDS_MSG6';
	public final static String MSG7='TIDS_MSG7';


	//Error Messages
	public final static String MSG11 ='TIDS_MSG11';
	public final static String MSG13 ='TIDS_MSG13';
	public final static String MSG14 ='TIDS_MSG14';
	public final static String MSG15 ='TIDS_MSG15';
	public final static String MSG16 ='TIDS_MSG16';
	public final static String MSG17 ='TIDS_MSG17';

	public final static String MSG23='TIDS_MSG23';
	public final static String MSG24='TIDS_MSG24';
	public final static String MSG31='TIDS_MSG31';
	public final static String MSG32='TIDS_MSG32';
	public final static String MSG33='TIDS_MSG33';
	public final static String MSG34='TIDS_MSG34';
	public final static String MSG35='TIDS_MSG35';
	public final static String MSG40='TIDS_MSG40';
	public final static String MSG41='TIDS_MSG41';
	public final static String MSG42='TIDS_MSG42';
	public final static String MSG43='TIDS_MSG43'; 
	public final static String MSG44='TIDS_MSG44';
	public final static String MSG45='TIDS_MSG45';
}