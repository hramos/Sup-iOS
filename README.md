# Sup app #

This is the source code for the sample app, Sup, demoed at Parse's NYC Meetup on June 23, 2014.

## iOS Setup ##

1. Create a new Parse app: https://parse.com (sign up if you don't have an account!)
2. Clone this repo.
3. Open the `AppDelegate.m` file and modify the following two lines to use your actual Parse application id and client key:

```
[Parse setApplicationId:YOUR_APP_ID
              clientKey:YOUR_CLIENT_KEY];
```

4. [Install](https://parse.com/docs/cloud_code_guide#started-installing) the Parse CLI.
5. [Set up your Cloud Code](https://parse.com/docs/cloud_code_guide#started-setup).
6. Copy the `main.js` from `parse/cloud` into your Cloud Code folder.
7. Deply! `parse deploy`
