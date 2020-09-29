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
	
	
	public void getRequestCase(){
		isVirtualBranchRequest=false;
		isRelinquishRequest=false;
		isStartVetting=false;
		mcase = new List<Case>();
		mcase=[Select Id, contactId, AccountId, Reason1__c, Subject, Decision__c, Decision_Date__c, OwnerId From Case Where id=:vcase.Id and Status!='Closed' Limit 1];
		if (mcase.size()==0) {this.isOpen=false;return;}
		isVirtualBranchRequest=(mcase[0].Subject=='TIDS – Virtual Branch Access Request');
		isRelinquishRequest=(mcase[0].Reason1__c=='TIDS – Relinquishment');
		isReinstateRequest=(mcase[0].Reason1__c=='TIDS – Reinstatement');
		if (isVirtualBranchRequest==false && isRelinquishRequest==false && isReinstateRequest==false)  {isStartVetting=true;}
	}
	
	public void approveRequest() {
		this.isOpen=false;
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG34);
		if (!Test.isRunningTest()) {getRequestCase();}
		if (mcase.size()==0){messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG31);return;}
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG32);
		if (isVirtualBranchRequest){
			List<Accreditation__c> a= new List<Accreditation__c>();
			a= [Select Id, Virtual_Branch_Enabled__c From Accreditation__c
			Where Related_Account__c=:mcase[0].AccountId Limit 1];
			if (a.size()>0){
				a[0].Virtual_Branch_Enabled__c=true;
				update a;
			}else{messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG33); return;}
		}
		mcase[0].Decision__c='APPROVED';
		mcase[0].Decision_Date__c=System.now();
		mcase[0].Status=TIDS_Constant.IS_CLOSED;
		mcase[0].OwnerId=UserInfo.getUserId();
		update mcase;
		if (isVirtualBranchRequest){
		   //Send Email to the account contact if any
		   TIDSUTIL.sendNotification(vcase.Id, mcase[0].contactId, TIDS_Constant.NTF_APPROVED_VB,null);
		}else if (isRelinquishRequest){
			TIDSUTIL.sendNotification(vcase.Id, mcase[0].contactId, TIDS_Constant.NTF_APPROVED_RL,null);
		   if (mcase[0].Subject==TIDS_Constant.CASE_SUBJECT_RELINQUISH){
				TidsBatchRelinquishment nb = new TidsBatchRelinquishment();
				nb.caseId=vcase.Id;
				Database.executeBatch(nb,100);
		   }else{
			  TidsBatchHelper.finishBuilderRelinquishment(vcase.Id);
		   }
		}else if (isReinstateRequest){
			TIDSUTIL.sendNotification(vcase.Id, mcase[0].contactId, TIDS_Constant.NTF_APPROVED_RE,null);
			TidsBatchHelper.finishBuilderReinstatement(vcase.Id);
		 }
	}
	public void rejectRequest() {
		this.isOpen=false;
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG34);
		if (!Test.isRunningTest()) {getRequestCase();}
		if (mcase.size()==0){messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG31);return;}
		messageError=TIDSUtil.getTIDSMetadataError(TIDS_Constant.MSG35);
		mcase[0].Decision__c='REJECTED';
		mcase[0].Decision_Date__c=System.now();
		mcase[0].Status=TIDS_Constant.IS_CLOSED;
		mcase[0].OwnerId=UserInfo.getUserId();
		update mcase;
		//Send email
		if (isVirtualBranchRequest){
			TIDSUTIL.sendNotification(vcase.Id, mcase[0].contactId, TIDS_Constant.NTF_REJECTED_VB,null);
		}else if (isRelinquishRequest){
			TIDSUTIL.sendNotification(vcase.Id, mcase[0].contactId, TIDS_Constant.NTF_REJECTED_RL,null);
		}else if (isReinstateRequest){
			TIDSUTIL.sendNotification(vcase.Id, mcase[0].contactId, TIDS_Constant.NTF_REJECTED_RE,null);
		}
	}
}