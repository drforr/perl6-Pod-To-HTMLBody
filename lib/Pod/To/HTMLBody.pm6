use v6;

=begin pod

=head1 Pod::To::HTMLBody

Generate a simple HTML C<< <body/> >> fragment.

Subclass this in order to do your own HTML display.

=head1 Synopsis

    use Pod::To::HTMLBody;

    say Pod::To::HTMLBody.render( $=[0] );

=head1 Documentation

Somewhat up in the air at the moment.

=end pod

#
#                    parent
#                       ^
#                       |
# previous-sibling <- $node -> next-sibling
#                     |    \
#                     |     --------,
#                     V              \
#                    first-child -> last-child
#
class Node {
	has $.parent is rw;
	has $.first-child is rw;
	has $.next-sibling is rw;
	has $.previous-sibling is rw;
	has $.last-child is rw;

	method add-below( $to-insert ) {
		return unless $to-insert;
		$to-insert.parent = self;
		if $.first-child {
			$to-insert.previous-sibling = $.last-child;
			$.last-child.next-sibling = $to-insert;
			$.last-child = $to-insert;
		}
		else {
			$.first-child = $to-insert;
			$.last-child = $to-insert;
		}
	}
}

class Node::Bold is Node {
	method html-start { '<b>' }
	method html-end { '</b>' }
}

class Node::Code is Node {
	method html-start { '<code>' }
	method html-end { '</code>' }
}

class Node::Comment is Node {
	method html-start { '<!--' }
	method html-end { '-->' }
}

class Node::Document is Node {
	method html-start { '<div>' }
	method html-end { '</div>' }
}

class Node::Entity is Node {
	has $.contents;
	method html-start { $.contents }
	method html-end { '' }
}

class Node::Item is Node {
	method html-start { '<li>' }
	method html-end { '</li>' }
}

class Node::Link is Node {
	has $.url;

	method html-start { qq[<a href="{$.url}">] }
	method html-end { '</ul>' }
}

class Node::List is Node {
	method html-start { '<ul>' }
	method html-end { '</ul>' }
}

class Node::Paragraph is Node {
	method html-start { '<p>' }
	method html-end { '</p>' }
}

class Node::Section is Node {
	has $.title;
	method html-start { qq[<section><h1>{$.title}</h1>] }
	method html-end { qq[</section>] }
}

# XXX What is this?...
class Node::Reference is Node {
	has $.title;
	method html-start { qq[<var>] }
	method html-end { qq[</var>] }
}

class Node::Heading is Node {
	has $.level;
	method html-start { qq[<h{$.level}>] }
	method html-end { qq[</h{$.level}>] }
}

class Node::Text is Node {
	has $.value;

	method html-start { $.value }
	method html-end { '' }
}

class Node::Table is Node {
	method html-start { '<table>' }
	method html-end { '</table>' }
}

class Node::Table::Header is Node {
	method html-start { '<th>' }
	method html-end { '</th>' }
}

class Node::Table::Data is Node {
	method html-start { '<td>' }
	method html-end { '</td>' }
}

class Node::Table::Body is Node {
	method html-start { '' }
	method html-end { '' }
}

class Node::Table::Body::Row is Node {
	method html-start { '<tr>' }
	method html-end { '</tr>' }
}

class Pod::To::HTMLBody {

	sub walk( $node ) {
		my $html = '';
		$html ~= $node.html-start;
		my $child = $node.first-child;
		while $child {
			$html ~= walk( $child );
			$child = $child.next-sibling;
		}
		$html ~= $node.html-end;
		$html;
	}

	method add-contents-below( $node, $pod ) {
		for @( $pod.contents ) -> $element {
			$node.add-below( self.to-node( $element ) );
		}
	}

	method render( $pod ) {
		my $tree = self.pod-to-tree( $pod );
		return self.tree-to-html( $tree );
	}

	multi method to-node( $pod ) {
		die "Unknown Pod type " ~ $pod.gist;
	}

	multi method to-node( Pod::Block::Code $pod ) {
		my $node = Node::Code.new;
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Block::Comment $pod ) {
		my $node = Node::Comment.new;
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Block::Named $pod ) {
		given $pod.name {
			when 'pod' { self.new-Node-Document( $pod ) }
			default { self.new-Node-Section( $pod ) }
		}
	}

	multi method to-node( Pod::Block::Para $pod ) {
		my $node = Node::Paragraph.new;
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Block::Table $pod ) {
		my $node = Node::Table.new;
		$node.add-below( self.new-Node-Table-Header( $pod ) );
		$node.add-below( self.new-Node-Table-Body( $pod ) );
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod ) {
		given $pod.type {
			when 'B' {
				my $node = Node::Bold.new;
				self.add-contents-below( $node, $pod );
				$node;
			}
			when 'C' {
				my $node = Node::Code.new;
				self.add-contents-below( $node, $pod );
				$node;
			}
			when 'E' {
				# XXX Need to escape this properly
				my $node = Node::Entity.new(
					:contents( $pod.contents )
				);
				$node;
			}
			when 'L' {
				my $node = Node::Link.new(
					:url( $pod.meta )
				);
				self.add-contents-below( $node, $pod );
				$node;
			}
			when 'R' {
				my $node = Node::Reference.new;
				self.add-contents-below( $node, $pod );
				$node;
			}
			default { self.new-Node-Section( $pod ) }
		}
	}

	multi method to-node( Pod::Heading $pod ) {
		my $node = Node::Heading.new( :level( $pod.level ) );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Item $pod ) {
		my $node = Node::Item.new( :level( $pod.level ) );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Str $pod ) {
		Node::Text.new( :value( $pod ) )
	}

	method new-Node-Table-Data( $pod ) {
		my $node = Node::Table::Data.new;
		my $child = self.to-node( $pod );
		$node.first-child = $child;
		$node.last-child = $child;
		$node;
	}

	method new-Node-Table-Header( $pod ) {
		my $node = Node::Table::Header.new;
		for @( $pod.headers ) -> $element {
			$node.add-below( self.new-Node-Table-Data( $element ) );
		}
		return $node if $node.first-child;
		return Nil;
	}

	method new-Node-Table-Body-Row( $pod ) {
		my $node = Node::Table::Body::Row.new;
		for @( $pod ) -> $element {
			$node.add-below( self.new-Node-Table-Data( $element ) );
		}
		$node;
	}


	method new-Node-Table-Body( $pod ) {
		my $node = Node::Table::Body.new;
		for @( $pod.contents ) -> $element {
			$node.add-below( 
				self.new-Node-Table-Body-Row( $element )
			);
		}
		return $node if $node.first-child;
		return Nil;
	}

	method new-Node-Document( $pod ) {
		my $node = Node::Document.new;
		self.add-contents-below( $node, $pod );
		$node;
	}

	method new-Node-Section( $pod ) {
		my $node = Node::Section.new( :title( $pod.name ) );
		self.add-contents-below( $node, $pod );
		$node;
	}

	method pod-to-tree( $pod ) {
		my $tree = self.to-node( $pod );
		return $tree;
	}

	method tree-to-html( $tree ) {
		return walk($tree);
	}
}

# vim: ft=perl6
