Feature: Purchase a One Way ticket in Webstore Stage logged in

Background:
  * url 'https://api.dev.tdstickets.com/webstore/'
#  * url 'https://api2.stage.tdstickets.com/webstore/'
#  * url 'https://api.qa.tdstickets.com/webstore/'
#  * url 'https://api.trailwaysny.com/webstore/'
  * configure headers = { 'x-agency-id': 'fb813bbec72711e4b70bcd1b6ee070a1', 'Content-Type': 'application/json'} Dev/Stage
#  * configure headers = { 'x-agency-id': 'c6ebc417d3ec11e4b6f757d6b72f2478', 'Content-Type': 'application/json'}
#  * configure headers = { 'x-agency-id': '17cc512e2b6411e8a467abe441b24777', 'Content-Type': 'application/json'}
#    * configure headers = { 'x-agency-id': '7c15f5050e0f11e58956b71fbc4c05e7', 'Content-Type': 'application/json'} Prod
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
  * def today = getDate("today")



Scenario: Oneway Purchase
  * header Authorization = call read('basic-auth.js') { username: 'sbrooks@tdstickets.com', password: 'test1234' }
  Given path 'v1/user/login'
  And request {}
  When method post
  Then status 200

  Given path 'v1/stop/4249'
  * params { country: 'US', city: 'One', state: 'NY'}
  When method get
  Then status 200

  * def stops = response
#  * print 'The Stops Are:', stops
  * def condition = function(x){ return x.code == 151338 }
  * def origin = karate.filter(stops, condition)
  * print 'Your Origin Is:', origin


  Given path 'v1/stop/4249'
  * params { country: 'US', city: 'New Y', state: 'NY'}
  When method get
  Then status 200

  * def stops = response
#  * print 'The Stops Are:', stops
  * def condition = function(x){ return x.code == 151239 }
  * def destination = karate.filter(stops, condition)
  * print 'Your Destination Is:', destination[0]

  Given path 'v1/search/4249'
  And request { adults: 1, seniors: 0, children: 0, departDate: '#(tomorrow)', destination: #(destination[0]), origin: #(origin[0]) }
  When method post
  Then status 201

  * def location = responseHeaders['Location'][0].substring(responseHeaders['Location'][0].lastIndexOf('webstore/') + 9)
#  * print location

  Given path location
  When method get
  Then status 200

  * def schedule = response
#  * print schedule
  * def outboundSchedules = get schedule.outboundSchedules
#  * print outboundSchedule
  * def fareSearch =
    """
    function(x) {
      return x.fares.flexFare != null;
    }
    """
  * def scheduleResults = karate.filter(outboundSchedules, fareSearch)
#  * print schedulesResults
  * def departKey = scheduleResults[0].key
  * def departFareKey = scheduleResults[0].fares.flexFare.key
#  * print departKey
#  * print departFareKey

  Given path 'v1/detail/4249'
  And request { adults: 1, seniors: 0, children: 0, departDate: '#(tomorrow)', destination: #(destination[0]), origin: #(origin[0]), departKey: #(departKey), departFareKey: #(departFareKey) }
  When method post
  Then status 201

  * def detailLocation = responseHeaders['Location'][0].substring(responseHeaders['Location'][0].lastIndexOf('webstore') + 9)
#  * print detailLocation

  Given path detailLocation
  When method get
  Then status 200

  * def detail = response
#  * print detail
  * def amount = detail.total
#  * print total
  * def upg =
    """
    {
    "agency" : {
    "gateway": "CARDCONNECT",
    "agency": "4249",
    "country": "US"
    },
    "accountNumber": "5123456789012346",
    "securityCode": "123",
    "expirationMonth": "05",
    "expirationYear": "21",
    "nameOnCard": "Steven Brooks",
    "address1": "9310 Old Kings Rd",
    "address2": "",
    "city": "Jacksonville",
    "state": "FL",
    "postalCode": "32257",
    "country": "US",
    "phone": "4084898120",
    "email": "sbrooks@tdstickets.com",
    "ipAddress": "127.0.0.1",
    "fraudAlgorithm": ""
    }
    """

  Given url 'https://upg.dev.tdstickets.com/tokenizer/v1/generate/card'
#  Given url 'https://upg.stage.tdstickets.com/tokenizer/v1/generate/card'
#  Given url 'https://upg.qa.tdstickets.com/tokenizer/v1/generate/card'
#  Given url 'https://upg.tdstickets.com/tokenizer/v1/generate/card'
  And request upg
  When method post
  Then status 200
  * def token = response.token
#  * print token

  Given url 'https://api.dev.tdstickets.com/webstore/'
#  Given url 'https://api2.stage.tdstickets.com/webstore/'
#  Given url 'https://api.qa.tdstickets.com/webstore/'
#  Given url 'https://api.trailwaysny.com/webstore/'

  * def bookRequest =
    """
    {
      "buyer": {
        "address1"		: "9310 Old Kings Rd",
        "city"			: "Jacksonville",
        "country"		: "US",
        "firstName"		: "Kyle",
        "lastName"		: "Kerlew",
        "phone1"		: "5554458556",
        "postalCode"	: "32225",
        "state"			: "FL"
      },
      "emailAddress"		: "aking@tdstickets.com",
      "phoneNumber"			: "5554458556",
      "loyaltyAmount"		: null,
      "cardHolderTraveling"	: true,
      "departDate"			: "<departDate>",
      "departFareKey"		: "<departFareKey>",
      "departKey"			: "<departKey>",
      "destination": {
        "stopId"		: "<destination>"
      },
      "origin": {
        "stopId"		: "<origin>"
      },
      "passengers": [
        {
          "ada"			: false,
          "bags"		: 0,
          "firstName"	: "D",
          "lastName"	: "One",
          "type"		: "ADULT",
          "specialNeed" : "SIGHT_IMPAIRED"
        }
      ],
      "payment": {
        "accountNumber"		: "5123456789012346",
        "amount"			: "<amount>",
        "country"			: "US",
        "createProfile"		: false,
        "expirationMonth"	: "05",
        "expirationYear"	: "21",
        "paymentType"		: "CC",
        "token"				: "<token>"
      }
    }
    """


  * replace bookRequest.departDate = tomorrow
  * replace bookRequest.departFareKey = departFareKey
  * replace bookRequest.departKey = departKey
  * replace bookRequest.destination = get destination[0].stopId
  * replace bookRequest.origin = get origin[0].stopId
  * replace bookRequest.amount = amount
  * replace bookRequest.token = token
#  * print 'Your booking request is:', bookRequest

  Given path 'v1/book/4249'
  And request bookRequest
  When method post
  Then status 201

  * def bookLocation = responseHeaders['Location'][0].substring(responseHeaders['Location'][0].lastIndexOf('webstore') + 9)

  Given path bookLocation
  When method get
  Then status 200

  * print response


