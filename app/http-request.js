var Q = require('q');
var request = Q.denodeify(require('request'));

module.exports = function httpRequest(url) {
    return request(url).then(function(result) {
        return result;
    });
};
