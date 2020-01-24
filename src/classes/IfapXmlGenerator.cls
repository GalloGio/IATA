public  class IfapXmlGenerator{

	/*
	IfapXmlGenerator.FinancialDocument fd = new IfapXmlGenerator.FinancialDocument(
																   new IfapXmls.Casexml('12345678'),
																   new IfapXmls.FileXml('nameOfTheFile'),
																   new IfapXmls.ReviewType(IfapXmls.ReviewTypes.Annual),
																   new IfapXmls.SubmittedDate(Date.Today())
																   );
			fd.XML())
													 */

	//public enum ReviewTypes {Annual, NewApplications, MajorChanges,Adhoc, ReinstatementAfterDefault,Cancelled}

	public class ReviewType {

		private String ReviewType {get; set;}
		private set<string> reviewsTypes = new set<string>{'Annual','New applications','Major Changes','Reinstatement after Default','Cancelled','Adhoc'};
		private ReviewType( ) {

		}

		/*public  ReviewType(ReviewTypes reviewType ) {

			if(reviewType == ReviewTypes.Annual)this.reviewType ='Annual';
			if(reviewType == ReviewTypes.NewApplications )this.reviewType ='New applications';
			if(reviewType == ReviewTypes.MajorChanges)this.reviewType ='Major Changes';
			if(reviewType == ReviewTypes.ReinstatementAfterDefault)this.reviewType ='Reinstatement after Default';
			if(reviewType == ReviewTypes.Cancelled)this.reviewType ='Cancelled';
			if(reviewType == ReviewTypes.Adhoc )this.reviewType ='Adhoc';

		} */

		public  ReviewType(string reviewType ) {
			if(reviewType == null || reviewsTypes.contains(reviewType) == null)throw new transformationException('Review type unknown');
			this.reviewType =reviewType;

		}



		public string getReviewType(){
			return this.reviewType;
		}

	}


	public class Casexml {


		private String SalesforceCaseNumber {get; set;}

		private Casexml( ) {

		}


		public  Casexml(string salesforceCaseNumber ) {

			string errorMessage;

			if(SalesforceCaseNumber == null || !SalesforceCaseNumber.isNumeric() || SalesforceCaseNumber.length() <> 8)
				errorMessage= 'SalesforceCaseNumber not valid';


			 if(errorMessage <> null) throw new transformationException(errorMessage);

			 this.SalesforceCaseNumber = salesforceCaseNumber;

		}


		public string getCasexml(){

			return this.SalesforceCaseNumber;
		}

	}


	public class FileXml{

		private String Name {get; set;}

		public string getFileXml(){

			return this.Name;
		}

		private  FileXml() {

		}


		public  FileXml(string name ) {

			if(name == null || name.length() >256)throw new transformationException('File Name not valid');
			this.name = name;
		}


	}


	public class SubmittedDate{

		private String subDate {get; set;}

		public string getSubmittedDate(){

			return this.subDate;
		}

		private  SubmittedDate() {

		}


		public  SubmittedDate(Date subDate) {

			if(subDate == null)throw new transformationException('Invalid Date');
			string mnth = string.valueOf(subDate.month()).length() == 2 ?  string.valueOf(subDate.month()) : '0'+string.valueOf(subDate.month());
			string dy = string.valueOf(subdate.day()).length() == 2 ?  string.valueOf(subdate.day()) : '0'+string.valueOf(subdate.day());
			this.subDate = string.valueOf(subDate.year()) +'-'+mnth+'-'+dy ;
		}


	}


	// to do test to see if the xml is well formatted against the xsd
	public class QualityIssue{

		private string XML;
		public Casexml Casexml {get;set;}
		public String IATACODE {get;set;}
		public IFAP_Quality_Issue__c IFAP_Quality_Issue {get;set;}
		public list<IFAP_Reassessment_Accounting_Issue__c> IFAP_Reassessment_Accounting_IssueList {get;set;}
		private map<string,string> qualityPerXmlPlaceHolder {get;set;}
		private list<map<string, string>> listAccountIssueOfAccountPerXmlPlaceHolder{get;set;}

		public QualityIssue(Casexml casexml,String IATACODE,IFAP_Quality_Issue__c IFAP_Quality_Issue,
						   list<IFAP_Reassessment_Accounting_Issue__c> IFAP_Reassessment_Accounting_IssueList){


			this.casexml = casexml;
			this.IATACODE = IATACODE;
			this.IFAP_Quality_Issue = IFAP_Quality_Issue;
			this.IFAP_Reassessment_Accounting_IssueList = IFAP_Reassessment_Accounting_IssueList;
			this.qualityPerXmlPlaceHolder = new map<string,string>{
															'WrongFigureExtracted' => string.valueOf(IFAP_Quality_Issue.Wrong_figure_was_extracted__c),
															'IncorrectSanityCheckFailure' => string.valueOf(IFAP_Quality_Issue.Incorrect_sanity_check_failure__c),
															'ParentCompanyAccountsNotReviewed' => string.valueOf(IFAP_Quality_Issue.Parent_company_accounts_not_reviewed__c),
															'FinancialsNotAuditedCertified' => string.valueOf(IFAP_Quality_Issue.Financials_not_audited_certified__c),
															'WrongTemplate' => string.valueOf(IFAP_Quality_Issue.Assessment_using_wrong_template__c),
															'WrongFinancialYear' => string.valueOf(IFAP_Quality_Issue.Wrong_financial_year__c),
															'IncorrectSalesUsed' => string.valueOf(IFAP_Quality_Issue.Incorrect_sales_used_for_the_assessment__c),
															'PrintoutUnreadable' => string.valueOf(IFAP_Quality_Issue.Wrong_figure_was_extracted__c),
															'WrongFigureExtracted' => string.valueOf(IFAP_Quality_Issue.The_printout_of_the_result_is_unreadable__c),
															'MissingValueInFields' => string.valueOf(IFAP_Quality_Issue.Missing_value_in_fields__c),
															'AssessmentOuputEmptyNotCompletedValueErrors' => string.valueOf(IFAP_Quality_Issue.Output_is_empty_not_completed_has_errors__c),
															'Other' => IFAP_Quality_Issue.Other__c,
															'listAccountIssueOfAccountPerXmlPlaceHolder' => 'listAccountIssueOfAccountPerXmlPlaceHolder',
															'NeedToUpdateTemplateInstructions' => string.valueOf(IFAP_Quality_Issue.Need_to_update_the_template_instructions__c),
															'TemplateWorkingProperly' => string.valueOf(IFAP_Quality_Issue.Template_working_properly__c),
															'FormattingIssueDetails' => IFAP_Quality_Issue.Formatting_Issue_details__c,
															'OtherIssueDetails' => IFAP_Quality_Issue.Other_Issue_details__c
															};


		   this.listAccountIssueOfAccountPerXmlPlaceHolder = initList(IFAP_Reassessment_Accounting_IssueList);

			}

		private  list<map<string, string>> initList(list<IFAP_Reassessment_Accounting_Issue__c> IFAP_Reassessment_Accounting_IssueList){

			if(IFAP_Reassessment_Accounting_IssueList == null || IFAP_Reassessment_Accounting_IssueList.size() == 0)return null;

			list<map<string, string>> listActIsseOfActPerXmlPlcHldr = new list<map<string, string>>();

			for(IFAP_Reassessment_Accounting_Issue__c IRA : IFAP_Reassessment_Accounting_IssueList ){

					map<string, string> ActPerXmlPlcHldrMap = new  map<string, string>{
																						'FieldName' => IRA.Field_Name__c <> null ? string.valueOf(IRA.Field_Name__c) : '',
																						'WrongValue' => IRA.Wrong_value__c <> null ?string.valueOf(IRA.Wrong_value__c): '',
																						'ValueToUse' =>IRA.Value_to_use__c <> null ? string.valueOf(IRA.Value_to_use__c): '',
																						'Comment' => IRA.Comment__c <> null ? string.valueOf(IRA.Comment__c)    : ''
																						};


					listActIsseOfActPerXmlPlcHldr.add(ActPerXmlPlcHldrMap);

			}
			return  listActIsseOfActPerXmlPlcHldr;

		}

	  public String getXML(){

				Xmlstreamwriter xmlW = new Xmlstreamwriter();
				xmlW.writeStartDocument('utf-8','1.0');
				xmlW.writeStartElement('', 'ReassessmentRequest', 'http://www.w3.org/2001/XMLSchema-instance');
				xmlW.writeNamespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance');

				xmlW.writeStartElement(null, 'SalesforceCaseNumber', null);
							xmlW.writeCharacters(Casexml.getCaseXML());
						xmlW.writeEndElement();

					 xmlW.writeStartElement(null, 'IATACode', null);
							xmlW.writeCharacters(IATACode);
						xmlW.writeEndElement();

				for(string key:qualityPerXmlPlaceHolder.keySet()){

						if(key <>'listAccountIssueOfAccountPerXmlPlaceHolder'){

							xmlW.writeStartElement(null, key, null);
							   if(key<> null &&  qualityPerXmlPlaceHolder.get(key) <> null) xmlW.writeCharacters(qualityPerXmlPlaceHolder.get(key));
							xmlW.writeEndElement();

						}else if(key == 'listAccountIssueOfAccountPerXmlPlaceHolder'){

							if(listAccountIssueOfAccountPerXmlPlaceHolder <> null && listAccountIssueOfAccountPerXmlPlaceHolder.size()>0){

							for(map<string, string> acListIssueElement:listAccountIssueOfAccountPerXmlPlaceHolder){
								 xmlW.writeStartElement(null, 'AccountingIssue', null);
								for(string keyMap: acListIssueElement.keySet()){
										xmlW.writeStartElement(null, keyMap, null);
										   if(keyMap<> null &&  acListIssueElement.get(keyMap) <> null) xmlW.writeCharacters(acListIssueElement.get(keyMap));
										xmlW.writeEndElement();
								}
								xmlW.writeEndElement();
							}

						 }else {

							set<string> emptyValues = new set<string>{'FieldName','WrongValue','ValueToUse','Comment'};

							 xmlW.writeStartElement(null, 'AccountingIssue', null);
							 for(string keyMap: emptyValues ){
										xmlW.writeStartElement(null, keyMap, null);

										xmlW.writeEndElement();
								}
							 xmlW.writeEndElement();


						}
						}

				}

							xmlW.writeEndElement();
				String xmlStringxmlRes = xmlW.getXmlString();

				xmlW.close();
		return xmlStringxmlRes;
	  }


	}

	public class FinancialDocument{

		Casexml Casexml {get;set;}
		FileXml FileXml {get;set;}
		ReviewType ReviewType {get;set;}
		SubmittedDate SubmittedDate {get;set;}

		private FinancialDocument(){


		}

		public FinancialDocument(Casexml casexml,FileXml fileXml,ReviewType ReviewType,SubmittedDate submittedDate){

			this.FileXml = fileXml;
			this.Casexml = Casexml;
			this.ReviewType = ReviewType;
			this.SubmittedDate = submittedDate;

		}

		private String XML;
		public String getXML(){

				   Xmlstreamwriter xmlW = new Xmlstreamwriter();

					xmlW.writeStartDocument('utf-8','1.0');


					 xmlW.writeStartElement('', 'WorkflowIntegrationDictionary', 'http://www.w3.org/2001/XMLSchema-instance');


					xmlW.writeNamespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance');

						xmlW.writeStartElement(null, 'SalesforceCaseNumber', null);
							xmlW.writeCharacters(Casexml.getCaseXML());
						xmlW.writeEndElement();

						xmlW.writeStartElement(null, 'Files', null);

							xmlW.writeStartElement(null, 'FileName',null);
								xmlW.writeCharacters(this.FileXml.getFileXml());
							xmlW.writeEndElement();

						xmlW.writeEndElement();

						/* for Cancellations its exatcly the same*/
						xmlW.writeStartElement(null, 'ReviewType', null);
							xmlW.writeCharacters(this.ReviewType.getReviewType());
						xmlW.writeEndElement();


						xmlW.writeStartElement(null, 'SubmittedDate', null);
							xmlW.writeCharacters(SubmittedDate.getSubmittedDate());
						xmlW.writeEndElement();

					 xmlW.writeEndElement();

				xmlW.writeEndDocument();


				String xmlStringxmlRes = xmlW.getXmlString();

				xmlW.close();
				return xmlStringxmlRes;

		}


	}


}
