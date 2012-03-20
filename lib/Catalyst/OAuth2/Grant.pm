package Catalyst::OAuth2::Grant;
use Moose::Role;

with 'Catalyst::OAuth2';

has response_type => ( is => 'ro', required  => 1 );
has client_id     => ( is => 'ro', required  => 1 );
has scope         => ( is => 'ro', predicate => 'has_scope' );
has state         => ( is => 'ro', predicate => 'has_state' );

around _params => sub {
  my $orig = shift;
  return $orig->(@_), qw(response_type scope state client_id)
};

1;
