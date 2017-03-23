/* Created by @dipak.pawar@enzigma.in on 12 May 2016
* This class should contain all the methods related to Date
*/

public class DateUtilities {	
	
	/*
   Comment   : This method used for check the day is weekend or not.
   Issue     : 
   Author    : Dipak Pawar 
   Date      : 13 May 2016 */
	public static Boolean isWeekendDay (Date dateParam) 
	{
      try 
      {
      	boolean result    = false;
	    Date startOfWeek  = dateParam.toStartOfWeek();
	    integer dayOfWeek = dateParam.day() - startOfWeek.day();
	    result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
	    return result;
      }
      catch(Exception ex) 
      {
      	Debug.log(ex.getMessage());
      	return null;
      }      
   }
   
   /*
   Comment   : This method used for check the day of week.
   Issue     : 
   Author    : Dipak Pawar 
   Date      : 17 May 2016 */
	public static Integer dayOfWeek(Date dateParam) 
	{
        try 
        {
        	Integer day = 0;
	        Date startOfWeek  = dateParam.toStartOfWeek();
			day = dateParam.day() - startOfWeek.day();
	        return day;
        }
        catch (Exception ex) 
        {
        	Debug.log(ex.getMessage());
        	return null;
        }
    }
	
	/*
   Comment   : This method used for add business days into date provided as givenDate.
   Issue     : ST-293
   Author    : Dipak Pawar 
   Date      : 13 May 2016 */
	public static Date addBusinessDays (Date givenDate, Integer daysToAdd) 
	{
		try 
		{
			if (daysToAdd < 0) 
			{
        		Debug.log('days cannot be negative');
    		}
    		
    		if (daysToAdd == 0) 
    		{
        		return givenDate;
    		}
    		
    		Integer dayOfWeek = dayOfWeek(givenDate);
    		        
    		if (dayOfWeek == 6)	
    		{
        		givenDate = givenDate.addDays(2);
        		daysToAdd -= 1;
    		}
		    else if (dayOfWeek == 0)
		    {
		        givenDate = givenDate.addDays(1);
		        daysToAdd -= 1;
		    }
		    
		    givenDate = givenDate.addDays(daysToAdd / 5 * 7);		       
		    Integer extraDays = Math.mod(daysToAdd , 5);
		    		
		    if (Integer.valueOf(dayOfWeek(givenDate) + extraDays) > 5) 
		    {
		        extraDays += 2;
		    }
    		return givenDate.addDays(extraDays);
		}
		catch (Exception ex) 
		{
				Debug.log(ex.getMessage());
				return null;
		}
	}
	
    /*
   Comment   : This method used for find next business days from date provided as givenDate.
   Issue     : ST-294
   Author    : Dipak Pawar 
   Date      : 13 May 2016 */
	public static Date getNextBusinessDay (Date givenDate) 
	{
		try 
		{
			Date getNextBusinessDate;
			//if given day is weekend day then returns the same date.
			if(isWeekendDay(givenDate)) 
			{	
                Debug.log('givenDate ::'+givenDate);
				getNextBusinessDate = givenDate;
			}
			//if given day is business day then returns the next business day.
			else 
			{
                getNextBusinessDate = addBusinessDays (givenDate, 1);
			}
			return getNextBusinessDate;
		}
		catch (Exception ex) 
		{
			Debug.log(ex.getMessage());
			return null;
		}
	}
}