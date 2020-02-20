Feature: Testing Reservation endpoint with Confirmation Number and Last Name

  Background:
    * url 'https://api.dev.tdstickets.com/ticketing/'
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

    * call read('reservationConfirmationCode.feature')
#    * print reservation


  Scenario: Pulling successful reservation  with confirmation number and last name

    Given path 'reservation/'
    And param confirmationNumber = confirmationNumber
    And param lastName =  lastName
    When method get
    Then status 200

    * print response