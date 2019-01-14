/* General Trigger on Case
 * Created On 12/12/2013
 * Created By Kofi Johnson
 *
 * Code moved to a helper class: SIDRACaseHelper.cls
 * by Javier Tena
 * on 17/02/2017
 */

trigger trgCaseLastSIDRADate on Case (after insert, after update) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SIDRACaseHelper.doAfterInsert(Trigger.newMap);
        }
        if (Trigger.isUpdate) {
            SIDRACaseHelper.doAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}
