#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;

use Net::DBus;
use Net::DBus::Reactor;
use Data::Dumper;

sub catch_all {
   my $con = shift;
   my $msg    = shift;
   say "on catch all";
   say "Type        ".$msg->get_type;
   say "Interface   ".$msg->get_interface;
   say "Path        ".$msg->get_path;
   say "Name        ".$msg->get_destination;
   say "enviado por ".$msg->get_sender;
   say "id          ".$msg->get_serial;
   say "miembro     ".$msg->get_member;
   say "firma       ".$msg->get_signature;
   return if $msg->get_no_reply();
   say "waiting ack ";
   my @arguments = $msg->get_args_list;
   say "($_)" for @arguments;
   
   push @arguments,"on catch all";
   my $reply = $con->make_method_return_message($msg);
   $reply->append_args_list(@arguments);
   $con->send($reply);
   return 1;
   
}

push @INC, $ENV{HOME}."/pfpim";
use Jpd::Freesmartphone;
use Jpd::Freesmartphone::PIM;
   my $bus = Net::DBus->find or die "i can't find it";
   my $service = $bus->export_service("jpd.freesmartphone.PIM");
   
   $bus->get_connection->register_fallback("/jpd/freesmartphone",\&catch_all);
   
   my $player = Jpd::Freesmartphone->new($bus);
   my $object = Jpd::Freesmartphone::PIM->new($player);
   
   #print Dumper($object);
   
   Net::DBus::Reactor->main->run;

   exit 0;
