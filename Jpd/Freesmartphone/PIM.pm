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
use Net::DBus qw(:typing);

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
dbus_method("Register_Query",[qw(string string)],[["variant"]],#);
	{param_names => [qw(query_name domain)],return_names => ['queryid']});
sub Register_Query {
	my $self = shift;
	my $name = shift;
        my $query = shift;
        my $id = 1 - push @{$self->{queries}},$query;
	# Do something here
        print "(Name:$name query $query)/n";
	return $id;


}
=pod

=head @empty_list = $pimobject->AddField ($name,$type)

Creates a field with name $name and type $type for $pimobject.

=cut

dbus_method("AddField",
	["string","string"],[],
	'org.freesmartphone.PIM.Fields',
	{param_names => [qw(name type)]});
	
sub AddField {
	my $self = shift;
	my $name = shift;
	my $type = shift;
	#Place holder
        print "adding $name,$type\n";
        return ();
        
}

=pod

=head @empty_list = $pimobject->DeleteField ($name)

Deletes a field with name $name and type $type for $pimobject.

=cut

dbus_method("DeleteField",
	["string"],[],
	'org.freesmartphone.PIM.Fields',
	{param_names => [qw(name)]});
	
sub DeleteField {
	my $self = shift;
	my $name = shift;
	#Place holder
        print "deleting $name\n";
        return ();
        
}

=pod

=head $type = $pimobject->AddField ($name)

Returns the type of the field with name $name.

=cut

dbus_method("GetType",
	["string"],["string"],
	'org.freesmartphone.PIM.Fields',
	{param_names => [qw(name)],
	 return_names => ["type"]});
	
sub GetType {
	my $self = shift;
	my $name = shift;
	my $type = "type_of($name)";
	#Place holder
        print "$name es un $type\n";
        return $type;
        
}

=pod

=head @usedfields = $pimobject->ListFields()

Returns an array of (name,type) for the fields defined in $pimobject.

=cut

dbus_method("ListFields",
	[],[["array",["struct","string","string"]]],
	'org.freesmartphone.PIM.Fields',
	{return_names => ["fields"]});
	
sub ListFields {
	my $self = shift;
	#Place holder
	my @result = (
		[qw(nombre string)],
		[qw(telefono string)],
		[qw(cumpleanos fecha)],
		[qw(foto blob)]);
		
		
		
	for (@result) {
		my ($name,$type) = @{$_};
		print "adding $name,$type\n";};
        return [@result];
        
}

=pod

=head @usedfields = $pimobject->ListFieldsWithType($type)

Returns an array of names for the fields with type $type defined in $pimobject.

=cut

dbus_method("ListFieldsWithType",
	["string"],[["array","string"]],
	'org.freesmartphone.PIM.Fields',
	{param_names => ["type"],
	 return_names => ["fields"]});
	
sub ListFieldsWithType {
	my $self = shift;
	my $type = shift;
	#Place holder
	my @result;
	for (0,1,2,3) {
		print push @result,"$type$_";
	}
        return [@result];
}

=pod

=head @tipos = $pimobject->List()

Returns an array of the available field types for $pimobject.

=cut

dbus_method("List",
	[],[["array","string"]],
	'org.freesmartphone.PIM.Types',
	{return_names => ["types"]});
	
sub List {
	my $self = shift;
	#Place holder
	my @result = qw(entryid  name longtext
		generic photo  objectpath number
		uri timezone boolean phonenumber
		address date integer text email);
	print "listing types\n";
        return [@result];
        
}

=pod

=head @EntryData = $pimobject->GetContent()

Returns an array of tuples fieldname, value types for $pimobject.

=cut

dbus_method("GetContent",
	[],[["array",["struct","string",["variant"]]]],
	'org.freesmartphone.PIM.Entry',
	{return_names => ["entry_data"]});
	
sub GetContent{
	my $self = shift;
	#Place holder
	my @result = (["nombre","jose luis"],
	              ["telefono","+34943298907"],
	              ["entero",dbus_int32(12)],
	              ["real",dbus_double(2.14)]);
	print "listing types\n";
        return [@result];
        
}


=pod

=head @EntryData = $pimobject->GetMultipleFields($field_list)

Returns an array of tuples fieldname, value types for $field_list in $pimobject.

=cut

dbus_method("GetMultipleFields",
	["string"],[["array",["struct","string",["variant"]]]],
	'org.freesmartphone.PIM.Entry',
	{param_names => ["field_list"],
 	 return_names => ["field_data"]});
	
sub GetMultipleFields{
	my $self = shift;
	my $field_list = shift;
	#Place holder
	print "$field_list\n";
	my @fields = split ",",$field_list;
	my @result;
	for my $field (@fields) {
		push @result, [$field,"value_of_$field"];
	}
	print "listing types\n";
        return [@result];
        
}
=pod

=head @EntryBackends = $pimobject->GetUsedBackends()

Returns an array of the names of the backends used for $pimobject.

=cut

dbus_method("GetUsedBackends",
	[],[["array","string"]],
	'org.freesmartphone.PIM.Entry',
	{return_names => ["backends"]});
	
sub GetUsedBackends{
	my $self = shift;
	#Place holder
	my @result = qw(Perl SQLite otros);
	
	print "listing types\n";
        return [@result];
        
}

=pod

=head $pimobject->GetUpdate($entry_data)

Updates the fields valule tuples of in $entry_data for $pimobject

=cut

dbus_method("Update",
	["caller",["array",["struct","string",["variant"]]]],[],
	'org.freesmartphone.PIM.Entry',
	{param_names => ["contact_data"]});
	
sub Update{
	my $self = shift;
	my $client = shift;
	my $contact_data = shift;
	#Place holder
	for my $field (@{$contact_data}) {
		my ($name,$value) = @{$field};
		print "updating [$name $value]\n";
	}
	#emitir la señal for Entry
	$self->emit_signal_in("Updated",'org.freesmartphone.PIM.Entry',$client,$contact_data);
	#emitir la señal para Entries
	$self->emit_signal_in("Updated",'org.freesmartphone.PIM.Entries',undef,[$self->get_object_path,$contact_data]);
	#check if is in a query to send the corresponding signal 
        return ();
        
}


=pod

=head $pimobject->Delete();

Deletes $pimobject

=cut

dbus_method("Delete",
	["caller"],[],
	'org.freesmartphone.PIM.Entry',
	{});
	
sub Delete{
	my $self = shift;
	my $client = shift;
	print "Deleting\n";
	#Emit signal to caller
	$self->emit_signal_in("Deleted",'org.freesmartphone.PIM.Entry',$client);
	#Emit signal for Entries interface
	$self->emit_signal_in("Deleted",'org.freesmartphone.PIM.Entries',undef,$self->get_object_path);
	#code for checking presence on queries
        return ();
}
=pod

=head Emited signals;

Deleted();
Updated($contact_data);

=cut

dbus_signal("Deleted",[],'org.freesmartphone.PIM.Entry',{});
dbus_signal("Updated",[["array",["struct","string",["variant"]]]],
	'org.freesmartphone.PIM.Entry',{});

=pod

=head $path = $pimobject->Add($entry_data);

Creates a new entry for the array of tuples(fieldname, value)
$entry_data in $pimobject and returns the path of the new 
Entry object.

=cut




dbus_method("Add",
	[["array",["struct","string",["variant"]]]],
	["string"],
	'org.freesmartphone.PIM.Entries',
	{param_names => ["entry_data"],
 	 return_names => ["path"]});
	
sub Add{
	my $self = shift;
	my $entry_data = shift;
	#Place holder
	my @fields = @{$entry_data};
	for my $field (@fields) {
		my ($field_name,$value) = @{$field};
		print "$field_name := $value\n";
	}
	print "listing types\n";
	my $path = "me se el camino";
	#enviamos la senal
	$self->emit_signal_in("New",'org.freesmartphone.PIM.Entries',undef,$path);
	#procesar para la query
        return ($path);
        
}


=pod

=head $Que = $pimobject->GetSingleEntrySingleField{$query,$field_name);

Returns the value of $field_name from a result to  the query


=cut




dbus_method("GetSingleEntryField",
	[["array",["struct","string",["variant"]]],"string"],
	[["variant"]],
	'org.freesmartphone.PIM.Entries',
	{param_names => [qw(query field)],
 	 return_names => ["value"]});
	
sub GetSingleEntryField{
	my $self = shift;
	my $query = shift;
	my $field = shift;
	#Place holder
	for my $entry  (@{$query}) {
		my ($key,$value) = @{$entry};
		print "$key: $value\n";
	}
	print "$field\n";
        return "soy yo";
        
}


=pod

=head $Query_path = $pimobject->Query{$query,$field_name);

Returns the path of the object to retirve the results of the query
a query is an array of tuples 
$Key.$prexix."name", Value;
$Key is in (">" "<") 
Fieldname if $prefix = "";
Type if $prefix = "$";
Domain if $prefix = "@";
Special if prexix = "_";

=cut

dbus_method("Query",
	[["array",["struct","string",["variant"]]]],
	["string"],
	'org.freesmartphone.PIM.Entries',
	{param_names => [qw(query)],
 	 return_names => ["query_path"]});
	
sub Query{
	my $self = shift;
	my $query = shift;
	#Place holder
	for my $entry  (@{$query}) {
		my ($key,$value) = @{$entry};
		print "$key: $value\n";
	}
	print "hecho\n";
        return "/jpd/freesmartphone/PIM/Queries";
        
}

dbus_signal("New",["objectpath"],'org.freesmartphone.PIM.Entries',
	{param_names =>[qw(contact_path)]});
dbus_signal("Updated",["objectpath",["array",["struct","string",["variant"]]]],
	'org.freesmartphone.PIM.Entries',{param_names =>[qw(entry_path entry_data)]});
dbus_signal("Deleted",["objectpath"],
	'org.freesmartphone.PIM.Entries',{param_names =>[qw(contact_path)]});

=pod

=head2 Skip( $num_entries ) -> ()


It actualitzes the current cursor for the client movin it $num_entries entries forward.

=cut
dbus_method('Skip',["caller","int32"],[],'org.freesmatphone.Query',
	{param_names => ["num_entries"]});
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

dbus_method('GetResultCount',[],["int32"],'org.freesmatphone.Query',
	{return_names=>[qw(count)]});
	
sub GetResultCount {
	my $self = shift;
	print "Retorno el numero de registros que es 12\n";
	return 12;
}

=pod

=head2 GetResult () -> (array string variant)

Returns the active record in the current query and client.

=cut

dbus_method('GetResult',['caller'],[['array',['struct','string',["variant"]]]],
	'org.freesmatphone.Query',{return_names=>[qw(item)]});
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

dbus_method('GetMultipleResults',['caller','int32'],
	[['array',['array',['struct','string',["variant"]]]]],
	'org.freesmatphone.Query',
	{param_names =>[qw(num_entries)],return_names =>[qw(resultset)]});
sub GetMultipleResults {
	my $self = shift;
	my $client = shift;
	my $num_entries = shift;
	print "Retorno el $num_entries registro para $client:\n";
	my @result;
	push @result, GetResult($self,$client) for 1..$num_entries;
	return [@result];
}

=pod

=head2  Added($path) -> ()

Signals that the query has a new element whith path $path.

=cut

dbus_signal('Added',['objectpath'],'org.freesmatphone.Query',{param_names => ["Path"]});
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
my $object = __PACKAGE__->new();
	
}

run() unless caller();

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2009 Anonymous.

=cut
