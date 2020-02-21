/****************************************************************************************************
	Created by Kevin Ky 2015-09-23
	Prevent order items deletion with some status of the order
****************************************************************************************************/
trigger OrderItems on OrderItem (after insert, after update, before delete, before update) {
	if (Utility.getNumericSetting('Stop Trigger:Order and OrderItem') == 1) return;
	OrderItem_Dom.triggerHandler();
}
