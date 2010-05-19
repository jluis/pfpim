package DBus::Pim;

=pod

=head1 NAME

DBus::Pim - Generates a dbus PIM storage service

=head1 SYNOPSIS

  my $service_name = 'org.beer.bar';
  my $object_path  = '/foo/beer/bar';
  my $object = DBus::Pim->new( $bus,$sevice_name,$path);
  
  my $name = $object->get_service_name;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';
use Net::DBus;
use Net::DBus::Object;
use Net::DBus::Dumper;
use Net::DBus::Exporter "org.freedesktop.DBus.Introspectable";
=pod

=head2 new

  my $object = DBus::Pim->new($bus,$name,$path);

The C<new> constructor lets you create a new B<DBus::Pim> object atached to the dBus $bus 
withing as service $name with the fallback object staring on path$ .

So no big surprises there...

Returns a new B<DBus::Pim> or dies on error.

=cut

sub crea {
	my $class   = shift;
	my $bus     = shift;
	my $name    = shift || 'org.freesmartphone.opim';
	my $service = $bus->export_service($name)||die "I cannot own service $name";
	my $path    = shift || '/org/freesmartphone/PIM';
	my $self    = new($service,$path) || die "I cannot run object $path"; 
	my $con     = $bus->get_connection || die "I cannot get the connection";
	$con->register_fallback($path."/casa",\&dinamicpath);
	bless $self, $class;
	return $self;
}

=pod

=head2 dinamicpath($connection,$message)

This method gets called when a none of the declared object can process the message it 
recives $conection a Net::DBus::Binding::Connection and a $message  Net::DBus::Binding::Message
=cut

sub dinamicpath {
	my $con  = shift;
	my $msg = shift;

	# we just print some contents
	print "type          ".$msg->get_type."\n";
	print "interface     ".$msg->get_interface."\n";
	print "path          ".$msg->get_path."\n";
	print "destination   ".$msg->get_destination."\n";
	print "sender        ".$msg->get_sender."\n";
	print "serial        ".$msg->get_serial."\n";
	print "method/signal ".$msg->get_member."\n";
	print "signature     ".$msg->get_signature."\n";
	print "waiting reply ".$msg->get_no_reply()."\n";
	my @arguments = $msg->get_args_list;
	print "($_)\n" for @arguments;

	return 1;
}

# sub Introspect {
	# my $self = shift;
	# print dbus_dump($self);
	# my $introspector = $self->_introspector;
	# my $xml = $introspector->format($self);
	# return $xml;
	# }
	# 
sub run{
    print "comenzando la prueba\n";
    my $bus     = Net::DBus->find();
    
    my $object = DBus::Pim->new($bus,'org.jpd','/org/jpd');
    
 #   print dbus_dump($object);
    use Net::DBus::Reactor;
    my $reactor = Net::DBus::Reactor->main();

    $reactor->run();
    print "Acabando\n"
}


run() unless caller();


1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2010 Anonymous.

=cut
