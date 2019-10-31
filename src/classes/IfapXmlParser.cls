public with sharing class IfapXmlParser {


/* 

   IfapXmlParser demo = new IfapXmlParser();

        String str ='<?xml version="1.0" ?>'+
					+'<WorkflowIntegrationDictionary xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
						+'<SalesforceCaseNumber>00000002</SalesforceCaseNumber>'
						+'<ReassessmentRejectionReason>Unsatisfactory - New Financial Security</ReassessmentRejectionReason>'
					+'</WorkflowIntegrationDictionary>';





        XmlStreamReader reader = new XmlStreamReader(str);
        IfapXmlParser.ReassessmentRequest ReassessmentRequest = demo.parseReassessmentRequest(reader);

        System.debug(ReassessmentRequest);

 */


    public ReassessmentRequest parseReassessmentRequest(XmlStreamReader reader){
    
    	ReassessmentRequest reassessmentRequest = new ReassessmentRequest();
    	
    	       while(reader.hasNext()) {
        
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                
	                     string localName = reader.getLocalName();
	                     if ('SalesforceCaseNumber' == localName ) {
	                                        reader.next();
	                                        if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
	                                         reassessmentRequest.SalesforceCaseNumber  =reader.getText();
	                                         }
	                          
	                	}else if ('ReassessmentRejectionReason' == localName ) {
                                        reader.next();
                                        if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                         reassessmentRequest.ReassessmentRejectionReason=reader.getText();
                                         }
                          
                       	}                         
                       
                }  
          
          reader.next();
        
        }
    	
    	return reassessmentRequest;
    }



/* 

   IfapXmlParser demo = new IfapXmlParser();

        String str ='<?xml version="1.0" ?>'+
					+'<WorkflowIntegrationDictionary xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
						+'<SalesforceCaseNumber>00000002</SalesforceCaseNumber>'
						+'<File>'
							+'<FileName>MX-P-8653021.pdf</FileName>'
							+'<FileType>FinancialAssessmentResult</FileType>'
						+'</File>'
						+'<GFAStatus>Unsatisfactory - New Financial Security</GFAStatus>'
						+'<Error>'
							+'<ErrorCode>0</ErrorCode>'
						+'</Error>'
					+'</WorkflowIntegrationDictionary>';





        XmlStreamReader reader = new XmlStreamReader(str);
        IfapXmlParser.IfapResult parseIfapResult = demo.parseIfapResult(reader);

        System.debug(parseIfapResult);

 */

    public IfapResult parseIfapResult(XmlStreamReader reader){
    
    	IfapResult ifapResult = new IfapResult();
    	
    	       
        while(reader.hasNext()) {
        
        
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                
	                     string localName = reader.getLocalName();
	                     if ('SalesforceCaseNumber' == localName ) {
                                         reader.next();
                                         if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                         ifapResult.SalesforceCaseNumber  =reader.getText();
                                         }
	                          
	                	}else if ('GFAStatus' == localName ) {
                                         reader.next();
                                         if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                         ifapResult.GFAStatus=reader.getText();
                                         }
                          
                       	}else if ('File' == localName ) {
                                      	reader.next();
                                      	ifapResult.Files= parseFiles(reader);
                                      	
						}else if ('FinancialSecurity' == localName ) {
                                        reader.next();
                                        ifapResult.FinancialSecurity=parseFinancialSecurity(reader);
                          
						}else if ('Error' == localName ) {
                                        reader.next();
                                  		ifapResult.Error=parseError(reader);
                          
	                	}else if ('FinancialCriteriaTotalScore' == localName ) {
                                        reader.next();
                                         if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                         ifapResult.FinancialCriteriaTotalScore=reader.getText();
                        }
                          
	                	}                           
                       
                }  
          reader.next();
        }
        
        
        return ifapResult;
    
    }



 	public Error parseError (XmlStreamReader reader){
 		Error Error = new Error();
            
            while(reader.hasNext()) {
            
              if (reader.getEventType() == XmlTag.END_ELEMENT &&  'Error' == reader.getLocalName()) {
                        return Error ;
    
                    }
               else if (reader.getEventType() == XmlTag.START_ELEMENT) {
                         
                         string localName = reader.getLocalName();
                         if ('ErrorCode' == localName ) {
                                            reader.next();
                                            if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                             Error.ErrorCode=reader.getText();
                                             }
                              
                                   } 
               			else  if ('ErrorMessage' == localName ) {
                                            reader.next();
                                            if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                             Error.ErrorMessage=reader.getText();
                                             }
                              
                                   } 
                    }
            
          
           reader.next();
            }
            
         return null;
 	
 	}

		
		
		
 	public FinancialSecurity parseFinancialSecurity (XmlStreamReader reader){
 		
 		FinancialSecurity financialSecurity = new FinancialSecurity();
 		
        while(reader.hasNext()) {
            
              if (reader.getEventType() == XmlTag.END_ELEMENT &&  'financialSecurity' == reader.getLocalName()) {
                        return financialSecurity ;
    
                    }
               else if (reader.getEventType() == XmlTag.START_ELEMENT) {
               	
                             string localName = reader.getLocalName();
                         if ('Amount' == localName ) {
                                            reader.next();
                                            if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                             financialSecurity.Amount=reader.getText();
                                             }
                              
                                   } 
               			else  if ('Currency_x' == localName ) {
                                            reader.next();
                                            if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                             financialSecurity.Currency_x=reader.getText();
                                             }
                              
                                   } 
                    }
            
          
           reader.next();
            }
        
        
       return  null;
	}



	  public list<File> parseFiles (XmlStreamReader reader){
	  	
	  	
	  	  list<File> Files = new list<File>();
	  	  File file = new File();
	  	 while(reader.hasNext()) {
	  	 	 
	                if (reader.getEventType() == XmlTag.END_ELEMENT &&  'File' == reader.getLocalName()) {
	                	return Files;
	                
	                } else if (reader.getEventType() == XmlTag.END_ELEMENT &&  'FileType' == reader.getLocalName()) {
	                     Files.add(file);
	                  
	                     file = new file();
	                     
	                }else  if (reader.getEventType() == XmlTag.START_ELEMENT) {
	  						
	  					string localName = reader.getLocalName();
	  					
                     	if ('FileName' == localName ) {
                                        reader.next();
                                        if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                         file.FileName = reader.getText();
                                         }else{}
                          
						}else if ('FileType' == localName ) {
                                        reader.next();
                                        if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
                                         file.FileType=reader.getText();
                                        }
                          
	                	}  	  						
	                }
	                
	          reader.next();
	        }
	
	     return null ;
	  
	  
	  }
	  
	  
	  
	  
	  	public class File{
		    private String FileName;
		
		    private String FileType;
		
		    public String getFileName (){
		        return FileName;
		    }
		
		    public void setFileName (String FileName){
		        this.FileName = FileName;
		    }
		
		    public String getFileType (){
		        return FileType;
		    }
		
		    public void setFileType (String FileType){
		        this.FileType = FileType;
		    }
		
		
		}
	  
	  
		public class IfapResult{
			
		    private FinancialSecurity FinancialSecurity;

			private String FinancialCriteriaTotalScore;

		    private String GFAStatus;
		
		    private File[] Files;
		
		    private String SalesforceCaseNumber;
		
		    private Error Error;
		
		    public FinancialSecurity getFinancialSecurity (){
		        return FinancialSecurity;
		    }
		
		    public void setFinancialSecurity (FinancialSecurity FinancialSecurity){
		        this.FinancialSecurity = FinancialSecurity;
		    }
		
		    public String getGFAStatus (){
		        return GFAStatus;
		    }
		
		    public String getFinancialCriteriaTotalScore(){
		        return FinancialCriteriaTotalScore;
		    }

		    public void setGFAStatus (String GFAStatus){
		        this.GFAStatus = GFAStatus;
		    }
		
		    public void setFinancialCriteriaTotalScore (String FinancialCriteriaTotalScore){
		        this.FinancialCriteriaTotalScore = FinancialCriteriaTotalScore;
		    }

		    public File[] getFiles (){
		        return Files;
		    }
		
		    public void setFiles (File[] Files){
		        this.Files = Files;
		    }
		
		    public String getSalesforceCaseNumber (){
		        return SalesforceCaseNumber;
		    }
		
		    public void setSalesforceCaseNumber (String SalesforceCaseNumber){
		        this.SalesforceCaseNumber = SalesforceCaseNumber;
		    }
		
		    public Error getError (){
		        return Error;
		    }
		
		    public void setError (Error Error){
		        this.Error = Error;
		    }
		
		
		}	
			
	
	public class Error{
			
		    private String ErrorMessage;
		
		    private String ErrorCode;
		
		    public String getErrorMessage (){
		        return ErrorMessage;
		    }
		
		    public void setErrorMessage (String ErrorMessage){
		        this.ErrorMessage = ErrorMessage;
		    }
		
		    public String getErrorCode (){
		        return ErrorCode;
		    }
		
		    public void setErrorCode (String ErrorCode){
		        this.ErrorCode = ErrorCode;
		    }
		
		
		}	
	
	public class FinancialSecurity{
		    
		    private String Amount;
		
		    private String Currency_x;
		
		    public String getAmount (){
		        return Amount;
		    }
		
		    public void setAmount (String Amount){
		        this.Amount = Amount;
		    }
		
		    public String getCurrency_x (){
		        return Currency_x;
		    }
		
		    public void setCurrency_x (String Currency_x){
		        this.Currency_x = Currency_x;
		    }
	
	
		}


	public class ReassessmentRequest{
		    
		    private String ReassessmentRejectionReason;
		
		    private String SalesforceCaseNumber;
		
		    public String getReassessmentRejectionReason (){
		        return ReassessmentRejectionReason;
		    }
		
		    public void setReassessmentRejectionReason (String ReassessmentRejectionReason){
		        this.ReassessmentRejectionReason = ReassessmentRejectionReason;
		    }
		
		    public String getSalesforceCaseNumber (){
		        return SalesforceCaseNumber;
		    }
		
		    public void setSalesforceCaseNumber (String SalesforceCaseNumber){
		        this.SalesforceCaseNumber = SalesforceCaseNumber;
		    }
	

	}
	

}