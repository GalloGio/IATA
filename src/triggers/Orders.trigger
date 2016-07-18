/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
    Prevent orders deletion with some status
****************************************************************************************************/
trigger Orders on Order (after delete, after insert, after update, before delete, before insert, before update) {
    Order_Dom.triggerHandler();
}