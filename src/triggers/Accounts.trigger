trigger Accounts on Account (after update) {
    if (Utility.getNumericSetting('Stop Trigger:Account') == 1) return;
    Account_Dom.triggerHandler();
}