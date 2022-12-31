use v6;

unit class Math::Libgsl::Histogram2D:ver<0.0.3>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Raw::Histogram;

has gsl_histogram2d $.h;

# Histogram allocation
multi method new(UInt $nx!, UInt $ny!)  { self.bless(:$nx, :$ny) }
multi method new(UInt :$nx!, UInt :$ny!) { self.bless(:$nx, :$ny) }
multi method new(gsl_histogram :$histogram!) { self.bless(:$histogram) }
submethod BUILD(UInt :$nx?, UInt :$ny?, gsl_histogram2d :$histogram?) {
  with   $nx && $ny { $!h = gsl_histogram2d_calloc($nx, $ny) }
  orwith $histogram { $!h = $histogram }
  else              { fail X::Libgsl.new: errno => GSL_FAILURE, error => "Can't initialize object'" }
}
submethod DESTROY { gsl_histogram2d_free($!h) }

method set-ranges(:@xranges where *.elems == self.nx + 1, :@yranges where *.elems == self.ny + 1 --> Math::Libgsl::Histogram2D) {
  my CArray[num64] $xranges .= new: @xranges».Num;
  my CArray[num64] $yranges .= new: @yranges».Num;
  my $ret = gsl_histogram2d_set_ranges($!h, $xranges, @xranges.elems, $yranges, @yranges.elems);
  fail X::Libgsl.new: errno => $ret, error => "Can't set histogram ranges" if $ret ≠ GSL_SUCCESS;
  self
}
method set-uniform(Num() $xmin, Num() $xmax where * > $xmin, Num() $ymin, Num() $ymax where * > $ymin --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_set_ranges_uniform($!h, $xmin, $xmax, $ymin, $ymax);
  fail X::Libgsl.new: errno => $ret, error => "Can't set uniform histogram ranges" if $ret ≠ GSL_SUCCESS;
  self
}
# Updating and accessing histogram elements
method increment(Num() $x, Num() $y --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_increment($!h, $x, $y);
  fail X::Libgsl.new: errno => $ret, error => "Can't increment the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method accumulate(Num() $x, Num() $y, Num() $weight --> Math::Libgsl::Histogram2D){
  my $ret = gsl_histogram2d_accumulate($!h, $x, $y, $weight);
  fail X::Libgsl.new: errno => $ret, error => "Can't accumulate into the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method get(Int $i, Int $j --> Num) { gsl_histogram2d_get($!h, $i, $j) }
method get-xrange(Int $i --> List) {
  my num64 ($lower, $upper);
  my $ret = gsl_histogram2d_get_xrange($!h, $i, $lower, $upper);
  fail X::Libgsl.new: errno => $ret, error => "Can't read bin range" if $ret ≠ GSL_SUCCESS;
  return $lower, $upper;
}
method get-yrange(Int $i --> List) {
  my num64 ($lower, $upper);
  my $ret = gsl_histogram2d_get_yrange($!h, $i, $lower, $upper);
  fail X::Libgsl.new: errno => $ret, error => "Can't read bin range" if $ret ≠ GSL_SUCCESS;
  return $lower, $upper;
}
method xmax(--> Num) { gsl_histogram2d_xmax($!h) }
method xmin(--> Num) { gsl_histogram2d_xmin($!h) }
method ymax(--> Num) { gsl_histogram2d_ymax($!h) }
method ymin(--> Num) { gsl_histogram2d_ymin($!h) }
method nx(--> UInt)  { gsl_histogram2d_nx($!h) }
method ny(--> UInt)  { gsl_histogram2d_ny($!h) }
method reset()       { gsl_histogram2d_reset($!h) }
# Search histogram ranges
method find(Num() $x, Num() $y --> List) {
  my size_t ($i, $j);
  my $ret = gsl_histogram2d_find($!h, $x, $y, $i, $j);
  fail X::Libgsl.new: errno => $ret, error => "Can't find bin" if $ret ≠ GSL_SUCCESS;
  $i, $j;
}
# Copying histograms
method copy(Math::Libgsl::Histogram2D $src where { $src.nx == self.nx && $src.ny == self.ny } --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_memcpy($!h, $src.h);
  fail X::Libgsl.new: errno => $ret, error => "Can't copy the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method clone(--> Math::Libgsl::Histogram2D) {
  Math::Libgsl::Histogram2D.new: histogram => gsl_histogram2d_clone($!h)
}
# Statistics
method max-val(--> Num)  { gsl_histogram2d_max_val($!h) }
method min-val(--> Num)  { gsl_histogram2d_min_val($!h) }
method max-bin(--> List) {
  my size_t ($i, $j);
  gsl_histogram2d_max_bin($!h, $i, $j);
  return $i, $j;
}
method min-bin(--> List) {
  my size_t ($i, $j);
  gsl_histogram2d_min_bin($!h, $i, $j);
  return $i, $j;
}
method xmean(--> Num)  { gsl_histogram2d_xmean($!h) }
method ymean(--> Num)  { gsl_histogram2d_ymean($!h) }
method xsigma(--> Num) { gsl_histogram2d_xsigma($!h) }
method ysigma(--> Num) { gsl_histogram2d_ysigma($!h) }
method cov(--> Num)    { gsl_histogram2d_cov($!h) }
method sum(--> Num)    { gsl_histogram2d_sum($!h) }
# Histogram operations
method equal(Math::Libgsl::Histogram2D $h2 --> Bool) {
  gsl_histogram2d_equal_bins_p($!h, $h2.h) == 1 ?? True !! False
}
method add(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_add($!h, $h2.h);
  fail X::Libgsl.new: errno => $ret, error => "Can't add the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method sub(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_sub($!h, $h2.h);
  fail X::Libgsl.new: errno => $ret, error => "Can't subtract the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method mul(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_mul($!h, $h2.h);
  fail X::Libgsl.new: errno => $ret, error => "Can't multiply the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method div(Math::Libgsl::Histogram2D $h2 --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_div($!h, $h2.h);
  fail X::Libgsl.new: errno => $ret, error => "Can't divide the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method scale(Num() $scale --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_scale($!h, $scale);
  fail X::Libgsl.new: errno => $ret, error => "Can't scale the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method shift(Num() $offset --> Math::Libgsl::Histogram2D) {
  my $ret = gsl_histogram2d_shift($!h, $offset);
  fail X::Libgsl.new: errno => $ret, error => "Can't shift the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
# I/O
method write(Str $filename --> Math::Libgsl::Histogram2D) {
  my $ret = mgsl_histogram2d_fwrite($filename, $!h);
  fail X::Libgsl.new: errno => $ret, error => "Can't write the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method read(Str $filename --> Math::Libgsl::Histogram2D) {
  my $ret = mgsl_histogram2d_fread($filename, $!h);
  fail X::Libgsl.new: errno => $ret, error => "Can't read the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method printf(Str $filename, Str $range-format, Str $bin-format --> Math::Libgsl::Histogram2D) {
  my $ret = mgsl_histogram2d_fprintf($filename, $!h, $range-format, $bin-format);
  fail X::Libgsl.new: errno => $ret, error => "Can't print the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
method scanf(Str $filename --> Math::Libgsl::Histogram2D) {
  my $ret = mgsl_histogram2d_fscanf($filename, $!h);
  fail X::Libgsl.new: errno => $ret, error => "Can't scan the histogram" if $ret ≠ GSL_SUCCESS;
  self
}
