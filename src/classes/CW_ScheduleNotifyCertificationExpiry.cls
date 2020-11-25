/**
 * @description		Schedulable class for calling batch to send notification emails for expiring certifications
 *
 * Edit Log:
 * @history			2020/04/27  |  sf-621  |  Creation.
 */
public with sharing class CW_ScheduleNotifyCertificationExpiry implements Schedulable {
	/**
	 * @description		Method to call the batch class to send notification emails for expiring certifications
	 * @param			sc <SchedulableContext>
	 */
	public void execute(SchedulableContext sc) {
		CW_BatchNotifyCertificationExpiry batchClass = new CW_BatchNotifyCertificationExpiry();
		database.executebatch(batchClass, 1);
	}
}