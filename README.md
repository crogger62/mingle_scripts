mingle_scripts
==============

check_project_activity
----------------------

Runs on 
* ruby - 2.1.1
* api-auth - 1.1.0

Usage:

* If using HMAC
** ruby check_project_activity.rb https://yoursite.mingle.thoughtworks.com HMAC your_username your_secret_HMAC_key
* If using Basic Auth
** ruby check_project_activity.rb https://yoursite.mingle.thoughtworks.com Basic your_username your_password

Split the HMAC key into separate arguments if they have line breaks.
Check out [Mingle help docs](http://www.thoughtworks.com/products/docs/mingle/current/help/mingle_api.html) on how to generate HMAC key for yourself.


Output: A CSV file, named after your hostname, containing the project identifiers and last updated date.

