use strict;

package P4;

use LWP::UserAgent;
use Data::Dumper;
use HTML::TreeBuilder;
use HTTP::Cookies;

my $cookie_jar = HTTP::Cookies -> new();
my $ua = LWP::UserAgent->new( agent => "test",
  cookie_jar => $cookie_jar,
  show_progress => 1,
);
push @{ $ua->requests_redirectable }, 'POST';
my $req = HTTP::Request->new( GET => "https://bramka.play.pl");

my $res = $ua -> request( $req );

my $tree = HTML::TreeBuilder->new_from_content( $res -> content );
my $form = $tree -> look_down( _tag => "form" );
my @inputs = $form -> look_down( _tag => "input" );
my %form=();
foreach my $input ( @inputs ) {
  my $name = defined $input->{name} ? $input->{"name"} : "";
  $form{$name}=$input->{'value'};
}

$res = $ua -> post( $form -> {'action'}, \%form );

# Właściwe logowanie
$tree = HTML::TreeBuilder->new_from_content( $res -> content );
$form = $tree -> look_down( _tag => "form" );
@inputs = $form -> look_down( _tag => "input" );
%form=();
foreach my $input ( @inputs ) {
  my $name = defined $input->{name} ? $input->{"name"} : "";
  $form{$name}=$input->{'value'};
}
my $auth;
if ( -r "$ENV{HOME}/.play" ) { $auth = do "$ENV{HOME}/.play"; print "\nOK\n" };
$form{'IDToken1'} = $auth->{'login'} ? $auth->{'login'} : ""; # nr telefonu
$form{'IDToken2'} = $auth->{'password'} ? $auth->{'password'} : ""; # hasło

$res = $ua -> post( "https://logowanie.play.pl/".$form -> {'action'}, \%form );

my $tree = HTML::TreeBuilder->new_from_content( $res -> content );
my $form = $tree -> look_down( _tag => "form" );
my @inputs = $form -> look_down( _tag => "input" );
my %form=();
foreach my $input ( @inputs ) {
  my $name = defined $input->{name} ? $input->{"name"} : "";
  $form{$name}=$input->{'value'};
}

$res = $ua -> post( $form -> {'action'}, \%form );

my $tree = HTML::TreeBuilder->new_from_content( $res -> content );
my $form = $tree -> look_down( _tag => "form" );
my @inputs = $form -> look_down( _tag => "input" );
my %form=();
foreach my $input ( @inputs ) {
  my $name = defined $input->{name} ? $input->{"name"} : "";
  $form{$name}=$input->{'value'};
}

$res = $ua -> post( 'https://bramka.play.pl/composer/'.$form -> {'action'}, \%form );
# SMS compose
my $tree = HTML::TreeBuilder->new_from_content( $res -> content );
my $form = $tree -> look_down( _tag => "form" );
my @inputs = $form -> look_down( _tag => "input" );
my $textarea = $form -> look_down( _tag => 'textarea' );
my %form;
foreach my $input ( @inputs ) {
  my $name = defined $input->{name} ? $input->{"name"} : '';
  print "$name = \"$input->{'value'}\"\n";
  $form{$name}=$input->{'value'};
}
$form{recipients} = $ARGV[0];
$form{sendform} = 'on';
$form{$textarea->{name}}=<STDIN>;
$form{'content_out'}=$form{'content_in'};
$form{'old_content'}=$form{'content_in'};
$form{'czas'} = 0;
$res = $ua -> post( 'https://bramka.play.pl/composer/public/editableSmsCompose.do', \%form );
# SMS confirm
$res = $ua -> post( 'https://bramka.play.pl/composer/public/editableSmsCompose.do', { SMS_SEND_CONFIRMED => 'Wyślij' } );

print $res->content;
1;
