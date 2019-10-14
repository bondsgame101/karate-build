Feature: Purchase a One Way ticket in TMP Dev/Stage/QA not logged in

  Background:
#    * url 'https://api.qa.tdstickets.com/ticketing/'
    * url 'https://quasar-api.tdstickets.com/ticketing/'
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '8D238A87-F063-46B9-8D51-E0A2977B8C23', 'Content-Type': 'application/json'}
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
     And request { 'carrierId': 1, 'origin': { 'stopUuid': '#(origin)' }, 'destination': { 'stopUuid': '#(destination)' }, 'departDate': '#(week)' }
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
     * def fares = availability.outboundFares.Adult[0]
     * print fares
     * def fareId = fares.fareId
     * def type = fares.type
     * def passengerType = fares.passengerType
     * def amount = fares.amount
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
               "gateway": "CARDCONNECT",
               "agency": "189697",
               "country": "US"
           },
             "accountNumber": "376759138081051",
             "securityCode": "1384",
             "expirationMonth": "05",
             "expirationYear": "24",
             "nameOnCard": "Terry Cordell",
             "address1": "9310 Old Kings Rd., Ste 401",
             "address2": "",
             "city": "Jacksonville",
             "state": "FL",
             "postalCode": "32257",
             "country": "US",
             "phone": "5555546855",
             "email": "khoehn@tdstickets.com",
             "ipAddress": "127.0.0.1",
             "fraudAlgorithm": ""
          }
          """

     Given url 'https://upg.tdstickets.com/tokenizer/v1/generate/card'
     And request upg
     When method post
     Then status 200
     * def token = response.token
     * print token


#     Given url 'https://api.qa.tdstickets.com/ticketing/'
     Given url 'https://quasar-api.tdstickets.com/ticketing/'

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
              "firstName": "Terry",
              "lastName": "Cordell",
              "email": "khoehn@tdstickets.com",
              "phone": "(201) 543-9867",
              "mobile": "(908) 789-1234",
              "address1": "9310 Old Kings Rd",
              "address2": "Suite 310",
              "city": "Jacksonville",
              "state": "FL",
              "zip": "32257"
            },
            "passengers": [
              {
                "firstName": "Patrick",
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
     * replace bookRequest.departDate = departDate
     * replace bookRequest.scheduleUuid = scheduleUuid
     * replace bookRequest.destination = destination
     * replace bookRequest.origin = origin
     * replace bookRequest.total = total
     * replace bookRequest.token = token
     * replace bookRequest.fareId = fareId
     * replace bookRequest.type = type
     * replace bookRequest.passengerType = passengerType
     * replace bookRequest.amount = amount

     Given path 'book'
     And request bookRequest
     When method post
     Then status 200

     * def book = response
     * print book


