public with sharing class AMS_OSCAR_AutomationManager {
	public AMS_OSCAR_AutomationManager(){}

	// Return the appropriate class instance based on className
	public AMS_OSCAR_Automation.IClassFactory newClassInstance(String className)
	{
		System.debug('DNG! className:' + className);
		Type t = Type.forName(className);
		return (AMS_OSCAR_Automation.IClassFactory) t.newInstance();
	}
}
