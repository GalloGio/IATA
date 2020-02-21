@isTest
private class AMS_OSCAR_JSON_Test {

	static testMethod void Object() {
		//test for class AMS_OSCAR_JSON
		AMS_OSCAR_JSON json = new AMS_OSCAR_JSON();
		json.processes = new List<AMS_OSCAR_JSON.Process>();

		AMS_OSCAR_JSON.Action action = new AMS_OSCAR_JSON.Action();
		action.actionLabel = '';
		action.functionName = '';
		action.args = new List<String>();

		AMS_OSCAR_JSON.ChangeCode changecode = new AMS_OSCAR_JSON.ChangeCode();
		changecode.memoText = '';
		changecode.name = '';
		changecode.reasonCode = '';
		changecode.reasonDesc = '';
		changecode.status = '';

		AMS_OSCAR_JSON.Automation automation = new AMS_OSCAR_JSON.Automation();
		automation.changeCode = changecode;
		automation.className = '';
		automation.status = '';

		AMS_OSCAR_JSON.Flow flow = new AMS_OSCAR_JSON.Flow();
		flow.name = '';
		flow.steps = new List<AMS_OSCAR_JSON.Step>();

		AMS_OSCAR_JSON.Process process = new AMS_OSCAR_JSON.Process();
		process.name = '';
		process.flows = new List<AMS_OSCAR_JSON.Flow>();

		AMS_OSCAR_JSON.Step step = new AMS_OSCAR_JSON.Step();
		step.name = '';
		step.label = '';
		step.required = new List<String>();
		step.actions = new List<AMS_OSCAR_JSON.Action>();
		step.automations = new List<AMS_OSCAR_JSON.Automation>();
		step.displayFields = new List<String>();
		step.isDependent = false;
	}

}
