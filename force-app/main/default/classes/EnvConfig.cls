public class EnvConfig {
    public static String get(String key) {
        Environment_Variable__mdt setting = [
            SELECT Value__c 
            FROM Environment_Variable__mdt 
            WHERE DeveloperName = :key 
            LIMIT 1
        ];
       System.debug('endpoint URL>>> ' +setting.Value__c);
        return setting.Value__c;
    }
}