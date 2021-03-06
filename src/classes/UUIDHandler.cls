/*
Version 4 (random)[edit]

Version 4 UUIDs use a scheme relying only on random numbers. This algorithm sets the version number 
as well as two reserved bits. All other bits (the remaining 122 bits) are set using a random or 
pseudorandom data source. Version 4 UUIDs have the form xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx 
where x is any hexadecimal digit and y is one of 8, 9, A, or B (e.g., f47ac10b-58cc-4372-a567-0e02b2c3d479).

*/
/**
* @Merge By		Mayuresh Ghodke 
* @New Class	AccountTriggerHandler
* @Date			05/07/2016
*/
public with sharing class UUIDHandler {
	
	private static String[] hex_X = new String[] {
		'a', 'b', 'c', 'd', 'e', 'f', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' 
	};

	private static String[] hex_Y = new String[] {
		'a', 'b', '8', '9' 
	};

	//should return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	public static String generateVersion4() {
		long timetick = Datetime.now().getTime();
		string uniqueId;
		String hexTimeTick = EncodingUtil.convertToHex(Blob.valueOf(''+timetick))+''+EncodingUtil.convertToHex(Blob.valueOf(''+timetick));
		uniqueId = hexTimeTick.substring(0, 8) + '-' + hexTimeTick.substring(8, 12) + '-4' + hexTimeTick.substring(12, 15) + '-'+ UUIDHandler.getRandomStringFromCollection(hex_Y) +''+ hexTimeTick.substring(15, 18) + '-' +hexTimeTick.substring(18, 30);
		return uniqueId;
	}

	public static String getRandomStringFromCollection(String[] pCollection) {
		return pCollection.get( 
			getRandomInt(0, pCollection.size() - 1)
		);
	}
	
	/**
	 * Gets a random integer number between lower (inclusive) and upper (exclusive)
	 */
	private static Integer getRandomInt (Integer pLower, Integer pUpper) {
		return Math.round((Math.random() * (pUpper - pLower)) + pLower);
	}
	
}