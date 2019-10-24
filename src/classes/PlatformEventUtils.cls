/**
 * Created by LBERB on 17/10/2019.
 */

/**
 * Handle platform event logic (add them to a list and send them)
 */
public with sharing class PlatformEventUtils {

    @TestVisible
    private static List<SObject> events = new List<SObject>();

    public static void clear() {
        System.debug('PlatformEventUtils.clear()');
        events.clear();
    }

    public static void add(SObject sobj) {
        System.debug('PlatformEventUtils.add() - ' + sobj);
        events.add(sobj);
    }

    public static Boolean send() {
        System.debug('PlatformEventUtils.send() - ' + events.size());
        Boolean isFullSuccess = true;
        if (events.size() > 0) {
            // Send and inspect publishing result for each event
            for (Database.SaveResult saveResult : EventBus.publish(events)) {
                if (!saveResult.isSuccess()) {
                    isFullSuccess = false;
                    for (Database.Error error : saveResult.getErrors()) {
                        System.debug('Error returned: ' + error.getStatusCode() + ' - ' + error.getMessage());
                    }
                }
            }
        }

        // TODO Gestion d'erreurs
        return isFullSuccess;
    }
}