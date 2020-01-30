public without sharing class Community360Ctrl {
@AuraEnabled
	public static void createCommunity360ReadEntry(String recortId){
		if(recortId != null){
			try {
				insert new NetworkUserHistoryRecent(
					AccessTimestamp = Datetime.now(),
					ActionType = 'Read',
					NetworkId = Network.getNetworkId(),
					NetworkUserId = UserInfo.getUserId(),
					RecordId = recortId,
					RecordKeyPrefix = recortId.left(3),
					UserType =  UserInfo.getUserType()
				);
			} catch (Exception e) {
				System.debug(LoggingLevel.FINE, '[cls Community360Ctrl - createCommunity360ReadEntry] exception - ' + e.getStackTraceString());
			}
		}
	}
}