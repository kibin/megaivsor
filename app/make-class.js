module.exports = function(card, index) {
    var active = card - 1;
    var prefix = 'carousel-card_';
    var side = (index === active) ? 'active' :
        ((index > active) ? 'right' : 'left');

    var idx = (index === active) ? '' :
        ((index > active) ? index - active : active - index) - 1;

    var firstClass = prefix + side;

    var secondClass = (side === 'active') ? '' :
        ' ' + prefix + side + '_' + idx;

    return firstClass + secondClass;
}
