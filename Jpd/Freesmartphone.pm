package Jpd::Freesmartphone;

=pod

=head1 NAME

Jpd::Freesmartphone - My author was too lazy to write an abstract

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
use base qw(Net::DBus::Service);

#push @INC, "/home/jluis/Opimd/";
#use Jpd::Freesmartphone::PIM;

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
	my $bus   = shift;
	my $self  = $class->SUPER::new($bus,"jpd.freesmartphone.PIM");
	bless $self, $class;
#       Contrust here the fallback class	
#	$self->{manager} = Jpd::Freesmartphone::PIM->new($self);
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

Copyright 2009 Anonymous.

=cut
