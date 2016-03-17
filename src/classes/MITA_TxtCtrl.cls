public with sharing class MITA_TxtCtrl {

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
							a.Name.rightPad(102) + 
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
							a.Name.rightPad(103) + 
							formatDate(a.MITA_One_way_Pass_Issuing_Airline__c) + ' \r\n';
			}	
		

		///// IAB2D3.TXT /////
		// ABC Aerolineas S.A. de C.V.                                                                         4O*837 837  
		// ABSA  -  Aerolinhas Brasileiras S.A.                                                                M3     549 
		}else if(txtType==IAB2D3){
			for(Account a : [SELECT Name, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Passenger__c, IATAcode__c, Airline_Designator__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company'
						 	ORDER BY Name]){
					
				content += 	a.Name.rightPad(100) + 
							(a.Airline_Designator__c==null ? '   ' : a.Airline_Designator__c.rightPad(3))+
							(a.MITA_IATA_Interline_Passenger__c==null || a.IATAcode__c==null ? '    ' : a.IATAcode__c.rightPad(4))+
							(a.MITA_IATA_Interline_Cargo__c==null || a.IATAcode__c==null ? '    ' : a.IATAcode__c.rightPad(4))+
							'\r\n';
			}	
		
		
		///// IAB2D4.TXT /////
		// 2K Aerolineas Galapagos S.A. Aerogal                                                                    
		// 3A Kenosha Aero, Inc. dba Alliance Airlines                                                            &
		}else if(txtType==IAB2D4){
			String firstLetter;
			for(Account a : [SELECT Name, Airline_Designator__c
							FROM Account 
							WHERE RecordType.Name = 'Airline Headquarters'
						 	AND ACLI_Status__c = 'Active Company'
						 	AND Airline_Designator__c <> NULL
						 	ORDER BY Airline_Designator__c]){
				
				content += 	(a.Airline_Designator__c==null ? '   ' : a.Airline_Designator__c.rightPad(3))+
							a.Name.rightPad(100);
						
				if(firstLetter != a.Airline_Designator__c.substring(0,1)){
					if(firstLetter != null)
						content+='&\r\n';
					firstLetter = a.Airline_Designator__c.substring(0,1);
				}else
					content+=' \r\n';
				
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
							a.Name.rightPad(102)+
							'\r\n';
				
				
			}	
			
			
			
		///// IAB2D6.TXT /////
		// ABC AEROLINEAS S.A. DE C.V.                                                                Passenger                                                             (1) Raul Lopez Woolrich                                               (1) Raul Lopez Woolrich                                                 
        //                                                                                            Raul Lopez Woolrich                                                   (2) -                                                                     IT Manager                                                          
        //                                                                                            IT Manager                                                            (3) -                                                                     Calle Ignacio Longams 102, Mz2 Lt2                                  
        //                                                                                            Calle Ignacio Longams 102,Mz 2 Lt 2                                   (4) -                                                                     Parque Industrial Exporte                                           
        //                                                                                            Parque Industrial Exporte I                                           (5) 52 722                                                                Toluca                                                              
        //                                                                                            Toluca                                                                                                                                          Mexico                                                              
        //                                                                                            Mexico                                                                                                                                          52000                                                               
        //                                                                                            52000                                                                                                                                       (2) -                                                                   
		}else if(txtType==IAB2D5){
				
	
		}
		
		
		
		return content;
	}
	
	private String formatDate(Date d){
		Map<Integer,String> monthNames = new Map<Integer,String>{
			1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'
		};
		if(d!=null)
			return (d.day()<10?'0':'') + d.day()+' '+monthNames.get(d.month())+' '+d.year();
		else
			return '  -        ';
	}
}