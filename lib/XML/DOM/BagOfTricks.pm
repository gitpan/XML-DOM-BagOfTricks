package XML::DOM::BagOfTricks;
use strict;

=head1 NAME

XML::DOM::BagOfTricks - Convenient XML DOM

=head1 SYNOPSIS

  use XML::DOM::BagOfTricks;

  # get the XML document and root element
  my ($doc,$root) = getDocument('Foo');

  # or

  # get the XML document with xmlns and version attributes specified
  my $doc = getDocument({name=>'Foo', xmlns=>'http://www.other.org/namespace', version=>1.3});

  # get a text element like <Foo>Bar</Bar>
  my $node = getTextElement($doc,'Foo','Bar');

  # get an element like <Foo isBar="0" isFoo="1"/>
  my $node = getElement($doc,'Foo','isBar'=>0, 'isFoo'=>1);

  # get a nice element with attributes that contains a text node <Foo isFoo="1" isBar="0">Bar</Foo>
  my $foo_elem = getElementwithText($DOMDocument,'Foo','Bar',isFoo=>1,isBar=>0);


=head1 DESCRIPTION

XML::DOM::BagOfTricks provides a bundle, or bag, of functions that make 
dealing with and creating DOM objects easier.

getTextContents() from 'Effective XML processing with DOM and XPath in Perl'
by Parand Tony Darugar, IBM Developerworks Oct 1st 2001

=cut


use XML::DOM;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our $VERSION = '0.01';
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
				   &getTextContents &getDocument &getTextElement
				   &getElement &getElementwithText
				   ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

=head2 getTextElement($doc,$name,$value)

    This function returns a nice XML::Xerces::DOMNode representing an element
    with an appended Text subnode, based on the arguments provided.

    In the example below $node would represent '<Foo>Bar</Foo>'

    my $node = getTextElement($doc,'Foo','Bar');

    More useful than a pocketful of bent drawing pins! If only the Chilli Peppers
    made music like they used to 'Zephyr' is no equal of 'Fight Like A Brave' or
    'Give it away'

=cut

sub getTextElement {
    my ($doc, $name, $value) = @_;
    die "getTextElement requires a name  : ", caller() unless $name;
    my $field = $doc->createElement($name);
    my $fieldvalue = $doc->createTextNode($value);
    $field->appendChild($fieldvalue);
    return $field;
}

=head2 getElement($doc,$name,%attributes)

    This function returns a nice XML::Xerces::DOMNode representing an element
    with an appended Text subnode, based on the arguments provided.

    In the example below $node would represent '<Foo isBar='0' isFoo='1'/>'

    my $node = getElement($doc,'Foo','isBar'=>0, 'isFoo'=>1);

=cut


sub getElement {
    my ($doc, $name, @attributes) = @_;
    my $node = $doc->createElement($name);
    while (@attributes) {
	my ($name,$value) = (shift @attributes, shift @attributes);
	$node->setAttribute($name,$value) if ($name);
    }

    return $node;
}


=head2 getElementwithText($DOMDocument,$node_name,$text,$attr_name=>$attr_value);

  # get a nice element with attributes that contains a text node ( i.e. <Foo isFoo='1' isBar='0'>Bar</Foo> )
  my $foo_elem = getElementwithText($DOMDocument,'Foo','Bar',isFoo=>1,isBar=>0);

=cut

sub getElementwithText {
    my ($doc, $nodename, $textvalue, @attributes) = @_;
    die "getElementwithText requires a DOMDocument ", caller()  unless (ref $doc && $doc->isa('XML::Xerces::DOMDocument'));
    die "getElementwithText requires a name : ", caller() unless $nodename;
    my $node = $doc->createElement($nodename);
    if ($textvalue) {
	my $text = $doc->createTextNode($textvalue);
	$node->appendChild($text);
    }
    while (@attributes) {
	my ($name,$value) = (shift @attributes, shift @attributes);
	$node->setAttribute($name,$value) if ($name);
    }

    return $node;
}


=head2 getDocument($namespace,$root_tag)

This function will return a nice XML:DOM::Document object,
if called in array context it will return a list of the Document and the root.

It requires a root tag, and a list of tags to be added to the document

the tags can be scalars :

my ($doc,$root) = getDocument('Foo', 'Bar', 'Baz');

or a hashref of attributes, and the tags name :

my $doc = getDocument({name=>'Foo', xmlns=>'http://www.other.org/namespace', version=>1.3}, 'Bar', 'Baz');

=cut

# maybe we should memoize this later

sub getDocument {
    my ($root_tag,@tags) = @_;
    my $docroot = (ref $root_tag) ? $root_tag->{name} : $root_tag;
    my $doc = XML::DOM::Document->new();
    my $root = $doc->createElement($docroot);
    if (ref $root_tag) {
	foreach (keys %$root_tag) {
	    next if /name/;
	    $root->setAttribute($_,$root_tag->{$_});
	}
    }
    foreach my $tag ( @tags ) {
	last unless ($tag);
	my $element_tag = (ref $tag) ? $tag->{name} : $tag;
	my $element = $doc->createElement ($element_tag);
	if (ref $tag) {
	    foreach (keys %$tag) {
		next if /name/;
		$element->setAttribute($_,$tag->{$_});
	    }
	}
	$root->appendChild($element);
    }
    return (wantarray) ? ($doc,$root): $doc;
}

####

# Based on example in 'Effective XML processing with DOM and XPath in Perl'
# by Parand Tony Darugar, IBM Developerworks Oct 1st 2001
# Copyright (c) 2001 Parand Tony Darugar

=head2 getTextContents($node)

returns the text content of a node (and its subnodes)

my $content = getTextContents($node);

Function by P T Darugar, published in IBM Developerworks Oct 1st 2001

=cut
sub getTextContents {
    my ($node, $strip)= @_;
    my $contents;

    if (! $node ) {
	return;
    }
    for my $child ($node->getChildNodes()) {
	if ( $child->getNodeType() == 3 or $child->getNodeType() == 4 ) {
	    $contents .= $child->getData();
	}
    }

    if ($strip) {
	$contents =~ s/^\s+//;
	$contents =~ s/\s+$//;
    }

    return $contents;
}


#####################################################


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head2 EXPORT

:all

&getTextContents &getDocument &getTextElement &getElement &getElementwithText

=head1 SEE ALSO

XML:DOM

XML::Xerces

XML::Xerces::BagOfTricks

=head1 AUTHOR

Aaron Trevena, E<lt>teejay@droogs.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Aaron Trevena
Copyright (c) 2001 Parand Tony Darugar, where applicable

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
