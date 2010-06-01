use strict;
use warnings;
use DBI;

my $dbh = DBI->connect( "dbi:SQLite:dbname=test", "", "" );

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
		value	 	TEXT DEFAULT NULL);}
    );
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS fields (
		field_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		name 		TEXT NOT NULL UNIQUE,
		type 		TEXT NOT NULL REFERENCES type (type));}
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
