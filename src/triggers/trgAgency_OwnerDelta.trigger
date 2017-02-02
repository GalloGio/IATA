/*
 * This trigger and similar trigger should be run on all object related to a GSS File specfifcaiton 
 * It is calling the trigger helper (GSS_DeltaTriggerHelper.calculateDeltas) that takes care of tracking
 * deltas per file specification
 * 
 * Author:  Alexandre Jaimes 05/10/2015
 */

trigger trgAgency_OwnerDelta on Agency_Owner__c (after insert, after update, after delete) {

    //Calls the Trigger Helper that will calculate the deltas that relates file specification and this reccord  
    if (trigger.isInsert) GSS_DeltaTriggerHelper.calculateDeltas('I', Trigger.New, Trigger.New);
  
    if (trigger.isUpdate) GSS_DeltaTriggerHelper.calculateDeltas('U', Trigger.Old, Trigger.New);
    
    if (trigger.isDelete) GSS_DeltaTriggerHelper.calculateDeltas('D', Trigger.Old, Trigger.Old);    

}