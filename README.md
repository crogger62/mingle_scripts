mingle_scripts
==============

check_project_activity
----------------------

Runs on 
ruby - 2.1.1
api-auth - 1.1.0

Usage: - ruby check_project_activity.rb https://yoursite.mingle.thoughtworks.com <your username> <your secret HMAC key>

Split the HMAC key into separate arguments if they have line breaks.
Check out Mingle help docs on how to generate HMAC key for your self.


Output: A CSV file, named after your hostname, containing the project identifiers and last updated date.

