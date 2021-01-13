/*
 * Description: CW_AdvancedSearch Tests
 */
@isTest
public with sharing class CW_AdvancedSearchTest {
	/*
	 * Description: case 1 - structureOK, run all the class
	 */
	@isTest
	public static void structureOK() {
		Test.startTest();
		List<CW_AdvancedSearch.ComparisonSupercategoryWrapper> response = (List<CW_AdvancedSearch.ComparisonSupercategoryWrapper>) JSON.deserialize(CW_AdvancedSearch.getStructureFacilities(),List<CW_AdvancedSearch.ComparisonSupercategoryWrapper>.class);
		CW_AdvancedSearch.ComparisonSupercategoryWrapper responseItem = (CW_AdvancedSearch.ComparisonSupercategoryWrapper) response[0];
		Boolean containsMessage = responseItem.label.contains('Equipment and Infrastructure');
		System.assertEquals(containsMessage, true, 'communication failed');
		Test.stopTest();
	}
	
	@isTest
	public static void equipmentOK() {
		Test.startTest();
		List<CW_AdvancedSearch.Field> fields = new List<CW_AdvancedSearch.Field>();
		CW_AdvancedSearch.Equipment equipment = new CW_AdvancedSearch.Equipment('name', 'label', fields, 'category', 'categoryDevName');
		System.assertNotEquals(equipment, null, 'equipment covered');
		Test.stopTest();
	}
}