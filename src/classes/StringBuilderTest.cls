@isTest
private class StringBuilderTest {

	@isTest static void StringBuilderTestMthod1() {

		String x1 = 'test string1';
		String x2 = 'test string2';
		String x3 = 'test string3';
		String x4 = 'test string4';

		StringBuilder sb = new StringBuilder(new List<String>{x1,x2,x3,x4});

		sb.add('test1');

		String x5 = sb.getStringValue();

		StringBuilder.CSVBuilder csvB = new StringBuilder.CSVBuilder(new List<String>{x1,x2,x3,x4});

		csvB.getStringValue();
		csvB.getStringValue('xpto');

		StringBuilder.MultiCurrencyFieldListBuilder mcflb = new StringBuilder.MultiCurrencyFieldListBuilder(new List<Schema.SObjectField>{Case.subject});

	}



}
