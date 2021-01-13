/**
 * @description		Handler for managing database transactions concerning rollbacks
 *
 * Edit Log:
 * @history			2020/08/27  |  SF-964  |  Creation.
 */
public with sharing class CW_DBTransactionHandler {
	
	/**
	 * @description		Handle rollback to given SavePoint
	 * @param			sp <Savepoint to rollback to>
	 */
	public static void doRollback(Savepoint sp){
		if(sp != null){
			Database.rollback(sp);
		}
	}

	/**
	 * @description		Get the current state of the database
	 * @return			Savepoint object that represents the state of the database at the time of execution
	 */
	public static Savepoint setSavePoint(){
		return Database.setSavepoint();		
	}

}