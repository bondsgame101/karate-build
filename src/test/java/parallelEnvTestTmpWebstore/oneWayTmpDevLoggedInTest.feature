Feature: Purchase a One Way 1 Passenger ticket in TMP Dev logged in

  Background:
    * url 'https://api.dev.tdstickets.com/ticketing/'
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'} dev/stage
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

  Scenario: A full purchase in TMP Dev
    * header Authorization = call read('basic-auth.js') { username: 'sbrooks+ppb2@tdstickets.com', password: 'test1234' } dev/stage
    Given path 'user/login'
    And request {}
    When method post
    Then status 200

    Given path 'stop'
    And request { 'carrierId': 1, 'type': 'ORIGIN' }
    When method post
    Then status 200

    * def origins = response
#     * print origins
    * def condition = function(x){ return x.stationName == 'Amherst UMass' }
    * def temp = karate.filter(origins, condition)
    * def origin = temp[0].stopUuid
    * print origin

    Given path 'stop'
    And request { 'carrierId': 1, 'type': 'DESTINATION', 'originStopId': '#(origin)' }
    When method post
    Then status 200

    * def destinations = response
#     * print destinations
    * def condition = function(x){ return x.stationName == 'Woods Hole' }
    * def temp = karate.filter(origins, condition)
    * def destination = temp[0].stopUuid
    * print destination

    Given path 'schedule'
    And request { 'carrierId': 1, 'origin': { 'stopUuid': '#(origin)' }, 'destination': { 'stopUuid': '#(destination)' }, 'departDate': '#(tomorrow)' }
    When method post
    Then status 200

    * def schedules = response
#     * print schedules[0]
    * def scheduleUuid = schedules[0].scheduleUuid
    * def departDate = schedules[0].departTime.substring(0, schedules[0].departTime.lastIndexOf('T'))
#     * def departDate = schedules[0].departTime
    * print scheduleUuid
    * print departDate

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

    * def upg =
          """
          {
           "agency" :
           {
               "gateway": "AUTHORIZE",
               "agency": "4249",
               "country": "US"
           },
             "accountNumber": "4111111111111111",
             "securityCode": "000",
             "expirationMonth": "05",
             "expirationYear": "21",
             "nameOnCard": "#(faker.name().fullName())",
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

    Given url 'https://upg.dev.tdstickets.com/tokenizer/v1/generate/card'
    And request upg
    When method post
    Then status 200
    * def token = response.token
    * print token

    Given url 'https://api.dev.tdstickets.com/ticketing/'

    * def passengerJson = function(i){ return { 'firstName': faker.name().firstName(), 'lastName': faker.name().lastName(), 'email': 'sbrooks@tdstickets.com', 'type': 'Adult', 'outboundFare': outboundFares }}
    * def passengers = karate.repeat(1, passengerJson)

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
            "buyer": {
              "firstName": "#(faker.name().firstName())",
              "lastName": "#(faker.name().lastName())",
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
              "expirationMonth": 05,
              "expirationYear": 21,
              "createProfile": false
            },
            "sendConfirmationEmail": true
          }
          """

    * set bookRequest.buyer.address1 = address1
    * set bookRequest.buyer.city = city
    * set bookRequest.buyer.state = state
    * set bookRequest.buyer.zip = zip
    * set bookRequest.passengers = passengers
    * replace bookRequest.departDate = departDate
    * replace bookRequest.scheduleUuid = scheduleUuid
    * replace bookRequest.destination = destination
    * replace bookRequest.origin = origin
    * replace bookRequest.total = total
    * replace bookRequest.token = token

    Given path 'book'
    And request bookRequest
    When method post
    Then status 200

    * def book = response
    * print book


