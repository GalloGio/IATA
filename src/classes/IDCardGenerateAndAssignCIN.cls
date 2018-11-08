public class IDCardGenerateAndAssignCIN extends TriggerAction {
	/**
	 * Method that checks if the record type is AIMS
	 * @param s the affected record
	 * @return true if the record type equals to AIMS
	 */
	protected override Boolean isRelevant(SObject s) {

		ID_Card__c idCardRecord = (ID_Card__c) s;

		if(idCardRecord.RecordTypeID == IDCardUtil.IDCARDAIMS_RTID)
			return true;

		return false;
	}

	/**
	 * Method that updates the CIN field
	 * @param records records with record type AIMS
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

		Map<String, String> mapCinTemplatePerIdCardName = new Map<String, String>();
        Map<String, Integer> mapIncDigitsPerCinTemplate = new Map<String, Integer>();
        Set<String> setCinTemplates = new Set<String>();
        Set<Id> setIdCardApplication = new Set<Id>();
        Map<Id, ID_Card_Application__c> mapIdCardApplicationsById = new Map<Id, ID_Card_Application__c>();

        for (ID_Card__c idCardRecord : (List<ID_Card__c>) records)
            setIdCardApplication.add(idCardRecord.ID_Card_Application__c);
        
        //Since the info from ID Card Application is not available in the idcard before trigger, we need to query the value of the UIR field 
        if(!setIdCardApplication.isEmpty())
            mapIdCardApplicationsById = new Map<Id, ID_Card_Application__c>([SELECT Id, UIR__c FROM ID_Card_Application__c WHERE Id IN: setIdCardApplication]);

        for (ID_Card__c idCard : (List<ID_Card__c>) records) {
            String CIN = '';
            try {
                CIN += idCard.LastName__c.left(3);
                CIN += Datetime.newInstanceGmt(idCard.Date_of_Birth__c.year(), idCard.Date_of_Birth__c.month(), idCard.Date_of_Birth__c.day()).format('yy', 'GMT');
                CIN += idCard.FirstName__c.left(1);
                CIN += Datetime.newInstanceGmt(idCard.Date_of_Birth__c.year(), idCard.Date_of_Birth__c.month(), idCard.Date_of_Birth__c.day()).format('MMdd', 'GMT');
                CIN += '__'; // THE INCREMENT DIGITS
                CIN += idCard.Position_Code__c != '' ? idCard.Position_Code__c : ' ';
                CIN += idCard.Duty_Code__c != '' ? idCard.Duty_Code__c : ' ';
                CIN += idCard.HourWorkedCode__c != '' ? idCard.HourWorkedCode__c : ' ';

                if (mapIdCardApplicationsById.containsKey(idCard.ID_Card_Application__c) && mapIdCardApplicationsById.get(idCard.ID_Card_Application__c).UIR__c != null) {
                    CIN += mapIdCardApplicationsById.get(idCard.ID_Card_Application__c).UIR__c.left(2);
                }
            } catch (Exception e) {
                // empty fields could lead to this
				System.debug('____ [cls IDCardGenerateAndAssignCIN - execute] Error generating CIN: ' + e.getMessage());
            }

            CIN = CIN.toUpperCase();

            // add a temporary prefix for sex M/F, REMOVE IT BEFORE ASSIGNING to the ID Card
            CIN = (idCard.Gender__c == 'Male' ? 'M' : 'F') + CIN;

            mapCinTemplatePerIdCardName.put(idCard.Name, CIN);
            mapIncDigitsPerCinTemplate.put(CIN, idCard.Gender__c == 'Male' ? 0 : 50);
            setCinTemplates.add(CIN.substring(1)); // add to the set without the prefix, to correctly match in the DB

			System.debug('____ [cls IDCardGenerateAndAssignCIN - execute] CIN template: ' + CIN.substring(1));
        }

        // Get current max for the increment digits for each template

        for (ID_Card__c idcard : [SELECT Id, CIN__c, LastName__c, Gender__c FROM ID_Card__c WHERE CIN__c <> null AND CIN__c LIKE :setCinTemplates]) {
			System.debug('____ [cls IDCardGenerateAndAssignCIN - execute] Found related CIN: ' + idcard.CIN__c);

            // for Last Names shorter than 3 chars
            Integer LNamelength = idCard.LastName__c.left(3).length();
            Integer incDigitsStartPosition = LNamelength + 7; // 10 normally

			System.debug('____ [cls IDCardGenerateAndAssignCIN - execute] incDigitsStartPosition: ' + incDigitsStartPosition);

            Integer incDigits = Integer.valueOf(idcard.CIN__c.mid(incDigitsStartPosition, 2));

            if ( incDigits > mapIncDigitsPerCinTemplate.get( (idcard.Gender__c == 'Male' ? 'M' : 'F') + idcard.CIN__c.left(incDigitsStartPosition) + '__' + idcard.CIN__c.substring(incDigitsStartPosition + 2) ) ) {
                mapIncDigitsPerCinTemplate.put( (idcard.Gender__c == 'Male' ? 'M' : 'F') + idcard.CIN__c.left(incDigitsStartPosition) + '__' + idcard.CIN__c.substring(incDigitsStartPosition + 2), incDigits );
            }
        }


        // Set the new inc digits into the CINs and assign them

        for (ID_Card__c idCard : (List<ID_Card__c>) records) {
            // Get the increment digits
            Integer incDigits = mapIncDigitsPerCinTemplate.get(mapCinTemplatePerIdCardName.get(idCard.Name));

            //increase the digits for the new card
            incDigits++;

            // update the increased digits in the map
            mapIncDigitsPerCinTemplate.put(mapCinTemplatePerIdCardName.get(idCard.Name), incDigits);

            // insert the digits in the CIN template for the idcard
            String strCIN = mapCinTemplatePerIdCardName.get(idCard.Name).replace('__', String.valueOf(incDigits).leftPad(2).replace(' ', '0'));

            // remove the temporary prefix (M/F)
            strCIN = strCIN.substring(1);

            idCard.CIN__c = strCIN;

			System.debug('____ [cls IDCardGenerateAndAssignCIN - execute] New CIN assigned: ' + strCIN);
        }
	}
}