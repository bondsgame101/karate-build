function fn(creds) {
    var https = require("https");
    var querystring = require("querystring");

    var body = querystring.stringify({
            grant_type: creds.grant_type,
            client_id: creds.client_id, // QA Bus Bud client Id
            client_secret: creds.client_secret // QA Wanderu client secrect
        });

    var echoPostRequest = {
        host: 'accounts.stage.tdstickets.com',
        method: 'POST',
        path: '/auth/realms/qa/protocol/openid-connect/token',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': body.length
        }
    };

    var getToken = true;

    var accessTokenExpiry;
    var currentAccessToken;

    if (!accessTokenExpiry  || !currentAccessToken ) {
        console.log('Token or expiry date are missing')
    } else if (accessTokenExpiry <= (new Date()).getTime()) {
        console.log('Token is expired')
    } else {
        getToken = false;
        console.log('Token and expiry date are all good');
    }

    if (getToken === true) {
        var reqPost = https.request(echoPostRequest, function (res) {
            var result = '';
            res.on('data', function (chunk) {
                result += chunk;
            });
            res.on('end', function () {
                console.log(result);
            });
            res.on('error', function (err) {
                console.log(err);
            })
        });

        reqPost.write(body);
        reqPost.end();
    }
}