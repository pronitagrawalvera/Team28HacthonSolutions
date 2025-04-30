// This handler finds the latest ContentVersion and enqueues a queueable for callouts
public with sharing class ContentDocumentLinkHandler {
    public static void handleNewLinks(List<ContentDocumentLink> links) {
        Set<Id> responseRecordIds = new Set<Id>();
        Map<Id, Id> docIdToLinkedRecord = new Map<Id, Id>();
        for (ContentDocumentLink link : links) {
            responseRecordIds.add(link.LinkedEntityId);
            docIdToLinkedRecord.put(link.ContentDocumentId, link.LinkedEntityId);
        }

        Map<Id, Response__c> responseMap = new Map<Id, Response__c>([
            SELECT Id FROM Response__c WHERE Id IN :responseRecordIds
        ]);
        
        List<Id> responseDocIds = new List<Id>();
        Map<Id,Id> docToResponseMap = new Map<Id, Id>();
        
        for (Id docId : docIdToLinkedRecord.keySet()) {
            Id linkedId = docIdToLinkedRecord.get(docId);
            if (responseMap.containsKey(linkedId)) {
                responseDocIds.add(docId);
                docToResponseMap.put(docId, linkedId);
            }
        }
        if (responseDocIds.isEmpty()) return;
        System.enqueueJob(new DocumentParserQueueable(responseDocIds, docToResponseMap));
        
    }
}