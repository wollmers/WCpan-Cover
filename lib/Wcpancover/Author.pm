package Wcpancover::Author;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  # Render template "front/index.html.ep"
  $self->render();
}

sub query {
  my $self = shift;
  my $author = $self->param('author');

  $self->redirect_to("/author/$author");
}

sub show {
  my $self = shift;

  # Render $page
  $self->render_not_found
    unless $self->render();
}

1;
