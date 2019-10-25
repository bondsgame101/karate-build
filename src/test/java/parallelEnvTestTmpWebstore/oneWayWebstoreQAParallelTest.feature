Feature: Purchase a One Way ticket in Webstore Stage not logged in

Background:
  * url 'https://api.qa.tdstickets.com/webstore/'
  * configure headers = { 'x-agency-id': 'c6ebc417d3ec11e4b6f757d6b72f2478', 'Content-Type': 'application/json'}
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



Scenario: One Way Purchase
  Given path 'v1/stop/4249'
  * params { country: 'US', city: 'Alb', state: 'NY'}
  When method get
  Then status 200

  * def stops = response
#  * print 'The Stops Are:', stops
  * def condition = function(x){ return x.code == 150051 }
  * def origin = karate.filter(stops, condition)
  * print 'Your Origin Is:', origin


  Given path 'v1/stop/4249'
  * params { country: 'US', city: 'New', state: 'NY'}
  When method get
  Then status 200

  * def stops = response
#  * print 'The Stops Are:', stops
  * def condition = function(x){ return x.code == 151239 }
  * def destination = karate.filter(stops, condition)
  * print 'Your Destination Is:', destination[0]

  Given path 'v1/search/4249'
  And request { adults: 4, seniors: 0, children: 0, departDate: '#(tomorrow)', destination: #(destination[0]), origin: #(origin[0]) }
  When method post
  Then status 201

  * def location = responseHeaders['Location'][0]
#  * print location

  Given url location
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
  * def departFareKey = scheduleResults[0].fares.saverFare.key
#  * print departKey
#  * print departFareKey
  * url 'https://api.qa.tdstickets.com/webstore/'

  Given path 'v1/detail/4249'
  And request { adults: 4, seniors: 0, children: 0, departDate: '#(tomorrow)', destination: #(destination[0]), origin: #(origin[0]), departKey: #(departKey), departFareKey: #(departFareKey) }
  When method post
  Then status 201

  * def detailLocation = responseHeaders['Location'][0]
#  * print detailLocation

  Given url detailLocation
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
    "securityCode": "000",
    "expirationMonth": "05",
    "expirationYear": "21",
    "nameOnCard": "#(faker.name().fullName())",
    "address1": "3265 Woodmont Drive",
    "address2": "",
    "city": "San Jose",
    "state": "CA",
    "postalCode": "95118",
    "country": "US",
    "phone": "4084898120",
    "email": "aeldridge@tdstickets.com",
    "ipAddress": "127.0.0.1",
    "fraudAlgorithm": ""
    }
    """

  Given url 'https://upg.qa.tdstickets.com/tokenizer/v1/generate/card'
  And request upg
  When method post
  Then status 200
  * def token = response.token
#  * print token

  Given url 'https://api.qa.tdstickets.com/webstore/'

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
          "firstName"	: "#(faker.name().firstName())",
          "lastName"	: "#(faker.name().lastName())",
          "type"		: "ADULT"
        },
        {
          "ada"			: false,
          "bags"		: 0,
          "firstName"	: "#(faker.name().firstName())",
          "lastName"	: "#(faker.name().lastName())",
          "type"		: "ADULT"
        },
        {
          "ada"			: false,
          "bags"		: 0,
          "firstName"	: "#(faker.name().firstName())",
          "lastName"	: "#(faker.name().lastName())",
          "type"		: "ADULT"
        },
        {
          "ada"			: false,
          "bags"		: 0,
          "firstName"	: "#(faker.name().firstName())",
          "lastName"	: "#(faker.name().lastName())",
          "type"		: "ADULT"
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
  * print 'Your booking request is:', bookRequest

  Given path 'v1/book/4249'
  And request bookRequest
  When method post
  Then status 201

  * def bookLocation = responseHeaders['Location'][0].substring(responseHeaders['Location'][0].lastIndexOf('webstore') + 9)

  Given path bookLocation
  When method get
  Then status 200

  * print response


