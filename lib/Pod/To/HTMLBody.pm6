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

class Node::Item is Node {
	method html-start { '<li>' }
	method html-end { '</li>' }
}

class Node::List is Node {
	method html-start { '<ul>' }
	method html-end { '</ul>' }
}

class Node::Section is Node {
	has $.title;
	method html-start { qq[<section><h1>{$.title}</h1>] }
	method html-end { qq[</section>] }
}

class Node::Paragraph is Node {
	method html-start { '<p>' }
	method html-end { '</p>' }
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

	method render( $pod ) {
		return self.pod-to-tree( $pod );
	}

	multi method to-node( $pod ) {
		die "Unknown Pod type " ~ $pod.gist;
	}

	multi method to-node( Pod::Block::Code $pod ) {
		my $node = Node::Code.new;
		for @( $pod.contents ) -> $element {
			my $child = self.to-node( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}

	multi method to-node( Pod::Block::Comment $pod ) {
		my $node = Node::Comment.new;
		for @( $pod.contents ) -> $element {
			my $child = self.to-node( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
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
		for @( $pod.contents ) -> $element {
			my $child = self.to-node( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}

	multi method to-node( Pod::Block::Table $pod ) {
		my $node = Node::Table.new;
		my $header = self.new-Node-Table-Header( $pod );
		my $body = self.new-Node-Table-Body( $pod );
		if $header.first-child {
			$node.first-child = $header;
			$node.last-child = $header;
		}
		if $body.first-child {
			$node.first-child.next-sibling = $body;
			$body.previous-sibling = $header;
			$node.last-child = $body;
		}
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod ) {
		given $pod.type {
			when 'C' {
				my $node = Node::Code.new;
				for @( $pod.contents ) -> $element {
					my $child = self.to-node( $element );
					$child.parent = $node;
					if $node.first-child {
						$node.last-child.next-sibling = $child;
						$child.previous-sibling = $node.last-child;
						$node.last-child = $child;
					}
					else {
						$node.first-child = $child;
						$node.last-child = $child;
					}
				}
				$node;
			}
			default { self.new-Node-Section( $pod ) }
		}
	}

	multi method to-node( Pod::Heading $pod ) {
		my $node = Node::Heading.new( :level( $pod.level ) );
		for @( $pod.contents ) -> $element {
			my $child = self.to-node( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}

	multi method to-node( Pod::Item $pod ) {
		my $node = Node::Item.new( :level( $pod.level ) );
		for @( $pod.contents ) -> $element {
			my $child = self.to-node( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
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
			my $child = self.new-Node-Table-Data( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}

	method new-Node-Table-Body-Row( $pod ) {
		my $node = Node::Table::Body::Row.new;
		for @( $pod ) -> $element {
			my $child = self.new-Node-Table-Data( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}


	method new-Node-Table-Body( $pod ) {
		my $node = Node::Table::Body.new;
		for @( $pod.contents ) -> $element {
			my $child = self.new-Node-Table-Body-Row( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}

	method new-Node-Document( $pod ) {
		my $node = Node::Document.new;
		for @( $pod.contents ) -> $element {
			my $child = self.to-node( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}

	method new-Node-Section( $pod ) {
		my $node = Node::Section.new( :title( $pod.name ) );
		for @( $pod.contents ) -> $element {
			my $child = self.to-node( $element );
			$child.parent = $node;
			if $node.first-child {
				$node.last-child.next-sibling = $child;
				$child.previous-sibling = $node.last-child;
				$node.last-child = $child;
			}
			else {
				$node.first-child = $child;
				$node.last-child = $child;
			}
		}
		$node;
	}

#`(
	sub list-extent( $start ) {
		my $end = $start;
		while $end.next-sibling ~~ Node::Item {
			$end = $end.next-sibling;
		}
		$end;
	}

	sub new-Node-List( $start ) {
		my $node = Node::List.new;
		$start.parent = $node;
		my $end = $start;
		while $end.next-sibling ~~ Node::Item {
			$end.parent = $node;
			$end = $end.next-sibling;
		}
		$node.first-child = $start;
		$node.last-child = $end;
		$start.previous-sibling = Nil;
		$end.next-sibling = Nil;
		$node;
	}

	sub build-list( $node ) {
		my $start = $node.first-child;
		while $start {
			if $start ~~ Node::Item {
				my $end = list-extent( $start );
my $new-list-previous = $start.previous-sibling;
my $new-list-next = $end.next-sibling;
				my $list = new-Node-List( $start );
$list.previous-sibling = $new-list-previous;
$list.next-sibling = $new-list-next;
$new-list-previous.next-sibling = $list if $new-list-previous and $new-list-previous.next-sibling;
$new-list-next.previous-sibling = $list if $new-list-next and $new-list-next.previous-sibling;
			}
			build-list( $start );
			$start = $start.next-sibling;
		}
	}
)

	method pod-to-tree( $pod ) {
		my $tree = self.to-node( $pod );
#		build-list($tree);
		return walk($tree);
	}
}

# vim: ft=perl6
