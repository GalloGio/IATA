@isTest
public inherited sharing class IGOM_XMLParserTest {

	@isTest
	private static void parseIGOMTest_Success() {
		String str = '<?xmlversion="1.0" encoding="utf-8"?><Chapter permid="igom-gap-1" id="igom-gap-1" edition="10" xml:lang="en"><Section1 permid="igom-permid_0.4171466117622492" id="igom-1" xml:lang="en"><Section1Number>Chapter 1:</Section1Number><Section1Heading>PassengerHandlingProcedures</Section1Heading><Section2 permid="igom-permid_0.7857337828998681" id="igom-1-1.1"><Section2Number>1.1</Section2Number><Section2Heading>PassengerDeparture</Section2Heading><Section3 permid="igom-permid_0.6496767700095887" id="igom-1-1.1.1"><Section3Number>1.1.1</Section3Number><Section3Heading>Pre-DepartureActivities</Section3Heading><Section4 permid="igom-permid_0.6146238625670233" id="igom-1-1.1.1.1" rev="changed"><Section4Number>1.1.1.1</Section4Number><Section4Heading>TicketSalesCounter</Section4Heading></Section4><Section4 permid="igom-permid_0.6487040525387596" id="igom-1-1.1.1.2" rev="deleted"><Section4Number>1.1.1.2</Section4Number><Section4Heading>PassengerPre-FlightPreparation</Section4Heading></Section4></Section3></Section2></Section1></Chapter>';
		IGOM_XMLParser.XMLElement generalElement;
		Test.startTest();
		generalElement = IGOM_XMLParser.parse(str);
		Test.stopTest();

		System.assertNotEquals(null, generalElement);
		System.assertEquals(1, generalElement.children.size());
		System.assertEquals(1, generalElement.children.get(0).children.size());
		System.assertEquals(1, generalElement.children.get(0).children.get(0).children.size());
		System.assertEquals(2, generalElement.children.get(0).children.get(0).children.get(0).children.size());
		System.assertEquals('Chapter', generalElement.name);
		System.assertEquals(4, generalElement.attributes.keySet().size());
	}

	@isTest
	private static void parseOtherXMLTest_Success() {
		String str = '<?xml version="1.0" encoding="UTF-8"?><breakfast_menu><food><name>Belgian Waffles</name><price>$5.95</price><description>Two of our famous Belgian Waffles with plenty of real maple syrup</description><calories>650</calories></food><food><name>Strawberry Belgian Waffles</name><price>$7.95</price><description>Light Belgian waffles covered with strawberries and whipped cream</description><calories>900</calories></food><food><name>Berry-Berry Belgian Waffles</name><price>$8.95</price><description>Light Belgian waffles covered with an assortment of fresh berries and whipped cream</description><calories>900</calories></food><food><name>French Toast</name><price>$4.50</price><description>Thick slices made from our homemade sourdough bread</description><calories>600</calories></food><food><name>Homestyle Breakfast</name><price>$6.95</price><description>Two eggs, bacon or sausage, toast, and our ever-popular hash browns</description><calories>950</calories></food></breakfast_menu>';
		IGOM_XMLParser.XMLElement generalElement;
		Test.startTest();
		generalElement = IGOM_XMLParser.parse(str);
		Test.stopTest();

		System.assertNotEquals(null, generalElement);
		System.assertEquals(5, generalElement.children.size());
		System.assertEquals('breakfast_menu', generalElement.name);
		System.assertEquals(4, generalElement.children.get(0).attributes.keySet().size());
	}

	@isTest
	private static void parseOtherTxtTest_Error() {
		String str = 'Lorem ipsum dolor sit amet consectetur adipiscing elit tempor, nullam inceptos molestie dignissim a vehicula mollis. Aptent sagittis et dapibus non quisque venenatis vestibulum, ad sed urna id malesuada nascetur dictum habitant, quis mauris nam faucibus odio ultrices. Ante commodo posuere natoque mus dictumst massa nam, netus orci taciti ligula placerat varius, class dui cum gravida ad congue.';
		IGOM_XMLParser.XMLElement generalElement;
		Test.startTest();
		try{
			generalElement = IGOM_XMLParser.parse(str);
		}catch(XMLException e){
			System.assert(e.getMessage().contains('Failed to parse XML'));
		}
		Test.stopTest();
		System.assertEquals(null, generalElement);
	}
}