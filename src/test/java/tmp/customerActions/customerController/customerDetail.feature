Feature: Customer Detail
  Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}

  Scenario: Pulling of logged in Customer Detail
    Given path 'customer/detail'
    And request {}
    When method get
    Then assert responseStatus == 200 || responseStatus == 403

    * if ( responseStatus == 200 ) karate.set('loggedIn', 'Logged In')
    * if ( responseStatus == 403 ) karate.set('loggedIn', 'Not Logged In')
    * print loggedIn

    * def customerDetail = response
#    * print customerDetail
    * def customerId = customerDetail.customerId
#    * print customerId