@isTest
public class IDCard_ApplicationAdminControllerTest {

	static testMethod void testApplicationAdmin(){
		IDCard_ApplicationAdminController ctrl = new IDCard_ApplicationAdminController();

		String CSV = 'IATA CODE, VER, DELEGATE\r\n'+
					 '12345678, VER123, MrDel';
		Blob blobCSV = Blob.valueOf(CSV);

		ctrl.csvFileBody = blobCSV;

		ctrl.importCSVFile();

		ctrl.saveRecord();
	}

}
