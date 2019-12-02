public class ANG_MulticountryCopyParentInfo implements Queueable {

	private List<Id> listAccountID;
	private String changeCode;

	public ANG_MulticountryCopyParentInfo(List<Id> accListId, String code){
		this.listAccountID = accListId;
		this.changeCode = code;
	}

	public void execute(QueueableContext context) {

		System.debug(LoggingLevel.FINE, '____ [cls ANG_MulticountryCopyParentInfo - execute] Executing ANG_MulticountryCopyParentInfo Job');

		List<AMS_OSCAR__c> oscars = [SELECT Id, AMS_Online_Accreditation__c,
										Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c, 
										Account__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Remittance_Frequency_per_State__c,
										Account__r.Parent.Name, 
										Account__r.Parent.IATA_ISO_Country__r.AMS_Settlement_System__c,
										Account__r.Parent.Remittance_frequency__c
									 FROM AMS_OSCAR__c
									 WHERE Account__r.ParentId IN :listAccountID];

		if(oscars.isEmpty()) return;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_MulticountryCopyParentInfo - execute] oscars to update: ' + oscars);

		List<AMS_Pax_Accreditation_Form__c> onlineAccList = new List<AMS_Pax_Accreditation_Form__c>();
		AMS_Pax_Accreditation_Form__c onlineAcc;

		if(changeCode == 'FIN'){

			for(AMS_OSCAR__c osc : oscars){
				
				System.debug(LoggingLevel.FINE, '____ [cls ANG_MulticountryCopyParentInfo - execute] Copying data from: ' + osc.Account__r.Parent.Name);

				if (osc.Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c 
						== osc.Account__r.Parent.IATA_ISO_Country__r.AMS_Settlement_System__c
					&& ! osc.Account__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Remittance_Frequency_per_State__c)
				{
					onlineAcc = new AMS_Pax_Accreditation_Form__c(
						id = osc.AMS_Online_Accreditation__c, 
						Remittance_frequency__c = osc.Account__r.Parent.Remittance_frequency__c
					);

					onlineAccList.add(onlineAcc);
				}
			}
		}

		System.debug(LoggingLevel.FINE, '____ [cls ANG_MulticountryCopyParentInfo - execute] Before update Chield Staging area onlineAccList: ' + onlineAccList );

		if(!onlineAccList.isEmpty()) update onlineAccList;
	}

}