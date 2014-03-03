var render = require('./render');
var getData = require('./get-data');

// Роутеры у koa пока не умеют добавлять регулярки к роутам, пришлось вручную.
module.exports = function *routeHandler() {
    if (this.url === '/?') { return this.response.redirect('/'); }
    if (this.url === '/') { return (this.body = yield render('index')); }

    if (this.params.catalog) {
        if (!/^\d+$/.test(this.params.catalog)) {
            return this.response.redirect('/');
        }

        if (this.params.card && !/^\d+$/.test(this.params.card)) {
            return this.response.redirect('/' + this.params.catalog);
        }

        var api = this.url.split('/').indexOf('api') > -1;

        if (api && !this.request.header['x-requested-with']) {
            return this.response.redirect('/');
        }

        return (this.body = yield getData(this.params, api));
    }
};
