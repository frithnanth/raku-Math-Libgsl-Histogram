#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 25 Histograms, Paragraph 25.22

use Math::Libgsl::Random;
use lib 'lib';
use Math::Libgsl::Histogram2D;
use Math::Libgsl::Histogram2D::PDF;

# create a 2D histogram e put 3 data points in it, each with its own weight
my $h = Math::Libgsl::Histogram2D.new(10, 10)
        .set-uniform(0, 1, 0, 1)
        .accumulate(.3, .3, 1)
        .accumulate(.8, .1, 5)
        .accumulate(.7, .9, .5);

my Math::Libgsl::Random $r .= new;

# consider the 2D histogram as a distribution function
my $p = Math::Libgsl::Histogram2D::PDF.new($h.nx, $h.ny, $h);
for ^1000 -> $i {
  # generate random points around each histogram 2D bin (mesh cell), according to their weights
  my ($x, $y) = $p.sample($r.get-uniform, $r.get-uniform);
  printf "%g %g\n", $x, $y;
}
