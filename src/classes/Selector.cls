public abstract with sharing class Selector
{

	abstract List<Schema.SObjectField> getSObjectFieldList();
	abstract Schema.SObjectType getSObjectType();

	public Set<String> IdToString(Set<Id> ids)
	{
		Set<String> ret = new Set<String>();

		for(Id i: ids)
			ret.add((String)i);

		return ret;
	}

	public String SetToString(Set<String> ids)
	{
		return  '\'' + String.join(new List<String>(ids), '\' , \'') + '\'';
	}

	public List<String> getDefaultFields()
	{
		List<String> ret = new  List<String>();
		for(Schema.SObjectField f : getSObjectFieldList())
		{
			ret.add(f.getDescribe().getName());
		}

		return ret;
	}

	public List<SObject> selectSObjectByField(String field, Set<String> idSet)
	{
		return selectSObjectByField(field,idSet,getDefaultFields());
	}

	public List<SObject> selectSObjectByField(String field, Set<String> idSet, List<String> fields)
	{
		List<SObject> results = new List<SObject>();

		if(!idSet.isEmpty())
		{

			if(String.isBlank(field))
			{
				field = 'Id'; //Default fields to query from
			}

			if(fields.isEmpty())
			{
				fields = getDefaultFields();
			}

			String idSetString = SetToString(idSet);


			String query = String.format('SELECT {0}  FROM {1} WHERE {2} IN :idSet ',
				new List<String>{
					String.join(fields, ', '),
					getSObjectType().getDescribe().getName(),
					field
				}
			);

			//System.debug('query::'+query);
			results = Database.query(query);
		}

		return results;
	}

	public List<SObject> selectSObjectById(Set<Id> idSet)
	{
		return selectSObjectByField('Id', IdToString(idSet), getDefaultFields());
	}

	public List<SObject> selectSObjectById(Set<Id> idSet, List<String> fields)
	{
		return selectSObjectByField('Id', IdToString(idSet), fields);
	}
}
