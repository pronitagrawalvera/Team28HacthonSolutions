public with sharing class CSVToListAction {
    
    public class InputWrapper {
        @InvocableVariable(required=true)
        public String csvValues;
    }

    public class OutputWrapper {
        @InvocableVariable
        public List<String> values;
    }

    @InvocableMethod(label='Split CSV to List' description='Splits a comma-separated string into a list of strings')
    public static List<OutputWrapper> splitCSV(List<InputWrapper> requests) {
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper req : requests) {
            OutputWrapper result = new OutputWrapper();
            if (String.isNotBlank(req.csvValues)) {
                result.values = new List<String>();
                for (String item : req.csvValues.split(',')) {
                    result.values.add(item.trim());
                }
            } else {
                result.values = new List<String>();
            }
            results.add(result);
        }

        return results;
    }
}