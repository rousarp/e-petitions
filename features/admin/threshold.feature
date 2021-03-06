Feature: Threshold list
  In order to see and action petitions that require a response
  As a threshold or sysadmin user I can see a list of petitions that have exceeded the signature threshold count
  Or have been marked as requiring a response
  
  Background:
    Given I am logged in as a threshold user
    And the date is the "21 April 2011 12:00"
    And a department "Treasury" exists with name: "Treasury"
    And a system setting exists with key: "threshold_signature_count", value: "5"
    And an open petition "p1" exists with title: "Petition 1", closed_at: "1 January 2012", department: department "Treasury"
    And the petition "Petition 1" has 25 validated signatures
    And an open petition "p2" exists with title: "Petition 2", closed_at: "20 August 2011"
    And the petition "Petition 2" has 4 validated signatures
    And an open petition "p3" exists with title: "Petition 3", closed_at: "20 September 2011"
    And the petition "Petition 3" has 5 validated signatures
    And a closed petition "p4" exists with title: "Petition 4", closed_at: "20 April 2011"
    And the petition "Petition 4" has 10 validated signatures
    And an open petition "p5" exists with title: "Petition 5", response_required: false
    And a closed petition "p6" exists with title: "Petition 6", response_required: true, closed_at: "21 April 2011"
    And all petitions have had their signatures counted

  Scenario: A threshold user sees all petitions above the threshold signature count
    When I go to the admin threshold page
    Then I should see the following admin index table:
      | Title      | Count | Closing date |
      | Petition 6 | 1     | 21-04-2011   |
      | Petition 3 | 5     | 20-09-2011   |
      | Petition 4 | 10    | 20-04-2011   |
      | Petition 1 | 25    | 01-01-2012   |
    And I should be connected to the server via an ssl connection
    And the markup should be valid

  Scenario: Threshold petitions are paginated
    Given I am logged in as a sysadmin
    And 20 petitions exist with a signature count of 6
    When I go to the admin threshold page
    And I follow "Next"
    Then I should see 4 rows in the admin index table
    And I follow "Previous"
    And I should see 20 rows in the admin index table
    
  Scenario: A threshold user can view the details of a petition and form fields
    When I go to the admin threshold page
    And I follow "Petition 1"
    Then I should see "Treasury"
    And I should see "01-01-2012"
    And I should see a "Internal response" textarea field
    And I should see a "Public response required" checkbox field
    And I should see a "Public response" textarea field
    And I should see a "Email signees" checkbox field

  Scenario: A threshold user updates the internal response to a petition
    When I go to the admin threshold page
    And I follow "Petition 1"
    And I fill in "Internal response" with "Parliament here it comes"
    And I check "Public response required"
    And I press "Save"
    Then I should be on the admin threshold page
    And a petition should exist with title: "Petition 1", internal_response: "Parliament here it comes", response_required: true
    
  Scenario: A threshold user updates the public response to a petition
    Given the time is "3 Dec 2010 01:00"
    When I go to the admin threshold page
    And I follow "Petition 1"
    And I fill in "Public response" with "Parliament here it comes"
    And I check "Email signees"
    And I press "Save"
    Then I should be on the admin threshold page
    And a petition should exist with title: "Petition 1", response: "Parliament here it comes", email_requested_at: "2010-12-03 01:00:00"
    And the response to "Petition 1" should be publicly viewable on the petition page

  Scenario: A threshold user unsuccessfully tries to update the public response to a petition
    Given the time is "3 Dec 2010 01:00"
    When I go to the admin threshold page
    And I follow "Petition 1"
    And I check "Email signees"
    And I press "Save"
    Then I should see "must be completed when email signees is checked"
    And a petition should not exist with title: "Petition 1", email_requested_at: "2010-12-03 01:00:00"
