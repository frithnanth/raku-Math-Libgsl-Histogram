unit class Math::Libgsl::Histogram:ver<0.1.1>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Raw::Histogram;

has gsl_histogram $.h;

# Histogram allocation
multi method new(UInt $size!)  { self.bless(:$size) }
multi method new(UInt :$size!) { self.bless(:$size) }
multi method new(gsl_histogram :$histogram!) { self.bless(:$histogram) }
submethod BUILD(UInt :$size?, gsl_histogram :$histogram?) {
  with   $size      { $!h = gsl_histogram_calloc($size) }
  orwith $histogram { $!h = $histogram }
  else              { fail X::Libgsl.new: errno => GSL_FAILURE, error => "Can't initialize object'" }
}
submethod DESTROY { gsl_histogram_free($!h) }

method set-ranges(*@ranges where *.elems == self.bins + 1 --> Math::Libgsl::Histogram) {
  my CArray[num64] $ranges .= new: @ranges».Num;
  my $ret = gsl_histogram_set_ranges($!h, $ranges, @ranges.elems);
  X::Libgsl.new(errno => $ret, error => "Can't set histogram ranges").throw if $ret ≠ GSL_SUCCESS;
  self
}
method set-uniform(Num() $xmin, Num() $xmax where * > $xmin --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_set_ranges_uniform($!h, $xmin, $xmax);
  X::Libgsl.new(errno => $ret, error => "Can't set uniform histogram ranges").throw if $ret ≠ GSL_SUCCESS;
  self
}
# Updating and accessing histogram elements
method increment(*@x --> Math::Libgsl::Histogram) {
  my $ret;
  for @x {
    $ret +|= gsl_histogram_increment($!h, $_.Num);
  }
  X::Libgsl.new(errno => $ret, error => "Can't increment the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method accumulate(Num() $x, Num() $weight --> Math::Libgsl::Histogram){
  my $ret = gsl_histogram_accumulate($!h, $x, $weight);
  X::Libgsl.new(errno => $ret, error => "Can't accumulate into the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method get(UInt $i where * < self.bins --> Num) { gsl_histogram_get($!h, $i) }
method get-range(UInt $i --> List) {
  my num64 ($lower, $upper);
  my $ret = gsl_histogram_get_range($!h, $i, $lower, $upper);
  X::Libgsl.new(errno => $ret, error => "Can't read bin range").throw if $ret ≠ GSL_SUCCESS;
  return $lower, $upper;
}
method max(--> Num) { gsl_histogram_max($!h) }
method min(--> Num) { gsl_histogram_min($!h) }
method bins(--> UInt) { gsl_histogram_bins($!h) }
method reset() { gsl_histogram_reset($!h) }
# Search histogram ranges
method find(Num() $x --> UInt) {
  my size_t $bin;
  my $ret = gsl_histogram_find($!h, $x, $bin);
  fail X::Libgsl.new: errno => $ret, error => "Can't find bin" if $ret ≠ GSL_SUCCESS;
  $bin
}
# Copying histograms
method copy(Math::Libgsl::Histogram $src where { $src.bins == self.bins } --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_memcpy($!h, $src.h);
  X::Libgsl.new(errno => $ret, error => "Can't copy the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method clone(--> Math::Libgsl::Histogram) {
  Math::Libgsl::Histogram.new: histogram => gsl_histogram_clone($!h)
}
# Statistics
method max-val(--> Num)  { gsl_histogram_max_val($!h) }
method max-bin(--> UInt) { gsl_histogram_max_bin($!h) }
method min-val(--> Num)  { gsl_histogram_min_val($!h) }
method min-bin(--> UInt) { gsl_histogram_min_bin($!h) }
method mean(--> Num)     { gsl_histogram_mean($!h) }
method sigma(--> Num)    { gsl_histogram_sigma($!h) }
method sum(--> Num)      { gsl_histogram_sum($!h) }
# Histogram operations
method equal(Math::Libgsl::Histogram $h2 --> Bool) {
  gsl_histogram_equal_bins_p($!h, $h2.h) == 1 ?? True !! False
}
method add(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_add($!h, $h2.h);
  X::Libgsl.new(errno => $ret, error => "Can't add the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method sub(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_sub($!h, $h2.h);
  X::Libgsl.new(errno => $ret, error => "Can't subtract the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method mul(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_mul($!h, $h2.h);
  X::Libgsl.new(errno => $ret, error => "Can't multiply the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method div(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_div($!h, $h2.h);
  X::Libgsl.new(errno => $ret, error => "Can't divide the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method scale(Num() $scale --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_scale($!h, $scale);
  X::Libgsl.new(errno => $ret, error => "Can't scale the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method shift(Num() $offset --> Math::Libgsl::Histogram) {
  my $ret = gsl_histogram_shift($!h, $offset);
  X::Libgsl.new(errno => $ret, error => "Can't shift the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
# I/O
method write(Str $filename --> Math::Libgsl::Histogram) {
  my $ret = mgsl_histogram_fwrite($filename, $!h);
  X::Libgsl.new(errno => $ret, error => "Can't write the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method read(Str $filename --> Math::Libgsl::Histogram) {
  my $ret = mgsl_histogram_fread($filename, $!h);
  X::Libgsl.new(errno => $ret, error => "Can't read the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method printf(Str $filename, Str $range-format, Str $bin-format --> Math::Libgsl::Histogram) {
  my $ret = mgsl_histogram_fprintf($filename, $!h, $range-format, $bin-format);
  X::Libgsl.new(errno => $ret, error => "Can't print the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}
method scanf(Str $filename --> Math::Libgsl::Histogram) {
  my $ret = mgsl_histogram_fscanf($filename, $!h);
  X::Libgsl.new(errno => $ret, error => "Can't scan the histogram").throw if $ret ≠ GSL_SUCCESS;
  self
}

=begin pod

![Distribution of simulated events](examples/2Dhistogram.svg)

=head1 NAME

Math::Libgsl::Histogram - An interface to libgsl, the Gnu Scientific Library - Histograms

=head1 SYNOPSIS

=begin code :lang<raku>

use Math::Libgsl::Histogram;

my $h = Math::Libgsl::Histogram.new(3).set-ranges(0, 10, 100, 1000);
say $h.find(18);
$h.scanf('file.dat');
say "max: { $h.max-val } in bin { $h.max-bin }";
say "mean: { $h.mean } standard deviation: { $h.sigma }";

=end code

=begin code :lang<raku>

use Math::Libgsl::Histogram2D;

my $h = Math::Libgsl::Histogram2D.new(10, 10)
        .set-uniform(0, 1, 0, 1)
        .accumulate(.3, .3, 1)
        .accumulate(.8, .1, 5)
        .accumulate(.7, .9, .5);
say "Number of bins: x = { $h.nx }, y = { $h.ny }"; # output: Number of bins: x = 10, y = 10
say "bin (0, 0) = { $h.get(0, 0) }";                # output: bin (7, 9) = 0.5

=end code

=head1 DESCRIPTION

Math::Libgsl::Histogram is an interface to the Histogram functions of libgsl, the Gnu Scientific Library.

This module exports four classes:

=item Math::Libgsl::Histogram
=item Math::Libgsl::Histogram::PDF
=item Math::Libgsl::Histogram2D
=item Math::Libgsl::Histogram2D::PDF

Histogram manages one-dimensional histograms, Histogram2D manages two-dimensional histograms, Histogram::PDF uses the 1D histogram as a probability function, same goes for the Histogram2D::PDF.

=head2 Math::Libgsl::Histogram

=head3 new(UInt $size!)
=head3 new(UInt :$size!)

The constructor accepts one simple or named argument: the histogram size, or number of bins.

All the following methods I<throw> on error if they return B<self>, otherwise they I<fail> on error.

=head3 set-ranges(*@ranges where *.elems == self.bins + 1 --> Math::Libgsl::Histogram)

This method sets the ranges of the histogram using the B<@array>.

This method returns B<self>, to allow method chaining.

=head3 set-uniform(Num() $xmin, Num() $xmax where * > $xmin --> Math::Libgsl::Histogram)

This method sets the ranges of the histogram to cover the range from B<$xmin> to B<$xmax> uniformly.

This method returns B<self>, to allow method chaining.

=head3 increment(*@x --> Math::Libgsl::Histogram)

This method updates the histogram by adding one (1.0) to each bin whose range contains each of the coordinates B<@x>.

This method returns B<self>, to allow method chaining.

=head3 accumulate(Num() $x, Num() $weight --> Math::Libgsl::Histogram)

This method updates the histogram by increasing the value of the appropriate bin by the floating-point number B<$weight>.

This method returns B<self>, to allow method chaining.

=head3 get(Int $i where * < self.bins --> Num)

This method returns the content of the i-th bin of the histogram.

=head3 get-range(UInt $i --> List)

This method finds the upper and lower range limits of the i-th bin of the histogram and returns them as a two-value list.

=head3 max(--> Num)
=head3 min(--> Num)
=head3 bins(--> UInt)

These methods return the maximum upper and minimum lower range limits and the number of bins of the histogram.

=head3 reset()

This method resets all the bins in the histogram to zero.

=head3 find(Num() $x --> UInt)

This method returns the index of the bin which covers the coordinate B<$x> in the histogram.

=head3 copy(Math::Libgsl::Histogram $src where { $src.bins == self.bins } --> Math::Libgsl::Histogram)

This method copies the histogram B<$src> into the current object.

This method returns B<self>, to allow method chaining.

=head3 clone(--> Math::Libgsl::Histogram)

This method returns a newly created histogram which is an exact copy of the current histogram.

=head3 max-val(--> Num)

This method returns the maximum value contained in the histogram bins.

=head3 max-bin(--> UInt)

This method returns the index of the bin containing the maximum value.

=head3 min-val(--> Num)

This method returns the minimum value contained in the histogram bins.

=head3 min-bin(--> UInt)

This method returns the index of the bin containing the minimum value.

=head3 mean(--> Num)

This method returns the mean of the histogrammed variable, where the histogram is regarded as a probability distribution.

=head3 sigma(--> Num)

This method returns the standard deviation of the histogrammed variable, where the histogram is regarded as a probability distribution.

=head3 sum(--> Num)

This method returns the sum of all bin values.

=head3 equal(Math::Libgsl::Histogram $h2 --> Bool)

This method returns True if the all of the individual bin ranges of the two histograms are identical, and False otherwise.

=head3 add(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram)

This method adds the contents of the bins in histogram h2 to the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 sub(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram)

This method subtracts the contents of the bins in histogram h2 from the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 mul(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram)

This method multiplies the contents of the bins in histogram h2 by the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 div(Math::Libgsl::Histogram $h2 --> Math::Libgsl::Histogram)

This method divides the contents of the bins in histogram h2 by the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 scale(Num() $scale --> Math::Libgsl::Histogram)

This method multiplies the contents of the bins of the current histogram by B<$scale>.

This method returns B<self>, to allow method chaining.

=head3 shift(Num() $offset --> Math::Libgsl::Histogram)

This method shifts the contents of the bins of the current histogram by B<$offset>.

This method returns B<self>, to allow method chaining.

=head3 write(Str $filename --> Math::Libgsl::Histogram)

This method writes the ranges and bins of the current histogram to a file in binary format.

This method returns B<self>, to allow method chaining.

=head3 read(Str $filename --> Math::Libgsl::Histogram)

This method reads the ranges and bins of the current histogram from a file in binary format.

This method returns B<self>, to allow method chaining.

=head3 printf(Str $filename, Str $range-format, Str $bin-format --> Math::Libgsl::Histogram)

This function writes the ranges and bins of the current histogram line-by-line to a file using the format specifiers B<$range-format> and B<$bin-format>.

This method returns B<self>, to allow method chaining.

=head3 scanf(Str $filename --> Math::Libgsl::Histogram)

This function reads formatted data from a file.

The histogram must be preallocated with the correct length since the C library function uses the size of the current object to determine how many numbers to read.

This method returns B<self>, to allow method chaining.


=head2 Math::Libgsl::Histogram::PDF

=head3 new(UInt $size!, Math::Libgsl::Histogram $h!)
=head3 new(UInt :$size!, Math::Libgsl::Histogram :$h!)

The constructor accepts two simple or named arguments: the probability distribution function size, or number of bins, and the histogram.

The histogram must not contain negative values, because a probability distribution cannot contain negative values.

=head3 sample(Num() $r --> Num)

This method uses B<$r>, a uniform random number between zero and one, to compute a single random sample from the probability distribution object.


=head2 Math::Libgsl::Histogram2D

=head3 new(UInt $nx!, UInt $ny!)
=head3 new(UInt :$nx!, UInt :$ny!)

The constructor accepts two simple or named arguments: the number of bins in the x direction B<$nx> and the number of bins in the y direction B<$ny>.

=head3 set-ranges(:@xranges where *.elems == self.nx + 1, :@yranges where *.elems == self.ny + 1 --> Math::Libgsl::Histogram2D)

This method sets the ranges of the current histogram using the arrays B<@xrange> and B<@yrange>.

This method returns B<self>, to allow method chaining.

=head3 set-uniform(Num() $xmin, Num() $xmax where * > $xmin, Num() $ymin, Num() $ymax where * > $ymin --> Math::Libgsl::Histogram2D)

This method sets the ranges of the histogram to cover the ranges B<$xmin> to B<$xmax> and B<$ymin> to B<$ymax> uniformly.

This method returns B<self>, to allow method chaining.

=head3 increment(Num() $x, Num() $y --> Math::Libgsl::Histogram2D)

This method updates the histogram by adding one (1.0) to the bin whose x and y ranges contain the coordinates B<($x, $y)>.

This method returns B<self>, to allow method chaining.

=head3 accumulate(Num() $x, Num() $y, Num() $weight --> Math::Libgsl::Histogram2D)

This method updates the histogram by increasing the value of the appropriate bin by the floating-point number B<$weight>.

This method returns B<self>, to allow method chaining.

=head3 get(UInt $i where * < self.nx, Int $j where * < self.ny --> Num)

This method returns the content of the (i, j)-th bin of the histogram.

=head3 get-xrange(UInt $i --> List)
=head3 get-yrange(UInt $i --> List)

This method finds the upper and lower range limits of the i-th and j-th bin in the x and y directions of the histogram and returns them as a two-value list.

=head3 xmax(--> Num)
=head3 xmin(--> Num)
=head3 nx(--> UInt)
=head3 ymax(--> Num)
=head3 ymin(--> Num)
=head3 ny(--> UInt)

These methods return the maximum upper and minimum lower range limits and the number of bins of the histogram.

=head3 reset()

This method resets all the bins in the histogram to zero.

=head3 find(Num() $x, Num() $y --> List)

This method returns the index of the bin which covers the coordinate B<($x, $y)> in the histogram.

=head3 copy(Math::Libgsl::Histogram2D $src where { $src.nx == self.nx && $src.ny == self.ny } --> Math::Libgsl::Histogram2D)

This method copies the histogram B<$src> into the current object.

This method returns B<self>, to allow method chaining.

=head3 clone(--> Math::Libgsl::Histogram2D)

This method returns a newly created histogram which is an exact copy of the current histogram.

=head3 max-val(--> Num)

This method returns the maximum value contained in the histogram bins.

=head3 max-bin(--> List)

This method returns the indexes of the bin containing the maximum value.

=head3 min-val(--> Num)

This method returns the minimum value contained in the histogram bins.

=head3 min-bin(--> List)

This method returns the indexes of the bin containing the minimum value.

=head3 xmean(--> Num)

This method returns the mean of the histogrammed x variable, where the histogram is regarded as a probability distribution.

=head3 ymean(--> Num)

This method returns the mean of the histogrammed y variable, where the histogram is regarded as a probability distribution.

=head3 xsigma(--> Num)

This method returns the standard deviation of the histogrammed x variable, where the histogram is regarded as a probability distribution.


=head3 ysigma(--> Num)

This method returns the standard deviation of the histogrammed y variable, where the histogram is regarded as a probability distribution.

=head3 cov(--> Num)

This method returns the covariance of the histogrammed x and y variables, where the histogram is regarded as a probability distribution.

=head3 sum(--> Num)

This method returns the sum of all bin values.

=head3 equal(Math::Libgsl::Histogram2D $h2 --> Bool)

This method returns True if the all of the individual bin ranges of the two histograms are identical, and False otherwise.

=head3 add(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D)

This method adds the contents of the bins in histogram h2 to the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 sub(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D)

This method subtracts the contents of the bins in histogram h2 from the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 mul(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D)

This method multiplies the contents of the bins in histogram h2 by the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 div(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D)

This method divides the contents of the bins in histogram h2 by the corresponding bins of the current histogram.

The two histograms must have the same number of bins and the same ranges.

This method returns B<self>, to allow method chaining.

=head3 scale(Num() $scale --> Math::Libgsl::Histogram2D)

This method multiplies the contents of the bins of the current histogram by B<$scale>.

This method returns B<self>, to allow method chaining.

=head3 shift(Num() $offset --> Math::Libgsl::Histogram2D)

This method shifts the contents of the bins of the current histogram by B<$offset>.

This method returns B<self>, to allow method chaining.

=head3 write(Str $filename --> Math::Libgsl::Histogram2D)

This method writes the ranges and bins of the current histogram to a file in binary format.

This method returns B<self>, to allow method chaining.

=head3 read(Str $filename --> Math::Libgsl::Histogram2D)

This method reads the ranges and bins of the current histogram from a file in binary format.

This method returns B<self>, to allow method chaining.

=head3 printf(Str $filename, Str $range-format, Str $bin-format --> Math::Libgsl::Histogram2D)

This function writes the ranges and bins of the current histogram line-by-line to a file using the format specifiers B<$range-format> and B<$bin-format>.

This method returns B<self>, to allow method chaining.

=head3 scanf(Str $filename --> Math::Libgsl::Histogram2D)

This function reads formatted data from a file.

The histogram must be preallocated with the correct length since the C library function uses the size of the current object to determine how many numbers to read.

This method returns B<self>, to allow method chaining.


=head2 Math::Libgsl::Histogram2D::PDF

=head3 new(UInt $nx!, UInt $ny!, Math::Libgsl::Histogram2D $h!)
=head3 new(UInt :$nx!, UInt :$ny!, Math::Libgsl::Histogram2D :$h!)

The constructor accepts three simple or named arguments: the probability distribution function x and y number of bins, and the histogram.

The histogram must not contain negative values, because a probability distribution cannot contain negative values.

=head3 sample(Num() $r1, Num() $r2 --> List)

This method uses two uniform random numbers between zero and one, B<$r1> and B<$r2>, to compute a single random sample from the two-dimensional probability distribution.

=head1 C Library Documentation

For more details on libgsl see L<https://www.gnu.org/software/gsl/>.

The excellent C Library manual is available here L<https://www.gnu.org/software/gsl/doc/html/index.html>, or here L<https://www.gnu.org/software/gsl/doc/latex/gsl-ref.pdf> in PDF format.

=head1 Prerequisites

This module requires the libgsl library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux and Ubuntu 20.04

=begin code
sudo apt install libgsl23 libgsl-dev libgslcblas0
=end code

That command will install libgslcblas0 as well, since it's used by the GSL.

=head2 Ubuntu 18.04

libgsl23 and libgslcblas0 have a missing symbol on Ubuntu 18.04.

I solved the issue installing the Debian Buster version of those three libraries:

=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgslcblas0_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl-dev_2.5+dfsg-6_amd64.deb>

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::Libgsl::Histogram
=end code

=head1 AUTHOR

Fernando Santagata <nando.santagata@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
