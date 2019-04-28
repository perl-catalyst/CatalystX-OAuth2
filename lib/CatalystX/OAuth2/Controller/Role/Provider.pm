package CatalystX::OAuth2::Controller::Role::Provider;
use Moose::Role;
use MooseX::SetOnce;
use Moose::Util;
use Class::Load;

# ABSTRACT: A role for writing oauth2 provider controllers

with 'CatalystX::OAuth2::Controller::Role::WithStore';

has $_ => (
  isa       => 'Catalyst::Action',
  is        => 'rw',
  traits    => [qw(SetOnce)],
  predicate => "_has_$_"
) for qw(_request_auth_action _get_auth_token_via_auth_grant_action);

around create_action => sub {
  my $orig   = shift;
  my $self   = shift;
  my $name   = {@_}->{name};
  if ( $name =~ /(request|grant)/ ) {
    my $action_config = $self->config->{action} && $self->config->{action}{$name};
    push @_, (%$action_config) if $action_config;
  }

  my $action = $self->$orig(@_);
  if (
    Moose::Util::does_role(
      $action, 'Catalyst::ActionRole::OAuth2::RequestAuth'
    )
    )
  {
    $self->_request_auth_action($action);
  } elsif (
    Moose::Util::does_role(
      $action, 'Catalyst::ActionRole::OAuth2::GrantAuth'
    )
    )
  {
    $self->_get_auth_token_via_auth_grant_action($action);
  }

  return $action;
};

sub check_provider_actions {
  my ($self) = @_;
  die
    q{You need at least an auth action and a grant action for this controller to work}
    unless $self->_has__request_auth_action
      && $self->_has__get_auth_token_via_auth_grant_action;
}

after register_actions => sub {
  shift->check_provider_actions;
};

1;
