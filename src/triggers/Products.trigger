/****************************************************************************************************
	Created by Kevin Ky 2015-08-17
		Send email notification to a list of addresses
****************************************************************************************************/
trigger Products on Product2 (after delete, after insert, after update, before delete, before insert, before update) {

	Product_Dom.triggerHandler();

}
