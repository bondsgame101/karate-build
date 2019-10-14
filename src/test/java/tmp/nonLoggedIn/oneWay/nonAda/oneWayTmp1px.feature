Feature: Purchase a One Way ticket in TMP Dev/Stage/QA not logged in

  Background:
#    * url 'https://api.dev.tdstickets.com/ticketing/'
    * url 'https://api2.stage.tdstickets.com/ticketing/'
#    * url 'https://dev-api.peterpanbus.com/ticketing/'
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
#    * configure headers = { 'x-carrier': 'PPB', 'Content-Type': 'application/json'}
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
            "mobile": "(908) 789-1234",
            "address1": "123 Road St",
            "address2": "Apt 101",
            "city": "Citytown",
            "state": "FL",
            "zip": "32222"
          },
          "passengerCounts": {
            "Adult": 1
            }
         }
         """
#     * replace availabilityRequest.departDate = tomorrow
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
     * print amount
#     * string stringFare = fares
#     * def fareReplace = stringFare.replaceAll("\\{","")
#     * def fare = fareReplace.replaceAll("\\}","").trim()
#     * print fare
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
     Given url 'https://upg.stage.tdstickets.com/tokenizer/v1/generate/card'
#     Given url 'https://upg.qa.tdstickets.com/tokenizer/v1/generate/card'
     And request upg
     When method post
     Then status 200
     * def token = response.token
     * print token

#     Given url 'https://api.dev.tdstickets.com/ticketing/'
     Given url 'https://api2.stage.tdstickets.com/ticketing/'
#     Given url 'https://dev-api.peterpanbus.com/ticketing/'

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
              "firstName": "Patrick",
              "lastName": "Locey",
              "email": "sbrooks@tdstickets.com",
              "phone": "(201) 543-9867",
              "mobile": "(908) 789-1234",
              "address1": "123 Road St",
              "address2": "Apt 101",
              "city": "Citytown",
              "state": "FL",
              "zip": "32222"
            },
            "passengers": [
              {
                "firstName": "#(faker.name.firstName)",
                "lastName": "Locey",
                "email": "sbrooks@tdstickets.com",
                "type": "Adult",
                "outboundFare": {
                  "fareId": "<fareId>",
                  "type": "<type>",
                  "passengerType": "<passengerType>",
                  "amount": "<amount>"
                }
              }
            ],
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

#     * replace bookRequest.departDate = tomorrow
     * set bookRequest.passengers[0].outboundFare = outboundFares
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


