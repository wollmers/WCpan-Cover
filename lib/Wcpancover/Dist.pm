package Wcpancover::Dist;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  # Render template "dist/index.html.ep"
  $self->render();
}


sub query {
  my $self = shift;
  my $dist = $self->param('dist');

  $self->redirect_to("/dist/$dist");
}


sub show {
  my $self = shift;

  # Render $page
  $self->render_not_found
    unless $self->render();
}

1;
