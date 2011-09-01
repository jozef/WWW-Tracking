package WWW::Tracking::Data::Plugin::GoogleAnalytics;

use WWW::Tracking::Data;
use URI::Escape 'uri_escape';
use LWP::UserAgent;

our $UTM_GIF_LOCATION = 'http://www.google-analytics.com/__utm.gif';
our @URL_PAIRS = (
	'utmhn'  => 'hostname',              # Host Name, which is a URL-encoded string.
	'utmp'   => 'request_uri',           # Page request of the current page. 
	'utmr'   => 'referer',               # Referral, complete URL.
	'utmvid' => 'visitor_id',            #
	'utmip'  => 'remote_ip',             #
	'utmcs'  => 'encoding',              # Language encoding for the browser. Some browsers don't set this, in which case it is set to "-"
	'utmul'  => 'browser_language',      # Browser language.
	'utmje'  => 'java',                  # Indicates if browser is Java-enabled. 1 is true.
	'utmsc'  => 'screen_color_depth',    # Screen color depth
	'utmsr'  => 'screen_resolution',     # Screen resolution
	'utmfl'  => 'flash_version',         # Flash Version
);

sub _map2(&@){ 
    my $code = shift; 
    map $code->( shift, shift ), 0 .. $#_/2 
}
sub _grep2(&@){ 
    my $code = shift; 
    map{ 
        my @pair = (shift,shift); 
        $code->( @pair ) ? @pair : ()
    } 0 .. $#_/2 
}

sub _utm_url {
	my $class         = shift;
	my $tracking_data = shift;
	
	my $tracker_account = $tracking_data->_tracking->tracker_account;
	
	return
		$UTM_GIF_LOCATION
		.'?'
		.'&utmac='.$tracker_account                    # Account String. Appears on all requests.
		.'&utmn='.$class->_uniq_gif_id                 # Unique ID generated for each GIF request to prevent caching of the GIF image. 
		.'&utmcc=__utma%3D999.999.999.999.999.1%3B'    # Cookie values. This request parameter sends all the cookies requested from the page.
		.join(
			'',
			_map2 {
				my $prop = $_[1];
				'&'.$_[0].'='.uri_escape($tracking_data->$prop)
			}
			_grep2 { defined $_[1] }
			@URL_PAIRS
		)
	;
}

sub _uniq_gif_id {
	return int(rand(0x7fffffff));
}

1;

package WWW::Tracking::Data;

use Carp::Clan 'croak';

sub as_ga {
	my $self = shift;
	
	return WWW::Tracking::Data::Plugin::GoogleAnalytics->_utm_url($self);
}

sub make_tracking_request_ga {
	my $self = shift;
	
	my $ua = LWP::UserAgent->new;
	$ua->agent($self->user_agent);
	my $ga_output = $ua->get($self->as_ga);

	croak $ga_output->status_line
  		unless $ga_output->is_success;
	
	return $self;
}

1;

__END__

=head1 NAME

WWW::Tracking::Data::Plugin::GoogleAnalytics - serialize to Google Analytics URL

=head1 SYNOPSIS

	use WWW::Tracking;
	use WWW::Tracking::Data::Plugin::GoogleAnalytics;
	
    my $wt = WWW::Tracking->new(
        'tracker_account' => 'MO-9226801-5',
        'tracker_type'    => 'ga',
    );
    $wt->from(
		'headers' => {
			'headers'     => $headers,
			'request_uri' => $request_uri,
			'remote_ip'   => $remote_ip,
			'visitor_cookie_name' => $VISITOR_COOKIE_NAME,
		},
    );
    
    my $visitor_id = $wt->data->visitor_id;    
    my $tracking_cookie = Apache2::Cookie->new(
        $apache,
        '-name'    => $VISITOR_COOKIE_NAME,
        '-value'   => $visitor_id,
        '-expires' =>  '+3M',
        '-path'    =>  '/',
    );
    $tracking_cookie->bake($apache);
    
    eval { $wt->make_tracking_request; };
    if ($@) {
        $logger->warn('failed to do request tracking - '.$@);
    }

=head1 DESCRIPTION

=cut
