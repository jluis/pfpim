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

Joerg Reisenweber Phone number Normalization algoritm

normalized number = "+<CC><HC><NUMBER>"
non-normalized my be: <NUMBER> | <NationalPrefix><anyHC><NUMBER> | 
<InterntlPrefix><anyCC><anyHC><NUMBER>

so: 
Nr1 := Nr s/<IP>(.*)/\+$1/           #00 49 911 12345 -> + 49 911 12345
Nr2 = Nr1 s/<NP>/\+<CC>/             # 0 911 12345 ->  + 49 911 12345
Nr3 = Nr2 s/[^\+](.*)/\+<CC><HC>$1/  # 12345 ->  + 49 911 12345
step3 above isn't considered very practical for cellphones
<IP>, <CC>, <NP>, and <HC> are user definable config-values

apply normalization to both numbers prior to strcmp() only - no mangeling of 
numbers on storing, dialing, display to user

nota bene: inbound call numbers are considered fully normalized (per GSM 
definition). If you like to cope with non-standards-conforming inbound 
numbers, you need a means to acquire CC' of the network currently in use, and 
use this CC' instead of CC for normalizing the inbound number.

a good idea might be to cut all spaces as well, and also truncate any 
leading/trailing netcode sequences like *31#+49 911 12345 W;1**3 (truncate 
from left side and from right side all short sequences including any 
non-numeric+"+" delimeter, this is "*31#" (excluding the "+"!) for left, 
and "W;1**3" for right. Admittedly this part is tricky. 
Left side truncation is mandatory, right side a nice-to-have)

jr@halley:~> . bin/normalizelib
jr@halley:~> # set InternationalPrefix, NationalPrefix, CountryCode, AreaCode
jr@halley:~> IP=00
jr@halley:~> NP=0
jr@halley:~> CC=49
jr@halley:~> AC=30
jr@halley:~> normalize "*31#0049 (0) 30 12300 - 456W*1200*#"
+493012300456
jr@halley:~>normalize "0049 30 123 00 456"
+493012300456
jr@halley:~> normalize "030 123 00 456;foo"
+493012300456
jr@halley:~> normalize "123 00 456"
+493012300456
jr@halley:~> 
jr@halley:~> cat bin/normalizelib
normalize(){
 echo "${1}" | sed "s/[wWpP\;\,].*//; s/[ -]//g; s/\([0-9]\)
(${NP})\([0-9]\)/\1\2/; s/.*[^0-9+]//; s/^${IP}/\+/; s/^${NP}/\+${CC}/; 
s/^\([^\+]\)/\+${CC}${AC}\1/"
}jr@halley:~>


Details:
s/[wWpP\;\,].*//; == cut trailing crap, actually only a few valid delimiters
s/[ -]//g; == remove filler chars, may add others here. User-config?
s/\([0-9]\)(${NP})\([0-9]\)/\1\2/; == remove stupid intersparsed NP
s/.*[^0-9+]//; == remove leading netcodes
s/^${IP}/\+/; == substitute IP with "+"
s/^${NP}/\+${CC}/; == substitute NP with "+"<CC>
s/^\([^\+]\)/\+${CC}${AC}\1/" == process local numbers (no "+", IP, NP)







=cut


sub create_tables {
    $dbh->do("PRAGMA foreign_keys = ON");
    my $sth = $dbh->table_info( undef, '%', '%', 'TABLE' );
    my $tables = $sth->fetchall_hashref('TABLE_NAME');
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS entry (
		id 		INTEGER PRIMARY KEY AUTOINCREMENT,
		value 		TEXT DEFAULT NULL);}
    ) unless defined( $tables->{entry} );
    if ( not defined $tables->{domain} ) {
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS domain (
		domain_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		name 		TEXT NOT NULL UNIQUE,
		value 		TEXT DEFAULT NULL);}
        );
        our %domains = (
            contacts => q{a contact usualy has a name},
            calls    => q{calls' log},
            messages => q{SMS log},
            dates    => q{appointmets agenda},
            tasks    => q{thinks to do},
            notes    => q{like a post it}
        );
        $dbh->begin_work;
        $dbh->do(
q{INSERT INTO domain VALUES(NULL,'contacts','All kinds of contact requires a name');}
        );
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'calls','Call log');});
        $dbh->do(
            q{INSERT INTO domain VALUES(NULL,'messages','SMS storage & log');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'dates','dates storge');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'tasks','task storge');});
        $dbh->do(q{INSERT INTO domain VALUES(NULL,'notes','task storage');});
        $dbh->commit;
    }
    $sth = $dbh->prepare_cached('SELECT "name","domain_id" from "domain";');
    $sth->execute;
    my $domain_id = $sth->fetchall_hashref("name");
    $domain_id->{$_} = $domain_id->{$_}->{domain_id} for keys( %{$domain_id} );

    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS tag (
		tag_id 		INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		value		TEXT UNIQUE);}
    ) unless defined( $tables->{tag} );
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
    ) unless defined $tables->{external};
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS taged_entries (
		taged_entry_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		tag_id         	INTEGER NOT NULL REFERENCES tag (tag_id),
		id 		INTEGER NOT NULL REFERENCES entry (id));}
    ) unless defined $tables->{taged_entries};
    $dbh->do(
        q{CREATE TABLE IF NOT EXISTS domain_entries (
		id              INTEGER PRIMARY KEY REFERENCES entry (id),
		domain_id 	INTEGER NOT NULL REFERENCES domain (domain_id));}
    ) unless defined $tables->{domain_entries};

    if ( not defined $tables->{type} ) {
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS type (
		type 		TEXT PRIMARY KEY ASC,
		affinity	TEXT NOT NULL,
		value	 	TEXT DEFAULT NULL);}
        );

        $dbh->begin_work;
        $dbh->do(
            q{INSERT INTO type VALUES('text','text','Sqlite TEXT affinity');});
        $dbh->do(
q{INSERT INTO type VALUES('integer','integer','Sqlite INTEGER affinity');}
        );
        $dbh->do(
            q{INSERT INTO type VALUES('real','real','Sqlite REAL affinity');});
        $dbh->do(
            q{INSERT INTO type VALUES('blob','blob','Sqlite NONE affinity');});
        $dbh->do(
q{INSERT INTO type VALUES('numeric','numeric','Sqlite NUMERIC affinity ');}
        );
        $dbh->do(
q{INSERT INTO type VALUES('name','text','A name for an entry Indexed');}
        );
        $dbh->do(
q{INSERT INTO type VALUES('phonenumber','phone','A telefon number to be processed');}
        );
        $dbh->do(
q{INSERT INTO type VALUES('phone','text','A canonical telefon number INDEXED');}
        );
        $dbh->do(
q{INSERT INTO type VALUES('photo','path','a file system path, processed');}
        );
        $dbh->do(
            q{INSERT INTO type VALUES('path','text','an existing file path');});
        $dbh->do(
q{INSERT INTO type VALUES('email','text','email related to an entry');}
        );
        $dbh->do(q{INSERT INTO type VALUES('date','integer','a time stamp');});
        $dbh->do(
q{INSERT INTO type VALUES('address','text','an address related to an entry');}
        );
        $dbh->do(
q{INSERT INTO type VALUES('boolean','integer','perlish way 0 = false');}
        );
        $dbh->do(
q{INSERT INTO type VALUES('number','numeric','when one need to store a number');}
        );
        $dbh->do(
q{INSERT INTO type VALUES('timezone','text',' I think it needs process');}
        );
        $dbh->commit;
    }

    if ( not defined $tables->{fields} ) {
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS fields (
		field_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
		name 		TEXT NOT NULL UNIQUE,
		type 		TEXT NOT NULL REFERENCES type (type));}
        );
        $dbh->begin_work;
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
        $dbh->do(
            q{INSERT INTO fields VALUES(NULL,'Work phone','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Note','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Email','email');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Birthday','date');});
        $dbh->do(
            q{INSERT INTO fields VALUES(NULL,'Mobile phone','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Timezone','timezone');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Address','address');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Nickname','name');});
        $dbh->do(
            q{INSERT INTO fields VALUES(NULL,'Home phone','phonenumber');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Answered','boolean');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Duration','real');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Timestamp','date');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'New','boolean');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Line','integer');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Type','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Start','date');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'End','date');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Message','text');});
        $dbh->do(q{INSERT INTO fields VALUES(NULL,'Title','name');});
        $dbh->commit;
    }
    $sth = $dbh->prepare_cached('SELECT "name","field_id" from "fields";');
    $sth->execute;
    my $field_id = $sth->fetchall_hashref("name");
    $field_id->{$_} = $field_id->{$_}->{field_id} for keys( %{$field_id} );

    #print Dumper($field_id);

    if ( not defined $tables->{domain_fields} ) {
        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS domain_fields (
		field_domain_id INTEGER PRIMARY KEY AUTOINCREMENT,
		domain_id 	INTEGER NOT NULL REFERENCES domain (domain_id),
		field_id 	INTEGER NOT NULL  DEFAULT NULL REFERENCES fields (field_id),
		block		TEXT DEFAULT NULL);}
        );
        $sth = $dbh->prepare_cached(
            q{INSERT INTO domain_fields VALUES(NULL,?,?,?);});
        $dbh->begin_work;
        $sth->execute( $domain_id->{contacts}, $field_id->{Surname},  "name" );
        $sth->execute( $domain_id->{contacts}, $field_id->{Name},     "name" );
        $sth->execute( $domain_id->{contacts}, $field_id->{Nickname}, "name" );
        $sth->execute( $domain_id->{contacts}, $field_id->{Phone}, "address" );
        $sth->execute( $domain_id->{contacts},
            $field_id->{'Home phone'}, "address" );
        $sth->execute( $domain_id->{contacts},
            $field_id->{'Mobile phone'}, "address" );
        $sth->execute( $domain_id->{contacts},
            $field_id->{'Work phone'}, "address" );
        $sth->execute( $domain_id->{contacts}, $field_id->{Email}, "address" );
        $sth->execute( $domain_id->{contacts}, $field_id->{Address},
            "address" );
        $sth->execute( $domain_id->{calls}, $field_id->{Peer},      "phone" );
        $sth->execute( $domain_id->{calls}, $field_id->{Timestamp}, "date" );
        $sth->execute( $domain_id->{calls}, $field_id->{Direction}, "in/out" );
        $sth->execute( $domain_id->{messages}, $field_id->{Timestamp}, "date" );
        $sth->execute( $domain_id->{messages},
            $field_id->{Direction}, "in/out" );
        $sth->execute( $domain_id->{messages}, $field_id->{Peer}, "phone" );
        $sth->execute( $domain_id->{messages}, $field_id->{Content},
            "message" );
        $sth->execute( $domain_id->{dates}, $field_id->{Start},
            "begin of date" );
        $sth->execute( $domain_id->{dates}, $field_id->{End}, "end of date" );
        $sth->execute( $domain_id->{dates}, $field_id->{Message},
            "text for the date" );
        $sth->execute( $domain_id->{tasks}, $field_id->{Start},   "date" );
        $sth->execute( $domain_id->{tasks}, $field_id->{Title},   "text" );
        $sth->execute( $domain_id->{tasks}, $field_id->{Content}, "text" );
        $sth->execute( $domain_id->{notes}, $field_id->{Title},   "name" );
        $sth->execute( $domain_id->{notes}, $field_id->{Content}, "text" );
        $dbh->commit;
    }

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
