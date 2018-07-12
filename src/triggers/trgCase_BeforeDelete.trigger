/* 
 * Created On 06/05/2014
 * Description: Forbid the deletion of IFAP cases
 */
trigger trgCase_BeforeDelete on Case (before delete)
{
	private Id IFAP_RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
	for (Case aCase: trigger.old)
	{
		if(aCase.RecordTypeId == IFAP_RecordTypeId) aCase.addError('Deleting an IFAP case is not allowed');
	}
}