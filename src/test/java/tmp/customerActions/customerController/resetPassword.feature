Feature: Forgot Password

  Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}

#    * call read('login.feature')

  Scenario: Sending Forgot Password

    Given path 'customer/reset-pw'
    And request {'matchingPassword': 'test1234', 'password': 'test1234', 'token': 'eerwrwersfwefwf'}
    When method post
    Then status 200

    * print response