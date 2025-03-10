@addon_mod_lesson @app @mod @mod_lesson @javascript
Feature: Test decimal separators in lesson

  Background:
    Given the Moodle site is compatible with this feature
    And the following "users" exist:
      | username | firstname | lastname | email                |
      | teacher1 | Teacher   | teacher  | teacher1@example.com |
      | student1 | Student   | student  | student1@example.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |
    And the following "activities" exist:
      | activity | name           | intro                | course | idnumber | modattempts | review | maxattempts | retake | allowofflineattempts |
      | lesson   | Basic lesson   | Basic lesson descr   | C1     | lesson   | 1           | 1      | 9           | 1      | 0                    |
      | lesson   | Offline lesson | Offline lesson descr | C1     | lesson   | 1           | 1      | 9           | 1      | 1                    |
    # Currently there are no generators for pages. See MDL-77581.
    And I log in as "teacher1"
    And I change window size to "small"
    And I am on "Course 1" course homepage
    And I follow "Basic lesson"
    And I follow "Add a question page"
    And I set the field "Select a question type" to "Numerical"
    And I press "Add a question page"
    And I set the following fields to these values:
      | Page title | Hardest question ever |
      | Page contents | 1 + 1.87? |
      | id_answer_editor_0 | 2.87 |
      | id_response_editor_0 | Correct answer |
      | id_jumpto_0 | End of lesson |
      | id_score_0 | 1 |
      | id_answer_editor_1 | 2.1:2.8 |
      | id_response_editor_1 | Incorrect answer |
      | id_jumpto_1 | This page |
      | id_score_1 | 0 |
    And I press "Save page"
    And I am on "Course 1" course homepage
    And I follow "Offline lesson"
    And I follow "Add a question page"
    And I set the field "Select a question type" to "Numerical"
    And I press "Add a question page"
    And I set the following fields to these values:
      | Page title | Hardest question ever |
      | Page contents | 1 + 1.87? |
      | id_answer_editor_0 | 2.87 |
      | id_response_editor_0 | Correct answer |
      | id_jumpto_0 | End of lesson |
      | id_score_0 | 1 |
      | id_answer_editor_1 | 2.1:2.8 |
      | id_response_editor_1 | Incorrect answer |
      | id_jumpto_1 | This page |
      | id_score_1 | 0 |
    And I press "Save page"
    And I log out

  Scenario: Attempt an online lesson successfully as a student (standard separator)
    Given I entered the course "Course 1" as "student1" in the app
    And I press "Basic lesson" in the app
    When I press "Start" in the app
    Then I should find "1 + 1.87?" in the app

    When I set the field "Your answer" to "2,87" in the app
    And I press "Submit" in the app
    Then I should find "One or more questions have no answer given" in the app

    When I press "Continue" in the app
    And I set the field "Your answer" to "2.87" in the app
    And I press "Submit" in the app
    Then I should find "Correct answer" in the app
    And I should find "2.87" in the app
    And I should not find "Incorrect answer" in the app

    When I press "Continue" in the app
    Then I should find "Congratulations - end of lesson reached" in the app
    And I should find "Your score is 1 (out of 1)." in the app

  Scenario: Attempt an online lesson successfully as a student (custom separator) and review as teacher
    Given the following "language customisations" exist:
      | component       | stringid | value |
      | core_langconfig | decsep   | ,     |
    And the following config values are set as admin:
      | customlangstrings | "core.decsep|,|en" | tool_mobile |
    And I entered the course "Course 1" as "student1" in the app
    And I press "Basic lesson" in the app
    When I press "Start" in the app
    Then I should find "1 + 1.87?" in the app

    When I set the field "Your answer" to "2,87" in the app
    And I press "Submit" in the app
    Then I should find "Correct answer" in the app
    And I should find "2,87" in the app
    And I should not find "Incorrect answer" in the app

    When I press "Continue" in the app
    Then I should find "Congratulations - end of lesson reached" in the app
    And I should find "Your score is 1 (out of 1)." in the app

    When I press "Review lesson" in the app
    Then the field "Your answer" matches value "2,87" in the app

    When I go back in the app
    And I press "Start" in the app
    And I set the field "Your answer" to "2.87" in the app
    And I press "Submit" in the app
    Then I should find "Correct answer" in the app
    And I should find "2,87" in the app
    And I should not find "Incorrect answer" in the app

    When I press "Continue" in the app
    Then I should find "Congratulations - end of lesson reached" in the app
    And I should find "Your score is 1 (out of 1)." in the app

    When I press "Review lesson" in the app
    Then the field "Your answer" matches value "2,87" in the app
    And the following events should have been logged for "student1" in the app:
      | name                                   | activity | activityname | object       | objectname            | course   |
      | \mod_lesson\event\course_module_viewed | lesson   | Basic lesson |              |                       | Course 1 |
      | \mod_lesson\event\lesson_started       | lesson   | Basic lesson |              |                       | Course 1 |
      | \mod_lesson\event\lesson_ended         | lesson   | Basic lesson |              |                       | Course 1 |
      | \mod_lesson\event\question_viewed      | lesson   | Basic lesson | lesson_pages | Hardest question ever | Course 1 |
      | \mod_lesson\event\question_answered    | lesson   | Basic lesson | lesson_pages | Hardest question ever | Course 1 |
      | \core\event\user_graded                |          |              |              |                       | Course 1 |

  Scenario: Attempt an offline lesson successfully as a student (standard separator)
    Given I entered the course "Course 1" as "student1" in the app
    When I press "Course downloads" in the app
    And I press "Download" within "Offline lesson" "ion-item" in the app
    Then I should find "Downloaded" within "Offline lesson" "ion-item" in the app

    When I go back in the app
    And I press "Offline lesson" in the app
    And I switch network connection to offline
    And I press "Start" in the app
    Then I should find "1 + 1.87?" in the app

    When I set the field "Your answer" to "2,87" in the app
    And I press "Submit" in the app
    Then I should find "One or more questions have no answer given" in the app

    When I press "Continue" in the app
    And I set the field "Your answer" to "2.87" in the app
    And I press "Submit" in the app
    Then I should find "Correct answer" in the app
    And I should find "2.87" in the app
    And I should not find "Incorrect answer" in the app

    When I press "Continue" in the app
    Then I should find "Congratulations - end of lesson reached" in the app
    And I should find "Your score is 1 (out of 1)." in the app

    When I switch network connection to wifi
    And I go back in the app
    Then I should find "An offline attempt was synchronised" in the app

  Scenario: Attempt an offline lesson successfully as a student (custom separator)
    Given the following "language customisations" exist:
      | component       | stringid | value |
      | core_langconfig | decsep   | ,     |
    And the following config values are set as admin:
      | customlangstrings | core.decsep\|,\|en | tool_mobile |
    And I entered the course "Course 1" as "student1" in the app
    When I press "Course downloads" in the app
    And I press "Download" within "Offline lesson" "ion-item" in the app
    Then I should find "Downloaded" within "Offline lesson" "ion-item" in the app

    When I go back in the app
    And I press "Offline lesson" in the app
    And I switch network connection to offline
    And I press "Start" in the app
    Then I should find "1 + 1.87?" in the app

    When I set the field "Your answer" to "2,87" in the app
    And I press "Submit" in the app
    Then I should find "Correct answer" in the app
    And I should find "2,87" in the app
    And I should not find "Incorrect answer" in the app

    When I press "Continue" in the app
    Then I should find "Congratulations - end of lesson reached" in the app
    And I should find "Your score is 1 (out of 1)." in the app

    When I switch network connection to wifi
    And I go back in the app
    Then I should find "An offline attempt was synchronised" in the app

    When I switch network connection to offline
    And I press "Start" in the app
    And I set the field "Your answer" to "2.87" in the app
    And I press "Submit" in the app
    Then I should find "Correct answer" in the app
    And I should find "2,87" in the app
    And I should not find "Incorrect answer" in the app

    When I press "Continue" in the app
    Then I should find "Congratulations - end of lesson reached" in the app
    And I should find "Your score is 1 (out of 1)." in the app
