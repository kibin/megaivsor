var httpRequest = require('./http-request');
var makeClass = require('./make-class');
var render = require('./render');

module.exports = function *getData(params, api) {
    var catalog = +params.catalog;
    var card = +params.card ? +params.card : 1;
    var url = 'http://megavisor.com/export/catalog.json?uuid=';
    var body = JSON.parse((yield httpRequest(url + catalog))[0].body);
    var errors = body.errors;
    // 403 возвращает массив в ошибках, 404 объект.
    var code = errors ? (errors[0] ? errors[0] : errors).code : 200;

    var template = 'index';

    var texts = {
        '403': 'Доступ запрещен, чувак',
        '404': 'Такого каталога нет, ты, наверное, что-то перепутал',
        '200': body
    };

    if (code === 200) {
        if (card && (card > body.info.totalCount || card > 100)) { card = 1; }

        body.items.forEach(function(item, index) {
            item['class'] = makeClass(card, index);
        });
    }

    var resp = {
        catalog: catalog,
        code: code,
        body: texts[code]
    };

    if (api) {
        return (this.body = resp);
    }

    return (this.body = yield render(template, resp));
};

