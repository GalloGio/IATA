global class AMS_EBulletinGenerator implements Schedulable {

	@ReadOnly
	global void execute(SchedulableContext sc) {
		String typeEBulletin = 'Daily';

		//AMS_EBulletinReportHelper.getEBulletinCCExtraction(typeEBulletin + '__c');
		
		Set <String> ccNamesToRecover = AMS_CustomSettingsUtils.ccNameSectionMap.keyset();
		
		AMS_EBulletinBatch b = new AMS_EBulletinBatch(typeEBulletin,ccNamesToRecover);
		database.executebatch(b,50);
	}

}