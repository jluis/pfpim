use strict;
use warnings;
use DBI;

my $dbh = DBI->connect( "dbi:SQLite:dbname=test", "", "" );

#I'm using this file as a brainstorming editor
#

=pod

=head1 Descrition

my @sqlite_Afinity = qw(integer text blob real);
my %types = ("name"=>["Process","COLLATE","INDEX","description"];...

=cut




sub create_tables {
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS entry (
		id 		INTEGER PRIMARY KEY AUTOINCREMENT,
		value 		TEXT DEFAULT NULL);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS domain (
		domain_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		name 		TEXT NOT NULL UNIQUE,
		value 		TEXT DEFAULT NULL);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS tag (
		tag_id 		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		value		TEXT UNIQUE);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS phone (
		phone_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		phone 		TEXT NOT NULL,
		value 		TEXT UNIQUE);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS external (
		URI_id 		INTEGER PRIMARY KEY AUTOINCREMENT,
		URI 		TEXT NOT NULL UNIQUE);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS taged_entries (
		taged_entry_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		tag_id         	INTEGER NOT NULL REFERENCES tag (tag_id),
		id 		INTEGER NOT NULL REFERENCES entry (id));}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS domain_entries (
		domain_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
		id 		INTEGER NOT NULL REFERENCES entry (id) UNIQUE,
		domain_id 	INTEGER NOT NULL REFERENCES domain (domain_id));}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS type (
		type 		TEXT PRIMARY KEY,
		affinity	TEXT NOT NULL DEFAULT 'TEXT'
		value	 	TEXT DEFAULT NULL);}
		
    );
    $dbH-do(
	q{
	    BEGIN TRANSACTION;
		INSERT INTO type VALUES('name','text','A name for an entry Indexed');
		INSERT INTO type VALUES('phonenumber','phone','A telefon number to be processed');
		INSERT INTO type VALUES('phone','text','A canonical telefon number INDEXED');
		INSERT INTO type VALUES('photo','path','a file system path, processed');
		INSERT INTO type VALUES('path','text','an existing file path');
		INSERT INTO type VALUES('email','text','email related to an entry');
		INSERT INTO type VALUES('date','integer','a time stamp');
		INSERT INTO type VALUES('address','text','an address related to an entry');
		INSERT INTO type VALUES('boolean','integer','perlish way 0 = false');
		INSERT INTO type VALUES('number','real','when one need to store a number');
		INSERT INTO type VALUES('timezone','text',' I think it needs process');
	    COMMIT;}
    );
	  
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS fields (
		field_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		name 		TEXT NOT NULL UNIQUE,
		type 		TEXT NOT NULL REFERENCES type (type));}
    );
    $dbh->do(q{
        BEGIN TRANSACTION;
	    INSERT INTO fields VALUES(NULL,'MessageSent','boolean');
            INSERT INTO fields VALUES(NULL,'Source','text');
            INSERT INTO fields VALUES(NULL,'Direction','text');
            INSERT INTO fields VALUES(NULL,'Content','text');
            INSERT INTO fields VALUES(NULL,'Peer','phonenumber');
            INSERT INTO fields VALUES(NULL,'MessageRead','boolean');
	    INSERT INTO fields VALUES(NULL,'Phone','phonenumber');
            INSERT INTO fields VALUES(NULL,'Surname','name');
            INSERT INTO fields VALUES(NULL,'Name','name');
            INSERT INTO fields VALUES(NULL,'Affiliation','text');
            INSERT INTO fields VALUES(NULL,'Photo','photo');
            INSERT INTO fields VALUES(NULL,'Work phone','phonenumber');
            INSERT INTO fields VALUES(NULL,'Note','text');
            INSERT INTO fields VALUES(NULL,'Email','email');
            INSERT INTO fields VALUES(NULL,'Birthday','date');
            INSERT INTO fields VALUES(NULL,'Mobile phone','phonenumber');
            INSERT INTO fields VALUES(NULL,'Timezone','timezone');
            INSERT INTO fields VALUES(NULL,'Adrress','address');
            INSERT INTO fields VALUES(NULL,'Nickname','name');
            INSERT INTO fields VALUES(NULL,'Home phone','phonenumber');
	    INSERT INTO fields VALUES(NULL,'Answered','boolean');
            INSERT INTO fields VALUES(NULL,'Duration','real');
            INSERT INTO fields VALUES(NULL,'Timestamp','date');
            INSERT INTO fields VALUES(NULL,'New','boolean');
            INSERT INTO fields VALUES(NULL,'Line','integer');
            INSERT INTO fields VALUES(NULL,'Timezone','timezone');
            INSERT INTO fields VALUES(NULL,'Type','text');
	COMMIT;}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS domain_fields (
		field_domain_id INTEGER PRIMARY KEY AUTOINCREMENT,
		domain_id 	INTEGER NOT NULL REFERENCES domain (domain_id),
		field_id 	INTEGER NOT NULL  DEFAULT NULL REFERENCES fields (field_id),
		grup		TEXT DEFAULT NULL);}
    );
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
