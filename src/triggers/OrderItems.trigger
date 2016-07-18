/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
    Prevent order items deletion with some status of the order
****************************************************************************************************/
trigger OrderItems on OrderItem (after insert, after update, before delete, before update) {
    OrderItem_Dom.triggerHandler();
}