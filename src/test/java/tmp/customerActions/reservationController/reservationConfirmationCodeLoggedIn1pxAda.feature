@ignore
Feature: Testing Reservation endpoint with Confirmation Code

  Background:
    * url 'https://api2.stage.tdstickets.com/ticketing/'
#    * configure headers = { TDS-Carrier-Code: 'ppb', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa
#
#    * def getDate = read('classpath:get-date.js')
#
#    * def today = getDate("today")
#    * def tomorrow = getDate("tomorrow")
#    * def week = getDate("week")
#    * def faker = new faker()
#    * def firstName = faker.name().firstName()
#    * def lastName = faker.name().lastName()
#    * def zip = faker.address().zipCode()
#    * def address1 = faker.address().streetAddress()
#    * def city = faker.address().city()
#    * def state = faker.address().stateAbbr()

    * call read('file:src/test/java/tmp/nonLoggedIn/oneWay/nonAda/oneWayTmp1px.feature')
    * print confirmationCode

  Scenario: Pulling successful reservation  with confirmation code

    Given path 'reservation/'
    And path confirmationCode
    When method get
    Then status 200

    * def reservation = response
    * def confirmationNumber = reservation.confirmationNumber
    * def lastName = reservation.receipt.lastName

