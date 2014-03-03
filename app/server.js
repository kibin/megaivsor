var koa = require('koa');
var router = require('koa-router');
var serve = require('koa-static');
var routeHandler = require('./route-handler');

var port = process.env.PORT || 3000;
var app = koa();

app.use(serve(__dirname + '/../public'));

app.use(router(app));
app.get('/', routeHandler);
app.get('/api/:catalog/:card', routeHandler);
app.get('/api/:catalog', routeHandler);
app.get('/:catalog/:card', routeHandler);
app.get('/:catalog', routeHandler);
app.redirect('/*', '/');

app.listen(port);
console.log('The port is ' + port);
