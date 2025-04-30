// Queueable Apex class that performs callout and inserts parsed document records
public with sharing class DocumentParserQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> contentDocumentIds;
    private Map<Id, Id> docToResponseMap;
   // private static final String AGENT_ID = '0XxdL000000bvYnSAI'; // <--  Agent Id
    
     public DocumentParserQueueable(List<Id> docIds, Map<Id, Id> docToResponse) {
        this.contentDocumentIds = docIds;
        this.docToResponseMap = docToResponse;
    }
    
   public void execute(QueueableContext context) {
    List<ContentVersion> versions = [
        SELECT Id, ContentDocumentId, Title
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentDocumentIds
        AND IsLatest = true
    ];

    List<DocumentParserService.RequestWrapper> inputs = new List<DocumentParserService.RequestWrapper>();
    Map<Id, Id> versionToDocumentMap = new Map<Id, Id>();
    Map<Id, Id> versionToResponseMap = new Map<Id, Id>();

    for (ContentVersion v : versions) {
        DocumentParserService.RequestWrapper input = new DocumentParserService.RequestWrapper();
        input.contentVersionId = v.Id;
        inputs.add(input);
        versionToDocumentMap.put(v.Id, v.ContentDocumentId);
        versionToResponseMap.put(v.Id, docToResponseMap.get(v.ContentDocumentId));
    }

    if (!inputs.isEmpty()) {
        List<DocumentParserService.ResponseWrapper> results = DocumentParserService.extractText(inputs);

        // Build a map from ContentVersionId to extracted text for safe access
        Map<Id, String> versionIdToExtractedText = new Map<Id, String>();
        for (Integer i = 0; i < inputs.size(); i++) {
            versionIdToExtractedText.put(inputs[i].contentVersionId, results[i].extractedText);
        }

        List<Parsed_Document__c> parsedDocs = new List<Parsed_Document__c>();

        for (ContentVersion v : versions) {
            Parsed_Document__c doc = new Parsed_Document__c();
            doc.Content_Version_ID__c = v.Id;
            doc.Content_Document_ID__c = v.ContentDocumentId;
            doc.Extracted_Text__c = versionIdToExtractedText.get(v.Id);
            doc.Response__c = versionToResponseMap.get(v.Id);
            parsedDocs.add(doc);
        }

        if (!parsedDocs.isEmpty()) {
            insert parsedDocs;
        }
    }
}


}