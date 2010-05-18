package Dbus::Pim;

=pod

=head1 NAME

Dbus::Pim - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $service_name = 'org.beer.bar';
  my $object = Dbus::Pim->new( $bus,$sevice_name);
  
  my $name = $object->get_service_name;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';
use base qw(Net::DBus::Service);

=pod

=head2 new

  my $object = Dbus::Pim->new(Net::DBus->find,'org.beer.bar');

The C<new> constructor lets you create a new B<Dbus::Pim> object.

So no big surprises there...

Returns a new B<Dbus::Pim> or dies on error.

=cut

sub new {
	my $class = shift;
	my $bus   = shift;
	my $name  = shift || 'org.freesmartphone.opim';
	my $self  = $class->SUPPER::new($bus,$name) || die "I cannot own service $name"; 
	bless $self, $class;
	####################################
	# I must prepare it to react to al messages
	####################################
	return $self;
}

=pod

=head2 dummy

This method does something... apparently.

=cut

sub dummy {
	my $self = shift;

	# Do something here

	return 1;
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2010 Anonymous.

=cut
