public without sharing class IECUtil {
	// payment method type used in salesforce
	public enum PaymentMethodType {BANK_TRANSFER, ICH, CREDIT_CARD}

	public static final String CLIENTTYPE_MEMBERAIRLINE = 'Member Airline';
	public static final String CLIENTTYPE_THIRDPARTY = 'Third Party';
	
	public static final String ZUORA_PAYMENTMETHODTYPE_OTHER = 'Other';	// ICH
	public static final String ZUORA_PAYMENTMETHODTYPE_BANKTRANSFER = 'BankTransfer'; 
	public static final String ZUORA_PAYMENTMETHODTYPE_CREDITCARD = 'CreditCard';

    public enum DomainValidation {
                                   	NOTMATCHINGDOMAINS, //Used when email does NOT match any domain registered under the account nor parent account
                                   	MATCHINGDOMAIN, 	//Used when email does match one domain registered under the account or parent account
                                    NOREGISTEREDDOMAIN,	//Used when no domain is registered under the account nor parent account
                                   	ERROR				//Used when no domain is registered under the account nor parent account
                                }    
	

	//private static final String ENCRYPTION_ALGORYTHM = 'AES128';
	
	/**
	 * Encrypts a string to be used as a GET parameter
	 * @param sValue The string parameter to encrypt
	 * @return The Encrypted parameter
	 */
	public static String EncryptParameter(String sValue) {
		if (sValue == null || sValue == '')
			throw new IECApplicationException('sValue parameter is null or empty');
		return EncryptString(IECConstants.ENCRYPTION_KEY, sValue);
	}
	
	/**
	 * Encrypts and URL encode a string to be used as a GET parameter
	 * @param sValue The string parameter to encrypt and encode
	 * @return The Encrypted/encoded parameter
	 */
	public static String EncryptEncodeParameter(String sValue) {
		if (sValue == null || sValue == '')
			throw new IECApplicationException('sValue parameter is null or empty');
		return EncodingUtil.urlEncode(EncryptString(IECConstants.ENCRYPTION_KEY, sValue), 'UTF-8');
	}
	
	/**
	 * Decrypts a string
	 * @param sValue The string parameter to decrypt
	 * @return The decrypted parameter
	 */
	public static String DecryptParameter(String sValue) {
		if (sValue == null || sValue == '')
			throw new IECApplicationException('Nothing to decrypt');
			
		try {
			return DecryptString(IECConstants.ENCRYPTION_KEY, sValue);
		}
		catch (Exception ex) {
			throw new IECApplicationException('Invalid parameter. Error: ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString());
		}
	}
	
	/**
	 * URL decode and decrypts a string
	 * @param sValue The string parameter to decrypt/decode
	 * @return The decrypted/decoded parameter
	 */
	public static String DecodeDecryptParameter(String sValue) {
		if (sValue == null || sValue == '')
			throw new IECApplicationException('Nothing to decrypt');
			
		try {
			return DecryptString(IECConstants.ENCRYPTION_KEY, Encodingutil.urlDecode(sValue, 'UTF-8'));
		}
		catch (Exception ex) {
			throw new IECApplicationException('Invalid parameter. Error: ' + ex.getMessage());
		}
	}
	
	/**
	 * Generates a new GUID
	 * @return A new GUID as a string
	 */
    public static String NewGuid() {

		String kHexChars = '0123456789abcdef';
        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }
    
    /**
     * Returns the SelectOption Label based on a value
     */
    public static String getSelectOptionLabelFromValue(List<SelectOption> listOptions, String value) {
		for (SelectOption option : listOptions) {
			if (option.getValue() == value)
				return option.getLabel();
		}
		return '';
	}
	
	/////////////////////////////////////////////////////////////////////////////////////
	// Private methods
	
	/**
	 * Encrypts a string
	 * @param key The key to use to encrypt
	 * @param str The String to encrypt
	 * @return The encrypted string
	 */
	private static String EncryptString(String key, String str) {
		Blob dataToEncrypt = Blob.valueOf(str);
		Blob encryptedData = Crypto.encryptWithManagedIV(IECConstants.ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), dataToEncrypt);
		return EncodingUtil.base64Encode(encryptedData);
	}
	
	/**
	 * Decrypts a string
	 * @param key The key to use to decrypt
	 * @param str The encrypted string
	 * @return The decrypted string
	 */
	private static String DecryptString(String key, String str) {
	 	Blob encryptedData = Encodingutil.base64Decode(str);
	 	Blob decryptedData = Crypto.decryptWithManagedIV(IECConstants.ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), encryptedData);
	 	return decryptedData.toString();
	}
	
	private static String getCharAtIndex(String str, Integer index){
        if (str == null) 
        	return null;

        if (str.length() <= 0) 
        	return str;    

        if (index == str.length()) 
        	return null;    

        return str.substring(index, index+1);
    }
    
	/**
	 * Retrieves the URL from the Resource Name
	 * @param resourceName Resource Name as defined in Salesforce
	 * @return The URL for the specified resource
	 *
	public static String GetResourceURL(String resourceName){
		// Fetching the resource
		List<StaticResource> resourceList =
			[SELECT Name, NamespacePrefix, SystemModStamp
			FROM StaticResource
			WHERE Name = :resourceName];
		
		// Checking if the result is returned or not
		if(resourceList.size() == 1) {
			// Getting namespace
			String namespace = resourceList[0].NamespacePrefix;
			// Resource URL
			return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
		}
		else return '';
	}
	*/

	public static PaymentMethodType toPaymentMethodEnum(String pmValue) {
		if (pmValue == ZUORA_PAYMENTMETHODTYPE_CREDITCARD)
			return PaymentMethodType.CREDIT_CARD;
		else if (pmValue == ZUORA_PAYMENTMETHODTYPE_OTHER)
			return PaymentMethodType.ICH;
		else if (pmValue == ZUORA_PAYMENTMETHODTYPE_BANKTRANSFER)
			return PaymentMethodType.BANK_TRANSFER;
		else
			return null;
	}
	
	/**
	 * Query database to retrieve the list of countries in pairs of Name-Name
	 */    
    public static List<SelectOption> getCountries_NameName() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select a Country-'));
        
        for(IATA_ISO_Country__c iso: IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
        	options.add(new SelectOption(iso.Name,iso.Name));
        }
        return options;
    }
    
	/**
	 * Query database to retrieve the list of countries in pairs of Id-Name
	 */    
    public static List<SelectOption> getCountries_IdName() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select a Country-'));
        
        for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
        	options.add(new SelectOption(iso.Id,iso.Name));
        }
        return options;
    }
    
    /**
     * Returns the State Code of a state based on the name and the country code
     */
    public static String getStateCodeByNameAndCountryCode(String sStateName, String sCountryCode) {
    	
    	if (String.isBlank(sCountryCode))
    		return null;
    	
    	sCountryCode = sCountryCode.toUpperCase();
    	
    	if (sCountryCode == 'CA') {
    		if (sStateName == 'Alberta') return 'AB';
    		if (sStateName == 'British Columbia') return 'BC';
    		if (sStateName == 'Manitoba') return 'MB';
    		if (sStateName == 'New Brunswick') return 'NB';
    		if (sStateName == 'Newfoundland and Labrador') return 'NL';
    		if (sStateName == 'Nova Scotia') return 'NS';
    		if (sStateName == 'Northwest Territories') return 'NT';
    		if (sStateName == 'Nunavut') return 'NU';
    		if (sStateName == 'Ontario') return 'ON';
    		if (sStateName == 'Prince Edward Island') return 'PE';
    		if (sStateName == 'Quebec') return 'QC';
    		if (sStateName == 'Saskatchewan') return 'SK';
    		if (sStateName == 'Yukon') return 'YT';
    	}
    	else if (sCountryCode == 'US') {
    		if (sStateName == 'Alabama') return 'AB';
			if (sStateName == 'Alaska') return 'AK';
			if (sStateName == 'Arizona') return 'AZ';
			if (sStateName == 'Arkansas') return 'AR';
			if (sStateName == 'California') return 'CA';
			if (sStateName == 'Colorado') return 'CO';
			if (sStateName == 'Connecticut') return 'CT';
			if (sStateName == 'Delaware') return 'DE';
			if (sStateName == 'Florida') return 'FL';
			if (sStateName == 'Georgia') return 'GA';
			if (sStateName == 'Hawaii') return 'HI';
			if (sStateName == 'Idaho') return 'ID';
			if (sStateName == 'Illinois') return 'IL';
			if (sStateName == 'Indiana') return 'IN';
			if (sStateName == 'Iowa') return 'IA';
			if (sStateName == 'Kansas') return 'KA';
			if (sStateName == 'Kentucky') return 'KY';
			if (sStateName == 'Louisiana') return 'LA';
			if (sStateName == 'Maine') return 'ME';
			if (sStateName == 'Maryland') return 'MD';
			if (sStateName == 'Massachusetts') return 'MA';
			if (sStateName == 'Michigan') return 'MI';
			if (sStateName == 'Minnesota') return 'MN';
			if (sStateName == 'Mississippi') return 'MS';
			if (sStateName == 'Missouri') return 'MO';
			if (sStateName == 'Montana') return 'MT';
			if (sStateName == 'Nebraska') return 'NE';
			if (sStateName == 'Nevada') return 'NV';
			if (sStateName == 'New Hampshire') return 'NH';
			if (sStateName == 'New Jersey') return 'NJ';
			if (sStateName == 'New Mexico') return 'NM';
			if (sStateName == 'New York') return 'NY';
			if (sStateName == 'North Carolina') return 'NC';
			if (sStateName == 'North Dakota') return 'ND';
			if (sStateName == 'Ohio') return 'OH';
			if (sStateName == 'Oklahoma') return 'OK';
			if (sStateName == 'Oregon') return 'OR';
			if (sStateName == 'Pennsylvania[') return 'PA';
			if (sStateName == 'Rhode Island') return 'RI';
			if (sStateName == 'South Carolina') return 'SC';
			if (sStateName == 'South Dakota') return 'SD';
			if (sStateName == 'Tennessee') return 'TN';
			if (sStateName == 'Texas') return 'TX';
			if (sStateName == 'Utah') return 'UT';
			if (sStateName == 'Vermont') return 'VT';
			if (sStateName == 'Virginia') return 'VA';
			if (sStateName == 'Washington') return 'WA';
			if (sStateName == 'West Virginia') return 'WV';
			if (sStateName == 'Wisconsin') return 'WI';
			if (sStateName == 'Wyoming') return 'WY';
    	}
    	return null;
    }
    
    public static DomainValidation validateContactEmailDomain(String contactEmail, String accountId) {
    	
    	List<String> accIds;
    	List<Account_Domain__c> domains;
    	
    	try {
        
        	//Split email address in 2 components: right and left side of "@"
        	String[] emailSplit = contactEmail.split('@', 2);
        
        	//Validate split address contains 2 elements: user name / domain name
        	//This IF is for security reasons. The email structure validation in the first step of registration process should avoid a return from inside this IF
       		 if (emailSplit == null || emailSplit.size() < 2) 
        	    return DomainValidation.NOTMATCHINGDOMAINS;
        
       		//Get right side of email split
        	String contatDomain = emailSplit[1];

       		//Get Account patent objet, if any
        	Account accountOBJ;
        	List<Account> accountOBJList = [SELECT Id, ParentId FROM Account WHERE Id = :accountId ];
        	
        	if(accountOBJList != null && accountOBJList.size() > 0) 
        		accountOBJ = accountOBJList[0];
        	else 
        		return DomainValidation.ERROR;
        
        	//Create a list of Accounts Ids to search for Domains
        	accIds = new List<String>();
        
        	accIds.add(accountId);

	        String accParentId = accountOBJ.ParentId;
        	if (accParentId != null && accParentId != '') {
        	    accIds.add(accParentId);
        	}

        	//Query for domain objets 
        	domains = [SELECT Name from Account_Domain__c WHERE Account__c IN :accIds];
        
        	if (domains!= null && domains.size() > 0) {
            	//Compare email domain with account domains
            	for (Account_Domain__c dom : domains) {
                	if (dom.Name == contatDomain) 
                		return DomainValidation.MATCHINGDOMAIN;
            	}
            	return DomainValidation.NOTMATCHINGDOMAINS;
        	}
        	return DomainValidation.NOREGISTEREDDOMAIN;
    	}
    	catch (Exception ex) {
    		return DomainValidation.ERROR;
    	}
    }
    
    /**
     * format a decimal into a string with commas and 2 decimal points
     * @param num Decimal number to be formatted
     * @return formatted string version of the decimal
     */
    public static String DecimalToString(decimal num) {
    	if (num == null) return '';

    	String str = String.format(num.setScale(2).format(), new List<String> {'0','number','###,###,##0.00'});
    	if (str.contains('.')) {
    		if (str.substring(str.indexOf('.')).length() == 2)
    			return str + '0';
    		else
    			return str;
    	}
    	else
    		return str + '.00';
    }

	public static String GetStringFromDate(Date dtValue) {
		return dtValue.year() + ((dtValue.month() < 10) ? '-0' : '-') + dtValue.month() + ((dtValue.day() < 10) ? '-0' : '-') + dtValue.day();
	}
    
	public static Map<String, AggregateResult> GetAggregateResultMap(List<AggregateResult> aggResultList) {
		return GetAggregateResultMap(aggResultList, null);
	}

	public static Map<String, AggregateResult> GetAggregateResultMap(List<AggregateResult> aggResultList, List<String> lstGroupKeysType) {
		Map<String, AggregateResult> mapResults = new Map<String, AggregateResult>();
		for (AggregateResult ar : aggResultList){
			if (lstGroupKeysType == null) {
				mapResults.put(string.valueOf(ar.get('GroupByKey1')), ar);
			}
			else {
				string key = '';
				integer i = 1;
				for (String grpKeyType : lstGroupKeysType) {
					if (grpKeyType == 'Date') {
						Date dt = Date.valueOf(ar.get('GroupByKey' + i));
						key += GetStringFromDate(dt) + ':';
					}
					else
						key += string.valueOf(ar.get('GroupByKey' + i)) + ':';
					i++;
				}
				key = key.left(key.length() - 1);
				mapResults.put(key, ar);
			}
		}
		return mapResults;
	}
	
	public static List<String> GetCountryNameFromISOCode(List<String> lstISOCode) {
		if (lstISOCode == null || lstISOCode.size() == 0) return null;
		
		List<String> lstCountryName = new List<String>();
		for (IATA_ISO_Country__c country : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>(lstISOCode)), 'Name')) {
			lstCountryName.add(country.Name);
		}
		
		return lstCountryName;		
	}
	
	public static List<String> GetStateNameFromISOCode(List<String> lstISOCode) {
		if (lstISOCode == null || lstISOCode.size() == 0) return null;
		
		Set<String> isoCodeSet = new Set<String>();
		isoCodeSet.addAll(lstISOCode); 
		List<String> lstStateName = new List<String>();
		for (IATA_ISO_State__c state : IATAIsoStateDAO.sortIATAIsoStateList(IATAIsoStateDAO.getIsoStateByIsoCodes(isoCodeSet), 'Name')){
			lstStateName.add(state.Name);
		}
		
		return lstStateName;		
	}
	
	public static List<String> GetAgencyProgramNameFromCode(List<String> lstAgencyProgramCode) {
		if (lstAgencyProgramCode == null || lstAgencyProgramCode.size() == 0) return null;
		
		List<String> lstAgencyProgramName = new List<String>();
		for (IEC_Agency_Type__c agencyType :
			[SELECT Agency_Program__c
			FROM IEC_Agency_Type__c
			WHERE Agency_Program_Code__c IN :lstAgencyProgramCode
			ORDER BY Agency_Program__c]) {
			lstAgencyProgramName.add(agencyType.Agency_Program__c);
		}
		
		return lstAgencyProgramName;		
	}

	/**
	 * Convert Array of Strings into a single string
	 * @param StringArray: array of strings
	 */
	public static String ArrayToString(String[] StringArray) {
		if (StringArray == null) return null;

		String sOutput = '';
		for (String s : StringArray) {
			sOutput += ', ' + s;
		}
		
		return (sOutput.length() == 0) ? null : sOutput.substring(2);
	}
	
	/**
	 * Get the Batch Replication record of the the specified batch name
	 * @param BatchName: the name of the batch running
	 */
	public static IEC_Batch_Replication__c GetBatchReplication(String BatchName) {
		List<IEC_Batch_Replication__c> lstBtch =
			[SELECT Id, Batch_Name__c, Last_Modified_Date__c
			FROM IEC_Batch_Replication__c
			WHERE Batch_Name__c = :BatchName];
		
		return (lstBtch.size() > 0)
			? lstBtch.get(0)
			: new IEC_Batch_Replication__c(
				Batch_Name__c = BatchName
				, Last_Modified_Date__c = DateTime.newInstance(1999, 1, 1)
			);
	}
	
	/**
	 * Set the Batch Replication last modified date of the the specified batch name
	 * @param BatchName: the name of the batch running
	 * @param dtLastModified: Last modified date for the data
	 */
	public static void SetBatchReplication(String sBatchName, DateTime dtLastModified) {
		upsert new IEC_Batch_Replication__c (Batch_Name__c = sBatchName, Last_Modified_Date__c = dtLastModified) IEC_Batch_Replication__c.Batch_Name__c;
	}
	
	/**
	 * Get the RecordTypeId for a specified Object and RecordType name
	 * @param ObjName: the name of the object
	 * @param DevName: the developer name of record type
	 */
	public static Id GetRecordTypeId(String ObjName, String DevName) {
		return RecordTypeSingleton.getInstance().getRecordTypeId(ObjName, DevName);
	}
	
	/**
	 * Wraps the provided string into fixed length chunks
	 * @param StrToWrap: String to wrap
	 * @param WrapLength: Length of the string before wrapping it into a second line
	 */
	 public static List<String> WrapText(String StrToWrap, integer WrapLength) {
	 	List<String> lstLines = new List<String>();
	 	if (!String.isBlank(StrToWrap)) {
		 	List<String> lstWords = StrToWrap.split(' ');

			// Determine whether any of the words is more than specified WrapLength: then wrap by character instead of word
			Boolean bWrapChar = false;
			for (String word : lstWords) {
				if (word.length() > WrapLength) {
					bWrapChar = true;
					break;
				}
			}

			// Wrap by character instead of word
			if (bWrapChar) {
				integer i = 0;
				for (i = 0; i < (StrToWrap.length() / WrapLength); i++) {
					lstLines.add(StrToWrap.substring(i * WrapLength, (i + 1) * WrapLength));
				}
				if (math.mod(StrToWrap.length(), WrapLength) > 0)
					lstLines.add(StrToWrap.substring(i * WrapLength, StrToWrap.length()));
			}
			// Wrap string by word
			else {
				String line = '';
				
				for (String word : lstWords) {
					if ((line + ' ' + word).trim().length() < (WrapLength - 1)) {
						line = (line + ' ' + word).trim();
					}
					else {
						lstLines.add(line);
						line = word;
					}
				}

				lstLines.add(line);
			}
	 	}	 	
				
		return lstLines; 
	}
	
	public static Boolean validateEmail(String email) {
		// source: http://www.regular-expressions.info/email.html
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
		Pattern MyPattern = Pattern.compile(emailRegex);
		Matcher MyMatcher = MyPattern.matcher(email);

		return MyMatcher.matches(); 
	}
	
	public static Boolean isPostOfficeBox(String streetAddress) {
		Pattern p = Pattern.compile('\\b[P|p]*(OST|ost)*\\.*\\s*[O|o|0]*(ffice|FFICE)*\\.*\\s*[B|b][O|o|0][X|x]\\s*\\d*\\b');
		Matcher m = p.matcher(streetAddress);
		return m.find();						
	}
}