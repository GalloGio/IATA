public class IECEBC_ETCampaignTrackingAsync {

	// updating campaign tracking records
	public static void updateTrackingRealtime (Id campaignId, String triggeredSendExternalKey, DateTime SendDate, Integer hour){
		// Retrieve Campagin tracking record
		List<EBC_Campaign_Email_Tracking__c> campEmailTracks = [Select Id, Name
														 From EBC_Campaign_Email_Tracking__c
														 Where ebc_campaign__c = :campaignId
														 And rank__c = :hour];

		EBC_Campaign_Email_Tracking__c campEmailTrack;
		if (campEmailTracks.size() > 0) { campEmailTrack = campEmailTracks[0]; }
		else {
			System.debug('Out of range');
			return ;
		}

		// call Get Triggered Send Summary
		Map<String, String> TSSummary = IECEBC_ExactTargetRetrieve.getTriggeredSendSummary(triggeredSendExternalKey);


		List<AggregateResult> previousCampEmailTracks = [Select
																		sum(NumberBounced__c) NumberBounced__c,
																		sum(NumberofClicks__c) NumberofClicks__c,
																		sum(NumberofOpens__c) NumberofOpens__c,
																		sum(NumberOptOuts__c) NumberOptOuts__c,
																		sum(NumberSent__c) NumberSent__c,

																		sum(NotSentDueToOptOut__c) NotSentDueToOptOut__c,
																		sum(NotSentDueToUndeliverable__c) NotSentDueToUndeliverable__c,
																		sum(NumberofUniqueClicks__c) NumberofUniqueClicks__c,
																		sum(NumberofUniqueOpens__c) NumberofUniqueOpens__c,
																		sum(NotSentDueToError__c) NotSentDueToError__c,
																		sum(FTAFEmailsSent__c) FTAFEmailsSent__c,
																		sum(FTAFOptIns__c) FTAFOptIns__c,
																		sum(FTAFRequests__c) FTAFRequests__c,
																		sum(SurveyResponses__c) SurveyResponses__c,
																		sum(Conversions__c) Conversions__c,
																		sum(UniqueConversions__c) UniqueConversions__c,
																		sum(InProcess__c) InProcess__c,
																		sum(Queued__c) Queued__c

																		From EBC_Campaign_Email_Tracking__c
																		Where ebc_campaign__c = :campaignId
										And rank__c < :hour];

		// set main metrics
		if(TSSummary.get('Bounces') != '') campEmailTrack.NumberBounced__c = Decimal.valueOf(TSSummary.get('Bounces')) - ((Decimal)previousCampEmailTracks[0].get('NumberBounced__c') != null ? (Decimal)previousCampEmailTracks[0].get('NumberBounced__c') : 0);
		if(TSSummary.get('Clicks') != '') campEmailTrack.NumberofClicks__c = Decimal.valueOf(TSSummary.get('Clicks')) - ((Decimal)previousCampEmailTracks[0].get('NumberofClicks__c') != null ? (Decimal)previousCampEmailTracks[0].get('NumberofClicks__c') : 0);
		if(TSSummary.get('Opens') != '') campEmailTrack.NumberofOpens__c = Decimal.valueOf(TSSummary.get('Opens')) - ((Decimal)previousCampEmailTracks[0].get('NumberofOpens__c') != null ? (Decimal)previousCampEmailTracks[0].get('NumberofOpens__c') : 0);
		if(TSSummary.get('OptOuts') != '') campEmailTrack.NumberOptOuts__c = Decimal.valueOf(TSSummary.get('OptOuts')) - ((Decimal)previousCampEmailTracks[0].get('NumberOptOuts__c') != null ? (Decimal)previousCampEmailTracks[0].get('NumberOptOuts__c') : 0);
		if(TSSummary.get('Sent') != '') campEmailTrack.NumberSent__c = Decimal.valueOf(TSSummary.get('Sent')) - ((Decimal)previousCampEmailTracks[0].get('NumberSent__c') != null ? (Decimal)previousCampEmailTracks[0].get('NumberSent__c') : 0);

		// set other metrics
		if(TSSummary.get('NotSentDueToOptOut') != '') campEmailTrack.NotSentDueToOptOut__c = Decimal.valueOf(TSSummary.get('NotSentDueToOptOut')) - ((Decimal)previousCampEmailTracks[0].get('NotSentDueToOptOut__c') != null ? (Decimal)previousCampEmailTracks[0].get('NotSentDueToOptOut__c') : 0);
		if(TSSummary.get('NotSentDueToUndeliverable') != '') campEmailTrack.NotSentDueToUndeliverable__c = Decimal.valueOf(TSSummary.get('NotSentDueToUndeliverable')) - ((Decimal)previousCampEmailTracks[0].get('NotSentDueToUndeliverable__c') != null ? (Decimal)previousCampEmailTracks[0].get('NotSentDueToUndeliverable__c') : 0);
		if(TSSummary.get('UniqueClicks') != '') campEmailTrack.NumberofUniqueClicks__c = Decimal.valueOf(TSSummary.get('UniqueClicks')) - ((Decimal)previousCampEmailTracks[0].get('NumberofUniqueClicks__c') != null ? (Decimal)previousCampEmailTracks[0].get('NumberofUniqueClicks__c') : 0);
		if(TSSummary.get('UniqueOpens') != '') campEmailTrack.NumberofUniqueOpens__c = Decimal.valueOf(TSSummary.get('UniqueOpens')) - ((Decimal)previousCampEmailTracks[0].get('NumberofUniqueOpens__c') != null ? (Decimal)previousCampEmailTracks[0].get('NumberofUniqueOpens__c') : 0);
		if(TSSummary.get('NotSentDueToError') != '') campEmailTrack.NotSentDueToError__c = Decimal.valueOf(TSSummary.get('NotSentDueToError')) - ((Decimal)previousCampEmailTracks[0].get('NotSentDueToError__c') != null ? (Decimal)previousCampEmailTracks[0].get('NotSentDueToError__c') : 0);
		if(TSSummary.get('FTAFEmailsSent') != '') campEmailTrack.FTAFEmailsSent__c = Decimal.valueOf(TSSummary.get('FTAFEmailsSent')) - ((Decimal)previousCampEmailTracks[0].get('FTAFEmailsSent__c') != null ? (Decimal)previousCampEmailTracks[0].get('FTAFEmailsSent__c') : 0);
		if(TSSummary.get('FTAFOptIns') != '') campEmailTrack.FTAFOptIns__c = Decimal.valueOf(TSSummary.get('FTAFOptIns')) - ((Decimal)previousCampEmailTracks[0].get('FTAFOptIns__c') != null ? (Decimal)previousCampEmailTracks[0].get('FTAFOptIns__c') : 0);
		if(TSSummary.get('FTAFRequests') != '') campEmailTrack.FTAFRequests__c = Decimal.valueOf(TSSummary.get('FTAFRequests')) - ((Decimal)previousCampEmailTracks[0].get('FTAFRequests__c') != null ? (Decimal)previousCampEmailTracks[0].get('FTAFRequests__c') : 0);
		if(TSSummary.get('SurveyResponses') != '') campEmailTrack.SurveyResponses__c = Decimal.valueOf(TSSummary.get('SurveyResponses')) - ((Decimal)previousCampEmailTracks[0].get('SurveyResponses__c') != null ? (Decimal)previousCampEmailTracks[0].get('SurveyResponses__c') : 0);
		if(TSSummary.get('Conversions') != '') campEmailTrack.Conversions__c = Decimal.valueOf(TSSummary.get('Conversions')) - ((Decimal)previousCampEmailTracks[0].get('Conversions__c') != null ? (Decimal)previousCampEmailTracks[0].get('Conversions__c') : 0);
		if(TSSummary.get('UniqueConversions') != '') campEmailTrack.UniqueConversions__c = Decimal.valueOf(TSSummary.get('UniqueConversions')) - ((Decimal)previousCampEmailTracks[0].get('UniqueConversions__c') != null ? (Decimal)previousCampEmailTracks[0].get('UniqueConversions__c') : 0);
		if(TSSummary.get('InProcess') != '') campEmailTrack.InProcess__c = Decimal.valueOf(TSSummary.get('InProcess')) - ((Decimal)previousCampEmailTracks[0].get('InProcess__c') != null ? (Decimal)previousCampEmailTracks[0].get('InProcess__c') : 0);
		if(TSSummary.get('Queued') != '') campEmailTrack.Queued__c = Decimal.valueOf(TSSummary.get('Queued')) - ((Decimal)previousCampEmailTracks[0].get('Queued__c') != null ? (Decimal)previousCampEmailTracks[0].get('Queued__c') : 0);

		//update object
		update campEmailTrack;
	}


	// initialise all tracking records
	// should be called after campaign send
	public static void initCampaignTrackingRecords(Id campaignId){
		EBC_Campaign__c c = [Select Id, External_Id__c, Send_Datetime__c, Name From EBC_Campaign__c Where Id = :campaignId];

		initCampaignTrackingRecords(c);
	}
	public static void initCampaignTrackingRecords(EBC_Campaign__c camp){
		List<EBC_Campaign_Email_Tracking__c> campTrackList = new List<EBC_Campaign_Email_Tracking__c>();
		for(Integer i = 1; i <= 48; i++){
			EBC_Campaign_Email_Tracking__c campTrack = new EBC_Campaign_Email_Tracking__c();
			campTrack.EBC_Campaign__c = camp.Id;
			campTrack.TriggeredSendName__c =  camp.External_Id__c;
			campTrack.SendDate__c = camp.Send_Datetime__c;
			campTrack.Name = 'Send date + ' + String.valueOf(i) + 'h';
			campTrack.Rank__c = i;
			resetCampaignTrackingRecord(campTrack, null);
			campTrackList.add(campTrack);
		}
		for(Integer d = 3; d <= 7; d++){
			Integer i = d * 24;
			EBC_Campaign_Email_Tracking__c campTrack = new EBC_Campaign_Email_Tracking__c();
			campTrack.EBC_Campaign__c = camp.Id;
			campTrack.TriggeredSendName__c =  camp.External_Id__c;
			campTrack.SendDate__c = camp.Send_Datetime__c;
			campTrack.Name = 'Send date + ' + String.valueOf(d) + 'd';
			campTrack.Rank__c = i;
			resetCampaignTrackingRecord(campTrack, null);
			campTrackList.add(campTrack);
		}
		insert campTrackList;
	}

	// Cumulative Campaign KPIs Tracking
	public static void createCumulativeCampaignTracking(List<EBC_Campaign__c> campaignList){
		// campaign list to update
		List<EBC_Campaign__c> campaignListUpdated = new List<EBC_Campaign__c>();

		// for each campaign
		for(EBC_Campaign__c c : campaignList){
			// check if Campaign scheduled and sent
			// calculate the difference of time
			Long dt1Long = c.Send_Datetime__c.getTime();
			Long dt2Long = DateTime.now().getTime();
			Double milliseconds = Double.valueOf(dt2Long - dt1Long);
			Integer hour = Integer.valueOf(Math.ceil(milliseconds / Double.valueOf(3600000)));
			if (hour <= 168) {

				System.debug('Update tracking for ' + c.Id);
				updateTrackingRealtime(c.Id,
									   c.External_Id__c,
									   c.Send_Datetime__c,
									   hour);

			}
			if(c.Send_Datetime__c.addDays(7) < Datetime.now()){
				c.is7dFollowUpCompleted__c = true;
				campaignListUpdated.add(c);
			}

		}
		if(campaignListUpdated.size() > 0){
			update campaignListUpdated;
		}
	}

	public static void resetCampaignTrackingRecord(EBC_Campaign_Email_Tracking__c campTrack, Integer fieldValue){

		// set main metrics
		campTrack.NumberBounced__c = fieldValue;
		campTrack.NumberofClicks__c = fieldValue;
		campTrack.NumberofOpens__c = fieldValue;
		campTrack.NumberOptOuts__c = fieldValue;
		campTrack.NumberSent__c = fieldValue;

		// set other metrics
		campTrack.NotSentDueToOptOut__c = fieldValue;
		campTrack.NotSentDueToUndeliverable__c = fieldValue;
		campTrack.NumberofUniqueClicks__c = fieldValue;
		campTrack.NumberofUniqueOpens__c = fieldValue;
		campTrack.NotSentDueToError__c = fieldValue;
		campTrack.FTAFEmailsSent__c = fieldValue;
		campTrack.FTAFOptIns__c = fieldValue;
		campTrack.FTAFRequests__c = fieldValue;
		campTrack.SurveyResponses__c = fieldValue;
		campTrack.Conversions__c = fieldValue;
		campTrack.UniqueConversions__c = fieldValue;
		campTrack.InProcess__c = fieldValue;
		campTrack.Queued__c = fieldValue;
	}
}
