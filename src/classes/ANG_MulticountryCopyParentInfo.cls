public class ANG_MulticountryCopyParentInfo implements Queueable {

	private List<Id> listAccountID;
	private String changeCode;

	public ANG_MulticountryCopyParentInfo(List<Id> accListId, String code){
		this.listAccountID = accListId;
		this.changeCode = code;
	}

	public void execute(QueueableContext context) {

		System.debug('[ANG_MulticountryCopyParentInfo] Execuing ANG_MulticountryCopyParentInfo');

		List<AMS_OSCAR__c> oscars = [SELECT id, AMS_Online_Accreditation__c, Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c, 
										Account__r.Parent.Name, 
										Account__r.Parent.IATA_ISO_Country__r.AMS_Settlement_System__c,
										Account__r.Parent.Company_Type__c, 
										Account__r.Parent.IATA_ISO_Country__c, 
										Account__r.Parent.Location_Class__c, 
										Account__r.Parent.TradeName__c, 
										Account__r.Parent.Short_Name__c, 
										Account__r.Parent.Website, 
										Account__r.Parent.VAT_Number__c, 
										Account__r.Parent.Iso_State__c,	
										Account__r.Parent.ANG_Accreditation_Model__c,
										Account__r.Parent.Remittance_frequency__c
									 FROM AMS_OSCAR__c
									 WHERE
									 	 Account__r.ParentId IN :listAccountID
									 AND Process__c =: AMS_Utils.MCAE];

		if(oscars.isEmpty()) return;

		System.debug('[ANG_MulticountryCopyParentInfo] oscars to update: ' + oscars);

		List<AMS_Pax_Accreditation_Form__c> onlineAccList = new List<AMS_Pax_Accreditation_Form__c>();
		AMS_Pax_Accreditation_Form__c onlineAcc;

		if(changeCode == 'NEW'){

			for(AMS_OSCAR__c osc : oscars){

				if(osc.Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c == osc.Account__r.Parent.IATA_ISO_Country__r.AMS_Settlement_System__c){

					System.debug('[ANG_MulticountryCopyParentInfo] Copiyng data from: ' + osc.Account__r.Parent.Name);

					//Create new AMS_Pax_Accreditation_Form__c object for each Oscar
					onlineAcc = new AMS_Pax_Accreditation_Form__c(

						id = osc.AMS_Online_Accreditation__c,
						Account_Name__c = osc.Account__r.Parent.Name,
												
						ISSP_AMS_Legal_Status__c = AMS_Utils.transformLegalStatus(osc.Account__r.Parent.Company_Type__c), 	


						Branch_Office_Country__c = osc.Account__r.Parent.IATA_ISO_Country__c,				//ISO Country 
						Location_Class__c = osc.Account__r.Parent.Location_Class__c,						//Location Class

						Trade_Name__c = osc.Account__r.Parent.TradeName__c,									//Account Trade Name
						Short_Name__c = osc.Account__r.Parent.Short_Name__c,								//Short Name
						Website__c = osc.Account__r.Parent.Website,											//Wesite
						ISSP_AMS_VAT_number__c = osc.Account__r.Parent.VAT_Number__c,						//VATNumber1,
						IATA_ISO_State__c = osc.Account__r.Parent.Iso_State__c,								//ISO state 
						ANG_Accreditation_type__c = osc.Account__r.Parent.ANG_Accreditation_Model__c		//accreditation type
					);
					onlineAccList.add(onlineAcc);
				}
			}
		}
		else if(changeCode == 'FIN'){

			for(AMS_OSCAR__c osc : oscars){

				if(osc.Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c == osc.Account__r.Parent.IATA_ISO_Country__r.AMS_Settlement_System__c){

		    		onlineAcc = new AMS_Pax_Accreditation_Form__c(
		    			id = osc.AMS_Online_Accreditation__c, 
		    			Remittance_frequency__c = osc.Account__r.Parent.Remittance_frequency__c
		    		);

	    			onlineAccList.add(onlineAcc);
	    		}
	    	}
	    }

	    System.debug('[ANG_MulticountryCopyParentInfo] Before update Chield Staging area onlineAccList: ' + onlineAccList );

	    if(!onlineAccList.isEmpty()) update onlineAccList;
	}

}