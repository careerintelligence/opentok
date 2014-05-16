How to deploy the sample app on Heroku
======================================

You can use [www.heroku.com](Heroku) to deploy the OpenTok archiving sample app.

One advantage to using Heroku is that it provides a server that will be accessible from the OpenTok server
(for REST callback APIs). (Your localhost server may be behind a firewall.) Although this sample app does not
use the REST callback APIs, you may want to write code to test them. If you do use the REST callback APIs,
using Heroku can provide you a test environment with an accessible callback URL.

To sign up for Heroku, go to [www.heroku.com](http://www.heroku.com/). (It's free!)

Local workstation setup
-----------------------

Install the [Heroku Toolbelt](https://toolbelt.heroku.com/) on your local workstation. This ensures that you have access to the Heroku command-line client, Foreman, and the Git revision control system.

Once installed, you can use the heroku command from your command shell. Log in using the email address and password you used when creating your Heroku account:

```
$ heroku login
Enter your Heroku credentials.
Email: adam@example.com
Password: 
Could not find an existing public key.
Would you like to generate one? [Yn] 
Generating new SSH public key.
Uploading ssh public key /Users/adam/.ssh/id_rsa.pub
```

Press enter at the prompt to upload your existing ssh key or create a new one, used for pushing code later on.

Create the app
--------------

```
$ heroku create
Creating sharp-rain-871... done, stack is cedar
http://sharp-rain-871.herokuapp.com/ | git@heroku.com:sharp-rain-871.git
Git remote heroku added
```

Set the Heroku configuration:

```
$ heroku config:set API_ENDPOINT=https://api.opentok.com API_KEY=YOUR-API-KEY API_SECRET=YOUR-API-SECRET
```

* Replace YOUR-API-KEY with your OpenTok API key.
* Replace YOUR-API-SECRET with your OpenTok API secret.


Deploy it
---------

```
$ git push heroku master
```

You've deployed your code to Heroku. Now you need to set the concurrency level for the web process:

```
$ heroku ps:scale web=1
```

You only need to do this once. To see if you did, check that you get output like:

```
$ heroku ps
=== web: `node web.js`
web.1: up for 10s
```

And now you can visit it by executing:

```
$ heroku open
Opening sharp-rain-871... done
```

For more information, see [heroku support](https://help.heroku.com/).