@RestResource(urlMapping='/BSPLink/*')
global class AMS_BSPLinkIntegration_InboundWS {

    @HttpPost	
	global static String doPost(list<BSPLinkRequest> lsAuthorization) {
		system.debug('DTULLO ' + lsAuthorization);
		try {
			map<string, string> mapNewStatus = new map<string, string>();
			
			boolean bPartialSuccess = false;
			
			if( lsAuthorization==null)	throw new customException('No BSPLink Authorization to process');
			
			if(lsAuthorization.isEmpty())
				throw new customException('No BSPLink Authorization to process');
			else{
				for(BSPLinkRequest req: lsAuthorization)
					mapNewStatus.put(req.sAuthorizationID.left(15), req.sStatus);
			}
			
			list<Agency_Authorization__c> lsAuth = [select id, Last_Request_Result__c, Status__c from Agency_Authorization__c where id in:mapNewStatus.keySet()];
			
			if(lsAuth.isEmpty())
				 throw new customException('All given BSPLink authorization not found');
			else{
				for(Agency_Authorization__c aut:lsAuth){
					aut.Status__c = mapNewStatus.get(string.ValueOf(aut.ID).left(15));
					aut.Last_Request_Result__c = 'BSPLink processed succesfully';
					
					mapNewStatus.remove(string.ValueOf(aut.ID).left(15));
				}
				
				try{
					update lsAuth;
					
					if(mapNewStatus.isEmpty())
						return JSON.serialize( new ResponsePOST('SUCCESS', '') );
					else{
						string sNotFound = 'Authorization not found: ';
						for(string s:mapNewStatus.keyset())
							sNotFound = sNotFound + s + '; ';
						
						return JSON.serialize( new ResponsePOST('PARTIAL SUCCESS', sNotFound) );
					}

				}catch(exception e){
					throw new customException('Error when updating given authorization: ' + e.getMessage());
				}
			}
		} catch ( Exception e ) {
			return JSON.serialize( new ResponsePOST('ERROR', e.getMessage()) );
		}
	}
	
	public class customException extends Exception {}
	
	global class BSPLinkRequest {
		public String sAuthorizationID {get; set;}
		public String sStatus {get; set;}
		
		public BSPLinkRequest( String sAuthorizationID, String sStatus) {
			this.sAuthorizationID = sAuthorizationID;
			this.sStatus = sStatus;
		}
	}
	
	public class ResponsePOST {
		public String Status {get; set;}
		public String ErrorMsg {get; set;}
		
		public ResponsePOST( String status, String errorMsg) {
			this.Status = status;
			this.ErrorMsg = errorMsg;
		}
	}
}