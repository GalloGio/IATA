/****************************************************************************************************
	Created by Kevin Ky 2015-08-17
	Link ZProduct and Product
****************************************************************************************************/

trigger ZProducts on zqu__ZProduct__c (after delete, after insert, after update, before delete, before insert, before update) {

	ZProduct_Dom.triggerHandler();

}
