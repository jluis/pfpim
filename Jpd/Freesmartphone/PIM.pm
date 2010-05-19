package Jpd::Freesmartphone::PIM;

=pod

=head1 NAME

Jpd::Freesmartphone::PIM - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = Module::Name->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->dummy;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use 5.8.8;
use strict;
use warnings;
use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(jpd.freesmartphone.pim);

our $VERSION = '0.01';

=pod

=head2 new

  my $object = Module::Name->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<Module::Name> object.

So no big surprises there...

Returns a new B<Module::Name> or dies on error.

=cut

sub new {
	my $class = shift;
	my $service = shift;
	print "$service 1 \n";
	my $self  = $class->SUPER::new($service,
		"/jpd/freesmartphone/PIM");
	print "servicio 2 \n";	
	bless $self, $class;
	print "servicio 3 \n";
#We need some structure to reutilitze the queries
        $self->{Queries} = ();
        print "servicio 4 \n";
	return $self;
}

=pod

=head2 Register_Query

This method does something... apparently.

=cut
dbus_method("Register_Query",["string","string"],["int64"]);
sub Register_Query {
	my $self = shift;
	my $name = shift;
        my $query = shift;
        my $id = 1 - push @{$self->{queries}},$query;
	# Do something here
        print "(Name:$name query $query)/n";
	return $id;

}


1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2009 Anonymous.

=cut
