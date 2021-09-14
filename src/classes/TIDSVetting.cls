public class TIDSVetting {
	public Case vcase;
	public boolean isVirtualBranchRequest {get;set;}
	public boolean isRelinquishRequest {get;set;}
	public boolean isReinstateRequest {get;set;}
	public boolean isStartVetting {get;set;}
	public boolean isOpen {get;set;}
	public string messageError {get;set;}
	private List<Case> mcase {get;set;}
	// The extension constructor initializes the private member
	// variable acct by using the getRecord method from the standard
	// controller.
	public TIDSVetting(ApexPages.StandardController stdController) {
		this.messageError='';
		this.isOpen=true;
		this.vcase = (Case)stdController.getRecord();
		getRequestCase();
	}
	//Reads the case record and make sure it does exist and is not closed
	public void getRequestCase(){
		isVirtualBranchRequest=false;
		isRelinquishRequest=false;
		isStartVetting=false;
		mcase = new List<Case>();
		TIDSUtil.getTidsCases(vcase.Id, false);
		if (TIDSUtil.cases.size()==0) {
			this.isOpen=false;
			return;
		}
		if (TIDSUtil.cases[0].Status==TIDS_Constant.IS_CLOSED) {
			this.isOpen=false;
			return;
		}
		mcase = TIDSUtil.cases;
		isVirtualBranchRequest=(mcase[0].Subject==TIDS_Constant.CASE_SUBJECT_VIRTUAL_ACCREQ);
		isRelinquishRequest=(mcase[0].Reason1__c==TIDS_Constant.CASE_REASON_RELINQUISH);
		isReinstateRequest=(mcase[0].Reason1__c==TIDS_Constant.CASE_REASON_REINSTATEMENT);
		if (isVirtualBranchRequest==false && isRelinquishRequest==false && isReinstateRequest==false){
			isStartVetting=true;
		}
	}
	//Approves the Tids request by updating the case
	public void approveRequest() {
		this.isOpen=false;
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG34);
		getRequestCase();
		if (mcase.size()==0){messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG31);return;}
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG32);
		Savepoint sp = Database.setSavepoint();
		try{
			if (isVirtualBranchRequest){
				List<Accreditation__c> a= new List<Accreditation__c>();
				a= [Select Id, Virtual_Branch_Enabled__c From Accreditation__c
				Where Related_Account__c=:mcase[0].AccountId Limit 1];
				if (a.size()>0){
					a[0].Virtual_Branch_Enabled__c=true;
					update a;
				}else{
					messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG33);
					return;
				}
			}
			mcase[0].Decision__c=TIDS_Constant.DECISION_APPROVED;
			mcase[0].Decision_Date__c=System.now();
			mcase[0].Status=TIDS_Constant.IS_CLOSED;
			mcase[0].OwnerId=UserInfo.getUserId();
			update mcase;
			if (!isVirtualBranchRequest){
				if (isRelinquishRequest){
					if (mcase[0].Subject==TIDS_Constant.CASE_SUBJECT_RELINQUISH){
						TidsBatchRelinquishment nb = new TidsBatchRelinquishment();
						nb.caseId=vcase.Id;
						Database.executeBatch(nb,100);
						TIDS_Controller.createChangeCode(mcase[0].AccountId, TIDS_Constant.RELINQ_HO);
					}else{
						TidsBatchHelper.finishBuilderRelinquishment(vcase.Id);
						TIDS_Controller.createChangeCode(mcase[0].AccountId, TIDS_Constant.RELINQ_BR);
					}
				}else if (isReinstateRequest){
					TidsBatchHelper.finishBuilderReinstatement(vcase.Id);
					TIDS_Controller.createChangeCode(mcase[0].AccountId, TIDS_Constant.REINSTATE_HO);
				}
			}
		} catch (exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSVetting -  approveRequest] e.getMessage() - ' + e.getMessage());
		}		
	}
	//Rejects the tids request and update the case
	public void rejectRequest() {
		this.isOpen=false;
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG34);
		getRequestCase();
		if (mcase.size()==0){
			messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG31);
			return;
		}
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG35);
		mcase[0].Decision__c=TIDS_Constant.DECISION_REJECTED;
		mcase[0].Decision_Date__c=System.now();
		mcase[0].Status=TIDS_Constant.IS_CLOSED;
		mcase[0].OwnerId=UserInfo.getUserId();
		try{
			update mcase;
		} catch (exception e){
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSVetting -  rejectRequest] e.getMessage() - ' + e.getMessage());
		}
	}
}