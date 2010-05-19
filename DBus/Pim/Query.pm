package DBus::Pim::Query;

=pod

=head1 NAME

DBus::Pim::Query - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = DBus::Pim::Query->new(
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
use Net::DBus::Exporter qw(org.freesmartphone.opimd);

our $VERSION = '0.01';

=pod

=head2 new

  my $object = DBus::Pim::Query->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<DBus::Pim::Query> object.

So no big surprises there...

Returns a new B<DBus::Pim::Query> or dies on error.

=cut

sub new {
	my $class   = shift;
	my $service = shift;
	my $self    = $class->SUPER::new($service,'/org/freesmartphone/PIM/Queries') 
	              or die 'Cannot create /org/freesmartphone/PIM/Queries';
	$self->{queries}= ();
	$self->{clients}= ();
	bless $self, $class;
	return $self;
}

=pod

=head2 Skip( $num_entries ) -> ()


It actualitzes the current cursor for the client movin it $num_entries entries forward.

=cut
dbus_method('Skip',["caller","int32"],[],'org.freesmatphone.Query',{param_names => ["num_entries"]});
sub Skip {
	my $self = shift;
	my $client = shift;
	my $num_entries = shift;

	# Do something here
	print "Saltando $num_entries registros para $client\n";

	return ();
}

=pod

=head2 Dispose () -> ()

Deataches the query form the client.

=cut
dbus_method('Dispose',['caller'],[],'org.freesmartphone.Query',{});
sub Dispose {
	my $self = shift;
	my $client = shift;
	
	print "el cliente $client ha finalizado con la Query \n";
	return ();
}

=pod

=head2 Rewind () -> ()

Sets teh cursor to the start of the query for the client.

=cut
dbus_method('Rewind',['caller'],[],'org.freesmartphone.Query',{});
sub Rewind {
	my $self = shift;
	my $client = shift;
	
	print "el cliente $client ha rebobinado la Query \n";
	return ();
}


=pod

=head2 GetResultCount () -> (int32)

Returns the number of records in the current query.

=cut

dbus_method('GetResultCount',[],["int32"],'org.freesmatphone.Query',{});
sub GetResultCount {
	my $self = shift;
	print "Retorno el numero de registros que es 12\n";
	return 12;
}

=pod

=head2 GetResult () -> (array string variant)

Returns the active record in the current query and client.

=cut

dbus_method('GetResult',['caller'],[['array','string','variant']],'org.freesmatphone.Query',{});
sub GetResult {
	my $self = shift;
	my $client = shift;
	print "Retorno el registro para $client:\n";
	my @result = [['numero',1],['nombre',"pepe perez"],["telefono","yo que se 49"]];
	
	return @result;
}

=pod

=head2 GetMultipleResults ($num_entries) -> (array[array string variant])

Returns the active record in the current query and client.

=cut

dbus_method('GetMultipleResults',['caller','int32'],[['array',['array','string','variant']]],'org.freesmatphone.Query',{param_names => ["num_entries"]});
sub GetMultipleResults {
	my $self = shift;
	my $client = shift;
	my $num_entries = shift;
	print "Retorno el $num_entries registro para $client:\n";
	my @result= [];
	push @result, GetResult($self,$client) for 1..$num_entries;
	return @result;
}

=pod

=head2  Added($path) -> ()

Signals that the query has a new element whith path $path.

=cut

dbus_signal('Added',['string'],'org.freesmatphone.Query',{param_names => ["Path"]});
sub Added {
	my $self = shift;
	my $path = shift;
	print "Retorno el $path:\n";
	return ();
}

=pod

=head2 GetPath () -> (string)

Returns the active object in the current query and client.

=cut

dbus_method('GetPath',['caller'],['string'],'org.freesmatphone.Query',{});
sub GetPath{
	my $self = shift;
	my $client = shift;
	print "Retorno el /org/freesmatphone/PIM/1  para $client:\n";
	return '/org/freesmatphone/PIM/1';
}

sub run{
print "I'm the main\n";
my $object = DBus::Pim::Query->new();
	
}

run() unless caller();

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2010 José Luis Pérez Diez.

=cut
