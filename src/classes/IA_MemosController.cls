public with sharing class IA_MemosController {

	public List<DocumentRow> listDocuments {
		get{
			if (listDocuments==null) {
				listDocuments = new list<DocumentRow>();

				for( ContentWorkspaceDoc doc :
					[SELECT ContentDocument.Id, ContentDocument.Title, CreatedDate
					FROM ContentWorkspaceDoc
					WHERE ContentWorkspace.Name = :IA_util.LIBRARY_CS
					ORDER BY CreatedDate DESC
					LIMIT 1000] )
				{
					DocumentRow row = new DocumentRow();
					row.docId = doc.ContentDocument.Id;
					row.docname = doc.ContentDocument.Title.replace('.pdf','');
					row.doctype = 'PDF';
					row.docdate = IA_util.dateformat(doc.CreatedDate);
					listDocuments.add(row);
				}
			}
			return listDocuments;
		}
		private set;
	}

	private class DocumentRow {
		public String docId {get;set;}
		public String docname {get;set;}
		public String docdate {get;set;}
		public String doctype {get;set;}
	}
}