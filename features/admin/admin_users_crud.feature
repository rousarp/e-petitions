Feature: Admin users index and crud
  As a sysadmin
  I can see the admin users index and crud admin users

  Background:
    Given I am logged in as a sysadmin with the email "muddy@fox.com", first_name "Sys", last_name "Admin"
    And a threshold user exists with email: "naomi@example.com", first_name: "Naomi", last_name: "Campbell"
    And a department exists with name: "Treasury"
    And a department exists with name: "DFID"
    
  Scenario: Accessing the admin users index
    When I go to the admin home page
    And I follow "Users" in the admin nav
    Then I should be on the admin users index page
    And I should be connected to the server via an ssl connection

  Scenario: Ordering of the users index
    Given an admin user exists with email: "derek@example.com", first_name: "Derek", last_name: "Jacobi"
    And an admin user exists with email: "helen@example.com", first_name: "Helen", last_name: "Hunt", failed_login_count: 5
    When I go to the admin users index page
    Then I should see the following admin index table:
      | Name            | Email             | Role      | Disabled |
      | Admin, Sys      | muddy@fox.com     | sysadmin  |          |
      | Campbell, Naomi | naomi@example.com | threshold |          |
      | Hunt, Helen     | helen@example.com | admin     | Yes      |
      | Jacobi, Derek   | derek@example.com | admin     |          |
    And the markup should be valid
    
  Scenario: Pagination of the users index
    Given 20 admin users exist
    When I go to the admin users index page
    And I follow "Next"
    Then I should see 2 rows in the admin index table
    And I follow "Previous"
    Then I should see 20 rows in the admin index table

  Scenario: Inspecting the new user form
    When I go to the admin users index page
    And I follow "New user"
    Then I should be on the admin new user page
    And I should be connected to the server via an ssl connection
    And I should see a "First name" text field
    And I should see a "Last name" text field
    And I should see a "Email" text field
    And I should see a "Role" select field with the following options:
      | admin     |
      | sysadmin  |
      | threshold |
    And I should see a "Force password reset" checkbox field
    And I should see a "Account disabled" checkbox field
    And I should see a "Password" password field
    And I should see a "Password confirmation" password field
    And I should see 4 dropdowns in the "departments" fieldset
    And I should see a "department_ids_0" select field with the following options:
      |          |
      | DFID     |
      | Treasury |

  Scenario: Creating a new user
    When I go to the admin users index page
    And I follow "New user"
    And I fill in "First name" with "Derek"
    And I fill in "Last name" with "Jacobi"
    And I fill in "Email" with "derek@example.com"
    And I select "sysadmin" from "Role"
    And I fill in "Password" with "Shebang22!"
    And I fill in "Password confirmation" with "Shebang22!"
    And I select "Treasury" from "department_ids_0"
    And I press "Save"
    Then I should be on the admin users index page
    And I should see "derek@example.com"
    When I follow "Jacobi, Derek"
    Then the "Role" select field should have "sysadmin" selected
    And the "Account disabled" checkbox should not be checked
    And the "department_ids_0" select field should have "Treasury" selected

  Scenario: Updating a user
    When I go to the admin users index page
    And I follow "Campbell, Naomi"
    And I fill in "First name" with "Nolene"
    And I fill in "Email" with "helen@example.com"
    And I check "Account disabled"
    And I press "Save"
    Then I should be on the admin users index page
    And I should see "helen@example.com"
    When I follow "Campbell, Nolene"
    And the "Email" field should contain "helen@example.com"
    And the "Account disabled" checkbox should be checked
    And an admin user should exist with email: "helen@example.com", failed_login_count: "5"
    And I should be connected to the server via an ssl connection

  Scenario: Enabling a user's disabled account
    Given an admin user exists with email: "derek@example.com", first_name: "Derek", last_name: "Jacobi", failed_login_count: "5"
    When I go to the admin users index page
    And I follow "Jacobi, Derek"
    And the "Account disabled" checkbox should be checked
    And I uncheck "Account disabled"
    And I press "Save"
    Then I should be on the admin users index page
    When I follow "Jacobi, Derek"
    And the "Account disabled" checkbox should not be checked
    And an admin user should exist with email: "derek@example.com", failed_login_count: "0"

  Scenario: Deleting a user
    When I go to the admin users index page
    And I follow "Delete" for "naomi@example.com"
    Then a admin user should not exist with email: "naomi@example.com"
    And the row with the name "naomi@example.com" is not listed
