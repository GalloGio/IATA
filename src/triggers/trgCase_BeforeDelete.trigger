/* 
 * Created On 06/05/2014
 * Description: Forbid the deletion of IFAP cases
 */
trigger trgCase_BeforeDelete on Case (before delete)
{
	private Id IFAP_RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
	for (Case aCase: trigger.old)
	{
		if(aCase.RecordTypeId == IFAP_RecordTypeId) aCase.addError('Deleting an IFAP case is not allowed');
	}
}