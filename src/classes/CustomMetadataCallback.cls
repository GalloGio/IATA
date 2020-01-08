public class CustomMetadataCallback {
	public static void Upsert_MDT_Value(List<CustomMetadataType> CMDTLIST) {
		// parameter passed should be a LIST of Custom Metadata Type Datatype with the MDT.DeveloperName (i.e. MDT_Case_Webservice__mdt.Default_Get_SOQL)
		// If this is an update to an existing record, only send the applicable field(s) to be updated

		Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
		Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
		Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
		integer nIndex = 0;
		for (CustomMetadataType cmdtItem : CMDTLIST) {
			customMetadata =  new Metadata.CustomMetadata();
			customMetadata.fullName = cmdtItem.strMDTAndRecord;
			customMetadata.label = cmdtItem.strMasterLabel;

			nIndex = 0;
			for (String strField : cmdtItem.fieldLIST) {
				customField = new Metadata.CustomMetadataValue();
				customField.field = strField;
				customField.value = cmdtItem.valueLIST[nIndex];
				customMetadata.values.add(customField);

				nIndex ++;
			}

			mdContainer.addMetadata(customMetadata);
		}

		// Setup deploy callback, DeployCallback implements the Metadata.DeployCallback interface
		DeployCallback callback = new DeployCallback();

		// Enqueue custom metadata deployment
		if (!test.isRunningTest()) Metadata.Operations.enqueueDeployment(mdContainer, callback);
	}

	public class DeployCallback implements Metadata.DeployCallback {
		public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
			// Intentionally empty
			if (result.status == Metadata.DeployStatus.Succeeded) {
				System.debug('[cls CustomMetadataCallback - DeployCallback] Success - ' + result);
			} else {
				System.debug('[cls CustomMetadataCallback - DeployCallback] Error - ' + result);
			}
		}
	}

	public class CustomMetadataType {
		public String strMDTAndRecord;
		public String strMasterLabel;
		public List<String> fieldLIST = new List<String>();
		public List<Object> valueLIST = new List<Object>();
	}
}
