public with sharing class ANG_IdsWrapper {
	public Map<String, String> objectsIds;

	public ANG_IdsWrapper() {
		objectsIds = new Map<String, String>();
	}

	public void put(String key, String value) {
		objectsIds.put(key, value);
	}	
}