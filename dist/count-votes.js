function countVotes() {
    var votes = [];
    var person;

    jQuery('.rating-nodes > [title]').each(
        function (i, n) {
            [ person, vote ] = n.title.split(': ');
            votes[person] = (votes[person] || 0) + Number(vote);
        }
    );

    var skip = [ 'Brian', 'Ivan', 'Jason' ];
    var currentPersonVotes = jQuery('.rating-nodes > .voting-node > .selected');
    var [ currentPersonName ] = currentPersonVotes[0].title.split(': ');
    votes[currentPersonName] = currentPersonVotes.length;

    console.warn('Number of votes on this page:');
    for (var name in votes) {
        if (skip.includes(name)) continue;
        var logFunc = votes[name] == 6 ? 'info' :
            votes[name] == 0 ? 'error' : 'warn';
        console[logFunc](name, ': ', votes[name]);
    };
    return void(0);
}

