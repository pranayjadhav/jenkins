public with sharing class BuildingHandler {

	/**
	*	Returns the Building UUID from the associated won Opportunity of the given account ID
	**/
	public static String getBuildingUUIDByAccount(Id pAccountID) {
		String result;

		Set<String> stagesToSync = new Set<String>{
																			'Closed Won', 
																			'Contract Sent'
															};
		try {
			Opportunity o = [	SELECT Building__r.UUID__c 
												FROM Opportunity 
												WHERE 
													AccountID =: pAccountID AND
													 stageName IN :stagesToSync
												LIMIT 1
											];
			result = o.Building__r.UUID__c;
		}
		catch(Exception pEx) {
			result = null; //default value
		}
		
		return result;
	}

	public static String getMultipicklistValuesFromUUID(String[] pUUIDs) {
		String result;
		String[] values = new String[]{};
		Debug.log('Passed Ids : '+pUUIDs);
		//uuid -> name
		Map<String, String> uuid_to_name = new Map<String, String>();

		try {
			//collect buildings
			for(Building__c b : [	SELECT name, uuid__c
														FROM Building__c
													]) {
				uuid_to_name.put(b.uuid__c, b.name);
			}

			//select values
			for(String u : pUUIDs) {
				String v = uuid_to_name.get(u);
				if (v != null) values.add(v);
			}

			//separate values with semi-colon
			result = String.join(values, ';');
			Debug.log('Got result of Ids : '+result);
			//check if no matches
			if (values.size() == 0) result = null;

		}
		catch(Exception pEx) {
			result = null; //default value
			Debug.log(pEx.getMessage());
		}
		
		return result;
	}

	public static String[] getUUIDsFromMultipicklistValues(String pMultipicklistField) {
		String[] result = new String[]{};
		try {
			//code here
			Debug.log('pMultipicklistField :: '+pMultipicklistField );
			String[] Vs = Common.splitStringToList(pMultipicklistField, ';');

			for (Building__c b : [	SELECT uuid__c 
															FROM Building__c 
															WHERE name IN :Vs
													 ]) {
				result.add(b.uuid__c);
			}
		}
		catch(Exception pEx) {
			result = new String[]{}; //default value
		}
		
		return result;
	}

	public static Id getBuildingIdByUUID(String pUUID) {
		Id result;
		try {
			result = [SELECT id FROM Building__c WHERE uuid__c = :pUUID LIMIT 1].id;
		}
		catch(Exception pEx) {
			result = null; //default value
		}
		
		return result;
	}
}