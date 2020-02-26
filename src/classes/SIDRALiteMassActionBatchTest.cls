@isTest
public class SIDRALiteMassActionBatchTest {

	@isTest
	public static void testBatch() {
		Id userId = USerInfo.getUserId();

		Case parent = new Case( Subject = 'parent Case');
		insert parent;

		Case child = new Case(
			Subject='test Case',
			RecordtypeId = SIDRALiteMassActionBatch.RECORDTYPE_SIDRA_LITE,
			ParentID = parent.Id
		);
		insert child;

		list<Case> listCase = new list<Case>{parent, child};

		Test.startTest();
		SIDRALiteMassActionBatch batch = new SIDRALiteMassActionBatch(listCase, userId);
		Database.executeBatch(batch);
		Test.stopTest();
	}

}
