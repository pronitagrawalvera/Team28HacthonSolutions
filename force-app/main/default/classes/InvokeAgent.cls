public class InvokeAgent {
    public static String getSummaryFromAgent(String extractedText) {
        try {
            // Create an instance of the invocable action with type ‘generateAiAgentResponse’ and name ‘Copilot_for_Salesforce’
            Invocable.Action action = Invocable.Action.createCustomAction('generateAiAgentResponse', 'Copilot_for_Salesforce');

            // Set the input parameter 
            action.setInvocationParameter('userMessage', extractedText);

            // Execute the action
            List<Invocable.Action.Result> results = action.invoke();
            Invocable.Action.Result result = results[0];

            // Handle the response
            if (result.isSuccess()) {
                String agentResponse = (String) result.getOutputParameters().get('agentResponse');
                System.debug('Agent Summary Response: ' + agentResponse);
                return agentResponse;
            } else {
                System.debug('Agent invocation failed: ' + result.getErrors());
                return null;
            }
        } catch (Exception e) {
            System.debug('Error invoking agent: ' + e.getMessage());
            return null;
        }
    }
}