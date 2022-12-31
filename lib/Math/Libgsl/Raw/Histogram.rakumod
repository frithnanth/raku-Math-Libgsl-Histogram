use v6;

unit module Math::Libgsl::Raw::Histogram:ver<0.0.3>:auth<zef:FRITH>;

use NativeCall;

constant GSLHELPER  = %?RESOURCES<libraries/gslhelper>.absolute;

sub LIB {
  run('/sbin/ldconfig', '-p', :chomp, :out)
    .out
    .slurp(:close)
    .split("\n")
    .grep(/^ \s+ libgsl\.so\. \d+ /)
    .sort
    .head
    .comb(/\S+/)
    .head;
}

class gsl_histogram is repr('CStruct') is export {
  has size_t        $.n;
  has CArray[num64] $.range;
  has CArray[num64] $.bin;
}

class gsl_histogram_pdf is repr('CStruct') is export {
  has size_t        $.n;
  has CArray[num64] $.range;
  has CArray[num64] $.sum;
}

class gsl_histogram2d is repr('CStruct') is export {
  has size_t        $.nx;
  has size_t        $.ny;
  has CArray[num64] $.xrange;
  has CArray[num64] $.yrange;
  has CArray[num64] $.bin;
}

class gsl_histogram2d_pdf is repr('CStruct') is export {
  has size_t        $.nx;
  has size_t        $.ny;
  has CArray[num64] $.xrange;
  has CArray[num64] $.yrange;
  has CArray[num64] $.sum;
}

# Histogram 1D
# Histogram allocation
sub gsl_histogram_alloc(size_t $n --> gsl_histogram) is native(LIB) is export { * }
sub gsl_histogram_set_ranges(gsl_histogram $h, CArray[num64] $range, size_t $size --> int32) is native(LIB) is export { * }
sub gsl_histogram_set_ranges_uniform(gsl_histogram $h, num64 $xmin, num64 $xmax --> int32) is native(LIB) is export { * }
sub gsl_histogram_free(gsl_histogram $h) is native(LIB) is export { * }
sub gsl_histogram_calloc(size_t $n --> gsl_histogram) is native(LIB) is export { * }
sub gsl_histogram_calloc_uniform(size_t $n, num64 $xmin, num64 $xmax --> gsl_histogram) is native(LIB) is export { * }
sub gsl_histogram_calloc_range(size_t $n, CArray[num64] $range --> gsl_histogram) is native(LIB) is export { * }
# Copying histograms
sub gsl_histogram_memcpy(gsl_histogram $dest, gsl_histogram $source --> int32) is native(LIB) is export { * }
sub gsl_histogram_clone(gsl_histogram $source --> gsl_histogram) is native(LIB) is export { * }
# Updating and accessing histogram elements
sub gsl_histogram_increment(gsl_histogram $h, num64 $x --> int32) is native(LIB) is export { * }
sub gsl_histogram_accumulate(gsl_histogram $h, num64 $x, num64 $weight --> int32) is native(LIB) is export { * }
sub gsl_histogram_get(gsl_histogram $h, size_t $i --> num64) is native(LIB) is export { * }
sub gsl_histogram_get_range(gsl_histogram $h, size_t $i, num64 $lower is rw, num64 $upper is rw --> int32) is native(LIB) is export { * }
sub gsl_histogram_max(gsl_histogram $h --> num64) is native(LIB) is export { * }
sub gsl_histogram_min(gsl_histogram $h --> num64) is native(LIB) is export { * }
sub gsl_histogram_bins(gsl_histogram $h --> size_t) is native(LIB) is export { * }
sub gsl_histogram_reset(gsl_histogram $h) is native(LIB) is export { * }
# Search histogram ranges
sub gsl_histogram_find(gsl_histogram $h, num64 $x, size_t $i is rw --> int32) is native(LIB) is export { * }
# Histogram statistics
sub gsl_histogram_max_val(gsl_histogram $h --> num64) is native(LIB) is export { * }
sub gsl_histogram_max_bin(gsl_histogram $h --> size_t) is native(LIB) is export { * }
sub gsl_histogram_min_val(gsl_histogram $h --> num64) is native(LIB) is export { * }
sub gsl_histogram_min_bin(gsl_histogram $h --> size_t) is native(LIB) is export { * }
sub gsl_histogram_mean(gsl_histogram $h --> num64) is native(LIB) is export { * }
sub gsl_histogram_sigma(gsl_histogram $h --> num64) is native(LIB) is export { * }
sub gsl_histogram_sum(gsl_histogram $h --> num64) is native(LIB) is export { * }
# Histogram operations
sub gsl_histogram_equal_bins_p(gsl_histogram $h1, gsl_histogram $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram_add(gsl_histogram $h1, gsl_histogram $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram_sub(gsl_histogram $h1, gsl_histogram $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram_mul(gsl_histogram $h1, gsl_histogram $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram_div(gsl_histogram $h1, gsl_histogram $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram_scale(gsl_histogram $h, num64 $scale --> int32) is native(LIB) is export { * }
sub gsl_histogram_shift(gsl_histogram $h, num64 $offset --> int32) is native(LIB) is export { * }
# I/O
sub mgsl_histogram_fwrite(Str $filename, gsl_histogram $h --> int32) is native(GSLHELPER) is export { * }
sub mgsl_histogram_fread(Str $filename, gsl_histogram $h --> int32) is native(GSLHELPER) is export { * }
sub mgsl_histogram_fprintf(Str $filename, gsl_histogram $h, Str $range_format, Str $bin_format --> int32) is native(GSLHELPER) is export { * }
sub mgsl_histogram_fscanf(Str $filename, gsl_histogram $h --> int32) is native(GSLHELPER) is export { * }
# Histogram probability distribution
sub gsl_histogram_pdf_alloc(size_t $n --> gsl_histogram_pdf) is native(LIB) is export { * }
sub gsl_histogram_pdf_init(gsl_histogram_pdf $p, gsl_histogram $h --> int32) is native(LIB) is export { * }
sub gsl_histogram_pdf_free(gsl_histogram_pdf $p) is native(LIB) is export { * }
sub gsl_histogram_pdf_sample(gsl_histogram_pdf $p, num64 $r --> num64) is native(LIB) is export { * }
# Histogram 2D
# Histogram allocation
sub gsl_histogram2d_alloc(size_t $nx, size_t $ny --> gsl_histogram2d) is native(LIB) is export { * }
sub gsl_histogram2d_set_ranges(gsl_histogram2d $h, CArray[num64] $xrange, size_t $xsize, CArray[num64] $yrange, size_t $ysize --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_set_ranges_uniform(gsl_histogram2d $h, num64 $xmin, num64 $xmax, num64 $ymin, num64 $ymax --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_free(gsl_histogram2d $h) is native(LIB) is export { * }
sub gsl_histogram2d_calloc(size_t $nx, size_t $ny --> gsl_histogram2d) is native(LIB) is export { * }
sub gsl_histogram2d_calloc_uniform(size_t $nx, size_t $ny, num64 $xmin, num64 $xmax, num64 $ymin, num64 $ymax --> gsl_histogram2d) is native(LIB) is export { * }
sub gsl_histogram2d_calloc_range(size_t $n, CArray[num64] $range --> gsl_histogram2d) is native(LIB) is export { * }
# Copying histograms
sub gsl_histogram2d_memcpy(gsl_histogram2d $dest, gsl_histogram2d $source --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_clone(gsl_histogram2d $source --> gsl_histogram2d) is native(LIB) is export { * }
# Updating and accessing histogram elements
sub gsl_histogram2d_increment(gsl_histogram2d $h, num64 $x, num64 $y --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_accumulate(gsl_histogram2d $h, num64 $x, num64 $y, num64 $weight --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_get(gsl_histogram2d $h, size_t $i, size_t $j --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_get_xrange(gsl_histogram2d $h, size_t $i, num64 $xlower is rw, num64 $xupper is rw --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_get_yrange(gsl_histogram2d $h, size_t $j, num64 $ylower is rw, num64 $yupper is rw --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_xmax(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_xmin(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_ymax(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_ymin(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_nx(gsl_histogram2d $h --> size_t) is native(LIB) is export { * }
sub gsl_histogram2d_ny(gsl_histogram2d $h --> size_t) is native(LIB) is export { * }
sub gsl_histogram2d_reset(gsl_histogram2d $h) is native(LIB) is export { * }
# Search histogram ranges
sub gsl_histogram2d_find(gsl_histogram2d $h, num64 $x, num64 $y, size_t $i is rw, size_t $j is rw --> int32) is native(LIB) is export { * }
# Histogram statistics
sub gsl_histogram2d_max_val(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_max_bin(gsl_histogram2d $h, size_t $i is rw, size_t $j is rw) is native(LIB) is export { * }
sub gsl_histogram2d_min_val(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_min_bin(gsl_histogram2d $h, size_t $i is rw, size_t $j is rw) is native(LIB) is export { * }
sub gsl_histogram2d_xmean(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_ymean(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_xsigma(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_ysigma(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_cov(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
sub gsl_histogram2d_sum(gsl_histogram2d $h --> num64) is native(LIB) is export { * }
# Histogram operations
sub gsl_histogram2d_equal_bins_p(gsl_histogram2d $h1, gsl_histogram2d $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_add(gsl_histogram2d $h1, gsl_histogram2d $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_sub(gsl_histogram2d $h1, gsl_histogram2d $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_mul(gsl_histogram2d $h1, gsl_histogram2d $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_div(gsl_histogram2d $h1, gsl_histogram2d $h2 --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_scale(gsl_histogram2d $h, num64 $scale --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_shift(gsl_histogram2d $h, num64 $offset --> int32) is native(LIB) is export { * }
# I/O
sub mgsl_histogram2d_fwrite(Str $filename, gsl_histogram2d $h --> int32) is native(GSLHELPER) is export { * }
sub mgsl_histogram2d_fread(Str $filename, gsl_histogram2d $h --> int32) is native(GSLHELPER) is export { * }
sub mgsl_histogram2d_fprintf(Str $filename, gsl_histogram2d $h, Str $range_format, Str $bin_format --> int32) is native(GSLHELPER) is export { * }
sub mgsl_histogram2d_fscanf(Str $filename, gsl_histogram2d $h --> int32) is native(GSLHELPER) is export { * }
# Histogram probability distribution
sub gsl_histogram2d_pdf_alloc(size_t $nx, size_t $ny --> gsl_histogram2d_pdf) is native(LIB) is export { * }
sub gsl_histogram2d_pdf_init(gsl_histogram2d_pdf $p, gsl_histogram2d $h --> int32) is native(LIB) is export { * }
sub gsl_histogram2d_pdf_free(gsl_histogram2d_pdf $p) is native(LIB) is export { * }
sub gsl_histogram2d_pdf_sample(gsl_histogram2d_pdf $p, num64 $r1, num64 $r2, num64 $x is rw, num64 $y is rw --> int32) is native(LIB) is export { * }
