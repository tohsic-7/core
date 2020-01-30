@api @TestAlsoOnExternalUserBackend @skipOnOcis @issue-ocis-reva-14
Feature: move (rename) file
  As a user
  I want to be able to move and rename files
  So that I can manage my file system

  Background:
    Given using OCS API version "1"
    And user "user0" has been created with default attributes and skeleton files

  @smokeTest
  Scenario Outline: Moving a file
    Given using <dav_version> DAV path
    When user "user0" moves file "/welcome.txt" to "/FOLDER/welcome.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And the following headers should match these regular expressions
      | ETag | /^"[a-f0-9]{1,32}"$/ |
    And the downloaded content when downloading file "/FOLDER/welcome.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
    Examples:
      | dav_version |
      | old         |
      | new         |

  @smokeTest
  Scenario Outline: Moving and overwriting a file
    Given using <dav_version> DAV path
    When user "user0" moves file "/welcome.txt" to "/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "204"
    And the following headers should match these regular expressions
      | ETag | /^"[a-f0-9]{1,32}"$/ |
    And the downloaded content when downloading file "/textfile0.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: Moving (renaming) a file to be only different case
    Given using <dav_version> DAV path
    When user "user0" moves file "/textfile0.txt" to "/TextFile0.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And as "user0" file "/textfile0.txt" should not exist
    And the content of file "/TextFile0.txt" for user "user0" should be "ownCloud test text file 0" plus end-of-line
    Examples:
      | dav_version |
      | old         |
      | new         |

  @smokeTest
  Scenario Outline: Moving (renaming) a file to a file with only different case to an existing file
    Given using <dav_version> DAV path
    When user "user0" moves file "/textfile1.txt" to "/TextFile0.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/textfile0.txt" for user "user0" should be "ownCloud test text file 0" plus end-of-line
    And the content of file "/TextFile0.txt" for user "user0" should be "ownCloud test text file 1" plus end-of-line
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: Moving (renaming) a file to a file in a folder with only different case to an existing file
    Given using <dav_version> DAV path
    When user "user0" moves file "/textfile1.txt" to "/PARENT/Parent.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/PARENT/parent.txt" for user "user0" should be "ownCloud test text file parent" plus end-of-line
    And the content of file "/PARENT/Parent.txt" for user "user0" should be "ownCloud test text file 1" plus end-of-line
    Examples:
      | dav_version |
      | old         |
      | new         |

  @files_sharing-app-required
  Scenario Outline: Moving a file into a shared folder as the sharee and as the sharer
    Given using <dav_version> DAV path
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created folder "/testshare"
    And user "user1" has created a share with settings
      | path        | testshare |
      | shareType   | user      |
      | permissions | change    |
      | shareWith   | user0     |
    And user "<mover>" has uploaded file with content "test data" to "/testfile.txt"
    When user "<mover>" moves file "/testfile.txt" to "/testshare/testfile.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/testshare/testfile.txt" for user "user0" should be "test data"
    And the content of file "/testshare/testfile.txt" for user "user1" should be "test data"
    And as "<mover>" file "/testfile.txt" should not exist
    Examples:
      | dav_version | mover |
      | old         | user0 |
      | new         | user0 |
      | old         | user1 |
      | new         | user1 |

  @files_sharing-app-required
  Scenario Outline: Moving a file out of a shared folder as the sharee and as the sharer
    Given using <dav_version> DAV path
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created folder "/testshare"
    And user "user1" has uploaded file with content "test data" to "/testshare/testfile.txt"
    And user "user1" has created a share with settings
      | path        | testshare |
      | shareType   | user      |
      | permissions | change    |
      | shareWith   | user0     |
    When user "<mover>" moves file "/testshare/testfile.txt" to "/testfile.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/testfile.txt" for user "<mover>" should be "test data"
    And as "user0" file "/testshare/testfile.txt" should not exist
    And as "user1" file "/testshare/testfile.txt" should not exist
    Examples:
      | dav_version | mover |
      | old         | user0 |
      | new         | user0 |
      | old         | user1 |
      | new         | user1 |

  @files_sharing-app-required
  Scenario Outline: Moving a folder into a shared folder as the sharee and as the sharer
    Given using <dav_version> DAV path
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created folder "/testshare"
    And user "user1" has created a share with settings
      | path        | testshare |
      | shareType   | user      |
      | permissions | change    |
      | shareWith   | user0     |
    And user "<mover>" has created folder "/testsubfolder"
    And user "<mover>" has uploaded file with content "test data" to "/testsubfolder/testfile.txt"
    When user "<mover>" moves folder "/testsubfolder" to "/testshare/testsubfolder" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/testshare/testsubfolder/testfile.txt" for user "user0" should be "test data"
    And the content of file "/testshare/testsubfolder/testfile.txt" for user "user1" should be "test data"
    And as "<mover>" file "/testsubfolder" should not exist
    Examples:
      | dav_version | mover |
      | old         | user0 |
      | new         | user0 |
      | old         | user1 |
      | new         | user1 |

  @files_sharing-app-required
  Scenario Outline: Moving a folder out of a shared folder as the sharee and as the sharer
    Given using <dav_version> DAV path
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created folder "/testshare"
    And user "user1" has created folder "/testshare/testsubfolder"
    And user "user1" has uploaded file with content "test data" to "/testshare/testsubfolder/testfile.txt"
    And user "user1" has created a share with settings
      | path        | testshare |
      | shareType   | user      |
      | permissions | change    |
      | shareWith   | user0     |
    When user "<mover>" moves folder "/testshare/testsubfolder" to "/testsubfolder" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/testsubfolder/testfile.txt" for user "<mover>" should be "test data"
    And as "user0" folder "/testshare/testsubfolder" should not exist
    And as "user1" folder "/testshare/testsubfolder" should not exist
    Examples:
      | dav_version | mover |
      | old         | user0 |
      | new         | user0 |
      | old         | user1 |
      | new         | user1 |

  @files_sharing-app-required
  Scenario Outline: Moving a file to a shared folder with no permissions
    Given using <dav_version> DAV path
    And user "user1" has been created with default attributes and skeleton files
    And user "user1" has created folder "/testshare"
    And user "user1" has created a share with settings
      | path        | testshare |
      | shareType   | user      |
      | permissions | read      |
      | shareWith   | user0     |
    When user "user0" moves file "/textfile0.txt" to "/testshare/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "403"
    When user "user0" downloads file "/testshare/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "404"
    Examples:
      | dav_version |
      | old         |
      | new         |

  @files_sharing-app-required
  Scenario Outline: Moving a file to overwrite a file in a shared folder with no permissions
    Given using <dav_version> DAV path
    And user "user1" has been created with default attributes and skeleton files
    And user "user1" has created folder "/testshare"
    And user "user1" has created a share with settings
      | path        | testshare |
      | shareType   | user      |
      | permissions | read      |
      | shareWith   | user0     |
    And user "user1" has copied file "/welcome.txt" to "/testshare/overwritethis.txt"
    When user "user0" moves file "/textfile0.txt" to "/testshare/overwritethis.txt" using the WebDAV API
    Then the HTTP status code should be "403"
    And the downloaded content when downloading file "/testshare/overwritethis.txt" for user "user0" with range "bytes=0-6" should be "Welcome"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: move file into a not-existing folder
    Given using <dav_version> DAV path
    When user "user0" moves file "/welcome.txt" to "/not-existing/welcome.txt" using the WebDAV API
    Then the HTTP status code should be "409"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: rename a file into an invalid filename
    Given using <dav_version> DAV path
    When user "user0" moves file "/welcome.txt" to "/a\\a" using the WebDAV API
    Then the HTTP status code should be "400"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: rename a file to a filename that is banned by default
    Given using <dav_version> DAV path
    When user "user0" moves file "/welcome.txt" to "/.htaccess" using the WebDAV API
    Then the HTTP status code should be "403"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: rename a file to a banned filename
    Given using <dav_version> DAV path
    When the administrator updates system config key "blacklisted_files" with value '["blacklisted-file.txt",".htaccess"]' and type "json" using the occ command
    And user "user0" moves file "/welcome.txt" to "/blacklisted-file.txt" using the WebDAV API
    Then the HTTP status code should be "403"
    Examples:
      | dav_version |
      | old         |
      | new         |

  @skipOnOcV10.3
  Scenario Outline: rename a file to a filename that matches (or not) blacklisted_files_regex
    Given using <dav_version> DAV path
    # Note: we have to write JSON for the value, and to get a backslash in the double-quotes we have to escape it
    # The actual regular expressions end up being .*\.ext$ and ^bannedfilename\..+
    And the administrator has updated system config key "blacklisted_files_regex" with value '[".*\\.ext$","^bannedfilename\\..+","containsbannedstring"]' and type "json"
    When user "user0" moves file "/welcome.txt" to these filenames using the webDAV API then the results should be as listed
      | filename                               | http-code | exists |
      | .ext                                   | 403       | no     |
      | filename.ext                           | 403       | no     |
      | bannedfilename.txt                     | 403       | no     |
      | containsbannedstring                   | 403       | no     |
      | this-ContainsBannedString.txt          | 403       | no     |
      | /FOLDER/.ext                           | 403       | no     |
      | /FOLDER/filename.ext                   | 403       | no     |
      | /FOLDER/bannedfilename.txt             | 403       | no     |
      | /FOLDER/containsbannedstring           | 403       | no     |
      | /FOLDER/this-ContainsBannedString.txt  | 403       | no     |
      | .extension                             | 201       | yes    |
      | filename.txt                           | 201       | yes    |
      | bannedfilename                         | 201       | yes    |
      | bannedfilenamewithoutdot               | 201       | yes    |
      | not-contains-banned-string.txt         | 201       | yes    |
      | /FOLDER/.extension                     | 201       | yes    |
      | /FOLDER/filename.txt                   | 201       | yes    |
      | /FOLDER/bannedfilename                 | 201       | yes    |
      | /FOLDER/bannedfilenamewithoutdot       | 201       | yes    |
      | /FOLDER/not-contains-banned-string.txt | 201       | yes    |
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: rename a file to an excluded directory name
    Given using <dav_version> DAV path
    When the administrator updates system config key "excluded_directories" with value '[".github"]' and type "json" using the occ command
    And user "user0" moves file "/welcome.txt" to "/.github" using the WebDAV API
    Then the HTTP status code should be "403"
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: rename a file to an excluded directory name inside a parent directory
    Given using <dav_version> DAV path
    When the administrator updates system config key "excluded_directories" with value '[".github"]' and type "json" using the occ command
    And user "user0" moves file "/welcome.txt" to "/FOLDER/.github" using the WebDAV API
    Then the HTTP status code should be "403"
    Examples:
      | dav_version |
      | old         |
      | new         |

  @skipOnOcV10.3
  Scenario Outline: rename a file to a filename that matches (or not) excluded_directories_regex
    Given using <dav_version> DAV path
    # Note: we have to write JSON for the value, and to get a backslash in the double-quotes we have to escape it
    # The actual regular expressions end up being endswith\.bad$ and ^\.git
    And the administrator has updated system config key "excluded_directories_regex" with value '["endswith\\.bad$","^\\.git","containsvirusinthename"]' and type "json"
    When user "user0" moves file "/welcome.txt" to these filenames using the webDAV API then the results should be as listed
      | filename                                   | http-code | exists |
      | endswith.bad                               | 403       | no     |
      | thisendswith.bad                           | 403       | no     |
      | .git                                       | 403       | no     |
      | .github                                    | 403       | no     |
      | containsvirusinthename                     | 403       | no     |
      | this-containsvirusinthename.txt            | 403       | no     |
      | /FOLDER/endswith.bad                       | 403       | no     |
      | /FOLDER/thisendswith.bad                   | 403       | no     |
      | /FOLDER/.git                               | 403       | no     |
      | /FOLDER/.github                            | 403       | no     |
      | /FOLDER/containsvirusinthename             | 403       | no     |
      | /FOLDER/this-containsvirusinthename.txt    | 403       | no     |
      | endswith.badandotherstuff                  | 201       | yes    |
      | thisendswith.badandotherstuff              | 201       | yes    |
      | name.git                                   | 201       | yes    |
      | name.github                                | 201       | yes    |
      | not-contains-virus-in-the-name.txt         | 201       | yes    |
      | /FOLDER/endswith.badandotherstuff          | 201       | yes    |
      | /FOLDER/thisendswith.badandotherstuff      | 201       | yes    |
      | /FOLDER/name.git                           | 201       | yes    |
      | /FOLDER/name.github                        | 201       | yes    |
      | /FOLDER/not-contains-virus-in-the-name.txt | 201       | yes    |
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: Checking file id after a move
    Given using <dav_version> DAV path
    And user "user0" has stored id of file "/textfile0.txt"
    When user "user0" moves file "/textfile0.txt" to "/FOLDER/textfile0.txt" using the WebDAV API
    Then user "user0" file "/FOLDER/textfile0.txt" should have the previously stored id
    And user "user0" should not see the following elements
      | /textfile0.txt |
    Examples:
      | dav_version |
      | old         |
      | new         |

  @files_sharing-app-required
  Scenario Outline: Checking file id after a move between received shares
    Given using <dav_version> DAV path
    And user "user1" has been created with default attributes and skeleton files
    And user "user0" has created folder "/folderA"
    And user "user0" has created folder "/folderB"
    And user "user0" has shared folder "/folderA" with user "user1"
    And user "user0" has shared folder "/folderB" with user "user1"
    And user "user1" has created folder "/folderA/ONE"
    And user "user1" has stored id of file "/folderA/ONE"
    And user "user1" has created folder "/folderA/ONE/TWO"
    When user "user1" moves folder "/folderA/ONE" to "/folderB/ONE" using the WebDAV API
    Then as "user1" folder "/folderA" should exist
    And as "user1" folder "/folderA/ONE" should not exist
		# yes, a weird bug used to make this one fail
    And as "user1" folder "/folderA/ONE/TWO" should not exist
    And as "user1" folder "/folderB/ONE" should exist
    And as "user1" folder "/folderB/ONE/TWO" should exist
    And user "user1" file "/folderB/ONE" should have the previously stored id
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: Renaming a file to a path with extension .part should not be possible
    Given using <dav_version> DAV path
    When user "user0" moves file "/welcome.txt" to "/welcome.part" using the WebDAV API
    Then the HTTP status code should be "400"
    And the DAV exception should be "OCA\DAV\Connector\Sabre\Exception\InvalidPath"
    And the DAV message should be "Can`t upload files with extension .part because these extensions are reserved for internal use."
    And the DAV reason should be "Can`t upload files with extension .part because these extensions are reserved for internal use."
    And user "user0" should see the following elements
      | /welcome.txt |
    But user "user0" should not see the following elements
      | /welcome.part |
    Examples:
      | dav_version |
      | old         |
      | new         |

  Scenario Outline: renaming to a file with special characters
    When user "user0" moves file "/welcome.txt" to "/<renamed_file>" using the WebDAV API
    Then the HTTP status code should be "201"
    And the downloaded content when downloading file "/<renamed_file>" for user "user0" with range "bytes=0-6" should be "Welcome"
    Examples:
      | renamed_file  |
      | #oc ab?cd=ef# |
      | *a@b#c$e%f&g* |
      | 1 2 3##.##    |
