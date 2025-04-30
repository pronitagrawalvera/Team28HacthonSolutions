public with sharing class DocumentParserService {
    public class RequestWrapper{
        @InvocableVariable(required=true)
        public Id contentversionId;   
    }
    
    public class ResponseWrapper{
        @InvocableVariable(required=true)
        public string extractedText;
    }
    
    @InvocableMethod(label='Extract text from Document' description='Calls external parser API and returns text content from the file')
    public static List<ResponseWrapper> extractText(List<RequestWrapper> requests){
        List<ResponseWrapper> results = new List<ResponseWrapper>();
        
        // Fetch the base URL of the Parser API from CMDT
        String baseUrl = EnvConfig.get('Parser_API_URL'); //
        
        //loop through the requests
        for(RequestWrapper req: requests){
            ResponseWrapper result = new ResponseWrapper();
            try{
                // Query the ContentVersion for the file data
                ContentVersion version= [SELECT Id,Title, FileExtension, VersionData
                                         FROM ContentVersion
                                         WHERE Id=:req.contentVersionId
                                         LIMIT 1
                                        ];
                //HTTP Request
                HttpRequest httpReq = new HttpRequest();
                //httpReq.setEndpoint(baseUrl + '/parse'); 
                httpReq.setEndpoint('https://document-parser-api.onrender.com/parse');
                httpReq.setMethod('POST');
                httpReq.setHeader('Content-Type', 'application/octet-stream');
                httpReq.setTimeout(120000); // Timeout in milliseconds (120 sec)
                httpReq.setHeader('X-Filename', version.Title + '.' + version.FileExtension);
                
                //request body as file data (blob)
                httpReq.setBodyAsBlob(version.VersionData);
                
                // Send the request
                Http http = new Http();
                HttpResponse res = http.send(httpReq);
                // Process the response
                if (res.getStatusCode() == 200) {
                    result.extractedText = res.getBody();
                } else {
                    result.extractedText = 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();
                }
                
            } catch (Exception e) {
                result.extractedText = 'Exception: ' + e.getMessage();
            }
            
            results.add(result);
            System.debug('results>>> ' + results);
        }
        
        return results;
    }
    
}