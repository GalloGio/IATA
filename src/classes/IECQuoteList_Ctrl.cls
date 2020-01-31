/****************************************************************************************************
	Created by CGI, Thai 2015-11-12
		Controller for Visualforce "IECQuoteList"
****************************************************************************************************/

public class IECQuoteList_Ctrl extends IEC_PageController
{

public Map<String, String> labels { get; set; }  //*** labels for VF page and messages to use in code
public Map<String, String> labelsQuoteDetail{get;set;}

public String quoteNumber { get; set; }
public Boolean showSendEmail{get;set;}
public String emailTo{get;set;}
public String emailCC{get;set;}
public String emailBCC{get;set;}
public String emailSubject{get;set;}
public String emailBody{get;set;}

class clsQuote
{
	public Order info { get; set; }
	public Boolean isExpired { get; set; }
	public clsQuote(Order info)
	{
		this.info = info;
		this.isExpired = (info.EndDate < system.today());
	}
}
public List<clsQuote> lstQuotes { get; set; }


/****************************************************************************************************
	Created by CGI, Thai 2015-11-12
		Constructor
****************************************************************************************************/
public IECQuoteList_Ctrl()
{


} //*** end of "IECQuoteList_Ctrl"

public PageReference pageLoad(){

	if(loggedCustomer == null)
	{
		//-- redfirect to login
		PageReference pgRef = new PageReference('/IEC_Login?returl=/IEC_ViewQuotes');
			pgRef.setRedirect(true);
		return pgRef;
	}

	//*** get labels & messages
	labels = Utility.buildMapFromString(Label.LabelsVF_IECQuoteList, '\n', ':');
	labelsQuoteDetail = Utility.buildMapFromString(Label.LabelsVF_IECQuoteDetail, '\n', ':');

	//*** get quotes
	lstQuotes = new List<clsQuote>();
	Id idContact = [select ContactId from User where Id = :UserInfo.getUserId() limit 1][0].ContactId;
	for (Order q : new Order_Sel().getQuotes(idContact))
	//for (Order q : Order_Sel.getQuotesList('003g000000ZoKog'))
		lstQuotes.add(new clsQuote(q));
	return null;
}


public void sendEmail()
{

	showSendEmail = true;
	emailTo = ApexPages.currentPage().getParameters().get('quoteShipToEmail');
	quoteNumber = ApexPages.currentPage().getParameters().get('quoteNumber');
	emailSubject = labelsQuoteDetail.get('emailSubjectPrefix') + quoteNumber;
	emailBody = labelsQuoteDetail.get('emailBody');
}

public void resetEmail()
{
	showSendEmail   = false;
	emailTo         = null;
	emailCC         = null;
	emailBCC        = null;
	emailSubject    = null;
	emailBody       = null;
}
public void cancelSendQuote()
{
	resetEmail();
}

public Boolean emailSendSuccessfully {get;set;}
public PageReference sendQuote()
{
	emailTo = ApexPages.currentPage().getParameters().get('emailTo');
	emailSubject = ApexPages.currentPage().getParameters().get('emailSubject');
	emailCC = ApexPages.currentPage().getParameters().get('emailCC');
	emailBCC = ApexPages.currentPage().getParameters().get('emailBCC');
	emailBody = ApexPages.currentPage().getParameters().get('emailBody');
	quoteNumber = ApexPages.currentPage().getParameters().get('quoteNumber');

	if(String.isBlank(emailTo) || String.isBlank(emailSubject))
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Label.Error_SendEmail_EmailTo_Required));
		return null;
	}
	else if(String.isBlank(emailSubject))
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Label.Error_SendEmail_Subject_Required));
		return null;
	}
	else
	{
		try
		{
			PageReference pdf = new PageReference('/IECQuotePDF?quote=' + quoteNumber);
			Blob body = (Test.isRunningTest()) ? Blob.valueOf('123456') : pdf.getContent();

			Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
				attachment.setFileName('Quote-'+quoteNumber+'.pdf');
				attachment.setBody(body);

			List<String> toAddresses = emailTo.split(';');
			List<String> ccAddresses = (String.isNotBlank(emailCC)) ? emailCC.split(';') : null;
			List<String> bccAddresses = (String.isNotBlank(emailBCC)) ? emailBCC.split(';') : null;

			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setSubject( emailSubject );
				email.setToAddresses( toAddresses );
				if(ccAddresses != null)
				{
					email.setCcAddresses(ccAddresses);
				}
				if(bccAddresses != null)
				{
					email.setBccAddresses(bccAddresses);
				}
				email.setPlainTextBody( emailBody );
				email.setFileAttachments(new List<Messaging.EmailFileAttachment>{
					attachment
				});

			List<Messaging.SendEmailResult> r = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
				email
			});

			resetEmail();
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,ex.getMessage()));
			emailSendSuccessfully = false;
			return null;
		}
		emailSendSuccessfully = true;
		return null;
	}

}



} //*** end of class
