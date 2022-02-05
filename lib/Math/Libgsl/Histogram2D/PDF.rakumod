use v6;

unit class Math::Libgsl::Histogram2D::PDF:ver<0.0.2>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Raw::Histogram;
use Math::Libgsl::Histogram2D;

has gsl_histogram2d_pdf $.hpdf;

multi method new(UInt $nx!, UInt $ny!, Math::Libgsl::Histogram2D $h!)  { self.bless(:$nx, :$ny, :$h) }
multi method new(UInt :$nx!, UInt :$ny!, Math::Libgsl::Histogram2D :$h!) { self.bless(:$nx, :$ny, :$h) }
submethod BUILD(UInt :$nx, UInt :$ny, Math::Libgsl::Histogram2D :$h) {
  $!hpdf = gsl_histogram2d_pdf_alloc($nx, $ny);
  gsl_histogram2d_pdf_init($!hpdf, $h.h);
}
submethod DESTROY { gsl_histogram2d_pdf_free($!hpdf) }
method sample(Num() $r1, Num() $r2 --> List) {
  my num64 ($x, $y);
  gsl_histogram2d_pdf_sample($!hpdf, $r1, $r2, $x, $y);
  $x, $y;
}
