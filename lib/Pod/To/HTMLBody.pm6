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

	method indent( Int $layer ) { ' ' xx $layer }
	method display( $layer ) {
		my @layer =
			self.WHAT.perl ~ "(\n",
			'  ' ~ self.parent ?? ':parent()' !! ':!parent',
			")\n";
		;
		return join( '', map { self.indent( $layer ) ~ $_ }, @layer );
	}
	method visualize( $layer = 0 ) {
		my $text = self.display( $layer );
		my $child = $.first-child;
		while $child {
			$text ~= $child.visualize( $layer + 1 );
			$child = $child.next-sibling;
		}
		$text;
	}

	method replace-with( $node ) {
		$node.parent = $.parent;
		$node.previous-sibling = $.previous-sibling;
		$node.next-sibling = $.next-sibling;
		# Don't touch first- and last-child.

		if $.parent and $.parent.first-child === self {
			$.parent.first-child = $node;
		}
		if $.parent and $.parent.last-child === self {
			$.parent.last-child = $node;
		}
		if $.previous-sibling {
			$.previous-sibling.next-sibling = $node;
		}
		if $.next-sibling {
			$.next-sibling.previous-sibling = $node;
		}
	}

	method add-below( $to-insert ) {
		return unless $to-insert;
		$to-insert.parent = self;
		$to-insert.next-sibling = Nil;
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
	method html-start { $.contents } # XXX Need to escape contents
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
#say $tree.visualize;
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
		$node.add-below( self.new-Node-Table-Header( $pod ) )
			if $pod.headers.elems;
		$node.add-below( self.new-Node-Table-Body( $pod ) )
			if $pod.contents.elems;
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
		my $node = Node::Text.new( :value( $pod ) );
		$node;
	}

	method new-Node-Table-Data( $pod ) {
		my $node = Node::Table::Data.new;
		$node.add-below( self.to-node( $pod ) );
		$node;
	}

	method new-Node-Table-Header( $pod ) {
		my $node = Node::Table::Header.new;
		for @( $pod.headers ) -> $element {
			$node.add-below( self.new-Node-Table-Data( $element ) );
		}
		$node;
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
		$node;
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

	sub walk-for-list( $tree ) {
		my $child = $tree.first-child;
		while $child {
			walk-for-list( $child );
			if $child ~~ Node::Item {
				my $new-list = Node::List.new;
				$new-list.add-below( $child );
				$child.replace-with( $new-list );
			}
			$child = $child.next-sibling;
		}
	}

	sub fixup-root-item( $tree ) {
		if $tree ~~ Node::Item {
			my $new-list = Node::List.new;
			$new-list.add-below( $tree );
			return $new-list;
		}
		$tree;
	}

	method pod-to-tree( $pod ) {
		my $tree = self.to-node( $pod );
		$tree = fixup-root-item( $tree );
		walk-for-list( $tree );
#		squish-items( $tree );
		return $tree;
	}

	method tree-to-html( $tree ) {
		return walk($tree);
	}
}

# vim: ft=perl6
