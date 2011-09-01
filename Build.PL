use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Tracking',
    license             => 'perl',
    dist_author         => 'Jozef Kutej <jkutej@cpan.org>',
    dist_version_from   => 'lib/WWW/Tracking.pm',
    requires => {
        'Class::Accessor::Fast' => 0,
        'Carp::Clan'     => 0,
        'CGI::Cookie'    => 0,
        'Digest::MD5'    => 0,
        'HTTP::Headers'  => 0,
        'LWP::UserAgent' => 0,
        'Scalar::Util'   => 0,
        'URI::Escape'    => 0,
    },
    build_requires => {
        'Test::More'        => 0,
        'Test::Differences' => 0,
    },
    add_to_cleanup => [ 'WWW-Tracking-*' ],
    create_readme  => 1,
    sign           => 1,
    meta_merge => {
        resources => {
            repository => 'http://github.com/jozef/WWW-Tracking',
            bugtracker => 'http://github.com/jozef/WWW-Tracking/issues',
        },
        keywords => [ qw/ web www tracking analytics / ],
    },
);
$builder->create_build_script();
