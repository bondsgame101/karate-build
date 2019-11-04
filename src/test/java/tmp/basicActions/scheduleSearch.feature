Feature: Pulling Destination

  Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}
    * def getDate =
    """
    function(period) {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var Calendar = Java.type('java.util.Calendar');
      var sdf = new SimpleDateFormat('yyyy-MM-dd');
      var random_one = Math.floor(Math.random() * 10) + 2;
      var random_two = Math.floor(Math.random() * 10) + 12;
      cal = Calendar.getInstance();
      if (period == "tomorrow") {
        cal.add(Calendar.DATE, 1);
      }
       else if (period == "today") {
        cal.add(Calendar.DATE, 0);
      }
       else if (period == "week") {
        cal.add(Calendar.DATE, 7)
      } else if (period == "randDepart") {
        cal.add(Calendar.DATE, random_one)
      } else if (period == "randReturn") {
        cal.add(Calendar.DATE, random_two)
      }
      return sdf.format(cal.getTime());
    }
    """
    * def getRandomInt =
    """
    function(max) {
        return Math.floor(Math.random() * Math.floor(max));
    }
    """

    * def randomSchedule =
     """
     function(list) {
       var random = getRandomInt(list.length)
       return list[random]
     }
     """

    * def today = getDate("today")
    * def tomorrow = getDate("tomorrow")
    * def week = getDate("week")
    * def randomDepart = getDate("randDepart")
    * def randomReturn = getDate("randReturn")
    * def faker = new faker()
    * def firstName = faker.name().firstName()
    * def lastName = faker.name().lastName()
    * def zip = faker.address().zipCode()
    * def address1 = faker.address().streetAddress()
    * def city = faker.address().city()
    * def state = faker.address().stateAbbr()

    * def origin = call read('origin.feature')
    * def destination = call read('destination.feature')

  Scenario: A full purchase in TMP Dev
    Given path 'schedule'
    And request { 'carrierId': 1, 'origin': { 'stopUuid': '#(origin.origin)' }, 'destination': { 'stopUuid': '#(destination.destination)' }, 'departDate': '#(randomDepart)' }
    When method post
    Then status 200

    * def schedules = response
    * def selectedSchedule = randomSchedule(schedules)
    * print selectedSchedule
    * def scheduleUuid = selectedSchedule.scheduleUuid
    * print 'Your ScheduleUuid Is:', scheduleUuid
    * print 'Your Depart Date Is:', selectedSchedule.departTime