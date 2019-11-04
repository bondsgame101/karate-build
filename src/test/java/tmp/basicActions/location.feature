Feature: Call Location
  Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}

  Scenario:
    Given path 'location/country'
    And request { 'carrierId': 1, 'type': 'DESTINATION', 'originStopId': '#(origin.origin)' }
    When method get
    Then status 200

    * def location = response
    * print location