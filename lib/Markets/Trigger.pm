package Markets::Trigger;
use Mojo::Base 'Markets::EventEmitter';

use constant { DEFAULT_PRIORITY => '100', };

has remove_list => sub { [] };
has [qw/app/];

sub new {
    my $self = shift;
    $self = $self->SUPER::new( app => shift );
    Scalar::Util::weaken $self->{app};
    $self;
}

sub remove_triggers {
    my $self  = shift;
    my $array = $self->remove_list;
    return unless @{$array};

    foreach my $remove_trigger ( @{$array} ) {
        my $trigger = $remove_trigger->{trigger};
        my $subscribers = $self->subscribers($trigger);
        my $unsubscribers =
          [ grep { $_->{cb_sub_name} eq $remove_trigger->{cb_sub_name} } @{$subscribers} ];

        map { $self->unsubscribe( $trigger, $_ ) } @{$unsubscribers};
    }
}

sub subscribe_triggers {
    my ( $self, $triggers ) = @_;
    $self->on($_) for @{$triggers};

    # rebuild cache
    $self->app->renderer->cache( Mojo::Cache->new );
}

sub unsubscribe_triggers {
    my ( $self, $triggers ) = @_;
    $self->unsubscribe( $_->{name} => $_ ) for @{$triggers};

    # rebuild cache
    $self->app->renderer->cache( Mojo::Cache->new );
}

1;

=encoding utf8

=head1 NAME

Markets::Trigger - Event for Markets

=head1 SYNOPSIS


=head1 DESCRIPTION

L<Markets::Trigger> is L<Mojolicious> Based events.

=head1 EVENTS

L<Markets::Trigger> inherits all events from L<Mojo::EventEmitter> & L<Markets::EventEmitter>.

=head1 ATTRIBUTES

=head2 C<app>

    my $app = $trigger->app;

Return the application object.

=head2 C<remove_list>

    $trigger->remove_list([]);
    my $list = $trigger->remove_list;

=head1 METHODS

L<Markets::Trigger> inherits all methods from L<Mojolicious::EventEmitter> and implements
the following new ones.

=head2 C<remove_triggers>

    $trigger->remove_triggers;

=head2 C<subscribe_triggers>

    $trigger->subscribe_triggers(\@triggers);

Subscribe trigger events.

=head2 C<unsubscribe_triggers>

    $trigger->unsubscribe_triggers(\@triggers);

Unsubscribe trigger events.

=head1 SEE ALSO

L<Markets::EventEmitter> L<Mojolicious::Plugins> L<Mojo::EventEmitter>

=cut
