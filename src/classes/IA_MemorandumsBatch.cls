/**
 * This class should be called exclusevely by IA_MemorandumsSchedule
 * It creates a single PDF file and stores it in a specific Library folder
 * These files are memorandums containing information about in Interline Agreements (MITA_Agreement__c)
 * and must be accessible in Interline Agreements portal application.
 */
public class IA_MemorandumsBatch implements Queueable, Database.AllowsCallouts {

	public static final ContentWorkspace LIBRARY = [SELECT ID FROM ContentWorkspace WHERE Name = :IA_util.LIBRARY_CS];
	public static final String MEMO_PAGE = 'InterlineAgreementsMemorandum';
	public static final String BASE_NAME = 'Memorandum';

	public String filename;
	public DateTime fromDate;

	public IA_MemorandumsBatch(DateTime fromDate) {
		this.fromDate = fromDate;
	}

	public void execute(QueueableContext context) {
		createMemorandum();
	}

	public void createMemorandum() {
		Savepoint sp = Database.setSavepoint();
		try {
			String counter = getNextCounter();
			this.filename = BASE_NAME + ' ' + counter + ' - Monthly Interline Agreements - ' + this.fromDate.format('MMMM yyyy') + '.pdf';
	
			ContentVersion doc = new ContentVersion();
			doc.Title = this.filename;
			doc.PathOnClient = doc.Title.replace(' ','_');
			doc.VersionData = getPDFContent(counter);
			doc.Country_visibilty__c = 'All - Globally';
			doc.Country_of_publication__c = 'All - Globally';
			doc.Language__c = 'English';
			doc.User_status_access__c = 'Approved User;Approved Admin';
			doc.Document_Category__c = '';
			insert doc;

			doc = [select ContentDocumentId from ContentVersion where id = :doc.id];

			ContentWorkspaceDoc docLink = new ContentWorkspaceDoc();
			docLink.ContentDocumentId = doc.ContentDocumentId;
			docLink.ContentWorkspaceId = LIBRARY.id;
			insert docLink;

		} catch (Exception e) {
			TransformationHelper.sendEmailSupport('ERROR: IA_MemorandumsBatch.createMemorandum() ' , '   STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
			Database.rollback(sp);
		}
	}

	public String getNextCounter() {
		// Find las content document
		String queryName = BASE_NAME + '%';
		list<ContentWorkspaceDoc> listDocs = [
			SELECT  ContentDocument.Title
			FROM ContentWorkspaceDoc
			WHERE ContentWorkspaceId = :LIBRARY.id
			AND ContentDocument.Title LIKE :queryName
			ORDER BY CreatedDate DESC
			LIMIT 1];
		// if not found the counter starts on 1
		if (listDocs.isEmpty()) {
			return '1';
		}
		// otherwise it will be the last counter +1
		String docName = listDocs[0].ContentDocument.Title;
		list<String> listParts = docName.split(' ');
		// position 0: string in BASE_NAME
		// position 1: counter
		// position ...: others
		Integer counter = Integer.valueOf(listParts[1]);
		return String.ValueOf(++counter);
	}

	/*
		Create a library document
	*/
	public static Blob testContent = null;
	private Blob getPDFContent(String counter) {
		PageReference page = new PageReference('/apex/' + MEMO_PAGE);
		page.getParameters().put('date',this.fromDate.format('dd/MM/yyyy'));
		page.getParameters().put('number',counter);
		
		return Test.isRunningTest()? testContent: page.getContentAsPdf();
	}
}