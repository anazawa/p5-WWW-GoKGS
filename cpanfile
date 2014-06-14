requires 'Carp';
requires 'parent';
requires 'URI';
requires 'Web::Scraper';
requires 'Exporter';
requires 'LWP::UserAgent';
requires 'Scalar::Util';
requires 'String::CamelCase';

on test => sub {
    requires 'Test::More' => '0.98';
    requires 'Test::Exception';
    requires 'Test::Pod'  => '1.45';
    requires 'Path::Class';
    requires 'Time::Piece';
};

on develop => sub {
    requires 'Module::Install';
    requires 'Module::Install::CPANfile';
    requires 'Module::Install::ReadmeFromPod';
};
