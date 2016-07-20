public with sharing class MITA_TxtCtrl {

	private static final map<Integer,String> MONTH_NAMES = new Map<Integer,String>{
		1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'
	};

	public final String IAB2D1 = 'iab2d1';
	public final String IAB2D2 = 'iab2d2';
	public final String IAB2D3 = 'iab2d3';
	public final String IAB2D4 = 'iab2d4';
	public final String IAB2D5 = 'iab2d5';
	public final String IAB2D6 = 'iab2d6';
	
	public final String IAB2P2 = 'iab2p2';
	
	public final String IAB3D1 = 'iab3d1';
	public final String IAB3D2 = 'iab3d2';
	
	public final String IAB4D2 = 'iab4d2';
	
	public final String IAB5D3 = 'iab5d3';
	
	public final String IAB7D1 = 'iab7d1';
	public final String IAB7D2 = 'iab7d2';

	public final String MITA27 = 'MITA2.7';
	
	
	public String txtType {get;set;}
	
	
	
	public MITA_TxtCtrl(){
		txtType = ApexPages.currentPage().getParameters().get('type');
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
			for(Account a : [SELECT Name, MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Passenger__c, 
									MITA_IATA_Interline_Pass_Art3_Joined__c, Membership_status__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company'  
						 	ORDER BY Name]){
				String star = '  ';
				if(a.Membership_status__c=='IATA Member')
					star = ' *';
				else if(a.Membership_status__c=='Associate')
					star = '**';

				content +=  star +
							formatString(a.Name,102) + 
							formatDate(a.MITA_IATA_Interline_Passenger__c) +
							(a.MITA_IATA_Interline_Pass_Art3_Joined__c!=null && a.MITA_IATA_Interline_Pass_Art3_Joined__c!=a.MITA_IATA_Interline_Passenger__c?
								'('+formatDate(a.MITA_IATA_Interline_Pass_Art3_Joined__c)+')!1':
								''.rightPad(15))+
							formatDate(a.MITA_IATA_Interline_Cargo__c) + ' \r\n';
		}

		///// IAB2D2.TXT /////
		// I**Aer Lingus Limited                                                                                     01 Jul 1993 
		// I *Aeromexico                                          Aerovias de Mexico S.A. de C.V.                    02 Mar 1994 
		}else if(txtType==IAB2D2){
			for(Account a : [SELECT Name, MITA_One_way_Pass_Issuing_Airline__c, Membership_status__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company'  
						 	ORDER BY Name]){
				String star = 'I  ';
				if(a.Membership_status__c=='IATA Member')
					star = 'I *';
				else if(a.Membership_status__c=='Associate')
					star = 'I**';

				content +=  star +
							formatString(a.Name,103) +
							formatDate(a.MITA_One_way_Pass_Issuing_Airline__c) + ' \r\n';
			}


		///// IAB2P2.TXT /////
		//P  Hawaii Island Air Inc.                              dba Island Air                                     21 Aug 2005 
		//P *Jetblue Airways Corporation                                                                            17 Aug 2015 
		}else if(txtType==IAB2P2){
			/*
			for(Account a : [SELECT Name, MITA_One_way_Pass_Issuing_Airline__c, Membership_status__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company'  
						 	ORDER BY Name]){
				String star = 'I  ';
				if(a.Membership_status__c=='IATA Member')
					star = 'I *';
				else if(a.Membership_status__c=='Associate')
					star = 'I**';

				content +=  star +
							formatString(a.Name,103) +
							formatDate(a.MITA_One_way_Pass_Issuing_Airline__c) + ' \r\n';
			}
			*/

		///// IAB2D3.TXT /////
		// ABC Aerolineas S.A. de C.V.                                                                         4O*837 837  
		// ABSA  -  Aerolinhas Brasileiras S.A.                                                                M3     549 
		}else if(txtType==IAB2D3){
			String firstLetter = '';
			for(Account a : [SELECT Name, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Passenger__c, IATAcode__c, Airline_Designator__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company'
						 	ORDER BY Name]){

				String firstLetterIndicator; 
				if (firstLetter == a.Name.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name.left(1);
				}

				content += 	formatString(a.Name,100) + 
							formatString(a.Airline_Designator__c, 3) +
							(a.MITA_IATA_Interline_Passenger__c==null || a.IATAcode__c==null ? '   ' : a.IATAcode__c.rightPad(3))+
							' '+
							(a.MITA_IATA_Interline_Cargo__c==null || a.IATAcode__c==null ? '   ' : a.IATAcode__c.rightPad(3))+
							' '+
							firstLetterIndicator+
							'\r\n';
			}	
		
		
		///// IAB2D4.TXT /////
		// 2K Aerolineas Galapagos S.A. Aerogal                                                                    
		// 3A Kenosha Aero, Inc. dba Alliance Airlines                                                            &
		}else if(txtType==IAB2D4){
			String firstLetter = '';
			for(Account a : [SELECT Name, Airline_Designator__c
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

				content += airlineDesignator
							+formatString(a.Name,100)
							+firstLetterIndicator
							+'\n\r';
			}

		///// IAB2D5.TXT /////
		// 014 014 Air Canada
		//     020 Lufthansa Cargo AG 
		}else if(txtType==IAB2D5){
			for(Account a : [SELECT Name, IATAcode__c, MITA_IATA_Interline_Passenger__c , MITA_IATA_Interline_Cargo__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND IATAcode__c <> NULL
							AND (MITA_IATA_Interline_Passenger__c<>NULL OR MITA_IATA_Interline_Cargo__c<> NULL)
							ORDER BY IATAcode__c]){

				content += 	(a.MITA_IATA_Interline_Passenger__c==null || a.IATAcode__c==null ? '    ' : a.IATAcode__c.rightPad(4))+
							(a.MITA_IATA_Interline_Cargo__c==null || a.IATAcode__c==null ? '    ' : a.IATAcode__c.rightPad(4)) + 
							formatString(a.Name,102)+
							'\r\n';
			}

		///// MITA27.TXT /////
		//1511      "Rossiya Airlines" JSC                                                                              MPCVladimir Bondarev                             Director External Relations Dep.                            18/4  Pilotov Street                                                            St Petersburg                                                      Russian Federation                          196210    LEDFAFV                                                            7 812 704-3663                  True MPBTatiana Kulik                                 Director  Accounting Department                             18/4 Pilotov str.,                                                              St Petersburg                                                      Russian Federation                          196210    LEDACFV                                                            7 812 704-3706                  True MCCTatiana Kulik                                 Director Accounting Department                              18/4 Pilotov St.                                                                St Petersburg                                                      Russian Federation                          196210    LEDACFV                                                            7 812                           True MCBJin Khoo Cheng                                Manager Freight Revenue Accounting                          3rd flr East womg Admin Bldg                                                    St Petersburg                                                      Russian Federation                          196210                                                                       7 812                           True 
		//3267      ABC Aerolineas S.A. de C.V.                                                                         MPCRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102,Mz 2 Lt 2     Parque Industrial Exporte I             Toluca                                                             Mexico                                      52000                                                                        52 722                          True MPBRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102, Mz2 Lt2      Parque Industrial Exporte               Toluca                                                             Mexico                                      52000                                                                        52 722                          True MCCRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102, Mz2 Lt2      Parque Industriel Exporte I             Toluca                                                             Mexico                                      52000                                                                        52 722                          True MCBRaul Lopez Woolrich                           IT Manager                                                  Calle Ignacio Longams 102, Mz2 Lt2      Parque Industrial Exporte I             Toluca                                                             Mexico                                      52000                                                                        52 722                          True 
		//1301      ABSA  -  Aerolinhas Brasileiras S.A.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         False                                                                                                                                                                                                                                                                                                                                                                                                                              MCCAndres Patricio Avagliano Penafiel            Finance Mngr                                                Rodovia Santos Dumont, Km66             S/N Lado Esquerdo Aeroporto Int'l ViracoCampinas, Sao Paulo                                                Brazil                                      13052-970                                                                    55 192 1384411                  True                                                                                                                                                                                                                                                                                                                                                                                                                               
		//633       Adria Airways - The Airline of Slovenia                                                             MPCNadja Gantar                                  Manager Industry and Int'l Affairs                          Zgornji Brnik 130h                                                              Brnik-Aerodrom                                                     Slovenia                                    SI-4210                                                                      396 4 259-4573                  True MPBRobert Music                                  Revenue Accounting Manager                                  Zgornji Brnik 130 h                                                             Brnik- Aerodrom                                                    Slovenia                                    SI-4210                                                                      396 4 259-4573                  True                                                                                                                                                                                                                                                                                                                                                                                                                          False                                                                                                                                                                                                                                                                                                                                                                                                                         False
		}else if(txtType==MITA27){
			/*
			for(Account a : [SELECT Name, IATAcode__c, MITA_IATA_Interline_Passenger__c , MITA_IATA_Interline_Cargo__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND IATAcode__c <> NULL
							ORDER BY IATAcode__c]){

			}
			*/

		///// IAB5D3.TXT /////
		//Air Algerie                                                                                         
		//Air Canada                                                                                          
		//Air Wisconsin Airlines Corporation                                                                  
		//Alaska Airlines Inc.                                                                                
		}else if(txtType==IAB5D3){
			String firstLetter = '';
			for(Account a : [SELECT Name, CurrencyIsoCode
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND IATAcode__c <> NULL
							ORDER BY Name]){

				String firstLetterIndicator; 
				if (firstLetter == a.Name.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name.left(1);
				}
				String legend = ' ';

				content +=legend
						+ formatString(a.Name,102)
						+ firstLetterIndicator
						//+ formatDate(a.)
						//+ formatDate(a.)
						+ firstLetterIndicator
						+ '\r\n';
			}

		///// IAB7D1.TXT /////
		//Air Algerie                                                                                         
		//Air Canada                                                                                          
		//Air Wisconsin Airlines Corporation                                                                  
		//Alaska Airlines Inc.                                                                                
		}else if(txtType==IAB7D1){
			String firstLetter = '';
			//TODO change CurrencyIsoCode for the right field
			for(Account a : [SELECT Name, CurrencyIsoCode
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND IATAcode__c <> NULL
							ORDER BY Name]){

				String firstLetterIndicator; 
				if (firstLetter == a.Name.left(1)) {
					firstLetterIndicator = ' ';
				} else {
					firstLetterIndicator = '&';
					firstLetter = a.Name.left(1);
				}
				String legend = ' ';

				content +=formatString(a.CurrencyIsoCode,40)
						+ legend
						+ formatString(a.Name,101)
						+ firstLetterIndicator
						+ '\r\n';
			}

		///// IAB7D2.TXT /////
		//Air Algerie                                                                                         
		//Air Canada                                                                                          
		//Air Wisconsin Airlines Corporation                                                                  
		//Alaska Airlines Inc.                                                                                
		}else if(txtType==IAB7D2){
			for(Account a : [SELECT Name
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
							AND ACLI_Status__c = 'Active Company'
							AND IATAcode__c <> NULL
							ORDER BY Name]){

				content += formatString(a.Name,100)
						+ '\r\n';
			}
		}

		return content;
	}

	private String formatDate(Date d){
		if(d!=null)
			return (d.day()<10?'0':'') + d.day()+' '+MONTH_NAMES.get(d.month())+' '+d.year();
		else
			return '  -        ';
	}

	private String formatString(String input, Integer length ) {
		String output = input==null? '': input;
		return output.rightPad(length);
	}
}