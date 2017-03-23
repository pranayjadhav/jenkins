/*
 * @ Created By : Anant Kumar
 * @ Created Date : 1 Mar 2016
 */
public class ReservableTriggerHandler {
    
    public void updateSpaceBasedOnSpaceUUID(List<Reservable__c> reservableNewList){
        Set<String> UUIDSet = new Set<String>();
        Set<String> spaceUUIDSet = new Set<String>();
        Set<String> spaceIDSet = new Set<String>();
        Set<String> spaceWithNoChangeIDSet = new Set<String>();
        for(Reservable__c reservable : reservableNewList){
            if(reservable.UUID__c != null && reservable.Space__c == null && reservable.Space_UUID__c == null)
                UUIDSet.add(reservable.UUID__c);
            else if(reservable.Space_UUID__c != null && reservable.Space__c == null)
                spaceUUIDSet.add(reservable.Space_UUID__c);
            else if(reservable.Space__c != null && reservable.Space_UUID__c == null)
                spaceIDSet.add(reservable.Space__c);
            else if(reservable.Space__c != null && reservable.Space_UUID__c != null)
                spaceWithNoChangeIDSet.add(reservable.Id);
        }
        Debug.log('Test : spaceUUIDSet ::: ' + spaceUUIDSet);
        Map<String, Reservable__c> reservableUUIDMap = new Map<String, Reservable__c>();
        Map<String, Reservable__c> reservableIDMap = new Map<String, Reservable__c>();
        Map<String, List<Reservable__c>> reservableSpaceIDMap = new Map<String, List<Reservable__c>>();
        if(spaceUUIDSet.size() > 0 || spaceIDSet.size() > 0 || UUIDSet.size() > 0)
        {
            String strQuery = 'SELECT Id, UUID__c, Space__c, Space_UUID__c FROM Reservable__c WHERE UUID__c in:'+spaceUUIDSet +'OR Id in:' +spaceIDSet +' OR Space_UUID__c in:'+ UUIDSet;
            Debug.log('Test : strQuery ::: ' + strQuery);
            for(Reservable__c reservable : [SELECT Id, UUID__c, Space__c, Space_UUID__c FROM Reservable__c WHERE UUID__c in:spaceUUIDSet OR Id in:spaceIDSet OR Space_UUID__c in:UUIDSet]){
                Debug.log('Test : reservable in 1st Iteration ::: ' + reservable);
                reservableUUIDMap.put(reservable.UUID__c, reservable);
                reservableIDMap.put(reservable.Id, reservable);
                if(reservable.Space_UUID__c != null){
                    List<Reservable__c> tempReservable = new List<Reservable__c>();
                    if(reservableSpaceIDMap.containsKey(reservable.Space_UUID__c))
                    	tempReservable = reservableSpaceIDMap.get(reservable.Space_UUID__c);
                    tempReservable.add(reservable);
                    reservableSpaceIDMap.put(reservable.Space_UUID__c, tempReservable);
                }
            }
        }
        Map<Id, Reservable__c> reservableToUpdateMap = new Map<Id, Reservable__c>();
        if(reservableIDMap.size() > 0){
            Debug.log('Test : reservableUUIDMap ::: ' + reservableUUIDMap);
            Debug.log('Test : reservableSpaceIDMap ::: ' + reservableSpaceIDMap);
            for(Reservable__c reservable : reservableNewList){
                Debug.log('Test : reservable ::: ' + reservable);
                Debug.log('Test : reservableSpaceIDMap.containsKey(reservable.UUID__c) ::: ' + reservableSpaceIDMap.containsKey(reservable.UUID__c));
                if(reservableSpaceIDMap.containsKey(reservable.UUID__c)){
                    for(Reservable__c reservableChild : reservableSpaceIDMap.get(reservable.UUID__c)){
                        Reservable__c reservableNew = new Reservable__c();
                        reservableNew.Id = reservableChild.Id;
                        reservableNew.Space__c = reservable.Id;
                        reservableToUpdateMap.put(reservableNew.Id, reservableNew);
                    }
                }
                else if(reservable.Space__c == null && reservable.Space_UUID__c == reservableUUIDMap.get(reservable.Space_UUID__c).UUID__c){
                    Reservable__c reservableNew = new Reservable__c();
                    reservableNew.Id = reservable.Id;
                    reservableNew.Space__c = reservableUUIDMap.get(reservable.Space_UUID__c).Id;
                    reservableToUpdateMap.put(reservableNew.Id, reservableNew);
                }
                else if(reservable.Space_UUID__c == null && reservableIDMap.get(reservable.Space__c).UUID__c != null){
                    Reservable__c reservableNew = new Reservable__c();
                    reservableNew.Id = reservable.Id;
                    reservableNew.Space_UUID__c = reservableIDMap.get(reservable.Space__c).UUID__c;
                    reservableToUpdateMap.put(reservableNew.Id, reservableNew);
                }
            }
        }
        try{
            if(reservableToUpdateMap.size() > 0)
            	update reservableToUpdateMap.values();
        }
        catch(DMLException ex){
            Debug.log('Exception Message ::: ' + ex.getMessage());
        }
    }
}