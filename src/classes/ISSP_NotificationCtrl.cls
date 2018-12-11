/**
 * Created by FME on 11/21/2018.
 */
public class ISSP_NotificationCtrl {

	public boolean showPopUp {get; set;}
	public boolean closePopUp {get; set;}
	public String msgLabelName {get; set;}
	public String msgLabelButton {get; set;}
	public String msgLabelTitle {get; set;}
	public String recordId {get; set;}
	public Boolean showButton {get; set;}
	public String vfpage {get; set;}
	public String attId {get; set;}

	public ISSP_NotificationCtrl(){
		closePopUp= false;
	}

	public void closeModalPopup()
	{
		//this.showPopUp = false;
		closePopUp = true;
	}

	public pageReference openRecord()
	{
		PageReference pageRef = new PageReference(vfpage);
		pageRef.getParameters().put(attId,recordId);
		pageRef.getParameters().put('mid','M1S2');
		pageRef.setRedirect(true);
		return pageRef;
	}



}