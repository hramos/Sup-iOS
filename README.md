# Sup app #

![Sup Home Screen](http://sup.parseapp.com/SupScreen.png)

This is the source code for the sample app, Sup, demoed at Parse's NYC Meetup on June 23, 2014.

## iOS Setup ##

1. Create a new Parse app: https://parse.com (sign up if you don't have an account!)
2. Clone this repo.
3. [OPTIONAL] Open the `AppDelegate.m` file and modify the following two lines to use your actual Parse application id and client key:

```
[Parse setApplicationId:YOUR_APP_ID
              clientKey:YOUR_CLIENT_KEY];
```


## Cloud Code Setup [OPTIONAL] ##

The following steps are only necessary if you are using your own Parse app. If you skipped step 3 above, you can skip the entire Cloud Code setup.

1. [Install](https://parse.com/docs/cloud_code_guide#started-installing) the Parse CLI.
2. [Set up your Cloud Code](https://parse.com/docs/cloud_code_guide#started-setup).
3. Copy the `main.js` from `parse/cloud` into your Cloud Code folder.
4. Deploy! `parse deploy`

