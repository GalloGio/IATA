global  class AcliFileDownload {


	public static String TEST_CSV;

  @future (callout=true)
  global static void downLoadAcliFile() {


			string folderID = UtilityCS__c.getInstance('AcliFolderID').value__c;
			String endpoint = UtilityCS__c.getInstance('AcliURL').value__c;
			//Body del file CSV
			String CSV = '';
			//Nella callout il limite è di 3 MB
			Integer kbLimit = 1024*2900;
			//Variabile che permette la comunicazione Http
			Http h = new Http();
			//Strutturiamo l'header della comunicazione, che contiene la Username e la Password per poter accedere al sistema esterno

			//Facciamo la GET per prelevare il file presente sul server
			HttpRequest request = new HttpRequest();
			request.setMethod('GET');
			request.setEndpoint(endpoint);
			request.setTimeout(5000);
			//Inviamo la request
			HttpResponse resp;
			 if(!Test.isRunningTest()){
			 resp = h.send(request);


			//Se lo Status Code si trova tra i 200 allora la comunicazione è andata a buon fine, altrimenti si è generato qualche errore
			if(resp.getStatusCode()<200 || resp.getStatusCode()>299){
				throw new transformationException( 'COMMUNICATION ERROR: The communication with the server has returned an error! Please contact your System Administrator!');
			}
			//Preleviamo il contenuto del file
				CSV = resp.getBody();
			 }else{
			   CSV = TEST_CSV;

			}

			Document d = new Document();
			list<Document> toFind = [SELECT ID,BODY,TYPE,name,CONTENTTYPE,developername,FolderId
										FROM Document
										WHERE developername = 'AcliUniqueFile'
										];
			if(toFind.size()<> 0){
				d = toFind[0];

			}
				csv = csv.replace('<span id="lblRawOutput"><font face="Verdana">','');
				csv = csv.replace('</font></span>','');
				d.FolderId = folderID;
				d.developername =test.isRunningtest()? 'asdasdasdasdasdgasedfg':'AcliUniqueFile';
				d.Name = 'AcliUniqueFile'+dateTime.now();
				d.Body = Blob.valueOf(CSV);
				d.ContentType = 'text/plain';

				d.Type = 'txt';
				upsert d;


			integer max =0;
			   string separator =  CSV.contains('<br>') ?  '<br>' : '\\n';
					for(String line : CSV.split(separator)) {
						max++;
					}
	   boolean inctivateTheAirlines = false;
			/* now we have to see if we have them in scope*/
		AcliWrapper wrapperTmp =AcliParser.AcliParsingNotFound(CSV,0,max,false);
		if(!wrapperTmp.AcliAccount.IsEmpty()
						  ){
			inctivateTheAirlines =true;
		}


		if(inctivateTheAirlines){

			  string message = 'The Acli File Update Task needs to be completed there are ' + wrapperTmp.NumberOfLines + ' not matching Airlines on the file    ';
			  string receiver = String.valueOf(utilityCs__c.getInstance('AcliOwnerEmail').value__c) ;
			  TransformationHelper.sendSFDevsAlertMessage('Acli File Update', message, receiver);

		}



			system.debug('dddddddddddddddddddddddddddddddddddddddddddddddddd '+ d);


  }

}
