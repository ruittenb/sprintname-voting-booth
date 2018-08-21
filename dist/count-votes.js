function countVotes() {
    var votes = [];
    var person, vote;

    // currently logged in user
    var currentPersonVotes = jQuery('.rating-nodes > .voting-node > .selected');
    if (currentPersonVotes.length) {
        var [ currentPersonName ] = currentPersonVotes[0].title.split(': ');
        votes[currentPersonName] = currentPersonVotes.length;
    }

    // other users
    jQuery('.rating-nodes > [title]:not([title=""])').each(
        function (i, n) {
            [ person, vote ] = n.title.split(': ');
            votes[person] = (votes[person] || 0) + Number(vote);
        }
    );

    var tiles = jQuery('.poketile').length;
    var expected = (
        tiles < 1 ? 0 :
        tiles === 1 ? 3 :
        tiles === 2 ? 5 : 6);

    // format results
    console.warn('Number of votes on this page:');
    var skip = [ 'Brian', 'Ivan', 'Jason' ];
    for (var name in votes) {
        if (skip.includes(name)) continue;
        var color = votes[name] == expected ? 'blue' :
            votes[name] == 0 ? 'red' : '#bb0';
        console.log('%c' + name + ': ' + votes[name], 'color:' + color);
    };
    return;
}

