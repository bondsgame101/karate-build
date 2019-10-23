Feature: Purchase a Round Trip 1 Passenger ticket in TMP Dev/Stage/QA not logged in

  Background:
#    * url 'https://api.dev.tdstickets.com/ticketing/'
#    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
#    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'} dev/stage
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'} qa
    * def getDate =
    """
    function(period) {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var Calendar = Java.type('java.util.Calendar');
      var sdf = new SimpleDateFormat('yyyy-MM-dd');
      cal = Calendar.getInstance();
      if (period == "tomorrow") {
        cal.add(Calendar.DATE, 1);
      }
       else if (period == "today") {
        cal.add(Calendar.DATE, 0);
      }
       else {
        cal.add(Calendar.DATE, 7)
      }
      return sdf.format(cal.getTime());
    }
    """
    * def tomorrow = getDate("tomorrow")
    * def week = getDate("week")
    * def faker = new faker()
    * def firstName = faker.name().firstName()
    * def lastName = faker.name().lastName()
    * def zip = faker.address().zipCode()
    * def address1 = faker.address().streetAddress()
    * def city = faker.address().city()
    * def state = faker.address().stateAbbr()

  Scenario: A full purchase in TMP Dev
#    * header Authorization = call read('basic-auth.js') { username: 'sbrooks+ppb@tdstickets.com', password: 'test1234' }
    * header Authorization = call read('classpath:basic-auth.js') { username: 'sbrooks+ppb1@tdstickets.com', password: 'test1234' }
    Given path 'user/login'
    And request {}
    When method post
    Then status 200

    Given path 'customer/detail'
    When method get
    Then status 200
    Given path 'stop'
    And request { 'carrierId': 1, 'type': 'ORIGIN' }
    When method post
    Then status 200

    * def origins = response
#     * print origins
    * def condition = function(x){ return x.stationName == 'Amherst Center' }
    * def temp = karate.filter(origins, condition)
    * def origin = temp[0].stopUuid
    * print origin

    Given path 'stop'
    And request { 'carrierId': 1, 'type': 'DESTINATION', 'originStopId': '#(origin)' }
    When method post
    Then status 200

    * def destinations = response
#     * print destinations
    * def condition = function(x){ return x.stationName == 'Boston (South Station)' }
    * def temp = karate.filter(origins, condition)
    * def destination = temp[0].stopUuid
    * print destination

    Given path 'schedule'
    And request { 'carrierId': 1, 'origin': { 'stopUuid': '#(origin)' }, 'destination': { 'stopUuid': '#(destination)' }, 'departDate': '#(tomorrow)' }
    When method post
    Then status 200

    * def schedules = response
    * def scheduleUuid = schedules[0].scheduleUuid
    * def departDate = schedules[0].departTime.substring(0, schedules[0].departTime.lastIndexOf('T'))
    * print scheduleUuid
    * print departDate

    Given path 'schedule'
    And request { 'carrierId': 1, 'origin': { 'stopUuid': '#(destination)' }, 'destination': { 'stopUuid': '#(origin)' }, 'departDate': '#(week)' }
    When method post
    Then status 200

    * def returnSchedules = response
#     * print schedules[0]
    * def returnScheduleUuid = returnSchedules[0].scheduleUuid
    * def returnDepartDate = returnSchedules[0].departTime.substring(0, schedules[0].departTime.lastIndexOf('T'))
    * print returnScheduleUuid
    * print returnDepartDate

    * def availabilityRequest =
         """
         {
          "outbound": {
             "carrierId": 1,
             "scheduleUuid": "<scheduleUuid>",
             "departDate": "<departDate>",
             "origin": {
                "stopUuid": "<origin>"
             },
             "destination": {
                "stopUuid": "<destination>"
             },
              "occurrence": 1
          },
          "returning": {
             "carrierId": 1,
             "scheduleUuid": "<returnScheduleUuid>",,
             "departDate": "<returnDepartDate>",
             "origin": {
               "stopUuid": "<returnOrigin>"
             },
             "occurrence": 1,
             "destination": {
               "stopUuid": "<returnDestination>"
             }
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
    * replace availabilityRequest.departDate = departDate
    * replace availabilityRequest.destination = destination
    * replace availabilityRequest.origin = origin
    * replace availabilityRequest.scheduleUuid = scheduleUuid
    * replace availabilityRequest.returnDepartDate = returnDepartDate
    * replace availabilityRequest.returnDestination = origin
    * replace availabilityRequest.returnOrigin = destination
    * replace availabilityRequest.returnScheduleUuid = returnScheduleUuid

    * print availabilityRequest

    Given path 'availability'
    And request availabilityRequest
    When method post
    Then status 200

    * def availability = response
    * print availability
#     * print availability.outboundFares.Adult[0]
    * def outboundFares = availability.outboundFares.Adult[0]
    * def returnFares = availability.returnFares.Adult[0]
    * print outboundFares
    * print returnFares
#     * print availability.total
    * def total = availability.total

    * def upg =
          """
          {
           "agency" :
           {
               "gateway": "AUTHORIZE",
               "agency": "4249",
               "country": "US"
           },
             "accountNumber": "5123456789012346",
             "securityCode": "123",
             "expirationMonth": "05",
             "expirationYear": "21",
             "nameOnCard": "Steven Brooks",
             "address1": "9310 Old Kings Rd., Ste 401",
             "address2": "",
             "city": "Jacksonville",
             "state": "FL",
             "postalCode": "32257",
             "country": "US",
             "phone": "5555546855",
             "email": "sbrooks@tdstickets.com",
             "ipAddress": "127.0.0.1",
             "fraudAlgorithm": ""
          }
          """

#     Given url 'https://upg.dev.tdstickets.com/tokenizer/v1/generate/card'
#     Given url 'https://upg.stage.tdstickets.com/tokenizer/v1/generate/card'
    Given url 'https://upg.qa.tdstickets.com/tokenizer/v1/generate/card'
    And request upg
    When method post
    Then status 200
    * def token = response.token
    * print token

    * def regPassengerJson = function(i){ return { 'firstName': faker.name().firstName(), 'lastName': faker.name().lastName(), 'email': 'sbrooks@tdstickets.com', 'type': 'Adult', 'outboundFare': outboundFares, 'returnFare': returnFares }}
    * def regPassengers = karate.repeat(1, regPassengerJson)

    * def bookRequest =
          """
          {
            "outbound": {
               "carrierId": 1,
               "scheduleUuid": "<scheduleUuid>",
               "departDate": "<departDate>",
               "origin": {
                  "stopUuid": "<origin>"
               },
                "destination": {
                  "stopUuid": "<destination>"
                },
                "occurrence": 1
            },
            "returning": {
               "carrierId": 1,
               "scheduleUuid": "<returnScheduleUuid>",
               "departDate": "<returnDepartDate>",
               "origin": {
                  "stopUuid": "<returnOrigin>"
               },
                "destination": {
                  "stopUuid": "<returnDestination>"
                },
                "occurrence": 1
            },
            "buyer": {
              "firstName": "Patrick",
              "lastName": "Locey",
              "email": "sbrooks@tdstickets.com",
              "phone": "(201) 543-9867",
              "mobile": "(908) 789-1234"
            },
            "passengers": [],
            "paymentInfo": {
              "country": "US",
              "amount": <total>,
              "token": "<token>",
              "transactionDate": 1559585242396,
              "paymentMethod": "ONLINE",
              "createProfile": true
            },
            "sendConfirmationEmail": true
          }
          """

    * set bookRequest.buyer.address1 = address1
    * set bookRequest.buyer.city = city
    * set bookRequest.buyer.state = state
    * set bookRequest.buyer.zip = zip
    * set bookRequest.passengers = regPassengers
    * replace bookRequest.departDate = departDate
    * replace bookRequest.scheduleUuid = scheduleUuid
    * replace bookRequest.origin = origin
    * replace bookRequest.destination = destination
    * replace bookRequest.returnDepartDate = returnDepartDate
    * replace bookRequest.returnDestination = origin
    * replace bookRequest.returnOrigin = destination
    * replace bookRequest.returnScheduleUuid = returnScheduleUuid
    * replace bookRequest.total = total
    * replace bookRequest.token = token

    * print bookRequest


#     Given url 'https://api.dev.tdstickets.com/ticketing/'
#     Given url 'https://api2.stage.tdstickets.com/ticketing/'
    Given url 'https://api.qa.tdstickets.com/ticketing/book'
    And request bookRequest
    When method post
    Then status 200

    * def book = response
    * print book


