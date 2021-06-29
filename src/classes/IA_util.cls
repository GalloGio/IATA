public with sharing class IA_util {

	// Library name where Interline agreement reports are stored
	public static final String LIBRARY_CS_NAME = 'Interline Memorandums Library Name';
	public static final String LIBRARY_CS = ISSP_CS__c.getValues(LIBRARY_CS_NAME)!=null? ISSP_CS__c.getValues(LIBRARY_CS_NAME).Value__c: null;

	// Type of contacts
	public static final String GENERIC_CONTACT = 'Interline Airline Generic Contact';
	public static final String CARGO_MANAGER = 'Interline Cargo Agreement Manager';
	public static final String PAX_MANAGER = 'Interline Passenger Agreement Manager';
	public static final String PAX_PROTECTION = 'Passenger Protection Agreement';
	public static final list<String> LIST_MITA_CONTACTS = new list<String>{GENERIC_CONTACT,CARGO_MANAGER,PAX_MANAGER,PAX_PROTECTION};
	public static final Map<String,String> MAP_MITA_CONTACT_TYPE_LABELS = new Map<String,String>{
		GENERIC_CONTACT => Label.IA_Description_Interline_Airline_Generic_Contact,
		CARGO_MANAGER => Label.IA_Description_Interline_Cargo_Agreement_Manager,
		PAX_MANAGER => Label.IA_Description_Interline_Passenger_Agreement_Manager,
		PAX_PROTECTION => Label.IA_Description_Passenger_Protection_Manager
	};

	public static final String CONCURRENCES = 'Concurrences';
	public static final String WITHDRAWALS = 'Withdrawals';
	public static final list<String> MEMO_TYPES = new list<String>{CONCURRENCES,WITHDRAWALS};

	public static final String MITA = 'MITA';
	public static final String BIETA = 'BIETA';
	public static final String EMD = 'EMD';
	public static final List<String> AGREEMENT_TYPES = new List<String>{MITA,BIETA,EMD};

	//Agreement Picklist values
	public static final String REASON_REJECTION = 'Rejected by Airline 2';
	public static final String REASON_CANCELLATION_AIRLINE1 = 'Airline 1 leaves agreement';
	public static final String REASON_CANCELLATION_AIRLINE2 = 'Airline 2 leaves agreement';
	public static final String REASON_REQUESTED_AIRLINE1 = 'Requested by Airline 1';
	public static final String REASON_REQUESTED_AIRLINE2 = 'Requested by Airline 2';
	public static final String STATUS_ACTIVE = 'Active';
	public static final String STATUS_PENDING_APPROVAL = 'Pending Approval';
	public static final String STATUS_NOT_ACTIVE_YET = 'Not Active Yet';
	public static final String STATUS_PENDING_WITHDRAWAL = 'Pending Withdrawal';
	public static final String STATUS_REJECTED = 'Rejected';
	public static final String STATUS_WITHDRAWN = 'Withdrawn';
	public static final Map<String,String> MAP_STATUS_LABELS = new Map<String,String>{
		STATUS_ACTIVE => Label.ISSP_Active,
		STATUS_PENDING_APPROVAL => Label.ISSP_Pending_Approval,
		STATUS_NOT_ACTIVE_YET => Label.IA_Status_not_active_yet,
		STATUS_PENDING_WITHDRAWAL => Label.IA_Status_pending_withdrawal,
		STATUS_REJECTED => Label.IA_Status_rejected,
		STATUS_WITHDRAWN => Label.IA_Status_withdrawn
	};

	// MITA Agreements
	public static final String TYPE_PAX_CARGO = 'The Passenger and Cargo Interline Traffic Agreement';
	public static final String TYPE_PAX = 'The Passenger Interline Agreement';
	public static final String TYPE_CARGO = 'The Cargo Interline Agreement';
	public static final String TYPE_ISSUING_AIRLINE = 'The One Way Issuing Airline';
	public static final String TYPE_PARTICIPATING_AIRLINE = 'The One Way Participating Airline';

	// BIETA Agreements
	public static final String TYPE_BILATERAL = 'Bilateral, both carriers can issue electronic tickets';
	public static final String TYPE_PAX_ISSUING_AIRLINE = 'One Way Passenger Issuing Airline';
	public static final String TYPE_PAX_PARTICIPATING_AIRLINE = 'One Way Passenger Participating';
	public static final String TYPE_IMOD_ISSUING_AIRLINE = 'One Way Intermodal Issuing Date';
	public static final String TYPE_IMOD_PARTICIPATING_AIRLINE = 'One Way Intermodal Participating Date';

	public static final String TYPE_EMD = 'Electronic Miscellaneous Document';

	public static final Map<String,List<String>> MAP_AGREEMENTS_BY_TYPE = new Map<String,List<String>>{
		MITA => new List<String>{TYPE_PAX,TYPE_CARGO,TYPE_ISSUING_AIRLINE,TYPE_PARTICIPATING_AIRLINE},
		BIETA => new List<String>{TYPE_BILATERAL,TYPE_PAX_ISSUING_AIRLINE,TYPE_PAX_PARTICIPATING_AIRLINE,TYPE_IMOD_ISSUING_AIRLINE,TYPE_IMOD_PARTICIPATING_AIRLINE},
		EMD => new List<String>{TYPE_EMD}
	};

	public static final Map<String,String> MAP_AGREEMENTS_BY_NAME = new Map<String,String>{
		TYPE_PAX_CARGO => MITA,
		TYPE_PAX => MITA,
		TYPE_CARGO => MITA,
		TYPE_ISSUING_AIRLINE => MITA,
		TYPE_PARTICIPATING_AIRLINE => MITA,
		TYPE_BILATERAL => BIETA,
		TYPE_PAX_ISSUING_AIRLINE => BIETA,
		TYPE_PAX_PARTICIPATING_AIRLINE => BIETA,
		TYPE_IMOD_ISSUING_AIRLINE => BIETA,
		TYPE_IMOD_PARTICIPATING_AIRLINE => BIETA,
		TYPE_EMD => EMD
	};

	public static final map<String, String> MAP_ONE_WAY_TYPES = new map<String,String>{
		TYPE_ISSUING_AIRLINE => TYPE_PARTICIPATING_AIRLINE,
		TYPE_PARTICIPATING_AIRLINE => TYPE_ISSUING_AIRLINE,
		TYPE_PAX_ISSUING_AIRLINE => TYPE_PAX_PARTICIPATING_AIRLINE,
		TYPE_PAX_PARTICIPATING_AIRLINE => TYPE_PAX_ISSUING_AIRLINE,
		TYPE_IMOD_ISSUING_AIRLINE => TYPE_IMOD_PARTICIPATING_AIRLINE,
		TYPE_IMOD_PARTICIPATING_AIRLINE => TYPE_IMOD_ISSUING_AIRLINE
	};

	public static final List<String> LIST_MITA_FIELDS = new List<String>{
		'MITA_IATA_Interline_Passenger__c',
		'MITA_IATA_Interline_Cargo__c',
		'MITA_One_way_Pass_Issuing_Airline__c',
		'MITA_One_way_Pass_Participating__c'
	};

	public static final List<String> LIST_BIETA_FIELDS = new List<String>{
		'BIETA_Bilateral_Date__c',
		'BIETA_One_way_Electronic_Issuing_Airline__c',
		'BIETA_One_way_Electronic_Participating__c',
		'BIETA_One_way_Intermodal_Issuing_Airline__c',
		'BIETA_One_way_Intermodal_Participating__c'
	};

	public static final Map<String,String> MAP_AGREEMENT_FIELDS = new Map<String,String>{
		'MITA_IATA_Interline_Passenger__c'=>TYPE_PAX,
		'MITA_IATA_Interline_Cargo__c'=>TYPE_CARGO,
		'MITA_One_way_Pass_Issuing_Airline__c'=>TYPE_ISSUING_AIRLINE,
		'MITA_One_way_Pass_Participating__c'=>TYPE_PARTICIPATING_AIRLINE,
		'BIETA_Bilateral_Date__c'=>TYPE_BILATERAL,
		'BIETA_One_way_Electronic_Issuing_Airline__c'=>TYPE_PAX_ISSUING_AIRLINE,
		'BIETA_One_way_Electronic_Participating__c'=>TYPE_PAX_PARTICIPATING_AIRLINE,
		'BIETA_One_way_Intermodal_Issuing_Airline__c'=>TYPE_IMOD_ISSUING_AIRLINE,
		'BIETA_One_way_Intermodal_Participating__c'=>TYPE_IMOD_PARTICIPATING_AIRLINE
	};

	public static final Map<String,String> MAP_AGREEMENT_LABELS = new Map<String,String>{
		TYPE_PAX_CARGO =>Label.ISSP_The_Passenger_and_Cargo_Interline_Traffic_Agreement,
		TYPE_PAX =>Label.ISSP_The_Passenger_Interline_Agreement,
		TYPE_CARGO =>Label.ISSP_The_Cargo_Interline_Agreement,
		TYPE_ISSUING_AIRLINE =>Label.ISSP_The_One_Way_Issuing_Airline,
		TYPE_PARTICIPATING_AIRLINE =>Label.ISSP_The_One_Way_Participating_Airline,
		TYPE_BILATERAL =>Label.ISSP_Bilateral_both_carriers_can_issue_electronic_tickets,
		TYPE_PAX_ISSUING_AIRLINE =>Label.ISSP_One_Way_Passenger_Issuing_Airline,
		TYPE_PAX_PARTICIPATING_AIRLINE =>Label.ISSP_One_Way_Passenger_Participating,
		TYPE_IMOD_ISSUING_AIRLINE =>Label.ISSP_One_Way_Intermodal_Issuing_Date,
		TYPE_IMOD_PARTICIPATING_AIRLINE =>Label.ISSP_One_Way_Intermodal_Participating_Date,
		TYPE_EMD => TYPE_EMD
	};

	public static final Integer DAYS_TO_WAIT_FOR_WITHDRAWAL = 7;

	public static final String ALERTMODAL_ERROR = 'errorMsg';
	public static final String ALERTMODAL_WARNING = 'Warning';
	public static final String ALERTMODAL_SUCCESSNEW = 'successMsgNew';
	// class to handle alert messages in the portal using the c:ISSP_AlertModal
	// also reused as a wrapper to be used with js class toastify.js
	public class AlertModal {
		public String msgType {get;set;}
		public String msgTitle {get;set;}
		public String msgHeader {get;set;}
		public String msgBody {get;set;}
		public String undoid {get;set;}
		public AlertModal (String mType, String mTitle, String mHeader, String mBody) {
			msgType = mType;
			msgTitle = mTitle;
			msgHeader = mHeader;
			msgBody = mBody;
		}
		public AlertModal (String mType, String mTitle, String mUndoid) {
			msgType = mType;
			msgTitle = mTitle;
			undoId = mUndoId;
		}
	}

	public static String dateformat(DateTime dt) {
		return dt == null ? '-': dt.format('d MMM yyyy');
	}

	public static String encrypt(Blob key, String IdToEncrypt){
		Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(IdToEncrypt));
		return EncodingUtil.base64Encode(cipherText);
	}

	public static String decrypt(Blob key, String idToDecrypt){
		try {
			Blob encodedEncryptedBlob = EncodingUtil.base64Decode(idToDecrypt);
			return Crypto.decryptWithManagedIV('AES128', key, encodedEncryptedBlob).toString();
		} catch(Exception e) {
			return null;
		}
	}

	public static String randomString(Integer count) {
		Integer[] chars = new Integer[0],
			offsets = new Integer[] { 48, 65, 97 },
				mods = new Integer[] { 10, 26, 26 };
	
		while(count > chars.size()) {
			Integer cat = Math.abs(Math.mod(Crypto.getRandomInteger(),3));
			chars.add(Math.mod(Math.abs(Crypto.getRandomInteger()), mods[cat])+offsets[cat]);
		}
		return String.fromCharArray(chars);
	}

	public static list<SelectOption> setToOptions(Set<String> setValues, map<String,String> mapLabels) {
		list<SelectOption> listOptions = new list<SelectOption>();
		list<String> listValues = new list<String>(setValues);
		listValues.sort();
		for (String value: listValues) {
			String label = mapLabels==null? value: mapLabels.get(value);
			listOptions.add(new SelectOption(value, label));
		}
		return listOptions;
	}

	public class MitaType {
		public String name {get;set;}
		public String description {get;set;}

		public MitaType(String mitaType) {
			this.name = mitaType.trim();
			this.description = MAP_MITA_CONTACT_TYPE_LABELS.get(this.name);
		}
	}
}
