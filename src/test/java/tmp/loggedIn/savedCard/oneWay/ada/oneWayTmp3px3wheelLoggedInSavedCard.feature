Feature: Purchase a One Way 3 Passenger 3 Wheelchair ticket in TMP Dev/Stage/QA not logged in

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


  Scenario: A full purchase in TMP Dev
     * header Authorization = call read('classpath:basic-auth.js') { username: 'sbrooks+ppb1@tdstickets.com', password: 'test1234' }
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
     * def condition = function(x){ return x.stationName == 'Bourne' }
     * def temp = karate.filter(origins, condition)
     * def origin = temp[0].stopUuid
     * print origin

     Given path 'stop'
     And request { 'carrierId': 1, 'type': 'DESTINATION', 'originStopId': '#(origin)' }
     When method post
     Then status 200

     * def destinations = response
#     * print destinations
     * def condition = function(x){ return x.stationName == 'Boston (Logan Airport)' }
     * def temp = karate.filter(origins, condition)
     * def destination = temp[0].stopUuid
     * print destination

    Given path 'schedule'
    And request { 'carrierId': 1, 'origin': { 'stopUuid': '#(origin)' }, 'destination': { 'stopUuid': '#(destination)' }, 'departDate': '#(randomDepart)' }
    When method post
    Then status 200

    * def schedules = response
    * def selectedSchedule = randomSchedule(schedules)
    * print selectedSchedule
    * def scheduleUuid = selectedSchedule.scheduleUuid
    * def departDate = selectedSchedule.departTime.substring(0, selectedSchedule.departTime.lastIndexOf('T'))
    * print scheduleUuid
    * print departDate

     Given path 'passenger/ada/options/1'
     And request {}
     When method get
     Then status 200

     * def adaOptions = response
     * print adaOptions[0]
     * json ada = adaOptions[0]

     * def availabilityRequest =
         """
         {
          "adaOptions":
           "<adaOptions>"
          ,
          "outbound": {
             "carrierId": 1,
             "scheduleUuid": <scheduleUuid>,
             "departDate": <departDate>,
             "origin": {
                "stopUuid": "<origin>"
            },
          "destination": {
                "stopUuid": <destination>
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
            "Adult": 3
            }
         }
         """
     * set availabilityRequest.buyer.address1 = address1
     * set availabilityRequest.buyer.city = city
     * set availabilityRequest.buyer.state = state
     * set availabilityRequest.buyer.zip = zip
     * set availabilityRequest.adaOptions[0] = ada
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

     Given path 'customer/payment/stored'
     And request {}
     When method get
     Then status 200

     * def storedCards = response
     * print storedCards[0].storedPaymentId
     * def paymentId = storedCards[0].storedPaymentId

     * def passengerJson = function(i){ return { 'adaOptions': [ada], 'firstName': faker.name().firstName(), 'lastName': faker.name().lastName(), 'email': 'sbrooks@tdstickets.com', 'type': 'Adult', 'outboundFare': outboundFares }}
     * def passengers = karate.repeat(3, passengerJson)
     * print passengers

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
              "storedPaymentId": <paymentId>,
              "paymentMethod": "ONLINE",
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
     * replace bookRequest.paymentId = paymentId

     * print bookRequest

     Given path 'book'
     And request bookRequest
     When method post
     Then status 400

     * def book = response
     * print book


