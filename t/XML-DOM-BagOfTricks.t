# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl XML-DOM-BagOfTricks.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use XML::DOM::BagOfTricks q(:all);

use Test::More tests => 4;
BEGIN { use_ok('XML::DOM::BagOfTricks') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.



my $okstring = '<Pubs><PublicHouse Name="Cittie of Yorke"><TubeStation>Chancery Lane</TubeStation><Postcode>WC1</Postcode></PublicHouse><PublicHouse Name="Penderals Oak" Brewery="Weatherspoons" Food="True"><TubeStation>Chancery Lane</TubeStation><Postcode>WC1</Postcode></PublicHouse><PublicHouse Name="Star of Belgravia" Brewery="Fullers" Food="True"><TubeStation>Knightsbridge</TubeStation><Postcode>SW1X 8HT</Postcode></PublicHouse><PublicHouse Name="The Angel"><TubeStation>Old Street</TubeStation><Postcode>EC1</Postcode></PublicHouse></Pubs>';

my %pubs = (
	    'Star of Belgravia'=> {
				   Tube => 'Knightsbridge',
				   Postcode => 'SW1X 8HT',
				   Food => 'True',
				   Brewery => 'Fullers',
				  },
	    'Cittie of Yorke' => {
				  Tube => 'Chancery Lane',
				  Postcode => 'WC1',
				 },
	    'Penderals Oak' => {
				Tube => 'Chancery Lane',
				Postcode => 'WC1',
				Food => 'True',
				Brewery => 'Weatherspoons',
			       },
	    'The Angel' => {
			    Tube => 'Old Street',
			    Postcode => 'EC1',
			   },
	   );

my ($doc,$root) = createDocument('Pubs');

isa_ok( $doc, 'XML::DOM::Document' );

isa_ok( $root, 'XML::DOM::Element' );

foreach my $pubname (sort keys %pubs) {
    my $pub = createElement($doc, 'PublicHouse','Name'=>$pubname ,'Brewery'=>$pubs{$pubname}{Brewery}, 'Food'=>$pubs{$pubname}{Food});

    my $pub_tube = createTextElement($doc,'TubeStation',$pubs{$pubname}{Tube});
    $pub->appendChild($pub_tube);

    $pub->appendChild(createTextElement($doc,'Postcode',$pubs{$pubname}{Postcode}));

    $root->appendChild($pub);
}

ok($okstring eq $root->toString, 'xml output');
