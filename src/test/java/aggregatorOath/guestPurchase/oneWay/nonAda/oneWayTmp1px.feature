Feature: Purchase a One Way 1 Passenger ticket in TMP Dev/Stage/QA not logged in

  Background:
    * def oauth = call read('classpath:oauth2-auth.js') { grant_type: 'client_credentials', client_id: 'wanderu-carrier-ops', client_secret: 'c5cdefb8-7982-48ad-84cd-354c991b186f' }
    * print oauth
    * def token = oauth.response
    * def accessToken = token.accessToken

#    * url 'https://accounts.stage.tdstickets.com/auth/realms/qa/protocol/openid-connect/token'
#    * form field grant_type = 'client_credentials'
#    * form field client_id = 'wanderu-carrier-ops'
#    * form field client_secret = 'c5cdefb8-7982-48ad-84cd-354c991b186f'
#    * method post
#    * status 200
#
#    * def accessToken = response.access_token
    * print accessToken

    * url 'https://api.qa.tdstickets.com/thirdparty/ticketing'
    * configure headers = { TDS-Carrier-Code: 'PPB', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa

    * def getDate = read('classpath:get-date.js')

#    * def getDate =
#    """
#    function(period) {
#      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
#      var Calendar = Java.type('java.util.Calendar');
#      var sdf = new SimpleDateFormat('yyyy-MM-dd');
#      var random_one = Math.floor(Math.random() * 10) + 2;
#      var random_two = Math.floor(Math.random() * 10) + 12;
#      cal = Calendar.getInstance();
#      if (period == "tomorrow") {
#        cal.add(Calendar.DATE, 1);
#      }
#       else if (period == "today") {
#        cal.add(Calendar.DATE, 0);
#      }
#       else if (period == "week") {
#        cal.add(Calendar.DATE, 7)
#      } else if (period == "randDepart") {
#        cal.add(Calendar.DATE, random_one)
#      } else if (period == "randReturn") {
#        cal.add(Calendar.DATE, random_two)
#      }
#      return sdf.format(cal.getTime());
#    }
#    """
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

     Given path 'stop'
     And request { 'carrierId': 1, 'type': 'ORIGIN' }
     When method post
     Then status 200

     * def origins = response
#     * print origins
     * def condition = function(x){ return x.stationName == 'Boston (South Station)' }
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
             "accountNumber": "5123456789012346",
             "securityCode": "123",
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

#     Given url 'https://upg.dev.tdstickets.com/tokenizer/v1/generate/card'
#     Given url 'https://upg.stage.tdstickets.com/tokenizer/v1/generate/card'
     Given url 'https://upg.qa.tdstickets.com/tokenizer/v1/generate/card'
     And request upg
     When method post
     Then status 200
     * def token = response.token
     * print token

     Given url 'https://api.qa.tdstickets.com/thirdparty/ticketing'

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
              "createProfile": true
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


