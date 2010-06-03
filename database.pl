use strict;
use warnings;
use DBI;
use Data::Dumper;

my $dbh = DBI->connect( "dbi:SQLite:dbname=test", "", "" );

#I'm using this file as a brainstorming editor
#

=pod

=head1 Descrition

my @sqlite_Afinity = qw(integer text blob real);
my %types = ("name"=>["Process","COLLATE","INDEX","description"];...

=cut




sub create_tables {
    $dbh->do("PRAGMA foreign_keys = ON");
    my $sth= $dbh->table_info(undef,'%','%','TABLE');
    my $tables = $sth->fetchall_hashref('TABLE_NAME');
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS entry (
		id 		INTEGER PRIMARY KEY AUTOINCREMENT,
		value 		TEXT DEFAULT NULL);}
    ) unless defined($tables->{entry});
    if (not defined $tables->{domain}){
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS domain (
		domain_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		name 		TEXT NOT NULL UNIQUE,
		value 		TEXT DEFAULT NULL);}
        );
        $dbh->do(q{BEGIN TRANSACTION;});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'contacts','All kinds of contact requires a name');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'calls','Call log');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'messages','SMS storage & log');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'dates','dates storge');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'task','task storge');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'Notes','task storage');});
        $dbh->do(q{END TRANSACTION;});
    };
    $sth = $dbh->prepare_cached('SELECT "name","domain_id" from "domain";');
    $sth -> execute;
    my $domain_id = $sth->fetchall_hashref("name");
    print Dumper($domain_id);
    
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS tag (
		tag_id 		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		value		TEXT UNIQUE);}
    ) unless defined($tables->{tag});
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS phone (
		phone_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		phone 		TEXT NOT NULL,
		value 		TEXT UNIQUE);}
    ) unless defined $tables->{phone};
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS external (
		URI_id 		INTEGER PRIMARY KEY AUTOINCREMENT,
		URI 		TEXT NOT NULL UNIQUE);}
    )unless defined $tables->{external};
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS taged_entries (
		taged_entry_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		tag_id         	INTEGER NOT NULL REFERENCES tag (tag_id),
		id 		INTEGER NOT NULL REFERENCES entry (id));}
    )unless defined $tables->{taged_entries};
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS domain_entries (
		domain_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id) UNIQUE,
		domain_id 	INTEGER NOT NULL REFERENCES domain (domain_id));}
    ) unless defined $tables->{domain_entries};

    if (not defined $tables->{type}) {
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS type (
		type 		TEXT PRIMARY KEY ASC,
		affinity	TEXT NOT NULL,
		value	 	TEXT DEFAULT NULL);}
        );
        $dbh->do(q{BEGIN TRANSACTION;});
        $dbh->do(q{INSERT INTO type VALUES('text','text','Sqlite TEXT affinity');});
        $dbh->do(q{INSERT INTO type VALUES('integer','integer','Sqlite INTEGER affinity');});
        $dbh->do(q{INSERT INTO type VALUES('real','real','Sqlite REAL affinity');});
        $dbh->do(q{INSERT INTO type VALUES('blob','blob','Sqlite NONE affinity');});
        $dbh->do(q{INSERT INTO type VALUES('numeric','numeric','Sqlite NUMERIC affinity ');});
        $dbh->do(q{INSERT INTO type VALUES('name','text','A name for an entry Indexed');});
        $dbh->do(q{INSERT INTO type VALUES('phonenumber','phone','A telefon number to be processed');});
        $dbh->do(q{INSERT INTO type VALUES('phone','text','A canonical telefon number INDEXED');});
        $dbh->do(q{INSERT INTO type VALUES('photo','path','a file system path, processed');});
        $dbh->do(q{INSERT INTO type VALUES('path','text','an existing file path');});
        $dbh->do(q{INSERT INTO type VALUES('email','text','email related to an entry');});
        $dbh->do(q{INSERT INTO type VALUES('date','integer','a time stamp');});
        $dbh->do(q{INSERT INTO type VALUES('address','text','an address related to an entry');});
        $dbh->do(q{INSERT INTO type VALUES('boolean','integer','perlish way 0 = false');});
        $dbh->do(q{INSERT INTO type VALUES('number','numeric','when one need to store a number');});
        $dbh->do(q{INSERT INTO type VALUES('timezone','text',' I think it needs process');});
         $dbh->do(q{END TRANSACTION;});
    };
    
    if (not defined $tables->{fields}) {
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS fields (
		field_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		name 		TEXT NOT NULL UNIQUE,
		type 		TEXT NOT NULL REFERENCES type (type));}
        );
        $dbh->do(q{BEGIN TRANSACTION;});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'MessageSent','boolean');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Source','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Direction','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Content','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Peer','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'MessageRead','boolean');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Phone','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Surname','name');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Name','name');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Affiliation','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Photo','photo');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Work phone','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Note','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Email','email');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Birthday','date');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Mobile phone','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Timezone','timezone');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Adrress','address');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Nickname','name');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Home phone','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Answered','boolean');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Duration','real');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Timestamp','date');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'New','boolean');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Line','integer');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Type','text');});
        $dbh->do(q{END TRANSACTION;});
    };
    $sth = $dbh->prepare_cached('SELECT "name","field_id" from "fields";');
    $sth -> execute;
    my $field_id = $sth->fetchall_hashref("name");
    print Dumper($field_id);
    
    if (not defined $tables->{domain_fields}) {
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS domain_fields (
		field_domain_id INTEGER PRIMARY KEY AUTOINCREMENT,
		domain_id 	INTEGER NOT NULL REFERENCES domain (domain_id),
		field_id 	INTEGER NOT NULL  DEFAULT NULL REFERENCES fields (field_id),
		grup		TEXT DEFAULT NULL);}
        );
        my $sth -> $dbh -> prepare_cached(q{INSERT INTO domain_fields VALUES(NULL,?,?,?);});
        $dbh->do(q{BEGIN TRANSACTION;});
        $sth-> execute($domain_id->{contacts},$field_id->{Surame},"name");
        $sth-> execute($domain_id->{contacts},$field_id->{Name},"name");
        $sth-> execute($domain_id->{contacts},$field_id->{Nickname},"name");
        $sth-> execute($domain_id->{contacts},$field_id->{Phone},"address");
        $sth-> execute($domain_id->{contacts},$field_id->{Home phone},"address");
        $sth-> execute($domain_id->{contacts},$field_id->{Mobile phone},"address");
        $sth-> execute($domain_id->{contacts},$field_id->{Work phone},"address");
        $sth-> execute($domain_id->{contacts},$field_id->{Email},"address");
        $sth-> execute($domain_id->{contacts},$field_id->{Address},"address");
        $sth-> execute($domain_id->{calls},$field_id->{Peer},"");
        $sth-> execute($domain_id->{messages},$field_id->{Peer},"name");
        $dbh->do(q{END TRANSACTION;});
    };
    
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS boolean_fields (
		boolean_field_id INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id),
		field_id 	INTEGER NOT NULL REFERENCES fields (field_id),
		value 		INTEGER NOT NULL);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS date_fields (
		date_field_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id),
		field_id 	INTEGER NOT NULL REFERENCES fields (field_id),
		value 		INTEGER NOT NULL);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS internal_fields (
		internal_field_id INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id),
		field_id 	INTEGER NOT NULL REFERENCES fields (field_id),
		value 		INTEGER NOT NULL REFERENCES entry (id));}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS generic_fields (
		generic_field_id INTEGER DEFAULT NULL PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id),
		field_id 	INTEGER NOT NULL  DEFAULT NULL REFERENCES fields (field_id),
		value 		TEXT NOT NULL DEFAULT NULL);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS phone_fields (
		phone_field_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id),
		field_id 	INTEGER NOT NULL REFERENCES fields (field_id),
		phone_id 	INTEGER NOT NULL REFERENCES phone (phone_id));}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS name_fields (
		name_field_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id),
		field_id 	INTEGER NOT NULL REFERENCES fields (field_id),
		value 		TEXT NOT NULL DEFAULT NULL);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS external_field (
		external_field_id INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id),
		field_id 	INTEGER NOT NULL REFERENCES fields (field_id),
		URI_id 		INTEGER NOT NULL REFERENCES external (URI_id));}
    );

    #
    # CREATE INDEX  ON Entry_Tags (tag_id);
    # CREATE INDEX  ON Entry_Tags (id);
    # CREATE INDEX  ON Entry_Domain (Domain_id);
    # CREATE INDEX normalized_Phone ON Phone (Value);
    # CREATE INDEX field_type ON Fields (Type);
    # CREATE INDEX boolean_entry_id ON Boolean_field (id);
    # CREATE INDEX boolean_field_id ON Boolean_field (Field_id);
    # CREATE INDEX internal_entry_id ON Internal_field (id);
    # CREATE INDEX internal_value ON Internal_field (value);
    # CREATE INDEX internal_field_id ON Internal_field (field_id);
    # CREATE INDEX phone_entry_id ON phonenumber_field (id);
    # CREATE INDEX phone_field_id ON phonenumber_field (field_id);
    # CREATE INDEX phone_id ON phonenumber_field (phone_id);
    #
}
create_tables();
