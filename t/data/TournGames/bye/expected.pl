use URI;

{
    name => 'May KGS+ Tournament, American Daytime 2k and under division',
    round => '3',
    time_zone => 'GMT',
    next_round => URI->new('http://www.gokgs.com/tournGames.jsp?id=885&round=4'),
    previous_round => URI->new('http://www.gokgs.com/tournGames.jsp?id=885&round=2'),
    games => [{
        kifu_uri => URI->new('http://files.gokgs.com/games/2014/5/17/Verse-Jugger.sgf'),
        white => [{
            name => 'Verse',
            rank => '2k'
        }],
        black => [{
            name => 'Jugger',
            rank => '5k',
        }],
        board_size => '9',
        handicap => undef,
        start_time => '5/17/14 7:45 PM',
        result => 'B+Res.'
    }, {
        white => [{
            name => 'Lim',
            rank => '2k',
        }],
        'black' => [],
        'result' => 'Bye',
    }],
    links => {
        time_zone => 'GMT',
        entrants => [{
            sort_by => 'name',
            link => URI->new('http://www.gokgs.com/tournEntrants.jsp?sort=n&id=885'),
        }, {
            sort_by => 'result',
            link => URI->new('http://www.gokgs.com/tournEntrants.jsp?sort=s&id=885'),
        }],
        rounds => [{
            round => '1',
            start_time => '5/17/14 7:05 PM',
            end_time => '5/17/14 7:25 PM',
            link => URI->new('http://www.gokgs.com/tournGames.jsp?id=885&round=1'),
        }, {
            round => '2',
            start_time => '5/17/14 7:25 PM',
            end_time => '5/17/14 7:45 PM',
            link => URI->new('http://www.gokgs.com/tournGames.jsp?id=885&round=2'),
        }, {
            round => '3',
            start_time => '5/17/14 7:45 PM',
            end_time => '5/17/14 8:05 PM',
            link => URI->new('http://www.gokgs.com/tournGames.jsp?id=885&round=3'),
        }, {
            round => '4',
            start_time => '5/17/14 8:05 PM',
            end_time => '5/17/14 8:25 PM',
            link => URI->new('http://www.gokgs.com/tournGames.jsp?id=885&round=4'),
        }, {
            round => '5',
            start_time => '5/17/14 8:25 PM',
            end_time => '5/17/14 8:45 PM',
            link => URI->new('http://www.gokgs.com/tournGames.jsp?id=885&round=5'),
        }],
    },
};
