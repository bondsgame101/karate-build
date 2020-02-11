Feature: Pulling Trip Availability

  Background:
    * def scheduleSearch = call read('scheduleSearch.feature')
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}
    * def getDate = read('classpath:get-date.js')
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

#    * def origin = call read('origin.feature')
#    * def destination = call read('destination.feature')
#    * def scheduleSearch = call read('scheduleSearch.feature')

  Scenario: A full trip availability call
    * def scheduleUuid = scheduleSearch.selectedSchedule.scheduleUuid
    * def departDate = scheduleSearch.selectedSchedule.travelDate
    * def origin = scheduleSearch.selectedSchedule.origin
    * def destination = scheduleSearch.selectedSchedule.destination
    * print 'Your Selected Schedule is:', scheduleSearch.selectedSchedule
    * print 'Your ScheduleUuid is:', scheduleUuid
    * print 'Your DepartDate is:', departDate
    * print 'Your Origin is:', origin
    * print 'Your Destination is:', destination
    * def availabilityRequest =
         """
         {
          "outbound": {
             "carrierId": 1,
             "scheduleUuid": "#(scheduleUuid)",
             "departDate": "#(departDate)",
             "origin": "#(origin)",
             "destination": "#(destination)",
             "occurrence": 1
            },
          "buyer": {
            "firstName": "Patrick",
            "lastName": "Locey",
            "email": "plocey@tdstickets.com",
            "phone": "(201) 543-9867",
            "mobile": "(908) 789-1234"
          },
          "passengerCounts": {
            "Adult": 1
            }
         }
         """

    * set availabilityRequest.buyer.address1 = address1
    * set availabilityRequest.buyer.city = city
    * set availabilityRequest.buyer.state = state
    * set availabilityRequest.buyer.zip = zip
#    * replace availabilityRequest.departDate = departDate
#    * replace availabilityRequest.destination = destination
#    * replace availabilityRequest.origin = origin
#    * replace availabilityRequest.scheduleUuid = scheduleUuid

    * print availabilityRequest

    Given path 'availability'
    And request availabilityRequest
    When method post
    Then status 200

    * def availability = response
    * print availability
#     * print availability.outboundFares.Adult[0]
    * def outboundFares = availability.outboundFares.Adult[0]
    * print outboundFares
    * def total = availability.total