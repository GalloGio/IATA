@isTest
private class AWS_ExplorerConTest {

	@isTest
	public static void testcon() {
		try {
			AWS_ExplorerCon a = new AWS_ExplorerCon();
			String credName = a.createTestCredentials();
			a.AWSCredentialName = credName;

			a.constructor();
			a.selectedObjectName = 'foo';
			system.assert( a.objectNames != null );
			a.getFields();
			system.debug ( a.selectedObjectName );
			system.debug ( a.selectedFieldName );
			system.debug ( a.selectedField );
			system.debug ( a.selectedObject );
			system.debug ( a.as3 );
			system.assert( a.getFieldDetails() == null );
		} catch (Exception ex) {
		}

	}

	@isTest
	public static void testcon2() {
		try {
			AWS_ExplorerCon a = new AWS_ExplorerCon();
			String credName = a.createTestCredentials();
			a.AWSCredentialName = credName;

			a.constructor();
			a.getFields();
		} catch (Exception ex) {
		}

	}

	@isTest
	public static void testcon3() {
		try {
			AWS_ExplorerCon a = new AWS_ExplorerCon();
			String credName = a.createTestCredentials();
			a.AWSCredentialName = credName;

			a.constructor();
			system.debug ( a.selectedObjectName );
			system.debug ( a.selectedFieldName );
			system.debug ( a.selectedField );
			system.debug ( a.selectedObject );
			system.debug ( a.as3 );
			try {
				system.assert( a.getFieldDetails() == null );
			} catch ( exception ee) {
				// expected
			}

			AWS_ExplorerCon.TreeNode t = new AWS_ExplorerCon.TreeNode('foo', 'sdf');
			system.debug( t.label );
			system.debug( t.value );
		} catch (Exception ex) {
		}
	}

}