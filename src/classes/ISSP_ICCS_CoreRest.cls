public class ISSP_ICCS_CoreRest{

	public static final String CORE_EXCEPTION = 'Core Exception : ';
	public static final String JSON_EXCEPTION = 'JSON Exception : ';

	public ISSP_ICCS_ServiceController pageController;
	
	public String tokenURL;
	public String username;
	public String password;
	public String serviceURL;
	
	public String token {
		get{
			if(token == null){
				System.debug('***** ISSP_ICCS_CoreRest retrieving token *****');
		
		        HttpRequest req = new HttpRequest();

		        req.setEndpoint(tokenURL);
		        req.setMethod('POST');	
		        req.setHeader('Content-Type','application/x-www-form-urlencoded');
		        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
		        req.setBody('grant_type=client_credentials');
		        
		        Http http = new Http();
		        HttpResponse response;
		        
		        if(!Test.isRunningTest()){
					try{
						response = http.send(req);
					}
					catch(Exception e){
						throw new ICCS_Exception('ISSP_ICCS_CoreRest retrieving token : ' + CORE_EXCEPTION + ' - ' + e.getMessage());
					}
				}
				else{
					response = ISSP_ICCS_Mock.getMockToken(pageController.participantId);
				}
		        
		        System.debug('RESPONSE : ' + response);
		        
		        if(response == null){
		        	throw new ICCS_Exception('ISSP_ICCS_CoreRest retrieving token : ' + CORE_EXCEPTION + ' No reponse from server');
		        }
		        else if(response.getStatusCode() != 200){
		        	throw new ICCS_Exception('ISSP_ICCS_CoreRest retrieving token : ' + CORE_EXCEPTION + response.getStatusCode() + ' - ' + response.getStatus());
		        }
		        else{
					Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
					System.debug('ISSP_ICCS_CoreRest retrieving token - response body : ' + m);
					token = (String) m.get('access_token');
		        }
			}
	        return token;
		}
		set;
	}


	/* CONSTRUCTOR */
	public ISSP_ICCS_CoreRest (ISSP_ICCS_ServiceController pageController){
		this.pageController = pageController;
		
		if(UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'){
			tokenURL = Label.ICCS_Endpoint_Token_URL_PROD;
			username = Label.ICCS_Endpoint_Username_PROD;
			password = Label.ICCS_Endpoint_Password_PROD;
			serviceURL = Label.ICCS_Endpoint_Services_URL_PROD;
		}
		else{
			tokenURL = Label.ICCS_Endpoint_Token_URL;
			username = Label.ICCS_Endpoint_Username;
			password = Label.ICCS_Endpoint_Password;
			serviceURL = Label.ICCS_Endpoint_Services_URL; 
		}
	}
	


	public HttpResponse sendRequest(String method, String body, String service, Map<String, String> headers, Boolean resetTokenIfExpired){
		System.debug('**** ' + (serviceURL + service) + ' ****');
		HttpRequest req = new HttpRequest();

		// Request endpoint
        req.setEndpoint(serviceURL + service);

		// Request method
        req.setMethod(method);

		// Request headers
		try{
        	req.setHeader('Authorization','Bearer ' + token);
        }
        catch(ICCS_Exception e){throw e;}

        req.setHeader('participant_code', pageController.participantId);
        
        if(headers != null){
        	for(String key : headers.keySet()){
		        req.setHeader(key,headers.get(key));
        	}
        }

		req.setTimeout(20000);
        
		// Request body
        if(body != ''){
        	System.debug('**** Request body ****');
        	System.debug(body);
        	req.setHeader('Content-Type', 'application/json');
	        req.setBody(body);
        }

        Http http = new Http();
        HttpResponse response;
        
		if(!Test.isRunningTest()){
	        try{
				response = http.send(req);
	        }
	        catch(Exception e){
	        	throw new ICCS_Exception(CORE_EXCEPTION + e.getMessage());
	        }
		}
		else{
			response = ISSP_ICCS_Mock.getMockResponse(serviceURL + service, pageController.participantId);
		}        
        
		// Handle response
        if(response == null){
        	throw new ICCS_Exception(CORE_EXCEPTION + 'No reponse from server');
        }
        // check if we can have several valid status code for a call. If so, we'll have to work with a list of Integer
        else if(response.getStatusCode() < 200 || response.getStatusCode() >= 400 ){
        	if(response.getStatusCode() == 400 && response.getBody() != null && response.getBody() != ''){
	        	throw new ICCS_Exception(response.getBody());
        	}
			// If token is expired, a 401 response is received. If it's the first attempt, the token is nullified (next get will then retrieve it again)
			// and the method is called again. The resetTokenIfExpired boolean value is used to avoid an infinite loop: only one additional attempt will be done
        	else if(response.getStatusCode() == 401 && resetTokenIfExpired){
        		token = null;
        		return sendRequest(method, body, service, headers, false);
        	}
        	else{
        		throw new ICCS_Exception(CORE_EXCEPTION + response.getStatusCode() + ' - ' + response.getStatus());
        	}
        }
        
		System.debug('**** Response body ****\n' + response.getBody());

        return response;
	}


	/*******************
		GENERIC DATA
	*******************/
	
	/*	GET /cashflows
		
		Returns the list of existing cashflows.
	*/
	public List<Cashflow> getCashflows(){
		System.debug('**** ISSP_ICCS_CoreRest.getCashflows() ****');

		HttpResponse response = sendRequest('GET', '', '/cashflows', null, true);

		try{
			String result = response.getBody();
			return (List<Cashflow>) JSON.deserialize(result, List<Cashflow>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}


	/*	GET /cycles
		
		Returns a filtered, ordered list of cycles. The statuses SF is interested in are 'Created' (for future) and 'AdHocWindow' (for cycle).
	*/
	public List<Cycle> getCycles(Set<CYCLE_STATUS> statuses){
		System.debug('**** ISSP_ICCS_CoreRest.getCycles(' + statuses + ') ****');

		String finalEndpoint = '/cycles';
		
		List<String> parameters = new List<String>();
		
		if(statuses != null && !statuses.isEmpty()){
			List<String> statusNames = new List<String>();
			for(CYCLE_STATUS status : statuses){
				statusNames.add(status.name());
			}
			parameters.add('status=' + String.join(statusNames, ','));
		}

		if(!parameters.isEmpty()){
			finalEndpoint += '?' + String.join(parameters, '&');
		}

		HttpResponse response = sendRequest('GET', '', finalEndpoint, null, true);

		try{
			String result = response.getBody();
			return ((Cycles) JSON.deserialize(result, Cycles.class)).cycles;
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}

	
	/*	GET /settlementInstructions/types
		
		Returns the list of instruction types.
	*/
	public List<InstructionType> getInstructionTypes(){
		System.debug('**** ISSP_ICCS_CoreRest.getInstructionTypes() ****');

		HttpResponse response = sendRequest('GET', '', '/settlementInstructions/types', null, true);

		try{
			String result = response.getBody();
			return (List<InstructionType>) JSON.deserialize(result, List<InstructionType>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}

	
	/*	GET /settlementInstructions/linetypes
		
		Returns the list of instruction line types
	*/
	public List<InstructionLineType> getInstructionLineTypes(){
		System.debug('**** ISSP_ICCS_CoreRest.getInstructionLineTypes() ****');

		HttpResponse response = sendRequest('GET', '', '/settlementInstructions/lineTypes', null, true);

		try{
			String result = response.getBody();
			return (List<InstructionLineType>) JSON.deserialize(result, List<InstructionLineType>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}
	
	
	/*	GET /reports/types
		
		Returns the list of report types
	*/
	public List<ReportType> getReportTypes(){
		System.debug('**** ISSP_ICCS_CoreRest.getReportTypes() ****');

		HttpResponse response = sendRequest('GET', '', '/reports/types', null, true);

		try{
			String result = response.getBody();
			return (List<ReportType>) JSON.deserialize(result, List<ReportType>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}
	



	/***********************
		PARTICIPANT DATA
	***********************/


	/*	GET /participants/{participant_code}/participations
		
		Returns the list of participations for a specific participant.
	 */
	public List<Participation> getParticipations(){
		System.debug('**** ISSP_ICCS_CoreRest.getParticipations() ****');

		HttpResponse response = sendRequest('GET', '', '/participants/' + pageController.participantId + '/participations', null, true);

		try{
			String result = response.getBody();
			return (List<Participation>) JSON.deserialize(result, List<Participation>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}
	
	/*	GET /participants/{participant_code}/settlementInstructions	
		
		Returns the list of settlement instructions for a specific participant.
	 */
	public List<SettlementInstruction> getSettlementInstructions(){
		System.debug('**** ISSP_ICCS_CoreRest.getSettlementInstructions() ****');

		HttpResponse response = sendRequest('GET', '', '/participants/' + pageController.participantId + '/settlementInstructions', null, true);

		try{
			String result = response.getBody().replaceAll('"Currency"', '"Currency_x"').replaceAll('"Number"', '"Number_x"');
			return (List<SettlementInstruction>) JSON.deserialize(result, List<SettlementInstruction>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}


	/*	GET /participants/{participant_code}/bankAccountsCodes
		
		Returns the list of Bank Account Codes for a specific participant.
	*/
	public List<BankAccountCode> getBankAccountsCodes(){
		System.debug('**** ISSP_ICCS_CoreRest.getBankAccountsCodes() ****');

		HttpResponse response = sendRequest('GET', '', '/participants/' + pageController.participantId + '/bankAccountsCodes', null, true);

		try{
			String result = response.getBody().replaceAll('"Currency"', '"Currency_x"').replaceAll('"Number"', '"Number_x"');
			return (List<BankAccountCode>) JSON.deserialize(result, List<BankAccountCode>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}


	/*************************
		PARTICIPATION DATA
	*************************/

	/*	GET /participations/{pid}

		Returns a specific participation.
	*/
	public Participation getParticipation(Integer participationId){
		System.debug('**** ISSP_ICCS_CoreRest.getParticipation(' + participationId + ') ****');

		HttpResponse response = sendRequest('GET', '', '/participations/' + participationId, null, true);

		try{
			String result = response.getBody();
			return (Participation) JSON.deserialize(result, Participation.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}

	/*********************************************************
		SETTLEMENT INSTRUCTIONS DATA (STANDARD AND FUTURE)
	**********************************************************/

	/*	GET /settlementInstructions/{sid}
		
		Returns a specific settlement instruction.
	*/
	public SettlementInstruction getSettlementInstruction(Integer settlementInstructionId){
		System.debug('**** ISSP_ICCS_CoreRest.getSettlementInstruction(' + settlementInstructionId + ') ****');

		HttpResponse response = sendRequest('GET', '', '/settlementInstructions/' + settlementInstructionId, null, true);

		try{
			String result = response.getBody().replaceAll('"Currency"', '"Currency_x"').replaceAll('"Number"', '"Number_x"');
			return (SettlementInstruction) JSON.deserialize(result, SettlementInstruction.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}

	/*	POST /settlementInstructions
		
		Creates a future settlement instruction (the cycle id is set in the settlement instruction object).
	*/
	public void createSettlementInstruction(SettlementInstruction settlementInstruction){
		System.debug('**** ISSP_ICCS_CoreRest.createSettlementInstruction(SettlementInstruction settlementInstruction) ****');

		String serializedInstruction = JSON.serialize(settlementInstruction, true).replaceAll( '"currency_x"', '"Currency"').replaceAll('"number_x"', '"Number"');

//		sendRequest('POST', serializedInstruction, '/settlementinstructions', new Map<String,String>{'participant_code' => pageController.participantId}, true);
		sendRequest('POST', serializedInstruction, '/settlementinstructions', null, true);
	}

	/*	PUT /settlementInstructions/{sid}
		
		Updates a standard or a future settlement instruction.
	*/
	public void updateSettlementInstruction(SettlementInstruction settlementInstruction){
		System.debug('**** ISSP_ICCS_CoreRest.updateSettlementInstruction(SettlementInstruction settlementInstruction) ****');

		String serializedSettlementInstruction = JSON.serialize(settlementInstruction, true).replaceAll( '"currency_x"', '"Currency"').replaceAll('"number_x"', '"Number"');

		sendRequest('PUT', serializedSettlementInstruction, '/settlementinstructions/' + settlementInstruction.id, null, true);
	}

	/*	DELETE /settlementInstructions/{sid}
		
		Deletes a future settlement instruction.
	*/
	public void deleteSettlementInstruction(SettlementInstruction settlementInstruction, Integer settlementInstructionId){
		System.debug('**** ISSP_ICCS_CoreRest.deleteSettlementInstruction(' + settlementInstructionId + ') ****');

		String serializedInstruction = JSON.serialize(settlementInstruction, true);
		
		sendRequest('DELETE', serializedInstruction, '/settlementinstructions/' + settlementInstructionId, null, true);
	}	


	/************
		CYCLE
	************/

	/*	GET /cycles/{cid}/cashflows
			
		Returns the list of cashflows for a specific cycle.
	*/
	public List<Cashflow> getCycleCashflows(String cycleId){
		System.debug('**** ISSP_ICCS_CoreRest.getCycleCashflows(' + cycleId + ') ****');

		HttpResponse response = sendRequest('GET', '', '/cycles/' + cycleId.replaceAll('#', '_').replaceAll('-', '_') + '/cashflows', null, true);

		try{
			String result = response.getBody();
			return (List<Cashflow>) JSON.deserialize(result, List<Cashflow>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}

	/*	GET /cycles/{cid}/participations
		
		Returns the list of participations for a specific cycle. It contains the list for all participants, we have to filter.
	*/
	public List<Participation> getCycleParticipations(String cycleId){
		System.debug('**** ISSP_ICCS_CoreRest.getCycleParticipations(' + cycleId + ') ****');

		HttpResponse response = sendRequest('GET', '', '/cycles/' + cycleId.replaceAll('#', '_').replaceAll('-', '_') + '/participations', null, true);
		
		try{
			String result = response.getBody().replaceAll('"BankAccountCode"', '"AccountCode"');
			
			List<Participation> unfilteredList = (List<Participation>) JSON.deserialize(result, List<Participation>.class);
			
			List<Participation> filteredList = new List<Participation>();
			
			for(Participation participation : unfilteredList){
				if(participation.participant.code == pageController.participantId){
					filteredList.add(participation);
				}
			}
			
			return filteredList;
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}

	/*	GET /cycles/{cid}/participants/{participant_code}/bankAccountsCodes
		
		Returns the list of participant's Bank Account Codes for a specific cycle.
	*/
	public List<BankAccountCode> getCycleBankAccountsCodes(String cycleId){
		System.debug('**** ISSP_ICCS_CoreRest.getCycleBankAccountsCodes(' + cycleId + ') ****');

		HttpResponse response = sendRequest('GET', '', '/cycles/' + cycleId.replaceAll('#','_').replaceAll('-', '_') + '/participants/' + pageController.participantId + '/bankAccountsCodes', null, true);

		try{
			String result = response.getBody().replaceAll('"Currency"', '"Currency_x"').replaceAll('"Number"', '"Number_x"');
			return (List<BankAccountCode>) JSON.deserialize(result, List<BankAccountCode>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}

	/*	GET /cycles/{cid}/settlementInstructions
		
		Returns the list of settlement instructions for a specific cycle.
	*/
	public List<SettlementInstruction> getCycleSettlementInstructions(String cycleId){
		System.debug('**** ISSP_ICCS_CoreRest.getCycleSettlementInstructions(' + cycleId + ') ****');

		HttpResponse response = sendRequest('GET', '', '/cycles/' + cycleId.replaceAll('#', '_').replaceAll('-', '_') + '/settlementInstructions?participant_code=' + pageController.participantId, null, true);

		try{
			String result = response.getBody().replaceAll('"Currency"', '"Currency_x"').replaceAll('"Number"', '"Number_x"');
			return (List<SettlementInstruction>) JSON.deserialize(result, List<SettlementInstruction>.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}


	/*	GET /cycles/{cid}/settlementInstructions/{sid}
		
		Returns a specific settlement instruction for a specific cycle.
	*/
	public SettlementInstruction getCycleSettlementInstruction(String cycleId, Integer settlementInstructionId){
		System.debug('**** ISSP_ICCS_CoreRest.getCycleSettlementInstruction(' + cycleId + ',' + settlementInstructionId + ') ****');

		HttpResponse response = sendRequest('GET', '', '/cycles/' + cycleId.replaceAll('#', '_').replaceAll('-', '_') + '/settlementInstructions/' + settlementInstructionId, null, true);

		try{
			String result = response.getBody().replaceAll('"Currency"', '"Currency_x"').replaceAll('"Number"', '"Number_x"');
			return (SettlementInstruction) JSON.deserialize(result, SettlementInstruction.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}


	/*	POST /cycles/{cid}/settlementinstructions
		
		Creates an Adhoc SI for a specific cycle.
	*/
	public void createCycleSettlementInstruction(SettlementInstruction settlementInstruction){
		System.debug('**** ISSP_ICCS_CoreRest.createCycleSettlementInstruction() ****');

		String serializedInstruction = JSON.serialize(settlementInstruction, true).replaceAll('"currency_x"', '"Currency"').replaceAll('"number_x"', '"Number"');
		
		sendRequest('POST', serializedInstruction, '/cycles/' + settlementInstruction.cycle.cycleId.replaceAll('#', '_').replaceAll('-', '_') + '/settlementinstructions', null, true);
	}
	

	/**************
		REPORTS
	**************/	

	/* 
		GET /reports
	
		Returns a sub-set of participant reports based on the filter criterias passed in parameters.
	*/
	public Reports getReports(Integer pageNumber, Integer pageSize, String cycleId, String fromDate, String toDate, String type){
		System.debug('**** ISSP_ICCS_CoreRest.getReports(' + pageNumber + ',' + pageSize + ',' + cycleId + ',' + fromDate + ',' + toDate + ',' + type + ') ****');

		String finalEndpoint = '/reports?';

		List<String> parameters = new List<String>();

		parameters.add('participant_code=' + pageController.participantId);
		
		if(pageNumber != null){
			parameters.add('page_number=' + pageNumber);
		}
		if(pageSize != null){
			parameters.add('page_size=' + pageSize);
		}
		if(cycleId != null && cycleId != ''){
			parameters.add('cycle_id=' + cycleId.replaceAll('#', '_').replaceAll('-', '_'));
		}
		if(fromDate != null && fromDate != ''){
			parameters.add('from=' + fromDate);
		}
		if(toDate != null && toDate != ''){
			parameters.add('to=' + toDate);
		}
		if(type != null && type != ''){
			parameters.add('type=' + type);
		}

		finalEndpoint += String.join(parameters, '&');

		HttpResponse response = sendRequest('GET', '', finalEndpoint, null, true);

		try{
			String result = response.getBody();
			return (Reports) JSON.deserialize(result, Reports.class);
        }
        catch(Exception e){
        	throw new ICCS_Exception(JSON_EXCEPTION + e.getMessage());
        }
	}


	/*
		GET /reports/{id}
		
		returns the URL of a report based on its Id and its mimetype set in the HTTP Request header
	*/
	public String getReport(String id, String mimetype){
		System.debug('**** ISSP_ICCS_CoreRest.getReport(' + id + ',' +  mimetype + ') ****');

        if(!Test.isRunningTest()){
			HttpResponse response = sendRequest('GET', '', '/reports/' + id, new Map<String,String>{'Accept' => mimetype}, true);
	
			System.debug('****** GET  : /reports/' + id + ' Location header : ' + response.getHeader('Location'));
	
			return response.getHeader('Location');
		}
		else{
			return 'https://iccd-reports-nonprod-b81f751c2674d101.s3-eu-west-1.amazonaws.com/DEV-QA/Ultimate_Poster_1920x1080_7.jpg?X-Amz-Expires=86400&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIYHNJEMVQTXGNQ7A/20171207/eu-west-1/s3/aws4_request&X-Amz-Date=20171207T142652Z&X-Amz-SignedHeaders=host&X-Amz-Signature=58a8fcb4c883aa38f563bb53ba78ac4db86eab5a1a577552069c767b6138b655';
		}
	}

	
	/********************
		INNER CLASSES
	********************/

	public class ICCS_Exception extends Exception{}

	public class SettlementInstruction {
		public Integer id {get;set;}
		public Participation participation {get;set;}
		public Cycle cycle {get;set;}
		public InstructionType type {get;set;}
    	public List<InstructionLine> instructionLines {get;set;}
    	public String modifiedOn {get;set;}

		// Specific to cycle Settlement instructions
		public Double settlementAmount {get;set;}
		public Boolean isApplied {get;set;}
		public String approvalStatus {get;set;}
		
		public SettlementInstruction(){
			participation = new Participation();
			cycle = new Cycle();
			type = new InstructionType();
			instructionLines = new List<InstructionLine>();
		}
	}
	
	public class Participation {
		public Integer id {get;set;}
		public Participant participant {get;set;}
		public String noa {get;set;}
		public Cashflow cashflow {get;set;}
		public String startDate {get;set;}
		public String endDate {get;set;}
		public ParticipationStatus status {get;set;}
		public String modifiedOn {get;set;}
		
		public Participation(){
			participant = new Participant();
			cashflow = new Cashflow();
			status = new ParticipationStatus();
		}
	}

    public class Participant{
    	public String code {get;set;}
    }

	public class Cashflow{
		public Integer id {get;set;}
		public String name {get;set;}
		public String code {get;set;}
		public String processingCurrency {get;set;}
		public CashflowType type {get;set;}
		public Country country {get;set;}
		public BankAccountCode accountCode {get;set;}
	}

	public class CashflowType {
		public Integer id {get;set;}
		public String code {get;set;}
	}

	public class Country {
		public String name {get;set;}
		public String iso3Code {get;set;}
	}

    public class BankAccountCode implements Comparable{
    	public Integer id {get;set;}
    	public String code {get;set;}
    	public BankAccount bankAccount {get;set;}

		/* CHECK IF WE CAN GET RID OF THIS */
		public String id_string {
			get{
				if(id_string == null){
					id_string = String.valueOf(id);
				}
				return id_string;
			}
			set{
//				try{
					id = Integer.valueOf(value);
					id_string = value;
					System.debug('bankAccount : ' + this);
/*				}
				catch(Exception e){
					System.debug('Not an Integer : ' + value);
					throw new ICCS_Exception('Please select a Bank Account Code');
				}*/
			}
		}
    	
    	public Integer compareTo(Object objectToCompare){
			BankAccountCode compareToBankAccountCode = (BankAccountCode) objectToCompare;

			if(code < compareToBankAccountCode.code){
				return -1;
			}
			else if(code > compareToBankAccountCode.code){
				return 1;
			}
			else{
				return 0;
			}    	
    	}
    }

	public class BankAccount{
		public Integer id {get;set;}
		public String currency_x {get;set;}	
		public Bank bank {get;set;}
		public String number_x {get;set;}
	}

	public class Bank{
		public String name {get;set;}
		public String bic {get;set;}
	}
	
	public class ParticipationStatus{
		public Integer id {get;set;}
		public String code {get;set;}
	}

    public class InstructionType{
    	public Integer id {get;set;}
    	public String code {get;set;}
    	public String description {get;set;}
    }
    
    public class InstructionLine implements Comparable{
    	public Integer id {get;set;}
    	public BankAccountCode accountCode {get;set;}
    	public InstructionLineType type {get;set;}
    	public Double value {get;set;}
    	public Integer order {get;set;}
    	public String modifiedOn {get;set;}

		public InstructionLine(){
			accountCode = new BankAccountCode();
			type = new InstructionLineType();
		}
		
		public Integer compareTo(Object compareTo) {
			InstructionLine compareToInstructionLine = (InstructionLine) compareTo;

			if(order == null && compareToInstructionLine.order == null){
				return 0;
			}
			else if(compareToInstructionLine.order == null){
				return -1;
			}
			else if(order == null){
				return 1;
			}
			else{
				return order - compareToInstructionLine.order;
			}
		}
    }

    public class InstructionLineType{
    	public Integer id {get;set;}
    	public String code {get;set;}
    	public String description {get;set;}

		/* CHECK IF WE CAN GET RID OF THIS */
		public String id_string {
			get{
				if(id_string == null){
					id_string = String.valueOf(id);
				}
				return id_string;
			}
			set{
//				try{
					id = Integer.valueOf(value);
					id_string = value;
					System.debug('instructionLineType : ' + this);
/*				}
				catch(Exception e){
					throw new ICCS_Exception('Please select a Instruction Line Type');
					System.debug('Not an Integer : ' + value);
				}*/
			}
		}
    }

	public class Reports {
		public PagingInfo pagingInfo {get;set;}
		public List<Report> reports {get;set;}
	}
	
	public class PagingInfo{
		public Integer records {get;set;}
	}
	
	public class Report{
		public String id {get;set;}
		public String name {get;set;}
		public List<AvailableFormat> availableFormats {get;set;}
		public String participantCode {get;set;}
		public String cycleId {get;set;}
		public ReportType type {get;set;}
		public String uploadDate {get;set;}
	}

	public class AvailableFormat{
		public String format {get;set;}
		public String mimetype {get;set;}
	}

	public class ReportType{
		public String code {get;set;}
		public String description {get;set;}
	}
    
	public class Cycles{
		public PagingInfo pagingInfo {get;set;}
		public List<Cycle> cycles {get;set;}
	}

	public class Cycle{
		public String cycleId {get;set;}
		public CycleType type {get;set;}
		public CycleStatus status {get;set;}
		public String startDate {get;set;}
		public String endDate {get;set;}
		public String comment {get;set;}
	}

	public class CycleType{
		public Integer id {get;set;}
		public String code {get;set;}
	}

	public class CycleStatus{
		public Integer id {get;set;}
		public String code {get;set;}
	}
		
	public Enum CYCLE_STATUS{
		Created,
		Started,
		AdHocWindow,
		PartiallyLocked,
		FxExecution,
		UnderAdjustments,
		Locked,
		Closed,
		ClosedandMatched
	}
	
	public Enum SORT_FIELD {
		NONE,
		Name,
		CycleCode,
		Type,
		UploadDate
	}

	public Enum SORT_DIRECTION {
		NONE,
		ASCENDING,
		DESCENDING
	}
}