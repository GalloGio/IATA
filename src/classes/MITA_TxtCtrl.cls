public with sharing class MITA_TxtCtrl {

	private static final map<Integer,String> MONTH_NAMES = new Map<Integer,String>{
		1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'
	};
	private static final map<String,String> AGREEMENT_TYPES = new map<String,String>{
		'The Passenger and Cargo Interline Traffic Agreement'=>'1.',
		'Bilateral, both carriers can issue electronic tickets'=>'1.',
		'The Passenger Interline Agreement'=>'2.',
		'The Cargo Interline Agreement'=>'3.',
		'The One Way Issuing Airline'=>'4.',
		'The One Way Participating Airline'=>'5.',
		'One Way Passenger Issuing Airline'=>'6.',
		'One Way Passenger Participating'=>'6.',
		'One Way Intermodal Issuing Date' => '7.',
		'One Way Intermodal Participating Date' => '7.'
	};
	private static final String NL = '\r\n';

	public static final String IAB2D1 = 'iab2d1';
	public static final String IAB2D2 = 'iab2d2';
	public static final String IAB2D3 = 'iab2d3';
	public static final String IAB2D4 = 'iab2d4';
	public static final String IAB2D5 = 'iab2d5';
	public static final String IAB2D6 = 'iab2d6';

	public static final String IAB2P2 = 'iab2p2';

	public static final String IAB3D1 = 'iab3d1';
	public static final String IAB3D2 = 'iab3d2';

	public static final String IAB4D2 = 'iab4d2';

	public static final String IAB5D3 = 'iab5d3';

	public static final String IAB7D1 = 'iab7d1';
	public static final String IAB7D2 = 'iab7d2';

	public static final String MITA27 = 'MITA2.7';

	public String txtType {get;set;}

	public MITA_TxtCtrl(){
		try {
			txtType = ApexPages.currentPage().getParameters().get('type');
		} catch (Exception e) {
			System.debug('No parameter "type"');
		}
	}

	public String getTitle(){
		return txtType+'.txt';
	}

	public String getContent(){
		String content = '';

		///// IAB2D1.TXT /////
		//  *Aegean Airlines S.A.                                                                                  31 Aug 1999               31 Aug 2000
		// **Aer Lingus Limited                                                                                    01 Mar 1948(05 Apr 1953)!101 Jun 2006
		if(txtType==IAB2D1){
			String firstLetter = '';
			for(Account a : [SELECT Name_on_AOC__c, MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Passenger__c,
									MITA_IATA_Interline_Pass_Art3_Joined__c, Membership_status__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND MITA_Member__c = true
							AND Name_on_AOC__c != null
							AND (
								(MITA_IATA_Interline_Passenger__c != null and MITA_IATA_Interline_Cargo__c !=null)
								OR (MITA_IATA_Interline_Passenger__c = null and MITA_IATA_Interline_Cargo__c !=null)
								OR (MITA_IATA_Interline_Passenger__c != null and MITA_IATA_Interline_Cargo__c =null)
							)
							ORDER BY Name_on_AOC__c]){

				String firstLetterIndicator;
				if (firstLetter == a.Name_on_AOC__c.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name_on_AOC__c.left(1);
				}

				String legend = '  ';
				if(a.Membership_status__c=='IATA Member')
					legend = ' *';
				else if(a.Membership_status__c=='Associate')
					legend = '**';
				else if(a.MITA_IATA_Interline_Art3_Excepted_Status__c)
					legend = ' +';

				content +=legend
						+ formatString(a.Name_on_AOC__c,101)
						+ ' '
						+ formatDate(a.MITA_IATA_Interline_Passenger__c) +
						+ (a.MITA_IATA_Interline_Pass_Art3_Joined__c!=null && a.MITA_IATA_Interline_Pass_Art3_Joined__c!=a.MITA_IATA_Interline_Passenger__c?
								'('+formatDate(a.MITA_IATA_Interline_Pass_Art3_Joined__c)+')!1':
								''.rightPad(15))+formatDate(a.MITA_IATA_Interline_Cargo__c)
						+firstLetterIndicator
						+NL;
			}

		///// IAB2D2.TXT /////
		// I**Aer Lingus Limited                                                                                     01 Jul 1993
		// I *Aeromexico                                          Aerovias de Mexico S.A. de C.V.                    02 Mar 1994
		}else if(txtType==IAB2D2){
			for(Account a : [SELECT Name_on_AOC__c, MITA_One_way_Pass_Issuing_Airline__c, Membership_status__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND MITA_Member__c = true
							AND MITA_One_way_Pass_Issuing_Airline__c != null
							ORDER BY Name_on_AOC__c]){

				String legend = '  ';
				if(a.Membership_status__c=='IATA Member')
					legend = ' *';
				else if(a.Membership_status__c=='Associate')
					legend = '**';

				content +='I'
						+ legend
						+ formatString(a.Name_on_AOC__c,103)
						+ formatDate(a.MITA_One_way_Pass_Issuing_Airline__c)
						+ ' '
						+ NL;
			}

		///// IAB2P2.TXT /////
		//P  Hawaii Island Air Inc.                              dba Island Air                                     21 Aug 2005
		//P *Jetblue Airways Corporation                                                                            17 Aug 2015
		}else if(txtType==IAB2P2){
			for(Account a : [SELECT Name_on_AOC__c, MITA_One_way_Pass_Participating__c, Membership_status__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND MITA_One_way_Pass_Participating__c != null
							AND MITA_Member__c = true
							ORDER BY Name_on_AOC__c]){
				String legend = '  ';
				if(a.Membership_status__c=='IATA Member')
					legend = ' *';
				else if(a.Membership_status__c=='Associate')
					legend = '**';

				content +='P'
						+ legend
						+ formatString(a.Name_on_AOC__c,103)
						+ formatDate(a.MITA_One_way_Pass_Participating__c)
						+ ' '
						+ NL;
			}

		///// IAB2D3.TXT /////
		// ABC Aerolineas S.A. de C.V.                                                                         4O*837 837
		// ABSA  -  Aerolinhas Brasileiras S.A.                                                                M3     549
		}else if(txtType==IAB2D3){
			String firstLetter = '';
			for(Account a : [ SELECT Name_on_AOC__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Passenger__c, IATAcode__c, Airline_Designator__c, Airline_Prefix__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND Name_on_AOC__c != null
							AND Airline_Designator__c != null
							AND MITA_Member__c = true
							ORDER BY Name_on_AOC__c]){

				String firstLetterIndicator;
				if (firstLetter == a.Name_on_AOC__c.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name_on_AOC__c.left(1);
				}

				content +=formatString(a.Name_on_AOC__c,100)
						+ formatString(a.Airline_Designator__c, 3)
						+ formatString(a.IATAcode__c,3)
						+ ' '
						+ formatString(a.Airline_Prefix__c,3)
						+ ' '
						+ firstLetterIndicator
						+ NL;
			}

		///// IAB2D4.TXT /////
		// 2K Aerolineas Galapagos S.A. Aerogal
		// 3A Kenosha Aero, Inc. dba Alliance Airlines                                                            &
		}else if(txtType==IAB2D4){
			String firstLetter = '';
			for(Account a : [SELECT Name_on_AOC__c, Airline_Designator__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND Airline_Designator__c <> NULL
							ORDER BY Airline_Designator__c]){

				String airlineDesignator = formatString(a.Airline_Designator__c,3);

				String firstLetterIndicator;
				if (firstLetter == airlineDesignator.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Airline_Designator__c.left(1);
				}

				content +=airlineDesignator
						+ formatString(a.Name_on_AOC__c,100)
						+ firstLetterIndicator
						+ NL;
			}

		///// IAB2D5.TXT /////
		// 014 014 Air Canada
		//     020 Lufthansa Cargo AG
		}else if(txtType==IAB2D5){
			for(Account a : [SELECT Name_on_AOC__c, IATAcode__c, Airline_Prefix__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND MITA_Member__c = true
							ORDER BY Name_on_AOC__c]){

				content +=formatString(a.IATAcode__c,3)
						+ ' '
						+ formatString(a.Airline_Prefix__c,3)
						+ ' '
						+ formatString(a.Name_on_AOC__c,102)
						+ NL;
			}

		///// MITA27.TXT /////
		//1511      "Rossiya Airlines" JSC                                                                              MPCVladimir Bondarev                             Director External Relations Dep.                            18/4  Pilotov Street                                                            St Petersburg                                                      Russian Federation                          196210    LEDFAFV                                                            7 812 704-3663                  True MPBTatiana Kulik                                 Director  Accounting Department                             18/4 Pilotov str.,                                                              St Petersburg                                                      Russian Federation                          196210    LEDACFV                                                            7 812 704-3706                  True MCCTatiana Kulik                                 Director Accounting Department                              18/4 Pilotov St.                                                                St Petersburg                                                      Russian Federation                          196210    LEDACFV                                                            7 812                           True MCBJin Khoo Cheng                                Manager Freight Revenue Accounting                          3rd flr East womg Admin Bldg                                                    St Petersburg                                                      Russian Federation                          196210                                                                       7 812                           True
		//3267      ABC Aerolineas S.A. de C.V.                                                                         MPCRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102,Mz 2 Lt 2     Parque Industrial Exporte I             Toluca                                                             Mexico                                      52000                                                                        52 722                          True MPBRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102, Mz2 Lt2      Parque Industrial Exporte               Toluca                                                             Mexico                                      52000                                                                        52 722                          True MCCRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102, Mz2 Lt2      Parque Industriel Exporte I             Toluca                                                             Mexico                                      52000                                                                        52 722                          True MCBRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102, Mz2 Lt2      Parque Industrial Exporte I             Toluca                                                             Mexico                                      52000                                                                        52 722                          True
		//1301      ABSA  -  Aerolinhas Brasileiras S.A.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         False                                                                                                                                                                                                                                                                                                                                                                                                                              MCCAndres Patricio Avagliano Penafiel            Finance Mngr                                                Rodovia Santos Dumont, Km66             S/N Lado Esquerdo Aeroporto Int'l ViracoCampinas, Sao Paulo                                                Brazil                                      13052-970                                                                    55 192 1384411                  True
		//633       Adria Airways - The Airline of Slovenia                                                             MPCNadja Gantar                                  Manager Industry and Int'l Affairs                          Zgornji Brnik 130h                                                              Brnik-Aerodrom                                                     Slovenia                                    SI-4210                                                                      396 4 259-4573                  True MPBRobert Music                                  Revenue Accounting Manager                                  Zgornji Brnik 130 h                                                             Brnik- Aerodrom                                                    Slovenia                                    SI-4210                                                                      396 4 259-4573                  True                                                                                                                                                                                                                                                                                                                                                                                                                          False                                                                                                                                                                                                                                                                                                                                                                                                                         False
		}else if(txtType==MITA27){
			//all account valid to insert in the file
			list<Account> listAccount = [
				SELECT Name_on_AOC__c, IATAcode__c, Top_Parent__c, (SELECT Name, Title, OtherStreet, OtherCity, OtherCountry, OtherPostalcode, MITA_Teletype__c, Fax, Status__c, MITA_Contact_Type__c  FROM Contacts)
				FROM Account
				WHERE RecordType.Name = 'Airline Headquarters'
				AND ACLI_Status__c = 'Active Company'
				AND IATAcode__c <> NULL
				and id = '001w0000015LHUsAAO'
				ORDER BY IATAcode__c
			];

			//Get all contacts related with the accounts
			list<Id> listContactId = new list<Id>();
			for(Account a : listAccount){
				listContactId.add(a.Top_Parent__c);
			}
			map<Id,Contact> mapContact = new map<Id,Contact>(
				[SELECT Name, Title, OtherStreet, OtherCity, OtherCountry, OtherPostalcode, MITA_Teletype__c, Fax, Status__c, MITA_Contact_Type__c  FROM Contact where id in :listContactId]
			);

			//start writing the export file
			for(Account a : listAccount){
				//get the map of contacts grouped by type
				map<String,Contact> mapTypeContact = new map<String,Contact>();
				Contact topContact = mapContact.get(a.Top_Parent__c);
				if (topContact!=null) {
					mapTypeContact.put(topContact.MITA_Contact_Type__c, topContact);
				}
				for (Contact contact: a.contacts) {
					mapTypeContact.put(contact.MITA_Contact_Type__c, contact);
				}

				//writing a line
				content +=formatString(a.IATAcode__c,10)
						+ formatString(a.Name_on_AOC__c,100)
						+ printContact('MPC', mapTypeContact.get('PAX Corresp.'))
						+ printContact('MPB', mapTypeContact.get('PAX Billing'))
						+ printContact('MCC', mapTypeContact.get('CGO Corresp.'))
						+ printContact('MCB', mapTypeContact.get('CGO Billing'))
						+ NL;
			}

		/**
			File for MITA Agreements
		**/
		}else if(txtType==IAB3D1){
			for(Account a : [SELECT id, Name_on_AOC__c, MITA_IATA_Interline_Cargo_Claims__c,
							( Select Airline_2__r.Airline_designator__c, Agreement_type__c From MITA_Agreements_1__r where Active__c = true and MITAorBIETA__c = 'MITA' ORDER BY Agreement_type__c),
							( Select Airline_1__r.Airline_designator__c, Agreement_type__c From MITA_Agreements_2__r where Active__c = true and MITAorBIETA__c = 'MITA' ORDER BY Agreement_type__c)
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND MITA_Member__c = true
							ORDER BY Name_on_AOC__c]){

				Format_IAB3 format = new Format_IAB3(a);
				content += format.toCSV();
			}

		/**
			File for BIETA Agreements
		**/
		}else if(txtType==IAB3D2){
			for(Account a : [SELECT id, Name_on_AOC__c, MITA_IATA_Interline_Cargo_Claims__c,
							( Select Airline_2__r.Airline_designator__c, Agreement_type__c From MITA_Agreements_1__r where Active__c = true and MITAorBIETA__c = 'BIETA' ORDER BY Agreement_type__c),
							( Select Airline_1__r.Airline_designator__c, Agreement_type__c From MITA_Agreements_2__r where Active__c = true and MITAorBIETA__c = 'BIETA' ORDER BY Agreement_type__c)
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND BIETA_Member__c = true
							ORDER BY Name_on_AOC__c]){

				Format_IAB3 format = new Format_IAB3(a);
				content += format.toCSV();
			}

		///// IAB4D2.TXT /////
		//Air Algerie
		//Air Canada
		//Air Wisconsin Airlines Corporation
		//Alaska Airlines Inc.
		}else if(txtType==IAB4D2){
			String firstLetter = '';
			for(Account a : [SELECT Name_on_AOC__c, Membership_status__c , MITA_IATA_Interline_Cargo_Claims__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND MITA_Member__c = true
							AND MITA_IATA_Interline_Cargo_Claims__c != null
							ORDER BY Name_on_AOC__c]){

				String legend = '  ';
				if(a.Membership_status__c=='IATA Member')
					legend = ' *';
				else if(a.Membership_status__c=='Associate')
					legend = '**';

				String firstLetterIndicator;
				if (firstLetter == a.Name_on_AOC__c.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name_on_AOC__c.left(1);
				}

				content += legend
						+ formatString(a.Name_on_AOC__c,101)
						+ formatDate(a.MITA_IATA_Interline_Cargo_Claims__c)
						+ firstLetterIndicator
						+ NL;
			}

		///// IAB5D3.TXT /////
		//Air Algerie
		//Air Canada
		//Air Wisconsin Airlines Corporation
		//Alaska Airlines Inc.
		}else if(txtType==IAB5D3){
			String firstLetter = '';
			for(Account a : [SELECT Name_on_AOC__c, Membership_status__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_IATA_Interline_Cargo_Charges__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND MITA_Member__c = true
							AND (MITA_IATA_Interline_Passenger_Charges__c != null  OR MITA_IATA_Interline_Cargo_Charges__c != null)
							ORDER BY Name_on_AOC__c]){

				String legend = '  ';
				if(a.Membership_status__c=='IATA Member')
					legend = ' *';
				else if(a.Membership_status__c=='Associate')
					legend = '**';

				String firstLetterIndicator;
				if (firstLetter == a.Name_on_AOC__c.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name_on_AOC__c.left(1);
				}

				content +=legend
						+ formatString(a.Name_on_AOC__c,102)
						+ formatDate(a.MITA_IATA_Interline_Passenger_Charges__c)
						+ ' '
						+ formatDate(a.MITA_IATA_Interline_Cargo_Charges__c)
						+ firstLetterIndicator
						+ NL;
			}

		///// IAB7D1.TXT /////
		//Air Algerie
		//Air Canada
		//Air Wisconsin Airlines Corporation
		//Alaska Airlines Inc.
		}else if(txtType==IAB7D1){
			String firstLetter = '';
			String firstCurrencyZone = '';
			for(Account a : [SELECT Name_on_AOC__c, Membership_status__c, MITA_Currency__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND ICH_Member__c = true
							AND MITA_Currency__c != null
							AND MITA_Currency__c != 'N/A'
							ORDER BY MITA_Currency__c desc, Name_on_AOC__c]){

				String legend = ' ';
				if(a.Membership_status__c=='Non-IATA member')
					legend = '*';
				else if(a.Membership_status__c=='XXX')
				//TODO : Also member of the Airlines Clearing House?
					legend = '+';

				String firstLetterIndicator;
				if (firstLetter == a.Name_on_AOC__c.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name_on_AOC__c.left(1);
				}

				String firstCurrencyZoneIndicator = '';
				if (firstCurrencyZone == a.MITA_Currency__c) {
					firstCurrencyZoneIndicator = '';
				} else {
					firstCurrencyZoneIndicator = a.MITA_Currency__c;
					firstCurrencyZone = a.MITA_Currency__c;
				}

				String currencyZone = '';
				if (firstCurrencyZoneIndicator == 'Euro' ) {
					currencyZone = 'EUROPEAN CURRENCY ZONE';
				} else if (firstCurrencyZoneIndicator == 'US Dollar' ) {
					currencyZone = 'U.S. DOLLAR ZONE';
				} else if (firstCurrencyZoneIndicator == 'Pound Sterling' ) {
					currencyZone = 'POUND STERLING ZONE';
				}

				content +=formatString(currencyZone,40)
						+ legend
						+ formatString(a.Name_on_AOC__c,101)
						+ firstLetterIndicator
						+ NL;
			}

		///// IAB7D2.TXT /////
		//Air Algerie
		//Air Canada
		//Air Wisconsin Airlines Corporation
		//Alaska Airlines Inc.
		}else if(txtType==IAB7D2){
			for(Account a : [SELECT Name_on_AOC__c
							FROM Account
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND ACH_Member__c = true
							ORDER BY Name_on_AOC__c]){

				content += formatString(a.Name_on_AOC__c,100)
						+ NL;
			}
		}

		return content;
	}

	public static String formatDate(Date d){
		if(d!=null)
			return (d.day()<10?'0':'') + d.day()+' '+MONTH_NAMES.get(d.month())+' '+d.year();
		else
			return '   -       ';
	}

	public static String formatString(String input, Integer length ) {
		String output = input==null? '': input;
		output = output.replaceAll('\r','');
		output = output.replaceAll('\n',' ');
		return output.rightPad(length);
	}

	private String printContact(String type, Contact contact) {
		if (contact == null) {
			return formatString('', 411);
		}
		String content  = formatString(type, 3)
						+ formatString(contact.Name, 46)
						+ formatString(contact.Title, 60)
						+ formatString(contact.OtherStreet, 80)
						+ formatString(contact.OtherCity, 67)
						+ formatString(contact.OtherCountry, 44)
						+ formatString(contact.OtherPostalcode, 10)
						+ formatString(contact.MITA_Teletype__c, 7) //TeleType
						+ formatString('', 30) //Telex
						+ formatString('', 30) //Cable
						+ formatString(contact.Fax, 32) //FX
						+ formatString(contact.Status__c=='Active'?'True':'False', 5);
		return content;
	}

	class Format_IAB3 {
		private final list<String> listLegends = new list<String>{'1.','2.','3.','4.','5.','6.','7.'};
		private final Integer elementsPerLine = 15;

		private Account account;

		public Format_IAB3(Account account) {
			this.account = account;
		}

		/**
			return a map with all agreements of a single account organized
		**/
		private map<String,list<String>> getMapAgreements(Account account) {
			map<String, list<String>> mapAgreements = new map<String, list<String>>();
			for ( MITA_Agreement__c agreement: account.MITA_Agreements_1__r) {
				String agreementCode = AGREEMENT_TYPES.get(agreement.Agreement_type__c);

				list<String> listAgreements = mapAgreements.get(agreementCode);
				if ( listAgreements == null ) {
					listAgreements = new list<String>();
				}
				listAgreements.add(agreement.Airline_2__r.Airline_designator__c);
				mapAgreements.put(agreementCode,listAgreements);
			}

			for ( MITA_Agreement__c agreement: account.MITA_Agreements_2__r) {
				String agreementCode = AGREEMENT_TYPES.get(agreement.Agreement_type__c);

				list<String> listAgreements = mapAgreements.get(agreementCode);
				if ( listAgreements == null ) {
					listAgreements = new list<String>();
				}
				listAgreements.add(agreement.Airline_1__r.Airline_designator__c);
				mapAgreements.put(agreementCode,listAgreements);
			}
			System.debug('##' + mapAgreements + '##');
			return mapAgreements;
		}

		/**
			Return a list of lines with all agreements per account
		**/
		private list<String> getLineAgreements() {
			map<String,list<String>> mapAgreements = getMapAgreements(this.account);

			list<String> listLines = new list<String>();
			for ( String legend: this.listLegends ) {
				list<String> agreements = mapAgreements.get(legend);
				if (agreements!=null && !agreements.isEmpty()) {
					String line = formatString(legend,4);

					//insert 'elementsPerLine' agreements per line
					Integer counter = 1;
					for (String agreement: agreements) {
						line += formatString(agreement,6);

						if (counter == elementsPerLine) {
							counter = 0;
							listLines.add(line);
							line = ''.leftPad(4);
						}
						counter++;
					}
					// fill with elements until the end of the line
					for (Integer i = counter; i <= elementsPerLine; i++) {
						line +=''.leftPad(6);
					}
					listLines.add(line);
				}
			}
			return listLines;
		}

		/**
			Extract info to a csv format
		**/
		public String toCSV() {

			String output = '';
			list<String> listLines = getLineAgreements();
			System.debug(this.account.Name_on_AOC__c + ' ' + listLines);
			for (Integer i = 0; i < listLines.size(); i++) {
				//special beggining for first and last lines
				if (i == 0) {
					output += formatString(this.account.Name_on_AOC__c,97);
				} else {
					output += ''.leftPad(97);
				}

				output += listLines.get(i);

				// special ending for last line
				if (i == listLines.size()-1) {
					output += ' !';
				} else {
					output += '  ';
				}
				output += NL;
			}
			return output;
		}
	}
}
