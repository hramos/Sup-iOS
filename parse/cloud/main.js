/* =============================================================================
 * Objects
 */

var Sup = Parse.Object.extend("Sup");


/* =============================================================================
 * Save Hooks
 */

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
  var username = request.object.get("username").toLowerCase();

  if (username.length > 10) {
    username = username.substring(0, 9);
  }

  request.object.set("username", username);
  response.success();
});

Parse.Cloud.beforeSave(Sup, function(request, response) {
  if (!request.object.get("fromUser")) {
    response.error("No user found.");
    return;
  }

  if (!request.object.get("fromUserName")) {
    response.error("No user found.");
    return;
  }

  if (!request.object.get("toUser")) {
    response.error("No user found.");
    return;
  }

  if (!request.object.get("toUserName")) {
    response.error("No user found.");
    return;
  }

  response.success();
});

Parse.Cloud.afterSave(Sup, function(request) {
  var username = request.object.get("fromUserName").toUpperCase();

  Parse.Analytics.track('sup', {});

  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("user", request.object.get("toUser"));

  Parse.Push.send({
    where: pushQuery,
    data: {
      alert: "From " + username,
      sound: "Sup.aiff",
      username: username
    }
  });
});


/* =============================================================================
 * Cloud Functions
 */
 
Parse.Cloud.define("sup", function(request, response) {
  var fromUser = request.user;
  var toUserName = request.params.username;

  if (!fromUser) {
    response.error("No user session found.");
    return;
  }

  if (!toUserName) {
    response.error("No recipient found.");
    return;
  } else {
    toUserName = toUserName.trim();
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query(Parse.User);
    query.equalTo("username", toUserName);
    query.first().then(function(toUser) {
      if (!toUser) {
        return Parse.Promise.error('No user found.');
      } else {
        return toUser;
      }
    }).then(function(toUser) {
      var sup = new Sup();
      sup.set("fromUser", fromUser);
      sup.set("fromUserName", fromUser.get("username"));
      sup.set("toUser", toUser);
      sup.set("toUserName", toUserName);

      var acl = new Parse.ACL();
      acl.setReadAccess(fromUser, true);
      acl.setReadAccess(toUser, true);
      sup.setACL(acl);

      return sup.save();
    }).then(function() {
      response.success();
    }, function(error) {
      response.error("Sorry.");
    });
  }
});
