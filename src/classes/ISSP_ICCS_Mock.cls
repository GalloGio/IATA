public class ISSP_ICCS_Mock{

	public static HTTPResponse getMockToken(String participantId) {
		
		// Create a fake response
		HttpResponse res = new HttpResponse();
		
		if(participantId == 'TO000'){
			res = null;
		}
		else if(participantId == 'TO400'){
			res.setStatusCode(400);
		}
		else if(participantId == 'TO401'){
			res.setStatusCode(401);
		}
		else{
			res.setBody('{"access_token" : "123abc"}');
			res.setStatusCode(200);
		}
		
		return res;
	}


	public static HTTPResponse getMockResponse(String endpoint, String participantId) {
		
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');

		// We'll determinate the type of responses with the participantId

		// Case 1 : Response will be successfull for participant LX724
		if(participantId == 'LX724'){
			res.setStatusCode(200);
	
			if(endpoint.endsWith('/cashflows')){
				res.setBody(getCashflows());
			}
			else if(endpoint.endsWith('/cycles')){
				res.setBody(getAllCycles());
			}
			else if(endpoint.endsWith('/cycles?status=AdHocWindow')){
				res.setBody(getAdhocWindowCycles());
			}
			else if(endpoint.endsWith('/cycles?status=Created')){
				res.setBody(getCreatedCycles());
			}
			else if(endpoint.endsWith('/settlementInstructions/types')){
				res.setBody(getInstructionTypes());
			}
			else if(endpoint.endsWith('/settlementInstructions/lineTypes')){
				res.setBody(getInstructionLineTypes());
			}
			else if(endpoint.endsWith('/reports/types')){
				res.setBody(getReportTypes());
			}
			else if(endpoint.endsWith('/participants/' + participantId + '/participations')){
				res.setBody(getParticipations());
			}
			else if(endpoint.endsWith('/participants/' + participantId + '/settlementInstructions')){
				res.setBody(getSettlementInstructions());
			}
			else if(endpoint.endsWith('/participants/' + participantId + '/bankAccountsCodes')){
				res.setBody(getBankAccountsCodes());
			}
			else if(endpoint.endsWith('/participations/1')){
				res.setBody(getParticipation(1));
			}
			else if(endpoint.endsWith('/participations/2')){
				res.setBody(getParticipation(2));
			}
			else if(endpoint.endsWith('/settlementInstructions/11')){
				res.setBody(getSettlementInstruction(11));
			}
			else if(endpoint.endsWith('/settlementInstructions/12')){
				res.setBody(getSettlementInstruction(12));
			}
			else if(endpoint.endsWith('/settlementInstructions/21')){
				res.setBody(getSettlementInstruction(21));
			}
			else if(endpoint.endsWith('/settlementInstructions/22')){
				res.setBody(getSettlementInstruction(22));
			}
			else if(endpoint.endsWith('/cycles/2017_12/cashflows')){
				res.setBody(getCycleCashflows('2017#12'));
			}
			else if(endpoint.endsWith('/cycles/2017_13/cashflows')){
				res.setBody(getCycleCashflows('2017#13'));
			}
			else if(endpoint.endsWith('/cycles/2017_12/participations')){
				res.setBody(getCycleParticipations('2017#12'));
			}
			else if(endpoint.endsWith('/cycles/2017_13/participations')){
				res.setBody(getCycleParticipations('2017#13'));
			}
			else if(endpoint.endsWith('/cycles/2017_12/participants/' + participantId + '/bankAccountsCodes')){
				res.setBody(getCycleBankAccountsCodes('2017#12'));
			}
			else if(endpoint.endsWith('/cycles/2017_13/participants/' + participantId + '/bankAccountsCodes')){
				res.setBody(getCycleBankAccountsCodes('2017#13'));
			}
			else if(endpoint.endsWith('/cycles/2017_12/settlementInstructions?participant_code=' + participantId)){
				res.setBody(getCycleSettlementInstructions('2017#12'));
			}
			else if(endpoint.endsWith('/cycles/2017_13/settlementInstructions?participant_code=' + participantId)){
				res.setBody(getCycleSettlementInstructions('2017#13'));
			}
			else if(endpoint.endsWith('/cycles/2017_12/settlementInstructions/1112')){
				res.setBody(getCycleSettlementInstruction('2017#12', 1112));
			}
			else if(endpoint.endsWith('/cycles/2017_12/settlementInstructions/2112')){
				res.setBody(getCycleSettlementInstruction('2017#12', 2112));
			}
			else if(endpoint.endsWith('/cycles/2017_12/settlementInstructions/1312')){
				res.setBody(getCycleSettlementInstruction('2017#12', 1312));
			}
			else if(endpoint.endsWith('/cycles/2017_12/settlementInstructions/1512')){
				res.setBody(getCycleSettlementInstruction('2017#12', 1512));
			}
			else if(endpoint.endsWith('/cycles/2017_13/settlementInstructions/1113')){
				res.setBody(getCycleSettlementInstruction('2017#13', 1113));
			}
			else if(endpoint.endsWith('/cycles/2017_13/settlementInstructions/2113')){
				res.setBody(getCycleSettlementInstruction('2017#13', 2113));
			}
			else if(endpoint.endsWith('/cycles/2017_13/settlementInstructions/2413')){
				res.setBody(getCycleSettlementInstruction('2017#13', 2413));
			}
			else if(endpoint.endsWith('/cycles/2017_13/settlementInstructions/1613')){
				res.setBody(getCycleSettlementInstruction('2017#13', 1613));
			}
			else if(endpoint.contains('/reports?participant_code=' + participantId)){
				res.setBody(GET_REPORTS);
			}
			else if(endpoint.endsWith('/reports/3ABF9348-F8AE-4AE2-869F-4C933378B115')){
				res.setBody('https://iccd-reports-nonprod-b81f751c2674d101.s3-eu-west-1.amazonaws.com/DEV-QA/Ultimate_Poster_1920x1080_7.jpg?X-Amz-Expires=86400&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIYHNJEMVQTXGNQ7A/20171207/eu-west-1/s3/aws4_request&X-Amz-Date=20171207T142652Z&X-Amz-SignedHeaders=host&X-Amz-Signature=58a8fcb4c883aa38f563bb53ba78ac4db86eab5a1a577552069c767b6138b655');
			}
			else if(endpoint.endsWith('/reports/3ABF9348-F8AE-4AE2-869F-4C933378AAAA')){
				res.setBody('https://iccd-reports-nonprod-b81f751c2674d101.s3-eu-west-1.amazonaws.com/DEV-QA/Ultimate_Poster_1920x1080_7.jpg?X-Amz-Expires=86400&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIYHNJEMVQTXGNQ7A/20171207/eu-west-1/s3/aws4_request&X-Amz-Date=20171207T142652Z&X-Amz-SignedHeaders=host&X-Amz-Signature=58a8fcb4c883aa38f563bb53ba78ac4db86eab5a1a577552069c767b6138b655');
			}
			else{
				res.setBody('');
			}		
		}
		
		// Case 2 : Response will be null for participantId NU000
		else if(participantId == 'ER000'){
			res = null;
		}

		// Case 3 : Response will be 400
		else if(participantId == 'ER400'){
			res.setStatusCode(400);
			res.setBody('Error 400');
		}

		// Case 4 : Response will be 401
		else if(participantId == 'ER401'){
			res.setStatusCode(401);
		}

		// Case 5 : Response will be 402
		else if(participantId == 'ER402'){
			res.setStatusCode(402);
			res.setBody('Error 402');
		}

		// Case 6 : Malformed Json
		else if(participantId == 'JS000'){
			res.setStatusCode(200);
			res.setBody('Malformed Json}');
		}

		return res;
	}


	private static final String CASHFLOW_1 =
		'    {'+
		'        "Id": 1,'+
		'        "Name": "Canada BSP",'+
		'        "Code": "CA_BSP_Y_CAD_I",'+
		'        "ProcessingCurrency": "CAD",'+
		'        "Type": {'+
		'            "Id": 1,'+
		'            "Code": "BSP"'+
		'        },'+
		'        "Country": {'+
		'            "Name": "Canada",'+
		'            "ISO3Code": "CAD"'+
		'        },'+
		'        "AccountCode": {'+
		'            "Id": 1,'+
		'            "Code": "P-123455CAD-01"'+
		'        }'+
		'    }';

	private static final String CASHFLOW_2 =
		'    {'+
		'        "Id": 2,'+
		'        "Name": "Canada BSP",'+
		'        "Code": "CA_BSP_Y_USD_I",'+
		'        "ProcessingCurrency": "USD",'+
		'        "Type": {'+
		'            "Id": 1,'+
		'            "Code": "BSP"'+
		'        },'+
		'        "Country": {'+
		'            "Name": "Canada",'+
		'            "ISO3Code": "CAD"'+
		'        },'+
		'        "AccountCode": {'+
		'            "Id": 2,'+
		'            "Code": "P-123455USD-01"'+
		'        }'+
		'    }';

	private static final String CASHFLOW_3 =
		'    {'+
		'        "Id": 3,'+
		'        "Name": "Ecuador CASS",'+
		'        "Code": "EC_CAS_Y_USD_I",'+
		'        "ProcessingCurrency": "USD",'+
		'        "Type": {'+
		'            "Id": 2,'+
		'            "Code": "CASS"'+
		'        },'+
		'        "Country": {'+
		'            "Name": "Ecuador",'+
		'            "ISO3Code": "ECU"'+
		'        },'+
		'        "AccountCode": {'+
		'            "Id": 3,'+
		'            "Code": "P-123466USD-01"'+
		'        }'+
		'    }';


	public static String getCashflows(){
		return '[' + CASHFLOW_1 + ',' + CASHFLOW_2 + ',' + CASHFLOW_3 + ']';
	}


	public static String getCycleCashflows(String cycleId){
		return '[' + CASHFLOW_1 + ',' + CASHFLOW_2 + ',' + CASHFLOW_3 + ']';
	}


	private static final String CYCLE_2017_12 = 
		'	{' +
		'		"CycleId": "2017#12",' +
		'		"Type": {' +
		'			"Id": 1,' +
		'			"Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"' +
		'		},' +
		'		"Status": {' +
		'			"Id": 1,' +
		'			"Code": "AdhocWindow"' +
		'		},' +
		'		"StartDate": "2017-09-25T11:38:55.324Z",' +
		'		"EndDate": "2017-09-25T11:38:55.324Z",' +
		'		"Comment": "string"' +
		'	}';

	private static final String CYCLE_2017_13 = 
		'	{' +
		'		"CycleId": "2017#13",' +
		'		"Type": {' +
		'			"Id": 1,' +
		'			"Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"' +
		'		},' +
		'		"Status": {' +
		'			"Id": 1,' +
		'			"Code": "AdhocWindow"' +
		'		},' +
		'		"StartDate": "2017-09-26T11:38:55.324Z",' +
		'		"EndDate": "2017-09-26T11:38:55.324Z",' +
		'		"Comment": "string"' +
		'	}';

	private static final String CYCLE_2017_14 = 
		'	{' +
		'		"CycleId": "2017#14",' +
		'		"Type": {' +
		'			"Id": 1,' +
		'			"Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"' +
		'		},' +
		'		"Status": {' +
		'			"Id": 1,' +
		'			"Code": "Created"' +
		'		},' +
		'		"StartDate": "2017-09-25T11:38:55.324Z",' +
		'		"EndDate": "2017-09-25T11:38:55.324Z",' +
		'		"Comment": "string"' +
		'	}';

	private static final String CYCLE_2017_15 = 
		'	{' +
		'		"CycleId": "2017#15",' +
		'		"Type": {' +
		'			"Id": 1,' +
		'			"Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"' +
		'		},' +
		'		"Status": {' +
		'			"Id": 1,' +
		'			"Code": "Created"' +
		'		},' +
		'		"StartDate": "2017-09-26T11:38:55.324Z",' +
		'		"EndDate": "2017-09-26T11:38:55.324Z",' +
		'		"Comment": "string"' +
		'	}';

	private static final String CYCLE_2017_23 = 
		'	{' +
		'		"CycleId": "2017#23",' +
		'		"Type": {' +
		'			"Id": 1,' +
		'			"Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"' +
		'		},' +
		'		"Status": {' +
		'			"Id": 1,' +
		'			"Code": "Created"' +
		'		},' +
		'		"StartDate": "2017-09-26T11:38:55.324Z",' +
		'		"EndDate": "2017-09-26T11:38:55.324Z",' +
		'		"Comment": "string"' +
		'	}';

	private static final String CYCLE_2017_26 = 
		'	{' +
		'		"CycleId": "2017#26",' +
		'		"Type": {' +
		'			"Id": 1,' +
		'			"Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"' +
		'		},' +
		'		"Status": {' +
		'			"Id": 1,' +
		'			"Code": "Created"' +
		'		},' +
		'		"StartDate": "2017-09-26T11:38:55.324Z",' +
		'		"EndDate": "2017-09-26T11:38:55.324Z",' +
		'		"Comment": "string"' +
		'	}';

	public static String getAdhocWindowCycles(){
		return '{"PagingInfo":{"Records":2},"Cycles":[' + CYCLE_2017_12 + ',' + CYCLE_2017_13 + ']}';
	}

	public static String getCreatedCycles(){
		return '{"PagingInfo":{"Records":2},"Cycles":[' + CYCLE_2017_14 + ',' + CYCLE_2017_15 + ']}';
	}
	
	public static String getAllCycles(){
		return '{"PagingInfo":{"Records":6},"Cycles":[' + CYCLE_2017_12 + ',' + CYCLE_2017_13 + ',' + CYCLE_2017_14 + ',' + CYCLE_2017_15 + ',' + CYCLE_2017_23 + ',' + CYCLE_2017_26 + ']}';
	}
	
	public static String getReportTypes(){
		return	'[' +
			    '	{ "Code": "30F", "Description": "Approximate Report" },' +
			    '	{ "Code": "31F", "Description": "Final Report" }' +
				']';
	}
	
    public static String getBankAccountsCodes(){
		return	'[{'+
			'    "Id": 1,'+
			'    "Code": "P-02792USD-01",'+
			'    "BankAccount": {'+
			'        "Id": 1,'+
			'        "Currency": "USD",'+
			'        "Number": "xxxxxxxxxxxxxx1234",'+
			'        "Bank": {'+
			'            "Name": "Citi London",'+
			'            "Bic": "laksdjlaksjd"'+
			'        }'+
			'    }'+
			'},'+
			'{'+
			'    "Id": 2,'+
			'    "Code": "P-02792USD-02",'+
			'    "BankAccount": {'+
			'        "Id": 2,'+
			'        "Currency": "USD",'+
			'        "Number": "xxxxxxxxxxxxxx6789",'+
			'        "Bank": {'+
			'            "Name": "Citi Westminster",'+
			'            "Bic": "abcdefghij"'+
			'        }'+
			'    }'+
			'},'+		
			'{'+
			'    "Id": 3,'+
			'    "Code": "P-02793EUR-01",'+
			'    "BankAccount": {'+
			'        "Id": 3,'+
			'        "Currency": "EUR",'+
			'        "Number": "xxxxxxxxxxxxxx4567",'+
			'        "Bank": {'+
			'            "Name": "Citi London",'+
			'            "Bic": "laksdjlaksjd"'+
			'        }'+
			'    }'+
			'},'+		
			'{'+
			'    "Id": 4,'+
			'    "Code": "P-02792USD-01-01",'+
			'    "BankAccount": {'+
			'        "Id": 1,'+
			'        "Currency": "USD",'+
			'        "Number": "xxxxxxxxxxxxxx1234",'+
			'        "Bank": {'+
			'            "Name": "Citi London",'+
			'            "Bic": "laksdjlaksjd"'+
			'        }'+
			'    }'+
			'}]';
    }

    public static String getCycleBankAccountsCodes(String cycleId){
		return	'[{'+
			'    "Id": 1,'+
			'    "Code": "P-02792USD-01",'+
			'    "BankAccount": {'+
			'        "Id": 1,'+
			'        "Currency": "USD",'+
			'        "Number": "xxxxxxxxxxxxxx1234",'+
			'        "Bank": {'+
			'            "Name": "Citi London",'+
			'            "Bic": "laksdjlaksjd"'+
			'        }'+
			'    }'+
			'},'+
			'{'+
			'    "Id": 2,'+
			'    "Code": "P-02792USD-02",'+
			'    "BankAccount": {'+
			'        "Id": 2,'+
			'        "Currency": "USD",'+
			'        "Number": "xxxxxxxxxxxxxx6789",'+
			'        "Bank": {'+
			'            "Name": "Citi Westminster",'+
			'            "Bic": "abcdefghij"'+
			'        }'+
			'    }'+
			'},'+		
			'{'+
			'    "Id": 3,'+
			'    "Code": "P-02793EUR-01",'+
			'    "BankAccount": {'+
			'        "Id": 3,'+
			'        "Currency": "EUR",'+
			'        "Number": "xxxxxxxxxxxxxx4567",'+
			'        "Bank": {'+
			'            "Name": "Citi London",'+
			'            "Bic": "laksdjlaksjd"'+
			'        }'+
			'    }'+
			'},'+		
			'{'+
			'    "Id": 4,'+
			'    "Code": "P-02792USD-01-01",'+
			'    "BankAccount": {'+
			'        "Id": 1,'+
			'        "Currency": "USD",'+
			'        "Number": "xxxxxxxxxxxxxx1234",'+
			'        "Bank": {'+
			'            "Name": "Citi London",'+
			'            "Bic": "laksdjlaksjd"'+
			'        }'+
			'    }'+
			'}]';
    }


	private static final String PARTICIPATION_1 = 
		'  {'+
		'    "Id": 1,'+
		'	 "Participant":{' +
		'	 	"Code" : "LX724"' +
		'    },'+
		'    "Cashflow": {'+
		'        "Id": 1,'+
		'        "Name": "Canada BSP",'+
		'        "Code": "CA_BSP_Y_CAD_I",'+
		'        "ProcessingCurrency": "CAD",'+
		'        "AccountCode": {'+
		'            "Id": 1,'+
		'            "Code": "P-123455CAD-01"'+
		'        }'+
		'    },'+
		'    "StartDate": "2010-05-01",'+
		'    "EndDate": null,'+
		'    "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'  }';

	private static final String PARTICIPATION_2 = 
		'  {'+
		'    "Id": 2,'+
		'	 "Participant":{' +
		'	 	"Code" : "LX724"' +
		'    },'+
		'    "Cashflow": {'+
		'        "Id": 2,'+
		'        "Name": "Canada BSP",'+
		'        "Code": "CA_BSP_Y_USD_I",'+
		'        "ProcessingCurrency": "USD",'+
		'        "AccountCode": {'+
		'            "Id": 2,'+
		'            "Code": "P-123455USD-01"'+
		'        }'+
		'    },'+
		'    "StartDate": "2010-05-01",'+
		'    "EndDate": "2100-01-01",'+
		'    "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'  }';




    public static String getParticipations(){
    	return '[' + PARTICIPATION_1 + ',' + PARTICIPATION_2 + ']';
    }
    
    public static String getCycleParticipations(String cycleId){
    	// TO BE REVIEWED
    	return '[' + PARTICIPATION_1 + ',' + PARTICIPATION_2 + ']';
    }
    
    public static String getParticipation(Integer participationId){
    	if(participationId == 1){
    		return PARTICIPATION_1;
    	}
    	else{
    		return PARTICIPATION_2;
    	}
    }

	private static final String STANDARD_SI_PARTICIPATION_1 =
		'	  {'+
		'	    "Id": 11,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	  }';	


	private static final String STANDARD_SI_PARTICIPATION_1_DETAIL =
		'	  {'+
		'	    "Id": 11,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD"'+
		'    		}'+
		'  		},'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 111,'+
		'	        "Order": 3,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 112,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 100000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 113,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 4,'+
		'	            "Code": "Percentage"'+
		'	        },'+
		'	        "Value": 25,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';	

	private static final String STANDARD_SI_PARTICIPATION_2 =
		'	  {'+
		'	    "Id": 21,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	  }';


	private static final String STANDARD_SI_PARTICIPATION_2_DETAIL =
		'	  {'+
		'	    "Id": 21,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_USD_I",'+
		'        		"ProcessingCurrency": "USD",'+
		'        		"AccountCode": {'+
		'            		"Id": 2,'+
		'            		"Code": "P-123455USD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 211,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 2,'+
		'    			"Code": "P-02792USD-02",'+
		'    			"BankAccount": {'+
		'        			"Id": 2,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx6789",'+
		'        			"Bank": {'+
		'            			"Name": "Citi Westminster",'+
		'            			"Bic": "abcdefghij"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 212,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 4,'+
		'    			"Code": "P-02793USD-03",'+
		'    			"BankAccount": {'+
		'        			"Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 0,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';

	private static final String FUTURE_SI_CYCLE_14_PARTICIPATION_1 =
		'	  {'+
		'	    "Id": 12,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#14"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	  }';

	private static final String FUTURE_SI_CYCLE_14_PARTICIPATION_1_DETAIL =
		'	  {'+
		'	    "Id": 12,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#14"'+
		'	    },'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD"'+
		'    		}'+
		'  		},'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 121,'+
		'	        "Order": 3,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 122,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 100000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 123,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 4,'+
		'	            "Code": "Percentage"'+
		'	        },'+
		'	        "Value": 25,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';

	private static final String FUTURE_SI_CYCLE_15_PARTICIPATION_2 =
		'	  {'+
		'	    "Id": 22,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#15"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	  }';


	private static final String FUTURE_SI_CYCLE_15_PARTICIPATION_2_DETAIL =
		'	  {'+
		'	    "Id": 22,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#15"'+
		'	    },'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_USD_I",'+
		'        		"ProcessingCurrency": "USD"'+
		'    		}'+
		'  		},'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 221,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 2,'+
		'    			"Code": "P-02792USD-02",'+
		'    			"BankAccount": {'+
		'        			"Id": 2,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx6789",'+
		'        			"Bank": {'+
		'            			"Name": "Citi Westminster",'+
		'            			"Bic": "abcdefghij"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 222,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 4,'+
		'    			"Code": "P-02793USD-03",'+
		'    			"BankAccount": {'+
		'        			"Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 0,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';


	private static final String ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_1 =
		'	  {'+
		'	    "Id": 1112,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'		"IsApplied": false,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 10000.00'+
		'	  }';	

	private static final String ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_1_DETAIL =
		'	  {'+
		'	    "Id": 1112,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": false,'+
		'  		"SettlementAmount": 10000.00,'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 11121,'+
		'	        "Order": 3,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 11122,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 100000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 11123,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 4,'+
		'	            "Code": "Percentage"'+
		'	        },'+
		'	        "Value": 25,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';	


	private static final String ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_1 =
		'	  {'+
		'	    "Id": 1113,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'		"IsApplied": false,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 20000.00'+
		'	  }';	


	private static final String ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_1_DETAIL =
		'	  {'+
		'	    "Id": 1113,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": false,'+
		'  		"SettlementAmount": 20000.00,'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 11131,'+
		'	        "Order": 3,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 11132,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 100000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 11133,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 4,'+
		'	            "Code": "Percentage"'+
		'	        },'+
		'	        "Value": 25,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';

	private static final String ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_2 =
		'	  {'+
		'	    "Id": 2112,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'		"IsApplied": false,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_USD_I",'+
		'        		"ProcessingCurrency": "USD",'+
		'        		"AccountCode": {'+
		'            		"Id": 2,'+
		'            		"Code": "P-123455USD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 20000.00'+
		'	  }';	


	private static final String ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_2_DETAIL =
		'	  {'+
		'	    "Id": 2112,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": false,'+
		'  		"SettlementAmount": 20000.00,'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_USD_I",'+
		'        		"ProcessingCurrency": "USD",'+
		'        		"AccountCode": {'+
		'            		"Id": 2,'+
		'            		"Code": "P-123455USD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 21121,'+
		'	        "Order": 3,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 21122,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 100000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 21123,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 4,'+
		'	            "Code": "Percentage"'+
		'	        },'+
		'	        "Value": 25,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';

	private static final String ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_2 =
		'	  {'+
		'	    "Id": 2113,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'		"IsApplied": false,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_USD_I",'+
		'        		"ProcessingCurrency": "USD",'+
		'        		"AccountCode": {'+
		'            		"Id": 2,'+
		'            		"Code": "P-123455USD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 20000.00'+
		'	  }';	



	private static final String ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_2_DETAIL =
		'	  {'+
		'	    "Id": 2113,'+
		'	    "Type": {'+
		'	        "Id": 1,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": false,'+
		'  		"SettlementAmount": 20000.00,'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_USD_I",'+
		'        		"ProcessingCurrency": "USD",'+
		'        		"AccountCode": {'+
		'            		"Id": 2,'+
		'            		"Code": "P-123455USD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 21131,'+
		'	        "Order": 3,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 21132,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 100000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 21133,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 4,'+
		'	            "Code": "Percentage"'+
		'	        },'+
		'	        "Value": 25,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';	


	private static final String ADHOC_FUTURE_SI_CYCLE_12_PARTICIPATION_1 =
		'	  {'+
		'	    "Id": 1312,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'		"IsApplied": false,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 10000.00'+
		'	  }';


	private static final String ADHOC_FUTURE_SI_CYCLE_12_PARTICIPATION_1_DETAIL =
		'	  {'+
		'	    "Id": 1312,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": false,'+
		'  		"SettlementAmount": 10000.00,'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 13121,'+
		'	        "Order": 3,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 13122,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 100000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 13123,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 1,'+
		'    			"Code": "P-02792USD-01",'+
		'    			"BankAccount": {'+
		'    			    "Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 4,'+
		'	            "Code": "Percentage"'+
		'	        },'+
		'	        "Value": 25,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';

	private static final String ADHOC_FUTURE_SI_CYCLE_13_PARTICIPATION_2 =
		'	  {'+
		'	    "Id": 2413,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'		"IsApplied": false,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Cashflow name",'+
		'        		"Code": "BSPPRT",'+
		'        		"ProcessingCurrency": "EUR",'+
		'        		"AccountCode": {'+
		'            		"Id": 3,'+
		'            		"Code": "P-02793EUR-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 20000.00'+
		'	  }';


	private static final String ADHOC_FUTURE_SI_CYCLE_13_PARTICIPATION_2_DETAIL =
		'	  {'+
		'	    "Id": 2413,'+
		'	    "Type": {'+
		'	        "Id": 2,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": false,'+
		'  		"SettlementAmount": 20000.00,'+
		'  		"Participation":{'+
		'    		"Id": 2,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 2,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_USD_I",'+
		'        		"ProcessingCurrency": "USD",'+
		'        		"AccountCode": {'+
		'            		"Id": 2,'+
		'            		"Code": "P-123455USD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 24131,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 2,'+
		'    			"Code": "P-02792USD-02",'+
		'    			"BankAccount": {'+
		'        			"Id": 2,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx6789",'+
		'        			"Bank": {'+
		'            			"Name": "Citi Westminster",'+
		'            			"Bic": "abcdefghij"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 24132,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 4,'+
		'    			"Code": "P-02793USD-03",'+
		'    			"BankAccount": {'+
		'        			"Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 0,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';


	private static final String ADHOC_SI_CYCLE_12_PARTICIPATION_1 =
		'	  {'+
		'	    "Id": 1512,'+
		'	    "Type": {'+
		'	        "Id": 3,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_ADHOC + '"'+
		'	    },'+
		'		"IsApplied": true,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 10000.00'+
		'	  }';


	private static final String ADHOC_SI_CYCLE_12_PARTICIPATION_1_DETAIL =
		'	  {'+
		'	    "Id": 1512,'+
		'	    "Type": {'+
		'	        "Id": 3,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_ADHOC + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#12"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": true,'+
		'  		"SettlementAmount": 10000.00,'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 15121,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 2,'+
		'    			"Code": "P-02792USD-02",'+
		'    			"BankAccount": {'+
		'        			"Id": 2,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx6789",'+
		'        			"Bank": {'+
		'            			"Name": "Citi Westminster",'+
		'            			"Bic": "abcdefghij"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 15122,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 4,'+
		'    			"Code": "P-02793USD-03",'+
		'    			"BankAccount": {'+
		'        			"Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 0,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';

	private static final String ADHOC_SI_CYCLE_13_PARTICIPATION_1 =
		'	  {'+
		'	    "Id": 1613,'+
		'	    "Type": {'+
		'	        "Id": 3,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_ADHOC + '"'+
		'	    },'+
		'		"IsApplied": true,'+
		'		"ApprovalStatus": "Approved",'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'  		"SettlementAmount": 10000.00'+
		'	  }';


	private static final String ADHOC_SI_CYCLE_13_PARTICIPATION_1_DETAIL =
		'	  {'+
		'	    "Id": 1613,'+
		'	    "Type": {'+
		'	        "Id": 3,'+
		'	        "Code": "' + ISSP_ICCS_Utils.SI_ADHOC + '"'+
		'	    },'+
		'	    "Cycle": {'+
		'	        "CycleId": "2017#13"'+
		'	    },'+
		'		"ModifiedOn": "2017-09-14T10:08:31.117Z",'+
		'		"IsApplied": true,'+
		'  		"SettlementAmount": 10000.00,'+
		'  		"Participation":{'+
		'    		"Id": 1,'+
		'	 		"Participant":{' +
		'	 			"Code" : "LX724"' +
		'    		},'+
		'    		"Cashflow": {'+
		'        		"Id": 1,'+
		'        		"Name": "Canada BSP",'+
		'        		"Code": "CA_BSP_Y_CAD_I",'+
		'        		"ProcessingCurrency": "CAD",'+
		'        		"AccountCode": {'+
		'            		"Id": 1,'+
		'            		"Code": "P-123455CAD-01"'+
		'        		}'+
		'    		}'+
		'  		},'+
		'	    "InstructionLines": ['+
		'	      {'+
		'	        "Id": 16131,'+
		'	        "Order": 1,'+
		'      		"AccountCode": {'+
		'    			"Id": 2,'+
		'    			"Code": "P-02792USD-02",'+
		'    			"BankAccount": {'+
		'        			"Id": 2,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx6789",'+
		'        			"Bank": {'+
		'            			"Name": "Citi Westminster",'+
		'            			"Bic": "abcdefghij"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 1,'+
		'	            "Code": "Fixed"'+
		'	        },'+
		'	        "Value": 300000,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      },'+
		'	      {'+
		'	        "Id": 16132,'+
		'	        "Order": 2,'+
		'      		"AccountCode": {'+
		'    			"Id": 4,'+
		'    			"Code": "P-02793USD-03",'+
		'    			"BankAccount": {'+
		'        			"Id": 1,'+
		'        			"Currency": "USD",'+
		'        			"Number": "xxxxxxxxxxxxxx1234",'+
		'        			"Bank": {'+
		'            			"Name": "Citi London",'+
		'            			"Bic": "laksdjlaksjd"'+
		'        			}'+
		'    			}'+
		'      		},'+
		'	        "Type": {'+
		'	            "Id": 2,'+
		'	            "Code": "Balance"'+
		'	        },'+
		'	        "Value": 0,'+
		'	        "ModifiedOn": "2017-09-14T10:08:31.117Z"'+
		'	      }'+
		'	    ]'+
		'	  }';


	public static final Map<Integer, String> SI_DETAIL_MAP = new Map<Integer, String>{
		1112 => ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_1_DETAIL,
		2112 => ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_2_DETAIL,
		1312 => ADHOC_FUTURE_SI_CYCLE_12_PARTICIPATION_1_DETAIL,
		1512 => ADHOC_SI_CYCLE_12_PARTICIPATION_1_DETAIL,
		1113 => ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_1_DETAIL,
		2113 => ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_2_DETAIL,
		2413 => ADHOC_FUTURE_SI_CYCLE_13_PARTICIPATION_2_DETAIL,
		1613 => ADHOC_SI_CYCLE_13_PARTICIPATION_1_DETAIL
	};



	public static String getParticipationSettlementInstructions(Integer participationId){
		if(participationId == 1){
			return '[' + STANDARD_SI_PARTICIPATION_1 + ',' + FUTURE_SI_CYCLE_14_PARTICIPATION_1 + ']';
		}
		else{
			return '[' + STANDARD_SI_PARTICIPATION_2 + ',' + FUTURE_SI_CYCLE_15_PARTICIPATION_2 + ']';
		}
	}
	
	public static String getSettlementInstruction(Integer settlementInstructionId){
		if(settlementInstructionId == 11){
			return STANDARD_SI_PARTICIPATION_1_DETAIL;
		}
		else if(settlementInstructionId == 12){
			return FUTURE_SI_CYCLE_14_PARTICIPATION_1_DETAIL;
		}
		else if(settlementInstructionId == 21){
			return STANDARD_SI_PARTICIPATION_2_DETAIL;
		}
		else{
			return FUTURE_SI_CYCLE_15_PARTICIPATION_2_DETAIL;
		}
	}

	public static String getSettlementInstructions(){
		return '[' + STANDARD_SI_PARTICIPATION_1_DETAIL + ',' + FUTURE_SI_CYCLE_14_PARTICIPATION_1_DETAIL + ',' + STANDARD_SI_PARTICIPATION_2_DETAIL + ',' + FUTURE_SI_CYCLE_15_PARTICIPATION_2_DETAIL + ']';
	}

	public static String getSettlementInstructionsOfCycle(String cycleId){
		if(cycleId == '2017#12'){
			return '[' + ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_1 + ',' + ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_2 + ',' + ADHOC_FUTURE_SI_CYCLE_12_PARTICIPATION_1 + ',' + ADHOC_SI_CYCLE_12_PARTICIPATION_1 + ']';
		}
		else{
			return '[' + ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_1 + ',' + ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_2 + ',' + ADHOC_FUTURE_SI_CYCLE_13_PARTICIPATION_2 + ',' + ADHOC_SI_CYCLE_13_PARTICIPATION_1 + ']';
		}
	}

	public static String getCycleSettlementInstructions(String cycleId){
		if(cycleId == '2017#12'){
			return '[' + ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_1 + ',' + ADHOC_STANDARD_SI_CYCLE_12_PARTICIPATION_2 + ',' + ADHOC_FUTURE_SI_CYCLE_12_PARTICIPATION_1 + ',' + ADHOC_SI_CYCLE_12_PARTICIPATION_1 + ']';
		}
		else{
			return '[' + ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_1 + ',' + ADHOC_STANDARD_SI_CYCLE_13_PARTICIPATION_2 + ',' + ADHOC_FUTURE_SI_CYCLE_13_PARTICIPATION_2 + ',' + ADHOC_SI_CYCLE_13_PARTICIPATION_1 + ']';
		}
	}

	public static String getCycleSettlementInstruction(String cycleId, Integer settlementInstructionId){
		return SI_DETAIL_MAP.get(settlementInstructionId);
	}
	
	public static String getInstructionTypes(){ 
	    return 	'['+
				'  {"Id": 1, "Code": "' + ISSP_ICCS_Utils.SI_STANDARD + '", "Description": "Standard"},'+
				'  {"Id": 2, "Code": "' + ISSP_ICCS_Utils.SI_FUTURE + '", "Description": "Future"},'+
				'  {"Id": 3, "Code": "' + ISSP_ICCS_Utils.SI_ADHOC + '", "Description": "Adhoc"}'+
				']';
	}
	
	public static String getInstructionLineTypes(){
		return 	'['+
				'    {"Id": 1, "Code": "Fixed", "Description": "Fixed"},'+
				'    {"Id": 2, "Code": "Balance", "Description": "Balance"},'+
				'    {"Id": 3, "Code": "MonthlyThreshold", "Description": "Monthly Threshold"},'+
				'    {"Id": 4, "Code": "Percentage", "Description": "Percentage"}'+
				']';
	}

	public static final String GET_REPORTS = 
		'{' +
			'"PagingInfo": {' +
			'	"Records": 123' +
			'},' +
			'"Reports":' +
				'[{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378B115",' +
			       ' "Name": "myfancyreport",' +
			       ' "ParticipantCode": "4B184",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	},' +
			       ' 	{'+
			       '		"format": "csv",' +
			       '		"mimetype": "text/csv"' +
			       '	},' +
			       ' 	{'+
			       '		"format": "xlsx",' +
			       '		"mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"' +
			       '	}' +
			       ' ],' +
			       ' "CycleId": "2017#23",' +
			       ' "Type": {'+
			       '	"Code": "31A",' +
			       '	"Description": "Some report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				'},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '},' + 
				'{' +
			       ' "Id": "3ABF9348-F8AE-4AE2-869F-4C933378AAAA",' +
			       ' "Name": "myotherfancyreport",' +
			       ' "AvailableFormats": [' +
			       ' 	{'+
			       '		"format": "pdf",' +
			       '		"mimetype": "application/pdf"' +
			       '	}' +
			       ' ],' +
			       ' "ParticipantCode": "4B1AA",' +
			       ' "CycleId": "2017#26",' +
			       ' "Type": {'+
			       '	"Code": "31F",' +
			       '	"Description": "Some final report"' +
			       ' },' +
			       ' "UploadDate": "2017-09-06T15:09:46.263Z"' +
				   '}' +
				']' +
		'}';
		
	public static final String GET_REPORT = 
		'{'+
		'    "Id": "3ABF9348-F8AE-4AE2-869F-4C933378B115",'+
		'    "Name": "myfancydata.xlsx",'+
		'    "ParticipantCode": "4B184",'+
		'    "CycleCode": "2017#23",'+
        ' 	 "Type": {'+
        '	 	"Code": "31A"' +
        ' 	 },' +
		'    "UploadDate": "2017-09-06T15:09:46.263Z"'+
		'}';
}