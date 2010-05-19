#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;

use Net::DBus;
use Net::DBus::Reactor;

sub catch_all {
   my $connection = shift;
   my $message    = shift;
   say "on catch all";
   say "Type        ".$message->get_type;
   say "Interface   ".$message->get_interface;
   say "Path        ".$message->get_path;
   say "Name        ".$message->get_destination;
   say "enviado por ".$message->get_sender;
   say "id          ".$message->get_serial;
   say "miembro     ".$message->get_member;
   say "firma       ".$message->get_signature;
   
}

push @INC, $ENV{HOME}."/pfpim";
use Jpd::Freesmartphone;
use Jpd::Freesmartphone::PIM;
   my $bus = Net::DBus->find or die "i can't find it";
   my $service = $bus->export_service("jpd.freesmartphone.PIM");
   
   $bus->get_connection->register_fallback("/jpd/freesmartphone",\&catch_all);
   
   my $player = Jpd::Freesmartphone->new($bus);
   my $object = Jpd::Freesmartphone::PIM->new($player);

   Net::DBus::Reactor->main->run;

   exit 0;
