{
  'games' => [
    {
      'black' => [
        {
          'name' => 'Jugger',
          'rank' => '5k'
        }
      ],
      'board_size' => '9',
      'handicap' => undef,
      'kifu_uri' => bless( do{\(my $o = 'http://files.gokgs.com/games/2014/5/17/Verse-Jugger.sgf')}, 'URI::http' ),
      'result' => 'B+Res.',
      'start_time' => '5/17/14 7:45 PM',
      'white' => [
        {
          'name' => 'Verse',
          'rank' => '2k'
        }
      ]
    },
    {
      'black' => [],
      'board_size' => undef,
      'handicap' => undef,
      'kifu_uri' => undef,
      'result' => 'Bye',
      'start_time' => undef,
      'white' => [
        {
          'name' => 'Lim',
          'rank' => '2k'
        }
      ]
    }
  ],
  'links' => {
    'entrants' => [
      {
        'link' => bless( do{\(my $o = 'http://www.gokgs.com/tournEntrants.jsp?sort=n&id=885')}, 'URI::http' ),
        'sort_by' => 'name'
      },
      {
        'link' => bless( do{\(my $o = 'http://www.gokgs.com/tournEntrants.jsp?sort=s&id=885')}, 'URI::http' ),
        'sort_by' => 'result'
      }
    ],
    'rounds' => [
      {
        'end_time' => '5/17/14 7:25 PM',
        'link' => bless( do{\(my $o = 'http://www.gokgs.com/tournGames.jsp?id=885&round=1')}, 'URI::http' ),
        'round' => '1',
        'start_time' => '5/17/14 7:05 PM'
      },
      {
        'end_time' => '5/17/14 7:45 PM',
        'link' => bless( do{\(my $o = 'http://www.gokgs.com/tournGames.jsp?id=885&round=2')}, 'URI::http' ),
        'round' => '2',
        'start_time' => '5/17/14 7:25 PM'
      },
      {
        'end_time' => '5/17/14 8:05 PM',
        'link' => bless( do{\(my $o = 'http://www.gokgs.com/tournGames.jsp?id=885&round=3')}, 'URI::http' ),
        'round' => '3',
        'start_time' => '5/17/14 7:45 PM'
      },
      {
        'end_time' => '5/17/14 8:25 PM',
        'link' => bless( do{\(my $o = 'http://www.gokgs.com/tournGames.jsp?id=885&round=4')}, 'URI::http' ),
        'round' => '4',
        'start_time' => '5/17/14 8:05 PM'
      },
      {
        'end_time' => '5/17/14 8:45 PM',
        'link' => bless( do{\(my $o = 'http://www.gokgs.com/tournGames.jsp?id=885&round=5')}, 'URI::http' ),
        'round' => '5',
        'start_time' => '5/17/14 8:25 PM'
      }
    ],
    'time_zone' => 'GMT'
  },
  'name' => 'May KGS+ Tournament, American Daytime 2k and under division',
  'next_round' => bless( do{\(my $o = 'http://www.gokgs.com/tournGames.jsp?id=885&round=4')}, 'URI::http' ),
  'previous_round' => bless( do{\(my $o = 'http://www.gokgs.com/tournGames.jsp?id=885&round=2')}, 'URI::http' ),
  'round' => '3'
}
